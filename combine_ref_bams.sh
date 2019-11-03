#!/bin/bash
#SBATCH -J make_combined_bam  #job name for array
#SBATCH -n 1     # Number of cores
#SBATCH -N 1                    # Ensure that all cores are on one machine
#SBATCH -t 0-05:00              # Runtime in D-HH:MM
#SBATCH -p serial_requeue       # Partition to submit to
#SBATCH --mem=16000               # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o ../shell_outputs/make_combined_bam.out      # File to which STDOUT will be written
#SBATCH -e ../shell_outputs/make_combined_bam.err      # File to which STDERR will be written
#SBATCH --mail-type=ALL              # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=milo.s.johnson.13@gmail.com  # Email to which notifications will be sent

module load samtools
PICARD_HOME=/n/sw/fasrcsw/apps/Core/picard/2.9.0-fasrc01
module load jdk/1.8.0_45-fasrc01

samtools merge combined_ref.bam ../tmp_work/*final.bam 

java -Xmx4g -XX:ParallelGCThreads=1 -jar $PICARD_HOME/picard.jar SortSam I=combined_ref.bam O=combined_ref.final.bam SORT_ORDER=coordinate CREATE_INDEX=true 2> ../logs/combined_ref_sorting.log

java -Xmx4g -XX:ParallelGCThreads=1 -jar $PICARD_HOME/picard.jar ValidateSamFile I=combined_ref.final.bam O=combined_ref.validate.txt MODE=SUMMARY 2> ../logs/combined_ref_validate.log
