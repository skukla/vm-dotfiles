#!/bin/bash
clear
printf "Warming the Luma cache...\n"
sleep 1
wget --quiet "http://luma.com/pub/luma.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done
printf "done."
sleep 1
clear
printf "Warming the Venia cache...\n"
sleep 1
wget --quiet "http://luma.com/pub/venia.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done
printf "done."
sleep 1
clear
printf "Warming the Custom B2C cache...\n"
sleep 1
wget --quiet "http://luma.com/pub/custom_b2c.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done
sleep 1
printf "done.\n"
clear
printf "Warming the Custom B2B cache...\n"
sleep 1
wget --quiet "http://b2b.luma.com/pub/custom_b2b.xml" --no-cache --output-document - | egrep -o "http://luma.com[^<]+" | while read line; do
    time curl -A 'Cache Warmer' -s -L $line > /dev/null 2>&1
    echo $line
done
sleep 1
printf "done.\n"