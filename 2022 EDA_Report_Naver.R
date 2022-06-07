setwd("C:/Program Files/R/QUE2022/Economy Data Analysis Collect_Report/Final") 
getwd()

library(flexdashboard)
library(RSelenium)
library(XML)
library(rvest)
library(stringr)
library(knitr)
library(dplyr)
library(tidyr)
library(lubridate)
library(httr)
library(readxl)
library(writexl)
library(jsonlite)
library(kableExtra)
library(DT)

rD <- rsDriver(port=4121L, "firefox")

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


#아래로 이동
for (i in 1:15) {
 element <- remDr$findElement   ("css", "body")
 element$sendKeysToElement(list (key = "page_down"))
 Sys.sleep(1)
} 

txt <- remDr$getPageSource()[[1]]
res <- read_html(txt)

Sys.sleep(1)

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
  str_extract("[0-9]+$")

#view 날짜 수집
date <- res %>%
  html_nodes(".sub_time") %>%
  html_text() 

tab <- cbind(title, date, link, id) %>% as_tibble() 

link.list <- tab$link

stack <- NULL

URL <- link.list

res <- read_html(URL)

#좋아요 수, 댓글 수 수집을 위해 블로그로 이동 

URL <- "https://blog.naver.com/fmsbbb/222703583754"
remDr$navigate(URL)

res <- read_html(URL)

txt <- remDr$getPageSource()[[1]]
res <- read_html(txt)

##같이 확 눌러야 같이 수집 됨 
frames = remDr$findElements(using = "css",
                            value = '#mainFrame')

print(frames)

remDr$switchToFrame(frames[[1]])

txt <- remDr$getPageSource()[[1]]
res <- read_html(txt)

pattern <- "#commentCount"
comment <- res %>% 
  html_nodes(pattern) %>% 
  html_text() %>% 
  str_trim()

pattern <- ".btn_sympathy > em:nth-child(2)"
like <- res %>% 
  html_nodes(pattern) %>% 
  html_text() %>% 
  str_trim()

remDr$switchToFrame(NULL)

txt <- remDr$getPageSource()[[1]]
res <- read_html(txt)

##동일한 방법으로 iframe이 있는 다른 블로그에서도 좋아요, 댓글 수 수집할 수 있음
##그러나 블로그마다 설정값이 다르기 때문에(iframe이 없는 블로그도 있음) iframe 코드를 입력해서 다수의 블로그에서 좋아요, 댓글 수를 한꺼번에 수집하기는 어려움 

tab <- cbind(title, date, link, id, comment, like) %>% as_tibble() 
tab
outfile <- "Naver Blog.xlsx"
write_xlsx(tab, outfile)

df <- tab %>%
  mutate(title.link = cell_spec(title, "html", link = link)) %>%
  select(title, date, link, id, comment, like)

names(df) <- c("Title","Date", "id", "comment","like")

tab %>% 
  kable(format="html", escape=FALSE) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed")) 

remDr$close()
rD$server$stop()
system("taskkill /im java.exe /F")
