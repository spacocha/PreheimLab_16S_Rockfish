#!/bin/sh
#
##SBATCH --job-name=QIIME2_single
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --partition=bigmem

module load qiime2/2023.5.1

source ./mock_community_analysis.config

#echo the time for each
echo "Starting mock community analysis"
date

qiime feature-table filter-samples --i-table $TABLE --m-metadata-file ${Mock_sample}  --o-filtered-table ${PREFIX}_mock_only.qza

qiime tools export --input-path ${PREFIX}_mock_only.qza --output-path ${PREFIX}_mock_only_feature_table

qiime tools export --input-path ${REPS} --output-path ${PREFIX}_rep-seqs

biom convert -i ${PREFIX}_mock_only_feature_table/feature-table.biom -o ${PREFIX}_mock_only_feature_table/feature-table.biom.txt --table-type "OTU table" --to-tsv

#These will only work if you have the path to scripts dir in PATH variable 
map2mock.pl ${MOCKFA} ${PREFIX}_rep-seqs/dna-sequences.fasta > ${PREFIX}_rep-seqs/dna-sequences.map

map2mock_mat.pl ${PREFIX}_rep-seqs/dna-sequences.map ${PREFIX}_mock_only_feature_table/feature-table.biom.txt ${MOCKFULL} > ${PREFIX}_mock_only_feature_table/feature-table.biom.fullconcs.map

cp ${PREFIX}_mock_only_feature_table/feature-table.biom.fullconcs.map ./Rfile

mock_corr.R 

mv ./corr.txt ${PREFIX}_mock_only_feature_table/feature-table.full.corr.txt

map2mock_mat.pl ${PREFIX}_rep-seqs/dna-sequences.map ${PREFIX}_mock_only_feature_table/feature-table.biom.txt ${MOCKGOOD} > ${PREFIX}_mock_only_feature_table/feature-table.biom.goodconcs.map

cp ${PREFIX}_mock_only_feature_table/feature-table.biom.goodconcs.map ./Rfile

mock_corr.R

mv ./corr.txt ${PREFIX}_mock_only_feature_table/feature-table.good.corr.txt
#At some point add x-y  plots to the mock_corr.R script

echo "End of script"
date

