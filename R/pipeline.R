#' Initialize a sewage Pipeline
#' @export
#' @returns A sewage pipeline object
Pipeline = function() {
  out = init_pipeline()
  return(out)
}

init_pipeline = function() {
  pipeline = list(
    initialized = Sys.time(),
    nodes = list(),
    outputs = list()
  )
  structure(pipeline, class = "sewage_pipeline")
}

is_pipeline = function(x) {
  inherits(x, 'sewage_pipeline')
}

#' Run a pipeline
#'
#' This function is the extry point for executing a pipeline object
#' @param pipeline an initialized pipeline object
#' @param ... parameter(s) to pass to first node of the pipeline. This should match the `input` parameter of `add_node` of the first node.
#' In the case that you have multiple inputs, each argument should match the name of a starting node in your pipeline.
#' @export
run = function(pipeline, ...) {

  if(!is_pipeline(pipeline)) {
    stop("pipeline object must be of type 'sewage_pipeline'")
  }

  dots = list(...)

  pipeline[['outputs']] = dots
  names(pipeline$outputs) = names(dots)

  nodes = pipeline$nodes

  for(node in nodes) {
    pipeline = execute(node)
  }

  return(pipeline)

}

is_executed_pipeline = function(x) {
  if(!is_pipeline(x)) {
    stop("x must be a sewage_pipeline")
  }

  return(length(x$outputs) > 0)
}

#' Extract output components from a pipeline
#' @param x an executed pipeline object
#' @param component a character string specifying which output component to pull
#' #' \dontrun{
#' pipeline = Pipeline()
#' pipeline = pipeline |>
#'     add_node(name = 'Splitter', component = Splitter(), input = 'file')
#' result = run(pipeline, file = mtcars)
#' result$outputs$Splitter.output_1
#' result$outputs$Splitter.output_2
#' }
#' @export
pull_output = function(x, component, ...) {
  UseMethod("pull_output")
}

#' @export
#' @rdname pull_output
pull_output.sewage_pipeline = function(x, component, ...) {
  if(!is_executed_pipeline(x)) {
    stop("No outputs available. Please execute pipeline using 'run'")
  }
  if(!is.character(component)) {
    stop("component must be a character string")
  }
  output = x$outputs[[component]]
  print(output)
}

