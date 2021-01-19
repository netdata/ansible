#!/usr/bin/env ruby

begin
    require 'yajl'
    require 'pastel'
rescue LoadError
    puts "Please install 'yajl-ruby' and 'pastel' dependencies."
    puts "Usually:"
    puts "    gem install yajl-ruby pastel"
    exit 1
end

$compulsory_aclk_keys = [
    :type,
    :version,
    :"msg-id"
]

$compulsory_aclk_v4_keys = [
    :mguid,
    :child
]

$pastel = Pastel.new

def print_help
    puts "Will parse STDIN stream as ACLK JSON messages and print them out with possibility to filter only certain message types."
    puts "To filter list all message types as parameters e.g.:"
    puts
    puts "\tjson_filter.rb \"child_connect\" \"child_disconnect\" \"connect\""
end

$msg_count = 0
$msg_filtered_count = 0
$msg_malformed_count = 0

if ARGV.size
    print_help if ARGV[0] == "-h" || ARGV[0] == "--help"
    $filter = ARGV
else
    $filter = nil
end

def log_aclk_message msg
    print "Got #{$pastel.green.bold(msg[:type])} v#{$pastel.bold(msg[:version])}"
    if msg[:version] >= 4
        puts ", mguid:\"#{$pastel.yellow(msg[:mguid])}\", child:#{$pastel.yellow(msg[:child])}"
    else
        puts
    end
end

def object_parsed json
    $compulsory_aclk_keys.each do |key|
        unless json.has_key?(key)
            puts $pastel.red "Doesn't look like ACLK message. JSON missing compulsory key \"#{key}\""
            $msg_malformed_count+=1
            return
        end
    end
    $compulsory_aclk_v4_keys.each do |key|
        unless json.has_key?(key)
            $msg_malformed_count+=1
            puts $pastel.red "Doesn't look like ACLK v4 message. JSON missing compulsory v4 key \"#{key}\""
            return
        end
    end if json[:version] >= 4

    $msg_count+=1

    if $filter.nil? || $filter.include?(json[:type])
        $msg_filtered_count+=1
        log_aclk_message(json)
    end
end

parser = Yajl::Parser.new(:symbolize_keys => true)
parser.on_parse_complete = method(:object_parsed)

def print_stats
    puts "Total ACLK messages: #{$msg_count}, Matching Filter: #{$msg_filtered_count}"
    STDERR.puts $pastel.red("Total malformed messages: #{$msg_malformed_count}") if $msg_malformed_count > 0
end

begin
    while true do
        parser << STDIN.readpartial(1000)
    end
rescue EOFError => e
    puts "EOF reached"
    print_stats
    exit 0
rescue Interrupt => i
    puts "Interrupted (probably CTRL+C)"
    print_stats
    exit 0
rescue Yajl::ParseError => e
    STDERR.puts "Input contains malformed JSON. Abort!"
    STDERR.puts e.inspect
    STDERR.puts e.backtrace
    exit 1
end
