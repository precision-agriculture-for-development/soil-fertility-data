clear

/****************************************************************************
This do file cleans the soil tests results entered from hard copies.
Data has been entered twice and both entries have been reconciled for all the farmers.

PII was removed from the raw data, so this file may not run.
****************************************************************************/

*Main path
gl Main ""

*Input data
loc hc "${Main}/07-soil-health-data/02-raw-data/ATAI_Soil Test Results_11June.dta"

*Output data
loc clean "$/07-soil-health-data/04-processed-dataATAI_Soil_Test_Results.dta"

use "`hc'"

replace phosphors_level="2" if Id=="B01V03F0096"
replace phosphors_level="2" if Id=="B06V75F2127"
replace potash_level="3" if Id=="B06V79F2262"
replace zinc_level="3" if Id=="B03V35F1042"
replace zinc_level="2" if Id=="B04V45F1295"
replace zinc_level="1" if Id=="B06V76F2170"

*replace Id = "B03V33F0979" in 1629
replace lab_no = "1269" if Id == "B03V33F0979"
replace farmer_name = "OMITTED" if Id == "B03V33F0979"
replace survey_no = "417" if Id == "B03V33F0979"
replace village = "Hindolgadh" if Id == "B03V33F0979"
replace block = "Vinchiya" if Id == "B03V33F0979"
replace district = "Rajkot" if Id == "B03V33F0979"
replace ph = "7.62" if Id == "B03V33F0979"
replace ec = "0.52" if Id == "B03V33F0979"
replace nitrogen_value = "303" if Id == "B03V33F0979"
replace nitrogen_level = "2" if Id == "B03V33F0979"
replace phosphors_value = "77.97" if Id == "B03V33F0979"
replace phosphors_level = "3" if Id == "B03V33F0979"
replace potash_value = "430" if Id == "B03V33F0979"
replace potash_level = "3" if Id == "B03V33F0979"
replace zinc_value = "1.02" if Id == "B03V33F0979"
replace zinc_level = "3" if Id == "B03V33F0979"
replace iron_value = "7.86" if Id == "B03V33F0979"
replace iron_level = "2" if Id == "B03V33F0979"
replace sulphur_value = "23.36" if Id == "B03V33F0979"
replace sulphur_level = "3" if Id == "B03V33F0979"

*replace Id = "B03V32F0948" in 1630
replace lab_no = "859" if Id == "B03V32F0948"
replace farmer_name = "OMITTED" if Id == "B03V32F0948"
replace survey_no = "" if Id == "B03V32F0948"
replace village = "Vangdhara" if Id == "B03V32F0948"
replace block = "Vinchiya" if Id == "B03V32F0948"
replace district = "Rajkot" if Id == "B03V32F0948"
replace ph = "7.67" if Id == "B03V32F0948"
replace ec = "0.39" if Id == "B03V32F0948"
replace nitrogen_value = "227" if Id == "B03V32F0948"
replace nitrogen_level = "1" if Id == "B03V32F0948"
replace phosphors_value = "17.95" if Id == "B03V32F0948"
replace phosphors_level = "1" if Id == "B03V32F0948"
replace potash_value = "391" if Id == "B03V32F0948"
replace potash_level = "3" if Id == "B03V32F0948"
replace zinc_value = "0.64" if Id == "B03V32F0948"
replace zinc_level = "2" if Id == "B03V32F0948"
replace iron_value = "6.24" if Id == "B03V32F0948"
replace iron_level = "2" if Id == "B03V32F0948"
replace sulphur_value = "13.99" if Id == "B03V32F0948"
replace sulphur_level = "2" if Id == "B03V32F0948"

*Modify variables for consistency with the merging data
rename Id uid
rename ph ph_value
rename ec ec_value
rename phosphors_value phosphorous_value 
rename phosphors_level phosphorous_level
rename farmer_name name

foreach var in district block village name {
	replace(`var') = lower(`var')
	}

foreach var of varlist lab_no ph_value - sulphur_level {
	destring `var', replace
	}
	
la def nutrient_level 1 low 2 medium 3 high


la val nitrogen_level phosphorous_level potash_level iron_level zinc_level sulphur_level nutrient_level

*Label variables
foreach x in nitrogen phosphorous potash iron zinc sulphur {
	
	loc xp = strproper("`x'")
	
	la var `x'_level "`xp' level"
	la var `x'_value "`xp' value"
	
}
foreach x in uid name lab_no survey_no village block district {
	
	loc xp = strproper(subinstr("`x'","_"," ",.))
	la var `x' "`xp'"
	
	}
	
la var ph_value "pH value"
la var ec_value "EC value"

format ec_value iron_value zinc_value %04.2fc

drop ComputerName	LoginPerson	LoginDate	LoginStartTime	LoginEndTime	Srno	ComputerName_Last ///
	LoginPerson_Last	LoginDate_Last	LoginStartTime_Last	LoginEndTime_Last	Srno_Last 

save "`clean'"	, replace

