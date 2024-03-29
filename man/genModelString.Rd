% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helperFunctions.R
\name{genModelString}
\alias{genModelString}
\title{genModelString}
\usage{
genModelString(
  Lambda = NULL,
  Phi = NULL,
  Beta = NULL,
  Psi = NULL,
  Theta = NULL,
  tau = NULL,
  Alpha = NULL,
  useReferenceIndicator = !is.null(Beta),
  metricInvariance = NULL,
  nGroups = 1
)
}
\arguments{
\item{Lambda}{Factor loading matrix.}

\item{Phi}{Factor correlation (or covariance) matrix. If \code{NULL}, all factors are orthogonal.}

\item{Beta}{Regression slopes between latent variables (all-y notation).}

\item{Psi}{Variance-covariance matrix of latent residuals when \code{Beta} is specified. If \code{NULL}, a diagonal matrix is assumed.}

\item{Theta}{Variance-covariance matrix of manifest residuals. If \code{NULL} and \code{Lambda} is not a square matrix, \code{Theta} is diagonal so that the manifest variances are 1. If \code{NULL} and \code{Lambda} is square, \code{Theta} is 0.}

\item{tau}{Intercepts. If \code{NULL} and\code{ Alpha} is set, these are assumed to be zero.}

\item{Alpha}{Factor means. If \code{NULL} and \code{tau} is set, these are assumed to be zero.}

\item{useReferenceIndicator}{Whether to identify factors in accompanying model strings by a reference indicator (\code{TRUE}) or by setting their variance to 1 (\code{FALSE}). When \code{Beta} is defined, a reference indicator is used by default, otherwise the variance approach.}

\item{metricInvariance}{A list containing the factor indices for which the accompanying model strings should apply metric invariance labels, e.g. \code{list(c(1, 2), c(3, 4))} to assume invariance for f1 and f2 as well as f3 and f4.}

\item{nGroups}{(defaults to 1) If > 1 and \code{metricInvariance = TRUE}, group specific labels will be used in the measurement model.}
}
\value{
A list containing the following \code{lavaan} model strings:
\item{\code{modelPop}}{population model}
\item{\code{modelTrue}}{"true" analysis model freely estimating all non-zero parameters.}
\item{\code{modelTrueCFA}}{similar to \code{modelTrue}, but purely CFA based and thus omitting any regression relationships.}
}
\description{
Creates \code{lavaan} model strings from model matrices.
}
