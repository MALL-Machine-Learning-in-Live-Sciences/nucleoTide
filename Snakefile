## Snakefile
import os
import shutil

configfile: "config/config.yaml"

wildcard_constraints:
    sample=r"AB\d+",
    read=r"R[1,2]"#|long"

def interm_results(wildcards):
    pairs_checkpoint_output = checkpoints.organize_input.get(**wildcards).output.pair_dir
    longs_checkpoint_output = checkpoints.organize_input.get(**wildcards).output.long_dir

    pair_samples = glob_wildcards(os.path.join(pairs_checkpoint_output, r"{sample,AB\d+}_{read,R[1,2]}.fastq.gz")).sample
    long_samples = glob_wildcards(os.path.join(longs_checkpoint_output, r"{sample,AB\d+}_long.fastq.gz")).sample
    
    samples = set([*pair_samples, *long_samples])

    return expand(os.path.join(config['dir']['out']['assembly'], "{sample}/{sample}.fasta"), sample=samples)
    

def final_results(wildcards):
    pairs_checkpoint_output = checkpoints.organize_input.get(**wildcards).output.pair_dir
    longs_checkpoint_output = checkpoints.organize_input.get(**wildcards).output.long_dir

    pair_samples = glob_wildcards(os.path.join(pairs_checkpoint_output, r"{sample,AB\d+}_{read,R[1,2]}.fastq.gz")).sample
    long_samples = glob_wildcards(os.path.join(longs_checkpoint_output, r"{sample,AB\d+}_long.fastq.gz")).sample
    
    samples = set([*pair_samples, *long_samples])

    return expand(os.path.join(config['dir']['out']['annotation'], "{sample}/{sample}.gff3"), sample=samples)
    
rule all:
    input: 
        interm_results,
        final_results,
        os.path.join(config['dir']['out']['preprocessing'], "multiqc", "multiqc_report.html"),
        os.path.join(config['dir']['out']['versions'], "fastp.txt"),
        os.path.join(config['dir']['out']['versions'], "fastplong.txt"),
        os.path.join(config['dir']['out']['versions'], "multiqc.txt"),
        os.path.join(config['dir']['out']['versions'], "unicycler.txt"),
        os.path.join(config['dir']['out']['versions'], "polypolish.txt"),
        os.path.join(config['dir']['out']['versions'], "bakta.txt")


checkpoint organize_input:
    input: 
        input_dir = config['dir']['in']
    output:
        pair_dir = directory(os.path.join(config['dir']['in'], "paired")),
        long_dir = directory(os.path.join(config['dir']['in'], "long"))
    resources:
        mem_mb = config['resources']['med']['mem'],
        time = config['resources']['med']['time'],
        cpus_per_task = config['resources']['med']['cpu']
    threads: 
        config['resources']['med']['cpu']
    run:
        import workflow.scripts.rename_inputs as rename

        if len(os.listdir(input.input_dir)) == 0:
            raise ValueError("There are no samples to proccess") # stop the workflow

        if not os.path.exists(output.pair_dir):
            os.makedirs(output.pair_dir)

        if not os.path.exists(output.long_dir):
            os.makedirs(output.long_dir)
        
        # Renaming files as {isolate}_{read}.fastq.gz
        count = rename.rename_fastq_files(input.input_dir)
        print(f'Number of renamed files: {count}')

        short_samples, reads = glob_wildcards(os.path.join(input.input_dir, "{sample}_{read}.fastq.gz"))
        long_samples = glob_wildcards(os.path.join(input.input_dir, "{sample}_long.fastq.gz")).sample

        samples = set([*short_samples, *long_samples])
        print(samples)

        for sample in samples:
            path_r1 = os.path.join(input.input_dir, "{sample}_R1.fastq.gz".format(sample=sample))
            path_r2 = os.path.join(input.input_dir, "{sample}_R2.fastq.gz".format(sample=sample))
            path_long = os.path.join(input.input_dir, "{sample}_long.fastq.gz".format(sample=sample))

            if os.path.exists(path_long):
                path_long_new = os.path.join(output.long_dir, "{sample}_long.fastq.gz".format(sample=sample))
                shutil.copy(path_long, path_long_new)

            if (os.path.exists(path_r1) and os.path.exists(path_r2)):
                path_r1_new = os.path.join(output.pair_dir, "{sample}_R1.fastq.gz".format(sample=sample))
                shutil.copy(path_r1, path_r1_new)
                path_r2_new = os.path.join(output.pair_dir, "{sample}_R2.fastq.gz".format(sample=sample))
                shutil.copy(path_r2, path_r2_new)
            
include: "workflow/rules/preprocessing/qc.smk"
include: "workflow/rules/assembly/unicycler.smk"
include: "workflow/rules/polishing/polypolish.smk"
include: "workflow/rules/annotation/bakta.smk"
include: "workflow/rules/versions/versions.smk" 

onsuccess:
    shell("""
        find "./results" -type f -empty -exec basename {{}} ";" > del_empty_files.txt
        find "./results" -type f -empty -delete

        find "./results" -type d -empty > del_empty_dir.txt
        find "./results" -type d -empty -delete

        find "./logs" -type f -empty -delete
        find "./logs" -type d -empty -delete

        find "./data/input" -type d -name "paired" -empty -delete
        find "./data/input" -type d -name "long" -empty -delete
        
        find "./results/assembly" -type f -name "hysi_samples.txt" -delete
        find "./results/assembly" -type f -name "long_samples.txt" -delete

        find . -maxdepth 1 -type d -name "tmp*" -empty -delete 

        find "./bakta_db" -type f -name "db_checked" -delete    
      """)

onerror:
    shell("""
        find "./results/assembly" -type f -name "hysi_samples.txt" -delete
        find "./results/assembly" -type f -name "long_samples.txt" -delete
      """)