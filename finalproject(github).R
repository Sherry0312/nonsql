#C:\Users\Jacky\Documents\畢專\RSelenium>java -jar selenium-server-standalone-3.141.59.jar
library(RSelenium)
library(rvest)
library(dplyr)
library(jsonlite)

remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444)
remDr$open()

# 建立連線後開啟instagram登入網址
remDr$navigate("https://www.instagram.com/accounts/login/")

# 輸入帳號
username<- "aaaaaaa"  # <username here>
Keyname <- remDr$findElement(using = 'xpath', value =
                               "//div[@class='-MzZI'][1]/div[@class='_9GP1n   ']/label[@class='f0n8F ']/input[@class='_2hvTZ pexuQ zyHYP']")
Keyname$sendKeysToElement(list(username))
#輸入密碼
password <- "aaaaaaa"  # <password here>
Keypassword <- remDr$findElement(using = 'xpath', value =
                                   "//div[@class='-MzZI'][2]/div[@class='_9GP1n   ']/label[@class='f0n8F ']/input[@class='_2hvTZ pexuQ zyHYP']")
Keypassword$sendKeysToElement(list(password))

#點選登入按鈕
Signin <- remDr$findElement(using = 'xpath', value = "//button[@class='sqdOP  L3NKy   y3zKF     ']")
Signin$clickElement()
#要手動點掉隱私設定

#第一層
remDr$navigate("https://www.instagram.com/tsai_ingwen/?hl=zh-tw")
#postUrl<-c()
for(i in 1:5){      #scroll and cache data
  remDr$executeScript(paste("scroll(0,",i*10000,");")) #
  Sys.sleep(5) #
  page1_source<-remDr$getPageSource()
  # 使用read_html(“欲擷取的網站網址”)函數讀取網頁
  page1Content<-read_html(page1_source[[1]],encoding = "UTF-8") 
  #%>% 將前一次函數的輸出作為後一次函數的輸入時
  # 使用html_nodes()函數擷取所需內容 (條件為CSS或xpath標籤)
  # 使用html_attr()函數擷取資料參數（如連結url）
  href<- page1Content %>% html_nodes("a") %>% html_attr('href')
  #grepl回傳每個向量是否符合條件
  posthref<-href[grepl('/p/',href)]
  #paste0兩文字連接
  url<-paste0("https://www.instagram.com",posthref)
  
  #check unique
  for (j in 1:length(url)){
    #%in%是不是存在在向量中
     if(url[j]%in%postUrl){
       next
     }else{
       postUrl<-c(postUrl,url[j])
     }
   }
}
#unique把重複元素刪除的方法
a<-unique(url)

AllPostUrl<-c()
AllPoster<-c()
AllDate<-c()
AllTime<-c()
AllPost<-c()
AllTag<-c()
AllTagpeople<-c()
tags<-c()
tags2<-c()

for(i in 1:length(postUrl)){
  remDr$navigate(postUrl[i])
  Sys.sleep(1)
  post_source<-remDr$getPageSource()
  postContent<-read_html(post_source[[1]],encoding = "UTF-8")
  #tag
  # 使用html_text()函數處理/清洗擷取內容，留下需要的資料
  people<-postContent%>%html_nodes(".JYWcJ") %>% html_text()
  if(length(people)==0){
    next
  }else{
    #發文ID
    AllPostUrl<-c(AllPostUrl,postUrl[i])
    #發文者
    AllPoster<-c(AllPoster,postContent%>% html_nodes(".nJAzx") %>% html_text())
    #發文日期
    Date<-postContent %>% html_nodes("._1o9PC.Nzb55")%>%html_attr("title")
    #as.character轉換為文字 
    AllDate<-c(AllDate,as.character(as.POSIXct(Date, format="%Y年%m月%d日")))
    #發文時間
    Time<-postContent%>%html_nodes("._1o9PC.Nzb55")%>%html_attr("datetime")
    #strsplit切割 strsplit(要切的東西,用什麼切)
    AllTime<-c(AllTime,strsplit(strsplit(Time,".000")[[1]][1],"T")[[1]][2])
    #發文內容
    post<-postContent%>% html_nodes(".X7jCj ._6lAjh+ span") %>% html_text()
    AllPost<-c(AllPost,post[1])
    #tag
    if(length(people)==1){
      AllTag<-c(AllTag,1)
      AllTagpeople<-c(AllTagpeople,people)
      tags<-c(tags,people)
    }else{
      AllTag<-c(AllTag,2)
      AllTagpeople<-c(AllTagpeople,"n")
      tags<-c(tags,people)
    }
  }
}
#stringsAsFactors = F將文字的內容以文字儲存，而非因素向量
DATA<-data.frame(PostUrl=AllPostUrl,Poster=AllPoster,Date=AllDate,
                  Time=AllTime,Post=AllPost,Tag=AllTag,Tagpeople=AllTagpeople,
                  stringsAsFactors = F)

tags<-unique(tags)

#第二層
AllPostUrl<-c()
AllPoster<-c()
AllDate<-c()
AllTime<-c()
AllPost<-c()
AllTag<-c()
AllTagpeople<-c()
tags2<-c()
postUrl<-c()

for(k in 1:length(tags)){
  remDr$navigate(paste0("https://www.instagram.com/",tags[k],"/?hl=zh-tw"))
  for(i in 1:5){      
    remDr$executeScript(paste("scroll(0,",i*10000,");"))
    Sys.sleep(5)
    page1_source<-remDr$getPageSource()
    page1Content<-read_html(page1_source[[1]],encoding = "UTF-8") 
    href<- page1Content %>% html_nodes("a") %>% html_attr('href')
    posthref<-href[grepl('/p/',href)] 
    url<-paste0("https://www.instagram.com",posthref)
    for (j in 1:length(url)){
      if(url[j]%in%postUrl){
        next
      }else{
        postUrl<-c(postUrl,url[j])
      }
    }
  }
}
for(i in 1:length(postUrl)){
  remDr$navigate(postUrl[i])
  Sys.sleep(1)
  post_source<-remDr$getPageSource()
  postContent<-read_html(post_source[[1]],encoding = "UTF-8")
  #tag
  people<-postContent%>%html_nodes(".JYWcJ") %>% html_text()
  if(length(people)==0){
    next
  }else{
    #發文ID
    AllPostUrl<-c(AllPostUrl,postUrl[i])
    #發文者
    AllPoster<-c(AllPoster,postContent%>% html_nodes(".nJAzx") %>% html_text())
    #發文日期
    Date<-postContent %>% html_nodes("._1o9PC.Nzb55")%>%html_attr("title")
    AllDate<-c(AllDate,as.character(as.POSIXct(Date, format="%Y年%m月%d日")))
    #發文時間
    Time<-postContent%>%html_nodes("._1o9PC.Nzb55")%>%html_attr("datetime")
    AllTime<-c(AllTime,strsplit(strsplit(Time,".000")[[1]][1],"T")[[1]][2])
    #發文內容
    post<-postContent%>% html_nodes(".X7jCj ._6lAjh+ span") %>% html_text()
    AllPost<-c(AllPost,post[1])
    #tag
    if(length(people)==1){
      AllTag<-c(AllTag,1)
      AllTagpeople<-c(AllTagpeople,people)
      tags2<-c(tags2,people)
    }else{
      AllTag<-c(AllTag,2)
      AllTagpeople<-c(AllTagpeople,"n")
      tags2<-c(tags2,people)
    }
  }
}

DATA2<-data.frame(PostUrl=AllPostUrl,Poster=AllPoster,Date=AllDate,
                 Time=AllTime,Post=AllPost,Tag=AllTag,Tagpeople=AllTagpeople,
                 stringsAsFactors = F)

tags2<-unique(tags2)
NewTag<-c()
for(i in 1:length(tags2)){
  if(tags2[i]%in%tags){
    next
  }else{
    NewTag<-c(NewTag,tags2[i])
  }
    
}

ALLDATA<-rbind(DATA,DATA2)

NewTag<-unique(NewTag)
                 
#丟到mongoDB
library(mongolite)
#用戶名
username <- "admin"
#密碼
password <- "admin"
#主機名稱(Hostname)
host <- "52.54.130.90"
#port
port <- "27017"
#URL設定
URL <- paste0("mongodb://",username,":",password,"@",host,":",port)


DB<-mongo(db="FinalProject",collection="20191218",url = URL)
DB$insert(ALLDATA)
