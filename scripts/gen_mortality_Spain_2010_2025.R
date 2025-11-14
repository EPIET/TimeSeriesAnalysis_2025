# Rensar workspace
rm(list = ls())
gc()

heading <- "------------------------------------------------------------------------------------
 FILE:   gen_mortality_Spain_2010_2025.R
 STUDY:  TSA module 2025
 CONTACT: Tanja Charles
 AFFILIATION: SPM/Fellowship
 PROJECT: 

 STATISTICIAN: Sharon Kühlmann

 Input : 

 Created:      14-11-2025
 Updated: 

 What: Read raw file with number of deaths per week in Spain. 
        Estimación del número de defunciones semanales
        Downloaded from https://www.ine.es/jaxiT3/Datos.htm?t=35177#_tabs-tabla
 

 Input : 
 Output: HALO-1i_lab_2023.Rdata

 R version:    4.2.2

------------------------------------------------------------------------------------
\n"



#---------------------------------------------------------------------------------------------------
# LIBRARIES
#---------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# PATHS
#---------------------------------------------------------------------------------------------------

project.path <- "C:/Users/skuhlmannberenzon/OneDrive - ECDC/Documents/GitHub/TimeSeriesAnalysis_2025/"
data.path    <- paste(project.path, "/data", sep="")
output.path  <- paste(project.path, "/_temporal conversion files", sep="")

sink(file.path(output.path, "gen_mortality_Spain_2010_2025.out"))

cat(heading)


#-----------------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------
# READ DATA
#---------------------------------------------------------------------------------------------------

dat <- read.table(file.path(data.path, "mortality_Spain_weekly.csv"), sep=",")
colnames(dat) <- dat[1,]
dat <- dat[-1,]
dat <- dat[, -(1:3)]
dat$Total <- as.numeric(gsub(".", "", dat$Total, fixed=TRUE))

pop <- read.table(file.path(data.path, "total population Spain.csv"), sep=";")
colnames(pop) <- pop[1,]
pop <- pop[-1,]

#---------------------------------------------------------------------------------------------------
# EDIT
#---------------------------------------------------------------------------------------------------

##################### deaths dataframe (dat) #####################
# extract year and week from Periodo column
dat$year  <- as.numeric(apply(as.matrix(dat$Periodo), 1, function(x) strsplit(x, "S")[[1]][1]))

dat$week  <- apply(as.matrix(dat$Periodo), 1, function(x) strsplit(x, "SM")[[1]][2])

# remove leading 0
dat$week  <- as.numeric(apply(as.matrix(dat$week), 1, 
                function(x) ifelse(substr(x, 1, 1)=="0", substr(x, 2, 2), x)))

dat$cases <- as.numeric(dat$Total)

# remove years 2009 and 2025.
dat <- dat[-which(dat$year == 2025 | dat$year == 2009),]

################### population dataframe ######################
pop$year <- as.numeric(apply(pop, 1, function(x) substring(x[3], nchar(x[3])-3, nchar(x[3]))))


dat$pop <- pop$Total[match(dat$year, pop$year)]
dat$pop <- as.numeric(gsub(".", "", dat$pop, fixed=TRUE))

dat <- dat[-which(colnames(dat) %in% c("Periodo", "Total"))]


# same name of df as in previous case studies TSA
# separate 2010:2019, and 2020.
mortagg  <- dat[dat$year %in% 2010:2019,]
mort2020 <- dat[dat$year %in% 2020,]

# --------------------------------------------------------------------------------------------------
#  SAVE
# --------------------------------------------------------------------------------------------------

save(mortagg, mort2020, file=file.path(data.path, "mortagg2.Rdata"))

print(summary(mortagg))

sink()
