
##########################  do input validation  #####################

#' validateInput
#'
#' Validates input for power calcuation function
#'
#'
#' @param power.type type of power analyses, one of "a-priori", post-hoc", "compromise", "powerplot.byN", "powerplot.byEffect"
#' @param effect effect size specifying the discrepancy between H0 and H1
#' @param effect.measure type of effect, one of "F0, "RMSEA", "Mc", "GFI", AGFI"
#' @param alpha alpha error
#' @param beta beta error
#' @param power power (1-beta)
#' @param abratio ratio alpha/beta
#' @param N the number of observations
#' @param df the model degrees of freedom
#' @param p the number of observed variables, required for effect.measure = "GFI" and "AGFI"
#' @param SigmaHat model implied covariance matrix
#' @param Sigma population covariance matrix
#' @param power.min for plotting: minimum power
#' @param power.max for plotting: maximum power
#' @param effect.min for plotting: minimum effect
#' @param effect.max for plotting: maximum effect
#' @param steps for plotting: number of sampled points
#' @param linewidth for plotting: linewidth
validateInput <- function(power.type = NULL, effect = NULL, effect.measure = NULL,
                          alpha = NULL, beta = NULL, power = NULL, abratio = NULL,
                          N = NULL, df = NULL, p = NULL,
                          SigmaHat = NULL, Sigma = NULL,
                          power.min = alpha, power.max = .999,
                          effect.min = NULL, effect.max = NULL,
                          steps = 50, linewidth = 1){

  known.effects.measures <- c("F0","RMSEA","MC","GFI", "AGFI")

  # remove list structure if length == 1
  if(is.list(effect) && length(effect) == 1) effect <- unlist(effect)
  if(is.list(N) && length(N) == 1) N <- unlist(N)
  if(is.list(SigmaHat) && length(SigmaHat) == 1) SigmaHat <- unlist(SigmaHat)
  if(is.list(Sigma) && length(Sigma) == 1) Sigma <- unlist(Sigma)
  
  # do input validation
  if(is.null(SigmaHat) && is.null(Sigma)){

    if(!effect.measure %in% known.effects.measures){
      stop(paste("Effect measure is unknown, must be one of", paste(known.effects.measures, collapse = ", ")))
    }

    # for multiple group analyses, check matching length
    if(is.list(N)){
      if(!is.null(effect) && length(effect) == 1){
        warning("Only single effect size provided in multiple group power analyses, assuming equal effects in each group.")
      }else if(!is.null(effect) && length(N) != length(effect)){
        stop("Power analyses with multiple groups requires specification of the effect size in each group.")
      }
    }
    if(is.list(effect) && power.type == "a-priori"){   # special messages for a priori, given weights need to be provided 
      if(is.null(N) || length(N) == 1){
        warning("No or only a single sample weight provided in multiple group power analyses, assuming equal weights.")        
      }else if(!is.null(N) && length(N) != length(effect)){
        stop("A priori power analyses with multiple groups requires specification of sample size weights for each group via the N argument")      
      } 
    }
    if(is.list(effect) && (power.type == "post-hoc" || power.type == "compromise")){
      if(!is.null(N) && length(N) == 1){
        warning("Only single sample size provided in multiple group power analyses, assuming equal sample sizes for each group.")
      }else if(!is.null(N) && length(N) != length(effect)){
        stop("Power analyses with multiple groups requires specification of sample sizes for each group")        
      }
    }
    
    if(power.type != 'powerplot.byEffect'){
      if(is.null(effect)) stop('Effect is not defined.')
      sapply(effect, checkPositive, message = effect.measure)
    }

    if(effect.measure == "GFI" || effect.measure == "AGFI"){

      if(is.null(p)){
        stop("effect.measure GFI and AGFI require specification of p")
      }

      checkPositive(p)

    }
  }

  if((!is.null(SigmaHat) && is.null(Sigma)) || (is.null(Sigma) && !is.null(SigmaHat))){
    stop("Both SigmaHat and Sigma must be defined when effect is determined from covariance matrices")
  }
  if(!is.null(SigmaHat) && !is.null(Sigma)){
    if(!is.null(effect) || !is.null(effect.measure))
      warning("Ignoring effect and effect.measure when Sigma and SigmaHat are set")

    if(is.list(SigmaHat) || is.list(Sigma)){
      if(length(SigmaHat) != length(Sigma)) stop("Multiple group power analyses require specification of SigmaHat and Sigma for each group.")
      if(is.null(N) && power.type != "a-priori") stop("Multiple group power analyses require specification of N for each group (representing weights in a priori power analysis).")
      if(is.null(N) && power.type == "a-priori") warning("No sample weights provided, assuming equal sample sizes in each group.")
      if(length(N) == 1){
        warning("Only single sample size provided in multiple group power analyses, assuming equal sample sizes (weights in a priori power analyses) for each group.")
      }else if(length(SigmaHat) != length(N)){
        stop("Multiple group power analyses require specification ofN  for each group.")
      } 
    }
    
    if(!is.list(SigmaHat)) SigmaHat <- list(SigmaHat)
    if(!is.list(Sigma)) Sigma <- list(Sigma)
    
    if(any(sapply(Sigma, ncol) != sapply(SigmaHat, ncol)) || any(sapply(Sigma, nrow) != sapply(SigmaHat, nrow)))
      stop("Sigma and SigmaHat must be of equal size")
    if(any(!sapply(c(Sigma,SigmaHat), isSymmetric)))
      stop("Sigma and SigmaHat must be symmetric square matrices")
    if(any(sapply(c(Sigma,SigmaHat), ncol) < 2))
      stop("Sigma and SigmaHat must be at least of dimension 2*2")
    if(any(sapply(c(Sigma,SigmaHat), function(x){sum(eigen(x)$values < 0) > 0})))
      stop("Sigma and SigmaHat must be positive definite")
  }

  checkPositive(df)

  
  # specifics depending on type of power analyses

  if(power.type == "post-hoc" || power.type == "compromise" || (power.type == "a-priori" && is.list(effect))){
    if(is.null(N)) stop('N is not defined.')
    sapply(N, checkPositive, message = 'N')
  }

  if(power.type == "a-priori" || power.type == "post-hoc"){
    checkBounded(alpha)
  }

  if(power.type == "a-priori"){
    if(is.null(beta) && is.null(power))
      stop("Need to define either beta or power in a-priori power analyis")
    if(!is.null(beta) && !is.null(power) && power != (1-beta))
      stop("Either set beta or set power, but not both.")
    if(!is.null(beta))
      checkBounded(beta)
    if(!is.null(power))
      checkBounded(power)
  }

  if(power.type == "compromise"){
    checkPositive(abratio)
  }

  # specifics for power plots
  if(power.type == "powerplot.byN"){
    checkBounded(alpha)
    checkBounded(power.max)
    checkBounded(power.min)
    checkPositive(steps)
    checkPositive(linewidth)
  }
  
  if(power.type == "powerplot.byEffect"){
    checkPositive(N)
    checkBounded(alpha)
    checkPositive(effect.min)
    checkPositive(effect.max)
    checkPositive(steps)
    checkPositive(linewidth)
  }
  
  
}


#' checkPositive
#'
#' checks whether x is defined and a positive number, stop otherwise
#' @param x x
#' @param message identifier for x
checkPositive <- function(x, message = NULL){
  if(is.null(message)) message <- deparse(substitute(message))
  if(is.null(x) || is.na(x) || x <= 0){
    stop(paste(message," must be larger than zero"))
  }
}

#' checkBounded
#'
#' checks whether x is defined and lies within the specified bound
#' @param x x
#' @param message identifier for x
#' @param bound the boundaries, array of size two
checkBounded <- function(x, message = NULL, bound = c(0,1)){
  if(is.null(message)) message <- deparse(substitute(message))
  if(is.null(x) || is.na(x) || x <= bound[1] || x >= bound[2]){
    stop(paste(message," must must lie within",bound[1],'and', bound[2]))
  }
}

#' checkPositiveDefinite
#'
#' checks whether x is positive definite
#' @param x x
#' @param message identifier for x
checkPositiveDefinite <- function(x, message = NULL){
  if(is.null(message)) message <- deparse(substitute(message))
  if(is.null(x))
    stop(paste(message, " may not be NULL"))
  if(!is.numeric(x))
    stop(paste(message, " must contain numeric elements only"))
  if(!isSymmetric(x))
    stop(paste(message, " must be a symmetric square matrix"))
  if(sum(eigen(x)$values < 0) > 0)
    stop(paste(message, " must be positive definite"))
}
