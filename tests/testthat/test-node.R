library(dplyr)
test_that("Node returns a node type", {
  node = Node(input = "foo", call = read.csv, name = "bar")
  expect_s3_class(node, "sewage_node")
})

test_that("Splitter returns a splitter type", {
  splitter = Splitter(edges = 2)
  expect_s3_class(splitter, "sewage_splitter")
})

test_that("Splitter disallows less than 1 edge", {
  expect_error(Splitter(edges = 1))
})

test_that("Splitter results in split", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Splitter(), name = "Splitter", input = "data")

  output = run(pipeline, data = mtcars)

  expect_equal(length(output$outputs), 2)
})

test_that("Splitter results in n splits", {
  n_splits = 4

  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Splitter(edges = n_splits), name = "Splitter", input = "data")

  output = run(pipeline, data = mtcars)

  expect_equal(length(output$outputs), n_splits)
})

test_that("Joiner works for dplyr::bind_rows", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Joiner(method = dplyr::bind_rows), name = "Joiner", input = c("file1", "file2", "file3"))

  sewage_result = run(pipeline, file1=mtcars, file2=mtcars, file3=mtcars)
  dplyr_result = dplyr::bind_rows(mtcars, mtcars, mtcars)

  testthat::expect_equal(sewage_result$outputs$Joiner, dplyr_result)
})

test_that("Joiner works for dplyr::left_join", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Joiner(method = dplyr::left_join), name = "Joiner", input = c("file1", "file2"), by = 'name')

  sewage_result = run(pipeline, file1=dplyr::band_members, file2=dplyr::band_instruments)
  dplyr_result = dplyr::left_join(dplyr::band_members, dplyr::band_instruments, by = 'name')

  testthat::expect_equal(sewage_result$outputs$Joiner, dplyr_result)
})
