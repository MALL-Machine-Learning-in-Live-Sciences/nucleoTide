# Preprocessing step
import os

rule fastp:
    """
    Runs fastp on paired-end short reads, ensuring that both R1 and R2 files match.
    """
    input:
        r1 = os.path.join(config['dir']['in'], "paired", "{sample}_R1.fastq.gz"),
        r2 = os.path.join(config['dir']['in'], "paired", "{sample}_R2.fastq.gz")
    output:
        r1 = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}_R1_trim.fastq.gz"),
        r2 = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}_R2_trim.fastq.gz"),
        html = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}.html"),
        json = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}.json"),
        failed_out = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}.fastq")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "fastp.yaml"))
    params:
        detect_adapter_for_pe = "--detect_adapter_for_pe", #(default = disabled)
        trim_front1 = "--trim_front1 5", #(default = 0)
        trim_front2 = "--trim_front2 5", #(default = 0)
        trim_tail1 = "--trim_tail1 2", #(default = 0)
        trim_tail2 = "--trim_tail2 2", #(default = 0)
        cut_front = "--cut_front", #(default = disabled)
        cut_tail = "--cut_tail", #(default = disabled)
        cut_window_size = "--cut_window_size 4", #(default = 4)
        cut_mean_quality = "--cut_mean_quality 20" #(default = 20)
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'], 
        cpus_per_task = config['resources']['sml']['cpu'] 
    threads: 
        config['resources']['sml']['cpu']
    benchmark:
        os.path.join(config['dir']['out']['bench'], "fastp", "{sample}_bench.txt")
    log:
        os.path.join(config['dir']['out']['logs'], "fastp", "{sample}.log")
    priority: 
        100
    shell:
        """ 
        echo "Running fastp..."

        # Function to handle fastp errors
        handle_error() {{
            cp {input.r1} {output.r1}
            cp {input.r2} {output.r2}
            touch {output.html} {output.json} {output.failed_out} 
        }}

        fastp --in1 {input.r1} --in2 {input.r2} \
            --out1 {output.r1} --out2 {output.r2} \
            --html {output.html} --json {output.json} \
            --failed_out {output.failed_out} \
            {params.detect_adapter_for_pe} \
            {params.trim_front1} {params.trim_front2} \
            {params.trim_tail1} {params.trim_tail2} \
            {params.cut_front} {params.cut_tail} \
            {params.cut_window_size} {params.cut_mean_quality} \
            --thread {threads} 2> {log} || handle_error
        """

rule fastplong:
    """
    Runs fastp on long reads.
    """
    input:
        long = os.path.join(os.path.join(config['dir']['in'], "long"), "{sample}_long.fastq.gz")
    output:
        long = os.path.join(config['dir']['out']['preprocessing'], "fastplong", "{sample}_long_trim.fastq.gz"),
        html = os.path.join(config['dir']['out']['preprocessing'], "fastplong", "{sample}.html"),
        json = os.path.join(config['dir']['out']['preprocessing'], "fastplong", "{sample}.json"),
        failed_out = os.path.join(config['dir']['out']['preprocessing'], "fastplong", "{sample}.fastq")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "fastplong.yaml"))
    params:
        trim_front = "--trim_front 5", #(default = 0)
        trim_tail = "--trim_tail 2", #(default = 0)
        cut_front = "--cut_front", #(default = disabled)
        cut_tail = "--cut_tail", #(default = disabled)
        cut_window_size = "--cut_window_size 4", #(default = 4)
        cut_mean_quality = "--cut_mean_quality 20" #(default = 20)
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'], 
        cpus_per_task = config['resources']['sml']['cpu'] 
    threads: 
        config['resources']['sml']['cpu']
    benchmark:
        os.path.join(config['dir']['out']['bench'], "fastplong", "{sample}_bench.txt")
    log:
        os.path.join(config['dir']['out']['logs'], "fastplong", "{sample}.log")
    priority: 
        90
    shell:
        """
        echo "Running fastplong..."

        fastplong --in {input.long} --out {output.long} \
                --html {output.html} --json {output.json} \
                --failed_out {output.failed_out} \
                {params.trim_front} {params.trim_tail} \
                {params.cut_front} {params.cut_tail} \
                {params.cut_window_size} {params.cut_mean_quality} \
                --thread {threads} 2> {log} 
        """
def input_multiqc(wildcards):
    fastp = os.path.join(config['dir']['out']['preprocessing'], "fastp")
    fastplong = os.path.join(config['dir']['out']['preprocessing'], "fastplong")
    fastp_eval = os.path.exists(fastp)
    fastplong_eval = os.path.exists(fastplong)

    if fastp_eval and fastplong_eval:
        return config['dir']['out']['preprocessing']
    elif fastp_eval and not fastplong_eval:
        return fastp
    elif not fastp_eval and fastplong_eval:
        return fastplong
    else:
        return []
    
rule multiqc_report:
    """
    Aggregates preprocessing results across the samples into a single report.
    """
    input:
        preproc_dir = input_multiqc
    output:
        multiqc_dir = directory(os.path.join(config['dir']['out']['preprocessing'], "multiqc")),
        html = os.path.join(config['dir']['out']['preprocessing'], "multiqc", "multiqc_report.html")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "multiqc.yaml"))
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'],
        cpus_per_task = config['resources']['sml']['cpu'] 
    threads: 
        config['resources']['sml']['cpu']
    shell:
        """
        echo "Running multiqc..."

        IN_DIR={input}

        if [ -z "$(find $IN_DIR -mindepth 1 -maxdepth 1)" ]; then
            touch  {output.multiqc_dir} {output.html}
        else
            multiqc {input} -o {output.multiqc_dir}
        fi
        """