#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mqtt'
require 'json'
require 'colorize'

$verbose = false
$mqtt_host = '127.0.0.1'
$mqtt_port = 1883

def usage
    STDERR.puts "Usage: \"aclk_reply_hello.rb [min_aclk_version] [max_aclk_version]\""
end

if ARGV.size != 2
    STDERR.puts "2 arguments needed min and max version of protocol to pretend supporting".red
    usage
    exit 1
end

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

@client.subscribe("/agent/+/outbound/#")
begin
  @client.get() do |topic, message|
    json = JSON.parse(message, symbolize_names: true)
    if json[:type] == "hello"
      reply_topic = "/agent/#{topic.split('/')[2]}/inbound/cmd"
      msg = "{\"type\":\"version\",\"version\":1,\"min-version\":#{$min_ver},\"max-version\":#{$max_ver}}"
      STDERR.puts "Got \"hello\" message from agent with min=#{json[:"min-version"]}, max=#{json[:"max-version"]}".yellow
      STDERR.puts "Sending to \"#{reply_topic}\" reply:".yellow
      STDERR.puts JSON.pretty_generate(JSON.parse(msg))
      @client.publish(reply_topic, msg)
    elsif json[:type] == 'connect'
      STDERR.puts "Got \"connect\" from agent with version #{json[:version]}".yellow
    else
      puts "Got msg type \"#{json[:type]}\" ignoring." if $verbose
    end
  end
rescue Interrupt => e
    STDERR.puts "Interrupt received. Exiting...".green
    @client.disconnect
    exit 0
end
