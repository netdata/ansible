#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mqtt'
require 'concurrent'
require 'json'
require 'awesome_print'
require 'optparse'
require 'colorize'
require 'hexdump'

$agent_id = 'afb69b30-cb20-11ea-bb71-3085a98d4bee'
$total_queries = 10000

$t_count = `grep -i "query thread count" $NETDATA_INSTALL_PREFIX/netdata/etc/netdata/netdata.conf | awk '{ print $5; }'`
$t_count.chomp!

$req_v1 = <<-REQUEST
{"type":"http","version":1,"callback-topic":"/svc/agent-data-ctrl/callback","msg-id":"afb69b30-cb20-11ea-bb71-3085a98d4bee/c53d9aa6-e2cf-4d95-bb63-d491d04ffafc/data/1596042321983669351","payload":"/api/v1/data?chart=system.cpu\u0026_=1596042321857\u0026format=json\u0026points=420\u0026group=average\u0026gtime=0\u0026options=ms%7Cflip%7Cjsonwrap%7Cnonzero\u0026after=-300"}
REQUEST

@client = MQTT::Client.connect('127.0.0.1', 1883)
@client.subscribe("/agent/#{$agent_id}/outbound/meta")
@client.subscribe("/agent/#{$agent_id}/outbound/reply")
@client.subscribe("/svc/agent-data-ctrl/callback")
begin
  @client.get() do |topic, message|
    if topic == "/svc/agent-data-ctrl/callback"
        $replies+=1
        STDERR.puts "Got REPLY #{$replies} size #{message.size}".green if ($replies % ($total_queries/10)) == 0 || $replies == $total_queries
        if $replies == $total_queries
            STDERR.puts "Test with #{$t_count} RESULT>#{Time.now - $t_begin}".yellow
            exit 0
        end
    end

    json = JSON.parse(message, symbolize_names: true)
    if json[:type] == "connect"
      STDERR.puts "ON_CONNECT".red
      $replies = 0
      $t_begin = Time.now
      $total_queries.times do |i|
          @client.publish("/agent/#{$agent_id}/inbound/cmd", $req_v1);
      end
    end

#      STDERR.puts json[:type].blue
  end
rescue Interrupt => e
    STDERR.puts "Interrupt received. Exiting..."
    @client.disconnect
    exit 0
end