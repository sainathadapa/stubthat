returnByDefaultExternal <- function(return_val, env_obj) {
  env_obj$returns_default <- list(behavior = 'return', return_val = return_val)
  invisible(NULL)
}

throwByDefaultExternal <- function(msg, env_obj) {
  env_obj$returns_default <- list(behavior = 'throw', return_val = msg)
  invisible(NULL)
}

expectsExternal <- function(..., env_obj) {
  expected_args <- list(...)
  env_obj$expectations_default <- list(behavior = 'some', args = expected_args)
  invisible(NULL)
}

strictlyExpectsExternal <- function(..., env_obj) {
  expected_args <- list(...)
  env_obj$expectations_default <- list(behavior = 'exact', args = expected_args)
  invisible(NULL)
}

withArgsExternal <- function(..., env_obj, type) {
  expected_args <- list(...)
  
  addReturnValue <- function(return_val) {
    env_obj$return_with_args <- c(list(list(behavior = 'return',
                                            type = type,
                                            return_val = return_val,
                                            args = expected_args)),
                                  env_obj$return_with_args)
    invisible(NULL)
  }
  
  addThrowMsg <- function(msg) {
    env_obj$return_with_args <- c(list(list(behavior = 'throw',
                                            return_val = msg,
                                            type = type,
                                            args = expected_args)),
                                  env_obj$return_with_args)
    invisible(NULL)
  }
  
  list(returns = addReturnValue, throws = addThrowMsg)
}

onCallExternal <- function(num, env_obj) {
  
  addReturnValue <- function(return_val) {
    env_obj$returns_on_call[[as.character(num)]] <- list(behavior = 'return', return_val = return_val)
    invisible(NULL)
  }
  
  addThrowMsg <- function(msg) {
    env_obj$returns_on_call[[as.character(num)]] <- list(behavior = 'throw', return_val = msg)
    invisible(NULL)
  }
  
  strictlyExpects <- function(...) {
    expected_args <- list(...)
    
    env_obj$expectations_on_call[[as.character(num)]] <- list(behavior = 'exact', args = expected_args)
    
    invisible(list(returns = addReturnValue,
                   throws  = addThrowMsg))
  }
  
  expects <- function(...) {
    expected_args <- list(...)
    
    env_obj$expectations_on_call[[as.character(num)]] <- list(behavior = 'some', args = expected_args)
    
    invisible(list(returns = addReturnValue,
                   throws = addThrowMsg))
  }
  
  list(returns         = addReturnValue,
       throws          = addThrowMsg,
       strictlyExpects = strictlyExpects,
       expects         = expects)
}

output_func <- function(behavior, return_val) {
  if (behavior == 'return') return(return_val)
  stop(return_val)
}
