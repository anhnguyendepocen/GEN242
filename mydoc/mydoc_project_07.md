---
title: Data Management for Course Projects
last_updated: 29-Apr-16
---

## Shared big data space on biocluster

All larger data sets of the coure projects will be organized in a shared big data space under
`/bigdata/gen242/shared`. Within this space, each group will read and write data to a 
subdirectory named after their project:

+ `/bigdata/gen242/shared/RNA-Seq1`
+ `/bigdata/gen242/shared/RNA-Seq2`
+ `/bigdata/gen242/shared/ChIP-Seq1`
+ `/bigdata/gen242/shared/ChIP-Seq2`
+ `/bigdata/gen242/shared/VAR-Seq1`
+ `/bigdata/gen242/shared/VAR-Seq2`

Within each project subdirectory all input files of a workflow (_e.g._) will be saved to 
a `data` directory and all output files will be written to a `results` directory. 

## GitHub repositories for projects

Students will work on the course projects within GitHub repositories, one for each course project.
These project repositories are private and have been shared by the instructor with all members of each project group.
To populate a course project with an initial project workflow, please follow the instruction
given [below](http://girke.bioinformatics.ucr.edu/GEN242/mydoc/mydoc_project_07.html#generate-workflow-environment-with-project-data). 

## Generate workflow environment with project data

1. Generate workflow environment for your project on biocluster with `genWorkenvir` from `systemPipeRdata`. 
2. Replace the `data` and `results` directories by symbolic links pointing to the above described `data` and `results` directories of your course project. For instance, the project RNA-Seq1 should point on biocluster to:
    + `/bigdata/gen242/shared/RNA-Seq1/data` 
    + `/bigdata/gen242/shared/RNA-Seq1/results`
3. Add the workflow directory to the GitHub repository of your project with `git add -A`. This needs to be done only by one student in each project. After committing and pushing the repository to GitHub, it can be cloned with `git clone ...`.
4. Download the FASTQ files of your project with `getSRAfastq` (see below) to the `data` directory of your project. 
5. Generate a proper `targets` file for your project where the first column(s) point(s) to the downloaded FASTQ files. In addition, provide sample names matching the experimental design (columns: `SampleNames` and `Factor`).
6. Inspect and adjust the `.param` files you will be using. For instance, make sure the software modules you are loading and the path to the reference genome are correct. 

## Download of project data

### FASTQ files from SRA

#### Choose FASTQ data for your project

+ The FASTQ files for the ChIP-Seq project are from SRA study [SRP002174](http://www.ncbi.nlm.nih.gov/sra?term=SRP002174) ([Kaufman et al. 2010](http://www.ncbi.nlm.nih.gov/pubmed/20360106))
{% highlight r %}
sraidv <- paste("SRR0388", 45:51, sep="") 
{% endhighlight %}

+ The FASTQ files for the RNA-Seq project are from SRA study [SRP010938](http://www.ncbi.nlm.nih.gov/sra?term=SRP010938) ([Howard et al. 2013](http://www.ncbi.nlm.nih.gov/pubmed/24098335))
{% highlight r %}
sraidv <- paste("SRR4460", 27:44, sep="")
{% endhighlight %}

+ The FASTQ files for the VAR-Seq project are from SRA study [SRP008819](http://www.ncbi.nlm.nih.gov/sra?term=SRP008819) ([Lu et al 2012](http://www.ncbi.nlm.nih.gov/pubmed/22106370))
{% highlight r %}
sraidv <- paste("SRR1051", 389:415, sep="")
{% endhighlight %}

#### Load libraries and modules

{% highlight r %}
library(systemPipeR)
moduleload("sratoolkit/2.5.0")
system('fastq-dump --help') # prints help to screen
{% endhighlight %}

#### Define download function
The following function downloads and extracts the FASTQ files for each project from SRA.
Internally, it uses the `fastq-dump` utility from NCBI.

{% highlight r %}
getSRAfastq <- function(sraid, targetdir, maxreads="1000000000") {
    system(paste("fastq-dump --split-files --gzip --maxSpotId", maxreads, sraid, "--outdir", targetdir))
}
{% endhighlight %}

#### Run download

Note the following performs the download in serialized mode for the chosen data set and saves the extracted FASTQ files to 
the path specified under `targetdir`.
{% highlight r %}
for(i in sraidv) getSRAfastq(sraid=i, targetdir="data/")
{% endhighlight %}

Alternatively, the download can be performed in parallelized mode with `BiocParallel`. Please run this version only on one of the compute nodes.
{% highlight r %}
# bplapply(sraidv, getSRAfastq, targetdir="data/", BPPARAM = MulticoreParam(workers=4))
{% endhighlight %}

### Download reference genome and annotation

The following `downloadRefs` function downloads the _Arabidopsis thaliana_ genome sequence and GFF file from the [TAIR FTP site](ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/). 
It also assigns consistent chromosome identifiers to make them the same among both the genome sequence and the GFF file. This is
important for many analysis routines such as the read counting in the RNA-Seq workflow.  

{% highlight r %}
downloadRefs <- function(rerun=FALSE) {
    if(rerun==TRUE) {
        library(Biostrings)
        system("wget ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/TAIR10_chromosome_files/TAIR10_chr_all.fas -P ./data/")
        dna <- readDNAStringSet("./data/TAIR10_chr_all.fas")
        names(dna) <- paste(rep("Chr", 7), c(1:5, "M", "C"), sep="") # Fixes chromomse ids
        writeXStringSet(dna, "./data/TAIR10_chr_all.fas")
        system("wget ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/TAIR10_gff3/TAIR10_GFF3_genes.gff -P ./data/")
        system("wget ftp://ftp.arabidopsis.org/home/tair/Proteins/TAIR10_functional_descriptions -P ./data/")
    }
}
{% endhighlight %}

After sourcing the above function, execute it as follows:
{% highlight r %}
downloadRefs(rerun=FALSE) # To execute the function set 'rerun=TRUE'
{% endhighlight %}

