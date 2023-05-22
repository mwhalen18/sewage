#' add node to a sewage pipeline
#'
#' \code{add_node()} will place a new node in the specified pipeline. This will be executed sequentially when the pipeline is executed using \code{run()}
#' @param pipeline an initialized  sewage pipeline
#' @param component a function to be executed. Must be a valid function specification or exported sewage object including \code{Joiner} and \code{Splitter}
#' @param name a name to give to the given component. This will be used as the `input` parameter for downstream nodes
#' @param input the node to use as input into `component`. Inputs should be either (1) the name of an existing node in the pipeline, or (2) the name(s) of any argument(s) in the first ndoe of the pipeline. These names can be whatever you want, but should match the arguments you pass to \code{run()}
#' @param ... additional arguments to be passed to the `component` argument
#' @returns a \code{sewage_pipeline} object
#' @examples
#' my_func = function(df) {
#'     df %>%
#'         head(15)
#' }
#' pipeline = Pipeline()
#' pipeline = pipeline |>
#'     add_node(name = 'processor', component = my_func, input = 'file')
#' @export
add_node = function(pipeline, component, name, input, ...) {
  if (!is_pipeline(pipeline)) {
    stop("'pipeline' must be of class 'sewage_pipeline'")
  }


  if (is.character(component)) {
    stop("component cannot be a character. You should convert your function to a symbol (see as.symbol())")
  }

  if (!is.character("name")) {
    stop("name must be a character string")
  }

  dots = list(...)
  captured_component = substitute(component)

  pipeline = add_component_to_pipeline(component)
  return(pipeline)
}

# -----------------------------------------------------

add_component_to_pipeline = function(component, envir) {
  UseMethod("add_component_to_pipeline", component)
}


add_component_to_pipeline.function = function(component, envir = parent.frame()) {
  call = construct_caller(envir = envir)
  node = Node(
    name = envir$name,
    input = envir$input,
    call = call
  )

  envir$pipeline[['nodes']][[envir$name]] = node
  return(envir$pipeline)
}

add_component_to_pipeline.sewage_splitter = function(component, envir = parent.frame()) {
  component$input = envir$input
  component$name = envir$name

  envir$pipeline[['nodes']][[envir$name]] = component
  return(envir$pipeline)
}

add_component_to_pipeline.sewage_joiner = function(component, envir = parent.frame()) {
  component$input = envir$input
  component$name = envir$name

  .FUN = component$method #substitute(component$method)
  args = c(list(.FUN), envir$input, envir$dots)

  component$call = as.call(args)

  envir$pipeline[['nodes']][[envir$name]] = component

  return(envir$pipeline)
}

# -----------------------------------------------------

construct_caller = function(envir = parent.frame()) {
  .FUN = envir$captured_component
  input = envir$input
  dots = envir$dots

  args = c(list(.FUN), input, dots)

  return(as.call(args))
}
