#!/bin/sh
#
##SBATCH --job-name=QIIME2_single
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --partition=bigmem

module load qiime2/2023.5.1

#make sure to edit the merge_config.txt and put into the combined directory
source ./qiime2_merge_sequence.config

#echo the time for each
echo "Starting qiime2 two file merge"
date

#Check TMPDIR path is working
echo $TMPDIR
qiime feature-table merge --i-tables ${RUN1_DADA2} --i-tables ${RUN2_DADA2} --o-merged-table ${PREFIX}_dada2.qza
qiime feature-table merge-seqs --i-data ${RUN1_REPS} --i-data ${RUN2_REPS} --o-merged-data ${PREFIX}_reps.qza

qiime feature-table summarize --i-table ${PREFIX}_dada2.qza --o-visualization ${PREFIX}_dada2_summarize.qzv --m-sample-metadata-file ${METADATA}

echo "End of Script"
date

