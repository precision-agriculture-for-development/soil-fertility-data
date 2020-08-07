clear all
version 14
cap log close
set more off

*************************************************
* NOTE: This file will not run because it depends on variables containing PII
*************************************************

*Main path
gl Main ""

*Input data
loc results "07-soil-health-data/04-processed-data/ATAI_Soil_Test_Results.dta"
loc baseline	"01-baseline/04-cleaned-data/merged/ATAI_baseline_all.dta" /*We will use the baseline survey to check the area units*/
loc treatment "01-baseline/04-cleaned-data/merged/ATAI_baseline_treatment_assignment_T.dta"

*Output data
loc recommendations "07-soil-health-data/04-processed-data/ATAI_Soil_Tests_Results_Recommendations.dta"

use "`results'"

merge 1:1 uid using "`baseline'" , keepusing(name_f mobile_number_f d1_1 f3_date applicable_plot_size applicable_plot_marker f3_plot_marker sampled_plot_irrigated_area)
list uid if _m == 1


gen irrigatedarea = "."
replace irrigatedarea = "Irrigated" if sampled_plot_irrigated_area > 0
replace irrigatedarea = "Un-Irrigated" if sampled_plot_irrigated_area == 0
 
la var irrigatedarea "Irrigation status of sampled plot in 2017"
la var name_f "name of farmer"
la var mobile_number_f "mobile number of farmer"

destring mobile_number_f,replace
 
/*
B03V30F0905	dropped from study sample bc already in KT service
B03V32F0944	dropped from study sample bc already in KT service
B03V32F0947	dropped from study sample bc already in KT service
B03V32F0970	dropped from study sample bc already in KT service
B03V37F1093	dropped from study sample bc already in KT service
B03V40F1182	from ajmer village, dropped from study sample
B03V40F1184	from ajmer village, dropped from study sample
B03V40F1189	from ajmer village, dropped from study sample
B04V55F1514	dropped from study sample bc already in KT service
B05V58F1619	from bela village, droppped because total farmers in village < 10
B05V65F1804	dropped from study sample bc already in KT service
B05V66F1840	dropped from study sample bc already in KT service
B05V67F1860	from khared village, dropped because total farmers in village < 10
B05V67F1877	from khared village, dropped because total farmers in village < 10
B05V68F1899	dropped because mobile number was duplicated
*/

keep if _m == 3
drop _m
decode d1_1, gen(area_units)


* 1. Base recommendations to use 
* hardcoded
* 1A. Irrigated(kg/ha)
	loc nitrogen_base_ir		240
	loc phosphorous_base_ir		50
	loc	potash_base_ir			150
	loc zinc_base_ir			20

* 1B. Unirrigated (kg/ha)
	loc nitrogen_base_ur		80
	loc	gypsum_base_ur			625

 
/*
2. Split Dosage Rule

2A. Irrigated Cotton
2A1. Nitrogen is recommended in 4 equal amount splits (at time of sowing (Basal), 1 month after sowing, 2 month after sowing and 3 month after sowing)
2A2. Phosphorus is recommended in 2 equal amount splits (at time of sowing and 1 month after sowing)
2A3. Potash and Zink Sulphate recommended entire amount in 1 dosage (at time of sowing)

2B. Un-Irrigated Cotton
2B1. Nitrogen is recommended in 2 equal amount splits (at time of sowing (Basal) and 1 month after sowing,)
2B2. Gypsum recommended entire amount in 1 dosage (at time of sowing)
2C. Calculate dose wise amount of nutrients required for Irrigated and Un-Irrigated Cotton.
*/

/*
3. Calculate Nutrient recommendation (N, P and K) based on soil test report.
     Rule: 
3A. If Nutrient Level LOW, then: Base Amount + 25 % of Base Amount
3B. If Nutrient Level MEDIUM, then: Base Amount
3C. If Nutrient Level HIGH, then Base Amount - 25 % of Base Amount

3D. For Irrigated Cotton Zink Sulphate fertilizer recommending based on Z level (Low, Medium, High)
•	If Z is Low then: Base Amount + 25 % of Base Amount 
•	If Z is Medium then: Base Amount
•	If Z is High then: Base Amount - 25 % of Base Amount

3E. For Un-Irrigated Cotton Gypsum recommending irrespective of nutrient level (common for all)
*/
	foreach n in nitrogen phosphorous potash zinc {
		
		gen	`n'_rec_ir = .
		replace `n'_rec_ir = ``n'_base_ir' * 1.25	if `n'_level == 1 /*low*/
		replace `n'_rec_ir = ``n'_base_ir'			if `n'_level == 2 /*medium*/
		replace `n'_rec_ir = ``n'_base_ir' * 0.75	if `n'_level == 3 /*high*/
		

		}
		
	gen	nitrogen_rec_ur = .
	replace nitrogen_rec_ur = `nitrogen_base_ur' * 1.25 if nitrogen_level == 1 /*low*/
	replace nitrogen_rec_ur = `nitrogen_base_ur' 		if nitrogen_level == 2 /*medium*/
	replace nitrogen_rec_ur = `nitrogen_base_ur' * 0.75 if nitrogen_level == 3 /*high*/
	
	
	
/*
4. Fertilizer Recommendation (Kg/Hectare)
	Fertilizer amount needs to be calculated based on amount of nutrient recommended and percent of nutrient contains of fertilizer

				Fertilizers	Nutrient content (%)
				
						Nitrogen	Phosphorus	Potash
1	Urea					46 %		X			X	
2	DAP						18%			46%			X
3	Murrate of Potash		X			X			60%
4	Zink Sulphate		Actual Fertilizer Amount as per recommendation
5	Gypsum				Actual Fertilizer Amount as per recommendation

4A. For Irrigated Cotton Urea, DAP and Murrate of Potash fertilizers recommending based on the levels (Low/Medium/High) of Nitrogen (N),
	Phosphorus (P) and Potash (K) nutrients respectively in the soil test report. 
4B. For Irrigated Cotton Zink Sulphate fertilizer recommending recommending based on Z level (Low, Medium, High)
4C. For Un-Irrigated Cotton Urea fertilizer recommending based on the level (Low/Medium/High) of Nitrogen (N) in the soil test report.
4D. For Un-Irrigated Cotton Gypsum recommending irrespective of nutrient level (common for all)

	The Amount of Urea is dependent on Amount of DAP as the DAP contains Nitrogen as well.
	Hence first we calculate the amount of DAP requirements ( for Phosphorus ) and adjust the amount of Urea (for Nitrogen) for Basal Application and Dose 2 
*/

/*
5. Calculate the Dosage wise Fertilizer Recommendations for Irrigated Cotton (Kg/Hectare)

5A: Calculate Urea and DAP Fertilizer requirement for Irrigated Cotton
There are 9 combinations for Urea and DAP (Depends on N and P levels): 
1. Phosphorus (Low)+Nitrogen (Low), 2. Phosphorus (Low)+Nitrogen (Medium), 3.Phosphorus (Low)+Nitrogen (High)
4. Phosphorus (Medium)+Nitrogen (Low), 5. Phosphorus (Medium)+Nitrogen (Medium), 6. Phosphorus (Medium)+Nitrogen (High)
7. Phosphorus (High)+Nitrogen (Low), 8. Phosphorus (High)+Nitrogen (Medium), 9.Phosphorus (High)+Nitrogen (High)
*/
	gen double dap_total_rec_ir	=	phosphorous_rec_ir / 0.46
	gen double dap_bd_rec_ir		=	dap_total_rec_ir/2
	gen double dap_d2_rec_ir		=	dap_total_rec_ir/2
	
	gen double urea_total_rec_ir	=	(nitrogen_rec_ir / 0.46) - (dap_total_rec_ir * 0.18)
	gen double urea_bd_rec_ir		=	((nitrogen_rec_ir/4) / 0.46) - (dap_bd_rec_ir * 0.18)
	gen double urea_d2_rec_ir		=	((nitrogen_rec_ir/4) / 0.46) - (dap_d2_rec_ir * 0.18)
	gen double urea_d3_rec_ir		=	((nitrogen_rec_ir/4) / 0.46) 
	gen double urea_d4_rec_ir		=	((nitrogen_rec_ir/4) / 0.46) 

/*
5B: Calculate Murrate of Potash fertilizer requirement for Irrigated Cotton
•	Murrate of Potash requirement calculate based on Potash (K) level (Low, Medium, High)
Table 5B1: Fertilizer Requirement for Irrigated cotton when Potash is (Low, Medium, High)
*/
	gen double mop_total_rec_ir	=	potash_rec_ir / 0.60
	gen double mop_bd_rec_ir		=	mop_total_rec_ir
/*
5C: Calculate Zink Fertilizer requirement for Irrigated Cotton
•	Zink Sulphate requirement calculate based on Zink (Z) level (Low, Medium, High)
Table 5C1: Zink Sulphate Requirement for Irrigated Cotton
*/
	gen double zinc_sulphate_total_rec_ir	=	zinc_rec_ir
	gen double zinc_sulphate_bd_rec_ir		=	zinc_sulphate_total_rec_ir
 
/*
6. Calculate the Dosage wise Fertilizer Recommendations for Un-Irrigated Cotton (Kg/Hectare)

6A: Calculate Urea Fertilizer requirement for Un-Irrigated Cotton Based on Nitrogen Level (Low, Medium, High)
*/
	gen double urea_total_rec_ur	=	nitrogen_rec_ur / 0.46
	gen double urea_bd_rec_ur		=	urea_total_rec_ur / 2 
	gen double urea_d2_rec_ur		=	urea_total_rec_ur / 2
/*
6B: Calculate Gypsum requirement for Un-Irrigated Cotton
	Gypsum  recommendation is 625 kg/ha (Irrespective of nutrients level)
*/

	gen double gypsum_total_rec_ur	=	`gypsum_base_ur'
	gen double gypsum_bd_rec_ur		=	`gypsum_base_ur'

/*	
7. Calculate All Fertilizer Requirements for different area units (Kg/Hectare, Kg/Acre and Kg/Vihga)
Unit Conversions: 
1 Hectare = 2.5 Acre
1 Hectare = 6.25 Bigha
1 Acre = 2.5 Bigha.
*/

* We are using the area units used by the farmer in the baseline survey
	foreach var of varlist nitrogen_rec_ir - gypsum_bd_rec_ur {
	
		replace `var' = `var' / 2.5		if area_units == "acre" 
		replace `var' = `var' / 6.25	if area_units == "bigha"
		
	}


	* Round values
	foreach var of varlist dap_total_rec_ir - gypsum_bd_rec_ur {
	
		replace `var' = round(`var',1)
		
		}
		
	*Label variables
	la var nitrogen_rec_ir				"Nitrogen recommendation for irrigated cotton"
	la var phosphorous_rec_ir			"Phosphorous recommendation for irrigated cotton"
	la var potash_rec_ir				"Potash recommendation for irrigated cotton"
	la var zinc_rec_ir					"Zinc recommendation for irrigated cotton"
	
	la var nitrogen_rec_ur				"Nitrogen recommendation for unirrigated cotton"
	
	la var dap_total_rec_ir				"DAP total recommendation for irrigated cotton"
	la var dap_bd_rec_ir				"DAP recommended basal dose for irrigated cotton"
	la var dap_d2_rec_ir				"DAP recommended dose 2 for irrigated cotton"
	la var urea_total_rec_ir			"Urea total recommendation for irrigated cotton"
	la var urea_bd_rec_ir				"Urea recommended basal dose for irrigated cotton"
	la var urea_d2_rec_ir				"Urea recommended dose 2 for irrigated cotton"
	la var urea_d3_rec_ir				"Urea recommended dose 3 for irrigated cotton"
	la var urea_d4_rec_ir 				"Urea recommended dose 4 for irrigated cotton"
	la var mop_total_rec_ir				"MOP total recommendation for irrigated cotton"
	la var mop_bd_rec_ir				"MOP recommended basal dose for irrigated cotton"
	la var zinc_sulphate_total_rec_ir	"Zinc Sulphate total recommendation for irrigated cotton"
	la var zinc_sulphate_bd_rec_ir		"Zinc Sulphate recommended basal dose for irrigated cotton"
	
	la var urea_total_rec_ur			"Urea total recommendation for unirrigated cotton"
	la var urea_bd_rec_ur				"Urea recommended basal dose for unirrigated cotton"
	la var urea_d2_rec_ur				"Urea recommended dose 2 for unirrigated cotton"
	la var gypsum_total_rec_ur			"Gypsum total recommendation for unirrigated cotton"
	la var gypsum_bd_rec_ur				"Gypsum recommended basal dose for unirrigated cotton"
	
	la var area_units					"Area units reported in baseline survey"

	 
/* Generate string variables for SHC for Recommendations and area units */
	foreach var of varlist dap_total_rec_ir - gypsum_bd_rec_ur  {
		
		tostring `var', gen(`var'_str)
		replace `var'_str = `var'_str + " kg/" + area_units
		
		}
	/* Round values of nitrogen, phosphorous, potash and sulphur levels to 0 decimal place */
	foreach var of varlist nitrogen_value phosphorous_value potash_value sulphur_value mobile_number_f {
	
		replace `var' = round(`var')
		
		}
	
	/* Generate string variables for SHC that combine Recommendations and area units */
	foreach var of varlist ec_value nitrogen_value phosphorous_value potash_value iron_value zinc_value sulphur_value {
		
		tostring `var', gen(`var'_unit)
		replace `var'_unit = "0" + `var'_unit  if `var' < 1
		}
		
	replace ec_value_unit = " dS/m"
	replace nitrogen_value_unit = " kg/ha"
	replace phosphorous_value_unit = " kg/ha"
	replace potash_value_unit = " kg/ha"
	replace iron_value_unit = " ppm"
	replace zinc_value_unit = " ppm"
	replace sulphur_value_unit = " ppm"
	
/* Generate unit for ph value. Leaving it blank because pH is reported as a level and not on continuous scale */
	
	gen ph_value_unit = ""
	replace ph_value_unit = "-"
 
la var ph_value_unit " Unit of pH Value"	
la var ec_value_unit " Unit of ec Value"
la var nitrogen_value_unit " Unit of nitrogen Value"
la var phosphorous_value_unit " Unit of phosphorus Value"
la var potash_value_unit " Unit of potash Value"
la var iron_value_unit " Unit of iron Value"
la var zinc_value_unit " Unit of zinc Value"
la var sulphur_value_unit " Unit of sulphur Value"

/* Generate string variables for applicable plot size that combine plot size and area units */

replace applicable_plot_size = round(applicable_plot_size,.1)

tostring applicable_plot_size, generate(applicable_plot_size_str)force
replace applicable_plot_size_str = applicable_plot_size_str + " " + area_units
		
		
	/* Generating variables for level of pH and EC. The levels are dependent on the values pH and EC reported in SHC. 
Reference document: Nutrient ranges and names.xlsx */

    gen	ec_level = "."
	replace ec_level = "Normal" if ec_value < 1
	replace ec_level = "Moderately Saline" if ec_value > 1 & ec_value <3
	replace ec_level = "Moderately Saline" if ec_value == 1
    replace ec_level = "Moderately Saline" if ec_value == 3
	replace ec_level = "Highly Saline" if ec_value >3 & ec_value <. /*[VP] edited in May 22: ec_value <. */

	gen	ph_level = "."
	replace ph_level = "Acidic" if ph_value < 6.5
	replace ph_level = "Neutral" if ph_value > 6.5 & ph_value <8.2
	replace ph_level = "Neutral" if ph_value == 6.5
    replace ph_level = "Neutral" if ph_value == 8.2
	replace ph_level = "Alkali" if ph_value >8.2 & ph_value <. /*[VP] edited in May 22: ph_value <. */

	la var ec_level "Level of ec in soil"
	la var ph_level "Level of pH in soil"
	la var f3_date "Month and year of Form3 survey"
	
	save "`recommendations'" , replace
	
	











