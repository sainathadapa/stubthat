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
