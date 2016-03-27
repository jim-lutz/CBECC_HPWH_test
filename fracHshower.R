fn_script = "fracHshower.R"
# plot of shower fraction hot by day of year

# Jim Lutz "Sat Mar 26 19:14:21 2016"

# make sure all packages loaded and start logging
source("setup.R")

# set the working directory names 
source("setup_wd.R")

# load useful functions (probably don't need this.)
source("functions.R")

# load the data.tables for checking
load(file=paste0(wd_data,"DT.Rdata"))

tables()

# keep just the DT_HPWH data.table
l_tables <- tables()$NAME
rm(list = l_tables[l_tables != "DT_HPWH"])

# calculate fraction hot for showers by day
DT_Showers <- DT_HPWH[, list(frac.H.Shower = sum(HPWH.WH.Shower)/sum(HPWH.FXMix.Shower),
                             Tinlet        = mean(Tinlet),
                             Mon           = unique(Mon) )
                      , by = JDay]
DT_Showers[,Mon:=factor(Mon, labels=month.abb, ordered = TRUE)]

# find JDay of month start
DT_Mon_labels <- DT_Showers[, list(minJDay = min(JDay)),by = Mon]

# create a list of labels for every day of the year, all blank except first day of month
Months <- rep.int("", times = 365)
for (i in (1:12)) {
  Months[DT_Mon_labels[i]$minJDay] <- as.character(DT_Mon_labels[i]$Mon)
}

# plot of fraction hot & Tinlet through year
p <- ggplot(data = DT_Showers )

# plot of Tinlet
p1 <- p + geom_point(aes(x=JDay, y=Tinlet), color="blue")
p1 <- p1 + theme(axis.ticks.x = element_blank(),axis.text.x = element_blank())
p1 <- p1 + labs(x="", y=expression(paste("Tinlet ( ", degree ~ F, " )")) )
p1 <- p1 + ggtitle("Showers")

p1

# plot of frac.H.Shower
p2 <- p + geom_point(aes(x=JDay, y=frac.H.Shower),color="red")
p2 <- p2 + labs(x="date", y="Fraction Hot" )
p2 <- p2 + scale_x_continuous(breaks=DT_Mon_labels$minJDay,
                              labels=DT_Mon_labels$Mon)

p2

# show the plots
multiplot(p1, p2, cols=1)
# save to png file
png(file=paste0(wd_charts,"/showers.png"),width = 2833, height = 1408, res = 250)
multiplot(p1, p2, cols=1)
dev.off()


# # work with gridExtra
# if(!require(gridExtra)){install.packages("gridExtra")}
# library(gridExtra)
# logwarn('gridExtra loaded')
# 

