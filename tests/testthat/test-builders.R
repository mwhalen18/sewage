test_that("add-component works for functions", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = read.csv, name = "reader", input = NULL)

  expect_equal(length(pipeline$nodes), 1)
})

test_that("add-component works for splitter", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Splitter(), name = "reader", input = NULL)

  expect_equal(length(pipeline$nodes), 1)
})
