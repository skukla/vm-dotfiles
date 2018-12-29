#!/bin/bash
clear
printf "Warming the Luma cache...\n"
wget --quiet "http://luma.com/pub/luma.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done
clear
printf "Warming the Venia cache...\n"
wget --quiet "http://luma.com/pub/venia.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done
clear
printf "Warming the Custom cache...\n"
wget --quiet "http://luma.com/pub/custom.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done