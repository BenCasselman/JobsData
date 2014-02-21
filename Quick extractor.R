##################
#
# Quick CPS data extractor
# Exports data to CSV as time series
# Requires data loaded via CPS_loader
#
##################

Code<-NA
Name<-NA
library(reshape2)
library(ggplot2)
library(zoo)
library(quantmod)
setwd() #enter directory where CPS is saved
load("CPS.RData")
load("CPS_heads.RData")

###########################
########DATA ENTRY#########
###########################
#Enter LN codes here (as many as you'd like). But make sure they're right!!!
Code<-c("LNU05027036","LNU05027040","LNU05027038","LNU05027042")
#Give them names--these will be default data labels in charts
Name<-c("Want a job, 16-24","Don't want a job, 16-24","Want a job, 55+","Don't want a job, 55+")

#Set a start date--set earliest possible desirable date. Can subset later.
#Format yyyy-mm-dd
Date1<-"2005-01-01"
#Choose a file name
FileName<-"WantJobAges.csv"

###########################
#######ANALYSIS############
###########################
#Get labels (both "Names" given earlier and "series_description" from BLS as check
Labels<-data.frame(Code,Name)

#Subset data as working
#NOTE: If using quarterly or annual data, have to change CPSm to CPSy or CPSq
working <- subset(CPSm,subset=(series_id %in% Code),select=c("series_id","date","value"))
working$value<-as.numeric(as.character(working$value))
working$series_id<-as.character(working$series_id)
working <- merge(working,Labels,by.x="series_id",by.y="Code")

#Cast as time series as extract
extract<-dcast(working, date ~ Name)
#subset for start date
extract<-subset(extract,date>=Date1)

#Export as file
write.csv(extract,file=FileName) 

