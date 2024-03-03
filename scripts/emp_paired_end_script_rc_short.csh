#!/bin/sh
#
##SBATCH --job-name=QIIME2_single
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=parallel
#SBATCH --nodes=1

module load qiime2/2023.5.1

#cp single_config.txt to this folder
#edit variables according to analysis
#save them and this will use those in this analysis
source ./emp_paired_end_script.config

#echo the time for each
echo "Starting qiime2 analysis"
date
#import the demultiplexed data
echo "Starting import"
date
qiime tools import --type EMPPairedEndSequences --input-path $DATA --output-path ${PREFIX}.qza

#demultiplexing data
echo "Starting demux"
date
qiime demux emp-paired --i-seqs ${PREFIX}.qza --m-barcodes-file $METADATA --m-barcodes-column BarcodeSequence --p-rev-comp-mapping-barcodes --o-per-sample-sequences ${PREFIX}_demux.qza --o-error-correction-details ${PREFIX}_demux-details.qza --p-no-golay-error-correction
qiime demux summarize --i-data ${PREFIX}_demux.qza --o-visualization ${PREFIX}_demux.qzv
#use dada2 to remove sequencing errors
echo "Starting dada2"

date

qiime dada2 denoise-paired --i-demultiplexed-seqs ${PREFIX}_demux.qza --p-trim-left-f 23 --p-trim-left-r 23 --p-trunc-len-f 200 --p-trunc-len-r 200 --o-representative-sequences ${PREFIX}_reps.qza --o-table ${PREFIX}_dada2.qza --o-denoising-stats ${PREFIX}_stats-dada2.qza --p-n-reads-learn 10000
qiime feature-table summarize --i-table ${PREFIX}_dada2.qza --o-visualization ${PREFIX}_dada2_summarize.qzv --m-sample-metadata-file ${METADATA}

echo "End of script"
date
