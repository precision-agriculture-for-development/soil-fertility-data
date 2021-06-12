use "$final_data", clear 

// Create a t2 folder to store outputs if it doesn't exist 
capture mkdir "tables/t2/"

foreach x of varlist listen_prop* {
	replace `x' = 0 if missing(`x') //This means they weren't in the system so definitely didn't hear the call
}

egen listening_rate = rowmean(listen_prop*)
label var listening_rate "\makecell[c]{KT call \\ listening rate}"

foreach x of varlist pickup_rate* {
	dis in red "`x'"
	replace `x' = "1" if `x' == "y"
	replace `x' = "0" if `x' == "n"
	destring `x', replace 
	dis in red "`x'"
	replace `x' = 0 if missing(`x') //This means they weren't in the system so definitely didn't hear the call
}

egen pickup_rate = rowmean(pickup_rate*) 
label var pickup_rate "\makecell[c]{KT call \\ pickup rate}"

label var tot_qs "\makecell[c]{Questions \\ asked}"
replace tot_qs = 0 if missing(tot_qs)

label var fert_question "\makecell[c]{Fertilizer \\ questions asked}"
replace fert_question = 0 if missing(fert_question)

egen correct_questions = rowtotal(e*_correct), missing 
label var correct_questions "\makecell[c]{Number of \\ fertilizer questions \\ correct}"

replace trust_mobile_phone = 6 - trust_mobile_phone  // Originally coded from 1 (very high trust) to 5 (very low trust)

****************************************************************************************************************
* Panel A: Full sample 
****************************************************************************************************************

eststo clear 

eststo: regress pickup_rate treatment i.block_id, robust 
summarize pickup_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'

eststo: regress listening_rate treatment i.block_id, robust 
summarize listening_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress rating treatment i.block_id, robust 
summarize rating if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress info_mobile_phone treatment i.block_id, robust 
summarize info_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress trust_mobile_phone treatment i.block_id, robust 
summarize trust_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress correct_questions treatment i.block_id, robust 
summarize correct_questions if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

esttab using "tables/t2/kt_panel_a.tex", replace se noobs rename((1) treatment) frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
indicate("Block FE = *block*") noconstant b(%9.3fc)


****************************************************************************************************************
* Panel B: Farmer-reported yield 
****************************************************************************************************************

eststo clear 

preserve 

keep if fr_yield_sample == 1

eststo: regress pickup_rate treatment i.block_id, robust 
summarize pickup_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'

eststo: regress listening_rate treatment i.block_id, robust 
summarize listening_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress rating treatment i.block_id, robust 
summarize rating if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress info_mobile_phone treatment i.block_id, robust 
summarize info_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress trust_mobile_phone treatment i.block_id, robust 
summarize trust_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress correct_questions treatment i.block_id, robust 
summarize correct_questions if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

esttab using "tables/t2/kt_panel_b.tex", replace se noobs rename((1) treatment) r2 frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
indicate("Block FE = *block*") noconstant b(%9.3fc)

restore 

****************************************************************************************************************
* Panel C: Satellite yield sample 
****************************************************************************************************************

eststo clear 

preserve 

keep if satellite_yield_sample == 1

eststo: regress pickup_rate treatment i.block_id, robust 
summarize pickup_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'

eststo: regress listening_rate treatment i.block_id, robust 
summarize listening_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress rating treatment i.block_id, robust 
summarize rating if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress info_mobile_phone treatment i.block_id, robust 
summarize info_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress trust_mobile_phone treatment i.block_id, robust 
summarize trust_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress correct_questions treatment i.block_id, robust 
summarize correct_questions if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

esttab using "tables/t2/kt_panel_c.tex", replace se noobs rename((1) treatment) r2 frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
indicate("Block FE = *block*") noconstant b(%9.3fc)

restore 

****************************************************************************************************************
* Panel D: Intersecting sample 
****************************************************************************************************************

eststo clear 

preserve 

keep if intersecting_sample == 1

eststo: regress pickup_rate treatment i.block_id, robust 
summarize pickup_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'

eststo: regress listening_rate treatment i.block_id, robust 
summarize listening_rate if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress rating treatment i.block_id, robust 
summarize rating if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress info_mobile_phone treatment i.block_id, robust 
summarize info_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress trust_mobile_phone treatment i.block_id, robust 
summarize trust_mobile_phone if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

eststo: regress correct_questions treatment i.block_id, robust 
summarize correct_questions if treatment == 0, meanonly 
local varMean: di %9.3f `r(mean)' 
estadd scalar depMean = `varMean'

esttab using "tables/t2/kt_panel_d.tex", replace se noobs rename((1) treatment) r2 frag not label tex star(* 0.10 ** 0.05 *** 0.01) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean") sfmt(%9.0fc %9.3fc %9.3fc) ///
indicate("Block FE = *block*") noconstant b(%9.3fc)

restore 
