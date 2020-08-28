#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mqtt'
require 'json'
require 'colorize'

$verbose = false
$mqtt_host = '127.0.0.1'
$mqtt_port = 1883

$req_v2 = <<-REQUEST
{
  "type": "http",
  "version": 2,
  "callback-topic": "/svc/agent-data-ctrl/callback",
  "msg-id": "afb69b30-cb20-11ea-bb71-3085a98d4bee/c53d9aa6-e2cf-4d95-bb63-d491d04ffafc/data/1596042321983669351",
}\x0D\x0A\x0D\x0AGET /api/v1/data?chart=system.cpu&format=json&points=420&group=average&after=-300 HTTP/1.1\x0D\x0AAccept: application/json, text/plain, */*\x0D\x0AAccept-Encoding: gzip, deflate, br\x0D\x0A
REQUEST

def usage
    STDERR.puts "Usage: \"aclk_reply_hello.rb [min_aclk_version] [max_aclk_version]\""
end

if ARGV.size < 2
    STDERR.puts "2 arguments needed min and max version of protocol to pretend supporting".red
    usage
    exit 1
end

$send_v2_request = ARGV.size == 3 && ARGV[2].downcase == 'true'

$min_ver = ARGV[0].to_i
$max_ver = ARGV[1].to_i

if $min_ver <= 0 || $max_ver <= 0
    STDERR.puts "both parameters must be integers > 0".red
    usage
    exit 3
end

if $min_ver > $max_ver
    STDERR.puts "min ver must be less or equal to max ver".red
    usage
    exit 2
end

begin
  @client = MQTT::Client.connect($mqtt_host, $mqtt_port)
rescue Errno::ECONNREFUSED => e
  STDERR.puts "Connection to MQTT broker @ #{$mqtt_host}:#{$mqtt_port} failed.\nYou must first start MQTT broker before running this script.".red
  exit 4
end
STDERR.puts "Listening for \"hello\" message and replying with min, max = #{$min_ver}, #{$max_ver}".green
STDERR.puts "Will #{"NOT (default) " if !$send_v2_request}send v2 (compression) test query after connect."

@client.subscribe("/agent/+/outbound/#")
begin
  @client.get() do |topic, message|
    json = JSON.parse(message, symbolize_names: true)
    if json[:type] == "hello"
      reply_topic = "/agent/#{topic.split('/')[2]}/inbound/cmd"
      msg = "{\"type\":\"version\",\"version\":#{json[:version]},\"min-version\":#{$min_ver},\"max-version\":#{$max_ver}}"
      STDERR.puts "Got \"hello\" message from agent with min=#{json[:"min-version"]}, max=#{json[:"max-version"]}".yellow
      STDERR.puts "Sending to \"#{reply_topic}\" reply:".green
      STDERR.puts JSON.pretty_generate(JSON.parse(msg))
      @client.publish(reply_topic, msg)
      STDERR.puts "Wait for agent \"connect\" message. It might take some time due to popcorning etc.".green
    elsif json[:type] == 'connect'
      STDERR.puts "Got \"connect\" from agent with version #{json[:version]}".yellow
      if $send_v2_request
        if json[:version] >= 2 && $send_v2_request
          STDERR.puts "Sending V2 test query.".green
          @client.publish("/agent/#{topic.split('/')[2]}/inbound/cmd", $req_v2)
        else
          STDERR.puts "Will not send V2 test query as \"connect\" message received from agent is of too old version".red
        end
      end
      STDERR.puts ">>All Done<< You can restart The AGENT to test again. No need to restart this script (it will continue to listen). CTRL+C to end if you want to e.g. change parameters."
    else
      puts "Got msg type \"#{json[:type]}\" ignoring." if $verbose
    end
  end
rescue Interrupt => e
    STDERR.puts "Interrupt received. Exiting...".green
    @client.disconnect
    exit 0
end
