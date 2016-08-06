#' @importFrom testthat compare
compare_args <- function(args_expected, args_incoming, type = 'exact') {
  
  if (is.null(names(args_expected))) {
    names(args_expected) <- rep('', times = length(args_expected)) 
  }
  
  if (is.null(names(args_incoming))) {
    names(args_incoming) <- rep('', times = length(args_incoming)) 
  }
  
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
    
    this_msg <- ''
    
    if (type == 'exact') {
      expected_present <- by(all_comb, INDICES = all_comb$expectI, function(x) any(x$equal))
      incoming_present <- by(all_comb, INDICES = all_comb$expectJ, function(x) any(x$equal))
      
      if (!all(expected_present)) {
        this_msg <- paste0('Number of No-Name expected arguments not present: ',
                           sum(!expected_present))
      } else if (!all(incoming_present)) {
        this_msg <- paste0('Number of No-Name incoming arguments additionally present: ',
                           sum(!incoming_present))
      }
      
      good_or_not <- all(expected_present) && all(incoming_present)
    }
    
    if (type == 'some') {
      expected_present <- by(all_comb, INDICES = all_comb$expectI, function(x) any(x$equal))
      if (!all(expected_present)) {
        this_msg <- paste0('Number of No-Name expected arguments not present: ',
                           sum(!expected_present))
      }
      good_or_not <- all(expected_present)
    }
    
    blank_nam_comp <- list(equal = good_or_not, message = '')
    
    if (!good_or_not) blank_nam_comp$message <- this_msg
    
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
    
    base_msg <- paste0('Following arguments are not matching: {', 
                       paste0("'", intersect_names[!equal_vec], "'", collapse = ', '),
                       '}')
    other_msg <- as.character(Map(
      arg_nam = intersect_names[!equal_vec],
      comp_msg = message_vec[!equal_vec],
      f = function(arg_nam, comp_msg) {
        paste0("Argument: '", arg_nam, "':\n", comp_msg)
      }
    ))
    full_msg <- paste0(c(base_msg, other_msg), collapse = '\n')
    
    return(list(
      equal = FALSE,
      message = full_msg
    ))
    
  }
  
}
