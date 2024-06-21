
cat batchinfo.txt | cut -d'|' -f 1,5 | sed 's/.|/\t/' > CPUTime.txt
