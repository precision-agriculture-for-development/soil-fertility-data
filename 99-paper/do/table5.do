use "$final_data", clear

// Create a t5 folder to store outputs if it doesn't exist 
capture confirm file "tables/t5/"
if _rc mkdir "tables/t5/"

//Generate farmer reported productivity in metric tons/hectare (to limit leading 0s)

generate yield_tons_hectare_2018 = yield_hectare_2018*.001
label var yield_tons_hectare_2018 "Yield (metric tons/hectare)"

//Generate an indicator for fixed-effects singletons, to exclude them from the robustness check regressions 
replace grid_id = . if missing(yield_hectare_2018, max_re705_2018)
duplicates tag grid_id, gen(dup)
generate singleton = cond(dup==0, 1, 0)
replace singleton = 1 if missing(grid_id)
drop dup 

//Define program to return p-values of the actual data with .5km x .5km Grid FE and placebo data with FE 
capture program drop grid_p 
program define grid_p, eclass
syntax varname(numeric), [robust]
quietly{
local plcaebo_var = subinstr("`varlist'","max","placebo",.)
if "`robust'" == "robust" {
	areg yield_hectare_2018 `varlist' if singleton==0, absorb(grid_id) vce(robust)
	local p_fe = 2*ttail(e(df_r), _b[`varlist']/_se[`varlist'])

	areg yield_hectare_2018 `plcaebo_var' if singleton==0, absorb(grid_id) vce(robust)
	local p_fe_placebo = 2*ttail(e(df_r), _b[`plcaebo_var']/_se[`plcaebo_var'])
	ereturn scalar p_grid_fe_placebo = `p_fe_placebo'
	ereturn scalar p_grid_fe = `p_fe'
	ereturn scalar n_grid_fe = e(N)
}
else {
	areg yield_hectare_2018 `varlist' if singleton==0, absorb(grid_id)
	local p_fe = 2*ttail(e(df_r), _b[`varlist']/_se[`varlist'])

	areg yield_hectare_2018 `plcaebo_var' if singleton==0, absorb(grid_id) 
	local p_fe_placebo = 2*ttail(e(df_r), _b[`plcaebo_var']/_se[`plcaebo_var'])
	ereturn scalar p_grid_fe_placebo = `p_fe_placebo'
	ereturn scalar p_grid_fe = `p_fe'
	ereturn scalar n_grid_fe = e(N)
}
}

end


//Label variables
label var max_ndvi_2018 "NDVI"
label var max_gcvi_2018 "GCVI"
label var max_re705_2018 "reNDVI"
label var max_mtci_2018 "MTCI"
label var max_lai_2018 "LAI"

eststo clear

grid_p max_ndvi_2018, robust 
local p_fe = e(p_grid_fe)
local p_fe_placebo = e(p_grid_fe_placebo)
local n_grid = e(n_grid_fe)

regress placebo_ndvi_2018 yield_tons_hectare_2018, robust
local placebo = e(r2_a)
eststo: regress max_ndvi_2018 yield_tons_hectare_2018, robust
local placebo_r2a: di %9.3fc  `placebo'
estadd local placebo_r2a `placebo_r2a'
local p_grid_fe: di %9.3fc `p_fe' 
estadd local p_grid_fe `p_grid_fe'
local p_grid_fe_plcaebo: di %9.3fc `p_fe_placebo' 
estadd local p_grid_fe_plcaebo `p_grid_fe_plcaebo'
local n_grid_fe: di %9.0fc `n_grid' 
estadd local n_grid_fe `n_grid_fe'

grid_p max_gcvi_2018, robust 
local p_fe = e(p_grid_fe)
local p_fe_placebo = e(p_grid_fe_placebo)
local n_grid = e(n_grid_fe)

regress placebo_gcvi_2018 yield_tons_hectare_2018, robust
local placebo = e(r2_a)
eststo: regress max_gcvi_2018 yield_tons_hectare_2018, robust
local placebo_r2a: di %9.3fc  `placebo'
estadd local placebo_r2a `placebo_r2a'
local p_grid_fe: di %9.3fc `p_fe' 
estadd local p_grid_fe `p_grid_fe'
local p_grid_fe_plcaebo: di %9.3fc `p_fe_placebo' 
estadd local p_grid_fe_plcaebo `p_grid_fe_plcaebo'
local n_grid_fe: di %9.0fc `n_grid' 
estadd local n_grid_fe `n_grid_fe'

grid_p max_re705_2018, robust 
local p_fe = e(p_grid_fe)
local p_fe_placebo = e(p_grid_fe_placebo)
local n_grid = e(n_grid_fe)

regress placebo_re705_2018 yield_tons_hectare_2018, robust
local placebo = e(r2_a)
eststo: regress max_re705_2018 yield_tons_hectare_2018, robust
local placebo_r2a: di %9.3fc  `placebo'
estadd local placebo_r2a `placebo_r2a'
local p_grid_fe: di %9.3fc `p_fe' 
estadd local p_grid_fe `p_grid_fe'
local p_grid_fe_plcaebo: di %9.3fc `p_fe_placebo' 
estadd local p_grid_fe_plcaebo `p_grid_fe_plcaebo'
local n_grid_fe: di %9.0fc `n_grid' 
estadd local n_grid_fe `n_grid_fe'

grid_p max_mtci_2018, robust 
local p_fe = e(p_grid_fe)
local p_fe_placebo = e(p_grid_fe_placebo)
local n_grid = e(n_grid_fe)

regress placebo_mtci_2018 yield_tons_hectare_2018, robust
local placebo = e(r2_a)
eststo: regress max_mtci_2018 yield_tons_hectare_2018, robust
local placebo_r2a: di %9.3fc  `placebo'
estadd local placebo_r2a `placebo_r2a'
local p_grid_fe: di %9.3fc `p_fe' 
estadd local p_grid_fe `p_grid_fe'
local p_grid_fe_plcaebo: di %9.3fc `p_fe_placebo' 
estadd local p_grid_fe_plcaebo `p_grid_fe_plcaebo'
local n_grid_fe: di %9.0fc `n_grid' 
estadd local n_grid_fe `n_grid_fe'

grid_p max_lai_2018, robust 
local p_fe = e(p_grid_fe)
local p_fe_placebo = e(p_grid_fe_placebo)
local n_grid = e(n_grid_fe)

regress placebo_lai_2018 yield_tons_hectare_2018, robust
local placebo = e(r2_a)
eststo: regress max_lai_2018 yield_tons_hectare_2018, robust
local placebo_r2a: di %9.3fc  `placebo'
estadd local placebo_r2a `placebo_r2a'
local p_grid_fe: di %9.3fc `p_fe' 
estadd local p_grid_fe `p_grid_fe'
local p_grid_fe_plcaebo: di %9.3fc `p_fe_placebo' 
estadd local p_grid_fe_plcaebo `p_grid_fe_plcaebo'
local n_grid_fe: di %9.0fc `n_grid' 
estadd local n_grid_fe `n_grid_fe'

esttab using "tables/t5/sat_vs_fr.tex", replace se noobs ///
not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels frag b(%9.3fc) scalars("N Observations" "r2_a Adjusted \$R^2$" "placebo_r2a Placebo adjusted \$R^2$" "n_grid_fe Observations" "p_grid_fe p-value" "p_grid_fe_plcaebo Placebo p-value") ///
sfmt(%9.0fc %9.3fc %9.3fc %9.0fc %9.3fc %9.3fc)
