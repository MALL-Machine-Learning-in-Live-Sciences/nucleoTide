# NucleoTide: Genomic Assembly and Annotation Workflow

This Snakemake workflow automates the process of preprocessing, assembling, polishing, and annotating genomic sequencing data. It supports paired-end, long, and hybrid assemblies. It is configured to be executed locally or in a Slurm HPC cluster.

## Workflow Overview

1. **Preprocessing**
   - Short paired-end reads: Processed with Fastp
   - Long reads: Processed with Fastplong

2. **Quality Control**
   - MultiQC generates an HTML report of the preprocessing step

3. **Assembly**
   - Unicycler is used for assembly, supporting:
     - Paired-end assembly
     - Long assembly
     - Hybrid assembly (short paired-end + long reads)

4. **Polishing**
   - For paired-end and hybrid assemblies, an additional polishing step is performed with Polypolish
   - Long-read assemblies are polished by Unicycler (using Racon) during the assembly process

5. **Annotation**
   - Bakta is used for genome annotation
   - The full version of the Bakta database is utilized

6. **Logging and Benchmarking**
   - Software versions are recorded in text files
   - Log files are generated for each step
   - Benchmark files (in txt format) are created to track resource usage

## Requirements

- Snakemake
- Conda (for managing software environments)
- Fastp
- Fastplong
- MultiQC
- Unicycler
- Polypolish
- Bakta

## Local Usage

1. Clone this repository and navigate to the main directory, as follows:
    ```
    git clone https://github.com/MALL-Machine-Learning-in-Live-Sciences/nucleoTide.git
    cd nucleoTide
    ```

3. Install the Miniforge Distribution if not already installed. Visit the [Conda-forge pages](https://conda-forge.org/download/) and [Miniforge GitHub repository](https://github.com/conda-forge/miniforge) for instructions.

4. Create a Snakemake environment:
   ```
   mamba create -n snakemake snakemake
   mamba activate snakemake
   ```

6. Place all your read files (in `.fastq.gz` format) in the `data/input` directory. They must follow this naming structure:
    - Short read 1 (forward): `Isolatename_X_X_X_R1_X.fastq.gz` 
      Example: `AB15_3_S31_L001_R1_001.fastq.gz`
    - Short read 2 (reverse): `Isolatename_X_X_X_R2_X.fastq.gz`
      Example: `AB15_3_S31_L001_R2_001.fastq.gz`
    - Long read: `Isolatename_X_X_X_long.fastq.gz`
      Example: `AB15_44_S48_L001_long.fastq.gz`

7. If necessary, review and adjust the `config/config.yaml` file to match your project requirements.

8. Run the workflow from the main directory (nucleoTide):
    ```
    snakemake -s Snakefile --use-conda --configfile config/config.yaml
    ```

10. Access the results in the `results` directory.    

11. Deactivate the `snakemake` environment:
    ```
    mamba deactivate snakemake
    ```

## Slurm Usage

To run this workflow on a Slurm cluster, follow these steps:

1. Clone this repository (https://github.com/MALL-Machine-Learning-in-Live-Sciences/nucleoTide.git) and upload it to the cluster preferred node.

2. Load the Miniforge Distribution module (if available, else install it).

3. Follow steps 3-5 from the "Local Usage" section.

4. Install the Slurm plugin into the snakemake environment as follows:
   ```
   mamba install snakemake-executor-plugin-slurm
   ```

6. Adjust the `slurm/nucleoTide_slurm.sh` file to match your project requirements. Remember to:
   - write your email to receive the BEGIN, END and FAIL notifications
   - modify the `/route/to/cluster/node` (x4)
   - modify the `/route/to/conda` (x2)
   - modify the `/route/to/.conda` (x1)

7. Submit the workflow to Slurm from the main directory (nucleoTide):
    sbatch slurm/nucleoTide_slurm.sh

8. Monitor your job progress using `squeue`command.

9. Follow steps 7-8 from the "Local Usage" section.
