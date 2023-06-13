#' @rdname draw
#' @export
draw.sewage_pipeline = function(pipeline, ...) {
  dag = construct_dag(pipeline)
  spec = spec_viz(dag)
  DiagrammeR::grViz(spec)
}

#' Visualize a pipeline
#' @description This function draws a DAG of the existing pipeline flow.
#'     For additional information see \code{igraph::spec_viz}
#' @return an \code{htmlwdget} object
#' @param pipeline an instantiated \code{pipeline} object
#' @param ... reserved for future use
#' @export
draw = function(pipeline, ...) {
  UseMethod("draw")
}

#' @importFrom glue glue
spec_viz = function(dag) {
  spec = glue::glue("digraph a_nice_graph {
                  {{dag}}
    }", .open="{{")
  return(spec)
}

construct_dag = function(pipeline) {
  inputs = character()
  names = character()

  for (node in pipeline$nodes) {
    inputs = append(inputs, node$input)
  }

  for (node in pipeline$nodes) {
    name = node$name
    if(inherits(node, "sewage_joiner")) {
      name = rep(name, length(node$input))
    }
    names = append(names, name)
  }


  inputs = gsub(".output_[0-9]{1,2}", "", inputs)
  mat = matrix(c(inputs, names), nrow = length(inputs), byrow=FALSE)
  dags = apply(mat, 1, paste, collapse = "->")
  dag = paste(dags, collapse = "\n")
  return(dag)
}
