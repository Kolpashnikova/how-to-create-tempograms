*************************************************************************
*** This is a code to create tempograms using STULA (Japanese data)
*** created by Kamila Kolpashnikova 2018
*************************************************************************

/*before using the code you need to subset the sample 
for instance to women on weekends, or add options to tab below*/

clear
cd "~\Documents"
save temp, replace emptyok 



forvalues i = 1(1)96 {
  use "~\Japan_J.dta", clear
  cd "~\Documents"
  local j = 301+`i'*6-6
  quietly tab v`j', matcell(a)
  svmat double a
  keep a1
  keep in 1/20
  rename a1 a
  append using temp
  save temp, replace
 }

use temp, clear
recode a (.=0)

************************************************************************
*** working with the resulting table
************************************************************************
ssc install seq
seq b, f(1) t(20)
seq x1, f(96) t(1) b(20)

order b x1 a
 
reshape wide a, i(x1) j(b)

**** dealing with labels

forval i = 0(1)23 {
	local a = `i'*4+1
	label def tod `a' "`i':00", modify
}

forval i = 0(1)23 {
	local a = `i'*4+2
	label def tod `a' "`i':15", modify
}

forval i = 0(1)23 {
	local a = `i'*4+3
	label def tod `a' "`i':30", modify
}

forval i = 0(1)23 {
	local a = `i'*4+4
	label def tod `a' "`i':45", modify
}

label val x1 tod 


*********************************************************************
*** creating combined activities
*********************************************************************

gen sleep = a1
gen personal_care = sleep+a2+a19
gen eating = personal_care + a3
gen work = eating + a5 + a6
gen leisure = work + a13 + a14 + a15 + a16 + a17 + a18
gen TV = leisure + a12
gen housework = TV + a7 + a10
gen care = housework + a8
gen child_care = care + a9
gen travel = child_care + a4 + a11
gen other = travel + a20
	
graph twoway (area other travel ///
	child_care care housework TV ///
	leisure ///
	work eating personal_care ///
	sleep x1), ///
	xlabel(1 "00:00 am" 25 "6:00 am" 37 "9:00 am" ///
	49 "12:00 pm" 61 "15:00 pm" 73 "18:00 pm" ///
	81 "20:00 pm" 89 "22:00 pm", angle(90)) ///
	text(80000 15 "{bf:sleep}") ///
	text(220000 39 "{bf:housework}") ///
	text(85000 42 "{bf:work}") ///
	text(200000 85 "{bf:watch TV}") ///
	ylabel("") ///
	ytitle () ///
	xtitle (time of the day) ///
	legend()
