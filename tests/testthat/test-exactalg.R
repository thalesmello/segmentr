context("exactalg")

set.seed(123)
data_1 <- simulate2.1(1000)
data_2 <- simulate3.2(1000)

test_that("correctly identify independent results", {
  results <- exactalg(data_1, penalty = function(X) (0.5 * 2^ncol(X)) * log(nrow(X)))
  expect_equal(results$changepoints, c(5, 10))

  results <- exactalg(data_2, penalty = function(X) (0.5 * 3^ncol(X)) * log(nrow(X)))
  expect_equal(results$changepoints, c(5, 10))
})

test_that("can be called using segment", {
  results <- segment(data_1, penalty = function(X) (0.5 * 2^ncol(X)) * log(nrow(X)))
  expect_equal(results$changepoints, c(5, 10))

  results <- segment(data_2, penalty = function(X) (0.5 * 3^ncol(X)) * log(nrow(X)), algorithm = "exact")
  expect_equal(results$changepoints, c(5, 10))
})

test_that("works with cluster", {
  set.seed(123)
  data_1 <- simulate2.1(1000)
  data_2 <- simulate3.2(1000)

  doParallel::registerDoParallel(1)
  results <- exactalg(data_1, penalty = function(X) (0.5 * 2^ncol(X)) * log(nrow(X)), allow_parallel = TRUE)
  expect_equal(results$changepoints, c(5, 10))

  results <- exactalg(data_2, penalty = function(X) (0.5 * 3^ncol(X)) * log(nrow(X)), allow_parallel = FALSE)
  expect_equal(results$changepoints, c(5, 10))
  doParallel::stopImplicitCluster()
})

test_that("handles zero columns", {
  data <- makeRandom(1000, 0)
  results <- exactalg(data, penalty = function(X) (0.1 * 2^ncol(X)) * log(nrow(X)))
  expect_equal(length(results$changepoints), 0)
})

test_that("handles NaN in log_likelihood or penalty", {
  data <- makeRandom(5, 20)
  expect_error(
    exactalg(data, log_likelihood = function(X) if (ncol(X) == 2) NaN else sum(X)),
    "log_likelihood returned a NaN when called with log_likelihood\\(data\\[, 2:3\\]\\)"
  )

  expect_error(
    exactalg(data, penalty = function(X) if (ncol(X) == 2) NaN else sum(X)),
    "penalty returned a NaN when called with penalty\\(data\\[, 2:3\\]\\)"
  )
})

test_that("test max changepoints", {
  results <- exactalg(data_1, penalty = function(X) (0.5 * 2^ncol(X)) * log(nrow(X)), max_segments = 2)
  expect_equal(results$changepoints, c(9))
})

test_that("has detailed changepoints in the result set", {
  results <- exactalg(data_1, penalty = function(X) (0.1 * 2^ncol(X)) * log(nrow(X)))

  expect_equal(results$detailed_changepoints, list(
    list(changepoint = 5, gamma = 716.0865),
    list(changepoint = 10, gamma = 702.1316)
  ), tolerance = 0.001)
})