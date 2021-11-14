*Program to estimate effects of end of EUC, end of EB, on exit rates.
*Jesse Rothstein, 12/6/2014
*
*Strategy:
*  1) Identify weeks covered by EUC and EB in each state in the period before
*     each disappeared (e.g., EUC might have covered weeks 27-53 in Dec 2013,
*     EB weeks 73-93 earlier.
*  2) Make an indicator for being in that week range (regardless of whether
*     EUC/EB is in effect in the state/month where the individual is observed.
*  3) Regress exit from UE on that indicator and an interaction with a "post-
*     program" indicator, controlling for our usual (including potentially
*     state and month effects, identified from people in other ranges).
*  4) Can explore including state-X and month-X interactions, where X is the 
*     indicator for the affected duration weeks.

** RV final change on March 12:  
**	(i) use final extract (06), with corrected "majind2"
**	(ii) restrict sample to 2012-2014m6 (as labeled in the paper)
** 	(iii) eliminated duration categories from margins command (my version of Stata does not like i. in margins)

version 13
cd /Users/nikhilsebastian/Desktop/SciencesPo/Semester3/LaborEcon/extendedUI-COVID19/ReplicationFiles/dta
clear *
set more off

cap log close
log using euceb_eventstudy_final.log, text replace


*Figure out which weeks are on EUC in each state at end of 2013.
*Note: I focus only on cohorts that have not had an interruption.
 use if date==mdy(12,15,2013) using stateeuc_raw, clear
 gen eucweeks=(euc1_weeks+euc2_weeks+euc3_weeks+euc4_weeks)
 keep st_cens eucweeks
 tempfile eucwks
 save `eucwks'
 use if date>=mdy(12,1,2013) & date<mdy(1,1,2014) using simulateui_cps, clear
 gen dur=(date-startdt)/7
 isid st_fips dur
 sort st_fips dur
 xtset st_fips dur
 by st_fips: gen endofregular=(wksleft_reg==0 & L.wksleft_reg>0)
 keep if endofregular==1
 gen eucstart=dur+1
 keep st_fips st_cens eucstart
 merge 1:1 st_cens using `eucwks'
 gen eucend=eucstart+eucweeks-1
 keep st_fips eucstart eucend
 save `eucwks', replace

 *Now do the same for EB, in the last month of EB in the state
  *Start by identifying that month
  *NOTE: For now, I just capture the *last* time EB went away in the state,
  *not all of them. 
   use if date>mdy(1,1,2009) using stateeb_raw, clear
   sort st_cens date
   xtset st_cens date, delta(7)	
   by st_cens: gen endofeb=(eb_weeks>0 & F.eb_weeks==0)
   keep if endofeb==1
   sort st_cens date
   by st_cens: keep if _n==_N
   gen day=day(date)
   gen cpsdate=date if day>=12 & day<=18
   replace cpsdate=date-day+12 + mod(day-12, 7) if day>18
   replace cpsdate=date-21 if day<12
   replace cpsdate=cpsdate+7 if day<12 & day(cpsdate)<12
   keep st_cens cpsdate eb_weeks
   rename cpsdate date
   format date %td
   tempfile ebwks
   save `ebwks'
  *Now need to figure out how many weeks of regular & EUC benefits were available then
   merge 1:1 st_cens date using stateeuc_raw, assert(2 3) keep(3)
   gen eucweeks=(euc1_weeks+euc2_weeks+euc3_weeks+euc4_weeks)
   keep st_cens date eb_weeks eucweeks
   save `ebwks', replace
   merge 1:m st_cens date using simulateui_cps, assert(2 3) keep(3)
   gen dur=(date-startdt)/7
   isid st_fips dur
   sort st_fips dur
   xtset st_fips dur
   by st_fips: gen endofregular=(wksleft_reg==0 & L.wksleft_reg>0)
   keep if endofregular==1
   gen eucstart=dur+1
   gen ebstart=dur+eucweeks+1
   gen ebend=ebstart+eb_weeks-1
  keep st_fips date ebstart ebend
  rename date ebenddate
  save `ebwks', replace
  
 use ext06 if elig2==1,clear  /* ELIGIBLE */
 drop if date<=ym(2004,4)
  ** USE RV VARIABLE HERE (ALREADY MATCHED TO EXIT MONTH)
 gen byte ui_avail=(ui_weeks>duration2) if (ui_weeks<. & duration2<.)
 label var ui_avail "=1 if weeks left >0 (in exit month)"

 *Assign EUCrange
 merge m:1 st_fips using `eucwks', assert(3)
 gen eucrange=(duration2>=eucstart-4 & duration2<=eucend-4)
 gen posteuc=(date>=ym(2013,12))
 *Note: The classification isn't perfect
  tab ui_avail posteuc if eucrange==1
  tab date ui_avail if eucrange==1 & date>=ym(2013,9) & date<=ym(2014,3)
 *Assign EB range
  cap drop _merge
  merge m:1 st_fips using `ebwks', assert(1 3)
  gen ebrange=(duration2>=ebstart-4 & duration2<=ebend-4)
  gen posteb=(date>=mofd(ebenddate))
  gen diff_eb=date-mofd(ebenddate)
  tab diff_eb ui_avail if ebrange==1 & diff_eb>-12 & diff_eb<12
  
  gen cutoff=max(eucrange*posteuc, ebrange*posteb)
  gen cutoff_eb=ebrange*posteb
  gen cutoff_euc=eucrange*posteuc
 
/* DEFINE SOME MACROS */
macro define dur_FV i.durmoncat2
macro define dur_JR dur dur_sq dur_inv new_un gte26
#delimit ;
macro define X urate_st* d3lne_st* i.educ i.agecat female married fem_marr
 i.race i.majind2 i.state i.date;
macro define X2 i.educ i.agecat female married fem_marr
 nonwhite i.majind2;
#delimit cr

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

** Restrict to 2012-2014m6
keep if year>=2012

table eucrange ebrange, contents(n posteb sum posteb sum cutoff)

reg ui_avail eucrange ebrange cutoff posteb $dur_FV $X, cluster(mstate)

foreach v in exit2 exit2_emp exit2_nilf {
 di
 di "SPEC 1: OUTCOME IS `v'"
 di
 logit `v' eucrange ebrange cutoff posteb $dur_FV $X,cluster(mstate) nolog
 di "SPEC 1: OUTCOME IS `v'"
 margins,dydx(eucrange ebrange cutoff posteb)

} 

foreach v in exit2 exit2_emp exit2_nilf {
 di
 di "SPEC 2: OUTCOME IS `v'"
 di
 logit `v' eucrange ebrange cutoff_euc cutoff_eb posteb $dur_FV $X,cluster(mstate) nolog
 di "SPEC 2: OUTCOME IS `v'"
 margins,dydx(eucrange ebrange cutoff_euc cutoff_eb posteb)

} 

log close
