## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(semPower)
ap <- semPower.aPriori(effect = .05, effect.measure = 'RMSEA', 
                        alpha = .05, power = .80, df = 100)
summary(ap)

## -----------------------------------------------------------------------------
ph <- semPower.postHoc(effect = .05, effect.measure = 'RMSEA', 
                        alpha = .05, N = 1000, df = 100)
summary(ph)

## -----------------------------------------------------------------------------
cp <- semPower.compromise(effect = .05, effect.measure = 'RMSEA', 
                           abratio = 1, N = 1000, df = 100)
summary(cp)

## ----eval=FALSE---------------------------------------------------------------
#  library(lavaan)
#  
#  # define (true) population model
#  model.pop <- '
#  # define relations between factors and items in terms of loadings
#  f1 =~ .7*x1 + .7*x2 + .5*x3 + .5*x4
#  f2 =~ .8*x5 + .6*x6 + .6*x7 + .4*x8
#  # define unique variances of the items to be equal to 1-loading^2, so that the loadings above are in a standardized metric
#  x1 ~~ .51*x1
#  x2 ~~ .51*x2
#  x3 ~~ .75*x3
#  x4 ~~ .75*x4
#  x5 ~~ .36*x5
#  x6 ~~ .64*x6
#  x7 ~~ .64*x7
#  x8 ~~ .84*x8
#  # define variances of f1 and f2 to be 1
#  f1 ~~ 1*f1
#  f2 ~~ 1*f2
#  # define covariance (=correlation, because factor variances are 1) between the factors to be .9
#  f1 ~~ 0.9*f2
#  '

## ----eval=FALSE---------------------------------------------------------------
#  # population covariance matrix
#  cov.pop <- fitted(sem(model.pop))$cov

## ----eval=FALSE---------------------------------------------------------------
#  # sanity check
#  model.h1 <- '
#  f1 =~ x1 + x2 + x3 + x4
#  f2 =~ x5 + x6 + x7 + x8
#  '
#  summary(sem(model.h1, sample.cov = cov.pop, sample.nobs = 1000), stand = T, fit = T)

## ----eval=FALSE---------------------------------------------------------------
#  # define (wrong) analysis model
#  model.h0 <- '
#  f1 =~ NA*x1 + x2 + x3 + x4
#  f2 =~ NA*x5 + x6 + x7 + x8
#  # define variances of f1 and f2 to be 1
#  f1 ~~ 1*f1
#  f2 ~~ 1*f2
#  # set correlation between the factors to 1
#  f1 ~~ 1*f2
#  '
#  # fit analysis model to population data
#  fit.h0 <- sem(model.h0, sample.cov = cov.pop, sample.nobs = 1000, likelihood='wishart')

## ----eval=FALSE---------------------------------------------------------------
#  # model implied covariance matrix
#  cov.h0 <- fitted(fit.h0)$cov
#  df <- fit.h0@test[[1]]$df
#  # perform power analysis
#  ap5 <- semPower.aPriori(SigmaHat = cov.h0, Sigma = cov.pop,
#                          alpha = .05, power = .95, df = df)
#  summary(ap5)

## -----------------------------------------------------------------------------
library(semPower)
ap1 <- semPower.aPriori(effect = .05, effect.measure = 'RMSEA', 
                        alpha = .05, power = .80, df = 100)

## -----------------------------------------------------------------------------
summary(ap1)

## -----------------------------------------------------------------------------
ap2 <- semPower.aPriori(effect = .05, effect.measure = 'RMSEA', 
                        alpha = .05, power = .80, df = 100, p = 20)
summary(ap2)

## -----------------------------------------------------------------------------
ap3 <- semPower.aPriori(effect = .05, effect.measure = 'RMSEA', 
                        alpha = .05, beta = .20, df = 100, p = 20)

## -----------------------------------------------------------------------------
ph1 <- semPower.postHoc(effect = .05, effect.measure = 'RMSEA', 
                        alpha = .05, N = 1000, df = 100)
summary(ph1)

## -----------------------------------------------------------------------------
cp1 <- semPower.compromise(effect = .08, effect.measure = 'RMSEA', 
                           abratio = 1, N = 1000, df = 100)
summary(cp1)

## -----------------------------------------------------------------------------
cp2 <- semPower.compromise(effect = .08, effect.measure = 'RMSEA', 
                           abratio = 100, N = 1000, df = 100)
summary(cp2)

## -----------------------------------------------------------------------------
semPower.powerPlot.byN(effect = .05, effect.measure = 'RMSEA', 
                       alpha = .05, df = 100, power.min = .05, power.max = .99)

## -----------------------------------------------------------------------------
semPower.powerPlot.byEffect(effect.measure = 'RMSEA', alpha = .05, N = 500, 
                            df = 100, effect.min = .001, effect.max = .10)

## ----eval=FALSE---------------------------------------------------------------
#  semPower.aPriori(alpha = .05, power = .80, df = 100,
#                   Sigma = Sigma, SigmaHat = SigmaHat)
#  semPower.postHoc(alpha = .05, N = 1000, df = 100,
#                   Sigma = Sigma, SigmaHat = SigmaHat)
#  semPower.compromise(abratio = 1, N = 1000, df = 100,
#                      Sigma = Sigma, SigmaHat = SigmaHat)
#  semPower.powerPlot.byN(alpha = .05, df = 100, power.min = .05, power.max = .99,
#                         Sigma = Sigma, SigmaHat = SigmaHat)

## ----eval=FALSE---------------------------------------------------------------
#  library(lavaan)
#  
#  # define (true) population model
#  model.pop <- '
#  f1 =~ .8*x1 + .7*x2 + .6*x3
#  f2 =~ .7*x4 + .6*x5 + .5*x6
#  f1 ~~ 1*f1
#  f2 ~~ 1*f2
#  f1 ~~ 0.5*f2
#  '
#  # define (wrong) H0 model
#  model.h0 <- '
#  f1 =~ x1 + x2 + x3
#  f2 =~ x4 + x5 + x6
#  f1 ~~ 0*f2
#  '

## ----eval=FALSE---------------------------------------------------------------
#  # get population covariance matrix; equivalent to a perfectly fitting model
#  cov.pop <- fitted(sem(model.pop))$cov
#  
#  # get covariance matrix as implied by H0 model
#  res.h0 <- sem(model.h0, sample.cov = cov.pop, sample.nobs = 1000, likelihood='wishart')
#  df <- res.h0@test[[1]]$df
#  cov.h0 <- fitted(res.h0)$cov

## ----eval=FALSE---------------------------------------------------------------
#  ph4 <- semPower.postHoc(SigmaHat = cov.h0, Sigma = cov.pop, alpha = .05, N = 1000, df = df)
#  summary(ph4)

## ----eval=FALSE---------------------------------------------------------------
#  fitmeasures(res.h0, 'chisq')
#  ph4$fmin * (ph4$N-1)

