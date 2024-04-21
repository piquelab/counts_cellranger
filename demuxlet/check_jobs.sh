tail -n 1 slurm.SCAIP* | sed '/^[[:space:]]*$/d' | sed 'N;s/.out <==\nNOTICE/ /' | grep -v Finished 
