tail -n 1 slurm.* | sed '/^[[:space:]]*$/d' | sed 'N;s/.out <==\n/:: /' | grep -v Finished 

grep real slurm.* > real_time.txt
grep user slurm.* > user_time.txt

#paste real_time.txt user_time.txt

grep batch slurm.* | sed 's/slurm.//;s/.fd.out:/\t/;s/.batch.*//' \
    | while read jobname jobid; 
do 
    echo $jobname "<=="; 
    sacct -j $jobid --format=JobID,JobName,MaxRSS,CPUTime,UserCPU,TotalCPU,SystemCPU,AveCPU,CPUTimeRAW,MinCPU --parsable2 | grep batch 
done | sed 'N;s/<==\n/\|/' > batchinfo.txt

cat batchinfo.txt | cut -d'|' -f 1,4 | sed 's/.|/\t/' | awk -F"\t" '{ value = $2+0; suffix = substr($2, length($2)); if (suffix=="K") value /= (1024*1024); else if (suffix=="M") value /= 1024; else if (suffix!="G") value = -1; $2 = value; print }' > memory_usage.txt

