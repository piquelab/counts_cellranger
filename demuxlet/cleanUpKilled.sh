grep Killed *.out | cut -d: -f1 | sort | uniq | xargs rm
