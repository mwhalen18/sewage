
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sewage

<!-- badges: start -->

[![R-CMD-check](https://github.com/mwhalen18/sewage/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mwhalen18/sewage/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of sewage is to provide a light-weight pipelining interface for
data analyses. Rather than construct long scripts with intermiediate
datasets or processes, you can construct a single pipeline and run it in
a single call.

## Installation

You can install the development version of sewage from Github:

``` r
devtools::install_github("mwhalen18/sewage")
```

## Example

Below is an example of how to construct a simple pipeline.

``` r
library(sewage)
```

You can use any function as a component in the pipeline, including
custom functions you define or import from an external source.

``` r
subset_data = function(x) {
  subset(x, cyl == 6)
}
summarizer = function(x) {
  return(summary(x[['disp']]))
}
```

Currently, there are 3 components ready for use: `Nodes`, `Splitters`,
and `Joiners`. Nodes take one object as input and return exactly one
object. Splitters take in exactly one object and may return any number
of outputs greater than 1. `Joiners` take in multiple objects and return
1 object according to the method you pass to the `Joiner` (More on these
components below).

``` r
pipeline = Pipeline()
pipeline = pipeline |>
  add_node(component = readr::read_csv, name = "Reader", input = "file") |>
  add_node(component = Splitter(), name = "Splitter", input = "Reader") |>
  add_node(component = subset_data, name = "Subsetter", input = "Splitter.output_2") |>
  add_node(component = summarizer, name = "Summarizer", input = "Splitter.output_1")
```

Note outputs of a Splitter are accessible by specifying the name of the
splitter component (In this case `Splitter`) suffixed with the outgoing
edge in the format `{name}.output_{i}`.

The first node in your pipeline should specify the argument that will be
passed into the pipeline when we execute it (More on this below).

We can easily visualize our pipeline using the `draw` method.
