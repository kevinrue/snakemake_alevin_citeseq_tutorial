
# pipeline_alevin_citeseq

<!-- badges: start -->
<!-- badges: end -->

Feature Barcoding based Single-Cell Quantification with alevin

# Initial setup

Clone the pipeline repository to initialise your working directory.

```
git clone git@github.com:kevinrue/pipeline_alevin_citeseq.git
```

# Set up (tutorial)

Following instructions at <https://combine-lab.github.io/alevin-tutorial/2020/alevin-features/>.

## Step 1. Index the reference sequences

```
mkdir /ifs/mirror/alevin
cd /ifs/mirror/alevin
wget -nv http://refgenomes.databio.org/v2/asset/hg38/salmon_partial_sa_index/archive?tag=default
mv archive?tag=default salmon_partial_sa_index__default.tgz
tar -xvzf salmon_partial_sa_index__default.tgz
grep "^>" salmon_partial_sa_index/gentrome.fa | cut -d " " -f 1,7 --output-delimiter=$'\t' - | sed 's/[>"gene_symbol:"]//g' > txp2gene.tsv
```

## Step 2. Index the antibody sequences

```
cd /ifs/mirror/alevin
wget --content-disposition  -nv https://ftp.ncbi.nlm.nih.gov/geo/series/GSE128nnn/GSE128639/suppl/GSE128639_MNC_ADT_Barcodes.csv.gz
zcat GSE128639_MNC_ADT_Barcodes.csv.gz | awk -F "," '{print $1"\t"$4}' | tail -n +2 > adt.tsv
salmon index -t adt.tsv -i adt_index --features -k7
```

```
cd /ifs/mirror/alevin
wget --content-disposition  -nv https://ftp.ncbi.nlm.nih.gov/geo/series/GSE128nnn/GSE128639/suppl/GSE128639_MNC_HTO_Barcodes.csv.gz
zcat GSE128639_MNC_HTO_Barcodes.csv.gz | awk -F "," '{print $1"\t"$4}' | sed 's/Hashtag /Hashtag_/g' | tail -n +2 > hto.tsv
salmon index -t hto.tsv -i hto_index --features -k7
```

## Step 3. Download the raw RNA & antibody sequencing data

In the working directory.

```
mkdir data
cd data
# RNA experiment
wget --content-disposition -nv https://sra-pub-src-2.s3.amazonaws.com/SRR8758323/MNC-A_R1.fastq.gz && 
wget --content-disposition -nv https://sra-pub-src-2.s3.amazonaws.com/SRR8758323/MNC-A_R2.fastq.gz &&

# ADT experiment
wget --content-disposition -nv https://sra-pub-src-2.s3.amazonaws.com/SRR8758325/MNC-A-ADT_R1.fastq.gz &&
wget --content-disposition -nv https://sra-pub-src-2.s3.amazonaws.com/SRR8758325/MNC-A-ADT_R2.fastq.gz &&

# HTO experiment
wget --content-disposition -nv https://sra-pub-src-2.s3.amazonaws.com/SRR8758327/MNC-A-HTO_R1.fastq.gz &&
wget --content-disposition -nv https://sra-pub-src-2.s3.amazonaws.com/SRR8758327/MNC-A-HTO_R2.fastq.gz
```

# Configuration

## Samples and metadata

Edit the TAB-separated file `data/samples.tsv` that contains the following column(s) for each sample:

- `sample`, a unique sample identifiers found in the FASTQ file names (e.g., `{sample}_R1.fastq.gz`, `{sample}-HTO_R1.fastq.gz`, `{sample}-ADT_R1.fastq.gz`)

```
cd data
nano samples.tsv
```

## Pipeline settings

Edit `config.yaml` to the appropriate settings.

# Running the pipeline

Call `snakemake` with arguments appropriate to your configuration, e.g.

```
snakemake --profile drmaa
```
