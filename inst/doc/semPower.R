## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  ap <- semPower.aPriori(effect = .05, effect.measure = 'RMSEA',
#                          alpha = .05, power = .80, df = 100)
#  summary(ap)

## ----eval=FALSE---------------------------------------------------------------
#  ph <- semPower.postHoc(effect = .05, effect.measure = 'RMSEA',
#                          alpha = .05, N = 1000, df = 100)
#  summary(ph)

## ----eval=FALSE---------------------------------------------------------------
#  cp <- semPower.compromise(effect = .05, effect.measure = 'RMSEA',
#                             abratio = 1, N = 1000, df = 100)
#  summary(cp)

## ----eval=FALSE---------------------------------------------------------------
#  library(lavaan)
#  
#  # define (true) population model
#  model.pop <- '
#  # define relations between factors and items in terms of loadings
#  f1 =~ .7*x1 + .7*x2 + .5*x3 + .5*x4
#  f2 =~ .8*x5 + .6*x6 + .6*x7 + .4*x8
#  # define unique variances of the items to be equal to 1-loading^2,
#  # so that the loadings above are in a standardized metric
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
#  summary(sem(model.h1, sample.cov = cov.pop, sample.nobs = 1000, sample.cov.rescale = F), stand = T, fit = T)

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
#  # fit analysis model to population data; note the sample.nobs are arbitrary
#  fit.h0 <- sem(model.h0, sample.cov = cov.pop, sample.nobs = 1000, sample.cov.rescale = F, likelihood='wishart')

## ----eval=FALSE---------------------------------------------------------------
#  # model implied covariance matrix
#  cov.h0 <- fitted(fit.h0)$cov
#  df <- fit.h0@test[[1]]$df
#  # perform power analysis
#  ap5 <- semPower.aPriori(SigmaHat = cov.h0, Sigma = cov.pop,
#                          alpha = .05, power = .95, df = df)
#  summary(ap5)

## ----eval=FALSE---------------------------------------------------------------
#  library(lavaan)
#  
#  # population model group 1
#  model.pop.g1 <- '
#  f1 =~ .8*x1 + .7*x2 + .6*x3
#  f2 =~ .7*x4 + .6*x5 + .5*x6
#  x1 ~~ .36*x1
#  x2 ~~ .51*x2
#  x3 ~~ .64*x3
#  x4 ~~ .51*x4
#  x5 ~~ .64*x5
#  x6 ~~ .75*x6
#  f1 ~~ 1*f1
#  f2 ~~ 1*f2
#  f1 ~~ 0.5*f2
#  '
#  # population model group 2
#  model.pop.g2 <- '
#  f1 =~ .8*x1 + .4*x2 + .6*x3
#  f2 =~ .7*x4 + .6*x5 + .5*x6
#  x1 ~~ .36*x1
#  x2 ~~ .84*x2
#  x3 ~~ .64*x3
#  x4 ~~ .51*x4
#  x5 ~~ .64*x5
#  x6 ~~ .75*x6
#  f1 ~~ 1*f1
#  f2 ~~ 1*f2
#  f1 ~~ 0.5*f2
#  '

## ----eval=FALSE---------------------------------------------------------------
#  # population covariance matrices
#  cov.pop.g1 <- fitted(sem(model.pop.g1))$cov
#  cov.pop.g2 <- fitted(sem(model.pop.g2))$cov

## ----eval=FALSE---------------------------------------------------------------
#  # define analysis model
#  model.h0 <- '
#  f1 =~ x1 + x2 + x3
#  f2 =~ x4 + x5 + x6
#  '
#  # fit analysis model to population data; note the sample.nobs are arbitrary
#  fit.h0 <- sem(model.h0, sample.cov = list(cov.pop.g1, cov.pop.g2),
#                sample.nobs = list(1000, 1000), sample.cov.rescale = F,
#                group.equal = 'loadings', likelihood='wishart')
#  # get model implied covariance matrices
#  cov.h0.g1 <- fitted(fit.h0)$`Group 1`$cov
#  cov.h0.g2 <- fitted(fit.h0)$`Group 2`$cov
#  # df of metric invariance model
#  df <- fit.h0@test[[1]]$df
#  # obtain baseline df (no invariance constraints)
#  fit.bl <- sem(model.h0, sample.cov = list(cov.pop.g1, cov.pop.g2),
#                sample.nobs = list(1000, 1000), sample.cov.rescale=F,
#                likelihood='wishart')
#  df.bl <- fit.bl@test[[1]]$df
#  # difference in df
#  df.diff <- df - df.bl

## ----eval=FALSE---------------------------------------------------------------
#  # perform a priori power analysis
#  ap6 <- semPower.aPriori(SigmaHat = list(cov.h0.g1, cov.h0.g2),
#                          Sigma = list(cov.pop.g1, cov.pop.g2),
#                          alpha = .05, beta = .20, N = list(1, 1), df = df.diff)
#  
#  summary(ap6)

## ----eval=FALSE---------------------------------------------------------------
#  # perform post-hoc power analysis
#  ph6 <- semPower.postHoc(effect = list(0.01102, 0.01979), effect.measure = 'F0',
#                          alpha = .05, N = list(389, 389), df = df.diff)
#  summary(ph6)

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
#  res.h0 <- sem(model.h0, sample.cov = cov.pop,
#                sample.nobs = 1000, sample.cov.rescale = F, likelihood='wishart')
#  df <- res.h0@test[[1]]$df
#  cov.h0 <- fitted(res.h0)$cov

## ----eval=FALSE---------------------------------------------------------------
#  ph4 <- semPower.postHoc(SigmaHat = cov.h0, Sigma = cov.pop, alpha = .05, N = 1000, df = df)
#  summary(ph4)

## ----eval=FALSE---------------------------------------------------------------
#  fitmeasures(res.h0, 'chisq')
#  ph4$fmin * (ph4$N-1)

