#########################################################
#
#CPS loader (all LN series)
#
#
#First load CPS from BLS as CPS_Main. Footnotes are stripped
#
#
#Set working directory
setwd()
library(reshape2)

#Load file from BLS servers
temp<-tempfile()
download.file("http://download.bls.gov/pub/time.series/ln/ln.data.1.AllData",
	temp)
CPS_Main<-read.table(temp,
	header=FALSE,
	sep="\t",
	skip=1,
	stringsAsFactors=FALSE,
	strip.white=TRUE)
colnames(CPS_Main)<-c("series_id","year","period","value")
unlink(temp)

#
#Download series descriptions
#

temp<-tempfile()
download.file("http://download.bls.gov/pub/time.series/ln/ln.series",temp)
CPS_heads<-read.table(temp,sep="\t",
	header=FALSE,skip=2,
	stringsAsFactors=FALSE,
	strip.white=TRUE)
unlink(temp)
#Column names don't import properly.
#Either set up in CSV or add manually like so
colnames(CPS_heads)<-c("series_id", "lfst_code","periodicity_code","series_description","absn_code","activity_code","ages_code","class_code","duration_code","education_code","entr_code","expr_code","hheader_code","hour_code","indy_code","jdes_code","look_code","mari_code","mjhs_code","occupation_code","orig_code","pcts_code","race_code","rjnw_code","rnlf_code","rwns_code","seek_code","sexs_code","tdat_code","vets_code","wkst_code","born_code","chld_code","disa_code","seasonal","footnote_codes","begin_year","begin_period","end_year","end_period")
#save this for future use
save(CPS_heads,file="CPS_heads.RData")

#Merge series descriptions into main CPS files
CPS_Main <- merge(CPS_Main,CPS_heads,by=series_id)

#Select only monthly data as CPSm
CPSm <-subset(CPS_Main,grepl("M",CPS_Main$period))
CPSm<-subset(CPSm,!(period=="M13")) #remove annual data
CPSm$date <-as.Date(paste(CPSm$year,PSm$period,"01",sep="-"),
	format="%Y-M%m-%d")

#Do same for annual data as CPSy
CPSy <-subset(CPS_Main,grepl("M13",CPS_Main$period))
CPSy$period<-as.character(CPSy$period)

#And now quarterly as CPSq
CPSq<-subset(CPS_Main,grepl("Q",CPS_Main$period))
CPSq$period<-as.character(CPSq$period)
CPSq$quarter<-paste(CPSq$year,CPSq$period,sep="-")
quarters<-data.frame(quarters=c("Q01","Q02","Q03","Q04"),
	months=c("01-01","04-01","07-01","10-01"))
CPSq<-merge(CPSq,quarters,by.x="period",by.y="quarters")
CPSq$date<-as.Date(paste(CPSq$year,CPSq$months,sep="-"),
	format="%Y-%m-%d")

unlink(CPS_Main)

############################
#
#Can stop here and save--you now have the files, just not yet in a time series
#Or block out this line and go on
save(CPSm,CPSy,CPSq,file="CPS.RData")

#####
#Convert to time series
#Note that this loses series descriptions--can add them back in later
#for specific series
#
#First we'll pull monthly data
#This cuts off everything pre-2000.
#Can change date, but it'll take a long time
m <- subset(CPSm,year>=2000,select=c("series_id","date","value"))
m$value<-as.numeric(as.character(m$value))
m$series_id<-as.character(m$series_id)
m1 <- dcast(m,series_id ~ date,sum)

#For quarters, default is to start at 1970
q <- subset(CPSq,year>=1970,select=c("series_id","date","value"))
q$value<-as.numeric(as.character(q$value))
q$series_id<-as.character(q$haed(series_id)
q1 <- dcast(q,series_id ~ date,sum)

#For years, this is full time series
y <- subset(CPSy,select=c("series_id","year","value"))
y$value<-as.numeric(as.character(y$value))
y$series_id<-as.character(y$series_id)
y1 <- dcast(y,series_id ~ year,sum)

#####################
#
#Can save these as time series
#
write.csv(m1,"LNmonthly.csv")
write.csv(q1, "LNquarterly.csv")
write.csv(y1, "LNannual.csv")


