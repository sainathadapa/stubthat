missing_args <- function(args_expected, args_incoming) {
  
  incoming_missing <- setdiff(args_expected, args_incoming)
  
  msg1 <- NULL
  
  if (length(incoming_missing) != 0) {
    msg1 <- paste0("Function wasn't called with the following expected arguments: ",
                   paste0(incoming_missing, collapse = ', '))
  }
  
  extra_args <- setdiff(args_incoming, args_expected)
  
  msg2 <- NULL
  
  if (length(extra_args) != 0) {
    msg2 <- paste0("Function was called with the following extra arguments: ",
                   paste0(extra_args, collapse = ', '))
  }
  
  paste0(c(msg1, msg2), collapse = '\n')
}

#' @importFrom testthat compare
compare_args <- function(args_expected, args_incoming, type = 'exact') {
  
  if (type == 'exact' && 
      (!setequal(names(args_expected), names(args_incoming)))) {
    return(list(
      equal = FALSE,
      message = missing_args(names(args_expected), names(args_incoming))
    ))
  }
  
  intersect_names <- sort(intersect(names(args_expected), names(args_incoming)))
  
  if (type == 'some' && 
      (!setequal(names(args_expected), intersect_names))) {
    return(list(equal = FALSE,
                message = missing_args(names(args_expected), intersect_names)))
  }
  
  intersect_names_sub <- setdiff(intersect_names, '')
  
  match_results <- lapply(intersect_names_sub, function(one_nam) {
    compare(args_expected[[one_nam]], args_incoming[[one_nam]])
  })
  
  if ('' %in% intersect_names) {
    args_expected_blank_nams <- args_expected[names(args_expected) == '']
    args_incoming_blank_nams <- args_incoming[names(args_incoming) == '']
    
    all_comb <- expand.grid(expectI = seq_along(args_expected_blank_nams),
                            expectJ = seq_along(args_incoming_blank_nams))
    
    all_comb$equal <- vapply(X = seq_len(nrow(all_comb)),
                             FUN.VALUE = TRUE,
                             USE.NAMES = FALSE,
                             FUN = function(k) {
                               compare(args_expected_blank_nams[[all_comb$expectI[k]]],
                                       args_incoming_blank_nams[[all_comb$expectJ[k]]])$equal
                             })
    
    if (type == 'exact') {
      good_or_not <- all(by(all_comb, INDICES = all_comb$expectI, function(x) any(x$equal))) &&
        all(by(all_comb, INDICES = all_comb$expectJ, function(x) any(x$equal)))
    }
    
    if (type == 'some') {
      good_or_not <- all(by(all_comb, INDICES = all_comb$expectI, function(x) any(x$equal)))
    }
    
    blank_nam_comp <- list(equal = good_or_not, message = '')
    
    if (!good_or_not) {
      blank_nam_comp$message <- 'Arguments with no names are not matching!'
    }
    
    match_results <- c(list(blank_nam_comp), match_results)
  }
  
  equal_vec   <- vapply(X = match_results, FUN = function(x) x$equal,   FUN.VALUE = TRUE, USE.NAMES = FALSE)
  message_vec <- vapply(X = match_results, FUN = function(x) x$message, FUN.VALUE = 'a',  USE.NAMES = FALSE)
  
  if (all(equal_vec)) {
    return(list(
      equal = TRUE,
      message = ''
    ))
  } else {
    return(list(
      equal = FALSE,
      message = paste0(message_vec[!equal_vec], collapse = '\n')
    ))
  }
}

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

#' @title Build stubs out of functions
#' @description See the vignette for usage details. You can access it by executing \code{vignette('stubthat')}.
#' @param function_to_stub is the function that the user wants to make a stub out of
#' @export
stub <- function(function_to_stub) {
  
  force(function_to_stub)
  
  data_env <- new.env(hash = FALSE, emptyenv())
  
  data_env$stub_called_times    <- 0L
  
  data_env$expectations_default <- list()
  data_env$returns_default      <- list()
  
  data_env$return_with_args     <- list()
  
  data_env$expectations_on_call <- list()
  data_env$returns_on_call      <- list()
  
  returnByDefault <- function(return_val) returnByDefaultExternal(return_val, env_obj = data_env)
  
  throwByDefault  <- function(msg) throwByDefaultExternal(msg, env_obj = data_env)
  
  expects         <- function(...) expectsExternal(..., env_obj = data_env)
  
  strictlyExpects <- function(...) strictlyExpectsExternal(..., env_obj = data_env)
  
  withExactArgs   <- function(...) withArgsExternal(..., env_obj = data_env, type = 'exact')
  
  withArgs        <- function(...) withArgsExternal(..., env_obj = data_env, type = 'some')
  
  onCall          <- function(num) onCallExternal(num, env_obj = data_env)
  
  calledTimes     <- function() return(data_env$stub_called_times)
  
  mock_function <- function(...) {
    
    called_with_args <- as.list(environment(), all = TRUE)
    if ("..." %in% names(called_with_args)) {
      called_with_args['...'] <- NULL
      called_with_args        <- c(called_with_args, list(...))
    }
    
    stub_called_times_now      <- data_env$stub_called_times + 1L
    data_env$stub_called_times <- stub_called_times_now
    stub_called_times_now_char <- as.character(stub_called_times_now)
    
    if (stub_called_times_now_char %in% names(data_env$expectations_on_call)) {
      
      exp_call_eql <- compare_args(data_env$expectations_on_call[[stub_called_times_now_char]]$args,
                                   called_with_args,
                                   type = data_env$expectations_on_call[[stub_called_times_now_char]]$behavior)
      if (!exp_call_eql$equal) stop(exp_call_eql$message)
      
    } else if ( length(data_env$expectations_default) > 0L ) {
      
      exp_call_eql <- compare_args(data_env$expectations_default$args,
                                   called_with_args,
                                   type = data_env$expectations_default$behavior)
      if (!exp_call_eql$equal) stop(exp_call_eql$message)
      
    }
    
    do_this <- list(behavior = 'return', return_val = NULL)
    
    return_behavior_resolved <- FALSE
    
    if (stub_called_times_now_char %in% names(data_env$returns_on_call)) {
      do_this$behavior         <- data_env$returns_on_call[[stub_called_times_now_char]]$behavior
      do_this$return_val       <- data_env$returns_on_call[[stub_called_times_now_char]]$return_val
      return_behavior_resolved <- TRUE
    }
    
    if ( !return_behavior_resolved && length(data_env$return_with_args) > 0L ) {
      for (this_one in data_env$return_with_args) {
        exp_call_eql <- compare_args(this_one$args, called_with_args, type = this_one$type)
        if (exp_call_eql$equal) {
          do_this$behavior         <- this_one$behavior
          do_this$return_val       <- this_one$return_val
          return_behavior_resolved <- TRUE
          break
        }
      }
    }
    
    if ( !return_behavior_resolved && length(data_env$returns_default) > 0L ) {
      do_this$behavior         <- data_env$returns_default$behavior
      do_this$return_val       <- data_env$returns_default$return_val
      return_behavior_resolved <- TRUE
    }
    
    output_func(do_this$behavior, do_this$return_val)
    
  }
  
  formals(mock_function) <- formals(function_to_stub)
  
  list(returns         = returnByDefault,
       throws          = throwByDefault,
       
       expects         = expects,
       strictlyExpects = strictlyExpects,
       
       withExactArgs   = withExactArgs,
       withArgs        = withArgs,
       
       onCall          = onCall,
       
       calledTimes     = calledTimes,
       
       f               = mock_function)
}
