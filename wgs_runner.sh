#!/bin/bash
#SBATCH -J wgs_pipe  #job name for array
#SBATCH -n 2                    # Number of cores
#SBATCH -N 1                    # Ensure that all cores are on one machine
#SBATCH -t 0-02:30              # Runtime in D-HH:MM
#SBATCH -p serial_requeue       # Partition to submit to
#SBATCH --mem=4000               # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o ../shell_outputs/wgs_pipe_%A_%a.out      # File to which STDOUT will be written
#SBATCH -e ../shell_outputs/wgs_pipe_%A_%a.err      # File to which STDERR will be written
#SBATCH --mail-type=ALL              # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=milo.s.johnson.13@gmail.com  # Email to which notifications will be sent

# Getting sample name
SAMP=$(sed -n ${SLURM_ARRAY_TASK_ID}'{p;q}' Samples.txt)

# 1 TRIMMING
# NGmerge (only good for paired-end data)

module load NGmerge/0.2-fasrc01

NGmerge -1 ../../raw_reads/${SAMP}_S${SLURM_ARRAY_TASK_ID}_R1_001.fastq.gz -2 ../../raw_reads/${SAMP}_S${SLURM_ARRAY_TASK_ID}_R2_001.fastq.gz -a -v -o ../tmp_work/${SAMP}.trimmed

# 2 ALIGNMENT AGAINST A REFERENCE GENOME
# BWA: more suitable than Bowtie2 when GATK is used downstream  # because both BWA and GATK were created at Broad (same people)

module load bwa/0.7.15-fasrc02

# mem is the BWA function for alignment

bwa mem -M -t 1 -R "@RG\tID:HJ25MBGXC\tSM:${SAMP}\tPL:ILLUMINA" w303_ref ../tmp_work/${SAMP}.trimmed_1.fastq.gz ../tmp_work/${SAMP}.trimmed_2.fastq.gz > ../tmp_work/${SAMP}.sam 2> ../logs/${SAMP}.bwa.log

# 3 CONVERSION FROM SAM TO BAM FILE
# can be done with Samtools or Picard
# here Picard is used and data are also sorted and indexed
# Picard runs on java

module load jdk/1.8.0_45-fasrc01
PICARD_HOME=/n/sw/fasrcsw/apps/Core/picard/2.9.0-fasrc01

java -Xmx4g -XX:ParallelGCThreads=1 -jar $PICARD_HOME/picard.jar SortSam I=../tmp_work/${SAMP}.sam O=../tmp_work/${SAMP}.sorted.bam SORT_ORDER=coordinate CREATE_INDEX=true

# 4 MARKING DUPLICATES
# also performed with Picard

java -Xmx4g -XX:ParallelGCThreads=1 -jar $PICARD_HOME/picard.jar MarkDuplicates I=../tmp_work/${SAMP}.sorted.bam O=../tmp_work/${SAMP}.dedup.bam METRICS_FILE=../tmp_work/${SAMP}.dedup_metrics.txt REMOVE_DUPLICATES=false TAGGING_POLICY=All 2> ../logs/${SAMP}_dedup.log

# 5 RESORTING AND REINDEXING
# SortSam (Picard) needs to be run again

java -Xmx4g -XX:ParallelGCThreads=1 -jar $PICARD_HOME/picard.jar SortSam I=../tmp_work/${SAMP}.dedup.bam O=../tmp_work/${SAMP}.final.bam SORT_ORDER=coordinate CREATE_INDEX=true 2> ../logs/${SAMP}_final_sorting.log

# 6 VALIDATING THE BAM FILES
# also performed with Picard

java -Xmx4g -XX:ParallelGCThreads=1 -jar $PICARD_HOME/picard.jar ValidateSamFile I=../tmp_work/${SAMP}.final.bam O=../tmp_work/${SAMP}.validate.txt MODE=SUMMARY 2> ../logs/${SAMP}_validate.log
 --min-dangling-branch-length 1
