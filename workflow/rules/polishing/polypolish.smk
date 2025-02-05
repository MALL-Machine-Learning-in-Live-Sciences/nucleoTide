# Polishing step

def samples_to_polish(wildcards):
    hysi_samples = os.path.join(config['dir']['out']['assembly'], "hysi_samples.txt")
    with open(hysi_samples, 'r') as file:
        samples = file.read().splitlines()
    
    r1 = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}_R1_trim.fastq.gz")
    r2 = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}_R2_trim.fastq.gz")
    assembly = os.path.join(config['dir']['out']['assembly'], "{sample}/{sample}.fasta")
    
    return {
        'r1': r1,
        'r2': r2,
        'assembly': assembly
    }

rule polypolish:
    """
    Runs polypolish with short paired-end reads to polish the assembly.
    """
    input:
        unpack(samples_to_polish)
    output:
        poly_dir = directory(os.path.join(config['dir']['out']['polishing'], "{sample}")),
        poly_files = os.path.join(config['dir']['out']['polishing'], "{sample}/{sample}.fasta")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "polypolish.yaml"))
    resources:
        mem_mb = config['resources']['med']['mem'],
        runtime = config['resources']['med']['time'],
        cpus_per_task = config['resources']['med']['cpu']
    threads: 
        config['resources']['med']['cpu']
    benchmark:
        os.path.join(config['dir']['out']['bench'], "polypolish", "{sample}_bench.txt")
    log:
        os.path.join(config['dir']['out']['logs'], "polypolish", "{sample}.log")
    shell:
        """ 
        echo "Running polypolish..."

        if [ -s {input.assembly} ]; then
            bwa-mem2 index {input.assembly} 2> {log}
            bwa-mem2 mem -t {threads} -a {input.assembly} {input.r1} > {output.poly_dir}/alignments_1.sam 2> {log}
            bwa-mem2 mem -t {threads} -a {input.assembly} {input.r2} > {output.poly_dir}/alignments_2.sam 2> {log}
            polypolish filter --in1 {output.poly_dir}/alignments_1.sam --in2 {output.poly_dir}/alignments_2.sam --out1 {output.poly_dir}/filtered_1.sam --out2 {output.poly_dir}/filtered_2.sam 2> {log}
            polypolish polish {input.assembly} {output.poly_dir}/filtered_1.sam {output.poly_dir}/filtered_2.sam > {output.poly_files} 2> {log}
            rm {input.assembly}.amb {input.assembly}.ann {input.assembly}.pac {input.assembly}.0123 {input.assembly}.bwt.2bit.64 {output.poly_dir}/*.sam 2> {log}
        else
            touch {output.poly_dir} {output.poly_files}
        fi
        """

    
