use "$final_data", clear 

// Create a t3 folder to store outputs if it doesn't exist 
capture confirm file "tables/t3/"
if _rc mkdir "tables/t3/"

///////////////////////////////
// Full sample
//////////////////////////////

/**********************************************************************************
Followed recommendations 
**********************************************************************************/

foreach x in "UREA" "DAP" "MOP" "ZINC" {

if "`x'" == "ZINC" {
generate followed_rec_basal_`x' = SII_6_1_`x'
replace followed_rec_basal_`x' = 1 - SII_6_1_`x' if SII_4_1 == 0 //Unirrigated plots should not have had Zinc applied
label var followed_rec_basal_`x' "\makecell[c]{Zinc}"
}
else if "`x'" == "UREA" {
generate followed_rec_basal_`x' = SII_6_1_`x'
label var followed_rec_basal_`x' "\makecell[c]{`x'}"
}
else{
generate followed_rec_basal_`x' = SII_6_1_`x'
replace followed_rec_basal_`x' = 1 - SII_6_1_`x' if SII_4_1 == 0 //Unirrigated plots should not have MOP or DAP applied
label var SII_6_1_`x' "\makecell[c]{`x'}"
}

replace followed_rec_basal_`x' = . if consent_basal != 1

} 


eststo clear

// Joint effects

**Run regression of interest


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist followed_rec_basal_UREA followed_rec_basal_DAP followed_rec_basal_MOP followed_rec_basal_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust 

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post 

estimates store est1
estimates restore est1
eststo

/**********************************************************************************
Amount of fertilizer applied (kg/ha) 
**********************************************************************************/


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist UREA_kg_hectare_bd DAP_kg_hectare_bd MOP_kg_hectare_bd ZINC_kg_hectare_bd {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est2
estimates restore est2
eststo

/**********************************************************************************
Fertilizer gap
**********************************************************************************/

*This loops over each fertilizer of interest, calculates the distance (absolute difference), then calculates treatment effects with this DV

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_UREA distance_DAP distance_MOP distance_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est3
estimates restore est3
eststo

esttab using "tables/t3/panel_a.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels noconstant b(%9.3fc) scalars("N Observations") sfmt(%9.0fc) ///
mtitles("\makecell[c]{Binary fertilizer \\ use consistent \\ with recommendation}" "\makecell[c]{Amount of \\ fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer}")


////////////////////////////////////////////
// Farmer-reported yield sample 
////////////////////////////////////////////

preserve 

keep if fr_yield_sample == 1

/**********************************************************************************
Followed recommendations 
**********************************************************************************/

eststo clear

// Joint effects

**Run regression of interest


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist followed_rec_basal_UREA followed_rec_basal_DAP followed_rec_basal_MOP followed_rec_basal_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust 

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post 

estimates store est1
estimates restore est1
eststo

/**********************************************************************************
Amount of fertilizer applied (kg/ha) 
**********************************************************************************/


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist UREA_kg_hectare_bd DAP_kg_hectare_bd MOP_kg_hectare_bd ZINC_kg_hectare_bd {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est2
estimates restore est2
eststo


/**********************************************************************************
Fertilizer gap
**********************************************************************************/

*This loops over each fertilizer of interest, calculates the distance (absolute difference), then calculates treatment effects with this DV

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_UREA distance_DAP distance_MOP distance_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est3
estimates restore est3
eststo

esttab using "tables/t3/panel_b.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels noconstant b(%9.3fc) scalars("N Observations") sfmt(%9.0fc) ///
mtitles("\makecell[c]{Binary fertilizer \\ use consistent \\ with recommendation}" "\makecell[c]{Amount of \\ fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer}")

restore 

////////////////////////////////////////////
// Satellite yield sample 
////////////////////////////////////////////

preserve 

keep if satellite_yield_sample == 1

/**********************************************************************************
Followed recommendations 
**********************************************************************************/

eststo clear

// Joint effects

**Run regression of interest


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist followed_rec_basal_UREA followed_rec_basal_DAP followed_rec_basal_MOP followed_rec_basal_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust 

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post 

estimates store est1
estimates restore est1
eststo

/**********************************************************************************
Amount of fertilizer applied (kg/ha) 
**********************************************************************************/


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist UREA_kg_hectare_bd DAP_kg_hectare_bd MOP_kg_hectare_bd ZINC_kg_hectare_bd {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est2
estimates restore est2
eststo


/**********************************************************************************
Fertilizer gap
**********************************************************************************/

*This loops over each fertilizer of interest, calculates the distance (absolute difference), then calculates treatment effects with this DV

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_UREA distance_DAP distance_MOP distance_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est3
estimates restore est3
eststo

esttab using "tables/t3/panel_c.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels noconstant b(%9.3fc) scalars("N Observations") sfmt(%9.0fc) ///
mtitles("\makecell[c]{Binary fertilizer \\ use consistent \\ with recommendation}" "\makecell[c]{Amount of \\ fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer}")

restore 


////////////////////////////////////////////
// Intersecting sample 
////////////////////////////////////////////

preserve 

keep if intersecting_sample == 1

/**********************************************************************************
Followed recommendations 
**********************************************************************************/

eststo clear

// Joint effects

**Run regression of interest


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist followed_rec_basal_UREA followed_rec_basal_DAP followed_rec_basal_MOP followed_rec_basal_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust 

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post 

estimates store est1
estimates restore est1
eststo

/**********************************************************************************
Amount of fertilizer applied (kg/ha) 
**********************************************************************************/


local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist UREA_kg_hectare_bd DAP_kg_hectare_bd MOP_kg_hectare_bd ZINC_kg_hectare_bd {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est2
estimates restore est2
eststo


/**********************************************************************************
Fertilizer gap
**********************************************************************************/

*This loops over each fertilizer of interest, calculates the distance (absolute difference), then calculates treatment effects with this DV

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_UREA distance_DAP distance_MOP distance_ZINC {

	**Run regression for a given outcome in the variable list
	regress `x' treatment i.block_id

	**Store the estimates				
	noi estimates store var`var_num'_eg1
	
	**Store the SD from the control observations of the sample [Here, intervention == 3 was control]
	tempvar samplevar
	g `samplevar' = e(sample)
	summ `x' if `samplevar' == 1 & treatment == 0
	local sd1_`var_num' = r(sd)

	**Change variable number counter to next number
	local var_num = `var_num' + 1
}

**Combine stored estimates  [If you are clustering standard errors, you need to wait until now to do this or else SUEST won't work]
suest var1_eg1 var2_eg1 var3_eg1 var4_eg1, robust

**Calculate average standardized effect across outcomes  [Here, when combining outcomes sometimes have plus, sometimes minus, depending on whether more is good (ex: vitamin uptake) or bad (eg: malnutrition), 
//then use trickery to get it to save as a regression estimation that can be added correctly to esttab

nlcom (v1:([var1_eg1_mean]treatment/`sd1_1' + [var2_eg1_mean]treatment/`sd1_2' ///
+ [var3_eg1_mean]treatment/`sd1_3' + [var4_eg1_mean]treatment/`sd1_4') / 4), post

estimates store est3
estimates restore est3
eststo

esttab using "tables/t3/panel_d.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels noconstant b(%9.3fc) scalars("N Observations") sfmt(%9.0fc) ///
mtitles("\makecell[c]{Binary fertilizer \\ use consistent \\ with recommendation}" "\makecell[c]{Amount of \\ fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer}")

restore 

