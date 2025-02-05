# Annotation step

rule bakta_db:
    """
    Verifies that the Bakta database exists and is up to date.
    """
    output: 
        touch(os.path.join(config['dir']['db'], "db_checked"))
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "bakta.yaml"))
    resources:
        mem_mb = config['resources']['med']['mem'],
        runtime = config['resources']['med']['time'],
        cpus_per_task = config['resources']['med']['cpu']
    threads: 
        config['resources']['med']['cpu']
    benchmark:
        os.path.join(config['dir']['out']['bench'], "bakta", "check_db_bench.txt")
    log:
        os.path.join(config['dir']['out']['logs'], "bakta", "check_db.log")
    shell:
        """
        DB_DIR={config[dir][db]}

        if [ -z "$(find $DB_DIR -mindepth 1 -maxdepth 1)" ]; then
            echo "Bakta database is missing. Downloading full version..." >> {log}
            bakta_db download --output $DB_DIR --type full
            tar -xzf $DB_DIR/*.tar.gz -C $DB_DIR
            rm $DB_DIR/*.tar.gz
            bakta_db update --db $DB_DIR/*/
            amrfinder_update --database $DB_DIR/*/amrfinderplus-db
        else
            echo "Checking if bakta and amrfinder dbs are up to date..." >> {log}
            bakta_db update --db $DB_DIR/*/
            amrfinder_update --database $DB_DIR/*/amrfinderplus-db
        fi
        """

def bakta_input(wildcards):
    if os.path.exists(os.path.join(config['dir']['in'], "paired", "{sample}_R1.fastq.gz").format(sample=wildcards.sample)):
        return os.path.join(config['dir']['out']['polishing'], "{sample}/{sample}.fasta").format(sample=wildcards.sample)
    else:
        return os.path.join(config['dir']['out']['assembly'], "{sample}/{sample}.fasta").format(sample=wildcards.sample)

rule bakta:
    """
    Runs bakta to annotate the polished assembly fasta file.
    """
    input:
        bakta_file = bakta_input,
        db_checked = os.path.join(config['dir']['db'], "db_checked")
    output:
        bakta_dir = directory(os.path.join(config['dir']['out']['annotation'],"{sample}")),
        gff3_files = os.path.join(config['dir']['out']['annotation'], "{sample}/{sample}.gff3")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "bakta.yaml"))
    resources:
        mem_mb = config['resources']['big']['mem'],
        runtime = config['resources']['big']['time'], 
        cpus_per_task = config['resources']['big']['cpu']
    threads: 
        config['resources']['big']['cpu']
    benchmark:
        os.path.join(config['dir']['out']['bench'], "bakta", "{sample}_bench.txt")
    log:
        os.path.join(config['dir']['out']['logs'], "bakta", "{sample}.log")
    shell:
        """ 
        echo "Running bakta..."
        DB_DIR={config[dir][db]}

        # Function to handle unicycler errors
        handle_error() {{
            mkdir -p {output.bakta_dir}
            touch {output.gff3_files}
            touch {log}
        }}

        if [ -s {input.bakta_file} ]; then
            bakta --db $DB_DIR/*/ --output {output.bakta_dir} --threads {threads} {input.bakta_file} --force > {log} 2>&1 || handle_error
        else
            handle_error
        fi
        """
