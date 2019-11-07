#!/bin/bash
#PBS -q highmem_q                                                          
#PBS -N custom_species_abundance                                          
#PBS -l nodes=1:ppn=12 -l mem=700gb                                        
#PBS -l walltime=200:00:00                                                
#PBS -M rx32940@uga.edu                                                  
#PBS -m abe                                                              
#PBS -o /scratch/rx32940/CLARK                       
#PBS -e /scratch/rx32940/CLARK                         
#PBS -j oe     

path="/scratch/rx32940"
data_path="/scratch/rx32940/Metagenomic_taxon_profile/Data/01.Data/hostclean"

# set up the database
# $path/CLARK/CLARKSCV1.2.6.1/set_targets.sh $path/CLARK/DB custom --genus
# $path/CLARK/CLARKSCV1.2.6.1/set_targets.sh $path/CLARK/DB custom --phylum
$path/CLARK/CLARKSCV1.2.6.1/set_targets.sh $path/CLARK/DB custom --species
# $path/CLARK/CLARKSCV1.2.6.1/set_targets.sh $path/CLARK/DB bacteria viruses --species
# $path/CLARK/CLARKSCV1.2.6.1/set_targets.sh $path/CLARK/DB bacteria viruses --phylum
# $path/CLARK/CLARKSCV1.2.6.1/set_targets.sh $path/CLARK/DB bacteria viruses --genus

echo "set target done"


# database of discriminative 31-mers
# couldn't get a list of fastq files to run together, try to run individually now

for file in $data_path/*; do
    sample=$(basename "$file")
    $path/CLARK/CLARKSCV1.2.6.1/classify_metagenome.sh -P $data_path/$sample/${sample}_1_kneaddata_paired_1.fastq $data_path/$sample/${sample}_1_kneaddata_paired_2.fastq -R /scratch/rx32940/CLARK/output/custom/genus/regular/$sample.txt
done

#$path/CLARK/CLARKSCV1.2.6.1/classify_metagenome.sh -P $path/Metagenomic_taxon_profile/Data/01.Data/hostclean/R27.K/R27.K_1_kneaddata_paired_1.fastq $path/Metagenomic_taxon_profile/Data/01.Data/hostclean/R27.K/R27.K_1_kneaddata_paired_2.fastq -R /scratch/rx32940/CLARK/output/prebuilt/species/regular/R27.K.txt

echo "classify_metagenome done"

#analyze result from regular clark
for file in /scratch/rx32940/CLARK/output/custom/species/regular/*; do 
   sample_csv=$(basename "$file" ".txt.csv")
  $path/CLARK/CLARKSCV1.2.6.1/estimate_abundance.sh -F /scratch/rx32940/CLARK/output/custom/species/regular/$sample_csv.txt.csv -D $path/CLARK/DB > /scratch/rx32940/CLARK/output/abundance/species/${sample_csv}_abundance.txt
done

echo "regular abundance estimation done"

# databases of discriminative spaced 31-mers
cd /scratch/rx32940/CLARK/CLARKSCV1.2.6.1/./
./buildSpacedDB.sh

echo "spaced database built"

for file in $data_path/*; do
    sample=$(basename "$file")
    $path/CLARK/CLARKSCV1.2.6.1/classify_metagenome.sh -n 12 -P $data_path/$sample/${sample}_1_kneaddata_paired_1.fastq $data_path/$sample/${sample}_1_kneaddata_paired_2.fastq -R /scratch/rx32940/CLARK/output/custom/species/spaced/${sample}_spaced --spaced
done
# $path/CLARK/CLARKSCV1.2.6.1/classify_metagenome.sh -n 12 -P $path/Metagenomic_taxon_profile/Data/01.Data/hostclean/R22.K/R22.K_1_kneaddata_paired_1.fastq $path/Metagenomic_taxon_profile/Data/01.Data/hostclean/R22.K/R22.K_1_kneaddata_paired_2.fastq -R /scratch/rx32940/CLARK/output/prebuilt/species/spaced/R22.K_spaced --spaced

echo "spaced classification done"

#analyze result from spaced clark
for file in /scratch/rx32940/CLARK/output/custom/species/spaced/*; do 
   sample_csv=$(basename "$file" "_spaced.csv")
  $path/CLARK/CLARKSCV1.2.6.1/estimate_abundance.sh -F /scratch/rx32940/CLARK/output/custom/species/spaced/${sample_csv}_spaced.csv -D $path/CLARK/DB > /scratch/rx32940/CLARK/output/spaced_abundance/species/${sample_csv}_spaced_abundance.txt
done

echo "spaced abundance estimation done"