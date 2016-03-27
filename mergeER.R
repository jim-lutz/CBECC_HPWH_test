# mergeER.R"
# Electric resistance case
# source code to merger DT_ER0[1-5] into one table.
# call as code, not function.

# add hour of year to all the data.tables to avoid time change problems when mergeing
l_DT_ER <- ls(pattern = "^DT_ER*")
lapply(l_DT_ER,addHoY)

# now look at the data.tables
# Electric resistance case, electricity use
names(DT_ER01)
str(DT_ER01)
DT_ER01[, list(Dhw=sum(Dhw), DhwBu=sum(DhwBU), Subhr=unique(Subhr))]

# Electric resistance case, natural gas use
names(DT_ER02)
str(DT_ER02)
DT_ER02[, list(Dhw=sum(Dhw), DhwBu=sum(DhwBU), Subhr=unique(Subhr))]

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

# # check if DT_ER05 (days, temps & people) is the same as DT_HWPH05
# for (i in seq_along(names(DT_ER05))) {
#   print(colnames(DT_ER05)[i])
#   print(all.equal(DT_ER05[[i]],DT_HPWH05[[i]]))
# }
# only garT not the same.

# Electric resistance case,  days, temps & people
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


# Now merge all the electric resistance case data.
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

