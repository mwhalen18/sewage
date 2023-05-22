#' Printing Pipelines
#' @description print a sewage pipeline
#' @param x a [Pipeline()] object
#' @param ... not used
#' @description this will print all nodes and theis inputs in the pipeline.
#'    Once the pipeline has been executed, print will show the outputs available
#'    through [pull_output()]
#' @returns formatted sewage pipeline output
#' @export
#' @examples
#' pipeline = Pipeline() |>
#'     add_node(component = head, name = "Head", input = "file")
#' print(pipeline)
print.sewage_pipeline = function(x, ...) {
  #cat(sprintf("Pipeline Object with %i node(s): \n\n", length(x$nodes)))

  print_header(x)
  print_nodes(x)
  print_outputs(x)
  invisible(x)

}

print_header = function(x) {
  if (is_executed_pipeline(x)) {
    executed = " [executed]"
  } else {
    executed = ""
  }

  header = glue::glue("Pipeline{executed}\n")
  header <- cli::rule(header, line = 2)
  cat(header)
}

print_nodes = function(x) {
  node_title = sprintf("\n%i node(s):\n", length(x$nodes))
  node_title = cli::style_italic(node_title)
  cat(node_title)
  for(node in x$nodes) {
    display_node(node)
  }
}

print_outputs = function(x) {
  if (is_executed_pipeline(x)) {
    output_title = sprintf("\n%i output(s):\n", length(x$outputs))
    output_title = cli::style_italic(output_title)

    cat(output_title)

    for (output in names(x$outputs)) {
      pout = sprintf("\t%s\n\n", output)
      cat(pout)
    }
  }
}

#' @importFrom glue glue
display_node = function(node, ...) {

  cat(glue::glue(
    "
    \t{node$name} <-- Input: {paste(node$input, collapse = ' ')}
    \n
    "
  ))
}

