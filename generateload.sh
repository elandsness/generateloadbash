#!/bin/bash

numProcs=$(nproc 2>&1)
numProcs=$((numProcs+1))
if [ ! -z $2 ]; then
   numProcs=$2
fi

duration=60
if [ ! -z $3 ]; then
   duration=$3
fi

#setup bashtrap
trap bashtrap INT

#function to clean up
function cleanup {
   echo "Cleaning up..."
   killall -9 curl
}

#cleanup if canceled early
bashtrap(){
   echo "Load generation canceled."
}

if [ "$1" = '-h' ] || [ -z "$1" ]; then
   echo "Usage: $0 https://somewebsite.com <number threads> <duration in seconds>"
else
   if [[ ${1:0:4} == "http" ]] ; then
      site=$1
   else
      site="http://${1}"
   fi
   for i in `seq 1 $numProcs`
   do
      echo "Spawning process ${i} against ${site}"
      curl -s -X POST "${site}?yay=[1-999999999]"  >> /dev/null &
   done

   echo "Running for $duration seconds"
   sleep $duration
   cleanup
   echo "Done!"
fi
