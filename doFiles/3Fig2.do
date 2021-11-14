*************************************************************************
* Created by: 	Rob Valletta (modification of HF programs "fig_exit01(02).do"			
* Created on: 	12/22/14
* Modified on:	13/11/2021 - Nikhil Sebastian						
*************************************************************************

version 13.0
capture log close
clear *
set more off
capture program drop _all
cd /Users/nikhilsebastian/Desktop/SciencesPo/Semester3/LaborEcon/extendedUI-COVID19/ReplicationFiles/dta

set linesize 120
log using logs\fig_exits_new2.log, replace

use ext06, clear
/* DO QUARTERLY */
gen yrq=qofd(dofm(date))
gen byte late=yofd(dofm(date))>=2012
format %tq yrq
drop if durmoncat2<3
keep if elig2==1
keep if age>=18 & age<=69
collapse (mean) exit2 exit2_emp exit2_nilf late [aw=wgtbls],by(yrq)

/* SEASONALLY ADJUST AND SMOOTH */
gen byte quarter=quarter(dofq(yrq))
tab quarter,gen(q)
tsset yrq
foreach x in exit2 exit2_emp exit2_nilf {
	egen m`x' = mean(`x')
	reg `x' q1-q4,hascons
	predict `x'_a,resid
	replace `x'_a=`x'_a + m`x'
	drop m`x'
        tssmooth ma `x'_as=`x'_a,window(1 1 1)
}


** Graph code here 
set scheme s2mono
sort yrq
format yrq %tqYY!-!Qq
keep if yofd(dofq(yrq))>=2007

label var yrq "Quarter"
label var exit2_a "All Exits"
label var exit2_emp_a "Exits to Employment"
label var exit2_nilf_a "Exits out of Labor Force"

#d ;
graph twoway 
  scatter exit2_a exit2_emp_a exit2_nilf_a yrq, 
  c(l l l) ms(i i) lpattern(l .-.)
  ysize(1.8) l1("Exit Rate") yscale(range(0 0.35)) ylab(0(.05).35)
  xscale(range(188 217)) xlabel(188(2)216, tlength(*1.8) tposition(outside) labgap(0.5)) 
  legend(ring(0) pos(12) rows(1) size(medsmall) rowgap(0.4) colgap(1.0)) 
  plotregion(margin(0)) saving(figs\fig2_exits_new2.gph, asis replace);
  graph export figs\fig2_exits_new2.pdf,replace;

#d cr

log close
