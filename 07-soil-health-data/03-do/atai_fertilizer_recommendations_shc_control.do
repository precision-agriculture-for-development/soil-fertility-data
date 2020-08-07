clear all
version 14
cap log close
set more off
/****************************************************************************
This file takes the recommendation data and extracts data that will be used for SHC and supplements.
This file will also translate the values in English into Gujarati. 
****************************************************************************/

*Main path
gl Main ""

*Input data
loc recommendations "07-soil-health-data/04-processed-data/ATAI_Soil_Tests_Results_Recommendations.dta"
loc randomization	"01-baseline/04-cleaned-data/merged/ATAI_baseline_treatment_assignment.dta" 
loc treatment "01-baseline/04-cleaned-data/merged/ATAI_baseline_treatment_assignment_T.dta"
loc translated_farmer "OMITTED-PII"

*Output data
loc recommendations_shc_control "07-soil-health-data/04-processed-data/ATAI_Soil_Tests_Results_Recommendations_SHC.dta"
loc shc_control "07-soil-health-data/04-processed-data/ATAI_SHC_Control.xlsx"


/* Merging file with all recommendations with treatment file and data only for treatment farmers for whom we have soil test recommendations */

import excel "`translated_farmer'", firstrow 
save recommendations_shc_control, replace

merge 1:1 uid using "`recommendations'"
keep if _m ==3

drop _merge

format mobile_number_f %9.0fc

/* Replacing numerals/expressions in english to Gujarati

 */

	foreach var of varlist ec_value_unit ph_value_unit  nitrogen_value_unit phosphorous_value_unit potash_value_unit iron_value_unit sulphur_value_unit zinc_value_unit {
	
		replace `var' = trim(`var')  
}
replace ec_value_unit = "ડેસીમલ/મી" if ec_value_unit == "dS/m"

	foreach var of varlist nitrogen_value_unit phosphorous_value_unit potash_value_unit {
	
		replace `var' = "કિગ્રા/હે" if `var' == "kg/ha"		
}
foreach var of varlist iron_value_unit sulphur_value_unit zinc_value_unit {
	
		replace `var' = "પીપીએમ" if `var' == "ppm"	
}
replace ec_level = "સામાન્ય" if ec_level == "Normal"
replace ec_level = "મધ્યમ ક્ષારીય" if ec_level == "Moderately Saline"
replace ec_level = "વધારે ક્ષારીય" if ec_level == "Highly Saline"

replace ph_level = "અમ્લીય" if ph_level == "Acidic"
replace ph_level = "સામાન્ય" if ph_level == "Neutral"
replace ph_level = "આલ્કલી" if ph_level == "Alkali"

replace irrigatedarea = "પિયત" if irrigatedarea == "Irrigated" 
replace irrigatedarea = "બિન પિયત" if irrigatedarea == "Un-Irrigated" 


/* label nutrient_level
           1   low/ઑછું
           2   medium/મધ્યમ
           3   high/વધારે
*/
**[VP] edited 24 May.
la def nutrient_level_g 1 "ઑછું" 2 "મધ્યમ" 3 "વધારે"

foreach var of varlist nitrogen_level phosphorous_level potash_level iron_level sulphur_level zinc_level {

		la val `var' nutrient_level_g
		decode `var', gen(`var'_str)
		order `var'_str, after(`var')
}
	

foreach var of varlist ph_value nitrogen_value phosphorous_value potash_value sulphur_value applicable_plot_size_str dap_bd_rec_ir_str dap_d2_rec_ir_str urea_bd_rec_ir_str urea_d2_rec_ir_str urea_d3_rec_ir_str urea_d4_rec_ir_str mop_bd_rec_ir_str zinc_sulphate_total_rec_ir_str urea_bd_rec_ur_str urea_d2_rec_ur_str gypsum_total_rec_ur_str {

        tostring `var', replace
		replace `var' = subinstr(`var',"0","૦",.)
		replace `var' = subinstr(`var',"1","૧",.)
		replace `var' = subinstr(`var',"2","૨",.)
		replace `var' = subinstr(`var',"3","૩",.)
		replace `var' = subinstr(`var',"4","૪",.)
		replace `var' = subinstr(`var',"5","૫",.)
		replace `var' = subinstr(`var',"6","૬",.)
		replace `var' = subinstr(`var',"7","૭",.)
		replace `var' = subinstr(`var',"8","૮",.)
		replace `var' = subinstr(`var',"9","૯",.)
}

foreach var of varlist ec_value zinc_value iron_value  {

        tostring `var', replace format(%04.2fc)
		replace `var' = subinstr(`var',"0","૦",.)
		replace `var' = subinstr(`var',"1","૧",.)
		replace `var' = subinstr(`var',"2","૨",.)
		replace `var' = subinstr(`var',"3","૩",.)
		replace `var' = subinstr(`var',"4","૪",.)
		replace `var' = subinstr(`var',"5","૫",.)
		replace `var' = subinstr(`var',"6","૬",.)
		replace `var' = subinstr(`var',"7","૭",.)
		replace `var' = subinstr(`var',"8","૮",.)
		replace `var' = subinstr(`var',"9","૯",.)
} 
tostring applicable_plot_size_str, replace
replace applicable_plot_size_str = subinstr(applicable_plot_size_str,"bigha","વીઘા",.)
replace applicable_plot_size_str = subinstr(applicable_plot_size_str,"acre","એકર",.)


foreach var of varlist dap_bd_rec_ir_str dap_d2_rec_ir_str urea_bd_rec_ir_str urea_d2_rec_ir_str urea_d3_rec_ir_str urea_d4_rec_ir_str mop_bd_rec_ir_str zinc_sulphate_total_rec_ir_str urea_bd_rec_ur_str urea_d2_rec_ur_str gypsum_total_rec_ur_str {

        tostring `var', replace
		replace `var' = subinstr(`var',"kg/ha","કિગ્રા/હે",.)
		replace `var' = subinstr(`var',"kg/bigha","કિલો/વીઘા",.)
		replace `var' = subinstr(`var',"kg/acre","કિલો/એકર",.)
}

drop f3_plot_marker
rename Plot_Name f3_plot_marker
	
export excel uid village block district ph_value ec_value ec_value_unit nitrogen_value nitrogen_value_unit nitrogen_level phosphorous_value phosphorous_value_unit phosphorous_level potash_value potash_value_unit potash_level zinc_value zinc_value_unit zinc_level iron_value iron_value_unit iron_level sulphur_value sulphur_value_unit sulphur_level name_f mobile_number_f applicable_plot_size_str f3_plot_marker f3_date irrigatedarea dap_bd_rec_ir_str dap_d2_rec_ir_str urea_bd_rec_ir_str urea_d2_rec_ir_str urea_d3_rec_ir_str urea_d4_rec_ir_str mop_bd_rec_ir_str zinc_sulphate_total_rec_ir_str urea_bd_rec_ur_str urea_d2_rec_ur_str gypsum_total_rec_ur_str ph_value_unit ec_level ph_level using "shc_control", firstrow(variables)

save "`recommendations_shc_control'", replace
