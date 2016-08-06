missing_args <- function(args_expected, args_incoming) {
  
  incoming_missing <- setdiff(args_expected, args_incoming)
  
  msg1 <- NULL
  
  if (length(incoming_missing) != 0) {
    msg1 <- paste0("Function wasn't called with the following expected arguments: ",
                   paste0("'", incoming_missing, "'", collapse = ', '))
  }
  
  extra_args <- setdiff(args_incoming, args_expected)
  
  msg2 <- NULL
  
  if (length(extra_args) != 0) {
    msg2 <- paste0("Function was called with the following extra arguments: ",
                   paste0("'", extra_args, "'", collapse = ', '))
  }
  
  paste0(c(msg1, msg2), collapse = '\n')
}