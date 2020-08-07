clear all
version 14
cap log close
set more off

/****************************************************************************														
Note: requires missings 
This file may not run because PII was removed 
****************************************************************************/

cd ""

// Input Data
	loc midline_data_day_1			"03-midline/02-raw-data/ATAI Midline 2018.dta"
	loc midline_data_new			"03-midline/02-raw-data/ATAI Mildine_2018_New.dta"
	loc fertilizer_other_bagsize	"03-midline/02-raw-data/Other_fertilizer_bagsize.dta"
	loc fertilizer_other_bagsize_2	"03-midline/02-raw-data/Other_fertilizer_bagsize_secondunit.dta"
	loc crop_yield 					"03-midline/02-raw-data/Crop yield data_clean.xls"
	loc additional_info				"03-midline/02-raw-data/ATAI_Midline_Add Info.dta"
	loc gypsum_data					"03-midline/02-raw-data/ATAI_Midline_Gypsum_quantities.dta"
	loc irrigation					"03-midline/02-raw-data/ATAI_Midline_Irrigation.xlsx"
	
// Output Data 	
	loc midline_data_clean			"03-midline/04-cleaned-data/ATAI_Midline_2018_Clean.dta"
	
// Irrigation verified Data
	*Revised information on irrigation status and land of the farmers that
	*replied yes to having irrigated their cotton crops in a3_1 but in a3_4 the size of the plot that was irrigated is zero.
	*We called this farmers again to verify the information
	import excel "`irrigation'", sheet("Sheet1") firstrow clear
	destring a3_1, replace
	destring a3_3, replace
	destring a3_4, replace
	
	tempfile irrigation
	save `irrigation'
	clear
	
//	Crop Yield Verified Data
	import excel "`crop_yield'", sheet("Sheet1") firstrow

	drop if uid == ""
	
	*a4 Cotton crop still standing
	replace a4 = strproper(trim(a4))
	replace a4 = "1" if a4 == "Yes"
	replace a4 = "0" if a4 == "No"
	
	*b1 Have started harvesting
	replace b1 = strproper(trim(b1))
	replace b1 = "1" if b1 == "Yes"
	replace b1 = "0" if b1 == "No"

	*b2_1 Month
	replace b2_1 = strproper(trim(b2_1))
	replace b2_1 = "1" if b2_1 == "Octomber"
	replace b2_1 = "2" if b2_1 == "November"
	replace b2_1 = "3" if b2_1 == "December"

	destring a4 - b4_1 , replace

	tempfile crop_yield
	save `crop_yield'
	clear
		
// Append survey data 
	use "`midline_data_day_1'"
	append using "`midline_data_new'"
	notes drop _all

// Labels
	la def yesno 0 No 1 Yes
	la def yesnoda 0 No 1 Yes .r "Does not answer"

// Area conversion rates

	/*
	1 hectare = 6.25 bigha
	1 acre = 2.5 bigha
	1 guntha = 0.04 bigha
	1 guntha = 0.06 bigha (1 bigha = 16 ha in the area) **check this
	*/

	loc acre_bigha = 2.5
	loc ha_bigha = 6.25	
	loc guntha_bigha = 0.04
	
	// Weight conversion rates

	/*
	1 maund = 20 kg
	1 quintal = 100 kg
	*/	
	
	loc maund_kg = 20
	loc quintal_kg = 100
	
//Corrections	
	
	*Changing unique farmer IDs for cases where they were incorrectly recorded by surveyor
	replace uid = "B04V53F1476" if uid == "B04V53F1479" & a1 == 10
	replace uid = "B01V06F0153" if uid == "B01V06F0152" & a1 == 11	
	
	*Dropping older data for cases where re-surveys were done
    drop if uid == "B01V03F0077" & date == "24-Nov-2018"
	drop if uid == "B01V05F0150" & date == "24-Nov-2018"
	drop if uid == "B02v21f0644" & date == "25-Oct-2018"
	drop if uid == "B03V27F0808" & date == "23-Oct-2018"
	drop if uid == "B06V77F2205" & date == "26-Oct-2018"
	drop if uid == "B03V33F0971" & date == "17-Nov-2018"
	drop if uid == "B04V44F1251" & date == "15-Nov-2018"
	drop if uid == "B02V18F0546" & date == "14-Nov-2018"
	drop if uid == "B03V27F0807" & date == "24-Oct-2018"
	drop if uid == "B03V36F1065" & date == "27-Oct-2018"
	drop if uid == "B03V39F1154" & date == "24-Oct-2018"
	drop if uid == "B03V39F1167" & date == "29-Oct-2018"
	drop if uid == "B01V70F1965" & date == "24-Oct-2018"
	
// Intro

	*Survey Date
	gen double survey_date = date(date,"DMY") , after(date)
	replace survey_date = date_a if date_v == 0	
	format survey_date %td
	la var survey_date "Date on which survey was done"
	drop date_a date_v date

	*Survey time
	replace time = time_a if time_v == 0
	gen double survey_time = clock(time,"hms"), after(time)
	drop time time_a time_v
	format survey_time %tcHH:MM:SS
	la var survey_time "Time in which survey was done"

	drop baseline_area_bigha baseline_area_acre baseline_area_hectare baseline_area_guntha
	drop basal_sowing basal_irrigation
	drop basal_area_bigha basal_area_acre basal_area_hectare basal_area_guntha
	drop treatment
	drop start2 start3 start4 start5 later reject_why reject_no
	drop deviceid subscriberid simid devicephonenum intronote start1
	drop note*
	drop formdef_version key submissiondate starttime endtime
	

// Section X PII

	*Farmer/Respondent details
	label var uid "Unique ID of farmer"
	replace uid = strupper(uid)
	replace name = x1_2_1 + " " + x1_2_2 + " " + x1_2_3 if x1_1 == 0
	replace name = strproper(name)
	label var name "Name of Midline respondent"
	drop x1_2_1 x1_2_2 x1_2_3
	label var x1_1 "Whether survey done with baseline respondent"

	*Relationship between midline respondent and baseline respondent
	replace x1_2_4 = "7" if x1_2_4 == ".o"
	replace x1_2_4 = "6" if x1_1 == 1
	replace x1_2_4 = "6" if x1_2_4_o == "Self"
	replace x1_2_4 = "6" if x1_2_4_o == "Pote"
	replace x1_2_4 = "6" if x1_2_4_o == "pote"
	replace x1_2_4 = "8" if uid =="B03V31F0927"
	replace x1_2_4 = "6" if uid =="B01V07F0179"
	replace x1_2_4 = "6" if uid =="B05V59F1642"
	replace x1_2_4 = "2" if uid =="B02V21F0633"
	replace x1_2_4 = "3" if uid =="B03V34F1012"
	replace x1_2_4 = "6" if uid =="B06V75F2142"	
	replace x1_2_4 = "6" if uid =="B03V37F1104"
	replace x1_2_4 = "6" if uid =="B06V76F2174"	
				
	label define relation 1 "spouse" 2 "parent" 3 "child" 4 "sibling" 5 "grand parent" 6 "self" 7 "other" 8 "Sharecropper" 9 "grand child"
	destring x1_2_4, replace
	label var x1_2_4 "Relation of midline respondent with baseline respondent"
	label values x1_2_4 relation

	*Gender
	replace gender = "1" if gender == "Male"
	replace gender = "0" if gender == "Female"
	destring gender, replace
	replace gender = x1_3_1 if x1_3 == 0
	la val gender x1_3_1
	label var gender "Gender of respondent"
	drop x1_3 x1_3_1

	*District, block, village
	destring district_code village_code block_code, replace
	replace district_code = x1_5_1 if x1_5== 0
	replace block_code = x1_6_1 if x1_6== 0
	replace village_code = x1_7_1 if x1_7== 0

	la val district_code x1_5_1
	la val block_code x1_6_1
	la val village_code x1_7_1

	decode district_code, gen(district_dc)
	decode block_code, gen(block_dc)
	decode village_code, gen(village_dc)

	replace district = district_dc if x1_5 == 0
	replace block = block_dc if x1_6 == 0
	replace village = village_dc if x1_7 == 0

	replace district = strproper(district)
	replace block = strproper(block)
	replace village = strproper(village)

	drop x1_5 x1_6 x1_7 x1_5_1 x1_6_1 x1_7_1 district_dc block_dc village_dc

	label var district		"District"
	label var district_code "District Code"
	label var block 		"Block"
	label var block_code 	"Block Code"
	label var village 		"Village"
	label var village_code	"Village Code"

	*Mobile number
	replace mobile_number = x1_4_1 if x1_4== 0
	drop x1_4_1 x1_4_2

	label var mobile_number "Mobile number of midline respondent"
	label var x1_4 "Whether mobile number same as that in baseline"
	
	*Reject
	replace reject = 0 if reject == .
	label var reject "Whether farmer refused to be surveyed"

	*Surveyor & Supervisor
	label var x2_1 "Name of surveyor"
	label var x2_2 "Name of supervisor"

	*Consent
	drop start6
	label var consent1 "Whether farmer gave consent for the survey"
	rename consent1 consent
	label var consent_no "Why farmer did not give consent for the survey"
	
	rename x1_1		baseline_respondent
	rename x1_2_4	relation_baseline_respondent
	rename x1_2_4_o relation_other
	rename x1_4 	baseline_mobile
	rename x2_1		surveyor
	rename x2_2		supervisor
		
// Section A Plot information

	*Plot information
	recode a1 (-888 =.d)
	
	label define area_unit 1 "bigha" 2 "acre" 3 "hectare" 4 "guntha"
	label var a1 "Area of the surveyed plot"
	label var a1_1 "Unit of area of surveyed plot" 
	destring a1_1, replace
	label value a1_1 area_unit

	drop a1_1_id a1_1_lbl temp0

	destring a1_3, replace
	label var a1_3 "Area of surveyed plot in guntha (if any)"
	
	**Units incorrectly recorded by surveyor **
	replace a1_1 = 2 if uid == "B01V07F0178"
	replace a1_1 = 2 if uid == "B01V08F0219"
	replace a1_1 = 2 if uid == "B01V09F0252"
	replace a1_1 = 2 if uid == "B01V09F0254"
	replace a1_1 = 2 if uid == "B02V14F0408"
	replace a1_1 = 2 if uid == "B02V23F0693"
	replace a1_1 = 2 if uid == "B03V31F0929"
	replace a1_1 = 2 if uid == "B04V53F1460"
	replace a1_1 = 1 if uid == "B03V28F0830"		
	
	gen plot_area_bigha = a1 , before(a1)
	replace plot_area_bigha = a1 * `acre_bigha'		if a1_1 == 2
	replace plot_area_bigha = a1 * `ha_bigha' 		if a1_1 == 3
	replace plot_area_bigha = a1 * `guntha_bigha'	if a1_1 == 4
	replace plot_area_bigha = plot_area_bigha + (a1_3 * `guntha_bigha' ) if a1_2 == 1
	
	la var plot_area_bigha "Plot area in bigha"

	drop area_bigha area_guntha
	destring area_compare, replace
	label var area_compare "Difference in area of surveyed plot b/w baseline and midline survey (in bigha)"
	label var a1_1_2 "Reason for difference between area of surveyed plot b/w baseline and midline survey"

	drop check_area
	
	*Sowing Information
	label var a2 "Whether farmer sowed cotton in surveyed plot in 2018"
	
	*No sowing
	la def no_sowing	1	"Lack of water" ///
						2	"Late rains"	///
						3	"Changed crops"	///
						4	"Gave land on rent" ///
						5	"Left land fallow" ///
						.o	"Others"
						
	qui labellist no_sowing
	loc values `r(no_sowing_values)'

		foreach v of local values {
			local x = subinstr("`v'",".","",1) 
			gen a2_2_r`x'= regexm(a2_2,"`v'")
			local lbl : label no_sowing `v'
			la var a2_2_r`x' "Reason for not sowing cotton: `lbl'"
			la val a2_2_r`x' yesno
		}

	order a2_2_r1 - a2_2_ro , after(a2_2)

	drop check_sowing 
	label var a2_6_1 "Reason for difference in sowing status between basal and midline survey"


	label var a2_3 "Month in which farmer started sowing cotton in surveyed plot"
	destring a2_3, replace
	
	la def month_sowing 5 May ///
						6 June ///
						7 July ///
						8 August ///
						.o	Others
						
	la val a2_3 month_sowing
	
	replace a2_3 = 5 if a2_3_o == "May"
	
	destring a2_4, replace
	lab var a2_4 "Whether farmer sowed cotton in entire area of surveyed plot"
	lab val a2_4 yesno
	drop temp1
	
	destring a2_4_1, replace
	replace a2_4_1 = a1 if a2_4 == 1 /*Sowed cotton in the full area of plot*/ 
	lab var a2_4_1 "Size of surveyed plot on which farmer sowed cotton in ${a1_1_lbl}"
	recode a2_4_1 (-888=.d)
	drop temp2
	
	destring a2_4_1_g, replace
	replace a2_4_1_g = a1_3 if a2_4 == 1  /*Sowed cotton in the full area of plot*/
	label var a2_4_1_g "Size of surveyed plot in guntha in which cotton was sown"
	replace a2_4_1_g = -888 if a2_4_1_g == 888
	recode a2_4_1_g (-888 = .d)

	drop area_bigha_s area_guntha_s 
	
	*Cotton area in bigha
	gen cotton_area_bigha = plot_area_bigha					if a2_4 == 1 , before(a2_4_1) /*Sow cotton in whole plot*/
	replace cotton_area_bigha = a2_4_1						if a1_1 == 1 & a2_4 == 0 /*Didnt sow cotton in the whole plot & bigha*/
	replace cotton_area_bigha = a2_4_1 * `acre_bigha'		if a1_1 == 2 & a2_4 == 0 /*Didnt sow cotton in the whole plot & acre*/
	replace cotton_area_bigha = a2_4_1 * `ha_bigha' 		if a1_1 == 3 & a2_4 == 0 /*Didnt sow cotton in the whole plot & ha*/
	replace cotton_area_bigha = a2_4_1 * `guntha_bigha'		if a1_1 == 4 & a2_4 == 0 /*Didnt sow cotton in the whole plot & guntha*/
	replace cotton_area_bigha = 0							if a2 == 0 /*Didnt sow cotton*/
	replace cotton_area_bigha = cotton_area_bigha + ( a2_4_1_g * `guntha_bigha') if a1_2 == 1 & a2_4 == 0 /*Didnt sow cotton in the whole plot & uses guntha as a secondary unit */
	la var cotton_area_bigha "Cotton area in bigha"
	
	label var area_compare_s "Difference in area of cotton b/w basal and midline survey (in bigha)"
	label var a2_4_2 "Reason for difference between area of cotton b/w basal and midline survey"
	drop check_area_2
	
	*Irrigation
	*Adding the revised information on irrigation status and land 
	merge 1:1 uid using `irrigation' , update replace nolabel nogen

	replace a3_3 = . if a3_1 == 0
	replace a3_4 = . if a3_1 == 0
	
	la var a3_1 "Whether cotton crop in surveyed plot was irrigated"
	drop check_irrigation
	label var a3_1_1 "Reason for difference in irrigation status in surveyed plot between basal and midline survey"
	
	*Irrigation source
	la def irrigation 	1	rainfall ///
						2	"underground water" ///
						3	"nearby water/dam" ///
						4	canal ///
						.o	other
	
	qui labellist irrigation
	loc values `r(irrigation_values)'

		foreach v of local values {
			local x = subinstr("`v'",".","",1) 
			gen a3_2_r`x'= regexm(a3_2,"`v'")
			local lbl : label irrigation `v'
			la var a3_2_r`x' "Irrigation source: `lbl'"
			la val a3_2_r`x' yesno
		}

	order a3_2_r1 - a3_2_ro , after(a3_2)
		
	*Irrigated area
	replace a3_4 = -888 if a3_4 == 888
	recode a3_4 a3_4_g (-888 = .d)
	gen irrigated_area_bigha = . , before(a3_4)
	replace irrigated_area_bigha = cotton_area_bigha 		if a3_3 == 1 
	replace irrigated_area_bigha = a3_4						if a1_1 == 1 & a3_3 == 0 /*Didnt irrigate the whole plot & bigha*/
	replace irrigated_area_bigha = a3_4 * `acre_bigha'		if a1_1 == 2 & a3_3 == 0 /*Didnt irrigate the whole plot & acre*/
	replace irrigated_area_bigha = a3_4 * `ha_bigha' 		if a1_1 == 3 & a3_3 == 0 /*Didnt irrigate the whole plot & ha*/
	replace irrigated_area_bigha = a3_4 * `guntha_bigha'	if a1_1 == 4 & a3_3 == 0 /*Didnt irrigate the whole plot & guntha*/
	replace irrigated_area_bigha = 0						if a3_1 == 0 /*Didnt irrigate cotton*/
	replace irrigated_area_bigha = irrigated_area_bigha + (a3_4_g * `guntha_bigha') if a1_2 == 1 & a3_3 == 0 /* Didnt irrigate the whole plot & uses guntha as a secondary unit*/
	la var irrigated_area_bigha "Irrigated cotton area in bigha"	
	
	la var a3_5 "Applied optimal amount of water from irrigation to cotton crop"

	*Cotton still standing
	la var a4 "Cotton crop still standing"
	
	*Crop failure event
	la def crop_event	1	"drought/lack of water" ///
						2	flood ///
						3	"hail storm" ///
						4	lightening ///
						5	rainstorm ///
						6	insects ///
						7	rodents ///
						8	"animals eating crops" ///
						9	theft ///
						10	fire ///
						.o	other ///
						.d	"does not know/remember"
	
	quietly labellist crop_event
	loc values `r(crop_event_values)'
	
	tempvar a4_1
	gen `a4_1' = " " + a4_1 + " "

	foreach v of local values {
		local x = subinstr("`v'",".","",1) 
		gen a4_1_r`x' = (strpos(`a4_1', " `v' ")> 0)
		local lbl : label crop_event `v'
		la var a4_1_r`x' "Reason for crop failure: `lbl'"
		note a4_1_r`x' : "What was the reason for complete failure of the crop?"
		la val a4_1_r`x' yesno
	}
	order a4_1_r1 - a4_1_ro , after(a4_1)
	drop `a4_1'
	
	**Correction in data
	replace a4 = 1 if uid == "B06V76F2164"
	replace a4 = 1 if uid == "B06V77F2203"
	replace a4 = 1 if uid == "B06V76F2161"
	replace a4 = 1 if uid == "B06V73F2059"
	replace a4 = 1 if uid == "B06V72F2041"
	replace a4 = 1 if uid == "B06V72F2036"
	replace a4 = 1 if uid == "B06V72F2040"
	replace a4 = 1 if uid == "B06V73F2046"
	replace a4 = 1 if uid == "B06V76F2174"
	replace a4 = 1 if uid == "B06V76F2158"
	replace a4 = 1 if uid == "B06V76F2156"
	replace a4 = 0 if uid == "B05V62F1715" //Changing crop fail and harvest data where incorrectly recorded by surveyor
		
// Section B Expected Yield and Production Shocks

	replace b1 = 1 if uid == "B06V76F2164"
	replace b1 = 1 if uid == "B06V77F2203"
	replace b1 = 1 if uid == "B06V76F2161"
	replace b1 = 1 if uid == "B06V73F2059"
	replace b1 = 1 if uid == "B06V72F2041"
	replace b1 = 1 if uid == "B06V72F2036"
	replace b1 = 1 if uid == "B06V72F2040"
	replace b1 = 1 if uid == "B06V73F2046"
	replace b1 = 1 if uid == "B06V76F2174"
	replace b1 = 1 if uid == "B06V76F2158"
	replace b1 = 1 if uid == "B06V76F2156"

	replace b4_1 = "2" if uid == "B06V76F2164"
	replace b4_1 = "2" if uid == "B06V77F2203"
	replace b4_1 = "2" if uid == "B06V76F2161"
	replace b4_1 = "2" if uid == "B06V73F2059"
	replace b4_1 = "2" if uid == "B06V72F2041"
	replace b4_1 = "2" if uid == "B06V72F2036"
	replace b4_1 = "2" if uid == "B06V72F2040"
	replace b4_1 = "2" if uid == "B06V73F2046"
	replace b4_1 = "2" if uid == "B06V76F2174"
	replace b4_1 = "2" if uid == "B06V76F2158"
	replace b4_1 = "2" if uid == "B06V76F2156"

	replace b4 = 110 if uid == "B06V76F2164"
	replace b4 = 175 if uid == "B06V77F2203"
	replace b4 = 25 if uid == "B06V76F2161"
	replace b4 = 100 if uid == "B06V73F2059"
	replace b4 = 60 if uid == "B06V72F2041"
	replace b4 = 70 if uid == "B06V72F2036"
	replace b4 = 250 if uid == "B06V72F2040"
	replace b4 = 30 if uid == "B06V73F2046"
	replace b4 = 60 if uid == "B06V76F2174"
	replace b4 = 250 if uid == "B06V76F2158"
	replace b4 = 50 if uid == "B06V76F2156"

	destring b4_1, replace
	
	merge m:1 uid using `crop_yield' , update replace nolabel nogen
	*b3 was skipped when b1 was equal to 1
	replace b3 = "" if b1 == 1
	replace b3_o = "" if b1 == 1

	*Harvest
	//Changing crop fail and harvest data where incorrectly recorded by surveyor
	replace b1 = . if uid == "B05V62F1715"
	replace b3 = "" if uid == "B05V62F1715"
	
	*Entered incorrectly in the verified data
	replace b4_1 = 2 if uid == "B03V29F0869" | uid == "B03V29F0877" | uid == "B03V30F0896" | uid == "B03V31F0915"

	la var b1 "Have started harvesting"

	*Month
	replace b2_1 = b2_1 + 9
	la def month 9 September 10 October 11 November 12 December
	la val b2_1 month
	
	*Harvest
	la def harvest_due	1	"5 days from today" ///
						2	"10 days from today" /// 
						3	"15 days from today" ///
						4	"20 days from today" ///
						.o	other
	destring b3, replace
	la val b3 harvest_due
	
	*Expected cotton quantity
	replace b4 = -888 if b4 == 888
	recode b4 (-888 = .d)
	
	
	la def weight_unit	1	kg ///
						2	maund ///
						3	quintal ///
						4	pula ///
						.d	"does not know/remember"
						
	destring b4_1, replace
	la val b4_1 weight_unit
	
	gen expected_yield_kg = . , before(b4)
	replace expected_yield_kg = b4 					if b4_1 == 1
	replace expected_yield_kg = b4 * `maund_kg'		if b4_1 == 2
	replace expected_yield_kg = b4 * `quintal_kg'	if b4_1 == 3
	*replace expected_yield_kg = b4					if b4_1 == 4
	replace expected_yield_kg = 0					if b4 == 0
	la var expected_yield_kg "Expected cotton yield in kg"
	
	drop b4 b4_1

	*Crop Loss
	destring b5, replace
	la val b5 yesnoda
	la var b5		"In the Kharif season of 2018, did you face any crop loss"
	
	*Please select events due to which you faced crop loss	
	quietly labellist crop_event
	loc values `r(crop_event_values)'
		
	tempvar b5_1
	gen `b5_1' = " " + b5_1 + " "
	local n = 1
	foreach v of local values {
		local x = subinstr("`v'",".","",1) 
		gen b5_1_r`x' = (strpos(`b5_1', " `v' ")> 0) if b5_1 != ""
		local lbl : label crop_event `v'
		la var b5_1_r`x' "Crop event: `lbl'"
		la val b5_1_r`x' yesno
		
		if `n' <= 10 {
			rename b5_2_`n' b5_2_r`x'
			la var b5_2_r`x' "Month of: `lbl'"
			note b5_2_r`x' : "What was the month of `lbl'?"
			}
		else if `n' == 12 {
			rename b5_2_11 b5_2_ro
			la var b5_2_ro "Month of: other"
			note b5_2_ro : "What was the month of other crop event?"
			}
			
		local n = `n' + 1
	}
	
	order b5_1_r1 - b5_1_ro , after(b5_1)
	drop `b5_1' b5_1
	drop b5_1_r_count b5_1_id_*	b5_1_lbl_*
	
	*Quantity lost
	recode b5_3 (-888 = .d)
	
	*Unit of quantity lost
	la def loss_unit	1 kg ///
						2	maund ///
						3	quintal ///
						4	pula ///
						5	percentage ///
						.o	other
	destring b5_3_1, replace
	la val b5_3_1 loss_unit	
		
	*Rename variables	
	rename b1		harvesting_started
	rename b2_1		harvesting_month
	rename b2_2		harvesting_week
	rename b3		expected_harvesting_time
	rename b3_o		expected_harvesting_time_o
	rename b5		crop_loss
	rename b5_1_*	crop_loss_*
	rename b5_2_*	crop_loss_month_*
	rename b5_3		crop_loss_quantity
	rename b5_3_1	crop_loss_unit
	rename b5_3_1_o crop_loss_unit_o


// Section C Cotton Seed Use

	*Seed
	la def cotton_seed 	1 short ///
						2 medium ///
						3 long
	quietly labellist cotton_seed
	loc seed_values `r(cotton_seed_values)'
	
	la def seed_use	1 "purchased new seeds" ///
				2 "reused old seeds" ///
				3 "purchased and reused" ///
				.d	"does not know/remember"
	quietly labellist seed_use
	loc use_values `r(seed_use_values)'
	
	la def seed_weight	1	kilogram ///
						2	gram ///
						3	packet ///
						.d	"does not know/remember"
						
	la def seed_packet  1 "450 grams" ///
						2	"500 grams" ///
						3	"550 grams" ///
						.o	other

	la def btseed 	1	BT ///
					2	"Non-BT" ///
					.o	other ///
					.d	"does not know/remember"

	
	foreach v of local seed_values {
	
		gen c1_r`v'= regexm(c1,"`v'") if a2 == 1
		local lbl : label cotton_seed `v'
		la var c1_r`v' "Used `lbl' seeds"
		la val c1_r`v' yesno
		
		*Seed use
		la var c2_`v' "Did you purchase `lbl' seeds of the variety did you reuse old seeds for cotton plot"
		
		tempvar c2_`v'
		gen `c2_`v'' = " " + c2_`v' + " "
		foreach u of local use_values {
			local x = subinstr("`u'",".","",1) 
			gen c2_`v'_r`x' = (strpos(`c2_`v'', " `u' ")> 0)
			local ulbl : label seed_use `u'
			la var c2_`v'_r`x' "Seeds `lbl': `ulbl'"
			la val c2_`v'_r`x' yesno
		}
		
		drop `c2_`v''
		
		order c2_`v'_r1 - c2_`v'_rd, after(c2_`v')
		
		*Quantity
		destring c3_`v' , replace
		lab var c3_`v' "Quantity of `lbl' seeds"
		drop temp3_`v'
		
		*Units
		destring c3_1_`v', replace
		la val c3_1_`v' seed_weight
		la var c3_1_`v' "Units of `lbl' seeds"
		
		la var c3_1_o_`v' "Other units of `lbl' seeds"
		
		*Seeds packet
		destring c3_2_`v', replace
		la val c3_2_`v' seed_packet
		la var c3_2_`v'	"Size of `lbl' seeds packet"
		
		*Other size of packet
		la var c3_2_o_`v' "Other size of `lbl' seeds packet"
		
		tempvar other_size_units 
		gen `other_size_units' = 2 if c3_2_`v' == .o
		replace `other_size_units' = 1 if regexm(c3_2_o_`v',"[Kk]g|[Kk]ilogram[s]|[Kk.]")
		
		tempvar other_size
		gen `other_size' = regexs(0) if regexm(c3_2_o_`v', "[0-9]+")
		destring `other_size',  replace
		replace `other_size' = `other_size' / 1000 if `other_size_units' == 2 /*g*/
		
		gen `lbl'_seeds_kg = . , before(c3_`v')
		replace `lbl'_seeds_kg = c3_`v'					if c3_1_`v' == 1 /* kg */		
		replace `lbl'_seeds_kg = c3_`v' / 1000			if c3_1_`v' == 2 /* g */
		replace `lbl'_seeds_kg = c3_`v' * 0.45 			if c3_1_`v' == 3 & c3_2_`v' == 1 /* 450g packet */
		replace `lbl'_seeds_kg = c3_`v' * 0.50 			if c3_1_`v' == 3 & c3_2_`v' == 2 /* 450g packet */
		replace `lbl'_seeds_kg = c3_`v' * 0.55 			if c3_1_`v' == 3 & c3_2_`v' == 3 /* 450g packet */
		replace `lbl'_seeds_kg = 0						if c3_`v' == 0 
		replace `lbl'_seeds_kg = c3_`v' * `other_size'	if c3_2_`v' == .o /* Other size of seed packet */
		
		*Drop variables used to calculate quantities in kg
		drop c3_`v' c3_1_`v' c3_2_`v' c3_2_o_`v' `other_size_units' `other_size'
		
		la var `lbl'_seeds_kg "`lbl' seeds used in kg"
		
		*BT seeds
		destring c4_`v', replace
		la val c4_`v' btseed
		la var c4_`v' "Used BT seed or non-BT `lbl' seeds"
		
		drop c1_id_`v' c1_lbl_`v'
		
	}
	
	order c1_r1 - c1_r3, after(c1)
	drop c1
	
	drop c2_1 c2_2 c2_3

	*Drop all missing
	drop c4_o_1 c4_o_2 c4_o_3
	
	*Drop all constant in c2 seed use
	drop c2_*_r3 c2_*_rd
	
	*Drop other unit of seed quantity never reached because there wasnt an option for "other" in the form.
	drop c3_1_o_1 c3_1_o_2 c3_1_o_3
	
	*Drop all missing variables due to a typo in the repeat count on the form design.
	drop c1_id_4 - c4_o_11
	
	*Drop ODK count variable
	drop c1_var_count
	
	*Rename variables
	foreach v of local seed_values {
		local lbl : label cotton_seed `v'
		rename c1_r`v'	used_`lbl'_seeds
		rename c4_`v'	used_bt_`lbl'_seeds
		rename c2_`v'_r1 purchased_`lbl'_seeds
		rename c2_`v'_r2 reused_`lbl'_seeds
	}
	
	
// Section D Compost and Fertilizer Usage

	*Replace data as -888 for where mistakenly endtered as 888
    replace d5_2 = -888 if d5_2 == 888 & uid == "B06V81F2331"
	replace d6_c_2 = "-888" if d6_c_2 == "888" & uid == "B06V81F2331"
	replace d5_5 = -888 if d5_5 == 888 & uid == "B06V81F2331"
	replace d6_c_5 = "-888" if d6_c_5 == "888" & uid == "B06V81F2331"
	
	foreach var of varlist d4_16 - d16_1_o_6_16 {

		capture confirm numeric variable `var'
        if !_rc {
			replace `var' = . if uid == "B05V64F1794"
        }
		else {
			replace `var' = "" if uid == "B05V64F1794"
		}
	}
			
	*Add fertilizers additonal info
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 {
		destring d5_1_`x', replace
		destring d5_2_`x', replace
		destring d5_6_`x', replace
		destring d5_7_`x', replace
	}

	*Corrections in fertilizer price data	
	replace d5_1_1 = 2 if uid == "B04V49F1380"
	replace d5_2_1 = 3 if uid == "B04V49F1380"
	replace d5_1_1 = 2 if uid == "B05V61F1698"
	replace d5_2_1 = 3 if uid == "B05V61F1698"
	replace d5_1_1 = 2 if uid == "B04V49F1390"
	replace d5_2_1 = 3 if uid == "B04V49F1390"
	replace d5_1_1 = 2 if uid == "B03V32F0955"
	replace d5_2_1 = 2 if uid == "B03V32F0955"
	replace d5_6_1 = 2 if uid == "B01V04F0101"
	replace d5_7_1 = 2 if uid == "B01V04F0101"
	replace d5_1 = 270 if uid == "B01V10F0295"
	replace d5_1 = 270 if uid == "B02V19F0591"
	replace d5_1 = 270 if uid == "B03V36F1074"
	replace d5_6_1 = 2 if uid == "B02V21F0630"
	replace d5_7_1 = 2 if uid == "B02V21F0630"
	replace d5_1 = 270 if uid == "B03V30F0895"
	replace d5_1 = 270 if uid == "B05V63F1750"
	replace d5_1 = 270 if uid == "B01V05F0128"
	replace d5_1 = 250 if uid == "B03V37F1092"
	replace d5_1_1 = 2 if uid == "B02V14F0417"
	replace d5_2_1 = 2 if uid == "B02V14F0417"
	replace d5_1_1 = 2 if uid == "B05V64F1798"
	replace d5_2_1 = 3 if uid == "B05V64F1798"
	replace d5_1_1 = 2 if uid == "B04V52F1451"
	replace d5_2_1 = 2 if uid == "B04V52F1451"
	replace d5_1_1 = 2 if uid == "B05V64F1794"
	replace d5_2_1 = 2 if uid == "B05V64F1794"
	replace d5_1_1 = 2 if uid == "B06V80F2288"
	replace d5_2_1 = 3 if uid == "B06V80F2288"
	
	replace d5_1_2 = 2 if uid == "B02V14F0413"
	replace d5_2_2 = 3 if uid == "B02V14F0413"
	replace d5_1_2 = 2 if uid == "B01V09F0257"
	replace d5_2_2 = 3 if uid == "B01V09F0257"
	replace d5_2_2 = 3 if uid == "B01V04F0112"
	
	replace d5_2_3 = 3 if uid == "B01V04F0103"
	replace d5_1_3 = 2 if uid == "B04V49F1380"
	replace d5_2_3 = 3 if uid == "B04V49F1380"
	replace d5_1_3 = 2 if uid == "B03V27F0818"
	replace d5_2_3 = 3 if uid == "B03V27F0818"
	replace d5_1_3 = 3 if uid == "B03V34F1015"
	replace d5_1_3 = 2 if uid == "B01V03F0090"
	replace d5_2_3 = 3 if uid == "B01V03F0090"
	replace d5_1_3 = 3 if uid == "B03V34F1011"
	replace d5_1_3 = 3 if uid == "B03V27F0823"
	replace d5_3 = 1220 if uid == "B04V46F1328"
	replace d5_3 = 1900 if uid == "B03V35F1038"
	replace d5_1_3 = 2 if uid == "B05V62F1734"
	replace d5_2_3 = 3 if uid == "B05V62F1734"
	replace d5_1_3 = 2 if uid == "B05V64F1798"
	replace d5_2_3 = 3 if uid == "B05V64F1798"
	replace d5_1_3 = 2 if uid == "B05V64F1794"
	replace d5_2_3 = 3 if uid == "B05V64F1794"
	replace d5_1_3 = 2 if uid == "B03V29F0870"
	replace d5_2_3 = 3 if uid == "B03V29F0870"
	
	replace d5_1_o_13 = "1" if uid == "B03V34F1015"
	replace d5_1_o_16 = "1" if uid == "B03V28F0843"
	replace d5_1_o_16 = "5" if uid == "B05V57F1585"
	replace d5_1_o_16 = "1000" if uid == "B05V65F1811"
	replace d5_1_o_17 = "1" if uid == "B03V33F0984"
	
	*** Correcting data entered under 'other size of fertilizer bag' 	
	replace d4_2_o_11 = "10" if d4_2_o_11 == "10 kg"
	replace d4_2_o_11 = "1" if d4_2_o_11 == "1kg"
	replace d4_2_o_11 = "5" if d4_2_o_11 == "5kg"
	replace d4_2_o_13 = "0" if d4_2_o_13 == "1 kg"
	replace d4_2_o_15 = "3" if d4_2_o_15 == "3kg"
	replace d4_2_o_15 = "5" if d4_2_o_15 == "5 kg"
	replace d4_2_o_15 = "5" if d4_2_o_15 == "5kg"
	replace d4_2_o_16 = "3" if d4_2_o_16 == "3 kg"
	replace d4_2_o_16 = "3" if d4_2_o_16 == "3kg"
	replace d4_2_o_16 = "5" if d4_2_o_16 == "5 KG beg"
	replace d4_2_o_16 = "5" if d4_2_o_16 == "5 kg"	
	replace d4_2_o_17 = "10" if d4_2_o_17 == "10 kg"
	replace d4_2_o_17 = "3" if d4_2_o_17 == "3kg"
	replace d4_2_o_17 = "40" if d4_2_o_17 == "40 KG beg"
	replace d4_2_o_17 = "5" if d4_2_o_17 == "5 kg"
		
	*Bag sizes
	forvalues i = 1/20 {
		foreach j in 1 2 6 7 {

			replace d5_`j'_o_`i' = regexr(d5_`j'_o_`i',"kilogarm","")
			replace d5_`j'_o_`i' = regexr(d5_`j'_o_`i',"[Kk]g|[Kk]ilogram[s]|[Kk.]","")
			replace d5_`j'_o_`i' = regexr(d5_`j'_o_`i',"ilo","")
			replace d5_`j'_o_`i' = regexr(d5_`j'_o_`i',".g","")
			replace d5_`j'_o_`i' = regexr(d5_`j'_o_`i',"[beg]","")

		}
	}
	
	*Add revised data on fertilizers
	merge m:1 uid using "`additional_info'", update replace nolabel nonotes nogen

	*Merging cleaned data of 'other fertilizer bagsizes'
	merge m:1 uid using "`fertilizer_other_bagsize'", update replace nolabel nonotes nogen
	merge m:1 uid using "`fertilizer_other_bagsize_2'", update replace nolabel nonotes nogen
	
	*Merging with Gypsum data to fix two cases where fertilizer application was entered as 16. Sulphur instead of 17. Other (Gypsum)
	merge m:1 uid using "`gypsum_data'", update replace nolabel nonotes nogen

	
	*Corrections in fertilizer data (AK-5-12-18)
	replace d4_3_3 = "0" if uid == "B01V09F0257"  //surveoyr had entered price data in 'second unit of fertilizer' section
	replace d4_4_3 = "" if uid == "B01V09F0257"
	replace d4_4_1_3 = "" if uid == "B01V09F0257"
	replace d4_4_2_3 = "" if uid == "B01V09F0257"
	
	replace d8_2_1 = 1 if uid == "B04V46F1323" //surveyor entered bagsize instead of number of bags

	replace d4_3 = "3" if uid == "B05V60F1674" //surveyor entered 33 bags instead of 3 bags
	replace d4_1_3 = "5"  if uid == "B05V60F1674" //surveyor selected option of 'kilogram' instead of 'bag'
	replace d4_2_3 = "3"  if uid == "B05V60F1674" 
	replace d8_1_3 = 3 if uid == "B05V60F1674" //surveyor entered 33 bags instead of 3 bags
	
	replace d8_1_1 = 1 if uid == "B04V45F1291" // surveyor entered bagsize instead of number of bags
	replace d8_2_1 = 1 if uid == "B04V45F1291" // surveyor entered bagsize instead of number of bags

	replace d8_1_11 = .5 if uid == "B03V34F1015" // surveyor entered data in grams instead of kilograms
	replace d8_2_11 = .5 if uid == "B03V34F1015" // surveyor entered data in grams instead of kilograms
	
	replace d4_13 = "1" if uid == "B03V27F0823" // surveyor entered NPK combination instead of number of bags
	
	replace d4_17 = "20" if uid == "B02V16F0493" // surveyor entered fertilizer use for the entire plot instead of cotton area
	replace d8_1_17 = 20 if uid == "B02V16F0493" // surveyor entered fertilizer use for the entire plot instead of cotton area
	
	replace d8_1_1_15 = "1" if uid == "B02V21F0639" // surveyor entered bag instead of kilogram
	
	replace d4_17 = "5" if uid == "B03V34F1008"
	replace d8_1_17 = 5 if uid == "B03V34F1008"
	
	replace d4_1_17 = "1" if uid == "B03V35F1038" //surveyor entered mililiter as fertilizer quantity uint instead of kilo

	replace d8_1_1_1_5 = "3" if uid == "B06V80F2286" //bagsize details were missing
	replace d8_1_1_1_5 = "3" if uid == "B06V80F2305" //bagsize details were missing

	replace d4_15 = "1" if uid == "B01V07F0194" // surveyor had entered twice of the amount
	replace d8_1_15 = 0.5 if uid == "B01V07F0194"

	replace d4_15 = "1" if uid == "B01V08F0221" // surveyor had entered twice of the amount
	replace d8_1_15 = 0.5 if uid == "B01V08F0221"
	
	replace d4_15 = "6" if uid == "B02V22F0672"
	replace d4_1_15 = "1" if uid == "B02V22F0672"
	replace d4_2_15 = "" if uid == "B02V22F0672"
	replace d8_1_15 = 6 if uid == "B02V22F0672"
	replace d8_1_1_1_15 = "1" if uid == "B02V22F0672"
	
	replace d4_15 = "1" if uid == "B06V78F2230"
	replace d8_1_15 = 1 if uid == "B06V78F2230"
		
	**Compost
	la var d0 "Used compost for cotton"
	
	recode d0_1 d0_1_2 d0_2_1 d0_2_1_g (-888/-98 = .d)
	
	
	*Compost quantity units
	lab def compost_unit	1	kilogram ///
							2	"Trolley load" ///
							3	"Tractor load" ///
							.o	other
	destring d0_1_1, replace
	la val d0_1_1 compost_unit
	
	*Unit of weight of tractor/trolly load
	lab def load_weight	1	kilogram ///
						2	ton ///
						3	maund ///
						.o	other
	
	destring d0_1_3, replace
	la val d0_1_3 load_weight
	
	replace d0_1_2 = -888 if uid == "B06V72F2029"
	recode d0_1_2 (-888 = .d)
	
	*Compost applied in kg
	gen compost_kg = . , before(d0_1)
	replace compost_kg = d0_1 						if d0_1_1 == 1
	replace compost_kg = d0_1 * d0_1_2 				if (d0_1_1 == 2 | d0_1_1 == 3) & d0_1_3 == 1 /*Trolley or tractor & kg*/
	replace compost_kg = d0_1 * d0_1_2 * 1000		if (d0_1_1 == 2 | d0_1_1 == 3) & d0_1_3 == 2 /*Trolley or tractor & ton*/
	replace compost_kg = d0_1 * d0_1_2 * `maund_kg'	if (d0_1_1 == 2 | d0_1_1 == 3) & d0_1_3 == 3 /*Trolley or tractor & maund*/
	replace compost_kg = .d 						if d0_1 == .d | d0_1_2 == .d /*Didnt know/remember*/
	replace compost_kg = 0							if d0 == 0 /*Didnt use compost*/
	
	la var compost_kg "Compost used in kg"
	
	*Drop variables used to calculate compost_kg
	drop d0_1 d0_1_1 d0_1_1_o d0_1_2 d0_1_3 d0_1_3_o
	
	/*
	*Compost application area
	gen compost_area_bigha = cotton_area_bigha 				if d0_2 == 1 , before(d0_2)
	replace compost_area_bigha = d0_2_1						if a1_1 == 1 & d0_2 == 0 /*Didnt used compost in the whole plot & bigha*/
	replace compost_area_bigha = d0_2_1 * `acre_bigha'		if a1_1 == 2 & d0_2 == 0 /*Didnt used compost in the whole plot & acre*/
	replace compost_area_bigha = d0_2_1 * `ha_bigha' 		if a1_1 == 3 & d0_2 == 0 /*Didnt used compost in the whole plot & ha*/
	replace compost_area_bigha = d0_2_1 * `guntha_bigha'	if a1_1 == 4 & d0_2 == 0 /*Didnt used compost in the whole plot & guntha*/
	replace compost_area_bigha = 0							if d0 == 0 /*Didnt use compost*/
	replace compost_area_bigha = compost_area_bigha + (d0_2_1_g * `guntha_bigha') if a1_2 == 1 & d0_2 == 0 /* Didnt used compost in the whole plot & uses guntha as a secondary unit*/
	la var compost_area_bigha "Compost area in bigha"
	*/
	
	*Drop variables used to calculate compost area
	drop d0_2 d0_2_1 d0_2_1_g
	
	*Fertilizers
	
	*Drop variables generated in form design but were never reached in data collection 
	drop d3_id_18 - d16_1_o_6_20
	
	*Reasons for not using fertilizers
	la def fertilizers_no_use	1	"no money" ///
								2	"too costly" ///
								3	"not necessary" ///
								4	"no access" ///
								5	"advice from agro-dealer" ///
								6	"advice from other farmer" ///
								7	"never used" ///
								8	"have not heard about this fertilizer" ///
								9	"does not know how to use it" ///
								10	"too risky" ///
								.o	other
								
	qui labellist fertilizers_no_use
	loc values `r(fertilizers_no_use_values)'
	
	tempvar d2
	gen `d2' = " " + d2 + " "
	foreach v of local values {
		local x = subinstr("`v'",".","",1) 
		gen d2_r`x' = (strpos(`d2', " `v' ")> 0) 
		local lbl : label fertilizers_no_use `v'
		la var d2_r`x' "No fertilizer: `lbl'"
		la val d2_r`x' yesno
		note d2_r`x' : "Why did you not use any inorganic fertilizers?"
	}
	drop `d2'
	
	order d2_r1 - d2_ro , after(d2)
	
	*Which fertilizers did you use for your cotton cultivation on ${plot_name} plot in the Kharif season of 2018?
	
	la def fertilizers	1	Urea ///
						2	"Ammonium Sulphate" ///
						3	DAP ///
						4	SSP ///
						5	MOP ///
						6	"NPK 20-20-0" ///
						7	"NPK 20-20-13" ///
						8	"NPK 20-20-20" ///
						9	"NPK 20-20-0-13" ///
						10	"NPK 12-32-16" ///
						11	"NPK 19-19-19" ///
						12	"NPK 15-15-15" ///
						13	"Other NPK" ///
						14	Iron ///
						15	Zinc ///
						16	Sulphur ///
						17	"Other"

	quietly labellist fertilizers
	loc fert_values `r(fertilizers_values)'
	
	tempvar d3
	gen `d3' = " " + d3 + " "
	foreach v of local fert_values { 
		gen d3_r`v'=(strpos(`d3', " `v' ")> 0) if a2 == 1
		local lbl : label fertilizers `v'
		la var d3_r`v' "Used `lbl'"
		la val d3_r`v' yesno
	}
	drop `d3'
	
	order d3_r1 - d3_r17 , after(d3)
	
	split d3_add, p(" ", " ")
	
	foreach v of numlist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		replace d3_r`v' = 1 if d3_add1 == "`v'"
		replace d3_r`v' = 1 if d3_add2 == "`v'"
		replace d3_r`v' = 1 if d3_add3 == "`v'"
		replace d6_`v' = 6 if d6_`v' > 6 & d6_`v' < .
	}
	
	drop d3_add d3_add1 d3_add2 d3_add3

	la def fertilizers_units 	1	kilogram ///
								2	liter ///
								3	gram ///
								4	mililiter ///
								5	bag ///
								.d	"does not know/remember"

	la def bagsize_units 	1	"25 kilogram" ///
							2	"45 kilogram" ///
							3	"50 kilogram" ///
							4	"75 kilogram" ///
							.o	other ///
							.d	"does not know/remember"
							
	la def fertilizer_price	1	kilogram ///
							2	bag ///
							3	total ///
							.o	other

	la copy d7_1_1 crop_stage
	
	la def crop_stage_unit	1 day ///
							2	week /// 
							3	month ///
							.o	other

	la def yesnodk	0 No 1 Yes .d "does not know/remember"
	
	la def time_unit	1	day ///
						2	hour ///
						.o	other

	la def labour	1	"family labour" ///
					2	"exchange labour" /// 
					3	"labour contract" ///
					4	"hired labour" ///
					.o	"other labour"
	
	labellist labour 
	loc labour_values `r(labour_values)'
	
	la def payment_unit 1	"per day per person" ///
						2	"per hour per person" ///
						3	total ///
						.o	other
						
	la def wages_kind	1	breakfast ///
						2	lunch ///
						3	tea ///
						4	"extra tip" ///
						.o	other
						
	labellist wages_kind
	loc wages_values `r(wages_kind_values)'
	
	la def nonoptimal	1	"no money" ///
						2	"too costly" ///
						3	"not necessary" ///
						4	"no access" ///
						5	"advice from agro-dealer" ///
						6	"advice from other farmer" ///
						.o	other
						
	labellist nonoptimal
	loc nonoptimal_values `r(nonoptimal_values)'

	*Fertilizer repeat group loop
	foreach f of local fert_values {
	
	*Label
	local lbl : label fertilizers `f'
	
	*Quantity on total cotton
	replace d4_`f' = "-888"  if d4_`f' == "888"
	destring d4_`f' , replace
	recode d4_`f' (-888 = .d)
	la var d4_`f' "`lbl' used on total cotton cultivated"
	drop temp4_`f'
	
	*Quantity units
	destring d4_1_`f' , replace
	la val d4_1_`f' fertilizers_units
	la var d4_1_`f' "Units of `lbl'"
	
	*Bagsize units
	destring d4_2_`f' , replace
	la val d4_2_`f' bagsize_units
	la var d4_2_`f' "Units of `lbl' bag size"
	la var d4_2_o_`f' "Other units of `lbl' bag size"
	
	*Fertilizer used in kg from main unit
	gen fert_`f'_kg_mu = d4_`f' , before(d4_`f')
	replace fert_`f'_kg_mu = d4_`f' / 1000		if d4_1_`f' == 3 /* g */
	replace fert_`f'_kg_mu = d4_`f' / 1000		if d4_1_`f' == 4 /* ml */
	replace fert_`f'_kg_mu = d4_`f' * 25		if d4_1_`f' == 5 & d4_2_`f' == 1 /* 25kg bag */
	replace fert_`f'_kg_mu = d4_`f' * 45		if d4_1_`f' == 5 & d4_2_`f' == 2 /* 45kg bag */
	replace fert_`f'_kg_mu = d4_`f' * 50		if d4_1_`f' == 5 & d4_2_`f' == 3 /* 50kg bag */
	replace fert_`f'_kg_mu = d4_`f' * 75		if d4_1_`f' == 5 & d4_2_`f' == 4 /* 75kg bag */
	replace fert_`f'_kg_mu = .d					if d4_1_`f' == .d
	replace fert_`f'_kg_mu = .d					if d4_`f' == .d
	destring d4_2_o_`f', replace
	replace fert_`f'_kg_mu = d4_`f' * d4_2_o_`f' if d4_1_`f' == 5 & d4_2_`f' == .o /* other bag sizes */
	
	la var fert_`f'_kg_mu "`lbl' used in kg (main unit)"
	
	*Is there a second unit
	destring d4_3_`f' , replace
	la val d4_3_`f' yesno
	la var d4_3_`f' "Is there a second unit in which farmer applied `lbl'"
	
	*Quantity in second units
	destring d4_4_`f' , replace
	replace d4_4_`f' = -888 if d4_4_`f' == 888
	recode d4_4_`f' (-888 = .d)
	la var d4_4_`f' "`lbl' used on total cotton cultivated (second unit)"
	
	*Second units
	destring d4_4_1_`f' , replace
	la val d4_4_1_`f' fertilizers_units
	la var d4_4_1_`f' "Units of `lbl' (second unit)"
	
	*Bagsize in second units
	destring d4_4_2_`f' , replace
	la val d4_4_2_`f' bagsize_units
	la var d4_4_2_`f' "Units of `lbl' bag size (second unit)"
	la var d4_4_o_`f' "Other units of `lbl' bag size (second unit)"
	 
	gen fert_`f'_kg_su = . , before(d4_4_`f')
	replace fert_`f'_kg_su = d4_4_`f' 			if d4_4_1_`f' == 1 | d4_4_1_`f' == 2 /* kg or l */
	replace fert_`f'_kg_su = d4_4_`f' / 1000	if d4_4_1_`f' == 3 | d4_4_1_`f' == 4 /* g or ml */
	replace fert_`f'_kg_su = d4_4_`f' * 25		if d4_4_1_`f' == 5 & d4_4_2_`f' == 1 /* 25 kg bag */
	replace fert_`f'_kg_su = d4_4_`f' * 45		if d4_4_1_`f' == 5 & d4_4_2_`f' == 2 /* 45 kg bag */
	replace fert_`f'_kg_su = d4_4_`f' * 50		if d4_4_1_`f' == 5 & d4_4_2_`f' == 3 /* 50 kg bag */
	replace fert_`f'_kg_su = d4_4_`f' * 75		if d4_4_1_`f' == 5 & d4_4_2_`f' == 4 /* 75 kg bag */	
	replace fert_`f'_kg_su = .d					if d4_4_`f' == .d | d4_4_1_`f' == .d | d4_4_2_`f' == .d
	destring d4_4_o_`f', replace
	replace fert_`f'_kg_su = d4_4_`f' * d4_4_o_`f' if d4_4_1_`f' == 5 & d4_4_2_`f' == .o /* other bag sizes */
	
	la var fert_`f'_kg_su "`lbl' used in kg (second unit)"
	
	*Total kg applied
	egen fert_`f'_kg = rowtotal(fert_`f'_kg_mu fert_`f'_kg_su), missing
	order fert_`f'_kg, before(fert_`f'_kg_mu)
	la var fert_`f'_kg "Total `lbl' used in kg"
	
	/*
	*Total kg per bigha
	gen fert_`f'_kg_bigha = fert_`f'_kg / cotton_area_bigha
	order fert_`f'_kg_bigha, after(fert_`f'_kg)
	la var fert_`f'_kg_bigha "Total `lbl' used in kg per bigha"
	*/
	
	*Price
	replace d5_`f' = -888 if d5_`f' == 888
	la var d5_`f' "`lbl' price"
	recode d5_`f' (-888 = .d)
	
	*Price units
	destring d5_1_`f', replace
	la val d5_1_`f' fertilizer_price
	la var d5_1_`f' "Unit of `lbl' price"
	la var d5_1_o_`f' "Other unit of `lbl' price"
	
	destring d5_2_`f', replace
	la var d5_2_`f' "Units of `lbl' bag size"
	la val d5_2_`f' bagsize_units
	
	destring d5_2_o_`f' , replace
	la var d5_2_o_`f' "Other `lbl' bag size"
	
	*Price per kg from main unit
	gen fert_`f'_price_kg_mu = d5_`f' , before(d5_`f')
	replace fert_`f'_price_kg_mu = d5_`f'					if d5_1_`f' == 1 /* kg */
	replace fert_`f'_price_kg_mu = d5_`f' / 25				if d5_1_`f' == 2 & d5_2_`f' == 1 /* 25kg bag*/
	replace fert_`f'_price_kg_mu = d5_`f' / 45				if d5_1_`f' == 2 & d5_2_`f' == 2 /* 45kg bag*/
	replace fert_`f'_price_kg_mu = d5_`f' / 50				if d5_1_`f' == 2 & d5_2_`f' == 3 /* 50kg bag*/
	replace fert_`f'_price_kg_mu = d5_`f' / 75				if d5_1_`f' == 2 & d5_2_`f' == 4 /* 75kg bag*/
	replace fert_`f'_price_kg_mu = d5_`f' / fert_`f'_kg_mu 	if d5_1_`f' == 3 /* total */
	replace fert_`f'_price_kg_mu = d5_`f' / d5_2_o_`f'		if d5_2_`f' == .o /*other bagsize*/
	replace fert_`f'_price_kg_mu = .d						if d5_`f' == .d
	
	la var fert_`f'_price_kg_mu "`lbl' price per kg (main unit)"
		
	*Price for second units
	recode d5_3_`f' (-888 = .d)
	la var d5_3_`f' "`lbl' price (second unit)"
	
	*Price units (second units)
	destring d5_6_`f', replace
	la val d5_6_`f' fertilizer_price
	la var d5_6_`f' "Unit of `lbl' price (second unit)"
	la var d5_6_o_`f' "Other unit of `lbl' price (second unit)"
	
	destring d5_7_`f', replace
	la var d5_7_`f' "Units of `lbl' bag size (second unit)"
	la val d5_7_`f' bagsize_units
	
	destring d5_7_o_`f' , replace
	la var d5_7_o_`f' "Other `lbl' bag size (second unit)"
	
	*Price per kg from second unit
	gen fert_`f'_price_kg_su = d5_3_`f', before(d5_3_`f')
	replace fert_`f'_price_kg_su = d5_3_`f'						if d5_6_`f' == 1 /* kg */
	replace fert_`f'_price_kg_su = d5_3_`f' / 25				if d5_6_`f' == 2 & d5_7_`f' == 1 /* 25kg bag*/
	replace fert_`f'_price_kg_su = d5_3_`f' / 45				if d5_6_`f' == 2 & d5_7_`f' == 2 /* 45kg bag*/
	replace fert_`f'_price_kg_su = d5_3_`f' / 50				if d5_6_`f' == 2 & d5_7_`f' == 3 /* 50kg bag*/
	replace fert_`f'_price_kg_su = d5_3_`f' / 75				if d5_6_`f' == 2 & d5_7_`f' == 4 /* 75kg bag*/
	replace fert_`f'_price_kg_su = d5_3_`f' / fert_`f'_kg_su	if d5_6_`f' == 3 /* total */
	replace fert_`f'_price_kg_su = .d							if d5_3_`f' == .d
	replace fert_`f'_price_kg_su = d5_3_`f' / d5_7_o_`f'		if d5_7_`f' == .o /*other bagsize*/
	la var fert_`f'_price_kg_su "`lbl' price per kg (second unit)"
	
	*Weighted average
	gen fert_`f'_price_kg =  fert_`f'_price_kg_mu
	replace fert_`f'_price_kg = ((fert_`f'_price_kg_mu * fert_`f'_kg_mu )+(fert_`f'_price_kg_su * fert_`f'_kg_su ))/(fert_`f'_kg_mu + fert_`f'_kg_su) if d4_3_`f' == 1
	order fert_`f'_price_kg, before(fert_`f'_price_kg_mu)
	la var fert_`f'_price_kg "`lbl' price per kg"
	
	*Doses
	la var d6_`f' "Doses of `lbl'"
	recode d6_`f' (-888=.d)
	replace d6_`f' = 0 if d4_`f' == 0
	
	*Drop d6_c because was incorrectly specified in the form
	drop d6_c_`f'
	
		*Quantites used on each crop stage
		gen fert_`f'_pre_sowing_kg = 0 if a2 == 1
		gen fert_`f'_sowing_kg = 0 if a2 == 1
		gen fert_`f'_post_sowing_kg = 0 if a2 == 1
		*gen fert_`f'_pre_sowing_kg_bigha = 0 if a2 == 1 
		*gen fert_`f'_sowing_kg_bigha = 0 if a2 == 1
		*gen fert_`f'_post_sowing_kg_bigha = 0 if a2 == 1
		
		la var fert_`f'_pre_sowing_kg "`lbl' used before sowing in kg"
		*la var fert_`f'_pre_sowing_kg_bigha "`lbl' used before sowing in kg per bigha"
		la var fert_`f'_sowing_kg "`lbl' used at sowing in kg"
		*la var fert_`f'_sowing_kg_bigha "`lbl' used at sowing in kg per bigha"
		la var fert_`f'_post_sowing_kg "`lbl' used after sowing in kg"
		*la var fert_`f'_post_sowing_kg_bigha "`lbl' used after sowing in kg per bigha"
		
		*Loop through doses
		forvalues d = 1/6 {
		
			*Crop stage application
			la var d7_`d'_`f' "Crop stage for `lbl' application in dose #`d'"
			la val d7_`d'_`f' crop_stage
			note d7_`d'_`f' : "At what crop stage did you apply `lbl' in dose #`d'"
			
			*Application timing
			recode d7_1_`d'_`f' (-888=.d)
			la drop d7_1_`d'_`f'
			la var d7_1_`d'_`f' "Timing of `lbl' application in dose #`d' (from sowing/after sowing)"
			note d7_1_`d'_`f': "What was the duration from sowing/after sowing of cotton crop at which you applied dose #`d' of `lbl'"
			
			destring d7_2_`d'_`f' , replace
			la val d7_2_`d'_`f' crop_stage_unit
			la var d7_2_`d'_`f' "Unit of timing of `lbl' application in dose #`d'"
			
			gen fert_`f'_d`d'_timing = ., before(d7_1_`d'_`f')
			replace fert_`f'_d`d'_timing = d7_1_`d'_`f' 		if d7_2_`d'_`f' == 1 /*days*/
			replace fert_`f'_d`d'_timing = d7_1_`d'_`f' * 7		if d7_2_`d'_`f' == 2 /*weeks*/
			replace fert_`f'_d`d'_timing = d7_1_`d'_`f' * 30  	if d7_2_`d'_`f' == 3 /*months*/
			
			la var fert_`f'_d`d'_timing "Timing of `lbl' application in dose #`d' (days from sowing/after sowing)"
			
			drop d7_1_`d'_`f' d7_2_`d'_`f'
			
			la var d7_2_o_`d'_`f' "Other unit of timing of `lbl' application in dose #`d'"
			drop d7_2_o_`d'_`f'
			
			*Quantity applied in each dose
			la var d8_`d'_`f' "`lbl' used in dose #`d'"
			replace d8_`d'_`f' = -888 if d8_`d'_`f' == 888 
			recode d8_`d'_`f' (-888 = .d)
			replace d8_`d'_`f' = 0 if d6_`f' == 0
			
			*Units
			destring d8_1_`d'_`f' , replace
			la val d8_1_`d'_`f' fertilizers_units
			la var d8_1_`d'_`f' "`lbl' units in dose #`d'"
			
			*Bagsize units
			destring d8_1_1_`d'_`f' , replace
			la val d8_1_1_`d'_`f' bagsize_units
			la var d8_1_1_`d'_`f' "Units of `lbl' bag size in dose #`d'"
			destring d8_1_1_o_`d'_`f' , replace
			
			*Quantity in kg
			gen fert_`f'_d`d'_kg_mu = d8_`d'_`f' , before(d8_`d'_`f')
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f'					if d8_1_`d'_`f' == 1 | d8_1_`d'_`f' == 2 /*kg or l*/		
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' / 1000				if d8_1_`d'_`f' == 3 /* g */
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' / 1000				if d8_1_`d'_`f' == 4 /* g */
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' * 25				if d8_1_`d'_`f' == 5 & d8_1_1_`d'_`f' == 1 /* 25kg bag */
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' * 45				if d8_1_`d'_`f' == 5 & d8_1_1_`d'_`f' == 2 /* 45kg bag */
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' * 50				if d8_1_`d'_`f' == 5 & d8_1_1_`d'_`f' == 3 /* 50kg bag */
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' * 75				if d8_1_`d'_`f' == 5 & d8_1_1_`d'_`f' == 4 /* 75kg bag */
			replace fert_`f'_d`d'_kg_mu = d8_`d'_`f' * d8_1_1_o_`d'_`f' if d8_1_`d'_`f' == 5 & d8_1_1_`d'_`f' == .o /* other bag sizes */
			replace fert_`f'_d`d'_kg_mu = .d							if d8_`d'_`f' == .d
			
			la var fert_`f'_d`d'_kg_mu "`lbl' used in dose #`d' in kg (main unit)"
						
			*Second units
			la var d8_2_`d'_`f' "Is there a second unit in which farmer applied `lbl' in dose #`d'"
			la val d8_2_`d'_`f' yesno
			
			*Quantity in second units
			la var d8_3_`d'_`f' "`lbl' used in dose #`d' (second unit)"
			
			*Second units
			destring d8_3_1_`d'_`f' , replace
			la val d8_3_1_`d'_`f' fertilizer_units
			la var d8_3_1_`d'_`f' "Units of `lbl' in dose #`d' (second unit)"
			
			*Bagsize in second units
			destring d8_3_2_`d'_`f' , replace
			la val d8_3_2_`d'_`f' bagsize_units
			la var d8_3_2_`d'_`f' "Units of `lbl' bag size in dose #`d' (second unit)"
			la var d8_3_2_o_`d'_`f' "Other units of `lbl' bag size"
			destring d8_3_2_o_`d'_`f', replace
			
			*Quantity in kg
			gen fert_`f'_d`d'_kg_su = d8_3_`d'_`f' , before(d8_3_`d'_`f')
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f'						if d8_3_1_`d'_`f' == 1 | d8_3_1_`d'_`f' == 2 /*kg or l*/		
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' / 1000				if d8_3_1_`d'_`f' == 3 /* g */
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' / 1000				if d8_3_1_`d'_`f' == 4 /* g */
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' * 25					if d8_3_1_`d'_`f' == 5 & d8_3_2_`d'_`f' == 1 /* 25kg bag */
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' * 45					if d8_3_1_`d'_`f' == 5 & d8_3_2_`d'_`f' == 2 /* 45kg bag */
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' * 50					if d8_3_1_`d'_`f' == 5 & d8_3_2_`d'_`f' == 3 /* 50kg bag */
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' * 75					if d8_3_1_`d'_`f' == 5 & d8_3_2_`d'_`f' == 4 /* 75kg bag */
			replace fert_`f'_d`d'_kg_su = d8_3_`d'_`f' * d8_3_2_o_`d'_`f' 	if d8_3_1_`d'_`f' == 5 & d8_3_2_`d'_`f' == .o /* other bag sizes */
			replace fert_`f'_d`d'_kg_su = .d								if d8_3_`d'_`f' == .d
			
			la var fert_`f'_d`d'_kg_su "`lbl' used in dose #`d' in kg (second unit)"
			
			egen fert_`f'_d`d'_kg = rowtotal(fert_`f'_d`d'_kg_mu fert_`f'_d`d'_kg_su) , missing
			order fert_`f'_d`d'_kg , before(fert_`f'_d`d'_kg_mu)
			la var fert_`f'_d`d'_kg "`lbl' used in dose #`d' in kg"
			
			*Quantities per crop stage
			replace fert_`f'_sowing_kg  		= fert_`f'_sowing_kg 		+ fert_`f'_d`d'_kg if fert_`f'_d`d'_kg!=. & d7_`d'_`f' == 2
			replace fert_`f'_post_sowing_kg 	= fert_`f'_post_sowing_kg	+ fert_`f'_d`d'_kg if fert_`f'_d`d'_kg!=. & d7_`d'_`f' == 3 
			replace fert_`f'_pre_sowing_kg	= fert_`f'_pre_sowing_kg	+ fert_`f'_d`d'_kg if fert_`f'_d`d'_kg!=. & d7_`d'_`f' == 1
			
			*Drop variables to calculate dose quantity
			drop d8_`d'_`f' d8_1_`d'_`f' d8_1_1_`d'_`f' d8_1_1_o_`d'_`f' d8_2_`d'_`f' d8_3_`d'_`f' d8_3_1_`d'_`f' d8_3_2_`d'_`f' d8_3_2_o_`d'_`f'
			drop fert_`f'_d`d'_kg_mu fert_`f'_d`d'_kg_su
			
			*Fertilizer mix
			destring d9_`d'_`f' , replace
			la val d9_`d'_`f' yesnodk
			la var d9_`d'_`f' "`lbl' in dose #`d' was mixed with other fertilizer"
			notes d9_`d'_`f' : "Was the `lbl' in dose #`d' mixed with any other fertilizer at time of application?"
			
			/*Uncomment to generate variables for mixed doses
			
			la var d9_1_`d'_`f' "Name of the fertilizer with which `lbl' in dose #`d' was mixed"
			
			cap split d9_1_`d'_`f', gen(d9_1_`d'_`f'_r)
			
				if !_rc {
					order `r(varlist)', after(d9_1_`d'_`f')
						foreach u of var `r(varlist)' {
							destring `u', replace
							la var `u' "Fertilizer mixed with `lbl' in dose #`d'"
							la val `u' fertilizers
						}
				}
			
			la var d9_1_o_`d'_`f' "Other fertilizer mixed with `lbl' in dose #`d'"
			la var d9_1_npk_`d'_`f' "Other NPK fertilizer mixed with `lbl' in dose #`d'"
			*/
			
			drop d9_1_`d'_`f' d9_1_o_`d'_`f' d9_1_npk_`d'_`f'

			*Time
			la var d10_`d'_`f' "Time to apply `lbl' in dose #`d'"
			recode d10_`d'_`f' (-888=.d)
			
			destring d10_1_`d'_`f', replace
			la var d10_1_`d'_`f' "Unit of time taken to apply `lbl' in dose #`d'"
			la val d10_1_`d'_`f' time_unit
			
			la var d10_1_o_`d'_`f' "Other unit of time taken to apply `lbl' in dose #`d'"
			
			gen fert_`f'_d`d'_hours = d10_`d'_`f' if d10_1_`d'_`f' == 2 , before(d10_`d'_`f')
			replace fert_`f'_d`d'_hours = d10_`d'_`f' * 8			if d10_1_`d'_`f' == 1 /*days*/
			replace fert_`f'_d`d'_hours = d10_`d'_`f' / 60			if d10_1_`d'_`f' == .o /*minutes*/
			la var fert_`f'_d`d'_hours "Hours taken to apply `lbl' in dose #`d'" 
			
			*Drop variables used to calculate time taken to apply fertilizers dose
			*drop d10_`d'_`f' d10_1_`d'_`f' d10_1_o_`d'_`f'
			
			*Labour
			recode d11_`d'_`f' d11_1_`d'_`f' d11_2_`d'_`f' (-888=.d)
			la var d11_`d'_`f' "People used for applying `lbl' in dose #`d'"
			la var d11_1_`d'_`f' "Men used for applying `lbl' in dose #`d'"
			la var d11_2_`d'_`f' "Women used for applying `lbl' in dose #`d'"
			
			gen fert_`f'_d`d'_man_hours = d11_`d'_`f' * fert_`f'_d`d'_hours, before(d11_`d'_`f')
			la var fert_`f'_d`d'_man_hours "Man-hours taken to apply `lbl' in dose #`d'"
			
			*Type
			la var d12_`d'_`f' "Please share whether the labour used for applying `lbl' in dose #`d' were family members or hired labour"
			tempvar d12_`d'_`f'
			gen `d12_`d'_`f'' = " " + d12_`d'_`f' + " "
				
				foreach v of local labour_values {
				
					local x = subinstr("`v'",".","",1) 
					gen d12_`d'_`f'_r`x' = (strpos(`d12_`d'_`f'', " `v' ")> 0)
					local labour : label labour `v'
					la var d12_`d'_`f'_r`x' "Used `labour' for applying `lbl' in dose #`d'"
					la val d12_`d'_`f'_r`x' yesno
					note d12_`d'_`f'_r`x' : "Please share whether the labour used for applying `lbl' in dose #`d' were family members or hired labour"
				
				}
				
			order d12_`d'_`f'_r1 - d12_`d'_`f'_ro, after(d12_`d'_`f')
			drop `d12_`d'_`f'' d12_`d'_`f' 
				 
			*Hired labour
			recode d13_1_`d'_`f' d13_2_`d'_`f' (-888=.d)
			replace d13_1_`d'_`f' = d11_1_`d'_`f' if d12_`d'_`f'_r1 == 0 & d12_`d'_`f'_r4 == 1
			la var d13_1_`d'_`f' "Men hired for applying `lbl' in dose #`d'"
			
			replace d13_1_`d'_`f' = d11_2_`d'_`f' if d12_`d'_`f'_r1 == 0 & d12_`d'_`f'_r4 == 1
			la var d13_2_`d'_`f' "Women hired for applying `lbl' in dose #`d'"
			
			*For those cases were only hired people worked in fertilizer application we check that it matches the total people that worked
			tempvar check hired_only
			egen `check' = rowtotal(d12_`d'_`f'_r1 - d12_`d'_`f'_ro), missing
			gen `hired_only' = d12_`d'_`f'_r4 == 1 & `check' == 1
			replace d13_1_`d'_`f' = d11_1_`d'_`f'  if `hired_only' == 1
			replace d13_2_`d'_`f' = d11_2_`d'_`f'  if `hired_only' == 1
			
			drop `check' `hired_only'
			
			recode d14_1_`d'_`f' d14_2_`d'_`f' (-888=.d) (0=.)
			la var d14_1_`d'_`f' "Wages paid to hired male for applying `lbl' in dose #`d'"
			la var d14_2_`d'_`f' "Wages paid to hired female for applying `lbl' in dose #`d'"
			
			*Payment unit
			destring d14_3_`d'_`f', replace
			la var d14_3_`d'_`f' "Units of wages paid for applying `lbl' in dose #`d'"
			la val d14_3_`d'_`f' payment_unit
			la var d14_3_o_`d'_`f' "Other units of wages paid for applying `lbl' in dose #`d'"
			
			*Hourly wage
			*Average between wages paid to male and female workers
			replace d14_1_`d'_`f' = 0 if d13_1_`d'_`f' == 0
			replace d14_2_`d'_`f' = 0 if d13_2_`d'_`f' == 0
			gen average_`d'_`f' = ((d13_1_`d'_`f' * d14_1_`d'_`f') + (d13_2_`d'_`f' * d14_2_`d'_`f'))/(d13_1_`d'_`f' + d13_2_`d'_`f'), after(d14_2_`d'_`f')
			
			*Hours worked by hired labour		
			gen fert_`f'_d`d'_hired_hours = fert_`f'_d`d'_hours * (d13_1_`d'_`f' + d13_2_`d'_`f') , before(d13_1_`d'_`f')
			la var fert_`f'_d`d'_hired_hours "Hours hired to apply `lbl' in dose #`d'" 
			
			*Wage
			gen fert_`f'_d`d'_hourly_wage = ., before(d14_1_`d'_`f')
			replace fert_`f'_d`d'_hourly_wage = average_`d'_`f' 							if d14_3_`d'_`f' == 2 /*per hour per person*/
			replace fert_`f'_d`d'_hourly_wage = average_`d'_`f'/8 							if d14_3_`d'_`f' == 1 & d10_1_`d'_`f' == 1 /*per day per person & worked in days*/
			replace fert_`f'_d`d'_hourly_wage = average_`d'_`f'/d10_`d'_`f' 				if d14_3_`d'_`f' == 1 & d10_1_`d'_`f' == 2 /*per day per person & worked in hours*/
			replace fert_`f'_d`d'_hourly_wage = average_`d'_`f'/(d10_`d'_`f'/60)			if d14_3_`d'_`f' == 1 & d10_1_`d'_`f' == .o /*per day per person & worked in minutes*/
			replace fert_`f'_d`d'_hourly_wage = average_`d'_`f'/fert_`f'_d`d'_hired_hours	if d14_3_`d'_`f' == 3
								
			*In kind payment
			la var d14_4_`d'_`f' "Paid in kind for applying `lbl' in dose #`d'"
			la val d14_4_`d'_`f' yesno
			
			tempvar d14_5_`d'_`f'
			gen `d14_5_`d'_`f'' = " " + d14_5_`d'_`f' + " "
			
			la var d14_5_`d'_`f' "Wages paid in kind to hired labour for applying `lbl' in dose #`d'"
			
				foreach v of local wages_values {
			
					local x = subinstr("`v'",".","",1) 
					gen d14_5_`d'_`f'_r`x' = (strpos(`d14_5_`d'_`f'', " `v' ")> 0)
					local w : label wages_kind `v'
					la var d14_5_`d'_`f'_r`x' "Paid with `w' for applying `lbl' in dose #`d'"
					la val d14_5_`d'_`f'_r`x' yesno
					note d14_5_`d'_`f'_r`x' : "Wages paid in kind to hired labour for applying `lbl' in dose #`d'"
			
				}
			
			order d14_5_`d'_`f'_r1 - d14_5_`d'_`f'_ro, after(d14_5_`d'_`f')
			drop `d14_5_`d'_`f'' d14_5_`d'_`f'
			
			la var d14_5_o_`d'_`f' "Other wages paid in kind to hired labour for applying `lbl' in dose #`d'"
			
			la var d14_6_`d'_`f' "Monetary value of wages in kind for dose #`d' of `lbl' application"
			recode d14_6_`d'_`f' (-888=.d)
			
			destring d14_7_`d'_`f', replace
			la var d14_7_`d'_`f' "Units of wages in kind paid for applying `lbl' in dose #`d'"
			la val d14_7_`d'_`f' payment_unit
			
			gen fert_`f'_d`d'_hourly_in_kind_wage = ., before(d14_6_`d'_`f')
			replace fert_`f'_d`d'_hourly_in_kind_wage = d14_6_`d'_`f'							if d14_7_`d'_`f' == 2 /*per hour per person*/
			replace fert_`f'_d`d'_hourly_in_kind_wage = d14_6_`d'_`f'/8							if d14_7_`d'_`f' == 1 & d10_1_`d'_`f' == 1 /*per day per person & worked in days*/
			replace fert_`f'_d`d'_hourly_in_kind_wage = d14_6_`d'_`f'/d10_`d'_`f' 				if d14_7_`d'_`f' == 1 & d10_1_`d'_`f' == 2 /*per day per person & worked in hours*/
			replace fert_`f'_d`d'_hourly_in_kind_wage = d14_6_`d'_`f'/(d10_`d'_`f'/60)			if d14_7_`d'_`f' == 1 & d10_1_`d'_`f' == .o /*per day per person & worked in minutes*/
			replace fert_`f'_d`d'_hourly_in_kind_wage = d14_6_`d'_`f'/fert_`f'_d`d'_hired_hours	if d14_7_`d'_`f' == 3
			
			drop	d10_`d'_`f' d10_1_`d'_`f' d10_1_o_`d'_`f' ///
					d11_`d'_`f' d11_1_`d'_`f' d11_2_`d'_`f' d12_`d'_`f'_r* ///
					d13_1_`d'_`f' d13_2_`d'_`f' d14_1_`d'_`f' d14_2_`d'_`f' d14_3_`d'_`f' ///
					d14_3_o_`d'_`f' d14_4_`d'_`f' d14_5_`d'_`f'_r* d14_5_o_`d'_`f' d14_6_`d'_`f' d14_7_`d'_`f' ///
					fert_`f'_d`d'_hired_hours  average_`d'_`f'
			
			*Area
			la var d15_`d'_`f' "Was `lbl' applied in the entire plot for dose #`d'"
			la val d15_`d'_`f' yesno
			
			recode d15_1_`d'_`f' d15_1_g_`d'_`f' (-888=.d)
			la var d15_1_`d'_`f' "Area in which `lbl' was applied in dose #`d'"
			note d15_1_`d'_`f' : "In how many ${a1_1_lbl} of plot was the `lbl' applied for dose #`d'?"
			la var d15_1_g_`d'_`f' "Area (in guntha) in which `lbl' was applied in dose #`d'"
			note d15_1_g_`d'_`f' : "In how many guntha of plot was the `lbl' applied for dose #`d'?"
			lab drop d15_1_`d'_`f'
			lab drop d15_1_g_`d'_`f'
			
			*Area in which fertilizer dose was applied
			gen fert_`f'_area_d`d'_bigha = . , after(d15_`d'_`f')
			replace fert_`f'_area_d`d'_bigha = 0											if d3_r`f' == 0
			replace fert_`f'_area_d`d'_bigha = cotton_area_bigha							if d15_`d'_`f' == 1				
			replace fert_`f'_area_d`d'_bigha = d15_1_`d'_`f'								if a1_1 == 1 & d15_`d'_`f' == 0 /*Didnt apply dose in the whole plot & bigha*/
			replace fert_`f'_area_d`d'_bigha = d15_1_`d'_`f' * `acre_bigha' 				if a1_1 == 2 & d15_`d'_`f' == 0 /*Didnt apply dose in the whole plot & acre*/
			replace fert_`f'_area_d`d'_bigha = d15_1_`d'_`f' * `ha_bigha' 					if a1_1 == 3 & d15_`d'_`f' == 0 /*Didnt apply dose in the whole plot & ha*/
			replace fert_`f'_area_d`d'_bigha = d15_1_`d'_`f' * `guntha_bigha' 				if a1_1 == 4 & d15_`d'_`f' == 0 /*Didnt apply dose in the whole plot & guntha*/
			replace fert_`f'_area_d`d'_bigha = fert_`f'_area_d`d'_bigha + (d15_1_g_`d'_`f' * `guntha_bigha') if a1_2 == 1 &  d15_`d'_`f' == 0 /* Didnt apply dose in the whole plot & uses guntha as a secondary unit*/
			replace fert_`f'_area_d`d'_bigha = .d 											if d15_1_`d'_`f' == .d /*Does not know*/
			
			la var fert_`f'_area_d`d'_bigha "Area in which `lbl' in dose #`d' was applied in bigha"
			
			gen fert_`f'_area_d`d' = fert_`f'_area_d`d'_bigha / cotton_area_bigha , after(d15_`d'_`f')
			replace fert_`f'_area_d`d' = .d if fert_`f'_area_d`d'_bigha == .d | cotton_area_bigha  == .d
			la var fert_`f'_area_d`d' "Fraction of cotton area in which `lbl' in dose #`d' was applied"
			
			*Drop variables used to calculate fraction of cotton plot where fertilizer dose was applied
			drop d15_`d'_`f' d15_1_`d'_`f' d15_1_g_`d'_`f' fert_`f'_area_d`d'_bigha
			
			/*
			gen fert_`f'_d`d'_kg_bigha = fert_`f'_d`d'_kg / fert_`f'_area_d`d'_bigha, after(fert_`f'_d`d'_kg)
			replace fert_`f'_d`d'_kg_bigha = 0 if fert_`f'_d`d'_kg == 0 
			la var fert_`f'_d`d'_kg_bigha "`lbl' used in dose #`d' in kg per bigha"
			*/
			
			*Total quantites in each crop stage
			*replace fert_`f'_sowing_kg_bigha		= fert_`f'_sowing_kg_bigha 			+ fert_`f'_d`d'_kg_bigha if fert_`f'_d`d'_kg_bigha!=. & d7_`d'_`f' == 2
			*replace fert_`f'_post_sowing_kg_bigha 	= fert_`f'_post_sowing_kg_bigha	+ fert_`f'_d`d'_kg_bigha if fert_`f'_d`d'_kg_bigha!=. & d7_`d'_`f' == 3 
			*replace fert_`f'_pre_sowing_kg_bigha	= fert_`f'_pre_sowing_kg_bigha	+ fert_`f'_d`d'_kg_bigha if fert_`f'_d`d'_kg_bigha!=. & d7_`d'_`f' == 1

			*Optimal amounts
			la var d16_`d'_`f' "Applied optimal amount of `lbl' in dose #`d'"
			destring d16_`d'_`f', replace
			la val d16_`d'_`f' yesnodk
			la var d16_1_o_`d'_`f' "Other reason for not using optimal amount of `lbl' in dose #`d'"

			/*Uncomment to generate dummy variables on the reasons for not applying optimal fertilizer doses
			*Reasons for non-optimal amounts
			
			la var d16_1_`d'_`f' "Why were you not able to apply the optimal amount of `lbl' for your cotton in dose #`d'?"
			note d16_1_`d'_`f' : "Why were you not able to apply the optimal amount of `lbl'  for your cotton in dose #`d'?"
			tempvar d16_1_`d'_`f'
			gen `d16_1_`d'_`f'' = " " + d16_1_`d'_`f' + " "
			
				foreach v of local nonoptimal_values {
			
					local x = subinstr("`v'",".","",1) 
					gen d16_1_`d'_`f'_r`x' = (strpos(`d16_1_`d'_`f'', " `v' ")> 0)
					local o : label nonoptimal `v'
					la var d16_1_`d'_`f'_r`x' "Reason for not applying the optimal `lbl' in dose #`d': `o'"
					la val d16_1_`d'_`f'_r`x' yesno
					note d16_1_`d'_`f'_r`x' : "Why were you not able to apply the optimal amount of `lbl' for your cotton in dose #`d'?"
			
				}
			
			order d16_1_`d'_`f'_r1 - d16_1_`d'_`f'_ro, after(d16_1_`d'_`f')
			
			drop `d16_1_`d'_`f''
			*/
			drop d16_1_`d'_`f' d16_1_o_`d'_`f'
			
		}
	
	/*Uncomment to generate dummy variables indicating if fertilizers were applied before, at, after sowing
	*Crop stage (dummy)
	gen fert_`f'_pre_sowing = fert_`f'_pre_sowing_kg_bigha > 0 if !missing(fert_`f'_pre_sowing_kg_bigha) , before(fert_`f'_pre_sowing_kg)
	gen fert_`f'_sowing = fert_`f'_sowing_kg_bigha > 0 if  !missing(fert_`f'_sowing_kg_bigha) , before(fert_`f'_sowing_kg)
	gen fert_`f'_post_sowing = fert_`f'_post_sowing_kg_bigha > 0 if !missing(fert_`f'_post_sowing_kg_bigha) , before(fert_`f'_post_sowing_kg)
	
	la var fert_`f'_pre_sowing "Used `lbl' before sowing"
	la var fert_`f'_sowing "Used `lbl' at sowing"
	la var fert_`f'_post_sowing "Used `lbl' after sowing"	
	*/
		
	*Total fertilizer (dose wise calculation)
	egen fert_`f'_dw_kg = rowtotal(	fert_`f'_d1_kg fert_`f'_d2_kg fert_`f'_d3_kg fert_`f'_d4_kg fert_`f'_d5_kg fert_`f'_d6_kg ), missing
	order fert_`f'_dw_kg, after(fert_`f'_kg)
	la var fert_`f'_dw_kg "Total `lbl' used in kg (dose wise calculation)"
	
	/*
	egen fert_`f'_dw_kg_bigha = rowtotal(fert_`f'_d1_kg_bigha fert_`f'_d2_kg_bigha fert_`f'_d3_kg_bigha fert_`f'_d4_kg_bigha fert_`f'_d5_kg_bigha fert_`f'_d6_kg_bigha), missing
	order fert_`f'_dw_kg_bigha, after(fert_`f'_dw_kg)
	la var fert_`f'_dw_kg_bigha "Total `lbl' used in kg per bigha (dose wise calculation)"
	*/
	
	order fert_`f'_pre_sowing_kg fert_`f'_sowing_kg fert_`f'_post_sowing_kg /*fert_`f'_pre_sowing_kg_bigha fert_`f'_sowing_kg_bigha fert_`f'_post_sowing_kg_bigha*/ , after(fert_`f'_kg_mu)	
	
	drop d3_id_`f' d3_name_`f'
		
	*Drop variables used to calculate kg applied
	drop d4_`f' d4_1_`f' d4_2_`f' d4_2_o_`f' d4_3_`f' d4_4_`f' d4_4_1_`f' d4_4_2_`f' d4_4_o_`f'
	drop fert_`f'_kg_mu fert_`f'_kg_su
	
	*Drop variables to calculate price
	drop d5_`f' d5_1_`f' d5_1_o_`f' d5_2_`f' d5_2_o_`f' d5_3_`f' d5_6_`f' d5_6_o_`f' d5_7_`f' d5_7_o_`f'
	drop fert_`f'_price_kg_mu fert_`f'_price_kg_su
	
	*Amount spent on fertilizer
	gen fert_`f'_spent = fert_`f'_kg * fert_`f'_price_kg  , after(fert_`f'_price_kg)
	replace fert_`f'_spent = 0 if fert_`f'_kg == 0
	replace fert_`f'_spent = .d if fert_`f'_kg == .d |  fert_`f'_price_kg == .d
	la var fert_`f'_spent "Total amount spent on `lbl'"

	}
	
	*Compute total man-hours taken to apply fertilizers
	*To avoid double counting we consider that fertilizer applications done in the same day
	*as the same application
	preserve
		keep uid d7_* *_timing *_man_hours
		reshape long d7_1_@ d7_2_@ d7_3_@ d7_4_@ d7_5_@ d7_6_@ fert_@_d1_man_hours fert_@_d2_man_hours ///
					fert_@_d3_man_hours fert_@_d4_man_hours fert_@_d5_man_hours fert_@_d6_man_hours ///
					fert_@_d1_timing fert_@_d2_timing fert_@_d3_timing fert_@_d4_timing fert_@_d5_timing ///
					fert_@_d6_timing, i(uid) j(fertilizer)
		reshape long fert__d@_man_hours fert__d@_timing d7_@_, i(uid fertilizer) j(dose)
		drop if missing(d7__)
		gsort uid d7__ fert__d_timing -fert__d_man_hours
		duplicates drop uid d7__ fert__d_timing, force
		collapse (sum) fert__d_man_hours, by(uid)
		rename fert__d_man_hours fertilizers_man_hours
		la var fertilizers_man_hours "Total man-hours taken to apply fertilizers"
		tempfile man_hours
		save `man_hours'

	restore
	
	merge 1:1 uid using `man_hours', nogen keep(1 3)
	order fertilizers_man_hours, before(e1)
	drop fert_*_d*_man_hours
	
	*Calculate average wage paid in fertilizer applicaitions
	unab wages : fert_*_d*_hourly_wage
	egen fertilizers_average_wage = rowmean(`wages')
	order fertilizers_average_wage, before(e1)
	drop `wages'
	la var fertilizers_average_wage "Average hourly wage paid in fertilizer applications"
	
	unab inkind :  fert_*_d*_hourly_in_kind_wage
	egen fertilizers_average_in_kind_wage = rowmean(`inkind')
	order fertilizers_average_in_kind_wage, before(e1)
	drop `inkind'
	la var fertilizers_average_in_kind_wage "Average hourly in kind wage paid in fertilizer applications"
		
	*Total amount spent on fertilizer
	egen fertilizers_spent = rowtotal(fert_1_spent fert_2_spent fert_3_spent fert_4_spent fert_5_spent fert_6_spent fert_7_spent fert_8_spent fert_9_spent fert_10_spent fert_11_spent fert_12_spent fert_13_spent fert_14_spent fert_15_spent fert_16_spent fert_17_spent), missing
	order fertilizers_spent , before(e1)
	la var fertilizers_spent "Total amount spent on fertilizers"
	
	drop d3_r_count
	
	*Rename variables
	rename d0 used_compost
	rename d1 used_inorganic_fertilizers
	
	drop d2
	rename d2_r* no_fertilizers_r*
	rename d2_o no_fertilizers_o
	
	drop d3
	
	rename d3_o_npk other_npk
	rename d3_o other_fertilizer
	
	foreach v of local fert_values { 
	
		if `v' == 2 {
		
			local lbl ams
		}
		
		else {
		
		local lbl : label fertilizers `v'
		local lbl = subinstr("`lbl'"," ","_",.)
		local lbl = subinstr("`lbl'","-","_",.)
		local lbl = lower("`lbl'")
		
		}
		
		rename d3_r`v' used_`lbl'
		rename fert_`v'_kg `lbl'_total_kg
		rename fert_`v'_dw_kg  `lbl'_total_dw_kg
		rename fert_`v'_pre_sowing_kg `lbl'_pre_sowing_kg
		rename fert_`v'_sowing_kg	`lbl'_sowing_kg
		rename fert_`v'_post_sowing_kg `lbl'_post_sowing_kg
		rename fert_`v'_price_kg `lbl'_price_kg
		rename d6_`v' `lbl'_doses
		rename fert_`v'_spent `lbl'_spent
		
		*Loop through doses
			forvalues d = 1/6 {
			
				rename d7_`d'_`v' `lbl'_d`d'_crop_stage 
				rename fert_`v'_d`d'_kg	 `lbl'_d`d'_kg
				rename d9_`d'_`v' `lbl'_d`d'_mixed
				rename fert_`v'_area_d`d' `lbl'_d`d'_area
				rename d16_`d'_`v' `lbl'_d`d'_optimal
				rename fert_`v'_d`d'_timing `lbl'_d`d'_timing
				rename fert_`v'_d`d'_hours `lbl'_d`d'_time_taken
		
			}
	}
	
	

// Section E. Knowledge of Fertilizers

	la def nutrient 1	Nitrogen ///
					2	Phosphorous ///
					3	Potash ///
					.o	Other ///
					.d	"Does not know/remember" ///
					.r	"Does not answer"

	quietly labellist nutrient
	loc values `r(nutrient_values)'
	
	loc f `""irrigated cotton" "Urea" "DAP" "MOP""'
	loc p = "for"

	forvalues n = 1/4 {
	
	local lbl2 : word `n' of `f'
	
		foreach v of local values {
			local x = subinstr("`v'",".","",1) 
			gen e`n'_r`x' = regexm(e`n',"`v'")
			local lbl : label nutrient `v'
			la var e`n'_r`x' "Main nutrient `p' `lbl2': `lbl'"
			la val e`n'_r`x' yesno
		}
		
	loc p = "in"
	
	order e`n'_r1 - e`n'_rr , after(e`n')
	
	}
	
	*e1 Which main nutrients are required by irrigated cotton for growth?
	*Correct answer: Nitrogen, Phosphorous, Potash
	gen e1_correct = e1_r1 == 1 & e1_r2 == 1 & e1_r3 == 1, after(e1_o)
	la var e1_correct "Main nutrients required by irrigated cotton question answered correctly"
	la var e1_o "Other nutrients required by irrigated cotton"
	
	*e2 Which of the following is main nutrient in Urea?
	*Correct answer: Urea
	gen e2_correct = e2_r1 == 1, after(e2_o)
	la var e2_correct "Main nutrient in Urea question answered correctly"
	la var e2_o "Other main nutrient in Urea"
	
	*e3 Which of the following is main nutrient in DAP?
	*Correct answer: Phosphorous
	gen e3_correct = e3_r2 == 1, after(e3_o)
	la var e3_correct "Main nutrient in DAP question answered correctly"
	la var e3_o "Other main nutrient in DAP"
	
	*e4 Which of the following is main nutrient in MOP?
	*Correct answer: Potash
	gen e4_correct = e4_r3 == 1, after(e4_o)
	la var e4_correct "Main nutrient in MOP question answered correctly"
	la var e4_o "Other main nutrient in MOP"
	
	
	la def fertilizers_know	1	Urea ///
							2	"Ammonium Sulphate" ///
							3	DAP ///
							4	SSP ///
							5	MOP ///
							6	"NPK 20-20-0" ///
							7	"NPK 20-20-13" /// 
							8	"NPK 20-20-20" ///
							9	"NPK 20-20-0-13" ///
							10	"NPK 12-32-16" ///
							11	"NPK 19-19-19" ///
							12	"NPK 15-15-15" ///
							13	"Other NPK" ///
							14	Iron ///
							15	Zinc ///
							16	Sulphur ///
							17	"Other fertilizer" ///
							.d	"does not know/remember"

	
	quietly labellist fertilizers_know
	loc values `r(fertilizers_know_values)'
	
	loc f `""applying Nitrogen" "adding Potash""'
	loc i = 1
	
	forvalues j = 5/6 {
	
		tempvar e`j'
		gen `e`j'' = " " + e`j' + " "
		
		local lbl2 : word `i' of `f'

			foreach v of local values {
				local x = subinstr("`v'",".","",1) 
				gen e`j'_r`x' = (strpos(`e`j'', " `v' ")> 0)
				local lbl : label fertilizers_know `v'
				la var e`j'_r`x' "Best fertilizer for `lbl2': `lbl'"
				la val e`j'_r`x' yesno
			}
			loc i = `i' + 1
			order e`j'_r1 - e`j'_rd , after(e`j')
			drop `e`j''
			
	}
	
	
	*e5	Which is the best fertilizer for applying Nitrogen in the soil?
	*Correct answer: Urea
	gen e5_correct = e5_r1 == 1, after(e5_o)
	la var e5_correct "Best fertilizer for applying Nitrogen in the soil answered correctly"
	la var e5_o "Other fertilizer for applying Nitrogen in the soil"
	
	*e6	Which is the best fertilizer for adding Potash in the soil?
	*Correct answer: MOP
	gen e6_correct = e6_r5 == 1, after(e6_o)
	la var e6_correct "Best fertilizer for adding Potash in the soil"
	la var e6_o "Other fertilizer for adding Potash in the soil"

	la def fert_time 	1	"At the time of sowing" ///
						2	"30 days after sowing" ///
						3	"60 days after sowing" ///
						4	"90 days after sowing" ///
						.o	Other ///
						.d	"Does not know/remember"

	quietly labellist fert_time
	loc values `r(fert_time_values)'
	
	loc l `""Zinc for irrigated cotton" "Urea for irrigated cotton" "Urea for un-irrigated cotton" "DAP" "MOP" "'
	loc i = 1
						
	forvalues j = 7/11 {					
						
		tempvar e`j'
		gen `e`j'' = " " + e`j' + " "
		
		local lbl2 : word `i' of `l'
		
			foreach v of local values {
				local x = subinstr("`v'",".","",1)
				gen e`j'_r`x' = regexm(`e`j'', "`v'")
				local lbl : label fert_time `v'
				la var e`j'_r`x' "`lbl2' timing: `lbl'"
				la val e`j'_r`x' yesno
			}
		
		loc i = `i' + 1
		order e`j'_r1 - e`j'_ro , after(e`j')
		drop `e`j''
		
	}
	
	*e7	When is zinc recommended to be applied during cotton cultivation for irrigated cotton?
	*Correct answer: At the time of sowing
	gen e7_correct =  e7_r1 == 1, after(e7_o)
	la var e7_correct "Zinc application time question answered correctly"
	
	*e8	When should Urea be applied in the soil for irrigated cotton?
	*Correct answer: At time of sowing and one/two/three months after sowing
	gen e8_correct =  e8_r1 == 1 & e8_r2 == 1 & e8_r3 == 1 & e8_r4 == 1, after(e8_o)
	la var e8_correct "Urea application time for irrigated cotton question answered correctly"
	
	*e9	When should Urea be applied in the soil for un-irrigated cotton?
	*Correct answer: At time of sowing and one month after sowing
	gen e9_correct = e9_r1 == 1 & e9_r2 == 1, after(e9_o)
	la var e9_correct "Urea application time for un-irrigated cotton question answered correctly"
	
	*e10 When should DAP be applied in the soil for cotton cultivation?
	*Correct answer:  At the time of sowing, one month after sowing
	gen e10_correct = e10_r1 == 1 & e10_r2 == 1, after(e10_o)
	la var e10_correct "DAP application time question answered correctly"
	la var e10_o "Other DAP application time"
	
	*e11 When should MoP be applied in the soil for cotton cultivation?
	*Correct answer: At time of sowing
	gen e11_correct = e11_r1 == 1, after(e11_o)
	la var e11_correct "MOP application time question answered correctly"
	la var e11_o "Other MOP application time"
	
	
	la def fert_benefit 1	"More green" ///
						2	"Increased height and more branches" ///
						3	"More flowers" ///
						.o	other ///
						.d	"does not know/remember"
						
	quietly labellist fert_benefit
	loc values `r(fert_benefit_values)'
	
	loc l "Urea DAP Potash"
	loc i = 1
						
	forvalues j = 12/14 {					
						
		tempvar e`j'
		gen `e`j'' = " " + e`j' + " "
		
		local lbl2 : word `i' of `l'
		
			foreach v of local values {
				local x = subinstr("`v'",".","",1)
				gen e`j'_r`x' = regexm(`e`j'', "`v'")
				local lbl : label fert_benefit `v'
				la var e`j'_r`x' "Benefit of applying `lbl2': `lbl'"
				la val e`j'_r`x' yesno
			}
		
		loc i = `i' + 1
		order e`j'_r1 - e`j'_ro , after(e`j')
		drop `e`j''
		
	}					
	
	*e12	What is the benefit of appling Urea to soil?
	*Correct answer: More green
	gen e12_correct = e12_r1 == 1, after(e12_o)
	la var e12_correct "Benefit of applying Urea question answered correctly"
	la var e12_o "Other benefit of applying Urea"
	
	*e13	What is the benefit of appling DAP to soil?
	*Correct answer: Increased height and more branches
	gen e13_correct = e13_r2 == 1, after(e13_o)
	la var e13_correct "Benefit of applying DAP question answered correctly"
	la var e13_o "Other benefit of applying DAP"
	
	*e14	What is the benefit of appling Potash to soil?
	*Correct answer: More flowers
	gen e14_correct = e14_r3 == 1, after(e14_o)
	la var e14_correct "Benefit of applying Potash question answered correctly"
	la var e14_o "Other benefit of applying Potash"

// Section F. Feedback on KT 

	rename f1 kt_received
	la var kt_received "Received KT calls"

	rename f2 kt_rating
	la var kt_rating "KT calls usefulness"
	
	rename f3 kt_suggestions
	la var kt_suggestions "Suggestions for KT calls"

// Drop area variables
	drop a1 a1_1 a1_2 a1_3 area_compare a1_1_2
	rename a2 sowed_cotton
	rename a2_6_1 sowed_cotton_difference
	drop a2_2
	rename a2_2_r* no_cotton_r*
	rename a2_2_o no_cotton_o
	rename a2_3 sowing_month
	rename a2_3_1 sowing_week
	drop a2_3_o
	
	rename a2_4 sowed_cotton_entire_plot
	
	drop  a2_4_1 temp2_1 a2_4_1_g area_compare_s
	
	rename a2_4_2 cotton_area_difference
	
	rename a3_1 irrigated_cotton
	rename a3_1_1 irrigated_cotton_difference
	
	drop a3_2
	rename a3_2_r* irrigation_source_r*
	rename a3_2_o irrigation_source_o
	
	rename a3_3 irrigated_entire_cotton
	
	drop a3_4 a3_4_g
	
	rename a3_5 optimal_water
	
	rename a4 crop_still_standing
	
	drop a4_1 
	rename a4_1_r* crop_failure_r* 
	rename a4_2_o crop_failure_o
	
	
	
//	Drop form & surveycto

	drop	intro duration survey_date survey_time ///
			end1 end2 end3 end4 deviceid subscriberid simid ///
			devicephonenum date date_v time time_v time_a formdef_version ///
			key submissiondate starttime endtime date_a
			
// Remove PII
	drop name district village block district_code village_code mobile_number plot_name
	compress
	
	
// Drop variables with missing values in every observation
	missings dropvars, force
	
	
save "`midline_data_clean'", replace

	
	
