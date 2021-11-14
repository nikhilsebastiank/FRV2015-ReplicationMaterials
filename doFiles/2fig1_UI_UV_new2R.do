*************************************************************************
* Created by: 	Rob Valletta (modification of HF program "fig_ext03.do")		
* Created on: 	12/21/14
* Modified on:	13/11/21 - Nikhil Sebastian					
* Description: 	Creates UI weeks & U/V chart for Farber-Rothstein-Valletta UI paper
*************************************************************************

version 13.0
capture log close
clear *
set more off
capture program drop _all
cd /Users/nikhilsebastian/Desktop/SciencesPo/Semester3/LaborEcon/extendedUI-COVID19/ReplicationFiles/dta

set linesize 120
log using logs\fig1_UI_UV_new2.log, replace

#d ;
use ext_wks ui_weeks eb_weeks eb date year month elig2 age wgtbls
  if year>=2007 & elig2==1 using ext06, clear;
drop if age<18 | age>=70; /* KEEP ONLY 18-69 */
gen yrq=qofd(dofm(date));
format %tq yrq;

collapse (mean) mean_ui_wks=ui_weeks  (p10) q10_ui_wks=ui_weeks
 (p50) med_ui_wks=ui_weeks (p90) q90_ui_wks=ui_weeks [aw=wgtbls], by(yrq);
#d cr
label var yrq "Quarter"
label var mean_ui_wks "Mean Weeks UI Available"
label var med_ui_wks "Median Weeks UI Available"
label var q10_ui_wks "10th Percentile Weeks UI Available"
merge 1:1 yrq using Newfred_a, nogen /* MERGE IN UV RATIO */
label var uvrate "Unemployed per Vacancy"
keep if yofd(dofq(yrq))>=2007

** Graph code here 
set scheme s2mono
sort yrq
format yrq %tqYY!-!Qq

tsset yrq

#d ;
twoway 
  (tsline med_ui_wks, c(l) lpattern(solid) msymbol(i)) 
  (tsline uvrate, c(l) lpattern(dash) msymbol(i) yaxis(2)), 
  ysize(1.8) yscale(range(20 100) axis(1)) ylab(20(10)100, grid axis(1))
  yscale(range(1 7) axis(2)) ylab(1(1)7, axis(2))
  xscale(range(188 217)) xlabel(188(2)216, tlength(*1.8) tposition(outside) labgap(0.5))
  legend(label(1 "Median Weeks UI Available (left)") label(2 "Unemployed per Vacancy (right)") 
  ring(0) pos(11) rows(2) size(medsmall) rowgap(0.4) colgap(0.4)) plotregion(margin(0))
  saving(figs\fig1_UI_UV_new2.gph, asis replace);
  graph export figs\fig1_UI_UV_new2.pdf,replace;

#d cr
log close
