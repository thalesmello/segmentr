context("hieralg")

simulate2.1 = function(N)
{
  X1 = sample(1:2,N,replace=TRUE)
  X2 = sample(1:2,N,replace=TRUE)
  X3 = sample(1:2,N,replace=TRUE)
  X4 = sample(1:2,N,replace=TRUE)
  X5 = sample(1:2,N,replace=TRUE)
  X6 = sample(1:2,N,replace=TRUE)
  X = cbind(X1,X1-X2,X2,X1+X2,X1,X3,X3-X4,X4,X3+X4,X3,X5,X5-X6,X6,X5+X6,X5)
  X
}

simulate3.2 = function(N)
{
  X1 = sample(1:3,N,replace=TRUE)
  X2 = sample(1:3,N,replace=TRUE)
  X3 = X1
  X4 = X2
  X5 = sample(1:3,N,replace=TRUE)
  X6 = sample(1:3,N,replace=TRUE)
  X = cbind(X1,X1-X2,X2,X1+X2,X1,X3,X3-X4,X4,X3+X4,X3,X5,X5-X6,X6,X5+X6,X5)
  X
}


test_that("identifies points differently, if we take into account the different algorithm implementation", {
  set.seed(1234)
  data <- simulate2.1(2000)
  points <- hieralg(data, penalty = function(X) (0.1 * 2 ^ ncol(X)) * log(nrow(X)))
  expect_equal(points, c(5, 10))

  data <- simulate3.2(5000)
  points <- hieralg(data, penalty = function(X) (0.2* 3 ^ ncol(X)) * log(nrow(X)))
  expect_equal(points, c(7, 10))
})

test_that("works with a cluster as well", {
  set.seed(1234)
  data_1 <- simulate2.1(2000)
  data_2 <- simulate3.2(5000)
  doParallel::registerDoParallel(1)
  points <- hieralg(data_1, penalty = function(X) (0.1 * 2 ^ ncol(X)) * log(nrow(X)), allow_parallel = TRUE)
  expect_equal(points, c(5, 10))

  points <- hieralg(data_2, penalty = function(X) (0.2* 3 ^ ncol(X)) * log(nrow(X)), allow_parallel = FALSE)
  expect_equal(points, c(7, 10))
  doParallel::stopImplicitCluster()
})