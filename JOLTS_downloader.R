############################
#
#JOLTS loader
#Loads data from BLS Job Openings and Labor Turnover Survey (JOLTS)
#and coverts to time series
#
#############################

#Set working directory here
setwd()
#Download file and pull into data frame
library(reshape2)
temp<-tempfile()
download.file("http://download.bls.gov/pub/time.series/jt/jt.data.1.AllItems",temp)
JOLTS <- read.table(temp,header=TRUE,sep="\t",stringsAsFactors=FALSE,strip.white=TRUE)
unlink(temp)

#Split into monthly and annual data
JOLTSm <- subset(JOLTS,!(period=="M13"))
JOLTSm$date<-as.Date(paste(JOLTSm$year,JOLTSm$period,"01",sep="-"),format="%Y-M%m-%d")
JOLTSy <- subset(JOLTS,period=="M13")

#Create time series for each
JOLTSm.time <- dcast(JOLTSm,date ~ series_id)
JOLTSy.time <- dcast(JOLTSy,year ~ series_id)

#save in JOLTS
save(JOLTSm.time,JOLTSy.time,file="JOLTS.RData")