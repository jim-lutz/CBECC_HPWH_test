fn_script = "readCSEoutput.R"
# read hourly data from CSE output files
# save as data.tables to DR.Rdata

# Jim Lutz "Fri Mar 25 15:29:10 2016"
# "Sat Mar 26 13:33:13 2016"    merge all the datasets into one big data.table

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions (probably don't need this.)
# source("functions.R")

# run these bash commands in linux to split the csv files on '"",002'
# csplit -f HPWH -b "%02d.csv" '2SE_HPWHtest2 - Prop.csv' '/"",002/' '{*}'
# csplit -f ER -b "%02d.csv" '2SE_ERtest2 - Prop.csv' '/"",002/' '{*}'

# get list of the desired *.csv data files, with full path name
l_fn_csv <- list.files( path=wd_data, pattern = "*0[1-5].csv", full.names = TRUE)

# drop //
str_replace(l_fn_csv, "//", "/")

# make a list of just the prefix of the file names
l_fn <- str_match(l_fn_csv, "([A-Z]+0[1-5])")[,1]

# import from the list
for (i in seq_along(l_fn_csv)) {
 assign(paste0("DT_",l_fn[i]), fread(l_fn_csv[i]))
}

tables()
#     NAME       NROW NCOL MB COLS                                                                             KEY
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

# Electric resistance case, electricity use
names(DT_ER01)
str(DT_ER01)
DT_ER01[, list(Dhw=sum(Dhw), DhwBu=sum(DhwBU), Subhr=unique(Subhr))]
DT_ER01[, HoY:=seq_len(8760)] # add hour of year to avoid time change problems when mergeing

# Electric resistance case, natural gas use
names(DT_ER02)
str(DT_ER02)
DT_ER02[, list(Dhw=sum(Dhw), DhwBu=sum(DhwBU), Subhr=unique(Subhr))]
DT_ER02[, HoY:=seq_len(8760)] # add hour of year to avoid time change problems when mergeing

# Electric resistance case, hot water end use
names(DT_ER03)
str(DT_ER03)
DT_ER03[, list( Total   = summary(Total),
                Unknown = summary(Unknown),
                Faucet  = summary(Faucet),
                Shower  = summary(Shower),
                Bath    = summary(Bath),
                CWashr  = summary(CWashr),
                DWashr  = summary(DWashr)
                )]
DT_ER03[, HoY:=seq_len(8760)] # add hour of year to avoid time change problems when mergeing

# Electric resistance case, hot water drawn at water heater?
names(DT_ER04)
str(DT_ER04)
DT_ER04[, list( Total   = summary(Total),
                Unknown = summary(Unknown),
                Faucet  = summary(Faucet),
                Shower  = summary(Shower),
                Bath    = summary(Bath),
                CWashr  = summary(CWashr),
                DWashr  = summary(DWashr)
                )]
DT_ER04[, HoY:=seq_len(8760)] # add hour of year to avoid time change problems when mergeing

# check if DT_ER05 (days, temps & people) is the same as DT_HWPH05
for (i in seq_along(names(DT_ER05))) {
  print(colnames(DT_ER05)[i])
  print(all.equal(DT_ER05[[i]],DT_HPWH05[[i]]))
}
# only garT not the same.
names(DT_ER05)
str(DT_ER05)

# rename 2nd 'Day' to Day2
setnames(DT_ER05, 6,"Day2")

# get number of people
DT_ER05[, nPeople:=substr(Day2,1,1)]

# get string DOWH as an ordered factor 
DT_ER05[, sDOWH:= factor(substr(Day2,2,2), levels=c("U","M","T","W","R","F","S","H"), ordered = TRUE)]

setnames(DT_ER05, 1, "Mon") # change Mo to Mon for consistency w/ other tables

str(DT_ER05)
DT_ER05[, HoY:=seq_len(8760)] # add hour of year to avoid time change problems when mergeing


# Merge all the electric resistance case data.
DT_ER <- merge(DT_ER01[, list(HoY, Mon, Day, Hr, ER.ElecTot=Tot, ER.ElecDhwBU=DhwBU)], # Electric resistance case, electricity use
               DT_ER02[, list(HoY, Mon, Day, Hr, ER.NatGasTot=Tot, ER.NatGasDhwBU=DhwBU)], # Electric resistance case, natural gas use
               by = c("HoY", "Mon", "Day", "Hr") )
DT_ER <- merge(DT_ER, 
               DT_ER03[, list(HoY, Mon, Day, Hr,              # Electric resistance case, hot water end use
                              ER.FXMix.Total   = Total, 
                              ER.FXMix.Faucet  = Faucet,
                              ER.FXMix.Shower  = Shower,
                              ER.FXMix.Bath    = Bath,
                              ER.FXMix.CWashr  = CWashr,
                              ER.FXMix.DWashr  = DWashr)],
               by = c("HoY", "Mon", "Day", "Hr") )
DT_ER <- merge(DT_ER, 
               DT_ER04[, list(HoY, Mon, Day, Hr,       # Electric resistance case, hot water drawn at water heater?
                       ER.WH.Total   = Total, 
                       ER.WH.Faucet  = Faucet,
                       ER.WH.Shower  = Shower,
                       ER.WH.Bath    = Bath,
                       ER.WH.CWashr  = CWashr,
                       ER.WH.DWashr  = DWashr)],
               by = c("HoY", "Mon", "Day", "Hr") )
DT_ER <- merge(DT_ER, 
               DT_ER05[, list(HoY, Mon, Day, Hr,              # days, temps & people
                               JDay          = JDay,
                               DOWH          = DOWH,
                               sDOWH         = sDOWH,
                               nPeople       = nPeople,
                               tDbO          = tDbO,
                               Tinlet        = Tinlet,
                               ER.garT       = garT)],
               by = c("HoY", "Mon", "Day", "Hr") )
str(DT_ER)
str(DT_ER05)

               
               
               





# save all the data.tables for later work
save(list=tables()$NAME, file=paste0(wd_data,"DT.Rdata"))
