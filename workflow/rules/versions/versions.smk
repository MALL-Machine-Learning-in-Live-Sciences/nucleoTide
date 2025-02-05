# Save versions

rule fastp_version:
    output:
        os.path.join(config['dir']['out']['versions'], "fastp.txt")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "fastp.yaml"))
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'],
        cpus_per_task = config['resources']['sml']['cpu']
    threads: 
        config['resources']['sml']['cpu']
    shell:
        """
        fastp --version > {output} 2>&1
        """

rule fastplong_version:
    output:
        os.path.join(config['dir']['out']['versions'], "fastplong.txt")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "fastplong.yaml"))
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'],
        cpus_per_task = config['resources']['sml']['cpu']
    threads: 
        config['resources']['sml']['cpu']
    shell:
        """
        fastplong --version > {output} 2>&1
        """

rule multiqc_version:
    output:
        os.path.join(config['dir']['out']['versions'], "multiqc.txt")
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
        multiqc --version > {output} 2>&1
        """

rule unicycler_version:
    output:
        os.path.join(config['dir']['out']['versions'], "unicycler.txt")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "unicycler.yaml"))
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'],
        cpus_per_task = config['resources']['sml']['cpu']
    threads: 
        config['resources']['sml']['cpu']
    shell:
        """
        unicycler --version > {output} 2>&1
        """

rule polypolish_version:
    output:
        os.path.join(config['dir']['out']['versions'], "polypolish.txt")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "polypolish.yaml"))
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'],
        cpus_per_task = config['resources']['sml']['cpu']
    threads: 
        config['resources']['sml']['cpu']
    shell:
        """
        polypolish --version > {output} 2>&1
        """

rule bakta_version:
    output:
        os.path.join(config['dir']['out']['versions'], "bakta.txt")
    conda:
        os.path.abspath(os.path.join(config['dir']['envs'], "bakta.yaml"))
    resources:
        mem_mb = config['resources']['sml']['mem'],
        runtime = config['resources']['sml']['time'],
        cpus_per_task = config['resources']['sml']['cpu']
    threads: 
        config['resources']['sml']['cpu']
    shell:
        """
        bakta --version > {output} 2>&1
        """
