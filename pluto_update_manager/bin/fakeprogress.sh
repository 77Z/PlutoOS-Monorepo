#!/bin/bash

# Fake script that simulates rauc updating

# how does the program handle this?
echo "garbage output, doesn't contain percentage!!"

for i in {0..100..1}; do
	echo "$i% complete."
	sleep 0.2
done
echo "Task finished."

# exit 1