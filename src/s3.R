s3put <- function(file_name, obj_name) {
  # yum install libxml2-devel
  # install.packages('devtools')
  # devtools::install_github("hadley/xml2")
  # install.packages('base64enc')
  # install.packages("aws.s3", repos = c("cloudyr" = "http://cloudyr.github.io/drat"))
  # upload the object to S3
  aws.s3::put_object(file = file_name,
                     bucket = "amorata",
                     object = obj_name, 
                     key = "AKIAJIYZ5OOSSTZUG26Q",
                     secret = "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")
}
