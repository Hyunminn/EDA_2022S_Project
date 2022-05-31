setwd("C:/Program Files/R/QUE2022/Economy Data Analysis Collect_Report/Final")  
getwd()

library(RSelenium)
library(dplyr)
library(stringr)
library(rvest)
library(knitr)
library(XML)
library(writexl)
library(readr)
library(httr)
library(kableExtra)


rD <- rsDriver(port=4117L, "firefox")
remDr <- rD$client

URL <- "https://www.youtube.com/"
remDr$navigate(URL)
Sys.sleep(1)

element <- remDr$findElement("css", "input#search")
element$sendKeysToElement(list("투자자산운용사 합격후기"))

#search_btn
pattern <- "#search-icon-legacy"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(1)

#필터 열기 
pattern <- "#container > ytd-toggle-button-renderer"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(2)

#동영상으로 구분
#F#12(검사)를 열고 먼저 동영상으로 클릭했다가 그 후에 하면 동영상 구분 버튼 인식 
pattern <- "#collapse-content > ytd-search-filter-group-renderer:nth-child(2) > ytd-search-filter-renderer.style-scope.ytd-search-filter-group-renderer.selected"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(2)


#원하는 정보를 뽑기 위해 새로운 셀레니움 설정 
##그냥 바로 정보를 뽑게 될 경우 34가지의 기본 동영상 정보가 수집된다.
rD <- rsDriver(port=4933L, "firefox")
remDr <- rD$client


URL1 <- "https://www.youtube.com/results?search_query=%ED%88%AC%EC%9E%90%EC%9E%90%EC%82%B0%EC%9A%B4%EC%9A%A9%EC%82%AC+%ED%95%A9%EA%B2%A9%ED%9B%84%EA%B8%B0&sp=EgIQAQ%253D%253D"
remDr$navigate(URL1)
Sys.sleep(3)

for (i in 1:32) {
  element <- remDr$findElement("css", "body")
  element$sendKeysToElement(list(key = "page_down"))
  Sys.sleep(2)
  
}

  txt <- remDr$getPageSource()[[1]]
  
  res <- read_html(txt)
  Sys.sleep(1)
  
  title <- res %>%
    html_nodes("#video-title") %>%
    html_text() %>% 
    str_remove("\n") %>% 
    str_trim()
  
  link <- res %>%
    html_nodes("#video-title") %>%
    html_attr("href") %>%
    str_c("https://www.youtube.com", .)
  
  date <- res %>%
    html_nodes("#metadata-line > span:nth-child(2)") %>%
    html_text() %>% 
    str_remove("스트리밍 시간: ")
  
  length <- res %>%
    html_nodes("#overlays > ytd-thumbnail-overlay-time-status-renderer > span") %>%
    html_text()
  
  View <- res %>%
    html_nodes("#metadata-line > span:nth-child(1)") %>%
    html_text() 
  
  tbl <- cbind(title, date, length, link, View) %>%
    as.data.frame(stringsAsFactors=FALSE)
  
  return(tbl)
  
  outfile <- "Youtube_투자자산운용사 합격후기.xlsx"
  write_xlsx(tbl, outfile)
  
