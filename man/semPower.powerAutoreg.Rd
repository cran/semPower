% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convenienceFunctions.R
\name{semPower.powerAutoreg}
\alias{semPower.powerAutoreg}
\title{semPower.powerAutoreg}
\usage{
semPower.powerAutoreg(
  type,
  comparison = "restricted",
  nWaves = NULL,
  autoregEffects = NULL,
  lag1Effects = autoregEffects,
  lag2Effects = NULL,
  lag3Effects = NULL,
  means = NULL,
  variances = NULL,
  waveEqual = NULL,
  nullEffect = NULL,
  nullWhich = NULL,
  nullWhichGroups = NULL,
  standardized = TRUE,
  invariance = TRUE,
  autocorResiduals = TRUE,
  ...
)
}
\arguments{
\item{type}{type of power analysis, one of \code{'a-priori'}, \code{'post-hoc'}, \code{'compromise'}.}

\item{comparison}{comparison model, one of \code{'saturated'} or \code{'restricted'} (the default). This determines the df for power analyses. \code{'saturated'} provides power to reject the model when compared to the saturated model, so the df equal the one of the hypothesized model. \code{'restricted'} provides power to reject the hypothesized model when compared to an otherwise identical model that just omits the restrictions defined in \code{nullEffect}, so the df equal the number of restrictions.}

\item{nWaves}{number of waves, must be >= 2.}

\item{autoregEffects}{vector of the autoregressive effects, e.g. \code{c(.7, .6)} for  autoregressive effects of .7 for \code{X1 -> X2} and .6 for \code{X2 -> X3}. Must be a list for multiple groups models.}

\item{lag1Effects}{alternative name for \code{autoregEffects}.}

\item{lag2Effects}{vector of lag-2 effects, e.g. \code{c(.2, .1)} for lag-2 effects of .2 for \code{X1 -> X3} and .1 for \code{X2 -> X4}.}

\item{lag3Effects}{vector of lag-3 effects, e.g. \code{c(.2)} for a lag-3 effect of .2 for \code{X1 -> X4}.}

\item{means}{vector of means for \code{X}. Can be omitted for no meanstructure.}

\item{variances}{vector of (residual-)variances for \code{X}. When omitted and \code{standardized = FALSE}, all (residual-)variances are equal to 1. When omitted and \code{standardized = TRUE}, the (residual-)variances are determined so that all variances are 1, and will thus typically differ from each other. When provided, \code{standardized} must be \code{FALSE}.}

\item{waveEqual}{parameters that are assumed to be equal across waves in both the H0 and the H1 model. Valid are \code{'lag1'} (or equivalently \code{'autoreg'}), \code{'lag2'}, and  \code{'lag3'}, or \code{NULL} for none (so that all parameters are freely estimated, subject to the constraints defined in \code{nullEffect}).}

\item{nullEffect}{defines the hypothesis of interest. Valid are the same arguments as in \code{waveEqual} and additionally \code{'lag1 = 0'} (or equivalently \code{'autoregX = 0'}) \code{'lag2 = 0'}, \code{'lag3 = 0'} to constrain the autoregressive, lag-2, or lag-3 effects to zero, and \code{'autoregA = autoregB'} to the autoregressive effects be equal across groups.}

\item{nullWhich}{used in conjunction with \code{nullEffect} to identify which parameter to constrain when there are > 2 waves and parameters are not constant across waves. For example, \code{nullEffect = 'lag1 = 0'} with \code{nullWhich = 2} would constrain the second autoregressive effect for X to zero.}

\item{nullWhichGroups}{for hypothesis involving cross-groups comparisons, vector indicating the groups for which equality constrains should be applied, e.g. \code{c(1, 3)} to constrain the relevant parameters of the first and the third group. If \code{NULL}, all groups are constrained to equality.}

\item{standardized}{whether all parameters should be standardized (\code{TRUE}, the default). If \code{FALSE}, all regression relations are unstandardized.}

\item{invariance}{whether metric invariance over waves is assumed (\code{TRUE}, the default) or not (\code{FALSE}). When means are part of the model, invariant intercepts are also assumed. This affects the df when the comparison model is the saturated model and generally affects power (also for comparisons to the restricted model).}

\item{autocorResiduals}{whether the residuals of the indicators of latent variables are autocorrelated over waves (\code{TRUE}, the default) or not (\code{FALSE}). This affects the df when the comparison model is the saturated model and generally affects power (also for comparisons to the restricted model).}

\item{...}{mandatory further parameters related to the specific type of power analysis requested, see \code{\link[=semPower.aPriori]{semPower.aPriori()}}, \code{\link[=semPower.postHoc]{semPower.postHoc()}}, and \code{\link[=semPower.compromise]{semPower.compromise()}}, and parameters specifying the factor model. The order of factors is (X1, X2, ..., X_nWaves). See details.}
}
\value{
a list. Use the \code{summary} method to obtain formatted results. Beyond the results of the power analysis and a number of effect size measures, the list contains the following components:
\item{\code{Sigma}}{the population covariance matrix. A list for multiple group models.}
\item{\code{mu}}{the population mean vector or \code{NULL} when no meanstructure is involved. A list for multiple group models.}
\item{\code{SigmaHat}}{the H0 model implied covariance matrix. A list for multiple group models.}
\item{\code{muHat}}{the H0 model implied mean vector or \code{NULL} when no meanstructure is involved. A list for multiple group models.}
\item{\code{modelH0}}{\code{lavaan} H0 model string.}
\item{\code{modelH1}}{\code{lavaan} H1 model string or \code{NULL} when the comparison refers to the saturated model.}
\item{\code{simRes}}{detailed simulation results when a simulated power analysis (\code{simulatedPower = TRUE}) was performed.}
}
\description{
Convenience function for performing power analysis on effects in an autoregressive model.
This requires the lavaan package.
}
\details{
This function performs a power analysis to reject various hypotheses arising
in simple autoregressive (simplex) models, where one variable is repeatedly
assessed at two or more different time points (\code{nWaves}), yielding
autoregressive effects (aka lag-1 effects or stabilities, ; \code{X1 -> X2 -> X3}), and optionally
lagged effects (\code{X1 ->  X3}), variances, and means.

Relevant hypotheses in arising in an autogressive model are:
\itemize{
\item \code{autoreg} or \code{lag1}: Tests the hypothesis that the autoregressive (lag-1) effects are equal across waves (stationarity of autoregressive parameters).
\item \code{lag2}: Tests the hypothesis that the lag-2 effects are equal across waves (stationarity of lag-2 effects).
\item \code{lag3}: Tests the hypothesis that the lag-3 effects are equal across waves (stationarity of lag-3 effects).
\item \code{var}: Tests the hypothesis that the residual-variances of X (i.e., X_2, ..., X_nWaves) are equal across waves (stationarity of variance).
\item \code{mean}: Tests the hypothesis that the conditional means of X (i.e., X_2, ..., X_nWaves) are equal across waves (stationarity of means).
\item \code{autoreg = 0} or \code{lag1 = 0}: Tests the hypothesis that the autoregressive (lag-1) effect of X is zero.
\item \code{lag2 = 0} and \code{lag3 = 0}: Tests the hypothesis that a lag-2 or a lag-3 effect is zero.
\item \code{autoregA = autoregB} or \code{lag1A = lag1B}: : Tests the hypothesis that the autoregressive effect of X is equal across groups.
}

For hypotheses in an ARMA model, see \code{\link[=semPower.powerARMA]{semPower.powerARMA()}}. For hypotheses regarding a CLPM structure, see \code{\link[=semPower.powerCLPM]{semPower.powerCLPM()}}. For hypotheses regarding longitudinal measurement invariance, see \code{\link[=semPower.powerLI]{semPower.powerLI()}}.

Beyond the arguments explicitly contained in the function call, additional arguments
are required specifying the factor model and the requested type of power analysis.

Additional arguments related to the \strong{definition of the factor model}:
\itemize{
\item \code{Lambda}: The factor loading matrix (with the number of columns equaling the number of factors).
\item \code{loadings}: Can be used instead of \code{Lambda}: Defines the primary loadings for each factor in a list structure, e. g. \code{loadings = list(c(.5, .4, .6), c(.8, .6, .6, .4))} defines a two factor model with three indicators loading on the first factor by .5, , 4., and .6, and four indicators loading on the second factor by .8, .6, .6, and .4.
\item \code{nIndicator}: Can be used instead of \code{Lambda}: Used in conjunction with \code{loadM}. Defines the number of indicators by factor, e. g., \code{nIndicator = c(3, 4)} defines a two factor model with three and four indicators for the first and second factor, respectively. \code{nIndicator} can also be a single number to define the same number of indicators for each factor.
\item \code{loadM}: Can be used instead of \code{Lambda}: Used in conjunction with \code{nIndicator}. Defines the loading either for all indicators (if a single number is provided) or separately for each factor (if a vector is provided), e. g. \code{loadM = c(.5, .6)} defines the loadings of the first factor to equal .5 and those of the second factor do equal .6.
}

So either \code{Lambda}, or \code{loadings}, or \code{nIndicator} and \code{loadM} need to be defined.
If the model contains observed variables only, use \code{Lambda = diag(x)} where \code{x} is the number of variables.

Note that the order of the factors is (X1, X2, ..., X_nWaves).

Additional arguments related to the requested type of \strong{power analysis}:
\itemize{
\item \code{alpha}: The alpha error probability. Required for \code{type = 'a-priori'} and \code{type = 'post-hoc'}.
\item Either \code{beta} or \code{power}: The beta error probability and the statistical power (1 - beta), respectively. Only for \code{type = 'a-priori'}.
\item \code{N}: The sample size. Always required for \code{type = 'post-hoc'} and \code{type = 'compromise'}. For \code{type = 'a-priori'} and multiple group analysis, \code{N} is a list of group weights.
\item \code{abratio}: The ratio of alpha to beta. Only for \code{type = 'compromise'}.
}

If a \strong{simulated power analysis} (\code{simulatedPower = TRUE}) is requested, optional arguments can be provided as a list to \code{simOptions}:
\itemize{
\item \code{nReplications}: The targeted number of simulation runs. Defaults to 250, but larger numbers greatly improve accuracy at the expense of increased computation time.
\item \code{minConvergenceRate}:  The minimum convergence rate required, defaults to .5. The maximum actual simulation runs are increased by a factor of 1/minConvergenceRate.
\item \code{type}: specifies whether the data should be generated from a population assuming multivariate normality (\code{'normal'}; the default), or based on an approach generating non-normal data (\code{'IG'}, \code{'mnonr'}, \code{'RC'}, or \code{'VM'}).
The approaches generating non-normal data require additional arguments detailed below.
\item \code{missingVars}: vector specifying the variables containing missing data (defaults to NULL).
\item \code{missingVarProp}: can be used instead of \code{missingVars}: The proportion of variables containing missing data (defaults to zero).
\item \code{missingProp}: The proportion of missingness for variables containing missing data (defaults to zero), either a single value or a vector giving the probabilities for each variable.
\item \code{missingMechanism}: The missing data mechanism, one of \code{MCAR} (the default), \code{MAR}, or \code{NMAR}.
\item \code{nCores}: The number of cores to use for parallel processing. Defaults to 1 (= no parallel processing). This requires the \code{doSNOW} package.
}

\code{type = 'IG'} implements the independent generator approach (IG, Foldnes & Olsson, 2016) approach
specifying third and fourth moments of the marginals, and thus requires that skewness (\code{skewness}) and excess kurtosis (\code{kurtosis}) for each variable are provided as vectors. This requires the \code{covsim} package.

\code{type = 'mnonr'} implements the approach suggested by Qu, Liu, & Zhang (2020) and requires provision of  Mardia's multivariate skewness (\code{skewness})  and kurtosis  (\code{kurtosis}), where
skewness must be non-negative and kurtosis must be at least 1.641 skewness + p (p + 0.774), where p is the number of variables. This requires the \code{mnonr} package.

\code{type = 'RK'} implements the approach suggested by Ruscio & Kaczetow (2008) and requires provision of the population distributions
of each variable (\code{distributions}). \code{distributions} must be a list (if all variables shall be based on the same population distribution) or a list of lists.
Each component must specify the population distribution (e.g. \code{rchisq}) and additional arguments (\code{list(df = 2)}).

\code{type = 'VM'} implements the third-order polynomial method (Vale & Maurelli, 1983)
specifying third and fourth moments of the marginals, and thus requires that skewness (\code{skewness}) and excess kurtosis (\code{kurtosis}) for each variable are provided as vectors.  This requires the \code{semTools} package.
}
\examples{
\dontrun{
# Determine required N in a 4-wave autoregressive model
# to detect an autoregressive effect between X1 -> X2 of >= .5
# with a power of 80\% on alpha = 5\%, where
# X is measured by 3 indicators loading by .5 each (at each wave), and 
# the autoregressive effecst are .5 (X1 -> X2), .7 (X2 -> X3), and .6 (X3 -> X4), and
# there are no lagged effects, and
# metric invariance and autocorrelated residuals are assumed
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.5, .7, .6),
  nullEffect = 'autoreg=0',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)

# show summary
summary(powerAutoreg)
# optionally use lavaan to verify the model was set-up as intended
lavaan::sem(powerAutoreg$modelH1, sample.cov = powerAutoreg$Sigma,
            sample.nobs = powerAutoreg$requiredN,
            sample.cov.rescale = FALSE)
lavaan::sem(powerAutoreg$modelH0, sample.cov = powerAutoreg$Sigma,
            sample.nobs = powerAutoreg$requiredN,
            sample.cov.rescale = FALSE)


# same as above, but determine power with N = 250 on alpha = .05
powerAutoreg <- semPower.powerAutoreg(
  'post-hoc', alpha = .05, N = 250,
  nWaves = 4, 
  autoregEffects = c(.5, .7, .6),
  nullEffect = 'autoreg=0',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)

# same as above, but determine the critical chi-square with N = 250 so that alpha = beta
powerAutoreg <- semPower.powerAutoreg(
  'compromise', abratio = 1, N = 250,
  nWaves = 4, 
  autoregEffects = c(.5, .7, .6),
  nullEffect = 'autoreg=0',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)

# same as above, but compare to the saturated model
# (rather than to the less restricted model)
powerAutoreg <- semPower.powerAutoreg(
  'post-hoc', alpha = .05, N = 250,
  comparison = 'saturated',
  nWaves = 4, 
  autoregEffects = c(.5, .7, .6),
  nullEffect = 'autoreg=0',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)

# same as above, but assume only observed variables
powerAutoreg <- semPower.powerAutoreg(
  'post-hoc', alpha = .05, N = 250,
  nWaves = 4, 
  autoregEffects = c(.5, .7, .6),
  nullEffect = 'autoreg=0',
  nullWhich = 1,
  Lambda = diag(4))

# same as above, but provide reduced loadings matrix to define that
# X is measured by 3 indicators each loading by .8, .6, .7 (at each wave)
powerAutoreg <- semPower.powerAutoreg(
  'post-hoc', alpha = .05, N = 250,
  nWaves = 4, 
  autoregEffects = c(.5, .7, .6),
  nullEffect = 'autoreg=0',
  nullWhich = 1,
  loadings = list(
    c(.8, .6, .7),   # X1
    c(.8, .6, .7),   # X2
    c(.8, .6, .7),   # X3
    c(.8, .6, .7)    # X4
  ), 
  invariance = TRUE, autocorResiduals = TRUE)

# same as above, but assume wave-constant autoregressive effects
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.6, .6, .6),
  waveEqual = c('autoreg'),
  nullEffect = 'autoreg=0',
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)


# same as above, but detect that autoregressive effects are not wave-constant
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.6, .7, .8),
  nullEffect = 'autoreg',
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)

# same as above, but include lag-2 and lag-3 effects
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.6, .6, .6),
  lag2Effects = c(.25, .20),
  lag3Effects = c(.15),
  waveEqual = c('autoreg'),
  nullEffect = 'autoreg=0',
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)


# same as above, but detect that first lag-2 effect differs from zero
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.6, .6, .6),
  lag2Effects = c(.25, .20),
  lag3Effects = c(.15),
  waveEqual = c('autoreg'),
  nullEffect = 'lag2=0',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)


# same as above, but assume wave-constant lag2 effects
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.6, .6, .6),
  lag2Effects = c(.25, .25),
  lag3Effects = c(.15),
  waveEqual = c('autoreg', 'lag2'),
  nullEffect = 'lag2=0',
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)


# same as above, but detect that lag3 effect differs from zero
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4, 
  autoregEffects = c(.6, .6, .6),
  lag2Effects = c(.25, .25),
  lag3Effects = c(.15),
  waveEqual = c('autoreg', 'lag2'),
  nullEffect = 'lag3=0',
  nIndicator = rep(3, 4), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)


# Determine required N in a 3-wave autoregressive model
# assuming wave-constant autoregressive effects 
# that the autoregressive effects in group 1
# differ from those in group 2
# with a power of 80\% on alpha = 5\%, where
# X is measured by 3 indicators loading by .5 each (at each wave and in each group), and 
# the autoregressive effect is .7 in group 1 and
# the autoregressive effect is .5 in group 2 and
# there are no lagged effects, and
# metric invariance over both time and groups and autocorrelated residuals are assumed and
# the groups are equal-sized
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80, N = list(1, 1),
  nWaves = 3, 
  autoregEffects = list(
    c(.7, .7),
    c(.5, .5)
  ),
  waveEqual = c('autoreg'),
  nullEffect = 'autoregA = autoregB',
  nullWhich = 1,
  nIndicator = rep(3, 3), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE)
  
# Determine required N in a 4-wave autoregressive model
# to detect that the factor residual-variances (X2, X3, X4) differ
# with a power of 80\% on alpha = 5\%, where
# the (residual-)variances are 1, .5, 1.5, and 1, respectively,  
# X is measured by 3 indicators loading by .5 each (at each wave), and
# the autoregressive effects are .6, and
# both the H0 and the H1 assume wave-constant autoregressive effects, and
# there are no lagged effects, and
# metric invariance and autocorrelated residuals are assumed
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4,
  autoregEffects = c(.6, .6, .6),
  variances = c(1, .5, 1.5, 1),
  waveEqual = c('autoreg'),
  nullEffect = 'var',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  standardized = FALSE,
  invariance = TRUE, 
  autocorResiduals = TRUE)

# same as above, but 
# include latent means and 
# detect that latent means differ and
# assume wave-constant variances and autoregressive parameters for both H0 and H1
powerAutoreg <- semPower.powerAutoreg(
  'a-priori', alpha = .05, power = .80,
  nWaves = 4,
  autoregEffects = c(.6, .6, .6),
  variances = c(1, 1, 1, 1),
  means = c(0, .5, 1, .7),
  waveEqual = c('autoreg', 'var'),
  nullEffect = 'mean',
  nullWhich = 1,
  nIndicator = rep(3, 4), loadM = .5,
  standardized = FALSE,
  invariance = TRUE, 
  autocorResiduals = TRUE)
  
# request a simulated post-hoc power analysis with 500 replications
set.seed(300121)
powerAutoreg <- semPower.powerAutoreg(
  'post-hoc', alpha = .05, N = 500,
  nWaves = 3, 
  autoregEffects = c(.7, .7),
  waveEqual = c('autoreg'),
  nullEffect = 'autoreg = 0',
  nullWhich = 1,
  nIndicator = rep(3, 3), loadM = .5,
  invariance = TRUE, autocorResiduals = TRUE, 
  simulatedPower = TRUE,
  simOptions = list(nReplications = 500)
  )
  
}
}
\seealso{
\code{\link[=semPower.genSigma]{semPower.genSigma()}} \code{\link[=semPower.aPriori]{semPower.aPriori()}} \code{\link[=semPower.postHoc]{semPower.postHoc()}} \code{\link[=semPower.compromise]{semPower.compromise()}}
}
