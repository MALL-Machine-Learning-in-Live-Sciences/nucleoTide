# Assembly step

def input_assembly(wildcards):
    path_r1 = os.path.join(config['dir']['in'], "paired", "{sample}_R1.fastq.gz".format(sample=wildcards.sample))
    path_r2 = os.path.join(config['dir']['in'], "paired", "{sample}_R2.fastq.gz".format(sample=wildcards.sample))
    path_long = os.path.join(config['dir']['in'], "long", "{sample}_long.fastq.gz".format(sample=wildcards.sample))
    path_r1_t = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}_R1_trim.fastq.gz".format(sample=wildcards.sample))
    path_r2_t = os.path.join(config['dir']['out']['preprocessing'], "fastp", "{sample}_R2_trim.fastq.gz".format(sample=wildcards.sample))
    path_long_t = os.path.join(config['dir']['out']['preprocessing'], "fastplong", "{sample}_long_trim.fastq.gz".format(sample=wildcards.sample))
    hysi_samples = os.path.join(config['dir']['out']['assembly'], "hysi_samples.txt")
    long_samples = os.path.join(config['dir']['out']['assembly'], "long_samples.txt")
    check_path = (os.path.exists(path_r1), os.path.exists(path_r2), os.path.exists(path_long))
    
    if check_path == (True, True, True):
        sample = os.path.basename(path_r1).split('_')[0]
        with open(hysi_samples, 'a') as file:
            file.write(sample + "\n")
        
        return [path_r1_t, path_r2_t, path_long_t]
    
    elif check_path == (True, True, False):
        sample = os.path.basename(path_r1).split('_')[0]
        with open(hysi_samples, 'a') as file:
            file.write(sample + "\n")
        
        return [path_r1_t, path_r2_t]
    
    elif check_path == (False, False, True):
        sample = os.path.basename(path_long).split('_')[0]
        with open(long_samples, 'a') as file:
            file.write(sample + "\n")
        
        return path_long_t

rule unicycler:
    """
    Runs unicycler to generate the assembly fasta file.
    """
    input:
        trim_file = input_assembly
    output:
        uni_dir = directory(os.path.join(config['dir']['out']['assembly'], "{sample}")),
        fasta_file = os.path.join(config['dir']['out']['assembly'], "{sample}/{sample}.fasta")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "unicycler.yaml"))
    resources:
        mem_mb = config['resources']['big']['mem'],
        runtime = config['resources']['big']['time'], 
        cpus_per_task = config['resources']['big']['cpu']
    threads: 
        config['resources']['big']['cpu']
    benchmark:
        os.path.join(config['dir']['out']['bench'], "unicycler", "{sample}_bench.txt")
    log:
        os.path.join(config['dir']['out']['logs'], "unicycler", "{sample}.log")
    shell:
        """ 
        num_files=$(echo {input.trim_file} | wc -w)

        IFS=' ' read -a files_array <<< "{input.trim_file}"

        # Function to handle unicycler errors
        handle_error() {{
            mkdir -p {output.uni_dir}
            touch {output.fasta_file}
            touch {log}
        }}
        
        if [ $num_files -eq 3 ]; then
            echo "Running unicycler hybrid..."
            unicycler -1 ${{files_array[0]}} -2 ${{files_array[1]}} -l ${{files_array[2]}} -o {output.uni_dir} -t {threads} --keep 0 > {log} 2>&1 || handle_error
        elif [ $num_files -eq 2 ]; then
            echo "Running unicycler paired-end..."
            unicycler -1 ${{files_array[0]}} -2 ${{files_array[1]}} -o {output.uni_dir} -t {threads} --keep 0 > {log} 2>&1 || handle_error
        elif [ $num_files -eq 1 ]; then
            echo "Running unicycler long..."
            unicycler -l ${{files_array[0]}} -o {output.uni_dir} -t {threads} --keep 0 > {log} 2>&1 || handle_error
        fi

        if [ -d {output.uni_dir} ]; then
            sample=$(basename {output.uni_dir})
            if [ -f "{output.uni_dir}/assembly.fasta" ]; then
                mv "{output.uni_dir}/assembly.fasta" "{output.uni_dir}/${{sample}}.fasta"
            fi 
        fi
        """
