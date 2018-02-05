


version 14
capture log close
set more off
clear
clear matrix
clear mata

	    glo rootdir		"C:\Users\WB485280\OneDrive - WBG\work\Datascience\dataincub\data\project"
		glo	datadir     "${rootdir}"
		glo outdir		"${rootdir}\output"
		glo dodir		"${rootdir}\dofiles"
        
		
		
*******************************************************************************

cd "${datadir}"

global country "MAR TUN EGY DZA LBN FRA GBR USA"

foreach y of global country {

import excel "`y'.xlsx", sheet("Sheet1") clear

drop if A == ""

gen followers = ""
gen tweets = ""

split A, p("Followers ") gen(t)
drop t1

gen tt = t2[_n+1]

replace followers = tt

drop tt t2


split A, p("Tweets ") gen(t)
drop t1

gen tt = t2[_n+3]

replace tweets = tt
drop tt t2

drop if tweets == ""

gen Id = _n

rename A account

// From string to num //

split followers, p(",") gen(tt)
egen aa = concat(tt*)
replace followers = aa
destring followers, replace
drop tt* aa

split tweets, p(",") gen(tt)
egen aa = concat(tt*)
replace tweets = aa
destring tweets, replace
drop tt* aa

gen iso3 = "`y'"

save "`y'.dta", replace

}

append using "MAR.dta"
append using "TUN.dta"
append using "EGY.dta"
append using "DZA.dta"
append using "LBN.dta"
append using "FRA.dta"
append using "GBR.dta"

save data_twitter, replace

import excel "classi.xlsx", sheet("Sheet1") firstrow clear

merge 1:1 Id iso3 using "data_twitter"

keep if _merge == 3
drop _merge


gen pop = .

replace pop = 95.2 if iso3 == "EGY"
replace pop = 35.2 if iso3 == "MAR"
replace pop = 11.4 if iso3 == "TUN"
replace pop = 41 if iso3 == "DZA"
replace pop = 6 if iso3 == "LBN"
replace pop = 64.9 if iso3 == "FRA"
replace pop = 65.5 if iso3 == "GBR"
replace pop = 326.5 if iso3 == "USA"

gen internet = .

replace inter = 37.3 if iso3 == "EGY"
replace inter = 20.5 if iso3 == "MAR"
replace inter = 5.84 if iso3 == "TUN"
replace inter = 18.6 if iso3 == "DZA"
replace inter = 4.6 if iso3 == "LBN"
replace inter = 56.4 if iso3 == "FRA"
replace inter = 62 if iso3 == "GBR"
replace inter = 286.9 if iso3 == "USA"

gen facebook = .

replace face = 33 if iso3 == "EGY"
replace face = 12 if iso3 == "MAR"
replace face = 5.8 if iso3 == "TUN"
replace face = 18 if iso3 == "DZA"
replace face = 3.1 if iso3 == "LBN"
replace face = 33 if iso3 == "FRA"
replace face = 44 if iso3 == "GBR"
replace face = 240 if iso3 == "USA"

replace pop = 1000000*pop
replace internet = 1000000*internet
replace facebook = 1000000*facebook

save data_all, replace


/*************************************
Analysis of data
**************************************/

gen share_inter_media = 100*face/internet
gen share_inter = 100*inter/pop

bys iso3: egen nbr_pol = sum(polit)
bys iso3: egen nbr_media = sum(media)
gen one = 1
bys iso3: egen tot =sum(one)

gen share_pol = 100*nbr_pol/tot
gen share_media = 100*nbr_media/tot

gen t = 100*followers/face
bys iso3 : egen average_share1 = mean(t) if polit == 1
bys iso3 : egen average_share2 = mean(t) if media == 1

keep iso3 share* average*
duplicates drop

foreach var of varlist share* average* {

	replace `var' = 0  if `var' == .
	bys iso3: egen tt = max(`var')
	replace `var' = tt
	drop tt

}

duplicates drop

export excel using "output_final", sheetreplace firstrow(varlabels)
