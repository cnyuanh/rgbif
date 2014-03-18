#' Get number of occurrence records.
#' 
#' @template all
#' @import httr plyr
#' @export
#' @param nubKey Species key
#' @param georeferenced Return only occurence records with lat/long data (TRUE) or
#'    all records (FALSE, default). 
#' @param basisOfRecord Basis of record
#' @param datasetKey Dataset key
#' @param date Collection date
#' @param year Year data were collected in
#' @param catalogNumber Catalog number
#' @param country Country data was collected in
#' @param hostCountry Country that hosted the data
#' @param publishingCountry Publishing country, two letter ISO country code
#' @param from Year to start at
#' @param to Year to end at
#' @param type One of count (default), schema, basis_of_record, countries, or year.
#' @param callopts Pass on options to httr::GET for more refined control of 
#'    http calls, and error handling
#' @return A single numeric value
#' @examples \dontrun{
#' occ_count(basisOfRecord='OBSERVATION')
#' occ_count(georeferenced=TRUE)
#' occ_count(country='DENMARK')
#' occ_count(country='CANADA', georeferenced=TRUE, basisOfRecord='OBSERVATION')
#' occ_count(hostCountry='FRANCE')
#' occ_count(datasetKey='9e7ea106-0bf8-4087-bb61-dfe4f29e0f17')
#' occ_count(year=2012)
#' occ_count(nubKey=2435099)
#' occ_count(nubKey=2435099, georeferenced=TRUE)
#' 
#' # Just schema
#' occ_count(type='schema')
#' 
#' # Counts by basisOfRecord types
#' occ_count(type='basis_of_record')
#' 
#' # Counts by countries. publishingCountry must be supplied (default to US)
#' occ_count(type='countries')
#' 
#' # Counts by year. from and to years have to be supplied, default to 2000 and 2012 
#' occ_count(type='year', from=2000, to=2012)
#' }
#' 
#' @examples \donttest{
#' # Counts by publishingCountry, must supply a country (default to US)
#' ## NOT WORKING RIGHT NOW
#' occ_count(type='publishingCountry')
#' }

occ_count <- function(nubKey=NULL, georeferenced=NULL, basisOfRecord=NULL, 
  datasetKey=NULL, date=NULL, catalogNumber=NULL, country=NULL, hostCountry=NULL, 
  year=NULL, from=2000, to=2012, type='count', publishingCountry='US', callopts=list())
{
  args <- compact(list(nubKey=nubKey, georeferenced=georeferenced, 
                       basisOfRecord=basisOfRecord, datasetKey=datasetKey, 
                       date=date, catalogNumber=catalogNumber, country=country,
                       hostCountry=hostCountry, year=year))
  type <- match.arg(type, choices=c("count","schema","basis_of_record","countries","year"))
#   ,"publishingCountry"
  url <- switch(type, 
                count = 'http://api.gbif.org/v0.9/occurrence/count',
                schema = 'http://api.gbif.org/v0.9/occurrence/count/schema',
                basis_of_record = 'http://api.gbif.org/v0.9/occurrence/counts/basis_of_record',
                countries = 'http://api.gbif.org/v0.9/occurrence/counts/countries',
                year = 'http://api.gbif.org/v0.9/occurrence/counts/year')
#                 publishingCountry = 'http://api.gbif.org/v0.9/occurrence/counts/publishing_countries')
  args <- switch(type,
                count = args,
                schema = list(),
                basis_of_record = list(),
                countries = compact(list(publishingCountry=publishingCountry)),
                year = compact(list(from=from, to=to)))
#                 publishingCountry = compact(list(country=country))
  tt <- GET(url, query=args, callopts)
  warn_for_status(tt)
  assert_that(tt$headers$`content-type`=='application/json')
  res <- content(tt, as = 'text', encoding = "UTF-8")
  if(type=='count'){ as.numeric(res) } else{ RJSONIO::fromJSON(res, simplifyWithNames = FALSE) }
}