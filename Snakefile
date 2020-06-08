
import pandas as pd

configfile: "config.yaml"

samples = pd.read_table(config["samples"]).set_index("sample", drop=False)

print(config)

rule all:
    input:
        "alevin/.done"

rule alevin_gene:
    input:
        fastq1=expand("data/{sample}_R1.fastq.gz", sample=samples['sample']),
        fastq2=expand("data/{sample}_R2.fastq.gz", sample=samples['sample']),
    output:
        directory("alevin/{sample}_rna")
    params:
        index=config['alevin']['index'],
        tgmap=config['alevin']['tgmap'],
        threads=config['alevin']['threads']
    threads: config['alevin']['threads']
    resources:
        mem_mb=config['alevin']['memory_gb'] * 1024
    shell:
        """
        salmon alevin -l ISR -i {params.index} \
        -1 {input.fastq1} -2 {input.fastq2} \
        -o {output} -p {params.threads} --tgMap {params.tgmap} \
        --chromium --dumpFeatures
        """

rule alevin_all:
    input:
        expand("alevin/{sample}_rna", sample=samples['sample'])
    output:
        "alevin/.done"
    shell:
        """touch {output}"""
