% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulate.R
\name{genData.IG}
\alias{genData.IG}
\title{genData.IG}
\usage{
genData.IG(N = NULL, Sigma = NULL, nSets = 1, skewness = NULL, kurtosis = NULL)
}
\arguments{
\item{N}{sample size.}

\item{Sigma}{population covariance matrix.}

\item{nSets}{number of data sets to generate}

\item{skewness}{vector specifying skewness for each variable}

\item{kurtosis}{vector specifying excess kurtosis for each variable}
}
\value{
Returns the generated data
}
\description{
Generates random data conforming to a population variance-covariance matrix using
the independent generator approach (IG, Foldnes & Olsson, 2016) approach
specifying third and fourth moments of the marginals.
}
\details{
This function is a wrapper for the respective function of the \code{covsim} package.

For details, see
Foldnes, N. & Olsson, U. H. (2016) A Simple Simulation Technique for Nonnormal Data with Prespecified Skewness, Kurtosis, and Covariance Matrix. \emph{Multivariate Behavioral Research, 51}, 207-219. 10.1080/00273171.2015.1133274
}
