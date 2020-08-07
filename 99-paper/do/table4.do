use "$final_data", clear 

// Create a t4 folder to store outputs if it doesn't exist 
capture confirm file "tables/t4/"
if _rc mkdir "tables/t4/"

generate productivity_2017 = . //We will replace this variable in each regression so all 2017 values of the dependent variable appear in one row 
label var productivity_2017 "2017 productivity"

///////////////////////////////
// Full sample
//////////////////////////////

********************************************************************************************************
* Total amount of fertilizer applied (kg/ha)
********************************************************************************************************

eststo clear

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist urea_kg_hectare_ml dap_kg_hectare_ml mop_kg_hectare_ml zinc_kg_hectare_ml {

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
Fertilizer gap (all doses)
**********************************************************************************/

* Full sample 

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_urea distance_dap distance_mop distance_zinc {

  **Run regression for a given outcome in the variable list
  regress `x' treatment i.block_id

  **Store the estimates       
  noi estimates store var`var_num'_eg1
  
  **Store the SD from the control observations of the sample 
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
YIELDS
**********************************************************************************/

replace productivity_2017 = yield_hectare_2017_merged
summarize yield_hectare_2018_merged if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
eststo: regress yield_hectare_2018_merged treatment productivity_2017 i.block_id, robust
estadd scalar depMean = `varMean'

esttab using "tables/t4/panel_a.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
noconstant indicate("Block FE = *block*") b(%9.3fc) ///
mtitles("\makecell[c]{Total fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer (kg/ha)}" "\makecell[c]{Cotton yield (kg/ha)}")


////////////////////////////////////////////
// Farmer-reported yield sample 
////////////////////////////////////////////

preserve 

keep if fr_yield_sample == 1

********************************************************************************************************
* Total amount of fertilizer applied (kg/ha)
********************************************************************************************************

eststo clear

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist urea_kg_hectare_ml dap_kg_hectare_ml mop_kg_hectare_ml zinc_kg_hectare_ml {

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
Fertilizer gap (all doses)
**********************************************************************************/

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_urea distance_dap distance_mop distance_zinc {

  **Run regression for a given outcome in the variable list
  regress `x' treatment i.block_id

  **Store the estimates       
  noi estimates store var`var_num'_eg1
  
  **Store the SD from the control observations of the sample 
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
YIELDS
**********************************************************************************/

replace productivity_2017 = yield_hectare_2017_merged
summarize yield_hectare_2018_merged if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
eststo: regress yield_hectare_2018_merged treatment productivity_2017 i.block_id, robust
estadd scalar depMean = `varMean'

esttab using "tables/t4/panel_b.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
noconstant indicate("Block FE = *block*") b(%9.3fc) ///
mtitles("\makecell[c]{Total fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer (kg/ha)}" "\makecell[c]{Cotton yield (kg/ha)}")

restore 

////////////////////////////////////////////
// Satellite yield sample 
////////////////////////////////////////////

preserve 

keep if satellite_yield_sample == 1

********************************************************************************************************
* Total amount of fertilizer applied (kg/ha)
********************************************************************************************************

eststo clear

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist urea_kg_hectare_ml dap_kg_hectare_ml mop_kg_hectare_ml zinc_kg_hectare_ml {

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
Fertilizer gap (all doses)
**********************************************************************************/

* Full sample 

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_urea distance_dap distance_mop distance_zinc {

  **Run regression for a given outcome in the variable list
  regress `x' treatment i.block_id

  **Store the estimates       
  noi estimates store var`var_num'_eg1
  
  **Store the SD from the control observations of the sample 
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
YIELDS
**********************************************************************************/

* Full sample 

replace productivity_2017 = yield_hectare_2017_merged
summarize yield_hectare_2018_merged if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
eststo: regress yield_hectare_2018_merged treatment productivity_2017 i.block_id, robust
estadd scalar depMean = `varMean'

esttab using "tables/t4/panel_c.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
noconstant indicate("Block FE = *block*") b(%9.3fc) ///
mtitles("\makecell[c]{Total fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer (kg/ha)}" "\makecell[c]{Cotton yield (kg/ha)}")

restore 


////////////////////////////////////////////
// Intersecting sample 
////////////////////////////////////////////

preserve 

keep if intersecting_sample == 1

********************************************************************************************************
* Total amount of fertilizer applied (kg/ha)
********************************************************************************************************

eststo clear

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist urea_kg_hectare_ml dap_kg_hectare_ml mop_kg_hectare_ml zinc_kg_hectare_ml {

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
Fertilizer gap (all doses)
**********************************************************************************/

* Full sample 

local var_num = 1
**Defining list of variables looping over, for eventual combination of estimates
foreach x of varlist distance_urea distance_dap distance_mop distance_zinc {

  **Run regression for a given outcome in the variable list
  regress `x' treatment i.block_id

  **Store the estimates       
  noi estimates store var`var_num'_eg1
  
  **Store the SD from the control observations of the sample 
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
YIELDS
**********************************************************************************/

* Full sample 

replace productivity_2017 = yield_hectare_2017_merged
summarize yield_hectare_2018_merged if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
eststo: regress yield_hectare_2018_merged treatment productivity_2017 i.block_id, robust
estadd scalar depMean = `varMean'

esttab using "tables/t4/panel_d.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
noconstant indicate("Block FE = *block*") b(%9.3fc) ///
mtitles("\makecell[c]{Total fertilizer \\ applied (kg/ha)}" "\makecell[c]{Distance between \\ suggested \& \\ applied fertilizer (kg/ha)}" "\makecell[c]{Cotton yield (kg/ha)}")

restore 


