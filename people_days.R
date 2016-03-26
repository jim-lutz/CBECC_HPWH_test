fn_script = "people_days.R"
# load hourly data.tables from CSE outputs and review ndays by npeople

# Jim Lutz "Fri Mar 25 17:05:53 2016"

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions (probably don't need this.)
# source("functions.R")

# load the data.tables for checking
load(file=paste0(wd_data,"DT.Rdata"))

tables()
#      NAME       NROW NCOL MB COLS                                                                             KEY
# [1,] DT_ER01   8,760   28  2 Meter,Mon,Day,Hr,Subhr,Tot,Clg,Htg,HPHtg,Dhw,DhwBU,FanC,FanH,FanV,Fan,Aux,Proc,L    
# [2,] DT_ER02   8,760   28  2 Meter,Mon,Day,Hr,Subhr,Tot,Clg,Htg,HPHtg,Dhw,DhwBU,FanC,FanH,FanV,Fan,Aux,Proc,L    
# [3,] DT_ER03   8,760   12  1 Meter,Mon,Day,Hr,Subhr,Total,Unknown,Faucet,Shower,Bath,CWashr,DWashr               
# [4,] DT_ER04   8,760   12  1 Meter,Mon,Day,Hr,Subhr,Total,Unknown,Faucet,Shower,Bath,CWashr,DWashr               
# [5,] DT_ER05   8,760    9  1 Mo,Day,Hr,JDay,DOWH,Day,tDbO,Tinlet,garT                                            
# [6,] DT_HPWH01 8,760   28  2 Meter,Mon,Day,Hr,Subhr,Tot,Clg,Htg,HPHtg,Dhw,DhwBU,FanC,FanH,FanV,Fan,Aux,Proc,L    
# [7,] DT_HPWH02 8,760   28  2 Meter,Mon,Day,Hr,Subhr,Tot,Clg,Htg,HPHtg,Dhw,DhwBU,FanC,FanH,FanV,Fan,Aux,Proc,L    
# [8,] DT_HPWH03 8,760   12  1 Meter,Mon,Day,Hr,Subhr,Total,Unknown,Faucet,Shower,Bath,CWashr,DWashr               
# [9,] DT_HPWH04 8,760   12  1 Meter,Mon,Day,Hr,Subhr,Total,Unknown,Faucet,Shower,Bath,CWashr,DWashr               
# [10,] DT_HPWH05 8,760    9  1 Mo,Day,Hr,JDay,DOWH,Day,tDbO,Tinlet,garT                                            
# Total: 14MB

# look at number of days by Npeople
names(DT_ER05)
DT_ER05[]

# make sure HPWH and ER days are the same
names(DT_ER05) == names(DT_HPWH05)

for (i in seq_along(names(DT_ER05))) {
  print(all.equal(DT_ER05$i, DT_HPWH05$i))
  }
# [1] TRUE
# [1] TRUE
# [1] TRUE
# [1] TRUE
# [1] TRUE
# [1] TRUE
# [1] TRUE
# [1] TRUE
# [1] TRUE

# rename 2nd 'Day' in to Day2
setnames(DT_ER05, 6,"Day2")

# looke at Day2
DT_ER05[, list(.N/24), by=Day2][order(Day2)]
# fractional days?

# watch out for time changes
DT_ER05[,.N,by=JDay][order(N)]
#      JDay  N
# 1:     67 23
# 365:  305 25

# look at order of Day & Day2
DT_ER05[, list(DOWH = unique(DOWH),
                   Day2 = unique(Day2)), by = JDay ][1:14,]
#     JDay DOWH Day2
#  1:    1    8   5H
#  2:    2    6   3F
#  3:    3    7   2S
#  4:    4    1   3U
#  5:    5    2   3M
#  6:    6    3   4T
#  7:    7    4   5W
#  8:    8    5   5R
#  9:    9    6   3F
# 10:   10    7   2S
# 11:   11    1   4U
# 12:   12    2   6M
# 13:   13    3   6T
# 14:   14    4   3W
# week starts on Sunday

# split Day2
DT_ER05[, nPeople:=substr(Day2,1,1)]
DT_ER05[, DOWH   :=substr(Day2,2,2)]

# make a daily data.table 
DT_daily_ER05 <- DT_ER05[,list(Mo      = unique(Mo), 
                               Day     = unique(Day),
                               DOWH    = unique(DOWH),
                               nPeople = unique(nPeople), 
                               tDbO    = mean(tDbO),
                               Tinlet  = mean(Tinlet),
                               Tgar    = mean(garT)
                               ), by = JDay]

str(DT_daily_ER05)

# change DOWH into an ordered factor 
DT_daily_ER05[, DOWH:= factor(DOWH, levels=c("U","M","T","W","R","F","S","H"), ordered = TRUE)]

# make a table of the days by number of people
people_days <- addmargins(with(DT_daily_ER05, table(DOWH,nPeople)))
#     nPeople
# DOWH   1   2   3   4   5   6 Sum
#  U     3  15  10  12   9   3  52
#  M     4   9   9  15   2   9  48
#  T     5  13   9  13   6   5  51
#  W     5  13   7  15   8   3  51
#  R     3  16   6  16   9   1  51
#  F     1  18  12   8   8   2  49
#  S     5  15   7  16   4   5  52
#  H     1   1   4   2   2   1  11
#  Sum  27 100  64  97  48  29 365

# save to csv file
write.csv(people_days, file = paste0(wd_data,"people_days.csv"),row.names = TRUE)


