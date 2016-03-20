compare_args <- function(args1, args2, type = 'exact') {
  if (type == 'exact') {
    if (!setequal(names(args1), names(args2))) return(FALSE)
    return(isTRUE(all.equal(args1, args2[names(args1)])))
  } 
  
  if (type == 'some') {
    intersect_names <- intersect(names(args1), names(args2))
    if (!setequal(names(args1), intersect_names)) return(FALSE)
    return(isTRUE(all.equal(args1[intersect_names], args2[intersect_names])))
  }
}

err_msg <- 'Function is called with arguments different from expected!'

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
    env_obj$return_with_args <- c(env_obj$return_with_args,
                                  list(list(behavior = 'return',
                                            type = type,
                                            return_val = return_val,
                                            args = expected_args))
    )
    invisible(NULL)
  }
  
  addThrowMsg <- function(msg) {
    env_obj$return_with_args <- c(env_obj$return_with_args,
                                  list(list(behavior = 'throw',
                                            return_val = msg,
                                            type = type,
                                            args = expected_args))
    )
    invisible(NULL)
  }
  
  list(returns = addReturnValue,
       throws = addThrowMsg)
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
    
    invisible(list(
      returns = addReturnValue,
      throws = addThrowMsg
    ))
  }
  
  expects <- function(...) {
    expected_args <- list(...)
    
    env_obj$expectations_on_call[[as.character(num)]] <- list(behavior = 'some', args = expected_args)
    
    invisible(list(
      returns = addReturnValue,
      throws = addThrowMsg
    ))
  }
  
  list(returns = addReturnValue,
       throws = addThrowMsg,
       strictlyExpects = strictlyExpects,
       expects = expects)
}

#' @title Build stubs out of functions
#' @description See the vignette for details on usage
#' @param function_to_stub is the function that the user wants to make a stub out of
#' @export
stub <- function(function_to_stub) {
  
  force(function_to_stub)
  
  data_env <- new.env(hash = FALSE, emptyenv())
  data_env$default_out <- list()
  data_env$default_expect <- list()
  
  data_env$exact_called_with <- list()
  data_env$some_called_with <- list()
  data_env$called_with_on_call <- list()
  
  data_env$stub_called_times <- 0L
  
  data_env$expectations_default <- list()
  data_env$returns_default <- list()
  
  data_env$return_with_args <- list()
  
  data_env$expectations_on_call <- list()
  data_env$returns_on_call <- list()
  
  returnByDefault <- function(return_val) {
    returnByDefaultExternal(return_val, env_obj = data_env)
  }
  
  throwByDefault <- function(msg) {
    throwByDefaultExternal(msg, env_obj = data_env)
  }
  
  expects <- function(...) {
    expectsExternal(..., env_obj = data_env)
  }
  
  strictlyExpects <- function(...) {
    strictlyExpectsExternal(..., env_obj = data_env)
  }
  
  withExactArgs <- function(...) {
    withArgsExternal(..., env_obj = data_env, type = 'exact')
  }
  
  withArgs <- function(...) {
    withArgsExternal(..., env_obj = data_env, type = 'some')
  }
  
  onCall <- function(num) {
    onCallExternal(num, env_obj = data_env)
  }
  
  build_mock <- function() {
    build_expectations()
    return(mock_function)
  }
  
  data_env$expectations <- list()
  
  build_expectations <- function() {
    default_expectations <- get(x = 'default_out', envir = data_env, inherits = FALSE)
    if (length(get(x = 'default_expect', envir = data_env, inherits = FALSE)) != 0) {
      default_expectations <- c(default_expectations, list(expect = get(x = 'default_expect', envir = data_env, inherits = FALSE))) 
    }
    if (length(default_expectations) != 0) default_expectations$type <- 'default'
    if (length(default_expectations) != 0) default_expectations <- list(default_expectations)
    
    all_expectations_list <- list(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE),
                                  get(x = 'exact_called_with', envir = data_env, inherits = FALSE),
                                  get(x = 'some_called_with', envir = data_env, inherits = FALSE),
                                  default_expectations)
    new_expectations <- Reduce(f = `c`, init = list(), x = all_expectations_list)
    
    data_env$expectations <- new_expectations
    invisible(NULL)
  }
  
  output_func <- function(behavior, return_val) {
    if (behavior == 'return') {
      return(return_val)
    }
    
    stop(return_val)
  }
  
  mock_function <- function(...) {
    
    called_with_args <- as.list(environment(), all = TRUE)
    if ("..." %in% names(called_with_args)) {
      called_with_args['...'] <- NULL
      called_with_args <- c(called_with_args, list(...))
    }
    called_with_args <- called_with_args[order(names(called_with_args), na.last = TRUE)]
    
    stub_called_times_now <- get(x = 'stub_called_times', envir = data_env, inherits = FALSE) + 1L
    data_env$stub_called_times <- stub_called_times_now
    stub_called_times_now_char <- as.character(stub_called_times_now)
    
    if (stub_called_times_now_char %in% names(data_env$expectations_on_call)) {
      
      exp_call_eql <- compare_args(data_env$expectations_on_call[[stub_called_times_now_char]]$args,
                                   called_with_args,
                                   type = data_env$expectations_on_call[[stub_called_times_now_char]]$behavior)
      if (!exp_call_eql) stop(err_msg)
      
    } else if ( length(data_env$expectations_default) > 0L ) {
      
      exp_call_eql <- compare_args(data_env$expectations_default$args,
                                   called_with_args,
                                   type = data_env$expectations_default$behavior)
      if (!exp_call_eql) stop(err_msg)
      
    }
    
    do_this <- list(behavior = 'return', return_val = NULL)
    
    return_behavior_resolved <- FALSE
    
    if (stub_called_times_now_char %in% names(data_env$returns_on_call)) {
      do_this$behavior <- data_env$returns_on_call[[stub_called_times_now_char]]$behavior
      do_this$return_val <- data_env$returns_on_call[[stub_called_times_now_char]]$return_val
      return_behavior_resolved <- TRUE
    }
    
    if ( !return_behavior_resolved && length(data_env$return_with_args) > 0L ) {
      for (this_one in data_env$return_with_args) {
        exp_call_eql <- compare_args(this_one$args, called_with_args, type = this_one$type)
        if (exp_call_eql) {
          do_this$behavior <- this_one$behavior
          do_this$return_val <- this_one$return_val
          return_behavior_resolved <- TRUE
          break
        }
      }
    }
    
    if ( !return_behavior_resolved && length(data_env$returns_default) > 0L ) {
      do_this$behavior <- data_env$returns_default$behavior
      do_this$return_val <- data_env$returns_default$return_val
      return_behavior_resolved <- TRUE
    }
    
    output_func(do_this$behavior, do_this$return_val)
    
  }
  
  formals(mock_function) <- formals(function_to_stub)
  
  list(returns = returnByDefault,
       throws = throwByDefault,
       
       expects = expects,
       strictlyExpects = strictlyExpects,
       
       withExactArgs = withExactArgs,
       withArgs = withArgs,
       
       onCall = onCall,
       build = build_mock)
}
