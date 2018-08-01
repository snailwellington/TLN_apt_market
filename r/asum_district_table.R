library(rvest)

url <- "https://et.wikipedia.org/wiki/Tallinna_asumid"

asum_district_html <- read_html(x = url) %>% 
  html_table() %>% 
  as.data.frame()


names(asum_district_html) <- c("region","district","population","region_area")


asum_district_html <- asum_district_html %>% 
  mutate(region = ifelse(region == "Ülemistejärve", "Ülemiste järv",region))

saveRDS(object = asum_district_html,"data/rds/asum_district_match.Rds")
