#!/bin/bash

if [ ! -r packaging/installer/kickstart.sh ] || [ ! -w packaging/installer/methods/kickstart.md ]; then
    exit 127
fi

checksum="$(md5sum packaging/installer/kickstart.sh | cut -f 1 -d ' ')"

sed -e "s/^\[ \".*\" = \"\(.*\)$/[ \"${checksum}\" = \"\1/" packaging/installer/methods/kickstart.md > tmp
mv tmp packaging/installer/methods/kickstart.md
