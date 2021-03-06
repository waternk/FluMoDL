% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fitFluMoDL.R
\name{fitFluMoDL}
\alias{fitFluMoDL}
\title{Fit a FluMoDL object}
\usage{
fitFluMoDL(deaths, temp, dates, proxyH1, proxyH3, proxyB, yearweek,
  proxyRSV = NULL, smooth = TRUE, periodic = TRUE)
}
\arguments{
\item{deaths}{A vector of \emph{daily} deaths, of equal length to argument \code{`dates`}}

\item{temp}{A vector of \emph{daily} mean temperatures, of equal length to argument \code{`dates`}}

\item{dates}{A vector of dates (of class \code{Date})}

\item{proxyH1}{A vector of \emph{weekly} influenza A(H1N1)pdm09 incidence proxies, of equal
length to argument \code{`yearweek`}}

\item{proxyH3}{A vector of \emph{weekly} influenza A(H3N2) incidence proxies, of equal
length to argument \code{`yearweek`}}

\item{proxyB}{A vector of \emph{weekly} influenza B incidence proxies, of equal
length to argument \code{`yearweek`}}

\item{yearweek}{An integer vector of weeks, in \emph{yyyyww} format}

\item{proxyRSV}{An \emph{optional} vector of \emph{weekly} RSV incidence proxies, of equal
length to argument \code{`yearweek`}. (This is an experimental feature, and this argument
might be removed in the future.)}

\item{smooth}{\code{TRUE} (the default) if smoothing is to be applied to the influenza
incidence proxies when converting them to a daily series.}

\item{periodic}{Should a periodic B-spline term be included in the model? 
Defaults to \code{TRUE}.}
}
\value{
An object of class 'FluMoDL'. This is a list containing the following elements:
  \describe{
    \item{$data}{A \code{data.frame} with the data used to fit the model. Rows correspond to
    days in argument \code{dates}. The columns are named: \code{yearweek}, \code{dates},
    \code{deaths}, \code{temp}, (for temperature), \code{proxyH1}, \code{proxyH3}, \code{proxyB},
    \code{t} (linear trend, with values \code{1:nrow(m$data)}), \code{doy} (day of year,
    use to calculate the periodic B-spline term to model seasonality) and \code{dow} (day of
    the week). Also column \code{proxyRSV} if the relevant argument is provided.}

    \item{$model}{The fitted model; an object of class \code{glm} and of 'quasipoisson' family
    with log link.}

    \item{$basis}{A list with names 'temp', 'proxyH1', 'proxyH3' and 'proxyB' (and proxyRSV,
    if provided in the function arguments), containing the
    cross-basis matrices that are used as exposures in the model. See \code{\link[dlnm]{crossbasis}}.}

    \item{$MMP}{The Minimum Mortality Point, i.e. the temperature where mortality is lowest.}

    \item{$pred}{A list with names 'temp', 'proxyH1', 'proxyH3' and 'proxyB' (and 'proxyRSV'
    if provided in the function arguments), containing
    predictions (in the form of \code{\link[dlnm]{crosspred}} objects) for each exposure.
    These can be plotted in both the exposure-response and lag-response dimensions, see
    \code{\link[dlnm]{crosspred}}, \code{\link[dlnm]{plot.crosspred}} and the examples below.}

    \item{$blup}{This element is NULL when creating the object, but can receive a
    \code{\link{summary.FluMoDL}} object that contains Best Linear Unbiased Predictor
    (BLUP) coefficients, to be used when estimating attributable mortality. Can be
    retrieved or set with the \code{\link{blup.FluMoDL}} method}
  }

Objects of class 'FluMoDL' have methods \code{print()}, \code{coef()} and \code{vcov()}.
\code{coef()} returns a list of numeric vectors, with names 'proxyH1', 'proxyH3'
and 'proxyB' (and 'proxyRSV' if provided in the function arguments), containing the model
coefficients for these cross-basis terms. Similarly \code{vcov()} returns a list
of variance-covariance matrices for the same terms.
}
\description{
This function fits a FluMoDL object. This is a distributed lag nonlinear model (DLNM), of
quasipoisson family and with log link, which estimates the association between mortality
(as outcome) and daily mean temperatures and type-specific influenza incidence proxies
(as exposures), adjusted for covariates.
}
\details{
Objects of class 'FluMoDL' contain the model, the associated data, estimates of the predicted
associations and other information.
These objects can be further used as input for function \code{\link{attrMort}}, to calculate
influenza-attributable and temperature-attributable mortalities for any period in the data
(and any temperature range). Methods \code{print()}, \code{coef()} and \code{vcov()} have
been defined for objects of class 'FluMoDL' (see below),
and also \code{\link[=summary.FluMoDL]{summary()}}.

FluMoDL uses a DLNM with the \emph{daily} number of deaths as the outcome. Covariates
  include the following:
  \itemize{
    \item A \code{\link[dlnm:crossbasis]{cross-basis matrix}} for temperature. The exposure-response
    relationship is modelled with a quadratic B-spline with internal knots placed at the
    10th, 75th and 90th percentile of the temperatures distribution. The lag-response
    relationship is modelled with a natural cubic spline with three internal knots
    equidistant in the log scale.

    \item Three \code{\link[dlnm:crossbasis]{cross-basis matrices}} for influenza incidence proxies for
    each type/subtype: A(H1N1)pdm09, A(H3N2) and B. These normally are equal to a
    sentinel Influenza-Like Illness (ILI) rate, times the laboratory swab samples Percentage
    Positive (%%) for each type. The exposure-response relationship is specified as linear,
    implying an approximately constant case fatality ratio for each influenza type. The
    lag-response relationship is specified as above (for temperature).

    \item A periodic B-spline term to model seasonality, with three equidistant internal
    knots according to day of the year. Can optionally be suppressed by setting argument
    \code{periodic} to \code{FALSE}.

    \item A linear trend, and a factor variable for day of the week.

    \item \emph{Optionally}, a \code{\link[dlnm:crossbasis]{cross-basis matrix}} for an RSV
    incidence proxy, with specification identical to those for influenza. If given,
    it will be included in the model and output, and it will be possible to calculate
    mortality attributable to RSV with \code{\link{attrMort}}. This is an experimental feature;
    it might be removed in the future.
  }
}
\examples{
data(greece) # Use example surveillance data from Greece
m <- with(greece, fitFluMoDL(deaths = daily$deaths,
    temp = daily$temp, dates = daily$date,
    proxyH1 = weekly$ILI * weekly$ppH1,
    proxyH3 = weekly$ILI * weekly$ppH3,
    proxyB = weekly$ILI * weekly$ppB,
    yearweek = weekly$yearweek))
m

# Plot the association between A(H1N1)pdm09 activity and mortality
#   and the overall temperature-mortality association:
plot(m$pred$proxyH1, "overall")
plot(m$pred$temp, "overall")

# Add the Minimum Mortality Point to the plot:
abline(v=m$MMP)

# Check the lag-response dimension for the A(H1N1)pdm09 - mortality
#   association, for all proxy values, and for an indicative value of 30.
plot(m$pred$proxyH1) # Produces a 3D plot, see ?plot.crosspred
plot(m$pred$proxyH1, var=30)

# Have a look at the data associated with this FluMoDL:
str(m$data)
tail(m$data)

}
\references{
\itemize{
 \item Lytras T, Pantavou K, Mouratidou E, Tsiodras S. Mortality attributable to seasonal influenza
  in Greece, 2013 to 2017: variation by type/subtype and age, and a possible harvesting effect.
  \href{https://www.eurosurveillance.org/content/10.2807/1560-7917.ES.2019.24.14.1800118}{Euro Surveill.}
  2019;24(14):pii=1800118 (\href{https://www.ncbi.nlm.nih.gov/pubmed/30968823}{PubMed})

 \item Gasparrini A, Armstrong B, Kenward MG. Distributed lag non-linear models.
  \href{https://onlinelibrary.wiley.com/doi/abs/10.1002/sim.3940}{Stat Med} 2010;29(21):2224–34.

 \item Gasparrini A, et al. Mortality risk attributable to high and low ambient temperature:
  a multicountry observational study.
  \href{https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(14)62114-0/fulltext}{Lancet}
  2015 Jul 25;386(9991):369–75.
}
}
