use "$merged_data", clear 

// Create a t-a1 folder to store outputs if it doesn't exist 
capture mkdir "tables/t-a1/"

// Generate survey completion variables 

generate missing_map = cond(map_merge==1,1,0)
label var missing_map "Missing plot map"
label define missing_map 0 "Plot mapped" 1 "Plot not mapped"
label val missing_map missing_map

label var sowed_cotton "Grew cotton"
label drop sowed_cotton
label define sowed_cotton 0 "Did not sow cotton" 1 "Sowed cotton"
label val sowed_cotton sowed_cotton

generate basal_att = cond(consent_basal == 1, 0, 1)
label var basal_att "Basal"
label define basal_att 0 "Completed basal survey" 1 "Attrited"
label val basal_att basal_att

generate midline_att = cond(consent_ml == 1, 0, 1)
label var midline_att "Midline"
label define midline_att 0 "Completed midline survey" 1 "Attrited"
label val midline_att midline_att

generate endline_att = cond(consent_el == 1, 0, 1)
label var endline_att "Endline"
label define endline_att 0 "Completed endline survey" 1 "Attrited"
label val endline_att endline_att

egen all_complete = rowmax(basal_att midline_att endline_att missing_map)
replace all_complete = 1-all_complete
label var all_complete "\makecell[c]{All surveys and \\ mapping complete}"
label define all_complete 0 "Did not complete 1+ surveys" 1 "Completed all surveys"
label val all_complete all_complete

label var all_complete "All surveys and mapping complete"

//Cross-tabulation of survey completion rates

tabout sowed_cotton basal_att midline_att endline_att missing_map all_complete treatment using "tables/t-a1/attrition-cross-tab.tex", cells(freq col) format(0 1) clab(Number Percent) ///
replace style(tex) bt h1(\\[-2mm]) cl2(2-3 4-5 6-7) font(bold) ///
topstr(14cm)  
