library(testthat)
library(sewage)
subset_data = function(x) {
  subset(x, cyl == 6)
}
summarizer = function(x) {
  return(summary(x[['disp']]))
}

chute = function(x) {
  return(x)
}

pipeline = Pipeline()
pipeline = pipeline |>
  add_node(component = chute, name = "Reader", input = "file") |>
  add_node(component = chute, name = "Chute1", input = "Reader") |>
  add_node(component = Splitter(), name = "Splitter", input = "Chute1") |>
  add_node(component = subset_data, name = "Subsetter", input = "Splitter.output_2") |>
  add_node(component = summarizer, name = "Summarizer", input = "Splitter.output_1")

test_that("pipeline creates pipeline object", {
  expect_s3_class(pipeline, "sewage_pipeline")
})


test_that("run fails for non-pipelines", {
  pipeline = list()
  expect_error(
    run(pipeline, file = 'temp.csv'),
    regexp = "pipeline object must be of type 'sewage_pipeline'"
    )
})

test_that("pull_output works for executed pipeline objects", {
  x = subset_data(mtcars)
  result = run(pipeline, file = mtcars)
  expect_identical(
    pull_output(result, "Subsetter"),
    x
  )
})

test_that("pull_output fails for non-executed pipelines", {
  pipeline = Pipeline()
  expect_error(
    pull_output(pipeline, "Foo")
  )
})

test_that("halter stops pipeline at correct node", {
  result = run(pipeline, halt = "Splitter", file = 'temp.csv')
  expect_equal(names(result$outputs), c("Splitter.output_1", "Splitter.output_2"))
})

test_that("Start node and halt node run a subset of pipeline", {
  pipeline1 = pipeline |>
    add_node(component = chute, name = "Chute2", input = "Summarizer") |>
    add_node(component = chute, name = "Chute3", input = "Chute2") |>
    add_node(component = chute, name = "ChuteA", input = "Subsetter")

  result = run(pipeline1, start = "Summarizer", halt = "Chute3", Splitter.output_1 = mtcars)

  expect_equal(names(result$outputs), c("Chute3"))
})
