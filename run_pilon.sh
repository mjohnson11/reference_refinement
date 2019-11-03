#!/bin/bash
#SBATCH -J pilon  #job name for array
#SBATCH -n 1     # Number of cores
#SBATCH -N 1                    # Ensure that all cores are on one machine
#SBATCH -t 0-10:00              # Runtime in D-HH:MM
#SBATCH -p serial_requeue       # Partition to submit to
#SBATCH --mem=67000               # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o ../shell_outputs/pilon.out      # File to which STDOUT will be written
#SBATCH -e ../shell_outputs/pilon.err      # File to which STDERR will be written
#SBATCH --mail-type=ALL              # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=milo.s.johnson.13@gmail.com  # Email to which notifications will be sent

module load jdk/1.8.0_45-fasrc01

java -Xmx66g -jar ~/pilon/pilon-1.23.jar --genome w303_ref.fasta --bam combined_ref.final.bam --output w303_vlte --outdir ../new_ref/ --changes --tracks 

