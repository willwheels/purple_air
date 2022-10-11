library(httr)
library(tibble)

my_api_read_key <- readLines(here::here("keys", "my_read_key.txt"))

sensor_index <- 133213

base_url = paste0('https://api.purpleair.com/v1/sensors/', as.character(sensor_index))

r <- GET(base_url, add_headers("X-API-Key" = my_api_read_key))

http_status(r)

returned_content <- content(r, "parsed")

sensor_data <- as_tibble(returned_content$sensor)

## need to separate off stats and then widen that separately