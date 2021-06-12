use "$final_data", clear 

// Create a t1 folder to store outputs if it doesn't exist 
capture mkdir "tables/t1/"

label var physical_irrigation_bl "Irrigation = well, dam, or canal"
label define physical_irrigation_bl 0 "No irrigation or rain dependent" 1 "Irrigation based on a well, dam, or canal"

//Generate indicators for attrition from each survey 
generate basal_att = cond(consent_basal == 1 & sowed_cotton == 1, 0, 1)
generate midline_att = cond(consent_ml == 1 & sowed_cotton == 1, 0, 1)
generate endline_att = cond(consent_el == 1 & sowed_cotton == 1, 0, 1)

//Indicator for all satellite data 
generate sat_data_2016 = cond(missing(max_re705_2016), 0, 1)
generate sat_data_2017 = cond(missing(max_re705_2017), 0, 1)
generate sat_data_2018 = cond(missing(max_re705_2018), 0, 1)
generate all_sentinel_data = 1
foreach x of varlist sat_data_20* {
	replace all_sentinel_data = 0 if `x' != 1 
}
replace all_sentinel_data = . if map_merge != 3
label var all_sentinel_data "Sentinel-2: no missing data"
label define all_sentinel_data 0 "Missing data" 1 "No missing data"
label val all_sentinel_data all_sentinel_data

//Indicator for missing farmer-reported yield data 
generate missing_yield = cond(missing(yield_hectare_2018_alt), 1, 0)
assert missing_yield == 1 if sowed_cotton == 0 

//Create a program to create the balance table 
capture program drop table_1_balance
program define table_1_balance, eclass
syntax varlist(numeric) using/, fmt(string) treatvar(varname)

quietly{
// Initiate the output Latex file 
cap file close handle
file open handle using "`using'", write replace

foreach x in `varlist' {

	summarize `x', detail 
	replace `x' = r(p50) if missing(`x')

	local varlabel : var label `x'
	summarize `x' if `treatvar' == 0 
	local control_mean: di `fmt' r(mean)
	local control_sd: di `fmt' r(sd)
	local control_sd = subinstr("`control_sd'"," ","",.)

	regress `x' `treatvar'
	local beta_1: di `fmt' _b[`treatvar']
	local beta_1 = subinstr("`beta_1'"," ","",.)
	local se_1: di `fmt' _se[`treatvar']
	local se_1 = subinstr("`se_1'"," ","",.)
	if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .01 {
		local beta_1 = "`beta_1'\sym{***}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .05 {
		local beta_1 = "`beta_1'\sym{**}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .1 {
		local beta_1 = "`beta_1'\sym{*}"
	}

	regress `x' `treatvar' if basal_att == 0
	local beta_2: di `fmt' _b[`treatvar']
	local beta_2 = subinstr("`beta_2'"," ","",.)
	local se_2: di `fmt' _se[`treatvar']
	local se_2 = subinstr("`se_2'"," ","",.)
	if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .01 {
		local beta_2 = "`beta_2'\sym{***}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .05 {
		local beta_2 = "`beta_2'\sym{**}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .1 {
		local beta_2 = "`beta_2'\sym{*}"
	}

	regress `x' `treatvar' if midline_att == 0
	local beta_3: di `fmt' _b[`treatvar']
	local beta_3 = subinstr("`beta_3'"," ","",.)
	local se_3: di `fmt' _se[`treatvar']
	local se_3 = subinstr("`se_3'"," ","",.)
	if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .01 {
		local beta_3 = "`beta_3'\sym{***}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .05 {
		local beta_3 = "`beta_3'\sym{**}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .1 {
		local beta_3 = "`beta_3'\sym{*}"
	}

	regress `x' `treatvar' if endline_att == 0
	local beta_4: di `fmt' _b[`treatvar']
	local beta_4 = subinstr("`beta_4'"," ","",.)
	local se_4: di `fmt' _se[`treatvar']
	local se_4 = subinstr("`se_4'"," ","",.)
	if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .01 {
		local beta_4 = "`beta_4'\sym{***}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .05 {
		local beta_4 = "`beta_4'\sym{**}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .1 {
		local beta_4 = "`beta_4'\sym{*}"
	}

	regress `x' `treatvar' if missing_yield == 0
	local beta_5: di `fmt' _b[`treatvar']
	local beta_5 = subinstr("`beta_5'"," ","",.)
	local se_5: di `fmt' _se[`treatvar']
	local se_5 = subinstr("`se_5'"," ","",.)
	if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .01 {
		local beta_5 = "`beta_5'\sym{***}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .05 {
		local beta_5 = "`beta_5'\sym{**}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .1 {
		local beta_5 = "`beta_5'\sym{*}"
	}

	regress `x' `treatvar' if all_sentinel_data == 1
	local beta_6: di `fmt' _b[`treatvar']
	local beta_6 = subinstr("`beta_6'"," ","",.)
	local se_6: di `fmt' _se[`treatvar']
	local se_6 = subinstr("`se_6'"," ","",.)
	if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .01 {
		local beta_6 = "`beta_6'\sym{***}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .05 {
		local beta_6 = "`beta_6'\sym{**}"
	}
	else if 2*ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])) < .1 {
		local beta_6 = "`beta_6'\sym{*}"
	}

	file w handle "`varlabel' & `control_mean' & `beta_1' & `beta_2' & `beta_3' & `beta_4' & `beta_5' & `beta_6' \\ " _n
	file w handle " & [`control_sd'] & (`se_1') & (`se_2') & (`se_3') & (`se_4') & (`se_5') & (`se_6') \\ [1em] " _n
}

count if treatment == 0 
local n_0 = r(N)

regress `treatvar' `varlist'
local n_1: di %9.0fc e(N)
test `varlist'
local f_1 : di `fmt' `r(p)'

regress `treatvar' `varlist' if basal_att == 0
local n_2: di %9.0fc e(N)
test `varlist'
local f_2 : di `fmt' `r(p)'

regress `treatvar' `varlist' if midline_att == 0
local n_3: di %9.0fc e(N)
test `varlist'
local f_3 : di `fmt' `r(p)'

regress `treatvar' `varlist' if endline_att == 0
local n_4: di %9.0fc e(N)
test `varlist'
local f_4 : di `fmt' `r(p)'

regress `treatvar' `varlist' if missing_yield == 0
local n_5: di %9.0fc e(N)
test `varlist'
local f_5 : di `fmt' `r(p)'

regress `treatvar' `varlist' if all_sentinel_data == 1
local n_6: di %9.0fc e(N)
test `varlist'
local f_6 : di `fmt' `r(p)'

file w handle "Observations & `n_0' & `n_1' & `n_2' & `n_3' & `n_4' & `n_5' & `n_6' \\ " _n
file w handle "p-value of joint orthogonality &  & `f_1' & `f_2' & `f_3' & `f_4' & `f_5' & `f_6' \\ " _n

file close handle
}
end

label var pucca_house "Strong house"
label var literate "Literate"
generate total_cotton_land_ha = total_cotton_land/6.177625  // Conversion from bigha to hectares 
label var total_cotton_land_ha "Total cotton land (2017)" 
generate sampled_plot_size_ha = sampled_plot_size/6.177625
label var sampled_plot_size_ha "Sampled plot size (2017)"
label var physical_irrigation_bl "Irrigation"
label var plough_own "Own plough"
label var crop_insurance "Crop insurance"
label var children "Children"
label var educated "$>$ median education"
replace fertilizer_plot_kg_bigha_1 = 6.177625*fertilizer_plot_kg_bigha_1
label var fertilizer_plot_kg_bigha_1 "UREA last season (kg/ha)"
replace fertilizer_plot_kg_bigha_3 = 6.177625*fertilizer_plot_kg_bigha_3
label var fertilizer_plot_kg_bigha_3 "DAP last season (kg/ha)"
replace fertilizer_plot_kg_bigha_5 = 6.177625*fertilizer_plot_kg_bigha_5
label var fertilizer_plot_kg_bigha_5 "MOP last season (kg/ha)"
replace fertilizer_plot_kg_bigha_12 = 6.177625*fertilizer_plot_kg_bigha_12
label var fertilizer_plot_kg_bigha_12 "Zinc last season (kg/ha)"

table_1_balance age_bl literate total_cotton_land_ha sampled_plot_size_ha physical_irrigation_bl pucca_house plough_own crop_insurance children educated soil_test_before ///
fertilizer_plot_kg_bigha_1 fertilizer_plot_kg_bigha_3 fertilizer_plot_kg_bigha_5 fertilizer_plot_kg_bigha_12 using "tables/t1/balance.tex", fmt("%9.3fc") treatvar(treatment)

