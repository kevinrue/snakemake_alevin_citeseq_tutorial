
# pipeline_alevin_citeseq

<!-- badges: start -->
<!-- badges: end -->

Feature Barcoding based Single-Cell Quantification with alevin

# Set up

Following instructions at <https://combine-lab.github.io/alevin-tutorial/2020/alevin-features/>.

## Step 1. Index the reference sequences

```
cd /ifs/mirror/alevin
wget -nv http://refgenomes.databio.org/v2/asset/hg38/salmon_partial_sa_index/archive?tag=default
mv archive?tag=default salmon_partial_sa_index__default.tgz
tar -xvzf salmon_partial_sa_index__default.tgz
grep "^>" salmon_partial_sa_index/gentrome.fa | cut -d " " -f 1,7 --output-delimiter=$'\t' - | sed 's/[>"gene_symbol:"]//g' > txp2gene.tsv
```

## Step 2. Index the antibody sequences

```
wget --content-disposition  -nv https://ftp.ncbi.nlm.nih.gov/geo/series/GSE128nnn/GSE128639/suppl/GSE128639_MNC_ADT_Barcodes.csv.gz
zcat GSE128639_MNC_ADT_Barcodes.csv.gz | awk -F "," '{print $1"\t"$4}' | tail -n +2 > adt.tsv
salmon index -t adt.tsv -i adt_index --features -k7
```

```
wget --content-disposition  -nv https://ftp.ncbi.nlm.nih.gov/geo/series/GSE128nnn/GSE128639/suppl/GSE128639_MNC_HTO_Barcodes.csv.gz
zcat GSE128639_MNC_HTO_Barcodes.csv.gz | awk -F "," '{print $1"\t"$4}' | sed 's/Hashtag /Hashtag_/g' | tail -n +2 > hto.tsv
salmon index -t hto.tsv -i hto_index --features -k7
```

## Step 3. Download the raw RNA & antibody sequencing data

```
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

## Step 4. Quantify with alevin

```
salmon alevin -l ISR -i /ifs/mirror/alevin/salmon_partial_sa_index \
-1 data/MNC-A_R1.fastq.gz -2 data/MNC-A_R2.fastq.gz \
-o alevin_rna -p 16 --tgMap /ifs/mirror/alevin/txp2gene.tsv \
--chromium --dumpFeatures
```

### Sample metadata

Create a file `data/samples.tsv` that contains the following columns:

- sample, unique sample identifiers found in the library file name, i.e. {sample}_library.csv
