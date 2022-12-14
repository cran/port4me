#' Check whether a TCP port is free or not
#'
#' @param port (integer) A TCP port in \[1, 65535\].
#'
#' @return
#' `can_port_be_opened(port)` returns a logical indicating whether the port
#' can be opened or not, or cannot be queried.  If the port can be opened,
#' then `TRUE` is returned, if cannot be opened then `FALSE` is returned,
#' which may happen if the port is used by another process.
#' If port querying is not supported, as in R (< 4.0.0),  then `NA` is
#' returned.
#'
#' @keywords internal
#' @noRd
can_port_be_opened <- function(port) {
  stopifnot(length(port) == 1, is.numeric(port), is.finite(port), port >= 1, port <= 65535)
  
  ## If not possible to query, return NA
  ## It works in R (>= 4.0.0)
  ns <- asNamespace("parallel")
  if (!exists("serverSocket", envir = ns, mode = "function")) return(NA)
  serverSocket <- get("serverSocket", envir = ns, mode = "function")

  ## suspendInterrupts() is available in R (>= 3.5.0), so we're good here,
  ## but we use this to avoid 'R CMD check' WARNINGs in R (< 3.5.0)
  suspendInterrupts <- get("suspendInterrupts", envir = asNamespace("base"), mode = "function")

  ## Prevent user interrupts from giving false results
  suspendInterrupts({
    con <- tryCatch(serverSocket(port), error = identity)
  })

  ## Success?
  free <- inherits(con, "connection")
  if (free) close(con)
  
  free
}
