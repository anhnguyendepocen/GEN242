---
title: Cluster Analysis in R 
author: "Thomas Girke (thomas.girke@ucr.edu)"
date: "Last update: 18 May, 2016" 
output:
  BiocStyle::html_document:
    toc: true
    toc_depth: 4
    fig_caption: yes

fontsize: 14pt
bibliography: bibtex.bib
---
<!--
%% \VignetteEngine{knitr::rmarkdown}
%\VignetteIndexEntry{Graphics in R}
%% \VignetteDepends{methods}
%% \VignetteKeywords{compute cluster, pipeline, reports}
-->

<!---
- Conversion from Rnw/tex to Rmd
    - Build vignette from Rnw 
    - Then run: pandoc -s Rgraphics.tex -o Rgraphics.text
    - Then fix things, usually a lot...

- Compile from command-line
echo "rmarkdown::render('Rclustering.Rmd', clean=F)" | R -slave; R CMD Stangle Rclustering.Rmd; Rscript ../md2jekyll.R Rclustering.knit.md 16

- Commit to github
git commit -am "some edits"; git push -u origin master

- To customize font size and other style features, add this line to output section in preamble:  
    css: style.css
-->

<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
  document.querySelector("h1").className = "title";
});
</script>
<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function() {
  var links = document.links;  
  for (var i = 0, linksLength = links.length; i < linksLength; i++)
    if (links[i].hostname != window.location.hostname)
      links[i].target = '_blank';
});
</script>

Note: the most recent version of this tutorial can be found <a href="http://girke.bioinformatics.ucr.edu/GEN242/vignettes/16_Rgraphics/Rclustering.html">here</a> and a slide show [here](http://girke.bioinformatics.ucr.edu/GEN242/mydoc/mydoc_slides_17.html).

# Introduction

- What is Clustering?
    - Clustering is the classification of data objects into similarity groups (clusters) according to a defined distance measure. 
    - It is used in many fields, such as machine learning, data mining, pattern recognition, image analysis, genomics, systems biology, etc. 
    - Machine learning typically regards data clustering as a form of unsupervised learning.

- Why Clustering and Data Mining in R?}
    - Efficient data structures and functions for clustering
    - Reproducible and programmable
    - Comprehensive set of clustering and machine learning libraries 
    - Integration with many other data analysis tools

- Useful Links
    - [Cluster Task Views](http://cran.cnr.berkeley.edu/web/views/Cluster.html)
    - [Machine Learning Task Views](http://cran.cnr.berkeley.edu/web/views/MachineLearning.html)
    - [UCR Manual](http://manuals.bioinformatics.ucr.edu/home/R\_BioCondManual\#TOC-Clustering-and-Data-Mining-in-R)

# Data Preprocessing

## Data Transformations

Choice depends on data set!
	
- Center and standardize
    1. Center: subtract from each value the mean of the corresponding vector
	2.  Standardize: devide by standard deviation
	- Result: $$Mean = 0$$ and $$STDEV = 1$$

- Center and scale with the `scale()` function
    1. Center: subtract from each value the mean of the corresponding vector
	2. Scale: divide centered vector by their _root mean square_ (_rms_):
    $$ x_{rms} = \sqrt[]{\frac{1}{n-1}\sum_{i=1}^{n}{x_{i}{^2}}} $$
    - Result: $$Mean = 0$$ and $$STDEV = 1$$

- Log transformation 
- Rank transformation: replace measured values by ranks 
- No transformation

## Distance Methods

List of most common ones!

- Euclidean distance for two profiles $$X$$ and $$Y$$:
  $$ d(X,Y) = \sqrt[]{ \sum_{i=1}^{n}{(x_{i}-y_{i})^2} }$$
    - __Disadvantages__: not scale invariant, not for negative correlations
- Maximum, Manhattan, Canberra, binary, Minowski, ...
- Correlation-based distance: $$1-r$$
    - Pearson correlation coefficient (PCC):
	  $$r = \frac{n\sum_{i=1}^{n}{x_{i}y_{i}} - \sum_{i=1}^{n}{x_{i}} \sum_{i=1}^{n}{y_{i}}}{ \sqrt[]{(\sum_{i=1}^{n}{x_{i}^2} - (\sum_{i=1}^{n}{x_{i})^2}) (\sum_{i=1}^{n}{y_{i}^2} - (\sum_{i=1}^{n}{y_{i})^2})} }$$
        - __Disadvantage__: outlier sensitive 
	- Spearman correlation coefficient (SCC)
	    - Same calculation as PCC but with ranked values!

There are many more distance measures

- If the distances among items are quantifiable, then clustering is possible.
- Choose the most accurate and meaningful distance measure for a given field of application.
- If uncertain then choose several distance measures and compare the results. 

## Cluster Linkage

<center><img title="cluster linkage" src="images/linkage.png" ></center>

# Clustering Algorithms

## Hierarchical Clustering

### Overview of algorithm 

1. Identify clusters (items) with closest distance  
2. Join them to new clusters
3. Compute distance between clusters (items)
4. Return to step 1

#### Hierarchical clustering: agglomerative Approach
<center><img title="hierarchical clustering" src="images/hierarchical.png" ></center>

#### Hierarchical Clustering with Heatmap
<center><img title="heatmap" src="images/heatmap.png" ></center>

- A heatmap is a color coded table. To visually identify patterns, the rows and columns of a heatmap are often sorted by hierarchical clustering trees.  
- In case of gene expression data, the row tree usually represents the genes, the column tree the treatments and the colors in the heat table represent the intensities or ratios of the underlying gene expression data set.

### Hierarchical Clustering Approaches

1. Agglomerative approach (bottom-up)
    - R functions: `hclust()` and `agnes()`

2. Divisive approach (top-down)
    - R function: `diana()`

### Tree Cutting to Obtain Discrete Clusters

1. Node height in tree
2. Number of clusters
3. Search tree nodes by distance cutoff


### Create symbolic links 

For viewing les in IGV as part of `systemPipeR` workflows.

- `systemPipeR`: utilities for building NGS analysis [pipelines](https://github.com/tgirke/systemPipeR)

## Example

Using `hclust` and `heatmap.2`


```r
library(gplots) 
y <- matrix(rnorm(500), 100, 5, dimnames=list(paste("g", 1:100, sep=""), paste("t", 1:5, sep=""))) 
heatmap.2(y) # Shortcut to final result
```

![](Rclustering_files/figure-html/hclust_heatmap_example-1.png)<!-- -->
	

# References