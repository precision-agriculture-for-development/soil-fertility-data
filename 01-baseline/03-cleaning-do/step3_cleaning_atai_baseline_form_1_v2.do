clear all
version 14
cap log close
set more off
set maxvar 20000
/****************************************************************************
Note: requieres missings (ssc)

This file will not run because it relies on variables with PII. It is provided with the minimal possible edits for reference.
****************************************************************************/

*specify main path
cd "INSERT PATH"

*Input data
loc raw "01-baseline/02-raw-data/form_one/ATAI_Baseline_Test.dta"

*Output data
loc clean "04-cleaned-data/form_one/ATAI_baseline_survey_clean.dta"


use "`raw'"

*Check uids

drop if key == "uuid:b56371fb-681a-43ab-b622-155b6b61b32a" //same survey uploaded twice
drop if key == "uuid:1316b0dd-9715-4986-b590-ed3a22aef32f" // Respondent change survey wasn't filled properly. Supervisor filled the form again correctly selecting the correct respondent.
drop if key == "uuid:9a69ce6f-933f-42dd-8a73-adbbbbcc5f23" // same survey uploaded twice
drop if key == "uuid:00fe0e4d-b724-4efd-9c90-8f566c7739a0"  // Form 1 uploaded by mistake. It was restored and sent along with form 2 that was filled in revisit.
drop if key == "uuid:89a0cf90-533d-4de9-a48d-317023a8c2de"
drop if key == "uuid:e9e18d25-c41a-40f5-8f42-d92de9f5ab6f"
drop if key == "uuid:7d28a41d-6bd6-4119-84b5-59b20ad86580" // Survey REDONE
drop if key == "uuid:2e19648b-cef2-456b-9ace-9fd286039d48" // Declined at intro
drop if key == "uuid:3592a275-4e22-46c3-9cac-388a2ff156b0" // Declined at intro
drop if key == "uuid:1bbe9481-d7ef-4560-8d3e-25e211b9f486" // Declined at intro
drop if key == "uuid:493b9891-3e6f-4475-9c81-50f4f416a0dc" // Declined at intro

*5/08/2018
drop if key =="uuid:064d6e0d-63f1-4753-9b59-96b07de9cdb7" // Surveyor filled this form with a no consent where it was a case of respondent change. He filled the correct form later.
drop if key =="uuid:c3b487f3-4d0f-425a-be6f-ec8e54bc1fbf" // Surveyor filled this form with a no consent where it was a case of respondent change. Correct form was filled later.
drop if key =="uuid:73263ca5-ae0a-47b2-afcf-0b42e252a885" // Surveyor filled this form with selecting a wrong uid. Form was filled again with correct uid.
drop if key =="uuid:8c04efd7-e55b-4bfe-8e6e-5c4066c72276" // Surveyor filled this form with selecting a wrong uid. Form was filled again with correct uid.
drop if key =="uuid:58637062-9ca8-48f7-8c15-e6afb4b834a6" // Wrong uid entered while filling the form. Reenterd the survey using correct ID.
drop if key =="uuid:0420a591-0387-4ea4-9783-a27aea2635bc" //a4_1 was filled 0 by mistake. Form was refilled.
drop if key =="uuid:50fb8217-0100-4c57-9e92-d6ac9d76365e" // Respondent was already surveyed before. Form filled by surveyor's mistake

*5/09/2018
drop if key =="uuid:4dc25f83-7d03-45f7-bb16-5745fcf7cebb" // This survey was done on the first day of baseline where the respondent said he wouldn't grow cotton. Later he changed his mind and the survey was done again.
drop if key =="uuid:e25aef2f-13c2-49e2-a11f-04138173710b" // This survey was done on the first day of baseline where the respondent said he wouldn't grow cotton. Later he changed his mind and the survey was done again.
drop if key =="uuid:eb6318e3-d7e7-4944-83b4-1f940eb06dcf" // Change of respondent survey was filled twice
drop if key =="uuid:ad88c1ec-50f9-4cf5-8f90-ecf561e82683" // Form 1 was filled and uploaded on 17 march. Later retrieved and uploaded with form 2.
drop if key =="uuid:a5b7df5b-364c-4c26-99bb-b8bad0557191" // Same survey uploaded twice.
drop if key =="uuid:ddc4f89b-68b3-4dee-baff-08ae832ea1cd" // Same survey uploaded twice.
drop if key =="uuid:b493065d-5755-4410-8325-fefa7676ad71" // Form 1 was filled and uploaded on 23 march. Later retrieved and uploaded with form 2.
drop if key =="uuid:b8714891-558a-4d13-a3a9-9b637d7e3922" // Form 1 was filled and uploaded on 19 march. Later retrieved and uploaded with form 2.
drop if key =="uuid:6be42cc0-e6fc-4e43-807a-bf5326ac68f4" // Same survey uploaded twice.
drop if key =="uuid:64320888-836b-4357-a732-bf0b880af9d4" // Form 1 was filled and uploaded on 28 march. Later retrieved and uploaded with form 2.
drop if key =="uuid:a2b7963a-3c11-4d7b-82d5-d1a97ef213f5" // Form 1 was filled and uploaded on 28 march. Later retrieved and uploaded with form 2.
drop if key =="uuid:8431be66-9760-44fb-9c9b-a7438ccaae99" // Same survey uploaded twice.
drop if key =="uuid:88c94f99-a933-4bfc-9485-8f4db0712bdd" // Case of Rejection. Respondent works from a different place. The form was filled twice as second attempt.
drop if key =="uuid:b394ef24-470d-4502-aee5-aa17de3cf35c" // Respondent rejected at first as he was busy.

drop if key =="uuid:38ba08ca-4808-4a8f-83f0-9c7eb2ac3d9e" // Declined at intro

replace a4_1 = 1 if key == "uuid:c64e9107-bd72-4ca5-b762-15ba7fdff8f6"  //date entry error	
replace a5=1 if key =="uuid:58aa8942-c1d8-4a9e-8663-3b8e337ce5b3" // Respondent was attempted and this is a case of respondent change. The surveyor selected respondent is not coming now which wasn't the case.	
replace a5=0 if key =="uuid:a74750e3-6f72-4875-b205-3e9851b17482" // Respondent was attempted and this is a case of respondent change. The surveyor selected respondent is coming now which wasn't the case.

*05/11/2018	
drop if key=="uuid:8b2c000d-8c51-417e-a229-782a77639550" // Respondent not at village. Form was filled twice.
drop if key=="uuid:3ce19987-d4b0-49e7-831e-5ac21f4c665c" // Respondent did't give consent at first as he was busy. Later he agreed and did the survey with us.
drop if key=="uuid:85507116-2a97-41f3-9542-6b96fbc324a2" // Respondent not in village. Same form was filled twice
drop if key=="uuid:d2301994-d6e4-4f78-8382-9a43c379faab" //Respondent change case- Survey was first filled as a no consent. Later corrected and sent again
drop if key=="uuid:8ef65c31-9b8d-4272-910c-daf7d15fd0c5" //Respondent first was not planning to grow cotton. Later when we called for backchecking, he said he will grow. We did a revisit and survey him	
	
*05/12/2018
drop if key=="uuid:fd0c12c8-55f1-4d34-b5be-76722108844b" // Case of respondent change. Changed respondent not available so the form was filled again with no consent.
drop if key=="uuid:ea1601ac-a5c5-474e-aeb6-465a4e3086fe" // Both no consent survey. Kept which was done latest.
drop if key=="uuid:b67077d3-e68f-46eb-b471-d928cfa95ce8" // Change of respondent form wasn't filled with correct entries. Form filled again.
drop if key=="uuid:93a24a22-9e3f-469d-abe2-1804d66cb66f" // Change of respondent form wasn't filled with correct entries. Form filled again.
drop if key=="uuid:91eee6fa-e2d8-446b-b45a-f3df026129b6" // Two respondents were surveyed for two different plots of the same owner. Keeping the one with Largest plot size. 
drop if key=="uuid:ff610b73-b0ca-4ab2-b815-afb5e757f754" | key=="uuid:fc7bb43b-5969-4596-924f-d307a5ad3260" // Drop these as are the same survey uploaded thrice
drop if key=="uuid:d75970c8-eadd-4e6b-b00d-1d8f70bddb76" | key=="uuid:4a4c47c1-f822-4ca7-8ac1-1f5a5e61f9ed" // Drop these as are the same survey uploaded thrice
	
	
	
*complete survey (check)
gen complete = continue_2 == "1"

la def yesno 1 yes 0 no

local recode_mv	b0 b10 b12 ///
				c1 c2 ///
				d1_3 d2_3_1 d2_3_2 d2_3_3 d2_3_4 d2_3_5 d2_3_6 d2_3_7 d2_3_8 d2_3_9 d2_3_10 d2_3_11 ///
				v12 v52 ///
				e1 e3_1 e4_1 e5_1 e5_2_1 e5_3_1 e5_3_2 e5_4_1 e6_1 e6_3 e7_1 e7_3 e8_1 e8_3 ///
				m1_4_q_1 m1_4_q_2 m1_4_q_3 m1_4_q_4 m1_4_q_5 m1_4_q_6 m1_4_q_7 m1_4_q_8 m1_4_q_9 m1_4_q_10 m1_4_q_11 ///
				p6_1 ///
				g2_1_1 g2_1_2 g2_1_3 g2_1_4 g2_1_5 g2_1_6 ///
				g2_5_1 g2_5_2 g2_5_3 g2_5_4 g2_5_5 g2_5_6 ///
				g1_1 g1_3 g3_1 g3_3 g4_1 g4_3
				

*Convert -888 (Does not know) and -999 (Does not reply/answer) to missing values
foreach var in `recode_mv' {

	replace `var' = .k if `var' == -888
	replace `var' = .r if `var' == -999 
	}


/*******************************************************************************
SECTION X
********************************************************************************/

**survey date
gen double aux1 = date(date_f, "DMY") if date_v == 1
gen double aux2 = date(date_f, "YMD") if date_v == 0
gen aux = aux1 if date_v == 1, after(date_f)
replace aux = aux2 if date_v == 0 
format aux %td
drop aux1 aux2 date date_v date_a date_f
rename aux date

**time 
gen double aux1 = clock(time, "hms") if time_v == 1
gen double aux2 = clock(time_a, "hms") if time_v == 0
gen aux = aux1 if time_v == 1, after(time_f)
replace aux = aux2 if time_v == 0 
format aux %tcHH:MM:SS
drop aux1 aux2 time_f
rename aux time_f

**name
gen name_f = "", after(x1_2)
gen aux = x1_3_1 + " " + x1_3_2 + " " + x1_3_3 if x1_2 == 0
replace name_f = aux if x1_2 == 0
replace name_f = name if x1_2 == 1
replace name_f = lower(itrim(trim(name_f)))

drop aux x1_3_1	x1_3_2	x1_3_3
		
**gender
gen gender_f = . , after(x1_4)
replace gender_f = x1_5 if x1_4 == 0
replace gender_f = 1 if x1_4 == 1 & gender == "MALE"
replace gender_f = 0 if x1_4 == 1 & gender == "FEMALE"
la copy x1_5 gender
la val gender_f gender
drop x1_5

**Check uid B04V52F1438 gender is missing

**mobile number
gen mobile_number_f = "" , after(x1_6_0_1)
replace mobile_number_f = mobile_number if x1_6_0 == 0 & x1_6_0_1 == .
replace mobile_number_f = mobile_number if x1_6_0 == 1
replace mobile_number_f = mobile_number_alt if x1_6_0_1 == 1
drop x1_7 x1_8

*mobile number corrections based on 21-05-2018.xlsx
replace mobile_number_f = "OMITTED" if uid == "B04V46F1322"
replace mobile_number_f = "OMITTED" if uid == "B02V17F0517" & name_f == "OMITTED"


/*******************************************************************************
SECTION A
********************************************************************************/

rename a2_1 surveyor
rename a2_2 supervisor


destring not_eligible, replace
la val not_eligible yesno
la var not_eligible "Respondent is not eligible"

*Consent
la var no_consent_1 "Is not interested"
la var no_consent_2	"Does not want to participate in any survey"
la var no_consent_3	"Does not want to give soil sample"
la var no_consent_4	"It requieres too much time"
la var no_consent_5	"Is busy"
la var no_consent_777 "Other" 

foreach var of varlist no_consent_1 - no_consent_777 {
	la val `var' yesno
	note `var' : "Could you please tell the reason for refusal?"
	}


/*******************************************************************************
SECTION B
********************************************************************************/

rename b0 age
rename b2 school
la var school "Attended school"

gen household_head = cond(missing(b1),.,cond(b1==1,1,0)), before(b1)
la var household_head "Head of the household"
la val household_head yesno

rename b10 children
drop b10_r

gen pucca_house = cond(missing(b11),.,cond(b11==1,1,0)), before(b11)
la var pucca_house "Resides in a pucca house (strong structure)"
la val pucca_house yesno

gen primary_occupation_farming = cond(missing(b12),.,cond(b12==1,1,0)), before(b12)
la var primary_occupation_farming "Primary occupation is self-employed farming"
la val primary_occupation_farming yesno

*knows how to read and write




/*******************************************************************************
SECTION C
********************************************************************************/
rename c1 household_size 
la var household_size "Household size"
drop c1_r

rename c2 household_members_farming

*sources of income
la var c3_1	"Agriculture harvest"
la var c3_2	"Agriculture labor"
la var c3_3	"Own farming enterprise"
la var c3_4	"Non-agriculture labor"
la var c3_5	"Household business/trade"
la var c3_6	"Rent"
la var c3_7	"Employment generation schemes"
la var c3_8	"Remittances"
la var c3_9	"Interests and dividends"
la var c3_10 "Pensions"
la var c3_11 "Gifts/donations"
la var c3_12 "Government job/permanent job"
la var c3_777 "Other"
la var c3_999 "Does not answer"

foreach var of varlist c3_1 - c3_999 {
	la val `var' yesno
	note `var' : "What are the main sources of income of the household during the Kharif season in 2017?"
	}

/*******************************************************************************
SECTION D
********************************************************************************/
*Fix UID "B04V50F1406"
replace rank_2_plot = "3" if uid=="B04V50F1406"
replace rank_2_size = "7.5" if uid =="B04V50F1406"
replace rank_2_ir = "1" if uid =="B04V50F1406"
replace secondary_plot = "3" if uid =="B04V50F1406"
replace secondary_plot_size = "7.5" if uid =="B04V50F1406"
replace secondary_plot_marker = "OMITTED" if uid =="B04V50F1406"


qui summ d1_3

gen total_cotton_land = 0 if d1_3!=., after(d1_3)
la var total_cotton_land "Total cotton land in Kharif 2017 in bigha"

forvalues j = 1/`r(max)' {

	replace d2_1_`j' = lower(itrim(trim(d2_1_`j')))
	
	gen plot_size_`j' = . , before(d2_3_`j')
	replace plot_size_`j' = d2_3_`j'		if d1_1 == 1 /*bigha*/
	replace plot_size_`j' = d2_3_`j' * 2.5	if d1_1 == 2 /*acre*/
	replace plot_size_`j' = d2_3_`j' * 6.25	if d1_1 == 3 /*hectare*/
	
	/*Guntha units*/
	replace plot_size_`j' = d2_3_`j' * (1/40) * 2.5 if uid == "B01V08F0211"	 /*uid = B01V08F0211 reported guntha with an equivalence 1 acre = 40 guntha*/
	
	la var plot_size_`j' "Plot `j' size in bigha"
	
	destring cotton_plot_`j' eligible_plot_`j' , replace
	la val cotton_plot_`j' eligible_plot_`j' yesno
	
	la var cotton_plot_`j' "Grew cotton in plot `j' in Kharif season 2017"
	la var eligible_plot_`j' "Plot `j' is eligible"
	
	/*Total cotton land in Kharif 2017*/
	replace total_cotton_land = total_cotton_land + plot_size_`j' if cotton_plot_`j' == 1 & plot_size_`j' <.
	
	drop d2_0_`j' eligible_plot_marker_`j' eligible_plot_size_`j' plot_rank_`j' plot_ir_`j'	rank_1_`j'	rank_2_`j'
	
	}
	
	
drop d1_3r d2_count d2_3_r_* list_of_plot_size

destring	cotton_plots eligible_plots	rank_1_plot	rank_2_plot	rank_1_size	rank_2_size ///
			rank_1_ir rank_2_ir primary_plot secondary_plot primary_plot_size secondary_plot_size ///
			case_v1	case_v2	case_v3, replace

replace secondary_plot_size = .a if secondary_plot_size == -999			
			
la val case_v1 case_v2 case_v3 yesno

la var cotton_plots "Number of plots in which farmer grew cotton in Kharif season 2017"
la var eligible_plots "Number of eligible plots"
la var case_v1 "Respondent has no eligible plots"
la var case_v2 "Respondent has only one eligible plot"
la var case_v3 "Respondent has more than one eligible plots"

drop rank_1_plot rank_2_plot rank_1_size rank_2_size rank_1_ir rank_2_ir primary_plot secondary_plot ///
primary_plot_size secondary_plot_size primary_plot_marker secondary_plot_marker

			
/*******************************************************************************
SECTION V
********************************************************************************/

*Fix UID "B04V50F1406"
replace applicable_plot_marker = "OMITTED" if uid == "B04V50F1406"
replace	applicable_plot_size = "7.5" if uid == "B04V50F1406"

rename v12 v1_2
rename v52 v5_2

*Fix wrong relevance pattern in the form
replace v5_2 = . if v5 == 0

destring applicable	already_applicable_plot applicable_plot_size, replace
la val applicable	already_applicable_plot yesno

la var applicable "Survey is applicable"
la var already_applicable_plot	"Surveyor is already at the applicable plot"
la var applicable_plot_marker "Applicable plot marker"
la var applicable_plot_size	"Applicable plot size"



/*******************************************************************************
SECTION E
********************************************************************************/

**Correction based on HFC files
replace e5_1	= 3			if	uid ==	"B01V08F0203"
replace e7_1	= 120		if	uid ==	"B04V44F1260"
replace e5_1	= 2			if	uid ==	"B01V10F0285"
replace e5_4_1	= 1500000	if	uid ==	"B02V16F0478"
replace e5_1	= 3			if	uid	==	"B04V52F1449"

replace e8_1	= 8			if	uid	==	"B04V52F1449"
replace e8_2	= 1			if	uid	==	"B04V52F1449"
replace e8_3	= 1			if	uid	==	"B04V52F1449"

replace e5_1	= 1			if	uid	==	"B02V17F0511"
replace e5_1	= 1			if	uid	==	"B02V17F0505"

replace e5_2_2	= 2			if	uid ==	"B02V25F0739"

replace e6_1	= 13		if	uid	==	"B04V53F1458"
replace e6_3	= 1			if	uid ==	"B04V53F1458"

replace e5_1	= 3			if	uid	==	"B03V39F1171"
replace e5_1	= 1			if	uid	==	"B03V37F1107"

replace e6_4	= 1			if	uid ==	"B02V26F0768"

replace e6_2	= 2 		if	uid ==	"B02V17F0510"
replace e6_2	= 2 		if	uid ==	"B03V33F0987"
replace e6_2	= 2 		if	uid ==	"B05V62F1729"

replace e8_2	= 2 		if	uid ==	"B04V45F1299"
replace e8_2	= 2 		if	uid ==	"B04V52F1440"

replace e1		= 2			if	uid ==	"B02V22F0672"

replace e5_1	= 4			if	uid	==	"B01V01F0004"
replace e5_1	= 2			if	uid	==	"B01V04F0105"
replace e5_1	= 1			if	uid	==	"B01V05F0145"
replace e5_1	= 3			if	uid	==	"B01V07F0179"
replace e5_1	= 4			if	uid	==	"B01V11F0314"
replace e5_1	= 1			if	uid	==	"B05V57F1582"
replace e5_1	= 4			if	uid	==	"B06V73F2072"

replace e8_1	= 120		if	uid	==	"B02V14F0391"
replace e6_1	= 100		if	uid	==	"B03V31F0918"
replace e6_1	= -888		if	uid	==	"B05V62F1732"
replace e6_1	= 15		if	uid	==	"B06V75F2138"

replace e6_1	= 300		if	uid	==	"B05V65F1817"
replace e5_4_1	= 125000	if	uid	==	"B01V01F0020"
replace e5_4_1	= 200000	if	uid	==	"B06V75F2141"
replace e5_4_1	= 450000	if	uid	==	"B06V77F2203"
replace e6_1	= 100		if	uid	==	"B03V31F0918"
replace e7_1	= 300		if	uid	==	"B02V22F0671"
replace e8_1	= 500		if	uid	==	"B04V54F1509"

replace e3_1	= 120	if	uid	==	"B05V63F1762"
replace e3_1	= 110	if	uid	==	"B05V65F1819"
replace e3_1	= 123	if	uid	==	"B05V65F1825"

replace e6_1= 15 if uid =="B06V75F2138"






*Quantity harvested in kg
gen quantity_harvested = . , before(e3_1)
replace quantity_harvested = e3_1		if e3_2 == 1 /*kg*/
replace quantity_harvested = e3_1 * 20	if e3_2 == 2 /*maund*/
replace quantity_harvested = e3_1 * 100	if e3_2 == 3 /*quintal*/
**replace quantity_harvested = 			if e3_2 == 4 /*pula*/
replace quantity_harvested = .k			if e3_2 == 888 /*dont know/remember*/
la var quantity_harvested "Total cotton harvested in kg"

*Quantity sold in kg
gen quantity_sold = . , before(e4_1)
replace quantity_sold = e4_1		if e4_2 == 1 /*kg*/
replace quantity_sold = e4_1 * 20	if e4_2 == 2 /*maund*/
replace quantity_sold = e4_1 * 100	if e4_2 == 3 /*quintal*/
**replace quantity_sold = 			if e4_2 == 4 /*pula*/
replace quantity_sold = .k			if e4_2 == 888 /*dont know/remember*/
la var quantity_sold "Total cotton sold in kg"

*Largest sale in kg
gen largest_sale = . , before(e5_2_1)
replace largest_sale = e5_2_1		if e5_2_2 == 1 /*kg*/
replace largest_sale = e5_2_1 * 20	if e5_2_2 == 2 /*maund*/
replace largest_sale = e5_2_1 * 100	if e5_2_2 == 3 /*quintal*/
**replace largest_sale = 			if e5_2_2 == 4 /*pula*/
replace largest_sale = .k			if e5_2_2 == 888 /*dont know/remember*/
la var largest_sale "Cotton sold in largest sale in kg"

*Price from largest sale in Rupees per kg
gen q_aux = ., before(e5_3_1)
replace q_aux = e5_3_2			if e5_3_3 == 1 /*kg*/
replace q_aux = e5_3_2 * 20		if e5_3_3 == 2 /*maund*/
replace q_aux = e5_3_2 * 100	if e5_3_3 == 3 /*quintal*/
**replace q_aux = 				if e5_3_3 == 4 /*pula*/
replace q_aux = .k				if e5_3_3 == 888 /*dont know/remember*/

gen price_largest_sale = ., before(e5_3_1)
replace price_largest_sale = e5_3_1 / q_aux
replace price_largest_sale = .k if e5_3_1 == -888
la var price_largest_sale "Cotton price in largest sale in Rs/kg"

drop q_aux

* Revenue
gen revenue = e5_4_1, after(e5_4_1)
la var revenue "Cotton revenue"

*Price (implicit in total revenue)
gen price = revenue /quantity_sold , after(e5_4_1)
la var price "Cotton price in RS/kg"

**Harvest in typical year
gen yield_typical_year = ., before(e6_1)

gen aux = .
replace aux = e6_3 					if e6_4 == 1 /*bigha*/
replace aux = e6_3 * 2.5			if e6_4 == 2 /*acre*/
replace aux = e6_3 * 6.25			if e6_4 == 3 /*hectare*/
replace aux = e6_3 * (1/40) * 2.5	if e6_4 == 4 & uid == "B01V08F0211" /*guntha*/



replace e6_1 = .k if e6_1 == -888

replace yield_typical_year = e6_1		if e6_2 == 1 /*kg*/
replace yield_typical_year = e6_1 * 20	if e6_2 == 2 /*maund*/
replace yield_typical_year = e6_1 * 100	if e6_2 == 3 /*quintal*/
**replace yield_typical_year = 			if e6_2 == 4 /*pula*/
replace yield_typical_year = .k			if e6_2 == 888 /*dont know/remember*/	

replace yield_typical_year = yield_typical_year / aux
drop aux

la var yield_typical_year "Cotton harvested in a typical year in kg per bigha"

**Harvest in a good year
gen yield_good_year = ., before(e7_1)

gen aux = .
replace aux = e7_3 			if e7_4 == 1 /*bigha*/
replace aux = e7_3 * 2.5	if e7_4 == 2 /*acre*/
replace aux = e7_3 * 6.25	if e7_4 == 3 /*hectare*/
**replace aux = e7_4 			if e7_5 == 4 /*guntha*/

replace e7_1 = .k if e7_1 == -888

replace yield_good_year = e7_1			if e7_2 == 1 /*kg*/
replace yield_good_year = e7_1 * 20		if e7_2 == 2 /*maund*/
replace yield_good_year = e7_1 * 100	if e7_2 == 3 /*quintal*/
**replace yield_good_year = 			if e7_2 == 4 /*pula*/
replace yield_good_year = .k			if e7_2 == 888 /*dont know/remember*/	

replace yield_good_year = yield_good_year / aux
drop aux

la var yield_good_year "Cotton harvested in a good year in kg per bigha"

**Harvest in a bad year
gen yield_bad_year = ., before(e8_1)

gen aux = .
replace aux = e8_3 			if e8_4 == 1 /*bigha*/
replace aux = e8_3 * 2.5	if e8_4 == 2 /*acre*/
replace aux = e8_3 * 6.25	if e8_4 == 3 /*hectare*/
**replace aux = e8_4 			if e8_5 == 4 /*guntha*/

replace e8_1 = .k if e8_1 == -888

replace yield_bad_year = e8_1		if e8_2 == 1 /*kg*/
replace yield_bad_year = e8_1 * 20	if e8_2 == 2 /*maund*/
replace yield_bad_year = e8_1 * 100	if e8_2 == 3 /*quintal*/
**replace yield_bad_year = 			if e8_2 == 4 /*pula*/
replace yield_bad_year = .k			if e8_2 == 888 /*dont know/remember*/	

replace yield_bad_year = yield_bad_year / aux
drop aux

la var yield_bad_year "Cotton harvested in a bad year in kg per bigha"


drop sold_t_units harvest_units

/*******************************************************************************
SECTION F
********************************************************************************/
rename f1_1 short_seeds
rename f1_2 medium_seeds
rename f1_3 long_seeds

foreach x in short medium long {
	la var `x'_seeds "Used `x' seeds in the Kharif season 2017"
	la val `x'_seeds yesno
	}
	
/* f3	Please tell me which was the most important factor for you in deciding which type of seed to use?

1	low price
2	pest resistance
3	safe yield
4	high yield
5	fewer input requirements
6	less water requirements
7	what friends and other farmers use
8	accessibility
9	increases soil fertility
777	other
888	does not know/remember
*/

la var f3_1 "Low price"
la var f3_2 "Pest resistance"
la var f3_3 "Safe yield"
la var f3_4 "High yield"
la var f3_5 "Fewer input requirements"
la var f3_6 "Less water requirements"
la var f3_7 "What friends and other farmers use"
la var f3_8 "Accessibility"
la var f3_9 "Increases soil fertility"
la var f3_777 "Other"
la var f3_888 "Does not know/remember"

foreach var of varlist f3_1 - f3_888 {
	la val `var' yesno
	}

/*******************************************************************************
SECTION H
********************************************************************************/
foreach var of varlist h1 h2 {
	gen `var'_dr = cond(`var' == 999, 1, 0) if `var' <. , after(`var')
	la val `var'_dr yesno
	}


/* h3	What was the new input or practice you adopted?

1	dug a bore well
2	used a type of new fertilizer
3	changed/experimented with fertilizer quantity
4	used a different type of pesticide
5	used a new machinery for a particular farming technique
6	tried inter-cropping
7	used a new variety of seeds
8	tried drip irrigation
9	tried organic inputs/organic farming
777	other
888	does not know/remember
999	does not answer
*/

foreach var of varlist h3_1 - h3_999 {
	la val `var' yesno	
}

la var h3_1 "Dug a bore well"
la var h3_2 "Used a type of new fertilizer"
la var h3_3 "Changed/experimented with fertilizer quantity"
la var h3_4 "Used a different type of pesticide"
la var h3_5 "Used a new machinery for a particular farming technique"
la var h3_6 "Tried inter-cropping"
la var h3_7 "Used a new variety of seeds"
la var h3_8 "Tried drip irrigation"
la var h3_9 "Tried organic inputs/organic farming"
la var h3_777 "Other well"
la var h3_888 "Does not know/remember"
la var h3_999 "Does not answer"
	
rename h3_888 h3_dk
rename h3_999 h3_dr



/*h4	What made you decide to try something new?

1	observing other farmers
2	recommendation from government
3	subsidized from government
4	recommended by friends or family
5	learnt from a trusted information source
6	decided myself to try it
777	other
888	does not know/remember
999	does not answer
*/

la var h4_1 "Observing other farmers"
la var h4_2 "Recommendation from government"
la var h4_3 "Subsidized from government"
la var h4_4 "Recommended by friends or family"
la var h4_5 "Learnt from a trusted information source"
la var h4_6 "Decided himself to try it"
la var h4_777 "Other"
la var h4_888 "Does not know/remember"
la var h4_999 "Does not answer"

foreach var of varlist h4_1 - h4_999 {
	la val `var' yesno	
}


rename h4_888 h4_dk 
rename h4_999 h4_dr

/*******************************************************************************
SECTION I
********************************************************************************/
replace i3 = 1 if i3 == 9	/*Radio in previous versions of the form*/
replace i3 = 6 if i3 == 10	/*Krushi Mela in previous version of the form*/

/*******************************************************************************
SECTION J
********************************************************************************/

foreach var of varlist j2 j3 j4 j8_1 j8_2 j8_3 j8_4 j8_5 j8_6 {

	gen `var'_dk = cond(`var' == 888, 1, 0) if `var' <. , after(`var')
	gen `var'_dr = cond(`var' == 999, 1, 0) if `var' <. , after(`var'_dk)

	la val `var'_dk yesno
	la val `var'_dr yesno
	
	replace `var' = .k if `var'_dk == 1
	replace `var' = .r if `var'_dr == 1
	
}

gen j5_dk = cond(j5 == 888, 1, 0) if j5 <. , after(j5)
la val j5_dk yesno
replace j5 = .k if j5_dk == 1


foreach var of varlist j8_1 j8_2 j8_3 j8_4 j8_5 j8_6 {

note `var' : "I will read out a nutrient. Please describe the test result for that nutrient."
}

drop j8_lbl

rename j1 soil_test_before


/*******************************************************************************
SECTION K
********************************************************************************/
foreach var of varlist k1 k2 k3 k4 k5 k6 {

	gen `var'_dk = cond(`var' == 888, 1, 0) if `var' <. , after(`var')
	gen `var'_dr = cond(`var' == 999, 1, 0) if `var' <. , after(`var'_dk)
	
	la val `var'_dk yesno
	la val `var'_dr yesno

	replace `var'_o = itrim(trim(lower(`var'_o)))
	
	}

/*******************************************************************************
SECTION L
********************************************************************************/

lab define risk 1 "1 (10%)" 2 "2 (20%)" 3 "3 (30%)" 4 "4 (40%)" 5 "5 (50%)" 6 "6 (60%)" 7 "7 (70%)" 8 "8 (80%)" 9 "9 (90%)" 10 "10 (100%)" .k "does not know" .r "does not answer"

foreach var of varlist l1_1 l1_2 l2  {
	gen `var'_dk = cond(`var' == 888, 1, 0) if `var' <. , after(`var')
	gen `var'_dr = cond(`var' == 9999, 1, 0) if `var' <. , after(`var'_dk)
	
	la val `var'_dk yesno
	la val `var'_dr yesno
	
	replace `var' = .k if `var'_dk == 1
	replace `var' = .r if `var'_dr == 1
	
	la val `var' risk
	
	}
	
lab define additional_income 1 "pay of loans" 2 "home improvements" 3 "purchasing agriculture inputs" 4 "purchasing durable goods" 5 "invest in other income generating activities" 6 "savings" 7 "increase consumption" 8 "on household events" 9 "on household members" 777 "other" .r "does not answer"
	
foreach var of varlist l3_1 l3_2 l3_3 {
	gen `var'_dr = cond(`var' == 999, 1, 0) if `var' <. , after(`var')
	
	la val `var'_dr yesno
	
	replace `var' = .r if `var'_dr == 1
	
	la val `var' additional_income
	
	}
	
rename l1_1 risk_attitude_agriculture
rename l1_2 risk_attitude_finance
rename l2	risk_attitude
		

/*******************************************************************************
SECTION M
*******************************************************************************/

*Economic shock resulting from problems with cotton crop
la var m1_0_1	"Drought/lack of water"
la var m1_0_2	"Flood"
la var m1_0_3	"Hail storm"
la var m1_0_4	"Lightening"
la var m1_0_5	"Rainstorm"
la var m1_0_6	"Insects"
la var m1_0_7	"Rodents"
la var m1_0_8	"Animals eating crops"
la var m1_0_9	"Theft"
la var m1_0_10	"Fire"
la var m1_0_11	"Other"
la var m1_0_888	"Does not know/remember"

foreach var of varlist m1_0_1 - m1_0_888 {
	la val `var' yesno
	note `var' : "In the Kharif season 2017, did your household experience an economic shock resulting from problems with cotton crop on your fields or in storage, for example, due to weather, fire, pests, animals, plant disease, or theft?"
}

*Estimated cotton loss in kg
forvalues j=1/11 {
	gen m1_4_`j' = . , before(m1_4_q_`j')
	replace m1_4_`j' = m1_4_q_`j'		if m1_4_u_`j' == 1 /*kilos*/
	replace m1_4_`j' = m1_4_q_`j' * 20	if m1_4_u_`j' == 2 /*maund*/
	replace m1_4_`j' = m1_4_q_`j' *	100	if m1_4_u_`j' == 3 /*quintal*/
	*replace m1_4_`j' = m1_4_q_`j' *	if m1_4_u_`j' == 4 /*pula*/
	replace m1_4_`j' = .k				if m1_4_u_`j' == 888 /*Does not know*/
	
	la var m1_4_`j' "Estimated cotton loss in kg"

	destring m1_5_1_`j' - m1_5_888_`j' , replace
	
	la val m1_5_1_`j' - m1_5_888_`j' yesno
	
	la var m1_5_1_`j' "Find other sources of income"
	la var m1_5_2_`j' "Plant another crop"
	la var m1_5_3_`j' "Borrow money"
	la var m1_5_4_`j' "Reduce food consumption"
	la var m1_5_5_`j' "Use savings"
	la var m1_5_6_`j' "Financial assistance and gifts"
	la var m1_5_7_`j' "Government insurance"
	la var m1_5_8_`j' "Other insurance"
	la var m1_5_9_`j' "Sold stored harvest"
	la var m1_5_10_`j' "Nothing"
	la var m1_5_777_`j'	"Other"
	la var m1_5_888_`j'	"Does not know/remember"
	}
	
drop m1r_count	m1_id_*	m1_lbl_*

*Household income shocks
la var m2_0_1	"Health problems in the household"
la var m2_0_2	"Accidents"
la var m2_0_3	"Employment reduction"
la var m2_0_4	"Natural disaster"
la var m2_0_5	"Death in the family"
la var m2_0_6	"Collapse in household business"
la var m2_0_7	"Other"
la var m2_0_888	"Does not know/remember"

foreach var of varlist m2_0_1 - m2_0_888 {
	la val `var' yesno
	note `var' : "In the last 12 months, did your household experience other unanticipated major reductions in income that affected the economic conditions of the household?"
	}

forvalues j=1/7 {

	destring m2_4_1_`j' - m2_4_888_`j' , replace
	
	la val m2_4_1_`j' - m2_4_888_`j' yesno
	
	la var m2_4_1_`j' "Find other sources of income"
	la var m2_4_2_`j' "Borrow money"
	la var m2_4_3_`j' "Reduce food consumption"
	la var m2_4_4_`j' "Use savings"
	la var m2_4_5_`j' "Financial assistance and gifts"
	la var m2_4_6_`j' "Government insurance"
	la var m2_4_7_`j' "Other insurance"
	la var m2_4_8_`j' "Nothing"
	la var m2_4_777_`j'	"Other"
	la var m2_4_888_`j'	"Does not know/remember"
	}
	
		
drop m2r_count m2_id_* m2_lbl_*
	
/*******************************************************************************
SECTION N
*******************************************************************************/

*Correction based on HFC
replace	n3_2	=	180000	if	uid	==	"B06V75F2132"
replace	n3_2	=	245000	if	uid	==	"B06V74F2114"

replace	n3_2	=	0		if	uid	==	"B05V56F1549"
replace	n3_2	=	160000	if	uid	==	"B06V74F2091"
replace	n3_2	=	130000	if	uid	==	"B06V75F2133"
replace	n3_2	=	300000	if	uid	==	"B06V75F2138"
replace	n3_2	=	650000	if	uid	==	"B06V79F2269"


	
	
gen bullocks_own = cond(missing(n1_1),.,cond(n1_1==1,1,0)), after(n1_1)
la var bullocks_own "Has bullocks"
la val bullocks_own yesno

gen tractor_own = cond(missing(n1_2),.,cond(n1_2==1,1,0)), after(n1_2)
la var tractor_own "Has a tractor"
la val tractor_own yesno

gen plough_own = cond(missing(n1_3),.,cond(n1_3==1,1,0)), after(n1_3)
la var plough_own "Has plough"
la val plough_own yesno

*savings
egen aux = rowtotal(n2_1_1 n2_1_2 n2_1_3 n2_1_4 n2_1_5), missing
gen savings = cond(missing(aux),.,cond(aux>=1,1,0)), before(n2_1_1)
drop aux
la var savings "Has savings"
la val savings yesno

foreach var of varlist n2_2_1 n2_2_2 n2_2_3 n2_2_4 n2_2_5 n3_2 {
	gen `var'_dk = cond(`var' == -888 | `var' == 888, 1, 0) if `var' <. , after(`var')
	gen `var'_dr = cond(`var' == -999 | `var' == 999, 1,0) if `var' <. , after(`var'_dk)
	
	la val `var'_dk yesno
	la val `var'_dr yesno
	
	replace `var' = .k if `var'_dk == 1
	replace `var' = .r if `var'_dr == 1
	}
	
egen savings_amount = rowtotal(n2_2_1 n2_2_2 n2_2_3 n2_2_4 n2_2_5), missing 
order savings_amount, after(savings)
la var savings_amount "Total savings (Rs)"
	
/* Loan*/
foreach var of varlist n3_3_1 - n3_3_999 {
	la val `var' yesno
	note `var' : "From where did you take these loans?"
	}
la var n3_3_1	"Advance from employer"
la var n3_3_2	"Loan from friends and family"
la var n3_3_3	"Loan from moneylender"
la var n3_3_4	"Loan from bank"
la var n3_3_5	"Loan from society"
la var n3_3_6	"Loan from SHG"
la var n3_3_777	"Other"
la var n3_3_888	"Does not know/remember"
la var n3_3_999	"Does not answer"

/*Insurance provider*/
foreach var of varlist n4_2_1 - n4_2_999 {
	la val `var' yesno
	note `var' : "From where did you take this insurance?"
	}
	
la var n4_2_1	"Government"
la var n4_2_2	"Scheduled bank"
la var n4_2_3	"Co-operative bank"
la var n4_2_4	"Credit society"
la var n4_2_5	"NGO"
la var n4_2_6	"Private insurance company"
la var n4_2_777	"Other"
la var n4_2_888	"Does not know/remember"
la var n4_2_999	"Does not answer"


/*Insurance for cotton in 2018*/
gen insurance_18 = cond(missing(n4_3),.,cond(n4_3 == 2,1,0)), after(n4_3)
la var insurance_18 "Has already purchased insurance for cotton in Kharif 2018"

gen insurance_plans_18 = cond(missing(n4_3),.,cond(n4_3 == 1,1,0)), after(insurance_18)
la var insurance_plans_18 "Plans to get insurance for cotton in Kharif 2018"

gen no_insurance_18 = cond(missing(n4_3),.,cond(n4_3 == 0,1,0)), after(insurance_plans_18)
la var no_insurance_18 "Wont get insurance for cotton in Kharif 2018"

la val insurance_18 - no_insurance_18 yesno


** Financial sources for upcoming agriculture expenses
foreach var of varlist n5_1_1 - n5_1_999 {
	la val `var' yesno
	note `var' : "How do you plan on financing your upcoming agriculture expense of the Kharif season of 2018?"
	}
	
la var n5_1_1	"Savings"	
la var n5_1_2	"Selling assets"
la var n5_1_3	"Loans/credit"
la var n5_1_4	"Financial assistance from friends and family"
la var n5_1_5	"Credit from agro dealer/agro shops"
la var n5_1_6	"Input help from friends and family"
la var n5_1_666	"Not decided yet"
la var n5_1_777	"Other"
la var n5_1_888	"Does not know/remember"
la var n5_1_999 "Does not answer"

** Loan
foreach var of varlist n5_2_1 - n5_2_999 {
	la val `var' yesno
	note `var' : "From where would you take the loan/credit?"
	}

la var n5_2_1 "Advance from employer"
la var n5_2_2 "Loan from friends and family"
la var n5_2_3 "Loan from moneylender"
la var n5_2_4 "Loan from bank"
la var n5_2_5 "Loan from society"
la var n5_2_6 "Loan from SHG"
la var n5_2_777 "Other"
la var n5_2_888 "Does not know/remember"
la var n5_2_999 "Does not answer"

**During the upcoming Kharif season of 2018, if you needed to come up with Rs.5000 in 3 days for an agriculture expense, could you get this money?
**How would you get this money?
foreach var of varlist n6_2_1 - n6_2_777 {
	la val `var' yesno
	note `var' : "How would you get this money?"
	}
la var n6_2_1 "Savings"
la var n6_2_2 "Selling assets"
la var n6_2_3 "Loans/credit"
la var n6_2_4 "Friends and family"
la var n6_2_777 "Other"

**From where would you take the loan/credit?
foreach var of varlist n6_3_1 - n6_3_999 {
	la val `var' yesno
	note `var' : "From where would you take the loan/credit?"
	}
la var n6_3_1 "Advance from employer"
la var n6_3_2 "Loan from friends and family"
la var n6_3_3 "Loan from moneylender"
la var n6_3_4 "Loan from bank"
la var n6_3_5 "Loan from society"
la var n6_3_6 "Loan from SHG"
la var n6_3_777 "Other"
la var n6_3_888 "Does not know/remember"
la var n6_3_999 "Does not answer"	


	
/*******************************************************************************
SECTION A2
*******************************************************************************/
destring continue_2 , replace
la val continue_2 yesno

*Date
gen double aux = date(date_2,"DMY"), after(date_2)
format aux %td
drop date_2
rename aux date_2
la var date_2 "Survey Form 2, date"

*Time
gen double aux = clock(time_2,"hms"), after(time_2)
format aux %tcHH:MM:SS
drop time_2
rename aux time_2
la var time_2 "Survey Form 2, time"

/*******************************************************************************
SECTION P
*******************************************************************************/

*Corrections based on HFC
replace p2_1	=	30	if	uid == "B01V10F0275"
replace p4_1_1	=	15	if	uid == "B04V52F1455"

replace p6_1	=	150	if	uid == "B06V75F2139"
replace p6_2	=	2	if	uid == "B06V75F2139"

replace p2_1	=	13	if	uid == "B01V11F0323"
replace p2_1	=	10	if	uid == "B01V13F0381"
replace p2_1	=	10	if	uid == "B05V63F1749"
replace p2_1	=	20	if	uid == "B05V63F1751"

replace p10_1	=	35	if	uid == "B02V24F0704"

replace p2_1	=	7	if	uid	== "B02V18F0545"

replace p2_1	=	63	if	uid == "B01V02F0063"
replace p2_1	=	30	if	uid == "B06V73F2060"
replace p2_1	=	25	if	uid == "B01V10F0272"




		

*Sampled plot size
gen sampled_plot_size = . , before(p2_1)
replace sampled_plot_size = applicable_plot_size		if plot_units == "bigha" | plot_units == "વીઘા" /*bigha*/
replace sampled_plot_size = applicable_plot_size * 2.5	if plot_units == "acre" | plot_units == "એકર"/*acre*/
replace sampled_plot_size = applicable_plot_size * 6.25	if plot_units == "hectare" | plot_units == "હેક્ટર" /*hectare*/

la var sampled_plot_size "Sampled plot size in bigha"

*Cotton area in sampled plot
gen sampled_plot_cotton_area = ., before(p2_1)
replace sampled_plot_cotton_area = p2_1 		if p2_2 == 1 /*bigha*/
replace sampled_plot_cotton_area = p2_1 * 2.5	if p2_2== 2 /*acre*/
replace sampled_plot_cotton_area = p2_1 * 6.25	if p2_2 == 3 /*hectare*/
**replace sampled_plot_cotton_area = p2_1 		if p2_2 == 4 /*guntha*/

la var sampled_plot_cotton_area "Cotton area in sampled plot in bigha"

*Irrigated area in sampled plot
gen sampled_plot_irrigated_area = ., before(p4_1_1)
replace sampled_plot_irrigated_area = p4_1_1 		if p4_1_2 == 1 /*bigha*/
replace sampled_plot_irrigated_area = p4_1_1 * 2.5	if p4_1_2== 2 /*acre*/
replace sampled_plot_irrigated_area = p4_1_1 * 6.25	if p4_1_2 == 3 /*hectare*/
**replace sampled_plot_irrigated_area = p4_1_1 		if p4_1_2 == 4 /*guntha*/

replace sampled_plot_irrigated_area = p4_1_1 * (1/40) * 2.5	if p4_1_2 == 4 & uid == "B01V08F0211" /*guntha*/

la var sampled_plot_irrigated_area "Irrigated area in sampled plot in bigha"

gen sampled_plot_irrigated_ratio = sampled_plot_irrigated_area / sampled_plot_size , before(p4_1_1)
la var sampled_plot_irrigated_ratio "Ratio of irrigated area to total area"

/*
p4_2
1	rainfall
2	underground water
3	nearby water/dam
777	other
*/
foreach var of varlist p4_2_1 p4_2_2 p4_2_3 p4_2_777 {
	la val `var' yesno
	note `var' : "What was the source of irrigation dependent upon?"
	}
la var p4_2_1 "Source of irrigation: rainfall"
la var p4_2_2 "Source of irrigation: underground water"
la var p4_2_3 "Source of irrigation: nearby water/dam"
la var p4_2_777 "Source of irrigation: other"

*Cotton harvested in the sampled plot
gen sampled_plot_quantity_harvested = . , before(p6_1)
replace sampled_plot_quantity_harvested = p6_1			if p6_2 == 1 /*kg*/
replace sampled_plot_quantity_harvested = p6_1 * 20		if p6_2 == 2 /*maund*/
replace sampled_plot_quantity_harvested = p6_1 * 100	if p6_2 == 3 /*quintal*/
**replace sampled_plot_quantity_harvested = 			if p6_2 == 4 /*pula*/
replace sampled_plot_quantity_harvested = .k			if p6_2 == 888 /*dont know/remember*/
la var sampled_plot_quantity_harvested "Total cotton harvested in kg"

*Cotton yield in the sampled plot
gen sampled_plot_yield = sampled_plot_quantity_harvested / sampled_plot_cotton_area ,before(sampled_plot_quantity_harvested)
la var sampled_plot_yield "Cotton yield in kg per bigha"

/* p_8
1	cotton
2	groundnut
3	castor
4	sorgam
5	millet
6	pulses
777	other
*/
foreach var of varlist p8_1	p8_2 p8_3 p8_4 p8_5 p8_6 p8_777 {
	la val `var' yesno
	note `var' : "Please tell me the name of all the crops that you had grown on this plot in the Kharif season of 2017"
	}

la var p8_1 "Grew cotton in the Kharif season of 2017" /*Check*/
la var p8_2 "Grew groundnut in the Kharif season of 2017"
la var p8_3 "Grew castor in the Kharif season of 2017"
la var p8_4 "Grew sorgam in the Kharif season of 2017"
la var p8_5 "Grew millet in the Kharif season of 2017"
la var p8_6 "Grew pulses in the Kharif season of 2017"
la var p8_777 "Grew other crop in the Kharif season of 2017"

/* p_9_2
1	wheat
2	cumin
777	other
*/
foreach var of varlist p9_2_1 p9_2_2 p9_2_777 {
	la val `var' yesno
	note `var' : "Did you grow any Rabi crop on this plot in the Rabi season of 2017-18? Please tell me the name of the Rabi crops"
}

la var p9_2_1 "Grew wheat in the Rabi season of 2017-18"
la var p9_2_2 "Grew cumin in the Rabi season of 2017-18"
la var p9_2_777 "Grew other crop in the Rabi season of 2017-18"

*Planed cotton area in sampled plot
gen sampled_plot_planned_cotton_area = ., before(p10_1)
replace sampled_plot_planned_cotton_area = p10_1 		if p10_2 == 1 /*bigha*/
replace sampled_plot_planned_cotton_area = p10_1 * 2.5	if p10_2== 2 /*acre*/
replace sampled_plot_planned_cotton_area = p10_1 * 6.25	if p10_2 == 3 /*hectare*/
**replace sampled_plot_planned_cotton_area = p10_1 		if p10_2 == 4 /*guntha*/
replace sampled_plot_planned_cotton_area = p10_1  * (1/40) * 2.5	if p10_2 == 4 & uid == "B01V08F0211" /*guntha*/

la var sampled_plot_planned_cotton_area "Planned cotton area in sampled plot in bigha for Kharif season 2018"

gen sampled_plot_irrigate_plans = cond(missing(p11),.,cond(p11 == 1,1,0)) , before(p11)
la var sampled_plot_irrigate_plans "Plans to irrigate sampled plot in Kharif season 2018"


/*******************************************************************************
SECTION Q
*******************************************************************************/

*Corrections based on HFC
replace q12_u_1		=	6	if	uid	==	"B01V05F0135"
replace q13_0_3		=	2	if	uid	==	"B01V05F0135"
replace q13_q_3_1	=	1	if	uid	==	"B01V05F0135"
replace q13_q_3_2	=	1	if	uid	==	"B01V05F0135"

replace q5_1		=	10	if	uid	==	"B01V01F0034"
replace q5_1		=	15	if	uid	==	"B01V07F0172"
replace q5_3		=	12	if	uid	==	"B01V07F0172"

replace q12_1		=	6	if	uid	==	"B01V07F0172"
replace q13_q_1_1	=	1	if	uid	==	"B01V07F0172"
replace q13_q_1_2	=	1	if	uid	==	"B01V07F0172"
replace q13_q_1_3	=	1	if	uid	==	"B01V07F0172"

replace q12_1		=	6	if	uid	==	"B01V08F0226"

replace q12_12		=	4	if	uid ==	"B02V19F0564"
replace q13_q_12_1	=	1	if	uid ==	"B02V19F0564"
replace q13_q_12_2	=	1	if	uid ==	"B02V19F0564"
replace q13_q_12_3  =	1	if	uid ==	"B02V19F0564"
replace q13_q_12_4	=	1	if	uid ==	"B02V19F0564"

replace q13_q_13_1		=	11	if	uid ==	"B02V16F0495"
replace q13_u_13_1		=	777 if	uid ==	"B02V16F0495"
replace q13_ob_q_13_1	=	3	if	uid ==	"B02V16F0495"
replace q13_ob_u_13_1	=	1	if	uid ==	"B02V16F0495"
		
replace q12_2		=	3	if	uid ==	"B02V15F0449"
	
replace q13_0_2		=	1	if	uid ==	"B03V32F0943"
replace q13_q_2_2	=	.	if	uid ==	"B03V32F0943"
replace q13_u_2_2	=	.	if	uid ==	"B03V32F0943"

replace q13_u_3_1	=	1	if	uid ==	"B02V26F0792"
				
replace q12_6		=	3	if	uid ==	"B03V30F0889"
replace q13_q_6_1 	=	1	if	uid ==	"B03V30F0889"
replace q13_q_6_2 	=	1	if	uid ==	"B03V30F0889"
replace q13_q_6_3 	=	1	if	uid ==	"B03V30F0889"

replace q12_u_1 	=	6	if	uid ==	"B01V01F0030"

replace q12_ob_q_12	=	10	if	uid	==	"B02V18F0544"
replace q12_ob_u_12	=	1	if	uid	==	"B02V18F0544"

replace q12_ob_q_12	=	20	if	uid	==	"B02V17F0508"
replace q12_ob_u_12	=	1	if	uid	==	"B02V17F0508"

replace q12_ob_q_12	=	20	if	uid	==	"B06V81F2336"
replace q12_ob_u_12	=	1	if	uid	==	"B06V81F2336"

replace q12_ob_q_12	=	40	if	uid	==	"B02V24F0721"
replace q12_ob_u_12	=	1	if	uid	==	"B02V24F0721"

replace q12_u_1 	=	6	if	uid ==	"B02V24F0717"

replace q12_ob_q_13 =	2	if	uid	==	"B02V18F0544"
replace q12_ob_u_13	=	1	if	uid	==	"B02V18F0544"
	
replace q12_ob_q_13 =	3	if	uid	==	"B02V17F0508"
replace q12_ob_u_13	=	1	if	uid	==	"B02V17F0508"

replace q12_ob_q_13 =	3	if	uid	==	"B06V75F2121"
replace q12_ob_u_13	=	1	if	uid	==	"B06V75F2121"

replace q12_ob_q_13 =	5	if	uid	==	"B06V74F2091"
replace q12_ob_u_13	=	1	if	uid	==	"B06V74F2091"

replace q12_ob_q_13 =	6	if	uid	==	"B06V72F2042"
replace q12_ob_u_13	=	1	if	uid	==	"B06V72F2042"

replace q12_ob_q_13 =	10	if	uid	==	"B02V24F0706"
replace q12_ob_u_13	=	1	if	uid	==	"B02V24F0706"

replace q12_ob_q_13 =	70	if	uid	==	"B06V73F2058"
replace q12_ob_u_13	=	1	if	uid	==	"B06V73F2058"

replace q12_ob_q_13 =	5	if	uid	==	"B03V37F1086"
replace q12_ob_u_13	=	1	if	uid	==	"B03V37F1086"

replace q12_ob_q_14 =	5	if	uid	==	"B03V37F1086"
replace q12_ob_u_14	=	1	if	uid	==	"B03V37F1086"

replace q12_ob_q_14 =	10	if	uid	==	"B04V51F1417"
replace q12_ob_u_14	=	2	if	uid	==	"B04V51F1417"

replace q12_ob_q_14 =	40	if	uid	==	"B06V72F2038"
replace q12_ob_u_14	=	1	if	uid	==	"B06V72F2038"

replace q12_ob_q_14 =	1000	if	uid	==	"B01V11F0304"
replace q12_ob_u_14	=	1		if	uid	==	"B01V11F0304"

replace	q12_u_14	=	6	if	uid	==	"B06V78F2239"

replace q12_ob_q_5 =	5	if	uid	==	"B02V17F0523"
replace q12_ob_u_5 =	1	if	uid	==	"B02V17F0523"

replace	q13_u_1_1	=	6	if	uid	==	"B01V07F0174"
	
replace q13_ob_q_12_1 =	10	if	uid	==	"B02V18F0544"
replace q13_ob_u_12_1 =	1	if	uid	==	"B02V18F0544"

replace q13_ob_q_12_1 =	10	if	uid	==	"B02V24F0706"
replace q13_ob_u_12_1 =	1	if	uid	==	"B02V24F0706"

replace q13_ob_q_12_1 =	20	if	uid	==	"B06V81F2336"
replace q13_ob_u_12_1 =	1	if	uid	==	"B06V81F2336"

replace q13_ob_q_12_1 =	40	if	uid	==	"B02V24F0721"
replace q13_ob_u_12_1 =	1	if	uid	==	"B02V24F0721"

replace q13_u_12_1	= 6		if	uid == "B02V24F0717"

replace q13_ob_q_12_2 =	10	if	uid	==	"B02V18F0544"
replace q13_ob_u_12_2 =	1	if	uid	==	"B02V18F0544"

replace q13_ob_q_12_3 =	10	if	uid	==	"B02V18F0544"
replace q13_ob_u_12_3 =	1	if	uid	==	"B02V18F0544"

replace q13_ob_q_13_1 =	2	if	uid	==	"B02V17F0508"
replace q13_ob_u_13_1 =	1	if	uid	==	"B02V17F0508"
replace q13_ob_q_13_2 =	2	if	uid	==	"B02V17F0508"
replace q13_ob_u_13_2 =	1	if	uid	==	"B02V17F0508"
replace q13_ob_q_13_3 =	2	if	uid	==	"B02V17F0508"
replace q13_ob_u_13_3 =	1	if	uid	==	"B02V17F0508"
replace q13_ob_q_13_4 =	2	if	uid	==	"B02V17F0508"
replace q13_ob_u_13_4 =	1	if	uid	==	"B02V17F0508"

replace q13_ob_q_13_1 =	3	if	uid	==	"B06V75F2121"
replace q13_ob_u_13_1 =	1	if	uid	==	"B06V75F2121"

replace q13_ob_q_13_1 =	5	if	uid	==	"B06V74F2091"
replace q13_ob_u_13_1 =	1	if	uid	==	"B06V74F2091"

replace q13_ob_q_13_1 =	6	if	uid	==	"B06V72F2042"
replace q13_ob_u_13_1 =	1	if	uid	==	"B06V72F2042"

replace q13_ob_q_13_1 =	10	if	uid	==	"B02V24F0706"
replace q13_ob_u_13_1 =	1	if	uid	==	"B02V24F0706"
replace q13_ob_q_13_2 =	10	if	uid	==	"B02V24F0706"
replace q13_ob_u_13_2 =	1	if	uid	==	"B02V24F0706"
replace q13_ob_q_13_3 =	10	if	uid	==	"B02V24F0706"
replace q13_ob_u_13_3 =	1	if	uid	==	"B02V24F0706"
replace q13_ob_q_13_4 =	10	if	uid	==	"B02V24F0706"
replace q13_ob_u_13_4 =	1	if	uid	==	"B02V24F0706"

replace q13_ob_q_14_1 =	10	if	uid	==	"B04V51F1417"
replace q13_ob_u_14_1 =	2	if	uid	==	"B04V51F1417"

replace q13_ob_q_14_1 =	40	if	uid	==	"B06V72F2039"
replace q13_ob_u_14_1 =	1	if	uid	==	"B06V72F2039"

replace q13_ob_q_14_1 =	1000	if	uid	==	"B01V11F0304"
replace q13_ob_u_14_1 =	1		if	uid	==	"B01V11F0304"

replace q13_u_3_4	=	6		if	uid ==	"B03V37F1100"

replace q13_ob_q_5_1 =	5		if	uid	==	"B02V17F0523"
replace q13_ob_u_5_1 =	1		if	uid	==	"B02V17F0523"


replace q5_ob_q_12	=	10		if	uid	==	"B02V24F0706"
replace q5_ob_u_12	=	1		if	uid	==	"B02V24F0706"

replace q5_ob_q_12	=	20		if	uid	==	"B02V17F0508"
replace q5_ob_u_12	=	1		if	uid	==	"B02V17F0508"

replace q5_ob_q_13	=	2		if	uid	==	"B02V17F0508"
replace q5_ob_u_13	=	1		if	uid	==	"B02V17F0508"

replace q5_ob_q_13	=	2		if	uid	==	"B02V23F0685"
replace q5_ob_u_13	=	1		if	uid	==	"B02V23F0685"

replace q5_ob_q_13	=	3		if	uid	==	"B06V71F1998"
replace q5_ob_u_13	=	1		if	uid	==	"B06V71F1998"

replace q5_ob_q_13	=	3		if	uid	==	"B06V75F2121"
replace q5_ob_u_13	=	1		if	uid	==	"B06V75F2121"

replace q5_ob_q_13	=	10		if	uid	==	"B02V24F0706"
replace q5_ob_u_13	=	1		if	uid	==	"B02V24F0706"

replace q5_ob_q_14	=	1000	if	uid	==	"B01V11F0304"
replace q5_ob_u_14	=	1		if	uid	==	"B01V11F0304"

replace q5_ob_q_2	=	70		if	uid	==	"B02V21F0641"
replace q5_ob_u_2	=	1		if	uid	==	"B02V21F0641"

replace q13_u_1_1	=	1		if	uid	==	"B01V01F0030"
replace q13_u_1_2	=	1		if	uid	==	"B01V01F0030"

replace q12_3		=	25		if	uid == "B01V04F0122"

replace q13_u_12_1	=	3		if	uid == "B01V05F0143"
replace q12_12		=	500		if	uid == "B01V05F0143"

replace q13_q_3_2	=	4		if	uid == "B01V05F0145"

replace q5_9	=	50		if	uid == "B01V06F0156"
replace q13_0_9	=	1		if	uid == "B01V06F0156"
replace q13_q_9_1	=	1		if	uid == "B01V06F0156"
replace q12_9	=	20		if	uid == "B01V06F0156"

replace q13_u_1_3 = 1	if uid == "B01V06F0158"
	
replace q5_1	=	15		if	uid == "B01V07F0172"
replace q5_3	=	12		if	uid == "B01V07F0172"

replace q13_u_3_2=1 if uid =="B01V09F0257"
replace q13_u_1_3=1 if uid =="B01V13F0389"
replace q13_u_13_1=1 if uid =="B02V19F0572"
replace q13_u_14_1=1 if uid =="B02V21F0639"
replace q13_u_14_1=1 if uid =="B02V21F0639"
replace q13_u_12_1=1 if uid =="B02V26F0791"
replace q13_u_13_1=1 if uid =="B02V26F0791"
replace q13_u_3_1=1 if uid =="B02V26F0792"
replace q13_u_1_1=1 if uid =="B03V30F0898"
replace q12_u_1=1 if uid =="B03V37F1092"
replace q13_u_1_1=1 if uid =="B03V37F1096"
replace q13_u_3_1=1 if uid =="B03V37F1096"
replace q13_u_6_1=1 if uid =="B03V37F1096"
replace q13_u_1_1=1 if uid =="B03V37F1097"
replace q13_u_1_2=1 if uid =="B03V37F1098"
replace q13_u_1_2=1 if uid =="B03V38F1127"
replace q13_u_6_2=1 if uid =="B03V38F1127"
replace q13_u_8_2=1 if uid =="B03V38F1127"
replace q13_u_3_1=1 if uid =="B04V43F1248"
replace q13_u_3_1=1 if uid =="B04V44F1249"
replace q13_u_8_1=1 if uid =="B04V44F1261"
replace q13_u_1_1=1 if uid =="B04V45F1299"
replace q13_u_1_1=1 if uid =="B04V50F1401"
replace q13_u_3_1=1 if uid =="B04V50F1401"
replace q13_u_8_1=1 if uid =="B04V51F1433"
replace q13_u_13_1=1 if uid =="B05V56F1553"
replace q13_u_13_1=1 if uid =="B05V56F1566"
replace q13_u_1_1=1 if uid =="B05V63F1767"
replace q13_u_3_1=1 if uid =="B05V68F1895"
replace q12_u_14=1 if uid =="B06V70F1955"
replace q13_u_14_1=1 if uid =="B06V70F1955"
replace q13_u_14_1=1 if uid =="B06V70F1955"

replace q13_u_1_2=1 if uid =="B03V30F0898"
replace q13_u_1_2=1 if uid =="B03V37F1096"
replace q13_u_3_2=1 if uid =="B03V37F1096"
replace q13_u_6_2=1 if uid =="B03V37F1096"
replace q13_u_1_3=1 if uid =="B03V37F1098"
replace q13_u_1_3=1 if uid =="B03V38F1127"
replace q13_u_6_3=1 if uid =="B03V38F1127"
replace q13_u_8_3=1 if uid =="B03V38F1127"
replace q13_u_3_2=1 if uid =="B04V43F1248"
replace q13_u_8_2=1 if uid =="B04V44F1261"
replace q13_u_1_2=1 if uid =="B04V45F1299"
replace q13_u_1_2=1 if uid =="B04V50F1401"
replace q13_u_3_2=1 if uid =="B04V50F1401"
replace q13_u_13_2=1 if uid =="B05V56F1553"
replace q13_u_1_2=1 if uid =="B05V63F1767"
replace q13_u_3_2=1 if uid =="B05V68F1895"
replace q13_u_1_3=1 if uid =="B03V37F1096"
replace q13_u_1_4=1 if uid =="B03V37F1096"

replace q13_q_13_1=1 if uid =="B02V16F0495"
replace p2_1=1 if uid =="B02V18F0545"
replace q12_13=1 if uid =="B02V22F0667"
replace q13_q_5_1=1 if uid =="B02V22F0667"
replace q12_ob_q_12=1 if uid =="B02V22F0674"
replace q13_0_2=1 if uid =="B03V32F0943"
replace q13_q_13_2=1 if uid =="B06V70F1956"
replace q13_q_13_2=1 if uid =="B06V70F1956"
replace q13_q_8_1=1 if uid =="B06V74F2088"
replace q12_2=3 if uid =="B02V15F0449"
replace q12_6=3 if uid =="B03V30F0889"
replace q12_6=3 if uid =="B03V30F0889"
replace q13_q_13_1=3 if uid =="B06V80F2311"

replace q12_12=4 if uid =="B02V19F0564"
replace q13_q_8_1=4 if uid =="B04V55F1513"
replace q5_7=7 if uid =="B02V17F0513"

replace q12_13=7 if uid =="B06V70F1956"
replace q5_5=10 if uid =="B06V73F2064"
replace q13_q_13_1=11 if uid =="B02V16F0495"
replace q5_1=15 if uid =="B06V74F2101"

replace q12_u_13 = 5 if uid == "B06V73F2064"
replace q13_u_13_1 = 5 if uid == "B06V73F2064"
replace q13_u_5_1 = 5 if uid == "B06V73F2074"
replace q13_u_5_1 = 5 if uid == "B06V73F2074"

replace q5_1 = 50 if uid == "B01V10F0275"

replace q5_u_5= 5 if uid == "B06V73F2074"

replace q12_ob_q_12 = 10 if uid == "B06V78F2222"
replace q12_ob_u_12 = 1  if uid == "B06V78F2222"

replace q13_ob_q_12_1 = 10 if uid == "B06V78F2222"
replace q13_ob_u_12_1 = 1  if uid == "B06V78F2222"

**fertilizers
lab define fertilizer	1	Urea ///
						2	"Ammonium Sulphate" ///
						3	DAP ///
						4	SSP ///
						5	MOP ///
						6	"N-P-K 20-20-20" ///
						7	"NPK 20-20-13" ///
						8	"NPK 12-32-16" ///
						9	"NPK 19-19-19" ///
						10	"Other NPK" ///
						11	Iron ///
						12	Zinc ///
						13	Sulphur ///
						14	"Other fertilizer"

forvalues f = 1/14	{

	loc fert : label fertilizer `f'
	
	/*Total fertilizers*/
	replace q3_`f' = 0 if q1 == 0 & cotton_plots > 1 & cotton_plots <. //Did not use any fertilizer
	
	lab var q3_`f'	"Used `fert' for cotton cultivation on any plot in the Kharif season of 2017"
	la val q3_`f' yesno
	note q3_`f' : "Which fertilizers did you use for your cotton cultivation on any of the plots in the Kharif season of 2017?"
	
	la var q5_`f' "How much of `fert' did you use on your total cotton cultivated across plots?"

	gen total_fertilizer_dk_`f' = cond(missing(q5_`f'),.,cond(q5_`f' == -888,1,0)), after(q5_`f')
	gen total_fertilizer_dr_`f' = cond(missing(q5_`f'),.,cond(q5_`f' == -999,1,0)), after(total_fertilizer_dk_`f')
	
	replace q5_`f' = .k if q5_`f' == -888
	
	gen total_fertilizer_kg_`f' = . , after(q5_`f')
	
	
	/*Other bagsize in kg or l*/
	gen 	q5_ob_`f' = q5_ob_q_`f' 			if q5_ob_u_`f' == 1 | q5_ob_u_`f' == 2
	replace q5_ob_`f' = q5_ob_q_`f' * 1000		if q5_ob_u_`f' == 3 | q5_ob_u_`f' == 4
	replace q5_ob_`f' = .k						if q5_ob_u_`f' == 888
	
	replace total_fertilizer_kg_`f' = q5_`f'				if q5_u_`f' == 1 | q5_u_`f' == 2	/*kg or l*/
	replace total_fertilizer_kg_`f' = q5_`f' / 1000			if q5_u_`f' == 3 | q5_u_`f' == 4	/*g or ml*/
	replace total_fertilizer_kg_`f' = q5_`f' * 25			if q5_u_`f' == 5					/* 25 kg bag*/
	replace total_fertilizer_kg_`f' = q5_`f' * 50			if q5_u_`f' == 6					/* 50 kg bag*/
	replace total_fertilizer_kg_`f' = q5_`f' * q5_ob_`f'	if q5_u_`f' == 777 					/* other bagsize*/
	replace total_fertilizer_kg_`f' = .k					if total_fertilizer_dk_`f' == 1 | (q5_ob_`f' == .k & q5_u_`f' == 777)
	replace total_fertilizer_kg_`f' = .r					if total_fertilizer_dr_`f' == 1
	replace total_fertilizer_kg_`f' = 0						if q3_`f' == 0 						/*Did not apply fertilizer `f'*/
	
	drop q5_ob_`f'
	
	la var q5_u_`f' "Units of `fert'"
	
	la var total_fertilizer_kg_`f' "`fert' usage in total cotton area in kg"
	
	gen total_fertilizer_kg_bigha_`f' = total_fertilizer_kg_`f' / total_cotton_land , after(total_fertilizer_kg_`f')
	replace total_fertilizer_kg_bigha_`f'  = .k		if total_fertilizer_dk_`f' == 1
	replace total_fertilizer_kg_bigha_`f'  = .r		if total_fertilizer_dr_`f' == 1
	
	la var total_fertilizer_kg_bigha_`f' "`fert' usage in total cotton area in kg per bigha"
	
	drop q3_id_`f' q3_name_`f'
	
	/*Fertilizers on sampled plot*/
	replace q10_`f' = 0 if q1 == 0 
	
	la var q10_`f' "Used `fert' for cotton cultivation on this plot in the Kharif season of 2017"
	la val q10_`f' yesno
	note q10_`f' : "Which fertilizers did you use for your cotton cultivation on this plot in the Kharif season of 2017?"
	
	la var q12_`f' "How much of `fert' did you use on your total cotton cultivated on this plot?"
	la var q12_u_`f' "Units of `fert'"

	gen fertilizer_plot_dk_`f' = cond(missing(q12_`f'),.,cond(q12_`f' == -888,1,0)), after(q12_`f')
	gen fertilizer_plot_dr_`f' = cond(missing(q12_`f'),.,cond(q12_`f' == -999,1,0)), after(fertilizer_plot_dk_`f')
	
	replace q12_`f' = .k if q12_`f' == -888
	replace q12_`f' = .r if q12_`f' == -999
	
	gen fertilizer_plot_kg_`f' = . , after(q12_`f')
	
	/*Other bagsize in kg or l*/
	gen 	q12_ob_`f' = q12_ob_q_`f' 			if q12_ob_u_`f' == 1 | q12_ob_u_`f' == 2
	replace q12_ob_`f' = q12_ob_q_`f' * 1000	if q12_ob_u_`f' == 3 | q12_ob_u_`f' == 4
	replace q12_ob_`f' = .k						if q12_ob_u_`f' == 888
	
	
	replace fertilizer_plot_kg_`f' = q12_`f'				if q12_u_`f' == 1 | q12_u_`f' == 2	/*kg or l*/
	replace fertilizer_plot_kg_`f' = q12_`f' / 1000			if q12_u_`f' == 3 | q12_u_`f' == 4	/*g or ml*/
	replace fertilizer_plot_kg_`f' = q12_`f' * 25			if q12_u_`f' == 5					/* 25 kg bag*/
	replace fertilizer_plot_kg_`f' = q12_`f' * 50			if q12_u_`f' == 6					/* 50 kg bag*/
	replace fertilizer_plot_kg_`f' = q12_`f' * q12_ob_`f'	if q12_u_`f' == 777					/* other bagsize*/
	replace fertilizer_plot_kg_`f' = .k						if fertilizer_plot_dk_`f' == 1 | (q12_ob_`f' == .k & q12_u_`f' == 777)
	replace fertilizer_plot_kg_`f' = .r						if fertilizer_plot_dr_`f' == 1
	replace fertilizer_plot_kg_`f' = 0						if q10_`f' == 0
	
	drop q12_ob_`f'
	
	la var fertilizer_plot_kg_`f' "`fert' usage in sampled plot in kg"
	
	drop q10_id_`f' q10_name_`f'
	
	gen fertilizer_plot_kg_bigha_`f' = fertilizer_plot_kg_`f' / sampled_plot_cotton_area , after(fertilizer_plot_kg_`f')
	replace fertilizer_plot_kg_bigha_`f' = .k				if fertilizer_plot_dk_`f' == 1
	replace fertilizer_plot_kg_bigha_`f' = .r				if fertilizer_plot_dr_`f' == 1
	la var fertilizer_plot_kg_bigha_`f' "`fert' usage in sampled plot in kg per bigha"
	
	/*Dose-wise application on selected plot */
	
	la var q13_0_`f' "In how many doses did you use `fert' on this plot?"

	gen fertilizer_plot_`f'_dose_dk = cond(missing(q13_0_`f'),.,cond(q13_0_`f' == -888,1,0)), after(q13_0_`f')
	replace q13_0_`f' = .k if fertilizer_plot_`f'_dose_dk == 1
	
	gen fertilizer_plot_kg_`f'_td = cond(missing(q10_`f'),.,0), after(q13_0_`f')
	la var fertilizer_plot_kg_`f'_td "`fert' usage in sampled plot in kg (dosewise)"
	
	qui summ q13_0_`f'
	
	cap local n = `r(max)'
	
	cap assert `r(N)' > 0 & `n' > 0  
	
	if _rc == 0 {
	
			forvalues d = 1/`n' {
			
				la var q13_q_`f'_`d' "How much `fert' did you use in dose #`d'?"
				la var q13_u_`f'_`d' "Units of `fert' in dose #`d'"

				
				/*Dose-wise application on selected plot, dose */
				gen fertilizer_plot_`f'_dose_`d'_dk = cond(missing(q13_q_`f'_`d'),.,cond(q13_q_`f'_`d' == -888,1,0)), before(q13_q_`f'_`d')
				
				/*Other bagsize in kg or l*/
				gen 	q13_ob_`f'_`d' = q13_ob_q_`f'_`d'			if q13_ob_u_`f'_`d' == 1 | q13_ob_u_`f'_`d' == 2
				replace q13_ob_`f'_`d' = q13_ob_q_`f'_`d' * 1000	if q13_ob_u_`f'_`d' == 3 | q13_ob_u_`f'_`d' == 4
				replace q13_ob_`f'_`d' = .k							if q13_ob_u_`f'_`d' == 888
						
				gen fertilizer_plot_kg_`f'_dose_`d' = . , before(fertilizer_plot_`f'_dose_`d'_dk)
				replace fertilizer_plot_kg_`f'_dose_`d' = q13_q_`f'_`d'						if q13_u_`f'_`d' == 1 | q13_u_`f'_`d' == 2	/*kg or l*/
				replace fertilizer_plot_kg_`f'_dose_`d' = q13_q_`f'_`d' / 1000				if q13_u_`f'_`d' == 3 | q13_u_`f'_`d' == 4	/*g or ml*/
				replace fertilizer_plot_kg_`f'_dose_`d' = q13_q_`f'_`d' * 25				if q13_u_`f'_`d' == 5						/* 25 kg bag*/
				replace fertilizer_plot_kg_`f'_dose_`d' = q13_q_`f'_`d' * 50				if q13_u_`f'_`d' == 6						/* 50 kg bag*/
				replace fertilizer_plot_kg_`f'_dose_`d' = q13_q_`f'_`d' * q13_ob_`f'_`d'	if q13_u_`f'_`d' == 777						/* other bagsize*/
				replace fertilizer_plot_kg_`f'_dose_`d' = .k								if fertilizer_plot_`f'_dose_`d'_dk  == 1 | ( q13_u_`f'_`d' == 777 & q13_ob_`f'_`d' == .k)
				
				la var fertilizer_plot_kg_`f'_dose_`d' "`fert' used in dose #`d' in kg"
				
				replace fertilizer_plot_kg_`f'_td = fertilizer_plot_kg_`f'_td + fertilizer_plot_kg_`f'_dose_`d' if fertilizer_plot_kg_`f'_dose_`d' <.
				
				drop q13_ob_`f'_`d' 
			
				}
				
			forvalues d = `++n'/10 {
		
				missings dropvars q13_q_`f'_`d' q13_u_`f'_`d' q13_ob_q_`f'_`d' q13_ob_u_`f'_`d' , force
				
				}
			}
			
	if _rc == 9 {
			
			forvalues d = 1/10 {
		
				missings dropvars q13_q_`f'_`d' q13_u_`f'_`d' q13_ob_q_`f'_`d' q13_ob_u_`f'_`d' , force
				
				}
			}
			
	gen	fertilizer_plot_kg_bigha_`f'_td	= fertilizer_plot_kg_`f'_td / sampled_plot_cotton_area, after(fertilizer_plot_kg_`f'_td)
	la var fertilizer_plot_kg_bigha_`f'_td "`fert' usage in sampled plot in kg per bigha (dosewise)"
			
	drop q13_c_`f' q13_d_count_`f' q13_a_id_`f'_*

	*Optimal amount
	
	la var q15_`f' "Is this the optimal amount of `fert' for your cotton on this plot?"

	gen fertilizer_optimal_dk_`f' = cond(missing(q15_`f'),.,cond(q15_`f' == 888,1,0)), after(q15_`f')
	gen fertilizer_optimal_dose_`f' = cond(missing(q15_`f'),.,cond(q15_`f' == 1,1,0)), after(q15_`f')
	la val fertilizer_optimal_dose_`f' yesno
	la var fertilizer_optimal_dose_`f' "Believes `fert' usage was optimal"
	
	la var q17_`f' "Why were you not able to apply the optimal amount of `fert' for your cotton?"
	
	destring q17_1_`f' - q17_777_`f' , replace
	la val q17_1_`f' - q17_777_`f' yesno
	
	la var q17_1_`f'	"Non-optimal `fert': no money"
	la var q17_2_`f'	"Non-optimal `fert': too costly"
	la var q17_3_`f'	"Non-optimal `fert': not necessary"
	la var q17_4_`f'	"Non-optimal `fert': no access"
	la var q17_5_`f'	"Non-optimal `fert': advice from agro-dealer"
	la var q17_6_`f'	"Non-optimal `fert': advice from other farmer"
	la var q17_777_`f'	"Non-optimal `fert': other"
	
	la var q17_o_`f' "Other reason for not using optimal amount of `fert'"
	
	}
		
drop q3_r_count q10_r_count




*Why did you not use Urea for your cotton on this plot?
lab define fertilizer2	1	Urea ///
						2	DAP ///
						3	MOP ///
						4	Iron ///
						5	Zinc ///
						6	Sulphur
						
forvalues f = 1/6 {

	la val q11_`f'_2_1 - q11_`f'_2_777 yesno

	loc fert : label fertilizer2 `f'
	
	la var q11_`f'_2_1	"`fert', no use: no money"
	la var q11_`f'_2_2 	"`fert', no use: too costly"
	la var q11_`f'_2_3	"`fert', no use: not necessary"
	la var q11_`f'_2_4	"`fert', no use: no access"
	la var q11_`f'_2_5	"`fert', no use: advice from agro-dealer"
	la var q11_`f'_2_6	"`fert', no use: advice from other farmer"
	la var q11_`f'_2_7	"`fert', no use: never used"
	la var q11_`f'_2_8	"`fert', no use: have not heard about this fertilizer"
	la var q11_`f'_2_9	"`fert', no use: does not know how to use it"
	la var q11_`f'_2_10	"`fert', no use: too risky"
	la var q11_`f'_2_777 "`fert', no use: other"
	}


/*******************************************************************************
SECTION G
********************************************************************************/

*Corrections
replace g1_4 = 1 if uid == "B06V76F2170"
replace g2_6_3 = 1 if uid == "B04V46F1332"

** uid = B03V27F0810, 888 wrongly entered instead of -888 "Does not know"
foreach var of varlist g2_1_3  g2_5_3 g2_1_4 g2_5_4 g2_1_5 g2_5_5 g2_1_6 g2_5_6 {
	replace `var' = .k if uid == "B03V27F0810"
}
foreach var of varlist g2_2_3 g2_2_4 g2_2_5 g2_2_6 {
	replace `var' = . if uid == "B03V27F0810"
}

** uid == B01V13F0379, 888 wrongly entered instead of -888 "Does not know"
foreach var of varlist g2_1_5 g2_5_5 {
	replace `var' = .k if uid == "B01V13F0379"
	}
foreach var of varlist g2_2_5 g2_6_5 {
	replace `var' = . if uid == "B01V13F0379"
}

		
	
	
*What do you think are the optimal amount of Fertilizer # for cotton cultivation on this plot?
forvalues f = 1/6 {

	loc fert : label fertilizer2 `f'
	
	gen optimal_fert_dk_`f' = ., before(g2_1_`f')
	replace optimal_fert_dk_`f' = 1 if g2_1_`f' == .k
	replace optimal_fert_dk_`f' = 0 if g2_1_`f' < .
	la val optimal_fert_dk_`f' yesno
	
	gen optimal_fert_dr_`f' = ., before(g2_1_`f')
	replace optimal_fert_dr_`f' = 1 if g2_1_`f' == .r
	replace optimal_fert_dr_`f' = 0 if g2_1_`f' < .
	la val optimal_fert_dr_`f' yesno
	
	gen fert_kg_`f' = . , before(g2_1_`f')
	replace fert_kg_`f' = g2_1_`f'			if g2_2_`f' == 1 | g2_2_`f' == 2	/*kg or l*/
	replace fert_kg_`f' = g2_1_`f' / 1000	if g2_2_`f' == 3 | g2_2_`f' == 4	/*g or ml*/
	replace fert_kg_`f' = g2_1_`f' * 25		if g2_2_`f' == 5					/* 25 kg bag*/
	replace fert_kg_`f' = g2_1_`f' * 50		if g2_2_`f' == 6					/* 50 kg bag*/
	*replace fert_kg_`f' = 					if g2_2_`f' == 777					/* other bagsize*/
	replace fert_kg_`f' = .k				if optimal_fert_dk_`f' == 1
	replace fert_kg_`f' = .r				if optimal_fert_dr_`f' == 1
	
	gen land_fert_bigha_`f' = . , before(g2_1_`f')
	replace land_fert_bigha_`f' = g2_5_`f' 			if g2_6_`f' == 1 /*bigha*/
	replace land_fert_bigha_`f' = g2_5_`f' * 2.5	if g2_6_`f' == 2 /*acre*/
	replace land_fert_bigha_`f' = g2_5_`f' * 6.25	if g2_6_`f' == 3 /*hectare*/
	**replace land_fert_bigha_`f' = g2_5_`f' 		if g2_6_`f' == 4 /*guntha*/
	
	replace land_fert_bigha_`f' = g2_5_`f' * (1/40) * 2.5 if g2_6_`f' == 4 & uid == "B01V08F0211"	/*uid = B01V08F0211 reported guntha with an equivalence 1 acre = 40 guntha*/
	
	gen optimal_fertilizer_kg_bigha_`f' = fert_kg_`f' / land_fert_bigha_`f' , before(g2_1_`f')
	la var optimal_fertilizer_kg_bigha_`f' "Optimal amount of `fert' for cotton in kg/bigha"
	
	
	}
	
*Max yield
gen max_yield = ., before(g1_1)

gen aux = .
replace aux = g1_3 			if g1_4 == 1 /*bigha*/
replace aux = g1_3 * 2.5	if g1_4 == 2 /*acre*/
replace aux = g1_3 * 6.25	if g1_4 == 3 /*hectare*/
**replace aux = g1_3 		if g1_4 == 4 /*guntha*/

replace max_yield = g1_1		if g1_2 == 1 /*kg*/
replace max_yield = g1_1 * 20	if g1_2 == 2 /*maund*/
replace max_yield = g1_1 * 100	if g1_2 == 3 /*quintal*/
**replace max_yield = 			if g1_2 == 4 /*pula*/
replace max_yield = .k			if g1_2 == 888 /*dont know/remember*/	

replace max_yield = max_yield / aux
drop aux

la var max_yield "Max. yield with current plan in kg per bigha"
	
*Max yield with optimal fertilizer usage
gen max_yield_optimal_fertilizers = ., before(g3_1)

gen aux = .
replace aux = g3_3 			if g3_4 == 1 /*bigha*/
replace aux = g3_3 * 2.5	if g3_4 == 2 /*acre*/
replace aux = g3_3 * 6.25	if g3_4 == 3 /*hectare*/
**replace aux = g3_3 		if g3_4 == 4 /*guntha*/

replace aux = g3_3 * (1/40) * 2.5 if g3_4 == 4 & uid == "B01V08F0211"	/*uid = B01V08F0211 reported guntha with an equivalence 1 acre = 40 guntha*/

replace max_yield_optimal_fertilizers = g3_1		if g3_2 == 1 /*kg*/
replace max_yield_optimal_fertilizers = g3_1 * 20	if g3_2 == 2 /*maund*/
replace max_yield_optimal_fertilizers = g3_1 * 100	if g3_2 == 3 /*quintal*/
**replace max_yield = 								if g3_2 == 4 /*pula*/
replace max_yield_optimal_fertilizers = .k			if g3_2 == 888 /*dont know/remember*/	

replace max_yield_optimal_fertilizers = max_yield_optimal_fertilizers / aux
drop aux

la var max_yield_optimal_fertilizers "Max. yield with optimal fertilizer usage in kg per bigha"

*Max yield with optimal input usage and practices
gen max_yield_optimal = ., before(g4_1)

gen aux = .
replace aux = g4_3 			if g4_4 == 1 /*bigha*/
replace aux = g4_3 * 2.5	if g4_4 == 2 /*acre*/
replace aux = g4_3 * 6.25	if g4_4 == 3 /*hectare*/
**replace aux = g4_3 		if g4_4 == 4 /*guntha*/

replace aux = g4_3 * (1/40) * 2.5 if g4_4 == 4 & uid == "B01V08F0211"	/*uid = B01V08F0211 reported guntha with an equivalence 1 acre = 40 guntha*/

replace max_yield_optimal = g4_1		if g4_2 == 1 /*kg*/
replace max_yield_optimal = g4_1 * 20	if g4_2 == 2 /*maund*/
replace max_yield_optimal = g4_1 * 100	if g4_2 == 3 /*quintal*/
**replace max_yield = 					if g4_2 == 4 /*pula*/
replace max_yield_optimal = .k			if g4_2 == 888 /*dont know/remember*/	

replace max_yield_optimal = max_yield_optimal / aux
drop aux

la var max_yield_optimal "Max. yield with optimal inputs and practices in kg per bigha"

*Mode of transport to buy Zinc
la val g5_3_1_4_1 - g5_3_1_4_777 yesno
la var g5_3_1_4_1	"Mode of transport to buy Zinc: walk"
la var g5_3_1_4_2	"Mode of transport to buy Zinc: cycle"
la var g5_3_1_4_3	"Mode of transport to buy Zinc: auto"
la var g5_3_1_4_4	"Mode of transport to buy Zinc: car"
la var g5_3_1_4_5	"Mode of transport to buy Zinc: tempo"
la var g5_3_1_4_6	"Mode of transport to buy Zinc: truck"
la var g5_3_1_4_7	"Mode of transport to buy Zinc: bike"
la var g5_3_1_4_777	"Mode of transport to buy Zinc: other"


*Time taken to purchase fertilizers
foreach x in 1 4 5 6 {

	local lbl : variable label g5_3_2_`x'_q
	local lbl `lbl' in minutes

	gen g5_3_2_`x' = . , before(g5_3_2_`x'_q)
	replace g5_3_2_`x' =  g5_3_2_`x'_q 		if g5_3_2_`x'_u == 1 /*minutes*/
	replace g5_3_2_`x' =  g5_3_2_`x'_q * 60 if g5_3_2_`x'_u == 2 /*hours*/
	
	label var g5_3_2_`x' "`lbl'"

	}
/*******************************************************************************
Soil Sample Collection
********************************************************************************/

foreach var of varlist r7_1 r7_2 r7_3 r7_777 {
	la val `var' yesno
	note `var' : "Please tell me the reason why it would not be possible in the next 6 weeks"
	}

la var r7_1	"Crop will not be harvested in this period"
la var r7_2	"Soil will not be dry in this period"
la var r7_3	"Is not interested"
la var r7_777 "Other"
	
	
/*******************************************************************************
TIME VARIABLES
********************************************************************************/

foreach var of varlist 	start_time_sa start_time_sb start_time_sc start_time_sd start_time_sv ///
						start_time_se start_time_sf start_time_sh start_time_si start_time_sj ///
						start_time_sk start_time_sl start_time_sm start_time_sn start_time_so ///
						start_time_sp start_time_sq start_time_sg start_time_sr ///
						end_time_sa end_time_sb end_time_sc end_time_sd end_time_sv ///
						end_time_se end_time_sf end_time_sh end_time_si end_time_sj ///
						end_time_sk end_time_sl end_time_sm end_time_sn end_time_so ///
						end_time_sp end_time_sq end_time_sg end_time_sr {
						
	gen double aux_`var' = clock(`var',"hms"), after(`var')
	format aux_`var' %tcHH:MM:SS
	drop `var'
	rename aux_`var' `var'
	
}
						
foreach sec in a b c d v e f h i j k l m n o p q g r {

	gen duration_s`sec' = (end_time_s`sec' - start_time_s`sec')/60000 , after(end_time_s`sec')
	la var duration_s`sec' "Section `sec' duration in minutes"
	la var start_time_s`sec' "Section `sec' start time"
	la var end_time_s`sec' "Section `sec' end time"
	
}

gen duration_1 = (endtime - starttime)/60000, after(endtime)

local duration	duration_sa duration_sb duration_sc duration_sd duration_sv duration_se ///
				duration_sf duration_sh duration_si duration_sj duration_sk duration_sl ///
				duration_sm duration_sn duration_so duration_sp duration_sq duration_sg ///
				duration_sr
egen duration_2 = rowtotal(`duration'), missing 
order duration_2 , after(duration_1)	

/*******************************************************************************
GPS
********************************************************************************/			

save "`clean'" , replace

recast str244 no_consent_o , force
saveold "`clean_old'", version(12) replace

drop if not_eligible == 1
drop if consent == 0

sort uid date time

by uid: gen nobs = _n

duplicates tag uid, gen(dup)

drop if dup>0 & nobs == 1

drop nobs dup

drop name name_f mobile_number mobile_number_alternate mobile_number_f surveyor supervisor c4 r0

drop gps_end_1latitude gps_end_1longitude gps_end_1altitude gps_end_1accuracy gps_end_2 pic







