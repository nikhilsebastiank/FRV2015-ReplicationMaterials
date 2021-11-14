* Creating the data for U-V ratio *
* This file to be loaded into the R-script*

clear all
version 13
cd /Users/nikhilsebastian/Desktop/SciencesPo/Semester3/LaborEcon/extendedUI-COVID19/ReplicationFiles/dta
import delimited fred_a.csv
gen date1 =ym(year,month)
format date1 %tm
drop if year < 2007 | year > 2014

gen yrq = qofd(dofm(date1))
format %tq yrq

save fred_a, replace
