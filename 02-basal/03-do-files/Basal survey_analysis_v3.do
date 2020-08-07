clear all
version 14
cap log close
set more off
set maxvar 20000
/****************************************************************************

****************************************************************************/
*specify main (Dropbox) path
gl Main ""

*Input data
loc basal_survey "02-basal/04-processed-data/Basal_Survey_clean.dta"
loc baseline "01-baseline/04-cleaned-data/merged/ATAI_baseline_treatment_assignment.dta"
loc nutrient_recco "07-soil-health-data/04-processed-data/ATAI_Soil_Tests_Results_Recommendations.dta"

*Output data
loc soil_tests "02-basal/04-processed-data/basal_clean_2.dta"
****************************************************************************/
use "`basal_survey'"

** Potential outlier/error in survey. needs to be checked
replace SII_6_2_ZINC = 0 if uid=="B02V26F0775"
replace SII_6_3_ZINC = 0 if uid=="B02V26F0775"
replace SII_6_4_ZINC = 0 if uid=="B02V26F0775"
replace SII_7_2_DAP = "3" if uid == "B04V46F1323"
replace SII_7_3_DAP = 1 if uid == "B04V46F1323"

*5) Quantity of nutrients applied per unit of land size
*a) Converting all land into bigha
gen Cotton_area = . , after(SII_3_2)
replace Cotton_area = SII_3_1 if SII_3_2==1 /*bigha*/  
replace Cotton_area = SII_3_1* 2.5 if SII_3_2==2 /*acre*/ 
replace Cotton_area = SII_3_1* 6.25 if SII_3_2==3 /*hectare*/
label var Cotton_area "Cotton area in sampled plot in bigha"

*b) Converting into bigha in case farmer reported applying fertilizer on a part of land and reported the part in acre
foreach i in UREA DAP MOP ZINC NPK_202020 NPK_20200 NPK_123216 {
 destring SII_7_2_`i', replace
 replace SII_7_2_`i' = SII_7_2_`i'*2.5 if SII_7_3_`i'==2 
}

*c) Converting fertilizer into kilogram
foreach i in UREA DAP MOP ZINC NPK_202020 NPK_20200 NPK_123216 {
 destring SII_6_2_`i', replace
 gen `i'_Kg = SII_6_2_`i', after(SII_6_4_`i')
 replace `i'_Kg = SII_6_2_`i'*25 if SII_6_3_`i'==5 & SII_6_4_`i'==1 //multiplying by 25 in cases where farmer reported in terms of 25kg bag 
 replace `i'_Kg = SII_6_2_`i'*45 if SII_6_3_`i'==5 & SII_6_4_`i'==2 //multiplying by 45 in cases where farmer reported in terms of 45kg bag
 replace `i'_Kg = SII_6_2_`i'*50 if SII_6_3_`i'==5 & SII_6_4_`i'==3 //multiplying by 50 in cases where farmer reported in terms of 50kg bag
 replace `i'_Kg = SII_6_2_`i'*75 if SII_6_3_`i'==5 & SII_6_4_`i'==4 //multiplying by 75 in cases where farmer reported in terms of 75kg bag
 replace `i'_Kg = 0 if `i'_Kg==. & SII_5=="1"
 label var `i'_Kg "Kilogram of `i' applied to cotton in sampled plot"
}

*d) Variable for part of area of sampled plot on which fert was applied
foreach i in UREA DAP MOP ZINC NPK_202020 NPK_20200 NPK_123216 {
gen `i'_area = 1 if SII_7_1_`i' == 1, after(`i'_Kg)
replace `i'_area = SII_7_2_`i' / Cotton_area if SII_7_1_`i' == 0
la var `i'_area "Proportion of cotton plot on which `i' was applied in basal application"
}

save "`soil_tests'"
