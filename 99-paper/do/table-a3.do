use "$merged_data", clear 

keep if sowed_cotton == 1

// Create a t-a3 folder to store outputs if it doesn't exist 
capture confirm file "tables/t-a3/"
if _rc mkdir "tables/t-a3/"

//Generate an irrigation variable that uses data from all relevant surveys
generate irrigated = irrigation_ml 
replace irrigated = irrigation_el if missing(irrigated)
destring SII_4_1, replace 
replace irrigated = SII_4_1 if missing(irrigated)

// Look at the share and number of farmers that heard relevant recommendations 
eststo clear

egen rec_d4_ir = rowmax(farmer_recco_ir_D4*)
label var rec_d4_ir "Dose 4: irrigated (UREA, MOP, and DAP)"

egen rec_basal_ur = rowmax(farmer_recco_ur_basal*)
label var rec_basal_ur "Basal: unirrigated (UREA)"

egen rec_d2_ur = rowmax(farmer_recco_ur_D2*)
label var rec_d2_ur "Dose 2: unirrigated (UREA)"

egen rec_potash_ir_mid = rowmax(farmer_recco_ir_potash_mid*)
label var rec_potash_ir_mid "Mid-season: Potash (irrigated)"

egen rec_zinc_ir_mid = rowmax(farmer_recco_ir_zinc_mid*)
label var rec_zinc_ir_mid "Mid-season: Zinc (irrigated)"

egen rec_basal_ir = rowmax(farmer_recco_ir_basal*)
label var rec_basal_ir "Basal: irrigated (UREA, MOP, and DAP)"

egen rec_potash_ir_basal = rowmax(farmer_recco_ir_potash*)
label var rec_potash_ir_basal "Early season: Potash (irrigated)"

egen rec_zinc_ir_basal = rowmax(farmer_recco_ir_zinc*)
label var rec_zinc_ir_basal "Early season: Zinc (irrigated)"

egen rec_d2_ir = rowmax(farmer_recco_ir_D2*)
label var rec_d2_ir "Dose 2: irrigated (UREA, MOP, and DAP)"

egen rec_d3_ir = rowmax(farmer_recco_ir_D3*)
label var rec_d3_ir "Dose 3: irrigated (UREA, MOP, and DAP)"

label define recs 0 "Did not hear any recommendations" 1 "Heard 1 or more recommendations"

label val rec_* recs 

//Limit rates to irrigated farmers if irrigated recs and the same for unirrigated 

foreach x of varlist rec_basal_ir rec_potash_ir_basal ///
rec_d2_ir rec_d3_ir rec_d4_ir rec_potash_ir_basal rec_potash_ir_mid ///
rec_zinc_ir_basal rec_zinc_ir_mid {
	replace `x' = . if irrigated == 0 
}

foreach x of varlist rec_basal_ur rec_d2_ur {
	replace `x' = . if irrigated == 1
}

eststo: quietly estpost summarize rec_basal_ir rec_potash_ir_basal ///
rec_d2_ir rec_d3_ir rec_d4_ir rec_potash_ir_basal rec_potash_ir_mid ///
rec_zinc_ir_basal rec_zinc_ir_mid rec_basal_ur rec_d2_ur 

esttab using "tables/t-a3/listening_rates.tex", replace label ///
cells("mean(label(\makecell[c]{Share of relevant farmers \\ that heard $\ge$ 1 call}) fmt(3)) count(label(Number of relevant farmers) fmt(0))") nodepvars ///
frag tex noobs nomtitles nonumbers 

