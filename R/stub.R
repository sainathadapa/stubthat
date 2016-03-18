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
  env_obj$default_out <- list(behavior = 'return', return_val = return_val)
  invisible(NULL)
}

throwByDefaultExternal <- function(msg, env_obj) {
  env_obj$default_out <- list(behavior = 'throw', throw_msg = msg)
  invisible(NULL)
}

expectArgsExternal <- function(..., env_obj) {
  env_obj$default_expect <- list(...)
  invisible(NULL)
}

withExactArgsExternal <- function(..., env_obj) {
  expected_args <- list(...)
  
  addReturnValue <- function(return_val) {
    this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, type = 'exact_args')
    new_exact_called_with <- c(get(x = 'exact_called_with', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$exact_called_with <- new_exact_called_with
    invisible(NULL)
  }
  
  addThrowMsg <- function(msg) {
    this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, type = 'exact_args')
    new_exact_called_with <- c(get(x = 'exact_called_with', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$exact_called_with <- new_exact_called_with
    invisible(NULL)
  }
  
  list(returns = addReturnValue,
       throws = addThrowMsg)
}

withArgsExternal <- function(..., env_obj) {
  expected_args <- list(...)
  
  addReturnValue <- function(return_val) {
    this_behavior <- list(behavior = 'return', return_val = return_val, expected_args = expected_args, type = 'some_args')
    new_some_called_with <- c(get(x = 'some_called_with', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$some_called_with <- new_some_called_with
    invisible(NULL)
  }
  
  addThrowMsg <- function(msg) {
    this_behavior <- list(behavior = 'throw', throw_msg = msg, expected_args = expected_args, type = 'some_args')
    new_some_called_with <- c(get(x = 'some_called_with', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$some_called_with <- new_some_called_with
    invisible(NULL)
  }
  
  list(returns = addReturnValue,
       throws = addThrowMsg)
}

onCallExternal <- function(num, env_obj) {
  
  withExactArgs <- function(...) {
    expected_args <- list(...)
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_exact')
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_exact')
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    list(returns = addReturnValue,
         throws = addThrowMsg)
  }
  
  withArgs <- function(...) {
    expected_args <- list(...)
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_some')
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_some')
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    list(returns = addReturnValue,
         throws = addThrowMsg)
  }
  
  addReturnValue <- function(return_val) {
    this_behavior <- list(behavior = 'return', return_val = return_val, type = 'on_call', call = num)
    new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$called_with_on_call <- new_called_with_on_call
    invisible(NULL)
  }
  
  addThrowMsg <- function(msg) {
    this_behavior <- list(behavior = 'throw', throw_msg = msg, type = 'on_call', call = num)
    new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$called_with_on_call <- new_called_with_on_call
    invisible(NULL)
  }
  
  strictlyExpects <- function(...) {
    expected_args <- list(...)
    
    this_behavior <- list(behavior = 'throw', throw_msg = err_msg, type = 'on_call', call = num)
    new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$called_with_on_call <- new_called_with_on_call
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_exact')
      new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_exact')
      new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    invisible(list(returns = addReturnValue,
                   throws = addThrowMsg))
  }
  
  expects <- function(...) {
    expected_args <- list(...)
    
    this_behavior <- list(behavior = 'throw', throw_msg = err_msg, type = 'on_call', call = num)
    new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE), list(this_behavior))
    env_obj$called_with_on_call <- new_called_with_on_call
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_some')
      new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_some')
      new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = env_obj, inherits = FALSE))
      env_obj$called_with_on_call <- new_called_with_on_call
      invisible(NULL)
    }
    
    invisible(list(returns = addReturnValue,
                   throws = addThrowMsg))
  }
  
  list(withExactArgs = withExactArgs,
       withArgs = withArgs,
       returns = addReturnValue,
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
  
  returnByDefault <- function(return_val) {
    returnByDefaultExternal(return_val, env_obj = data_env)
  }
  
  throwByDefault <- function(msg) {
    throwByDefaultExternal(msg, env_obj = data_env)
  }
  
  expectArgs <- function(...) {
    expectArgsExternal(..., env_obj = data_env)
  }
  
  withExactArgs <- function(...) {
    withExactArgsExternal(..., env_obj = data_env)
  }
  
  withArgs <- function(...) {
    withArgsExternal(..., env_obj = data_env)
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
  
  mock_function <- function(...) {
    called_with_args <- as.list(environment(), all = TRUE)
    if ("..." %in% names(called_with_args)) {
      called_with_args['...'] <- NULL
      called_with_args <- c(called_with_args, list(...))
    }
    called_with_args <- called_with_args[sort(names(called_with_args))]
    
    stub_called_times_now <- get(x = 'stub_called_times', envir = data_env, inherits = FALSE) + 1L
    data_env$stub_called_times <- stub_called_times_now
    
    expectations <- get(x = 'expectations', envir = data_env, inherits = FALSE)
    
    do_this <- NULL
    
    for (expect_this in expectations) {
      
      if ((expect_this$type == 'on_call_exact') && (expect_this$call == stub_called_times_now)) {
        expect_this$type <- 'exact_args'
      }
      
      if ((expect_this$type == 'on_call_some') && (expect_this$call == stub_called_times_now)) {
        expect_this$type <- 'some_args'
      }
      
      if ((expect_this$type == 'on_call') && (expect_this$call == stub_called_times_now)) {
        do_this <- expect_this
        do_this$type <- NULL
        break
      }
      
      if (expect_this$type == 'exact_args') {
        exp_call_eql <- compare_args(expect_this$expect, called_with_args)
        if (exp_call_eql) {
          do_this <- expect_this
          do_this$type <- NULL
          break
        }
      }
      
      if (expect_this$type == 'some_args') {
        exp_call_eql <- compare_args(expect_this$expect, called_with_args, type = 'some')
        if (exp_call_eql) {
          do_this <- expect_this
          do_this$type <- NULL
          break
        }
      }
      
      if ((expect_this$type == 'default') && ('expect' %in% names(expect_this))) {
        exp_call_eql <- compare_args(expect_this$expect, called_with_args)
        if (!exp_call_eql) stop(err_msg)
      }
      
      if ((expect_this$type == 'default') && ('behavior' %in% names(expect_this))) {
        do_this <- expect_this
        do_this$type <- NULL
      }
    }
    
    if (!is.null(do_this) && (do_this$behavior == 'return')) {
      return(do_this$return_val)
    }
    
    if (!is.null(do_this) && (do_this$behavior == 'throw')) {
      stop(do_this$throw_msg)
    }
    
  }
  
  formals(mock_function) <- formals(function_to_stub)
  
  list(returns = returnByDefault,
       throws = throwByDefault,
       strictlyExpects = expectArgs,
       withExactArgs = withExactArgs,
       withArgs = withArgs,
       onCall = onCall,
       build = build_mock)
}
