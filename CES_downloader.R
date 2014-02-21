##################################
#
# Download Establishment Survey Data
#
#################################

setwd("//BRSFS1/CasselmB$/My Documents/R/CES")
library(reshape2)
#Download file
temp<-tempfile()
download.file("http://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries",temp)
CES <- read.delim(temp,header=TRUE,sep="\t",strip.white=TRUE)
unlink(temp)
CES$date <-as.Date(paste(CES$year,CES$period,"01",sep="-"),"%Y-M%m-%d")
#Eliminate annual data (M13)
CES<-subset(CES,period!="M13",select=c(series_id,date,value))

#export takeaways data to csv
takeaways<-subset(CES,(series_id=="CES0000000001" | series_id=="CES0500000001" | series_id=="CES9000000001"|
	series_id=="CES9091000001"|series_id=="CES9092000001"|series_id=="CES9093000001"|series_id=="CES2000000001"|
	series_id=="CES3000000001"|series_id=="CES4142000001"|series_id=="CES4200000001"|series_id=="CES4300000001"|
	series_id=="CES5000000001"|series_id=="CES5500000001"|series_id=="CES6000000001"|series_id=="CES6500000001"|
	series_id=="CES7000000001"|series_id=="CES7072200001"|series_id=="CES6056132001"|series_id=="CES0500000003"|
	series_id=="CES0500000002"|series_id=="CES0500000008") & 
	date>="2000-01-01")
takeaways<-dcast(takeaways,date ~ series_id)
write.csv(takeaways,"CEStakes.csv")

#add series breakdowns
temp<-tempfile()
download.file("http://download.bls.gov/pub/time.series/ce/ce.series",temp)
series<- read.delim(temp,header=TRUE,sep="\t",strip.white=TRUE)
unlink(temp)

# merge in series
CES<-merge(CES,series,by="series_id")

#save CES
save(CES,file="CES.RData")

#select just hours, jobs & earnings of production/nonsupervisory employees
hours<-subset(CES,data_type_code==7 & seasonal=="S" & date>="1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
jobs<-subset(CES,data_type_code==6 & seasonal=="S" & date>="1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
pay<-subset(CES,data_type_code==8&seasonal=="S" & date>"1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
week<-subset(CES,data_type_code==30 &seasonal=="S" & date>"1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))

#save this for later use as ProdSup.RData
save(hours,jobs,pay,week, file="ProdSup.RData")

#select just hours, jobs & earnings of all employees
hours<-subset(CES,data_type_code==2 & seasonal=="S" & date>="1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
jobs<-subset(CES,data_type_code==1 & seasonal=="S" & date>="1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
pay<-subset(CES,data_type_code==3 & seasonal=="S" & date>"1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
week<-subset(CES,data_type_code==11 &seasonal=="S" & date>"1990-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))

#save this for later use as AllEmp.RData
save(hours,jobs,pay,week, file="AllEmp.RData")

#now for since 1980
load("CES.RData")
hours<-subset(CES,data_type_code==7 & seasonal=="S" & date>="1980-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
jobs<-subset(CES,data_type_code==6 & seasonal=="S" & date>="1980-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
pay<-subset(CES,data_type_code==8&seasonal=="S" & date>"1980-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))
week<-subset(CES,data_type_code==30 &seasonal=="S" & date>"1980-01-01",select=c(series_id,date,data_type_code,supersector_code,industry_code,seasonal,value))

#save this for later use as ProdSup.RData
save(hours,jobs,pay,week, file="ProdSup1980.RData")
