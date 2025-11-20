# Rensar workspace
rm(list = ls())
gc()

heading <- "------------------------------------------------------------------------------------
 FILE:   gen_mortality_Spain_2010_2023.R
 STUDY:  TSA module 2025
 CONTACT: Tanja Charles
 AFFILIATION: SPM/Fellowship
 PROJECT: 

 STATISTICIAN: Sharon Kühlmann

 Input : 

 Created:      14-11-2025
 Updated: 

 What: Read raw file with number of deaths per week in Spain, total and per sex; 
        linked to yearly population total and by sex. 
        One object with 2010-2019, and another with only 2020.
        
        Source:
        Estimación del número de defunciones semanales
        Downloaded from https://www.ine.es/jaxiT3/Datos.htm?t=35177#_tabs-tabla
        
 

 Input : 
 Output: mortagg2.Rdata

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

sink(file.path(output.path, "gen_mortality_Spain_2010_2023.out"))

cat(heading)


#-----------------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------------

library(reshape2)

#---------------------------------------------------------------------------------------------------
# READ DATA
#---------------------------------------------------------------------------------------------------

dat_long <- read.table(file.path(data.path, "Spain_deaths_weekly_sex.csv"), sep=";")
colnames(dat_long) <- dat_long[1,]
dat_long <- dat_long[-1,]
dat_long <- dat_long[, -c(1:2,4,5)]
dat_long$Total <- as.numeric(gsub(".", "", dat_long$Total, fixed=TRUE))

dat <- dcast(dat_long, Periodo ~ Sexo, value.var="Total")


pop_long <- read.table(file.path(data.path, "Spain_population_sex.csv"), sep=";")
colnames(pop_long) <- pop_long[1,]
pop_long <- pop_long[-1,]
pop_long$Total <- as.numeric(gsub(".", "", pop_long$Total, fixed=TRUE))

pop <- dcast(pop_long, Periodo ~ Sexo, value.var="Total")



#---------------------------------------------------------------------------------------------------
# EDIT
#---------------------------------------------------------------------------------------------------

##################### deaths dataframe (dat) #####################
# extract year and week from Periodo column
dat$year  <- as.numeric(apply(as.matrix(dat$Periodo), 1, function(x) strsplit(x, "S")[[1]][1]))

dat$week  <- apply(as.matrix(dat$Periodo), 1, function(x) strsplit(x, "SM")[[1]][2])

#remove leading 0
dat$week  <- as.numeric(apply(as.matrix(dat$week), 1, 
                function(x) ifelse(substr(x, 1, 1)=="0", substr(x, 2, 2), x)))

colnames(dat)[colnames(dat) == "Total"] <- "cases"
colnames(dat)[colnames(dat) == "Mujeres"] <- "cases_f"
colnames(dat)[colnames(dat) == "Hombres"] <- "cases_m"



################### population dataframe ######################
pop$year <- as.numeric(apply(as.matrix(pop$Periodo), 1, function(x) substring(x, nchar(x)-3, nchar(x))))


dat$pop   <- pop$Total[match(dat$year, pop$year)]
dat$pop_f <- pop$Mujeres[match(dat$year, pop$year)]
dat$pop_m <- pop$Hombres[match(dat$year, pop$year)]

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
print(summary(mort2020))

sink()
