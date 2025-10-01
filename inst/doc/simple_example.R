## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----include=TRUE-------------------------------------------------------------
fun <- function(x, y) {
  Sys.sleep(2)
  x + y
}

# Note how each list item is a set of arguments for the function above.
args_list <- list(
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = "p", y = ceiling(rnorm(1) * 10)),  # Intentional type error
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  # Add more sets as needed
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10)),
  list(x = ceiling(rnorm(1) * 10), y = ceiling(rnorm(1) * 10))
)

## ----include=TRUE-------------------------------------------------------------
new_stirr <- bakerrr::bakerrr(
  fun,
  args_list,
  n_daemons = 4
) |>
  bakerrr::run_jobs(wait_for_results = TRUE)


## ----include=TRUE-------------------------------------------------------------
print(new_stirr)
new_stirr@results

