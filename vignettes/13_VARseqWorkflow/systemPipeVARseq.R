## ----style, echo = FALSE, results = 'asis'-------------------------------
BiocStyle::markdown()
options(width=100, max.print=1000)
knitr::opts_chunk$set(
    eval=as.logical(Sys.getenv("KNITR_EVAL", "TRUE")),
    cache=as.logical(Sys.getenv("KNITR_CACHE", "TRUE")))

## ----setup, echo=FALSE, messages=FALSE, warnings=FALSE-------------------
suppressPackageStartupMessages({
    library(systemPipeR)
    library(BiocParallel)
    library(Biostrings)
    library(Rsamtools)
    library(GenomicRanges)
    library(ggplot2)
    library(GenomicAlignments)
    library(ShortRead)
    library(ape)
})

## ----load_systempiper, eval=TRUE-----------------------------------------
library(systemPipeR)

## ----genVAR_workflow, eval=FALSE-----------------------------------------
## library(systemPipeRdata)
## genWorkenvir(workflow="varseq")
## setwd("varseq")
## download.file("https://raw.githubusercontent.com/tgirke/GEN242/master/vignettes/13_VARseqWorkflow/systemPipeVARseq.Rmd", "systemPipeVARseq.Rmd")

## ----load_custom_fct, eval=FALSE-----------------------------------------
## source("systemPipeChIPseq_Fct.R")

## ----load_targets_file, eval=TRUE----------------------------------------
targetspath <- system.file("extdata", "targets_chip.txt", package="systemPipeR")
targets <- read.delim(targetspath, comment.char = "#")
targets[,-c(5,6)]

## ----preprocess_reads, eval=FALSE----------------------------------------
## args <- systemArgs(sysma="param/trimPE.param", mytargets="targetsPE.txt")[1:4] # Note: subsetting!
## filterFct <- function(fq, cutoff=20, Nexceptions=0) {
##     qcount <- rowSums(as(quality(fq), "matrix") <= cutoff)
##     fq[qcount <= Nexceptions] # Retains reads where Phred scores are >= cutoff with N exceptions
## }
## preprocessReads(args=args, Fct="filterFct(fq, cutoff=20, Nexceptions=0)", batchsize=100000)
## writeTargetsout(x=args, file="targets_PEtrim.txt", overwrite=TRUE)

## ----fastq_report, eval=FALSE--------------------------------------------
## args <- systemArgs(sysma="param/tophat.param", mytargets="targets.txt")
## fqlist <- seeFastq(fastq=infile1(args), batchsize=100000, klength=8)
## pdf("./results/fastqReport.pdf", height=18, width=4*length(fqlist))
## seeFastqPlot(fqlist)
## dev.off()

## ----load_sysargs, eval=FALSE--------------------------------------------
## args <- systemArgs(sysma="bwa.param", mytargets="targets.txt")
## sysargs(args)[1] # Command-line parameters for first FASTQ file

## ----bwa_serial, eval=FALSE----------------------------------------------
## bampaths <- runCommandline(args=args)

## ----bwa_parallel, eval=FALSE--------------------------------------------
## moduleload(modules(args))
## system("bwa index -a bwtsw ./data/tair10.fasta")
## resources <- list(walltime="20:00:00", nodes=paste0("1:ppn=", cores(args)), memory="10gb")
## reg <- clusterRun(args, conffile=".BatchJobs.R", template="torque.tmpl", Njobs=18, runid="01",
##                   resourceList=resources)
## waitForJobs(reg)

## ----check_file_presence, eval=FALSE-------------------------------------
## file.exists(outpaths(args))

## ----gsnap_parallel, eval=FALSE------------------------------------------
## library(gmapR); library(BiocParallel); library(BatchJobs)
## gmapGenome <- GmapGenome(reference(args), directory="data", name="gmap_tair10chr", create=TRUE)
## args <- systemArgs(sysma="gsnap.param", mytargets="targetsPE.txt")
## f <- function(x) {
##     library(gmapR); library(systemPipeR)
##     args <- systemArgs(sysma="gsnap.param", mytargets="targetsPE.txt")
##     gmapGenome <- GmapGenome(reference(args), directory="data", name="gmap_tair10chr", create=FALSE)
##     p <- GsnapParam(genome=gmapGenome, unique_only=TRUE, molecule="DNA", max_mismatches=3)
##     o <- gsnap(input_a=infile1(args)[x], input_b=infile2(args)[x], params=p, output=outfile1(args)[x])
## }
## funs <- makeClusterFunctionsTorque("torque.tmpl")
## param <- BatchJobsParam(length(args), resources=list(walltime="20:00:00", nodes="1:ppn=1", memory="6gb"), cluster.functions=funs)
## register(param)
## d <- bplapply(seq(along=args), f)
## writeTargetsout(x=args, file="targets_gsnap_bam.txt")

## ----align_stats, eval=FALSE---------------------------------------------
## read_statsDF <- alignStats(args=args)
## write.table(read_statsDF, "results/alignStats.xls", row.names=FALSE, quote=FALSE, sep="\t")

## ----symbolic_links, eval=FALSE------------------------------------------
## symLink2bam(sysargs=args, htmldir=c("~/.html/", "somedir/"),
##             urlbase="http://biocluster.ucr.edu/~tgirke/",
##             urlfile="./results/IGVurl.txt")

## ----run_gatk, eval=FALSE------------------------------------------------
## writeTargetsout(x=args, file="targets_bam.txt")
## system("java -jar CreateSequenceDictionary.jar R=./data/tair10.fasta O=./data/tair10.dict")
## # system("java -jar /opt/picard/1.81/CreateSequenceDictionary.jar R=./data/tair10.fasta O=./data/tair10.dict")
## args <- systemArgs(sysma="gatk.param", mytargets="targets_bam.txt")
## resources <- list(walltime="20:00:00", nodes=paste0("1:ppn=", 1), memory="10gb")
## reg <- clusterRun(args, conffile=".BatchJobs.R", template="torque.tmpl", Njobs=18, runid="01",
##                   resourceList=resources)
## waitForJobs(reg)
## writeTargetsout(x=args, file="targets_gatk.txt")

## ----run_bcftools, eval=FALSE--------------------------------------------
## args <- systemArgs(sysma="sambcf.param", mytargets="targets_bam.txt")
## resources <- list(walltime="20:00:00", nodes=paste0("1:ppn=", 1), memory="10gb")
## reg <- clusterRun(args, conffile=".BatchJobs.R", template="torque.tmpl", Njobs=18, runid="01",
##                   resourceList=resources)
## waitForJobs(reg)
## writeTargetsout(x=args, file="targets_sambcf.txt")

## ----run_varianttools, eval=FALSE----------------------------------------
## library(gmapR); library(BiocParallel); library(BatchJobs)
## args <- systemArgs(sysma="vartools.param", mytargets="targets_gsnap_bam.txt")
## f <- function(x) {
##     library(VariantTools); library(gmapR); library(systemPipeR)
##     args <- systemArgs(sysma="vartools.param", mytargets="targets_gsnap_bam.txt")
##     gmapGenome <- GmapGenome(systemPipeR::reference(args), directory="data", name="gmap_tair10chr", create=FALSE)
##     tally.param <- TallyVariantsParam(gmapGenome, high_base_quality = 23L, indels = TRUE)
##     bfl <- BamFileList(infile1(args)[x], index=character())
##     var <- callVariants(bfl[[1]], tally.param)
##     sampleNames(var) <- names(bfl)
##     writeVcf(asVCF(var), outfile1(args)[x], index = TRUE)
## }
## funs <- makeClusterFunctionsTorque("torque.tmpl")
## param <- BatchJobsParam(length(args), resources=list(walltime="20:00:00", nodes="1:ppn=1", memory="6gb"), cluster.functions=funs)
## register(param)
## d <- bplapply(seq(along=args), f)
## writeTargetsout(x=args, file="targets_vartools.txt")

## ----filter_gatk, eval=FALSE---------------------------------------------
## library(VariantAnnotation)
## args <- systemArgs(sysma="filter_gatk.param", mytargets="targets_gatk.txt")
## filter <- "totalDepth(vr) >= 2 & (altDepth(vr) / totalDepth(vr) >= 0.8) & rowSums(softFilterMatrix(vr))>=1"
## # filter <- "totalDepth(vr) >= 20 & (altDepth(vr) / totalDepth(vr) >= 0.8) & rowSums(softFilterMatrix(vr))==6"
## filterVars(args, filter, varcaller="gatk", organism="A. thaliana")
## writeTargetsout(x=args, file="targets_gatk_filtered.txt")

## ----filter_bcftools, eval=FALSE-----------------------------------------
## args <- systemArgs(sysma="filter_sambcf.param", mytargets="targets_sambcf.txt")
## filter <- "rowSums(vr) >= 2 & (rowSums(vr[,3:4])/rowSums(vr[,1:4]) >= 0.8)"
## # filter <- "rowSums(vr) >= 20 & (rowSums(vr[,3:4])/rowSums(vr[,1:4]) >= 0.8)"
## filterVars(args, filter, varcaller="bcftools", organism="A. thaliana")
## writeTargetsout(x=args, file="targets_sambcf_filtered.txt")

## ----filter_varianttools, eval=FALSE-------------------------------------
## args <- systemArgs(sysma="filter_vartools.param", mytargets="targets_vartools.txt")
## filter <- "(values(vr)$n.read.pos.ref + values(vr)$n.read.pos) >= 2 & (values(vr)$n.read.pos / (values(vr)$n.read.pos.ref + values(vr)$n.read.pos) >= 0.8)"
## # filter <- "(values(vr)$n.read.pos.ref + values(vr)$n.read.pos) >= 20 & (values(vr)$n.read.pos / (values(vr)$n.read.pos.ref + values(vr)$n.read.pos) >= 0.8)"
## filterVars(args, filter, varcaller="vartools", organism="A. thaliana")
## writeTargetsout(x=args, file="targets_vartools_filtered.txt")

## ----annotate_gatk, eval=FALSE-------------------------------------------
## library("GenomicFeatures")
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_gatk_filtered.txt")
## txdb <- loadDb("./data/tair10.sqlite")
## fa <- FaFile(systemPipeR::reference(args))
## variantReport(args=args, txdb=txdb, fa=fa, organism="A. thaliana")

## ----annotate_bcftools, eval=FALSE---------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_sambcf_filtered.txt")
## txdb <- loadDb("./data/tair10.sqlite")
## fa <- FaFile(systemPipeR::reference(args))
## variantReport(args=args, txdb=txdb, fa=fa, organism="A. thaliana")

## ----annotate_varianttools, eval=FALSE-----------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_vartools_filtered.txt")
## txdb <- loadDb("./data/tair10.sqlite")
## fa <- FaFile(systemPipeR::reference(args))
## variantReport(args=args, txdb=txdb, fa=fa, organism="A. thaliana")

## ----combine_gatk, eval=FALSE--------------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_gatk_filtered.txt")
## combineDF <- combineVarReports(args, filtercol=c(Consequence="nonsynonymous"))
## write.table(combineDF, "./results/combineDF_nonsyn_gatk.xls", quote=FALSE, row.names=FALSE, sep="\t")

## ----combine_bcftools, eval=FALSE----------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_sambcf_filtered.txt")
## combineDF <- combineVarReports(args, filtercol=c(Consequence="nonsynonymous"))
## write.table(combineDF, "./results/combineDF_nonsyn_sambcf.xls", quote=FALSE, row.names=FALSE, sep="\t")

## ----combine_varianttools, eval=FALSE------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_vartools_filtered.txt")
## combineDF <- combineVarReports(args, filtercol=c(Consequence="nonsynonymous"))
## write.table(combineDF, "./results/combineDF_nonsyn_vartools.xls", quote=FALSE, row.names=FALSE, sep="\t")

## ----summary_gatk, eval=FALSE--------------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_gatk_filtered.txt")
## write.table(varSummary(args), "./results/variantStats_gatk.xls", quote=FALSE, col.names = NA, sep="\t")

## ----summary_bcftools, eval=FALSE----------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_sambcf_filtered.txt")
## write.table(varSummary(args), "./results/variantStats_sambcf.xls", quote=FALSE, col.names = NA, sep="\t")

## ----summary_varianttools, eval=FALSE------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_vartools_filtered.txt")
## write.table(varSummary(args), "./results/variantStats_vartools.xls", quote=FALSE, col.names = NA, sep="\t")

## ----venn_diagram, eval=FALSE--------------------------------------------
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_gatk_filtered.txt")
## varlist <- sapply(names(outpaths(args))[1:4], function(x) as.character(read.delim(outpaths(args)[x])$VARID))
## vennset_gatk <- overLapper(varlist, type="vennsets")
## args <- systemArgs(sysma="annotate_vars.param", mytargets="targets_sambcf_filtered.txt")
## varlist <- sapply(names(outpaths(args))[1:4], function(x) as.character(read.delim(outpaths(args)[x])$VARID))
## vennset_bcf <- overLapper(varlist, type="vennsets")
## pdf("./results/vennplot_var.pdf")
## vennPlot(list(vennset_gatk, vennset_bcf), mymain="", mysub="GATK: red; BCFtools: blue", colmode=2, ccol=c("blue", "red"))
## dev.off()

## ----sessionInfo---------------------------------------------------------
sessionInfo()
