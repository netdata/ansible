# ACLK Test Server

This is small server to have something to emulate cloud.

## Installation

1. install `ruby` interpreter with development pkg *(`dnf install ruby ruby-devel` on fedora)*
1. install `mqtt` dependency using `gem install mqtt`
1. install `concurrent` dependency using `gem install concurrent-ruby`
1. run mqtt broker `mosquitto`
1. run with `ruby ./aclk_simu_server.rb`
1. start netdata agent `netdata -D`

## Usage

`ruby ./aclk_simu_server.rb -h` will give you latest help on usage. Currently this options are understood:
``` text
Usage: aclk_simu_server [options]
    -t, --target HOST                Host where the MQTT broker is running. Default=localhost
    -p, --port PORT                  Port where the MQTT broker is listening. Default=1883
    -v, --[no-]verbose               Verbose: Will pretty print JSON received.
```