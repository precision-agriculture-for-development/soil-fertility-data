use "$final_data", clear

// Create a f3 folder to store outputs if it doesn't exist 
capture mkdir "figures/f4/"

//////////////////////////////////////////////////////
//Self-reported harvest and measured plot size
//////////////////////////////////////////////////////

cumul yield_hectare_2018 if treatment==0, gen(cdf_yield_hectare_2018_control)
cumul yield_hectare_2018 if treatment==1, gen(cdf_yield_hectare_2018_treatment)

line cdf_yield_hectare_2018_control yield_hectare_2018, sort lcolor(red) fcolor(red%50) recast(area) || ///
line cdf_yield_hectare_2018_treatment yield_hectare_2018, sort lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Cumulative Density") xtitle("Farmer-reported productivity (kg/hectare)") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") place(11) /// 
bmargin(small) bplacement(11)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.1fc))

gexport, file("figures/f4/yields_survey.png") 

//////////////////////////////////////////////////////
//Satellite-measured yield 
//////////////////////////////////////////////////////

*****************************************************************************
* Convert raw vegetation index values to yield estimates 
*****************************************************************************

regress yield_hectare_2017 max_re705_2017 
predict sentinel_2017, xb 
replace sentinel_2017 = 0 if sentinel_2017 < 0 

regress yield_hectare_2018 max_re705_2018 
predict sentinel_2018, xb 
replace sentinel_2018 = 0 if sentinel_2018 < 0 

cumul sentinel_2018 if treatment==0, gen(cdf_sentinel_2018_control)
cumul sentinel_2018 if treatment==1, gen(cdf_sentinel_2018_treatment)

line cdf_sentinel_2018_control sentinel_2018, sort lcolor(red) fcolor(red%50) recast(area) || ///
line cdf_sentinel_2018_treatment sentinel_2018, sort lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Cumulative Density") xtitle("Satellite-measured productivity (kg/hectare)") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") place(11) /// 
bmargin(small) bplacement(11)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.1fc))

gexport, file("figures/f4/yields_satellite.png") 

