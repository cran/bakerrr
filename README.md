
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bakerrr ⏲️ <a href="https://anirbanshaw24.github.io/bakerrr/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![CRAN](https://www.r-pkg.org/badges/version/bakerrr)](https://CRAN.R-project.org/package=bakerrr)
[![R-CMD-check](https://github.com/anirbanshaw24/bakerrr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/anirbanshaw24/bakerrr/actions/workflows/R-CMD-check.yml)
[![LintR-check](https://github.com/anirbanshaw24/bakerrr/actions/workflows/lintr-check.yml/badge.svg)](https://github.com/anirbanshaw24/bakerrr/actions/workflows/lintr-check.yml)
[![Spell-check](https://github.com/anirbanshaw24/bakerrr/actions/workflows/spell-check.yml/badge.svg)](https://github.com/anirbanshaw24/bakerrr/actions/workflows/spell-check.yml)
[![Test
coverage](https://github.com/anirbanshaw24/bakerrr/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/anirbanshaw24/bakerrr/actions/workflows/test-coverage.yml)
[![Codecov](https://codecov.io/gh/anirbanshaw24/bakerrr/graph/badge.svg?token=JUTW42674L)](https://app.codecov.io/gh/anirbanshaw24/bakerrr)
<!-- badges: end -->

## Elegant S7-based parallel job orchestration for R

{bakerrr} provides a clean, modern interface for running background
parallel jobs using S7 classes, mirai daemon(s), and callr process
management. Perfect for computationally intensive workflows that need
robust error handling and progress monitoring.

## Features

- S7 Class System: Type-safe, modern R object system
- Parallel Processing: Efficient daemon-based parallelization via mirai
- Background Execution: Non-blocking job execution with callr::r_bg
- Error Resilience: Built-in tryCatch error handling per job
- Progress Monitoring: Console spinner with live status updates
- Flexible Configuration: Customizable daemon count and cleanup options
- Clean API: Intuitive print(), summary(), and
  run_jobs(wait_for_results) methods

## Installation

You can install the development version of bakerrr from
[CRAN](https://CRAN.R-project.org/package=bakerrr) with:

``` r
install.packages("bakerrr")
```

## Quick Start

``` r
# Define your function
compute_sum <- function(x, y) {
  Sys.sleep(1)  # Simulate work
  x + y
}

# Create argument lists for each job
args_list <- list(
  list(x = 1, y = 2),
  list(x = 3, y = 4),
  list(x = 5, y = 6),
  list(x = 7, y = 8)
)

# Create and run bakerrr job
job <- bakerrr::bakerrr(
  fun = compute_sum,
  args_list = args_list,
  n_daemons = 2
) |> 
  bakerrr::run_jobs(wait_for_results = TRUE)

# Check results
job@results
#> [[1]]
#> [1] 3
#> 
#> [[2]]
#> [1] 7
#> 
#> [[3]]
#> [1] 11
#> 
#> [[4]]
#> [1] 15

print(job)
#>    [01] function (x, y) { Sys.sleep(1) x + y }
#>    [02] function (x, y) { Sys.sleep(1) x + y }
#>    [03] function (x, y) { Sys.sleep(1) x + y }
#>    [04] function (x, y) { Sys.sleep(1) x + y }
```

## Advanced Usage

### Error Handling

``` r
# Function that may fail
risky_function <- function(x) {
  if (x == "error") stop("Intentional error")
  x * 2
}

args_list <- list(
  list(x = 5),
  list(x = "error"),  # This will fail gracefully
  list(x = 10)
)

job <- bakerrr::bakerrr(risky_function, args_list) |>
  bakerrr::run_jobs(wait_for_results = FALSE)
job@results
#> [1] "running"
#> [[1]] [1] 10
#> [[2]] [1] "Error in purrr::in_parallel: Intentional error"
#> [[3]] [1] 20
```

### Background Job Arguments

``` r
# Custom logging and process options
compute_sum <- function(x, y) {
  Sys.sleep(1)  # Simulate work
  x + y
}

# Create argument lists for each job
args_list <- list(
  list(x = 1, y = 2),
  list(x = 3, y = 4),
  list(x = 5, y = 6),
  list(x = 7, y = 8)
)
job <- bakerrr::bakerrr(
  fun = compute_sum,
  args_list = args_list,
  bg_args = list(
    stdout = "job_output.log",
    stderr = "job_errors.log",
    supervise = TRUE
  )
) |>
  bakerrr::run_jobs(wait_for_results = FALSE)
```

### Asynchronous Execution

``` r
long_running_function <- function() {
  Sys.sleep(5)
}
# Start job without waiting
job <- bakerrr::bakerrr(long_running_function, args_list) |> 
  bakerrr::run_jobs(wait_for_results = FALSE)

# Check status later
summary(job)
#>           Length           Class1           Class2             Mode 
#>                1 bakerrr::bakerrr        S7_object           object
#> ⏳ BackgroundParallelJob [running] - 4 daemon(s), 10 jobs

# Get results when ready
if (!job@bg_job_status$is_alive()) {
  results <- job@results
}
```

### Multiple Functions in Parallel and in Background

You can run multiple different functions, each with their own arguments,
in parallel background jobs using {bakerrr}. Just supply a list of
functions and a matching list of argument sets:

``` r
# List of functions with different logic
fun_list <- list(
  function(x, y) x + y,
  function(x, y) x * y,
  function(x, y) x - y,
  function(x, y) x / y,
  function(x, y) x^y,
  function(x, y) x %% y,
  function(x, y) paste0(x, "-", y),
  function(x, y) mean(c(x, y)),
  function(x, y) max(x, y),
  function(x, y) min(x, y)
)

# Corresponding list of argument sets
set.seed(1)
args_list <- list(
  list(x = 3, y = 6),
  list(x = "p", y = 2),              # type error
  list(x = 5, y = 8),
  list(x = 10, y = 2),
  list(x = 2, y = 5),
  list(x = 13, y = 4),
  list(x = "A", y = 7),              # type error
  list(x = 6, y = 9),
  list(x = 3, y = 4),
  list(x = 1, y = 2)
)

# Run jobs in parallel
job <- bakerrr::bakerrr(
  fun = fun_list,
  args_list = args_list,
  n_daemons = 4
) |> bakerrr::run_jobs(wait_for_results = TRUE)

# Inspect results and status
job@results
#> [[1]]
#> [1] 9
#> 
#> [[2]]
#> Error in purrr::in_parallel: non-numeric argument to binary operator
#> 
#> [[3]]
#> [1] -3
#> 
#> [[4]]
#> [1] 5
#> 
#> [[5]]
#> [1] 32
#> 
#> [[6]]
#> [1] 1
#> 
#> [[7]]
#> [1] "A-7"
#> 
#> [[8]]
#> [1] 7.5
#> 
#> [[9]]
#> [1] 4
#> 
#> [[10]]
#> [1] 1
print(job)
#>    [01] function (x, y) x + y
#>    [02] function (x, y) x * y
#>    [03] function (x, y) x - y
#>    [04] function (x, y) x/y
#>    [05] function (x, y) x^y
#>    [06] function (x, y) x%%y
#>    [07] function (x, y) paste0(x, "-", y)
#>    [08] function (x, y) mean(c(x, y))
#>    [09] function (x, y) max(x, y)
#>    [10] function (x, y) min(x, y)
summary(job)
#>           Length           Class1           Class2             Mode 
#>                1 bakerrr::bakerrr        S7_object           object
bakerrr::status(job)
#> [1] "done"
```

## Performance Tips

- Optimal Daemon Count: Start with ceiling(cores / 5), adjust based on
  workload
- Batch Size: Group small tasks to reduce overhead
- Memory Usage: Monitor with bg_args = list(supervise = TRUE)
- Error Recovery: Use tryCatch in your functions for custom error
  handling

## Dependencies

- S7: Modern object system
- mirai: High-performance parallelization
- callr: Background R processes
- purrr: Functional programming toolkit
- cli: Progress indicators
- glue: String interpolation

## Further Help & Documentation

- For full documentation, visit the [package
  website](https://anirbanshaw24.github.io/bakerrr/)
- API reference: [Reference
  manual](https://anirbanshaw24.github.io/bakerrr/reference/)
- Report issues: [GitHub
  Issues](https://github.com/anirbanshaw24/bakerrr/issues)

## Troubleshooting

- Windows: Make sure Rtools is installed for compilation.
- Linux/macOS: Ensure system build tools (gcc, make, pandoc) are
  present.
- Parallel/job failures: Check <job@results> for error output; validate
  function arguments.
- Session Info: Please include output of sessionInfo() in bug reports.

## Citation

- To cite bakerrr in publications, run:

``` r
citation("bakerrr")
#> To cite package 'bakerrr' in publications use:
#> 
#>   Shaw A (2025). _bakerrr: Background-Parallel Jobs_. R package version
#>   0.2.0, <https://github.com/anirbanshaw24/bakerrr>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {bakerrr: Background-Parallel Jobs},
#>     author = {Anirban Shaw},
#>     year = {2025},
#>     note = {R package version 0.2.0},
#>     url = {https://github.com/anirbanshaw24/bakerrr},
#>   }
```
