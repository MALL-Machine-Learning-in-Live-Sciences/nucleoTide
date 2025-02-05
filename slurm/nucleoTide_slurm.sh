#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 24:00:00
#SBATCH --mem=3GB
#SBATCH --error=/route/to/cluster/node/nucleoTide_slurm.txt
#SBATCH --output=/route/to/cluster/node/nucleoTide_slurm.txt
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=

# Set Conda
source /route/to/conda/bin/activate

# Activate the Snakemake environment
conda activate /route/to/.conda/envs/snakemake

# Run snakemake
snakemake --default-resources mem_mb=3000 runtime=10 cpus_per_task=1 --conda-base-path /route/to/conda/bin/conda --executor slurm --use-conda -s /route/to/cluster/node/nucleoTide/Snakefile --configfile /route/to/cluster/node/nucleoTide/config/config.yaml --jobs 100
