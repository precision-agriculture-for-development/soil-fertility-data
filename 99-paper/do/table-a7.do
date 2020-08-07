use "$final_data", clear 

// Create a t-a7 folder to store outputs if it doesn't exist 
capture confirm file "tables/t-a7/"
if _rc mkdir "tables/t-a7/"

*************************************************************
* Panel A: Share of plot on which fertilizer was applied, conditional on non-zero application, by treatment 
* Basal fertilizer dose 
*************************************************************

// Initiate the output LaTex file 
cap file close handle
file open handle using "tables/t-a7/panel-a.tex", write replace

local fmt "%9.3fc"

foreach x in "UREA" "DAP" "MOP" "ZINC" {
	summarize `x'_fraction_basal if treatment == 0 & `x'_fraction_basal > 0, detail
	local control_mean = r(mean)
	local control_mean: di `fmt' `control_mean'
	local control_sd = r(sd) 
	local control_sd: di `fmt' `control_sd'
	local control_sd = subinstr("`control_sd'"," ","",.)
	local control_n = r(N)
	local control_n: di %9.0fc `control_n'
	summarize `x'_fraction_basal if treatment == 1 & `x'_fraction_basal > 0, detail
	local treatment_mean = r(mean)
	local treatment_mean: di `fmt' `treatment_mean'
	local treatment_sd = r(sd) 
	local treatment_sd: di `fmt' `treatment_sd'
	local treatment_sd = subinstr("`treatment_sd'"," ","",.)
	local treatment_n = r(N)
	local treatment_n: di %9.0fc `treatment_n'
	if "`x'" == "ZINC" {
		file w handle "Zinc & `control_mean' & `treatment_mean' \\ " _n
		file w handle " & [`control_sd'] & [`treatment_sd'] \\" _n
		file w handle " & N: `control_n' & N: `treatment_n' \\ " _n
	}
	else {
		file w handle "`x' & `control_mean' & `treatment_mean' \\ " _n
		file w handle " & [`control_sd'] & [`treatment_sd'] \\ " _n
		file w handle " & N: `control_n' & N: `treatment_n' \\ [1em] " _n
	}
}

file close handle

*************************************************************
* Panel B: Share of plot on which fertilizer was applied, conditional on non-zero application, by treatment 
* Average across all doses
*************************************************************

// Initiate the output LaTex file 
cap file close handle
file open handle using "tables/t-a7/panel-b.tex", write replace

foreach x in "urea" "dap" "mop" "zinc" {
	summarize `x'_fraction_average if treatment == 0 & `x'_fraction_average > 0, detail
	local control_mean = r(mean)
	local control_mean: di `fmt' `control_mean'
	local control_sd = r(sd) 
	local control_sd: di `fmt' `control_sd'
	local control_n = r(N)
	local control_n: di %9.0fc `control_n'
	summarize `x'_fraction_average if treatment == 1 & `x'_fraction_average > 0, detail
	local treatment_mean = r(mean)
	local treatment_mean: di `fmt' `treatment_mean'
	local treatment_sd = r(sd) 
	local treatment_sd: di `fmt' `treatment_sd'
	local treatment_n = r(N)
	local treatment_n: di %9.0fc `treatment_n'
	if "`x'" == "zinc" {
		file w handle "Zinc & `control_mean' & `treatment_mean' \\ " _n
		file w handle " & [`control_sd'] & [`treatment_sd'] \\ " _n
		file w handle " & N: `control_n' & N: `treatment_n' \\ " _n
	}
	else {
		local varname = upper("`x'")
		file w handle "`varname' & `control_mean' & `treatment_mean' \\ " _n
		file w handle " & [`control_sd'] & [`treatment_sd'] \\ " _n
		file w handle " & N: `control_n' & N: `treatment_n' \\ [1em] " _n
	}
}

file close handle
