fn_script = "GPD_nPeople.R"
# make boxplots of GPD (enduse & WH) by nPeople

# Jim Lutz "Sat Mar 26 19:14:21 2016"

# clean up leftovers before starting
# clear the console
cat("\014")
# clear all the variables
rm(list=ls(all=TRUE))
# clear the plots
dev.off(dev.list()["RStudioGD"])
# clear history
cat("", file = "nohistory")
loadhistory("nohistory")

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions (probably don't need this.)
source("functions.R")

# load the data.tables for checking
load(file=paste0(wd_data,"DT.Rdata"))

# check if water use is different HPWH vs electric resistance
names(DT_HPWH)
names(DT_ER)
all.equal(DT_ER$ER.FXMix.Total,DT_HPWH$HPWH.FXMix.Total)  # at end uses
# [1] TRUE
all.equal(DT_ER$ER.WH.Total,DT_HPWH$HPWH.WH.Total)        # at WH
# [1] TRUE

# GPD at end uses
DT_GPD <- DT_HPWH[ , list(GPD.FXMix = sum(HPWH.FXMix.Total),
                          GPD.WH    = sum(HPWH.WH.Total),
                          nPeople   = as.numeric(unique(nPeople))), 
                   by=JDay ]
str(DT_GPD)

# rearrange DT_GPD
DT_mGPD <- melt(DT_GPD, id.vars = c("JDay","nPeople"))
DT_mGPD[, list(variable=unique(variable))]

# add location for water use variable
DT_mGPD[variable=="GPD.FXMix", loc:=as.factor("enduse")]
DT_mGPD[variable=="GPD.WH",    loc:="WH"]

# clean up
DT_mGPD[ , variable:=NULL]
DT_mGPD[ , nPeople:=as.integer(nPeople)]
setnames(DT_mGPD, "value", "GPD")
str(DT_mGPD)

# boxplots of total GPD by nPeople
p <- ggplot(data = DT_mGPD )
p <- p + geom_boxplot( aes(y = GPD, x = as.factor(nPeople), fill = loc, dodge = loc),
                       position = position_dodge(width = .7),
                       varwidth = TRUE)
p <- p + ggtitle("Total Hot Water Use") + labs(x = "number of people")
p <- p +  scale_fill_discrete(name="HW use\nlocation")
p

# what are the low uses of nPeople == 6?
DT_mGPD[nPeople==6 & GPD<10]
DT_HPWH[JDay==232]
# August 20, 6 person house as only 2 faucet draws?

ggsave(filename = paste0(wd_charts,"/totalHWuse.png"), plot = p)

# same type of chart with facets by type of use
names(DT_HPWH)
DT_GPD_type <- DT_HPWH[ , list(FXMix.Total  = sum(HPWH.FXMix.Total),  
                               FXMix.Faucet = sum(HPWH.FXMix.Faucet),
                               FXMix.Shower = sum(HPWH.FXMix.Shower), 
                               FXMix.Bath   = sum(HPWH.FXMix.Bath),   
                               FXMix.CWashr = sum(HPWH.FXMix.CWashr), 
                               FXMix.DWashr = sum(HPWH.FXMix.DWashr), 
                               WH.Total     = sum(HPWH.WH.Total),    
                               WH.Faucet    = sum(HPWH.WH.Faucet),    
                               WH.Shower    = sum(HPWH.WH.Shower),    
                               WH.Bath      = sum(HPWH.WH.Bath),      
                               WH.CWashr    = sum(HPWH.WH.CWashr),    
                               WH.DWashr    = sum(HPWH.WH.DWashr), 
                               nPeople   = as.numeric(unique(nPeople))), 
                   by=JDay ]
str(DT_GPD_type)

# rearrange DT_GPD_type
DT_mGPD_type <- melt(DT_GPD_type, id.vars = c("JDay","nPeople"))
DT_mGPD_type[, list(variable=unique(variable))]

# add location for water use variable
DT_mGPD_type[str_detect(variable,"FXMix"), loc:=as.factor("enduse")]
DT_mGPD_type[str_detect(variable,"WH"),    loc:="WH"]

# add type 
DT_mGPD_type[, type:= str_extract(variable,"\\.[A-Za-z]*")]
DT_mGPD_type[, type:= str_sub(type,2,-1) ]
DT_mGPD_type[, list(type=unique(type))]
DT_mGPD_type[, type:= factor(type, levels=c("Total","Shower","Faucet","CWashr","DWashr","Bath"), ordered = TRUE)]

# clean up
DT_mGPD_type[ , variable:=NULL]
DT_mGPD_type[ , nPeople:=as.integer(nPeople)]
setnames(DT_mGPD_type, "value", "GPD")
str(DT_mGPD_type)

# boxplots of GPD by nPeople faceted by type
p <- ggplot(data = DT_mGPD_type )
p <- p + geom_boxplot( aes(y = GPD, x = as.factor(nPeople), fill = loc, dodge = loc),
                       position = position_dodge(width = .7),
                       varwidth = TRUE)
p <- p + ggtitle("Hot Water Uses") + labs(x = "number of people")
p <- p + scale_fill_discrete(name="HW use\nlocation")
p <- p + facet_wrap(~type, ncol=3, scales="free")
p

ggsave(filename = paste0(wd_charts,"/HWuses.png"), plot = p)

