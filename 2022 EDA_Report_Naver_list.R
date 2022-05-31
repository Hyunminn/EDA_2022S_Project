setwd("C:/Program Files/R/QUE2022/Economy Data Analysis Collect_Report/Final") 
getwd()

library(RSelenium)
library(dplyr)
library(stringr)
library(rvest)
library(writexl)

get.list <- function() {
  txt <- remDr$getPageSource()[[1]]
  res <- read_html(txt)
  
  #view 제목 수집 
  title <- res %>%
    html_nodes(".total_tit") %>%
    html_text()
  
  #view 링크 수집 
  link <- res %>%
    html_nodes(".total_tit") %>%
    html_attr("href") 
  
  #각 블로그 id
  pattern <- ".total_tit"
  id <- res %>% 
    html_nodes(pattern) %>%
    html_attr("href") %>% 
    str_extract_all("[0-9]+$")
  
  #view 날짜 수집
  date <- res %>%
    html_nodes(".sub_time") %>%
    html_text() 
   frames = remDr$findElements(using = "css",
                              value = '#mainFrame')
   
  
  
  tab <- cbind(title, date, link, id) %>%  as.data.frame(stringsAsFactors=FALSE)
  
  return(tab)
  
}

rD <- rsDriver(port=4190L, "firefox")

remDr <- rD$client

URL <- "https://www.naver.com/"
remDr$navigate(URL)
Sys.sleep(1)

#네이버에서 투자자산운용사 검색
element <- remDr$findElement("css", "#query")
element$sendKeysToElement(list("투자자산운용사 합격후기"))

#search_btn
pattern <- "#search_btn"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(1)

#view로 이동 
element <- remDr$findElement("css", "#lnb > div.lnb_group > div > ul > li:nth-child(2) > a")
element$clickElement()
Sys.sleep(1)

#블로그로만 수집하기 위해 블로그 버튼 클릭  
element <- remDr$findElement("css", ".type_sort .item:nth-child(2)")
element$clickElement()

tab1 <- get.list()
head(tab1)

for (i in 1:15) {
  element <- remDr$findElement   ("css", "body")
  element$sendKeysToElement(list (key = "page_down"))
  Sys.sleep(1)
} 

tab1_more <- get.list()
head(tab1_more)

outfile <- "Naver Blog.xlsx"
write_xlsx(tbl_more, outfile)