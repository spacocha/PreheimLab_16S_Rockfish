#!/bin/sh
#
##SBATCH --job-name=QIIME2_single
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --partition=bigmem

module load qiime2/2023.5.1

#cp single_config.txt to this folder
#edit variables according to analysis
#save them and this will use those in this analysis
source ./emp_single_dada2_10fold-chimera.config

#echo the time for each
echo "Starting qiime2 analysis"
date

#import the demultiplexed data
echo "Starting import"
date
echo $TMPDIR
qiime tools import --type EMPSingleEndSequences --input-path $DATA --output-path ${PREFIX}.qza

#demultiplexing data
echo "Starting demux"
date
echo $TMPDIR
qiime demux emp-single --i-seqs ${PREFIX}.qza --m-barcodes-file $METADATA --m-barcodes-column BarcodeSequence --p-rev-comp-mapping-barcodes --o-per-sample-sequences ${PREFIX}_demux.qza
qiime demux summarize --i-data ${PREFIX}_demux.qza --o-visualization ${PREFIX}_demux.qzv


#use dada2 to remove sequencing errors
echo "Starting dada2"
date
echo $TMPDIR
qiime dada2 denoise-single --i-demultiplexed-seqs ${PREFIX}_demux.qza --p-trim-left 23 --p-trunc-len 125 --o-representative-sequences ${PREFIX}_reps.qza --o-table ${PREFIX}_dada2.qza --o-denoising-stats ${PREFIX}_stats-dada2.qza --p-n-threads 0 --p-min-fold-parent-over-abundance 10

echo "End of script"
date
