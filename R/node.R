Node = function(input, call, name) {
  out = init_node()
  attr(out, "class") = "sewage_node"
  return(out)
}

init_node = function(envir = parent.frame()) {
  node = list(
    name = envir$name,
    input = envir$input,
    call = envir$call
  )

  return(node)
}

is_node = function(x) {
  inherits(x, "sewage_node")
}

#' Initialize a splitter object
#' @description \code{Splitter} takes in exactly one input node and
#'     propogates the input to \emph{n} output nodes.
#' @param edges number out outputs. Must be greater than 1
#' @note The ouputs of a \code{Splitter} object are accessed through the naming
#'     convention \code{{name}.output_{i}} where \code{name}
#'     is the specified name of the Splitter object. This allows you to pass
#'     split objects to downstream nodes or access them through the pipeline
#'     results.
#' @export
#' @details
#' After executing a \code{Splitter} object, the pipeline will contains
#'     \emph{n} outputs and will be named as \code{SplitterName_output{i}}.
#' @return a \code{sewage_splitter} object
#' @examples
#' \dontrun{
#' pipeline = Pipeline()
#' pipeline = pipeline |>
#'     add_node(name = 'Splitter', component = Splitter(), input = 'file')
#' result = run(pipeline, file = mtcars)
#' result$outputs$Splitter.output_1
#' result$outputs$Splitter.output_2
#' }
Splitter = function(edges = 2) {
  if(edges <= 1) {
    stop("edges must be > 1")
  }
  out = init_splitter()
  return(out)
}

init_splitter = function(envir = parent.frame()) {
  splitter = list(
    edges = envir$edges
  )

  attr(splitter, "class") = "sewage_splitter"

  return(splitter)
}

is_splitter = function(x) {
  inherits(x, "sewage_splitter")
}

#' Initialize a Joiner object
#' @description The \code{Joiner} takes in objects and joins them according to a
#' defined method into a single node.
#' @note additional arguments to be passed to \code{method} should be passed in the
#' \code{...} of [add_node()]
#' @param method function to join incoming objects together
#' @return a \code{sewage_joiner} object
#' @export
#' @examples
#' pipeline = Pipeline() |>
#'     add_node(Joiner(method = rbind), name = "Joiner", input = c("file1", "file2"))

Joiner = function(method) {
  method = substitute(method)
  out = init_joiner()
  attr(out, "class") = "sewage_joiner"
  return(out)
}

init_joiner = function(envir = parent.frame()) {
  joiner = list(
    method = envir$method
  )

  return(joiner)
}

is_joiner = function(x) {
  inherits(x, "sewage_joiner")
}

execute = function(x, envir) {
  UseMethod("execute", x)
}

execute.sewage_splitter = function(x, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input  = x[['input']]
  if(!input %in% names(outputs)) {
    stop(sprintf("missing input to node %s", x$name))
  }
  output = list()

  for(i in 1:x$edges) {
    output[[i]] = outputs[[input]]
  }

  names(output) = paste0(x$name, ".output_", 1:x$edges)

  out = c(outputs, output)
  out[[input]] = NULL

  envir$pipeline$outputs = out

  return(envir$pipeline)
}

execute.sewage_node = function(x, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input = x[['input']]
  call = x$call
  if(!input %in% names(outputs)) {
    stop(sprintf("missing input to node %s", x$name))
  }
  call[[2]] = outputs[[input]]
  output = eval(call, envir = parent.frame(n = 2))

  output = list(name = output)
  names(output) = x$name

  out = c(outputs, output)
  out[[input]] = NULL


  envir$pipeline$outputs = out

  return(envir$pipeline)
}

execute.sewage_joiner = function(x, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  inputs = x[['input']]
  call = x$call

  for(input in inputs) {
    if(!input %in% names(outputs)) {
      stop(sprintf("missing input to node %s", x$name))
    }
  }

  for(i in 1:length(inputs)) {
    call[[i+1]] = outputs[[inputs[i]]]
  }

  output = eval(call, envir = parent.frame(n = 2))

  output = list(name = output)
  names(output) = x$name
  out = c(outputs, output)

  out[inputs] = NULL

  envir$pipeline$outputs = out
  return(envir$pipeline)

}
