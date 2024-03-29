#' semPower.postHoc
#'
#' Performs a post-hoc power analysis, i. e., determines power (= 1 - beta) given alpha, df, and and a measure of effect.
#'
#' @param effect effect size specifying the discrepancy between the null hypothesis (H0) and the alternative hypothesis (H1). A list for multiple group models; a vector of length 2 for effect-size differences. Can be `NULL` if `Sigma` and `SigmaHat` are set.
#' @param effect.measure type of effect, one of `"F0"`, `"RMSEA"`, `"Mc"`, `"GFI"`, `"AGFI"`. Can be `NULL` if `Sigma` and `SigmaHat` are set.
#' @param alpha alpha error
#' @param N the number of observations (a list for multiple group models)
#' @param df the model degrees of freedom. See [semPower.getDf()] for a way to obtain the df of a specific model. 
#' @param p the number of observed variables, only required for `effect.measure = "GFI"` and `effect.measure = "AGFI"`.
#' @param SigmaHat can be used instead of `effect` and `effect.measure`: model implied covariance matrix (a list for multiple group models). Used in conjunction with `Sigma` to define the effect.
#' @param Sigma can be used instead of `effect` and `effect.measure`: population covariance matrix (a list for multiple group models). Used in conjunction with `SigmaHat` to define effect.
#' @param muHat can be used instead of `effect` and `effect.measure`: model implied mean vector. Used in conjunction with `mu`. If `NULL`, no meanstructure is involved.
#' @param mu can be used instead of `effect` and `effect.measure`: observed (or population) mean vector. Use in conjunction with `muHat`. If `NULL`, no meanstructure is involved.
#' @param fittingFunction one of `'ML'` (default), `'WLS'`, `'DWLS'`, `'ULS'`. Defines the discrepancy function used to obtain Fmin.
#' @param simulatedPower whether to perform a simulated (`TRUE`, rather than analytical, `FALSE`) power analysis. Only available if `Sigma` and `modelH0` are defined.
#' @param modelH0 for simulated power: `lavaan` model string defining the (incorrect) analysis model.
#' @param modelH1 for simulated power: `lavaan` model string defining the comparison model. If omitted, the saturated model is the comparison model.
#' @param simOptions a list of additional options specifying simulation details, see [simulate()] for details. 
#' @param lavOptions a list of additional options passed to `lavaan`, e. g., `list(estimator = 'mlm')` to request robust ML estimation.
#' @param lavOptionsH1 alternative options passed to `lavaan` that are only used for the H1 model. If `NULL`, identical to `lavOptions`. Probably only useful for multigroup models.
#' @param ... other parameters related to plots, notably `plotShow`, `plotShowLabels`, and `plotLinewidth`.
#' @return Returns a list. Use `summary()` to obtain formatted results.
#' @examples
#' \dontrun{
#' # achieved power with a sample of N = 250 to detect misspecifications corresponding
#' # to RMSEA >= .05 on 200 df on alpha = .05.
#' ph <- semPower.postHoc(effect = .05, effect.measure = "RMSEA", 
#'                        alpha = .05, N = 250, df = 200)
#' summary(ph)
#' 
#' # power analysis for to detect the difference between a model (with df = 200) exhibiting RMSEA = .05
#' # and a model (with df = 210) exhibiting RMSEA = .06.
#' ph <- semPower.postHoc(effect = c(.05, .06), effect.measure = "RMSEA", 
#'                        alpha = .05, N = 500, df = c(200, 210))
#' summary(ph)
#' 
#' # multigroup example
#' ph <- semPower.postHoc(effect = list(.02, .01), effect.measure = "F0", 
#'                         alpha = .05, N = list(250, 350), df = 200)
#' summary(ph)
#' 
#' # power analysis based on SigmaHat and Sigma (nonsense example)
#' ph <- semPower.postHoc(alpha = .05, N = 1000, df = 5,  
#'                        SigmaHat = diag(4), 
#'                        Sigma = cov(matrix(rnorm(4*1000),  ncol=4)))
#' summary(ph)
#' 
#' # simulated power analysis (nonsense example)
#' ph <- semPower.aPriori(alpha = .05, N = 500, df = 200,  
#'                        SigmaHat = list(diag(4), diag(4)), 
#'                        Sigma = list(cov(matrix(rnorm(4*1000), ncol=4)), 
#'                                     cov(matrix(rnorm(4*1000), ncol=4))),
#'                        simulatedPower = TRUE, nReplications = 100)
#' summary(ph)
#' }
#' @seealso [semPower.aPriori()] [semPower.compromise()]
#' @importFrom stats qchisq pchisq
#' @export
semPower.postHoc <- function(effect = NULL, effect.measure = NULL, alpha,
                             N, df = NULL, p = NULL,
                             SigmaHat = NULL, Sigma = NULL, muHat = NULL, mu = NULL,
                             fittingFunction = 'ML',
                             simulatedPower = FALSE, 
                             modelH0 = NULL, modelH1 = NULL,
                             simOptions = NULL, 
                             lavOptions = NULL, lavOptionsH1 = lavOptions,
                             ...){
  args <- list(...)

  # validate input and do some preparations
  pp <- powerPrepare(type = 'post-hoc', 
                     effect = effect, effect.measure = effect.measure,
                     alpha = alpha, beta = NULL, power = NULL, abratio = NULL,
                     N = N, df = df, p = p,
                     SigmaHat = SigmaHat, Sigma = Sigma, muHat = muHat, mu = mu,
                     fittingFunction = fittingFunction,
                     simulatedPower = simulatedPower, 
                     modelH0 = modelH0,
                     lavOptions = lavOptions)

  
  if(!simulatedPower){
    
    df <- pp[['df']]
    fmin <- pp[['fmin']]
    fmin.g <- pp[['fmin.g']]

  }else{
    # first perform analytical even when simulated is requested, so both results can be provided

    # set ML/WLS fitting function in case lavoption estimator requests otherwise, 
    # because here we perform analytical power analysis and dont care for corrections
    impliedFF <- getFittingFunctionFromEstimator(lavOptions)
    if(fittingFunction != impliedFF) warning(paste('Fitting function for analytical power analysis set to', impliedFF, 'to match requested estimator for simulated power analysis.'))
    # also set corresponding estimator, so that powerLav does not complain
    aLavOptions <- lavOptions
    aLavOptionsH1 <- lavOptionsH1
    aLavOptions[['estimator']] <- aLavOptionsH1[['estimator']] <- impliedFF
    ph <- semPower.powerLav(type = 'post-hoc', 
                            alpha = alpha, 
                            modelH0 = modelH0, modelH1 = modelH1, N = pp[['N']],
                            Sigma = Sigma, mu = mu, 
                            fittingFunction = impliedFF,
                            lavOptions = aLavOptions, lavOptionsH1 = aLavOptionsH1)
    
    df <- ph[['df']]
    fmin <- ph[['fmin']]
    fmin.g <- ph[['fmin.g']]
    
  }
  
  fit <- getIndices.F(fmin, df, pp[['p']], pp[['SigmaHat']], pp[['Sigma']], pp[['muHat']], pp[['mu']], pp[['N']])
  ncp <- getNCP(fmin.g, pp[['N']])
  
  beta <- pchisq(qchisq(alpha, df, lower.tail = FALSE), df, ncp = ncp)
  power <- pchisq(qchisq(alpha, df, lower.tail = FALSE), df, ncp = ncp, lower.tail = FALSE)
  
  result <- list(
    type = "post-hoc",
    alpha = alpha,
    beta = beta,
    power = power,
    impliedAbratio = alpha / beta,
    ncp = ncp,
    fmin = fmin,
    fmin.g = fmin.g,
    effect = pp[['effect']],
    effect.measure = pp[['effect.measure']],
    N = pp[['N']],
    df = df,
    p = pp[['p']],
    chiCrit = qchisq(alpha, df, ncp = 0, lower.tail = FALSE),
    simulated = FALSE,
    plotShow = if('plotShow' %in% names(args)) args[['plotShow']] else TRUE,
    plotLinewidth = if('plotLinewidth' %in% names(args)) args[['plotLinewidth']] else 1,
    plotShowLabels = if('plotShowLabels' %in% names(args)) args[['plotShowLabels']] else TRUE
  )
  
  # add fit indices
  result <- append(result, fit)

  if(simulatedPower){
      
    sim <- simulate(modelH0 = modelH0, modelH1 = modelH1,
                    Sigma = pp[['Sigma']], mu = pp[['mu']], N = pp[['N']], alpha = alpha,
                    simOptions = simOptions,
                    lavOptions = lavOptions, lavOptionsH1 = lavOptionsH1)


    simFmin <- simFmin.g <- sim[['meanFmin']]
    if(!is.null(sim[['meanFminGroups']])) simFmin.g <- sim[['meanFminGroups']]
    
    simFit <- getIndices.F(fmin = simFmin, df = sim[['df']], p = pp[['p']], N = pp[['N']])
    names(simFit) <- paste0('sim', names(simFit))
    simNcp <- getNCP(simFmin.g, pp[['N']])
    
    # also compute chi bias in model h0 and model diff, as we now have the  (analytical) ncp
    expValH0 <- sim[['dfH0']] + ncp
    bChiSqH0 <- (mean(sim[['chiSqH0']]) - expValH0) / expValH0
    ksChiSqH0 <- getKSdistance(sim[['chiSqH0']], sim[['dfH0']], ncp)  
    expValDiff<- sim[['df']] + ncp
    bChiSqDiff <- (mean(sim[['chiSqDiff']]) - expValDiff) / expValDiff
    ksChiSqDiff <- getKSdistance(sim[['chiSqDiff']], sim[['df']], ncp)  

    simResult <- list(
      simBeta = 1 - sim[['ePower']],
      simPower = sim[['ePower']],
      simImpliedAbratio = alpha / (1 - sim[['ePower']]),
      simNcp = simNcp,
      simFmin = simFmin,
      simDf = sim[['df']],
      simChiCrit = qchisq(alpha, sim[['df']], ncp = 0, lower.tail = FALSE),
      bChiSqH0 = bChiSqH0,
      ksChiSqH0 = ksChiSqH0,
      bChiSqDiff = bChiSqDiff,
      ksChiSqDiff = ksChiSqDiff 
    )
    simResult <- append(simResult, simFit)
    simResult <- append(simResult, sim[!names(sim) %in% c('df', 'chiSqH0', 'chiSqDiff')])
    
    result <- append(result, simResult)
    result[['simulated']] <- TRUE
    
  }

  class(result) <- "semPower.postHoc"
  result

}



#' semPower.postHoc.summary
#'
#' provide summary of post-hoc power analyses
#' @param object result object from semPower.posthoc
#' @param ... other
#' @export
summary.semPower.postHoc <- function(object, ...){

  out <- getFormattedResults('post-hoc', object)

  cat("\n semPower: Post hoc power analysis\n")
  if(object[['simulated']]){
    cat(paste("\n Simulated power based on", object[['nrep']], "successful replications.\n"))
  }

  print(out, row.names = FALSE, right = FALSE)
  
  if(object[['simulated']]){
    cat(paste("\n\n Simulation Results:\n"))
    simOut <- getFormattedSimulationResults(object)

    print(simOut, row.names = FALSE, right = FALSE)
    if(is.null(object[['bLambda']])) cat('Average Parameter Biases are only available when an H1 model was specified (add comparison = restricted).')
  }  

  if(object[['plotShow']])
    semPower.showPlot(chiCrit = object[['chiCrit']], ncp = object[['ncp']], df = object[['df']], 
                      linewidth = object[['plotLinewidth']], showLabels = object[['plotShowLabels']])
  
}

