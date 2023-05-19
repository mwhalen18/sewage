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
#' @param start node at which to start execution.
#' @param halt halt execution at a specified node. Adding this parameter will halt execution of the remainder of the pipeline.
#'     Note that because pipelines are executed sequentially in the order you add them to the pipeline, in the case of a branching pipeline,
#'     any nodes from a different branch that were specified earlier in the pipeline will still be executed.
#' @param ... parameter(s) to pass to starting node of the pipeline. This should match the `input` parameter of `add_node` of the starting node.
#' In the case that you have multiple inputs or are starting at a later point in the pipeline,
#'     each argument should match the name of a starting node in your pipeline.
#' @export
run = function(pipeline, start = NULL, halt = NULL, ...) {

  if(!is_pipeline(pipeline)) {
    stop("pipeline object must be of type 'sewage_pipeline'")
  }

  if(is_executed_pipeline(pipeline)) {
    stop("pipeline has already been executed")
  }

  if(!is.null(halt)) {
    halt = as.character(halt)
    if (!halt %in% names(pipeline$nodes)) {
      warning(sprintf("Halting node %s not in pipeline. Executing entire pipeline", halt))
    }
  } else{
    halt = tail(names(pipeline$nodes),1)
  }

  if(!is.null(start)) {
    start = as.character(start)
    if(!start %in% names(pipeline$nodes)) {
      stop(sprintf("Starting node %s not found in pipeline", start))
    }
  } else {
    start = head(names(pipeline$nodes), 1)
  }

  dots = list(...)

  pipeline[['outputs']] = dots
  names(pipeline$outputs) = names(dots)

  nodes = pipeline$nodes

  start_index = which(names(pipeline$nodes) == start)
  end_index = which(names(pipeline$nodes) == halt)
  working_nodes = nodes[start_index:end_index]

  for(node in working_nodes) {
    pipeline = execute(node)
    if (node$name == halt) {
      break
    }
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

