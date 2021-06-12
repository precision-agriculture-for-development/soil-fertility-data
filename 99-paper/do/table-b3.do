use "$final_data", clear 

generate yield_tons_hectare_2018 = yield_hectare_2018*.001

summarize calc_cotton_area, detail 
global median_plot_size = `r(p50)'

// Create a t-b3 folder to store outputs if it doesn't exist 
capture mkdir "tables/t-b3/"

label var max_ndvi_2018 "NDVI"
label var max_gcvi_2018 "GCVI" 
label var max_re705_2018 "reNDVI"
label var max_mtci_2018 "MTCI"
label var max_lai_2018 "LAI"

label var yield_tons_hectare_2018 "Yield (metric tons/hectare)"

// First store regressions for plots above the median size 
eststo clear 
eststo: regress max_ndvi_2018 yield_tons_hectare_2018 if calc_cotton_area > $median_plot_size, robust
local ri_group_1_size = e(N)
eststo: regress max_gcvi_2018 yield_tons_hectare_2018 if calc_cotton_area > $median_plot_size, robust
eststo: regress max_re705_2018 yield_tons_hectare_2018 if calc_cotton_area > $median_plot_size, robust
eststo: regress max_mtci_2018 yield_tons_hectare_2018 if calc_cotton_area > $median_plot_size, robust
eststo: regress max_lai_2018 yield_tons_hectare_2018 if calc_cotton_area > $median_plot_size, robust

esttab using "tables/t-b3/above_median.tex", replace se noobs ///
not tex star(* 0.10 ** 0.05 *** 0.01) label scalars("N Observations" "r2_a Adjusted \$R^2$") sfmt(%9.0fc %9.3fc %9.0fc) ///
noomitted frag b(%9.3fc) 

// Second, store regressions for plots less than or equal to the median size, and include a p-value indicating the chance that the difference in ar2 between panels is due to random chance 

eststo clear 
***********************************************************************************************************
* Randomization inference inspired approach to check if fit improvement on large plots is due to random chance
***********************************************************************************************************

capture program drop ri_r2
program define ri_r2, eclass
syntax varname(numeric), iterations(integer) start_seed(integer) group_1_size(integer)
quietly{
regress `varlist' yield_tons_hectare_2018 if calc_cotton_area > $median_plot_size, robust
local above_median_r2 = e(r2_a)
regress `varlist' yield_tons_hectare_2018 if calc_cotton_area <= $median_plot_size, robust
local below_median_r2 = e(r2_a)

local r2_difference = `above_median_r2' - `below_median_r2'

local bigger_difference = 0 
local smaller_difference = 0

local stop = `iterations' - 1

forval i = 0/`stop' {
	preserve
	local j = `i' + `start_seed'
	set seed `j'
	generate random_order = runiform()
	sort random_order
	generate group = cond(_n <= `group_1_size', 0, 1)
	regress `varlist' yield_tons_hectare_2018 if group==0, robust
	local r2_1 = e(r2_a)
	regress `varlist' yield_tons_hectare_2018 if group==1, robust
	local r2_2 = e(r2_a)
	local r2_difference_random = `r2_1' - `r2_2'
	if `r2_difference_random' > `r2_difference' {
		local bigger_difference = `bigger_difference' + 1
	}
	else {
		local smaller_difference = `smaller_difference' + 1
	}
	restore 
}

local diff_r2_p_value = (`bigger_difference')/(`bigger_difference' + `smaller_difference')
}
ereturn scalar p = `diff_r2_p_value'
end

ri_r2 max_ndvi_2018, iterations(10000) start_seed(20200512) group_1_size(`ri_group_1_size')
local ri_pval: di %9.3f `e(p)'
eststo: regress max_ndvi_2018 yield_tons_hectare_2018 if calc_cotton_area <= $median_plot_size, robust
estadd scalar ri_p = `ri_pval'

ri_r2 max_gcvi_2018, iterations(10000) start_seed(20200512) group_1_size(`ri_group_1_size')
local ri_pval: di %9.3f `e(p)'
eststo: regress max_gcvi_2018 yield_tons_hectare_2018 if calc_cotton_area <=$median_plot_size, robust
estadd scalar ri_p = `ri_pval'

ri_r2 max_re705_2018, iterations(10000) start_seed(20200512) group_1_size(`ri_group_1_size')
local ri_pval: di %9.3f `e(p)'
eststo: regress max_re705_2018 yield_tons_hectare_2018 if calc_cotton_area <= $median_plot_size, robust
estadd scalar ri_p = `ri_pval'

ri_r2 max_mtci_2018, iterations(10000) start_seed(20200512) group_1_size(`ri_group_1_size')
local ri_pval: di %9.3f `e(p)'
eststo: regress max_mtci_2018 yield_tons_hectare_2018 if calc_cotton_area <= $median_plot_size, robust
estadd scalar ri_p = `ri_pval'

ri_r2 max_lai_2018, iterations(10000) start_seed(20200512) group_1_size(`ri_group_1_size')
local ri_pval: di %9.3f `e(p)'
eststo: regress max_lai_2018 yield_tons_hectare_2018 if calc_cotton_area <= $median_plot_size, robust
estadd scalar ri_p = `ri_pval'


esttab using "tables/t-b3/below_median.tex", replace se noobs ///
not label tex star(* 0.10 ** 0.05 *** 0.01) /// 
noomitted frag b(%9.3fc) scalar("N Observations" "r2_a Adjusted \$R^2$" "ri_p p-value: \$R^2$ Panel A $\leq$ \$R^2$ Panel B") sfmt(%9.0fc %9.3fc %9.3fc) 
