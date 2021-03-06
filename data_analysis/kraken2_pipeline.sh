#!/bin/bash
#PBS -q highmem_q                                                            
#PBS -N submit-rat                                      
#PBS -l nodes=1:ppn=1 -l mem=10gb                                        
#PBS -l walltime=300:00:00                                                
#PBS -M rx32940@uga.edu                                                  
#PBS -m abe                                                              
#PBS -o /scratch/rx32940/
#PBS -e /scratch/rx32940/                     
#PBS -j oe   

cd $PBS_O_WORKDIR
DBNAME="/scratch/rx32940/kraken2_052020/kraken2/kraken2_db"
seq_path="/scratch/rx32940/kraken2_052020"
DATABASE="/scratch/rx32940/kraken2_052020/kneaddata/ref_db"
outpath="/scratch/rx32940/kraken2_052020/kraken2"

###############################################################################
# 
# KneadData
# - Trimmomatic
# - Bowtie
# output:
# no pair end reads after host clean, all surviving reads found in the unmatched_1
# 
################################################################################

# # build database for host reference (refseq for R.rattus and R.norvegicus_Rnor_6.0) for kneaddate cleaning
# bowtie2-build $seq_path/kneaddata/reference_seq/GCF_000001895.5_Rnor_6.0_genomic.fna $seq_path/kneaddata/ref_db/Rnor_6.0
# bowtie2-build $seq_path/kneaddata/reference_seq/GCF_011064425.1_Rrattus_CSIRO_v1_genomic.fna $seq_path/kneaddata/ref_db/Rrattus

# # host clean with KneadData (downloaded to sapelo2 home dir: pip install --user kneaddate)


# for sample in $seq_path/Data/rawdata/*;
# do
#     (
#         sample_id="$(basename "$sample" | awk -F"." '{print $1}')"
#         tissue_id="$(basename "$sample")"
#         species="species"

#         if [ "$sample_id" == "R28" ] ; 
#         then 
#             species="Rrattus"
#         else 
#             species="Rnor_6.0"
#             fi

#         sapelo2_header="#PBS -q highmem_q\n#PBS -N hostclean_$tissue_id\n
#         #PBS -l nodes=1:ppn=12 -l mem=100gb\n
#         #PBS -l walltime=100:00:00\n
#         #PBS -M rx32940@uga.edu\n                                                  
#         #PBS -m abe\n                                                            
#         #PBS -o /scratch/rx32940\n                      
#         #PBS -e /scratch/rx32940\n                        
#         #PBS -j oe\n
#         "
#         echo $sample
#         echo $species

#         echo -e $sapelo2_header > $seq_path/qsub_kneaddata.sh 

#         modules="module load Bowtie2/2.3.5.1-foss-2018a\n
#         module load Trimmomatic/0.36-Java-1.8.0_144\n
#         module load FastQC/0.11.8-Java-1.8.0_144\n 
#         module load SAMtools/1.10-GCC-8.2.0-2.31.1"

#         echo -e $modules >> $seq_path/qsub_kneaddata.sh 
        
#         echo "kneaddata -t 12 -v --trimmomatic /usr/local/apps/eb/Trimmomatic/0.33-Java-1.8.0_144 \
#         --input $sample/*_1.fq.gz --input $sample/*_2.fq.gz \
#         -db $DATABASE/$species --output $seq_path/kneaddata/hostclean_self" >> $seq_path/qsub_kneaddata.sh
    
#         qsub $seq_path/qsub_kneaddata.sh

#         echo "submit $sample"
#     ) &

#     wait 
#     echo "waiting"
# done

###############################################################################
# 
# Kraken2-build (v2.0.9-beta)
# - standard database 
# - minikraken (minikraken_8GB_20200312)
# - custom database (includes two Rattus sequences)
# 
################################################################################

# # kraken2-2.0.8-beta most recent released version
# module load BLAST+/2.7.1-foss-2016b-Python-2.7.14

# # build kraken2 standard database 
# # changed kraken2 src according to this: https://github.com/DerrickWood/kraken/issues/114
# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --standard --threads 12 --db $DBNAME/standard
# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --build --threads 12 --db $DBNAME/standard

# added rattus to standard kraken2 custom database
# cp -r standard/ custom
# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --add-to-library $DBNAME/rattus_seq/GCF_000001895.5_Rnor_6.0_genomic.fna --db $DBNAME/custom
# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --add-to-library $DBNAME/rattus_seq/GCF_011064425.1_Rrattus_CSIRO_v1_genomic.fna --db $DBNAME/custom


# build custom db by adding rattus reference genomes
# best approach to ensure rsync works is to download each library one by one in an interactive session (open multiple interactive session)
# but final building step still need to submit a script
# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --download-taxonomy --db $DBNAME/rat_only 

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --download-library human --db $DBNAME/rat_only 

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --download-library bacteria --db $DBNAME/rat_only 

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --download-library archaea --db $DBNAME/rat_only 

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --download-library viral --db $DBNAME/rat_only 

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --download-library UniVec_Core --db $DBNAME/rat_only 

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --add-to-library $DBNAME/rattus_seq/GCF_000001895.5_Rnor_6.0_genomic.fna --db $DBNAME/rat_only

# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --add-to-library $DBNAME/rattus_seq/GCF_011064425.1_Rrattus_CSIRO_v1_genomic.fna --db $DBNAME/rat_only

# echo "adding done"
# /scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2-build --build --threads 24 --db $DBNAME/rat_only

###############################################################################
# 
# Kraken2
# - input:
#       hostcleaned sequences for each sample from Kneaddata output
# - DB: minikraken (minikraken_8GB_20200312)
# 
################################################################################

# cat /scratch/rx32940/kraken2_052020/kneaddata/metagenomic_samples.txt | \
# while read sample;
# do
#     (
#     # no longer read from dir, but from the list of a sample file
#     # sample="$(basename "$subject" | awk -F"_" '{print $1}')"

#     sapelo2_header="#PBS -q bahl_salv_q\n#PBS -N kraken2_${sample}_mini\n
#             #PBS -l nodes=1:ppn=24 -l mem=20gb\n
#             #PBS -l walltime=100:00:00\n
#             #PBS -M rx32940@uga.edu\n                                                  
#             #PBS -m abe\n                                                            
#             #PBS -o /scratch/rx32940\n                      
#             #PBS -e /scratch/rx32940\n                        
#             #PBS -j oe\n
#             "
#     echo $sample


#     echo -e $sapelo2_header > $seq_path/qsub_kraken2.sh
#     echo "/scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2 \
#     --use-names --db $DBNAME/minikraken_8GB_20200312 --threads 24 \
#     --report $outpath/mini_output/$sample.kreport \
#     --paired $seq_path/kneaddata/hostclean_seq/${sample}_1_kneaddata_paired_1.fastq \
#     $seq_path/kneaddata/hostclean_seq/${sample}_1_kneaddata_paired_2.fastq \
#     > $outpath/mini_output/$sample.txt" >> $seq_path/qsub_kraken2.sh

#     qsub $seq_path/qsub_kraken2.sh

#     ) & 

#     wait
#     echo "waiting"
# done

##############################################################################

# Kraken2
# - input:
#       hostcleaned unmatched_1 sequences for each sample from Kneaddata output
# - DB: standard DB (built on 6/10/2020)

###############################################################################

# cat /scratch/rx32940/kraken2_052020/kneaddata/metagenomic_samples.txt | \
# while read sample;
# do
#     (
#     # sample="$(basename "$subject" | awk -F"_" '{print $1}')"
#     # need large memory for each job to load the hash table
#     sapelo2_header="#PBS -q highmem_q\n#PBS -N kraken2_${sample}_standard\n
#             #PBS -l nodes=1:ppn=12 -l mem=150gb\n
#             #PBS -l walltime=100:00:00\n
#             #PBS -M rx32940@uga.edu\n                                                  
#             #PBS -m abe\n                                                            
#             #PBS -o /scratch/rx32940\n                      
#             #PBS -e /scratch/rx32940\n                        
#             #PBS -j oe\n
#             "
#     echo $sample


#     echo -e $sapelo2_header > $seq_path/qsub_kraken2.sh
#     echo "/scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2 \
#     --use-names --db $DBNAME/standard --threads 12 \
#     --report $outpath/standard_output/$sample.kreport \
#     --paired $seq_path/kneaddata/hostclean_seq/${sample}_1_kneaddata_paired_1.fastq \
#     $seq_path/kneaddata/hostclean_seq/${sample}_1_kneaddata_paired_2.fastq \
#     > $outpath/standard_output/$sample.txt" >> $seq_path/qsub_kraken2.sh

#     qsub $seq_path/qsub_kraken2.sh

#     ) & 

#     wait
#     echo "waiting"
# done

##############################################################################

# Kraken2
# - input:
#       hostcleaned unmatched_1 sequences for each sample from Kneaddata output
# - DB: custom DB (built on 6/22/2020)
# - added reference genomes for Rattus rattus and Rattus nor

###############################################################################

cat /scratch/rx32940/kraken2_052020/kneaddata/metagenomic_samples.txt | \
while read sample;
do
    (
    # sample="$(basename "$subject" | awk -F"_" '{print $1}')"
    # need large memory for each job to load the hash table
    sapelo2_header="#PBS -q highmem_q\n#PBS -N kraken2_${sample}_rat\n
            #PBS -l nodes=1:ppn=12 -l mem=150gb\n
            #PBS -l walltime=20:00:00\n
            #PBS -M rx32940@uga.edu\n                                                  
            #PBS -m abe\n                                                            
            #PBS -o /scratch/rx32940\n                      
            #PBS -e /scratch/rx32940\n                        
            #PBS -j oe\n
            "
    echo $sample


    echo -e $sapelo2_header > $seq_path/qsub_kraken2.sh
    echo "/scratch/rx32940/kraken2_052020/kraken2/kraken2-2.0.9-beta/kraken2 \
    --use-names --db $DBNAME/rat_only --threads 12 \
    --report $outpath/rat_only_output/$sample.kreport \
    --paired $seq_path/kneaddata/hostclean_seq/${sample}_1_kneaddata_paired_1.fastq \
    $seq_path/kneaddata/hostclean_seq/${sample}_1_kneaddata_paired_2.fastq \
    > $outpath/rat_only_output/$sample.txt" >> $seq_path/qsub_kraken2.sh

    qsub $seq_path/qsub_kraken2.sh

    ) & 

    wait
    echo "waiting"
done
