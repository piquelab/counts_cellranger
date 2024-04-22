tail -n 1 slurm.* | sed '/^[[:space:]]*$/d' | sed 'N;s/.out <==\nProcessing/ /' | grep -v Finished 
