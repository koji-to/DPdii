
# DPdii

<!-- badges: start -->
<!-- badges: end -->
## Overview
**DPdii**: Data Paching Method Using Deletion - Imputation Iteration

DPdii is R package and Data Paching Method Using Deletion - Imputation Iteration.

It combines prodNA (by missForest package) and Multiple Imputation Techniques (Mice and missForest in this version) to patching (replacing) outlier to valid value.

See help text (in the making) to know more information and procedure of outlier deletion.
In this version, dataset must be constructed by ONLY numeric veriables.

## Installation

``` r
devtools::install_github("koji-to/DPdii")
```

## Dependencies
[mice](https://github.com/amices/mice)

[missForest](https://github.com/stekhoven/missForest)

## Usage

```
DPdii(
  data.df,
  imp = "mice",
  del_rate = 0.05,
  patch_rates = 0.1,
  elim_rates = 0.2,
  iter = 1000,
  penl = "SQD"
)
```

## Arguments
`data.df` target dataset

`imp` imputation method name ('mice' (default setting) or 'missForest')

`del_rate` deletion rate to complete dataset

`elim_rate` outlier elimination rate

`patch_rates` patching rate. This parameter allow vector like c(0.1, 0.2,0.3)

`elim_rates` elimination rate. This parameter allow vector like c(0.1, 0.2,0.3)

`iter` the number of of iteration

`penl` calculation method of residual ('SQD': Squared difference (default setting) or 'ABD': Absolute difference)

## Values

list of dataset

out[["patch_rate_0.1_elim_rate_0.2"]] return the dataset that its parameter is "patch_rate = 0.1" and "elim_rate = 0.2"

## Example

``` r
library(DPdii)

DPdii(iris[,-ncol(iris)], iter=1000)
out <- DPdii(iris[,-ncol(iris)],iter=1000)
out[["patch_rate_0.1_elim_rate_0.2"]]
```
## Citation

TBD


