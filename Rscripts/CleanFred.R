install.packages("haven")
library(haven)
library(dplyr)

# Set working directory
setwd("/Users/nikhilsebastian/Desktop/SciencesPo/Semester3/LaborEcon/extendedUI-COVID19/ReplicationFiles/dta")

# Read the cleaned dta data
data = read_dta("fred_a.dta")
data$q = 1 + (as.numeric(data$month)-1) %/% 3
View(data)

# Create a new data set with quarterly averaged unemployment to vacancy ratio
newdata = data %>%
    select(year, month, q, uvrate, yrq) %>%
    group_by(yrq) %>%
    summarize(uvrate = sum(uvrate)/3)

View(newdata)

# Export to a .dta file
write_dta(newdata, file.path(getwd(), "Newfred_a.dta"))
