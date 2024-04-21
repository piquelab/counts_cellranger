tail -n 1 slurm.* | sed '/^[[:space:]]*$/d' | sed 'N;s/.out <==\nNOTICE/ /' | grep -v Finished 
