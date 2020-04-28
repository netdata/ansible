#!/usr/bin/env ruby

require 'json'
require 'faraday'
require 'colorize'
require 'open3'
require 'securerandom'

unless ENV.has_key? 'NETDATA_INSTALL_PREFIX'
    STDERR.puts "You must set environment var NETDATA_INSTALL_PREFIX to run this script"
    exit 1
end

class Claimer
    def initialize
        # TODO
        # temporary measure until the Traefik cookie thing gets sorted out
        # connect directly to service for now
        @con = Faraday.new 'http://127.0.0.1:9009'
        #@con = Faraday.new 'https://localhost:8443', :ssl => {:verify => false}
    end
    def post_req_json url, body = nil
        resp = @con.post(url) do |req|
            req.headers['Content-Type'] = 'application/json'
            req.headers['Netdata-Account-Id'] = '79ec6c46-d5ca-453a-9351-fc1a4326ee55'
            req.body = body unless body.nil?
        end
        if resp.headers['content-type'] !~ /^application\/json/
            return { result: false , log: "ERROR: Unexpected \"content-type\" #{resp.headers['content-type']}\nSTATUS: #{resp.status}\nBODY: #{resp.body}" }
        end
        retval = { result: resp.status == 201 , json_data: JSON.parse(resp.body, {:symbolize_names => true}), log: "STATUS: #{resp.status}\n" }
        retval[:log] += "BODY:\n"
        JSON.pretty_generate(retval[:json_data]).each_line do |line|
            retval[:log] += "\t#{line}"
        end
        return retval
    end
    def create_space
        retval = post_req_json('/api/v1/spaces', {name: 'my space'}.to_json)
        @space_id = retval[:json_data][:id] if retval[:result]
        return retval
    end
    def get_claiming_token
        retval = post_req_json("/api/v1/spaces/#{@space_id}/tokens")
        @token = retval[:json_data][:token] if retval[:result]
        return retval
    end
    def agent_claim
        cmd = "$NETDATA_INSTALL_PREFIX/netdata/usr/sbin/netdata-claim.sh -url=http://localhost:9009 -token=#{@token}"
        retval = { result: true, log: "OUTPUT of Claiming Script:\n" }
        Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
            while line = stdout_err.gets
                retval[:log] += "\t#{line}"
            end
            exit_status = wait_thr.value
            unless exit_status.success?
                retval[:result] = false
            end
        end
        return retval
    end
    def print_claimed_id
        fname = "#{ENV['NETDATA_INSTALL_PREFIX']}/netdata/etc/netdata/claim.d/claimed_id"
        unless File.file?(fname)
            return { result: false, log: "file \"claimed_id\" doesn't exist or is unreadable" }
        end
        { result: true, log: "CLAIMED_ID: \"#{File.read(fname)}\"" }
    end
end

claimer = Claimer.new

# to be quickly able to modify
# as we go
jobs = [
    :create_space,
    :get_claiming_token,
    :agent_claim,
    :print_claimed_id
]

jobs.each_with_index do |job, index|
    STDERR.print "[#{index+1}/#{jobs.size}] Running job \"#{job}\"... ".blue
    resp = claimer.send(job)
    STDERR.puts (resp[:result] ? "DONE".green : "FAIL".red)
    resp[:log].each_line do |line|
        puts "\t#{line}"
    end
    exit 1 unless resp[:result]
end

puts "☑ All Jobs Finished".green