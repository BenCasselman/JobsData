#######################################################
#
#CPS Working File
#
#This code takes specific, user-entered LN codes,
#pulls them into a time series and runs very basic
#analysis (year-over-year change, etc). Can either
#export to csv or pursue more advanced analysis.
#
#Requires CPS.RData and CPS_heads.RData
#As currently set up, works on monthly data (should work for
#quarterly too). Annual will require modest tweaks
#
#This uses for-loops. I plan to rewrite using 'apply'
#but haven't gotten around to it yet. It isn't
#all that slow.
#
#NOTES: 
#Auto-exports to csv. Memo out write.csv line if you don't want the export.
#
#DOUBLE CHECK YOUR LN CODES and make sure they match the names you give them.
#If using 12-month changes, remember to set start date one year ahead of first required datapoint.
#
Code<-NA
Name<-NA
library(reshape2)
library(zoo)
load("CPS.RData")
load("CPS_heads.RData")

###########################
########DATA ENTRY#########
###########################
#Enter LN codes here (as many as you'd like). But make sure they're right!!!
Code<-c("LNS12000000","LNS12500000","LNS12600000","LNS12032194")

#Give them names--these will be default data labels in charts
Name<-c("Total employed","Full-time","Part-time","Involuntary part-time")

#Set a start date--set earliest possible desirable date. Can subset later.
#Format yyyy-mm-dd
Date1<-"1990-01-01"

#Set a file name
FileName <- "Myfilename.csv"

#Get labels (both "Names" given earlier and "series_description" 
#from BLS as check
Labels<-data.frame(Code,Name)
descrip<-subset(CPS_heads,
	series_id %in% Code, 
	select=c("series_id","series_description")
	)
Labels<-merge(Labels,descrip,by.x="Code",by.y="series_id")
####CHECK TO MAKE SURE THESE MATCH
Labels

#############################################
#
#ANALYSIS
#Shouldn't need to edit anything from here
#
#Subset data as CPSw.
#This chooses just the codes we want
CPSw <- subset(CPSm,subset=(series_id %in% Code),
	select=c("series_id","date","value")
	)
CPSw$value<-as.numeric(as.character(CPSw$value))
CPSw$series_id<-as.character(CPSw$series_id)
CPSw <- merge(CPSw,Labels,by.x="series_id",by.y="Code")

#subset for start date
CPSt<-subset(CPSw,date>=Date1)
#Cast as time series as CPSt
#Can set either Name or series_id as column heads
CPSt<-dcast(CPSw, date ~ Name)

#####
#Create secondary tables for analysis
#CPSpcty: Year-over-year percent change
#CPSchgy: Year-over-year change in level
#CPSpctm: Month-to-month percent change
#CPSchgm: Month-to-month level change
x<-length(Code)

CPSpcty <-data.frame(date=CPSt$date)
CPSpctm <-data.frame(date=CPSt$date)
CPSchgy <-data.frame(date=CPSt$date[-(1:12)])
CPSchgm <-data.frame(date=CPSt$date[-(1)])
loop = seq(1:x)
i=NULL
for (i in loop){
CPSpcty[,c(i+1)]<-data.frame(Delt(CPSt[,c(i+1)],k=12)*100)
colnames(CPSpcty)[i+1]<-colnames(CPSt)[i+1]
CPSpctm[,c(i+1)]<-data.frame(Delt(CPSt[,c(i+1)],k=1)*100)
colnames(CPSpctm)[i+1]<-colnames(CPSt)[i+1]
CPSchgy[,c(i+1)]<-data.frame(diff(CPSt[,c(i+1)],lag=12))
colnames(CPSchgy)[i+1]<-colnames(CPSt)[i+1]
CPSchgm[,c(i+1)]<-data.frame(diff(CPSt[,c(i+1)]))
colnames(CPSchgm)[i+1]<-colnames(CPSt)[i+1]
}
#Merge all files for export
CPSout<-merge(CPSt,CPSchgm,"date")
CPSout<-merge(CPSout,CPSpctm,"date")
CPSout<-merge(CPSout,CPSchgy,"date")
CPSout<-merge(CPSout,CPSpcty,"date")
i=NULL
for (i in loop){
colnames(CPSout)[c(x+i-(x-1),2*x+i-(x-1),3*x+i-(x-1),4*x+i-(x-1),5*x+i-(x-1))]<-c(paste(colnames(CPSt)[i+1],"level",Labels$Code[i],sep=","),paste(colnames(CPSchgm)[i+1],"m/m chg",sep=","),paste(colnames(CPSpctm)[i+1],"m/m % chg",sep=","),paste(colnames(CPSchgy)[i+1],"y/y chg",sep=","),paste(colnames(CPSpcty)[i+1],"y/y % chg",sep=","))
}

write.csv(CPSout,file=FileName) #Export as file