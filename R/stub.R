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

#' @title Build stubs out of functions
#' @description See the vignette for details on usage
#' @param function_to_stub is the function that the user wants to make a stub out of
#' @export
stub <- function(function_to_stub) {
  
  force(function_to_stub)
  
  data_env <- new.env(hash = FALSE, emptyenv())
  assign(x = 'default_out', value = list(), envir = data_env)
  assign(x = 'default_expect', value = list(), envir = data_env)
  assign(x = 'exact_called_with', value = list(), envir = data_env)
  assign(x = 'some_called_with', value = list(), envir = data_env)
  assign(x = 'called_with_on_call', value = list(), envir = data_env)
  assign(x = 'stub_called_times', value = 0L, envir = data_env)
  
  returnByDefault <- function(return_val) {
    assign(x = 'default_out', value = list(behavior = 'return', return_val = return_val), envir = data_env)
    invisible(NULL)
  }
  
  throwByDefault <- function(msg) {
    assign(x = 'default_out', value = list(behavior = 'throw', throw_msg = msg), envir = data_env)
    invisible(NULL)
  }
  
  expectArgs <- function(...) {
    assign(x = 'default_expect', value = list(...), envir = data_env)
    invisible(NULL)
  }
  
  withExactArgs <- function(...) {
    expected_args <- list(...)
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, type = 'exact_args')
      new_exact_called_with <- c(get(x = 'exact_called_with', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'exact_called_with', value = new_exact_called_with, envir = data_env)
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, type = 'exact_args')
      new_exact_called_with <- c(get(x = 'exact_called_with', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'exact_called_with', value = new_exact_called_with, envir = data_env)
      invisible(NULL)
    }
    
    list(returns = addReturnValue,
         throws = addThrowMsg)
  }
  
  withArgs <- function(...) {
    expected_args <- list(...)
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, expected_args = expected_args, type = 'some_args')
      new_some_called_with <- c(get(x = 'some_called_with', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'some_called_with', value = new_some_called_with, envir = data_env)
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, expected_args = expected_args, type = 'some_args')
      new_some_called_with <- c(get(x = 'some_called_with', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'some_called_with', value = new_some_called_with, envir = data_env)
      invisible(NULL)
    }
    
    list(returns = addReturnValue,
         throws = addThrowMsg)
  }
  
  onCall <- function(num) {
    
    withExactArgs <- function(...) {
      expected_args <- list(...)
      
      addReturnValue <- function(return_val) {
        this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_exact')
        new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      addThrowMsg <- function(msg) {
        this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_exact')
        new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      list(returns = addReturnValue,
           throws = addThrowMsg)
    }
    
    withArgs <- function(...) {
      expected_args <- list(...)
      
      addReturnValue <- function(return_val) {
        this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_some')
        new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      addThrowMsg <- function(msg) {
        this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_some')
        new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      list(returns = addReturnValue,
           throws = addThrowMsg)
    }
    
    addReturnValue <- function(return_val) {
      this_behavior <- list(behavior = 'return', return_val = return_val, type = 'on_call', call = num)
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
      invisible(NULL)
    }
    
    addThrowMsg <- function(msg) {
      this_behavior <- list(behavior = 'throw', throw_msg = msg, type = 'on_call', call = num)
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
      invisible(NULL)
    }
    
    strictlyExpects <- function(...) {
      expected_args <- list(...)
      
      this_behavior <- list(behavior = 'throw', throw_msg = 'Function is called with arguments different from expected!', type = 'on_call', call = num)
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
      
      addReturnValue <- function(return_val) {
        this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_exact')
        new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = data_env, inherits = FALSE))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      addThrowMsg <- function(msg) {
        this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_exact')
        new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = data_env, inherits = FALSE))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      invisible(list(returns = addReturnValue,
           throws = addThrowMsg))
    }
    
    expects <- function(...) {
      expected_args <- list(...)
      
      this_behavior <- list(behavior = 'throw', throw_msg = 'Function is called with arguments different from expected!', type = 'on_call', call = num)
      new_called_with_on_call <- c(get(x = 'called_with_on_call', envir = data_env, inherits = FALSE), list(this_behavior))
      assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
      
      addReturnValue <- function(return_val) {
        this_behavior <- list(behavior = 'return', return_val = return_val, expect = expected_args, call = num, type = 'on_call_some')
        new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = data_env, inherits = FALSE))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
        invisible(NULL)
      }
      
      addThrowMsg <- function(msg) {
        this_behavior <- list(behavior = 'throw', throw_msg = msg, expect = expected_args, call = num, type = 'on_call_some')
        new_called_with_on_call <- c(list(this_behavior), get(x = 'called_with_on_call', envir = data_env, inherits = FALSE))
        assign(x = 'called_with_on_call', value = new_called_with_on_call, envir = data_env)
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
  
  build_mock <- function() {
    build_expectations()
    return(mock_function)
  }
  
  assign(x = 'expectations', value = list(), envir = data_env)
  
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
    
    assign(x = 'expectations', value = new_expectations, envir = data_env)
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
    assign(x = 'stub_called_times', value = stub_called_times_now, envir = data_env)
    
    
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
        if (!exp_call_eql) stop('Function is called with arguments different from expected!')
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
