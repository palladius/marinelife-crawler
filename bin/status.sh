#!/bin/bash

shopt -s extglob

white 'STATUS : Lets see how many fish in the Sea'

#echo -en '0: total fish DELETEME:'ls en.wikipedia.org/rubycrawl/* |wc -l

echo "1: 🎣 $(find en.wikipedia.org/rubycrawl/ | egrep -v .ric.yaml |wc -l|xargs ) Fish in the bucket (just fished fish): "
#    find en.wikipedia.org/rubycrawl/ | egrep -v .ric.yaml |wc -l

echo "2: 🍤 $(ls en.wikipedia.org/rubycrawl/*.ric.yaml |wc -l|xargs) Crunched fish in the pond (crunched fish): "

cd rails7-marinelife-app/ &&
    echo -en "3: 🍣 $(echo 'puts WikiAnimal.all.count; nil' | rails c 2>/dev/null | egrep '^[1234567890]') Fish in Ruby app: "


