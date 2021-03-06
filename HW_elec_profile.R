fn_script = "HW_elec_profile.R"
# plot of hot water and electricity use by hour of day for entire year

# Jim Lutz "Sun Mar 27 17:26:42 2016"
# "Sun Mar 27 21:08:01 2016"    elec use in standby suspiciously identical

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions 
source("functions.R")

# load the data.tables for checking
load(file=paste0(wd_data,"DT.Rdata"))

tables()

# check reading correct Dhw and DhwBu
names(DT_HPWH)
DT_HPWH[, list(HPWH.ElecDhw=sum(HPWH.ElecDhw), HPWH.ElecDhwBU=sum(HPWH.ElecDhwBU))]
names(DT_HPWH01)
DT_HPWH01[, list(Dhw=sum(Dhw), DhwBU=sum(DhwBU))]

names(DT_ER)
DT_ER[, list(ER.ElecDhw=sum(ER.ElecDhw), ER.ElecDhwBU=sum(ER.ElecDhwBU))]
names(DT_ER01)
DT_ER01[, list(Dhw=sum(Dhw), DhwBU=sum(DhwBU))]

# keep DT_HPWH & DT_ER data.tables
l_tables <- tables()$NAME
rm(list = l_tables[grepl("*0[1-5]", l_tables)])

# merge table of electricity use & hot water for HPWH and ER
DT_EHW <-merge(DT_ER[,list(HoY,JDay,Mon,Day,Hr,sDOWH,nPeople,WH.Total=ER.WH.Total,ER.ElecDhw,ER.ElecDhwBU)],
               DT_HPWH[,list(HoY,HPWH.ElecDhw, HPWH.ElecDhwBU)], 
               by = "HoY")

# assume ElecTot and ElecDhwBU are same units, and are separate
DT_EHW[ , ER.Elec:= ER.ElecDhw + ER.ElecDhwBU]
DT_EHW[ , HPWH.Elec:= HPWH.ElecDhw + HPWH.ElecDhwBU]

# rearrange data for boxplots of hourly _use
DT_EHW[ , list(HoY,Hr, GPH=WH.Total, ER=ER.Elec, HPWH=HPWH.Elec)]

# melt into long format
DT_mEHW <- melt(DT_EHW[ , list(HoY,Hr, GPH=WH.Total, ER=ER.Elec, HPWH=HPWH.Elec)], id.vars = c("HoY","Hr"))
DT_mEHW[, list(variable=unique(variable))]
#    variable
# 1:      GPH
# 2:       ER
# 3:     HPWH

# change names
setnames(DT_mEHW, c("value", "variable"), c("hourly.use", "type.use"))

# boxplots of hourly use by type of use and hour of day
p <- ggplot(data = DT_mEHW )
p <- p + geom_boxplot( aes(y = hourly.use, x = as.factor(Hr),
                           fill = factor(type.use), 
                           color = factor(type.use),
                           dodge = type.use),
                       position = position_dodge(width = .7),
                       varwidth = TRUE)
p <- p + scale_fill_manual(values=c("#DDDDFF", "#FFDDDD", "#DDFFDD"),name="use")
p <- p + scale_color_manual(values=c("#0000FF", "#FF0000", "#00FF00"),name="use")
p <- p + ggtitle("Hot Water and Electricity Use") + labs(x = "hour", y = "Hourly Use")
p <- p + scale_x_discrete(breaks=1:24,labels=1:24)
p

ggsave(filename = paste0(wd_charts,"/Use_by_hour.png"), plot = p)

# now plot one day, high and low
DT_EHW[, list(GPD=sum(WH.Total)), by = JDay][order(GPD)]

# heavy day, JDay==138
DT_EHW[JDay==138,]
DT_heavy <- DT_EHW[JDay==138,list(Hr,GPH=WH.Total,ER=ER.Elec,HPWH=HPWH.Elec)]
str(DT_heavy)
p <- ggplot(data = DT_heavy )
p <- p + geom_line(aes(x=Hr, y=GPH), color="blue", size=2)
p <- p + geom_line(aes(x=Hr,y=ER), color="red")
p <- p + geom_line(aes(x=Hr,y=HPWH), color="green")
p <- p + ggtitle("Hot Water and Electricity Use (Mon, 5/18, 6 people)") + labs(x = "hour", y = "Hourly Use")
p <- p + scale_x_continuous(breaks=1:24,labels=1:24)
p

ggsave(filename = paste0(wd_charts,"/HW_elec_heavy.png"), plot = p)

# light day, JDay==15
DT_EHW[JDay==15,]
DT_light <- DT_EHW[JDay==15,list(Hr,GPH=WH.Total,ER=ER.Elec,HPWH=HPWH.Elec)]
str(DT_light)
p <- ggplot(data = DT_light )
p <- p + geom_line(aes(x=Hr, y=GPH), color="blue", size=2)
p <- p + geom_line(aes(x=Hr,y=ER), color="red")
p <- p + geom_line(aes(x=Hr,y=HPWH), color="green")
p <- p + ggtitle("Hot Water and Electricity Use (Thurs, 1/15, 2 people)") + labs(x = "hour", y = "Hourly Use")
p <- p + scale_x_continuous(breaks=1:24,labels=1:24)
p

ggsave(filename = paste0(wd_charts,"/HW_elec_light.png"), plot = p)
