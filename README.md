# Overcoming Barriers to Soil Fertility Management
## Overview

This repository presents research materials and data collected as part of the study "Overcoming Barriers to Soil Fertility Management" which received funding from the Agriculture Technology Adoption Initiative and the Harvard Business School Division of Research and Faculty Development. The intervention was implemented by Precision Agriculture for Development (PAD) through a mobile phone-based agricultural advisory service called Krishi Tarang. Survey instruments, de-identified data, and the code used for data cleaning and analysis are provided.

We include as many raw data files and as much code as possible while protecting personally identifiable information (PII). Raw data files generally have variables omitted. We excluded variables containing PII as well as open-ended string variables that could potentially be used to identify individuals. Some code used to clean data also has omissions. For instance, respondent names were sometimes used to resolve duplicates, which we had to drop to protect the privacy of individuals in the sample.

Details about any information that is not omitted are presented in this file or the README.md placed in individual folders within this repository.

Importantly, all analysis is done on de-identified data, and we include this data and code in the directory `99-paper`. This directory includes unmodified code, data, the LaTex files used to generate the paper, and a PDF copy of the paper. We will update this folder each time we release a new draft of the paper. Hence, all changes to our code, data, and paper text are logged so that changes are transparent.

## Study Information

| Variable | Value |
| --- | ----------- |
| Title of Proposal |  Overcoming Barriers to Soil Fertility Management|
| Principal Investigators | Shawn Cole and Tomoko Harigaya |
| Location | Gujarat, India |
| ATAI Barriers Addressed | Information |
| Research Question | How does providing customized soil information and fertilizer recommendations affect input adoption decisions, input costs, and productivity of cotton farmers in Gujarat? |
| Technology Introduced or Evaluated | Fertilizer recommendations based on plot-level soil fertility data |
| Intervention | Customized fertilizer recommendations delivered to individual farmers via soil health card and push calls. |
| Start date | March 1st, 2017 |
| End date | January 1st, 2020 |
| Paper title | Using Satellites and Phones to Evaluate and Promote Agricultural Technology Adoption: Evidences from Small-Holder Farms in India |
| Paper authors | Shawn Cole, Tomoko Harigaya, Grady Killeen, and Aparna Krishna |

## Data Sources

| Description | Source |
| --- | --- |
| Baseline survey | In-person survey |
| Basal survey | Phone survey |
| Midline survey | In-person survey |
| Endline survey | In-person survey |
| Plot boundary data | Dedicated data collection team |
| Satellite imagery | Sentinel-2 |
| Krishi Tarang usage data | System metadata provided by PAD |

## Baseline survey

- N = 1,585
- Dates: March-May 2018
- Data collected: soil sample, 2017 cotton yields, demographic variables, 2017 fertilizer use

The baseline survey was conducted from March-May 2018 using SurveyCTO. A Microsoft Word version of the survey and the SurveyCTO survey definition are included in `01-baseline/01-survey-instrument`. Soil samples were also collected from the primary plot of every farmer in the sample during the baseline survey.

Raw data is included in `01-baseline/02-raw-data`. This was modified from the version used in the paper to remove PII.

The code used to clean the data is presented in `01-baseline/03-cleaning-do`. These were modified to remove PII (e.g. farmer names), so they generally will not run. We also updated the paths of files to reflect those used in this repository. However, we did not remove any code that we think could change results, and in instances where we had to remove PII but the line was relevant we left the command and replaced the information about the farmer with a term such as "omitted."

The cleaned data is included in `01-baseline/04-cleaned-data`. This was lightly modified to remove some open-ended responses that we were concerned could reveal the identity of the respondent. None of the variables we removed were used in analysis.

### Randomization

Randomization was conducted after the baseline survey. The code used to randomize is included in `01-baseline/05-randomization-do` and the output is included in `01-baseline/04-cleaned-data/merged`. Only trivial modifications were applied to the randomization file.

## Basal survey

- N = 1,436
- Dates: July-August 2018
- Data collected: basal (first dose) fertilizer use, cotton sowing, and irrigation

Data on basal fertilizer application, which was emphasized in the intervention, was collected via a phone survey just after the application period in July-August 2018. The survey instrument is available in `02-basal/01-survey-instrument`.

The raw data is in `02-basal/02-raw-data` with minor modifications to protect PII.

The code used to clean the data is in `02-basal/03-do-files`. We only made trivial modifications to these two files, but they do not run because they reference a variable with PII that was dropped.

The clean data is presented in `02-basal/04-processed-data`. The file `basal_clean_2.dta` is the one used in analysis and is unmodified.

## Midline survey

- N = 1,533
- Dates: October-December 2018
- Data collected: full season fertilizer use and knowledge

This survey was conducted using Open Data Kit. The ODK instrument and a PDF version of the survey are included in `03-midline/01-survey-instrument`.

The raw data is included in `03-midline/02-raw-data`. The files were modified to remove PII.

The cleaning do file is presented in `03-midline/03-do-files`. This will not run since the data set was modified to remove PII.

The cleaned data is in `03-midline/04-cleaned-data` and is identical to the data used in analysis.

## Endline survey

 - N = 1,465
 - Dates: February-May 2019
 - Data collected: trust in information sources and yields

The endline survey was conducted using ODK. The survey instrument is included in `04-endline/01-survey-instrument`.

The raw data is presented in `04-endline/02-raw-data`. PII was removed before cleaning (we applied minor corrections based on field reports and anonymized the data in an omitted do file). As a result, the data was only trivially modified to code the device (tablets used for data collection) phone numbers to missing.

The cleaning do file is included in `04-endline/03-do-files`. We only modified the path data to reflect the structure of this repository.

The cleaned data is included in `04-endline/04-cleaned-data`. It was not modified before we uploaded it.

## Crop yield measurements
 - N = 1,389
 - Dates: March-May 2019
 - Data collected: plot boundary data

Plot boundary data was collected using Garmin eTrex 30x devices. The data was collected concurrently to the endline survey, but by a different survey team. Since yield measurements depend on precise GPS data, more data is omitted for this exercise. See `05-satellite-yield-measurements/README.md` for details about the data that is included and omitted and for information about the methodology.

The final vegetation index and rainfall data outputted from this process is included in `05-satellite-yield-measurements/04-output-data`.

## Krishi Tarang Metadata

 De-identified metadata from the Krishi Tarang system, for both the general calls sent to all farmers and the treatment farmers, is included in `06-kt-metadata`. We do not include the raw data because it does not offer any additional information. Data cleaning code is omitted because of a high concentration of PII. This code primarily removed PII.

## Soil Health Data

The results from the soil health tests and resulting fertilizer recommendations are included in `07-soil-health-data`. Raw data, cleaning code, and cleaned data are provided. We modified the raw data and cleaning files to remove PII.

## Merged data

The code used to merge the data and create the final data set used in the paper is presented in `08-merged-data/01-do-files`. This only has trivial modifications to reflect changes to the file structure in this repository.

The merged data used in the paper is presented in `08-merged-data/02-output`. This is unmodified.

## GPS data

We provide de-identified GPS data in the file `jittered_gps_data.csv`. Our approach to anonymizing the data was adapted from [DHS Spatial Analysis Reports 7 Appendix B](https://dhsprogram.com/pubs/pdf/SAR7/SAR7.pdf) and the [J-PAL Guide to De-Identifying Data](https://www.povertyactionlab.org/sites/default/files/research-resources/J-PAL-guide-to-deidentifying-data.pdf).

First, we averaged each GPS point in a village. Then, we selected a random number between 1,000 and 10,000 meters and a random direction. We then moved each point in the randomly selected direction by the randomly selected amount. The GPS points are thus not precise, with significant noise added due to the relatively low population density in much of the sample region. 
