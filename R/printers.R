#' @export
print.sewage_pipeline = function(x, ...) {
  cat(
    sprintf("Pipeline Object with %i node(s): \n\n", length(x$nodes)))

  for(node in x$nodes) {
    display_node(node)
  }
}

#' @importFrom glue glue
display_node = function(node, ...) {

  cli::cli(glue::glue(
    "
    \t{node$name} <-- Input: {paste(node$input, collapse = ' ')}
    \n
    "
  ))
}
