#! /bin/sh -
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=16:mem=64gb 

# This script performs ATAC-seq quality control,
# mapping, peak calling and makes BigWigs.

export LC_ALL=C

# Load modules
module load anaconda3/personal
source activate rnaseq 

DBG=0
CMD=''
if [ $DBG = 1 ] ; then
  CMD=echo
  
fi

set -x

PBS_O_WORKDIR=${PBS_O_WORKDIR:-.}
cd $PBS_O_WORKDIR

# Constants
filename1_suffix="_R1_val_1.fq.gz"
filename2_suffix="_R2_val_2.fq.gz"
BLACKLIST=${HOME}/../projects/kklf/live/genomes/hg38-blacklist.v2.bed

# Run fastqc
mkdir -p ./fastqc 
$CMD fastqc *.fastq.gz --outdir ./fastqc

# Run trim_galore
mkdir -p ./trim 
$CMD trim_galore --paired --stringency 3 --output_dir ./trim ./*.fastq.gz

# Run bowtie2
mkdir -p ./mapped 


for filename1 in `ls ./trim/*"${filename1_suffix}"` ; do

  fileroot=`basename "${filename1}" "${filename1_suffix}"`
  DIR=`dirname ${filename1}`
  filename2="${DIR}/${fileroot}${filename2_suffix}" 


  # Create the output SAM file 
  output_sam="mapped/${fileroot}.sam"


  # Run bowtie 
  $CMD bowtie2 -p 4 -x /rds/general/user/zwk22/projects/kklf/live/genomes/bowtie2/hg38 \
    -1 "$filename1" \
    -2 "$filename2" \
    -S "$output_sam" --local --very-sensitive-local --no-unal --no-mixed --no-discordant --phred33   -I 50 -X 1000

done

# Create a bam file and re-index 

for filename in `ls ./mapped/*.sam` ; do 

  fn2=$(basename "$filename" .sam)
  fn3="./mapped/${fn2}.bam"
  fn4="./mapped/${fn2}.sorted.bam"

  $CMD samtools view -bS $filename > $fn3
  $CMD samtools sort $fn3 -o $fn4
  $CMD samtools index $fn4

done 


rm ./mapped/*.sam

# Remove duplicates
mkdir -p ./rmdup

for filename in `ls ./mapped/*.sorted.bam` ; do
  fn1=$(basename "$filename" sorted.bam)
  outname="./rmdup/"$fn1"filtered.sorted.bam"
  metname="./rmdup/"$fn1"metrics.txt"
  bedname="./rmdup/"$fn1"blacklist.sorted.bam"


  $CMD picard \
    MarkDuplicates I=$filename \
    O=$outname \
    M=$metname \
    REMOVE_DUPLICATES=true


  $CMD bedtools intersect -v -abam $outname \
    -b ${BLACKLIST} \
    > $bedname
done 

for filename in `ls ./rmdup/*blacklist.sorted.bam` ; do 
  $CMD samtools index $filename
done 

# Peak calling with Macs2 

mkdir -p ./tag
mkdir -p ./macs2

for filename in `ls ./rmdup/*blacklist.sorted.bam` ; do 
  base_name=`basename "$filename" .blacklist.sorted.bam`
  tag_name="./tag/"$base_name
  outname=$tag_name"/"$base_name".txt"
  input=`ls ./tag/*Input/`

  $CMD macs2 callpeak \
  -t $filename \
  -c $input \
  -f BAM \
  -g 1.3e+8 \
  -n $outname \
  --outdir ./macs2

  $CMD makeTagDirectory $tag_name $filename

  $CMD makeBigWig.pl $tag_name hg38 -webdir $tag_name -url https://crumpdata.med.ic.ac.uk/zuzanna/
done