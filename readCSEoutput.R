fn_script = "readCSEoutput.R"
# read hourly data from CSE output files
# save as data.tables to DR.Rdata

# Jim Lutz "Fri Mar 25 15:29:10 2016"
# "Sat Mar 26 13:33:13 2016"    merge all the datasets into one big data.table
# "Sat Mar 26 18:02:53 2016"    functionalize some of the reading into two data.tables

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions 
source("functions.R")

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

# Merge DT_ER0[1-5] to make one data.table for the electric resistance WH case
source("mergeER.R") 
names(DT_ER)
str(DT_ER)

# Merge DT_HPWH0[1-5] to make one data.table for the HPWH case
source("mergeHPWH.R") 
names(DT_HPWH01)
str(DT_HPWH)

# save all the data.tables for later work
save(list=tables()$NAME, file=paste0(wd_data,"DT.Rdata"))
