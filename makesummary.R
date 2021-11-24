
library(tidyverse)

system("
grep 'Est' ./*/outs/metrics_summary.csv | head -1 | sed 's/.*csv:/Library ID,/' > all_summary.csv;
grep -v 'Est' ./*/outs/metrics_summary.csv | sed 's/\\/outs.*csv:/,/;s/\\.\\///' >> all_summary.csv
")


aa <- read_csv("all_summary.csv")

write_tsv(aa[,c(1:7,18:20,11,16,17)],"summary.tsv")
print(aa[,c(1:5)])
