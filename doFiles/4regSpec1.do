** REVISED VERSION OF REG06.DO, USING DATA WITH STATE ECONOMIC
** CONDITIONS MATCHED TO FORWARD MATCH MONTH
** Modified 13/11/2021 - Nikhil Sebastian

** THIS VERSION 2 ALSO USES MAJIND2 (FILLED IN MISSINGS BASED ON UNU AND UEU RECODES)

version 13.0 
capture log close
set linesize 80
set more off
cd /Users/nikhilsebastian/Desktop/SciencesPo/Semester3/LaborEcon/extendedUI-COVID19/ReplicationFiles/dta

log using logs\reg06r2.log,replace
use ext06 if elig2==1,clear  /* ELIGIBLE */
/* DEFINE SOME MACROS */
macro define dur_FV i.durmoncat2
macro define dur_JR dur dur_sq dur_inv new_un gte26
#delimit ;
macro define X urate_st* d3lne_st* i.educ i.agecat female married fem_marr
 i.race i.majind2 i.state i.date;
macro define X2 i.educ i.agecat female married fem_marr
 nonwhite i.majind2;
#delimit cr
/* NOTE THAT RACE INCLUDES HISPANIC.  HOW WAS THIS DONE? */
/* CREATE UI AVAILABILITY VARIABLES 
   NOTE THAT WKSLEFT_TOT IS MISSING FOR OBS PRIOR TO MAY 2004 
   BUT STILL SOME MISSINGS BETWEEN 2004M5 AND 2006M1  */
drop if date<=ym(2004,4)
  ** USE RV VARIABLE HERE (ALREADY MATCHED TO EXIT MONTH)
gen byte ui_avail=(ui_weeks>duration2) if (ui_weeks<. & duration2<.)
label var ui_avail "=1 if weeks left >0 (in exit month)"
#delimit:
gen byte ui_last=((duration2-ui_weeks)>=-4 & (duration2-ui_weeks)<=0)
  if (ui_weeks<. & duration2<.);
#delimit cr
label var ui_last "=1 if in last 4 weeks of eligibility (in exit month)"
/* macro define ui_hf ui_avail ui_last */
macro define ui_hf ui_avail
/* DROP AGE<18 AND AGE>=70 */
tab agecat
drop if age<18 | age>=70
tab agecat
label var agecat "Decade of Age"
/* DROP IF LESS THAN 3 MONTHS UNEMPLOYMENT */
drop if durmoncat2<3
/* GENERATE STATE BY MONTH FOR CLUSTERING */
gen long mstate=(state*1000)+date
label var mstate "state*1000 + month"
/* OVERALL HAZARD */
preserve
foreach v in exit2 exit2_emp exit2_nilf {
 keep if year>=2008 & year<=2011
 di
 di "OUTCOME IS `v'"
 di
 logit `v' $ui_hf  $dur_FV $X,cluster(mstate) nolog
 margins,dydx($ui_hf)
 restore,preserve
 keep if year>=2012
 di
 di "OUTCOME IS `v'"
 di
 logit `v' $ui_hf  $dur_FV $X,cluster(mstate) nolog
 margins,dydx($ui_hf)
 restore,preserve
}
log close
set more on
