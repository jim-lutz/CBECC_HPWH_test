fn_script = "people_days.R"
# load hourly data.tables from CSE outputs and review ndays by npeople

# Jim Lutz "Fri Mar 25 17:05:53 2016"
# "Sat Mar 26 18:42:46 2016"    make sure this still works after reworking readCSEoutput.R

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions (probably don't need this.)
source("functions.R")

# load the data.tables for checking
load(file=paste0(wd_data,"DT.Rdata"))

str(tables())
# Classes ‘data.table’ and 'data.frame':	12 obs. of  6 variables:
#   $ NAME: chr  "DT_ER" "DT_ER01" "DT_ER02" "DT_ER03" ...
#   $ NROW: chr  "8,760" "8,760" "8,760" "8,760" ...
#   $ NCOL: chr  "  27" "  29" "  29" "  13" ...
#   $ MB  : chr  " 2" " 2" " 2" " 1" ...
#   $ COLS: chr  "HoY,Mon,Day,Hr,ER.ElecTot,ER.ElecDhwBU,ER.NatGasTot,ER.NatGasDhwBU,ER.FXMix.Total,ER.FXMix.Faucet,ER.FXMix.Shower,ER.FXMix.Bath"| __truncated__ "Meter,Mon,Day,Hr,Subhr,Tot,Clg,Htg,HPHtg,Dhw,DhwBU,FanC,FanH,FanV,Fan,Aux,Proc,Lit,Rcp,Ext,Refr,Dish,Dry,Wash,Cook,User1,User2,"| __truncated__ "Meter,Mon,Day,Hr,Subhr,Tot,Clg,Htg,HPHtg,Dhw,DhwBU,FanC,FanH,FanV,Fan,Aux,Proc,Lit,Rcp,Ext,Refr,Dish,Dry,Wash,Cook,User1,User2,"| __truncated__ "Meter,Mon,Day,Hr,Subhr,Total,Unknown,Faucet,Shower,Bath,CWashr,DWashr,HoY" ...
#   $ KEY : chr  "HoY,Mon,Day,Hr" "" "" "" ...
#   - attr(*, ".internal.selfref")=<externalptr> 
  
# look at number of days by Npeople
names(DT_ER05)
DT_ER05[]

# make sure HPWH and ER days are the same
names(DT_ER05) == names(DT_HPWH05)
# [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE

for (i in seq_along(names(DT_ER05))) {
  print(colnames(DT_ER05)[i])
  print(all.equal(DT_ER05[[i]],DT_HPWH05[[i]]))
}
# [1] "Mon"
# [1] TRUE
# [1] "Day"
# [1] TRUE
# [1] "Hr"
# [1] TRUE
# [1] "JDay"
# [1] TRUE
# [1] "DOWH"
# [1] TRUE
# [1] "Day2"
# [1] TRUE
# [1] "tDbO"
# [1] TRUE
# [1] "Tinlet"
# [1] TRUE
# [1] "garT"
# [1] "Mean relative difference: 0.02852274"
# [1] "HoY"
# [1] TRUE
# [1] "nPeople"
# [1] TRUE
# [1] "sDOWH"
# [1] TRUE

# make a daily data.table 
DT_daily_ER05 <- DT_ER05[,list(Mon     = unique(Mon), 
                               Day     = unique(Day),
                               sDOWH   = unique(sDOWH),
                               nPeople = unique(nPeople), 
                               tDbO    = mean(tDbO),
                               Tinlet  = mean(Tinlet),
                               Tgar    = mean(garT)
                               ), by = JDay]

str(DT_daily_ER05)

# make a table of the days by number of people
people_days <- addmargins(with(DT_daily_ER05, table(sDOWH,nPeople)))
#      nPeople
# sDOWH   1   2   3   4   5   6 Sum
#   U     3  15  10  12   9   3  52
#   M     4   9   9  15   2   9  48
#   T     5  13   9  13   6   5  51
#   W     5  13   7  15   8   3  51
#   R     3  16   6  16   9   1  51
#   F     1  18  12   8   8   2  49
#   S     5  15   7  16   4   5  52
#   H     1   1   4   2   2   1  11
#   Sum  27 100  64  97  48  29 365

# save to csv file
write.csv(people_days, file = paste0(wd_data,"people_days.csv"),row.names = TRUE)


