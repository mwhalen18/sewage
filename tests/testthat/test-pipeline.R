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
