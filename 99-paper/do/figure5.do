use "$rainfall_data", clear 

merge 1:1 uid using "$merged_data", keepusing(sowed_cotton) keep(3) nogenerate

// Create a f5 folder to store outputs if it doesn't exist 
capture mkdir "figures/f5/"

// Create a folder to store the reshaped data (but not sync to Overleaf) if it doesn't exist
// This is to speed up execution on future runs
capture mkdir "data/nosync/"

keep if sowed_cotton == 1

drop sowed_cotton

**********************************************************************************************
*Daily 
**********************************************************************************************

preserve 

// The reshaping takes a very long time, so save the file (but add it to gitignore so it's not saved online), and then try loading it instead of recreating it on future runs
capture confirm file "data/nosync/rainfall_1.dta"
if _rc {

reshape long rain_daily_, i(uid) j(date_str) string 

gen date = date(date_str, "YMD")
format date %td

drop date_str 

rename rain_daily_ rain 

collapse (mean) rain, by(date)

label var rain "Rainfall (mm)"

generate day = day(date)
generate month = month(date)
generate year = year(date)

drop date 

reshape wide rain, i(day month) j(year)

generate year_dummy = 2017 //We will create a new date variable where the year is listed as 2017 regardless of what it actually is so that overlaying the plots is easier

generate date = mdy(month, day, year_dummy)
format date %tdMonth_dd

drop year_dummy day month 

tsset date 

//Rename 2018 and 2019 (the post-treatment years) so that we can emphasize them

rename rain2018 rain_2018

rename rain2019 rain_2019
label var rain_2019 "2019"

// We rename this because there are too many years to plot, or the graph cannot be interpreted 

rename rain2017 rainfall_2017
label var rainfall_2017 "2017"
rename rain2016 rainfall_2016 
label var rainfall_2016 "2016"

foreach x of varlist rain2* { 
local year = substr("`x'",5,4)
label var `x' "`year'"
}

save "data/nosync/rainfall_1.dta", replace 

}

else {
	use "data/nosync/rainfall_1.dta", clear 
}

label var rain_2018 "2018 (Intervention year)"

set scheme plotplain
*https://www.stata-journal.com/sjpdf.html?articlenum=gr0002

tsline rainfall* || ///
tsline rain_2018, lcolor(red) connect(direct) lpattern(solid) ///
legend(position(2) bmargin(tiny) ring(0)) ytitle("Rainfall (mm/day)") xtitle("")

gexport, file("figures/f5/rain_daily.png") 

capture graph close 
 
restore 

**********************************************************************************************
*Monthly
**********************************************************************************************

// The reshaping takes a very long time, so save the file (but add it to gitignore so it's not saved online), and then try loading it instead of recreating it on future runs
capture confirm file "data/nosync/rainfall_2.dta"
if _rc {

reshape long rain_daily_, i(uid) j(date_str) string 

rename rain_daily_ rain 

gen date = date(date_str, "YMD")
drop date_str 

replace date = mdy(month(date), 1, year(date))  // Converts to month and year only since we are producing monthly figures

collapse (mean) rain, by(date)

label var rain "Rainfall (mm/day)"

label var date "Date"

gen year = year(date)
label var year "Year" 

gen month = month(date)
label var month "Month"

bysort month: egen average_rain = mean(rain)

drop date 

reshape wide rain average_rain, i(month) j(year)

capture label drop month 
label define month 6 "June" 7 "July" 8 "August" 9 "September" 10 "October"

label val month month 
rename average_rain2010 average_rain 
label var average_rain "Average rainfall: 2010-2019 (mm/day)"

drop average_rain2* 
rename rain2018 rain_2018
rename rain2019 rain_2019

local labels 

foreach x of varlist rain2* { 
local year = substr("`x'",5,4)
label var `x' "`year'"
}

label var rain_2019 "2019"

label var average_rain "Average"

save "data/nosync/rainfall_2.dta", replace 

}

else {
	use "data/nosync/rainfall_2.dta", clear 
}

label var rain_2018 "2018 (Intervention year)"

graph twoway line rain20* month || ///
line average_rain month, lcolor(gs7) connect(direct) lpattern(solid) lwidth(thick) || ///
line rain_2018 month, lcolor(red) connect(direct) lpattern(solid) ///
legend(position(2) cols(2) bmargin(tiny) ring(0)) xlabel(6 7 8 9 10, valuelabel) ///
xtitle("") ytitle("Rainfall (mm/day)")

gexport, file("figures/f5/rain_monthly.png") 

capture graph close 
