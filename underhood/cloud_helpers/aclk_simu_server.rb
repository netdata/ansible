#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mqtt'
require 'concurrent'
require 'json'
require 'awesome_print'
require 'optparse'

#defaults in case not overwriten by commandline args
$options = {
  port: 1883,
  host: 'localhost',
  verbose: false
}

OptionParser.new do |parser|
  parser.on('-t', '--target HOST', String,
            "Host where the MQTT broker is running. Default=#{$options[:host]}") do |host|
    $options[:host] = host
  end
  parser.on('-p', '--port PORT', Integer,
            "Port where the MQTT broker is listening. Default=#{$options[:port]}") do |port|
    $options[:port] = port
  end
  parser.on("-v", "--[no-]verbose", "Verbose: Will pretty print JSON received.") do |v|
    $options[:verbose] = v
  end
end.parse!

$agents = Concurrent::Hash.new

def log_mqtt_msg(msg)
  ap msg if $options[:verbose]
end

$per_agent_subscribe_topics = [
  "data",
  "alarms"
]

class CloudSimulationServer
  def agent_known?(agent_id)
    $agents.has_key?(agent_id)
  end
  def register_new_agent(agent_id)
    puts "Registering new Agent with id \"#{agent_id}\""
    $agents[agent_id] = {
      state: :new,
    }
    $per_agent_subscribe_topics.each do |topic|
      @client.subscribe("/agent/#{agent_id}/#{topic}")
    end
    @client.publish("/agent/#{agent_id}/cmd", "data:chart=system.cpu&before=-10&after=100&format=json")
  end
  def handle_chart_metadata(agent_id, message)
    #expects agent exist check to be done at the higher lever in stack
    puts "Registering Chart \"#{message[:contents][:id]}\" for agent \"#{agent_id}\"."
    $agents[agent_id][:charts] = [] unless $agents[agent_id].has_key? :charts
    $agents[agent_id][:charts].push message[:contents]
  end
  def handle_meta_message(agent_id, topic, message)
    puts "An AGENT \"#{agent_id}\" sent meta(\"#{message[:type]}\")message. This agent is already known: #{agent_known?(agent_id)}."
    if !agent_known?(agent_id) && message[:type] != 'info'
      puts "Only 'info' message is allowed from agent we don't know about"
      log_mqtt_msg message
      return
    end
    case message[:type]
    when 'info'
      register_new_agent(agent_id) unless $agents.has_key? agent_id
      $agents[agent_id][:info] = message
      log_mqtt_msg $agents[agent_id][:info]
    when 'chart'
      handle_chart_metadata(agent_id, message)
      log_mqtt_msg message
    end
  end
  def run
    @client = MQTT::Client.connect($options[:host], $options[:port])
    @client.subscribe('/agent/+/meta')
    @client.get() do |topic, message|
      if topic =~ /^\/agent\/([^\/]*)\/meta/
        agent_id = Regexp.last_match(1)
        handle_meta_message(agent_id, topic, JSON.parse(message, symbolize_names: true))
        next
      end
      if topic =~ /^\/agent\/([^\/]*)\/data/
        agent_id = Regexp.last_match(1)
        puts "An AGENT \"#{agent_id}\" sent data #{}"
        log_mqtt_msg JSON.parse(message, symbolize_names: true)
        next
      end
      STDERR.puts "UNKNOWN MSG in topic \"#{topic}\":\n#{message}"
    end
  end
  def end
    @client.disconnect
  end
end

begin
  srv = CloudSimulationServer.new
  srv.run()
rescue Interrupt => e
  STDERR.puts "Interrupt received. Exiting..."
  srv.end()
  exit 0
end