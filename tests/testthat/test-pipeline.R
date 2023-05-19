test_that("pipeline creates pipeline object", {
  pipeline = Pipeline()
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
  input = "x"
  pipeline = Pipeline() |>
    add_node(component = c, name = "Printer", input = "x")
  result = run(pipeline, x = input)
  expect_identical(
    pull_output(result, "Printer"),
    c(input)
  )
})

test_that("pull_output fails for non-executed pipelines", {
  pipeline = Pipeline()
  expect_error(
    pull_output(pipeline, "Foo")
  )
})
