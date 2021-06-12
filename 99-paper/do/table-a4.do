use "$final_data", clear 

// Create a t3 folder to store outputs if it doesn't exist 
capture mkdir "tables/t-a4/"

/**********************************************************************************
Followed recommendations 
**********************************************************************************/

//Basal 
eststo clear

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

egen std_`x' = std(followed_rec_basal_`x')

replace followed_rec_basal_`x' = . if consent_basal != 1

summarize followed_rec_basal_`x' if treatment == 0, meanonly 
local varMean = `r(mean)' 
eststo: regress followed_rec_basal_`x' treatment i.block_id, robust
estadd scalar depMean = `varMean'
} 

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

estimates store est5
estimates restore est5
eststo


esttab using "tables/t-a4/followed_rec_basal.tex", replace se noobs rename(v1 treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) noconstant ///
indicate("Block FE = *block*") mtitles("\makecell[c]{UREA}" "\makecell[c]{DAP}" "\makecell[c]{MOP}" "\makecell[c]{Zinc}" "\makecell[c]{Standardized \\ joint effects}")


/**********************************************************************************
Amount of fertilizer applied (kg/ha)
**********************************************************************************/
eststo clear

foreach x in "UREA" "DAP" "MOP" "ZINC"{
	summarize `x'_kg_hectare_bd if treatment == 0, meanonly 
	local varMean =`r(mean)'
	eststo: regress `x'_kg_hectare_bd treatment i.block_id, robust
	estadd scalar depMean = `varMean'
}

//Joint effects

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

estimates store est5 

estimates restore est5
eststo


esttab using "tables/t-a4/fert_applied_basal.tex", replace se noobs not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) frag interaction(" x ") indicate("Block FE = *block*") ///
mtitles("UREA" "DAP" "MOP" "Zinc" "\makecell[c]{Standardized \\ joint effects}") rename(v1 treatment) ///
noconstant

/**********************************************************************************
Fertilizer gap
**********************************************************************************/

*This loops over each fertilizer of interest, calculates the distance (absolute difference), then calculates treatment effects with this DV
eststo clear

foreach x in "UREA" "DAP" "MOP" "ZINC"{
	summarize distance_`x' if treatment == 0, meanonly 
	local varMean =`r(mean)'
	eststo: regress distance_`x' treatment i.block_id, robust
	estadd scalar depMean = `varMean'
}

//Joint effects

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

estimates store est5 

estimates restore est5
eststo

esttab using "tables/t-a4/gap_basal.tex", replace se noobs not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) frag ///
indicate("Block FE = *block*") rename(v1 treatment) noconstant ///
mtitles("UREA" "DAP" "MOP" "Zinc" "\makecell[c]{Standardized \\ joint effects}")

