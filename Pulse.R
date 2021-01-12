library(rvest)
library(extract)

# Get Links from Census Website
webpage <- read_html("https://www.census.gov/programs-surveys/household-pulse-survey/datasets.html")
results <- webpage  %>% html_nodes(".uscb-layout-align-start-start")
urls <- vector(mode = "character", length = length(results))

for (i in seq(1, length(results))) {
  urls[i] <- results[i] %>% html_node("a") %>% html_attr("href")
}

# Get Zipped CSV URLs
zip_csv_urls <- str_extract(urls, ".*CSV.zip")
zip_csv_urls <- zip_csv_urls[!is.na(zip_csv_urls)]

# Get non-Zipped CSV URLs
csv_urls <- str_extract(urls, ".*csv")
csv_urls <- csv_urls[!is.na(csv_urls)]
csv_urls <- rev(csv_urls)

## Extending Timeout for Larger Files
options(timeout = 300)

# Downloading non-Zipped CSVs
#for (i in 1:length(csv_urls)) {
#  print(paste("Downloading File:", csv_urls[i]))
#  data <- read.csv(paste("https:", csv_urls[i], sep=""))
#  if (i == 1) {
#    csv_df <- data
#  } else {
#    csv_df <- rbind(csv_df, data)
#  }
#}

# Downloading Zipped CSVs
zip_csv_urls <- rev(zip_csv_urls)
start_week <- 1
year <- 2020
for (week in seq(start_week, length(zip_csv_urls))) {
  print(paste("Downloading File:", zip_csv_urls[week]))
  temp <- tempfile()
  download.file(paste("https:", zip_csv_urls[week], sep=""), temp)
  if (week < 10) {
    data <- read.csv(unz(temp, paste("pulse", year, "_puf_0", week, ".csv", sep="")))
  } else {
    data <- read.csv(unz(temp, paste("pulse", year, "_puf_", week, ".csv", sep="")))
  }
  if (week == start_week) {
    zip_csv_df <- data
  } else {
    zip_csv_df <- rbind.fill(zip_csv_df, data)
  }
}


