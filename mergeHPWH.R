# mergeHPWH.R
# HPWH case
# source code to merger DT_HPWH0[1-5] into one table.
# call as code, not function.

# add hour of year to all the data.tables to avoid time change problems when mergeing
l_DT_HPWH <- ls(pattern = "^DT_HPWH*")
lapply(l_DT_HPWH,addHoY)


# HPWH case, electricity use
names(DT_HPWH01)
str(DT_HPWH01)
DT_HPWH01[, list(Dhw=sum(Dhw), DhwBu=sum(DhwBU), Subhr=unique(Subhr))]

# HPWH case, natural gas use
names(DT_HPWH02)
str(DT_HPWH02)
DT_HPWH02[, list(Dhw=sum(Dhw), DhwBu=sum(DhwBU), Subhr=unique(Subhr))]

# HPWH case, hot water end use
names(DT_HPWH03)
str(DT_HPWH03)
DT_HPWH03[, list( Total   = summary(Total),
                Unknown = summary(Unknown),
                Faucet  = summary(Faucet),
                Shower  = summary(Shower),
                Bath    = summary(Bath),
                CWashr  = summary(CWashr),
                DWashr  = summary(DWashr)
)]

# HPWH case, hot water drawn at water heater?
names(DT_HPWH04)
str(DT_HPWH04)
DT_HPWH04[, list( Total   = summary(Total),
                Unknown = summary(Unknown),
                Faucet  = summary(Faucet),
                Shower  = summary(Shower),
                Bath    = summary(Bath),
                CWashr  = summary(CWashr),
                DWashr  = summary(DWashr)
)]

# HPWH case,  days, temps & people
names(DT_HPWH05)
str(DT_HPWH05)

# rename 2nd 'Day' to Day2
setnames(DT_HPWH05, 6,"Day2")

# get number of people
DT_HPWH05[, nPeople:=substr(Day2,1,1)]

# get string DOWH as an ordered factor 
DT_HPWH05[, sDOWH:= factor(substr(Day2,2,2), levels=c("U","M","T","W","R","F","S","H"), ordered = TRUE)]

setnames(DT_HPWH05, 1, "Mon") # change Mo to Mon for consistency w/ other tables

str(DT_HPWH05)


# Now merge all the HPWH case data.
DT_HPWH <- merge(DT_HPWH01[, list(HoY, Mon, Day, Hr, HPWH.ElecTot=Tot, HPWH.ElecDhw=Dhw, HPWH.ElecDhwBU=DhwBU)], # HPWH case, electricity use
               DT_HPWH02[, list(HoY, Mon, Day, Hr, HPWH.NatGasTot=Tot, HPWH.NatGasDhwBU=DhwBU)], # HPWH case, natural gas use
               by = c("HoY", "Mon", "Day", "Hr") )
DT_HPWH <- merge(DT_HPWH, 
               DT_HPWH03[, list(HoY, Mon, Day, Hr,              # HPWH case, hot water end use
                              HPWH.FXMix.Total   = Total, 
                              HPWH.FXMix.Faucet  = Faucet,
                              HPWH.FXMix.Shower  = Shower,
                              HPWH.FXMix.Bath    = Bath,
                              HPWH.FXMix.CWashr  = CWashr,
                              HPWH.FXMix.DWashr  = DWashr)],
               by = c("HoY", "Mon", "Day", "Hr") )
DT_HPWH <- merge(DT_HPWH, 
               DT_HPWH04[, list(HoY, Mon, Day, Hr,       # HPWH case, hot water drawn at water heater?
                              HPWH.WH.Total   = Total, 
                              HPWH.WH.Faucet  = Faucet,
                              HPWH.WH.Shower  = Shower,
                              HPWH.WH.Bath    = Bath,
                              HPWH.WH.CWashr  = CWashr,
                              HPWH.WH.DWashr  = DWashr)],
               by = c("HoY", "Mon", "Day", "Hr") )
DT_HPWH <- merge(DT_HPWH, 
               DT_HPWH05[, list(HoY, Mon, Day, Hr,        # HPWH case,  days, temps & people
                              JDay          = JDay,
                              DOWH          = DOWH,
                              sDOWH         = sDOWH,
                              nPeople       = nPeople,
                              tDbO          = tDbO,
                              Tinlet        = Tinlet,
                              HPWH.garT       = garT)],
               by = c("HoY", "Mon", "Day", "Hr") )
str(DT_HPWH)

