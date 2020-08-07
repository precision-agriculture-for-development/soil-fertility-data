# Overview

The repository contains the final cleaned and de-identified data, do files, tables, figures, and paper for the soil fertility study in Gujarat, India. This repository is cloned from Overleaf and thus contains a full history of the paper. 

The repository does not contain the raw data or the remote sensing analysis that was used to generate the final vegetation index values. The raw data and cleaning do files are stored in the PAD Dropbox. The remote sensing materials are stored on Grady Killeen's desktop and a backup encrypted hard drive (they are too large to store on Dropbox or git). Details about where to find these other data sources are provided below.

The do files in this reposutory generate all of the tables and figures for the paper. They are organized by table/figure number, and are called by `main.do`. Each do file begins by importing the cleaned data, then performs any analysis/generates any variables needed for the tables. This leads to redundant code, but makes it possible to figure out the process by which a table or figure was created by looking at the do file with that table/figure number and nowhere else.

Since this repository is hosted by Git, the author of any particular code block can be identified. If you need help figuring out how to accomplish this, contact Grady. 

## Unit conversions 
- 2.5 bigha per acre 
- 2.47105 acres per hectare 
- 6.177625 bigha per hectare 

## Miscellaneous notes

- The root Dropbox folder for most items is `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2`
- The name of the Dropbox folders containing the raw data and cleaning files have been changed over time (e.g. capital letters were replaced with lower case).
  - This doesn't appear to have been intentional. It may have been done by someone's OS.
  - A lot of do files will run into an error as a result. Often times just fixing the Dropbox path name in the do file will fix this.
- The folder `1318_Plot Mapping` contains data from a pilot conducted to determine if it was worthwhile to map plots for yield estimation. This folder does not relate to the plot boundary data that was collected for the RCT sample.
- Some folders use git for version control, and some have an archive folder with older versions of scripts. The system varies a lot across folders because there is no central source of do files and PAD's policies changed throughout the project.
  - A limitation of Dropbox is that we don't know who edited a particular file and changes can easily be made without a version being logged. Hence, we have an imperfect record of changes to cleaning files as well as who worked on them.

## The two Dropbox folders containing data

In late 2018, we made an effort to remove PII from the folder where analysis was being conducted. As a result, we renamed the existing Dropbox folder `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii` and created a new folder, `Field_data_india/0318_ATAI_Year 2`, that had no PII at the time. However, the raw endline data (with PII) was saved in the second folder, and soil test data with PII is also present.

As a result, both folders have PII and data not stored in the other. Generally, all raw data with PII from all surveys other than the endline is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii`, the raw data from the endline is in `Field_data_india/0318_ATAI_Year 2`, and all analysis files are in `Field_data_india/0318_ATAI_Year 2`. I attempt to document in detail where each data set is throughout the rest of this document.

# Surveys, data location, and cleaning

## Baseline

### Survey

The baseline survey is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0318_Baseline_decrypted/03_Documents/SurveyCTO/guj_final`. The file `atai_baseline_3.12.2018.docx` contains a Microsoft Word version, and `atai_baseline_t_v7.xlsx` contains the SurveyCTO definition.

I am not sure who created the SurveyCTO version of the survey. However, Victor Perez, Aparna Krishna, Swapnil Agarwal, and Azfar Karim were all involved with the project at around this point. The survey was completed from March-May 2018.

### Raw Data

The raw data with PII is in various directories in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii/ATAI_Year2_PII/0318_Baseline/data`

### Cleaned data

The cleaned data with PII is in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii/ATAI_Year2_PII/0318_Baseline/data/merged/0318_Baseline.dta`

The de-identified cleaned data is in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0318_Baseline_decrypted/05_Data/data/merged/0318_Baseline.dta`. This file excludes information about treatment assignment. The file `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0518_Randomization/01_Data/Output/ATAI_baseline_treatment_assignment.dta` includes treatment assignment and is used to import baseline data in all analysis.

### Cleaning scripts

The folder `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0318_Baseline_decrypted/01_Dofiles_decrypted` contains the baseline cleaning files. There's a similar folder in the folder with PII. It's unclear whether these will run correctly absent the PII. The majority of the cleaning files were written by Victor Perez.

## Soil Health Data

The soil health test data is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii/0418_Soil_Tests/Data/ATAI_Soil_Tests_Results_Recommendations.dta`. This data is cleaned. I do not know the details about how it was generated.

## Randomization

The randomization do file is `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0518_Randomization/02_Dofiles/atai_year_2_randomization_final.do`

## Basal

PAD conducted a phone survey after basal fertilizer application to elicit fertilizer usage and sowing patterns.

### Survey

The survey instruments are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0918_Basal Survey/01_Documents/Survey Instrument`. The survey was coded by Aparna Krishna. It was conducted during July and August, 2018.

### Raw Data

The raw data is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii/0918_Basal Survey/Data/Raw Data`.

### Cleaned Data

The cleaned data is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0918_Basal Survey/02_Data/Output`.

### Cleaning Scripts

The cleaning scripts are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0918_Basal Survey/03_Do`. These were written by Aparna Krishna.

## Midline

### Survey

The SurveyCTO definition of the survey is saved in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0718_Midline/01_Documents/Survey CTO/atai_midline_2018.xlsx`. I am not sure if a Microsoft Word or equivalent version exists. The midline survey was coded by Victor Perez and Prathyush Parasuraman. Data collection last from October-December, 2018.

### Raw Data

The raw midline data, with PII, appears to be stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year_2_with_pii/0718_Midline/Data`.

### Cleaned Data

The cleaned data is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0718_Midline/02_Data/Output/ATAI_Midline_2018_Clean.dta`.

### Cleaning Scripts

The cleaning scripts are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0718_Midline/03_Do Files`. Version control is present via git. I believe that Victor Perez wrote these scripts.

## Endline

### Survey

The survey instruments for the endline are saved in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/01_Documents/SurveyCTO`. Victor Perez and Prathyush Parasuraman coded the endline survey. It was implemented from February-May of 2019.

### Raw Data

The raw data is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/05_data/ATAI_Endline_Form_1.dta` and `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/05_data/ATAI_Endline_Form_2.dta`.

### Cleaned Data

The cleaned endline data is stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/05_data/01_cleaned/ATAI_Endline_2019_Clean.dta`.

The file `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/05_data/01_cleaned/ATAI_Endline_2019_Clean_Merged.dta` includes the endline data as well as variables from the baseline, basal, and midline surveys that are used in endline analysis. Remote sensing outputs are also included.

### Cleaning Scripts

The cleaning do file is `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/02_do/10_ATAI_Endline_cleaning.do`. Version control was done using git.

## Plot Mapping/Remote Sensing

### Survey

Plot mapping was done as part of the endline survey. However, separate teams did the two activities. As a result, there are some farmers for which we only have plot maps but not the endline survey and some farmers for which we have the endline survey but not the plot maps.

Farmers used a Garmin eTrex 30x to walk the plot boundaries. If the farmer only grew cotton on part of their plot, they walked the boundaries multiple times and saved both maps. Maps were saved using the farmer's unique ID. The cotton portions of land had the suffix \_C in the file name. Details of the mapping methodology are available at [https://docs.google.com/document/d/1CeGF49KdcF02h-dGK-V24ybfq-cRt1beiQ9At24TdFU/edit?usp=sharing](https://docs.google.com/document/d/1CeGF49KdcF02h-dGK-V24ybfq-cRt1beiQ9At24TdFU/edit?usp=sharing).

### Raw Data

The raw GPX data files (Garmin output) are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/04_plot_mapping`. Specifically, they are in the folders labeled with dates. The Python script `gpx2shp.py` converts these to an ESRI shapefile where the file name is saved in an attribute variable `id`. The output is saved in the folder `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/04_plot_mapping/shp`. The script also creates the folder `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/04_plot_mapping/convex_hull` which contains a convex hull of the plot boundary data.

The satellite imagery is too large to include on Dropbox and is stored locally on Grady Killeen's work desktop. It is also backed up on an external hard drive. Multispectral satellite imagery from the Sentinel-2 and PlanetScope missions was obtained and used to create vegetation indices. Rainfall data was also obtained from NASA's IMERG Level 6 Final Run product. Details of the imagery used are available in Shawn and Grady's paper analyzing the remote sensing results.

### Cleaned Data

The outputs from the remote sensing analysis, in a format ready for statistical analysis, are contained in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/05_data/zonalStats.dta`. This file is merged into `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1418_Endline/05_data/01_cleaned/ATAI_Endline_2019_Clean_Merged.dta`.

### Cleaning/Remote Sensing Scripts

The copy of the scripts used in analysis are stored locally on Grady's Desktop with the data. However, I copied as many as possible (some include sensitive API keys) to `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1720_Remote_Sensing_Scripts`. There is also a read me file (`README.md`) in that folder which describes the processing flow, data sources, and methodology in more detail.

These files are copied manually, so there's a chance they are not up to date despite my effort to maintain them. The remote sensing paper has the most detailed and up to date methodology description.

## Soil Resampling

The folder `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1618_soil_retest` contains data for the comparison between lab soil samples and cheap alternatives. Grady merged the files and removed PII using the do file `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1618_soil_retest/03Merged/merged_deidentified_soil_sample_data.dta` to create a product that could be analyzed without IRB oversight.

# Analysis

All of the analysis for the paper analyzing the intervention are contained in this repository.

## Baseline

Several baseline analysis do files are in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0318_Baseline_decrypted/01_Dofiles_decrypted`. I believe that these were written by Aparna Krishna, Victor Perez, and Swapnil Agarwal. Some additional analysis at the time is contained in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1018_doFiles/baselineAnaysisGSK.do` and was written by Grady Killeen. I believe that most outputs from files at this point went into internal documents and presentations.

## Basal

All of the basal analysis is contained in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1018_doFiles/basal`. The primary do file is `basalAnaysisGSK.do`. These files were all written by Grady Killeen.

The outputs from this analysis are all stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1118_outputs/20_basal`. These outputs were used in the first draft of the soil fertility paper written by Shawn, Tomoko, and Aparna.

## Midline

Victor Perez was the first to analyze the midline data. Victor's do files are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0718_Midline/03_Do Files`. Outputs are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/0718_Midline/04_Output`.

Grady Killeen then replicated this analysis. His do files are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1018_doFiles/midline` and his outputs are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1118_outputs/30_midline`.

I do not believe that any of these outputs were used in academic or external documents. However, Grady took some of the code from his midline do files and used it in his endline analysis (mainly for analysis of fertilizer use across the full season).

## Endline

All endline do files to date are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1018_doFiles/endline` and were written by Grady Killeen. They have not been checked in detail by anyone else. The primary do file is `main.do`.

The outputs from this analysis are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1118_outputs/40_endline`. They can also be pushed to Overleaf via Git and can be viewed on Overleaf at [https://www.overleaf.com/read/ppxnncdjqgps](https://www.overleaf.com/read/ppxnncdjqgps) if updated versions have been pushed.

## Endline Remote Sensing

The remote sensing do files were written by Grady Killeen and are accessible at `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1018_doFiles/endline-remote-sensing`. The outputs are stored in `Dropbox (Precision Agr)/Field_data_india/0318_ATAI_Year 2/1118_outputs/50_endline_remote_sensing`.

These outputs were used in the remote sensing paper that existed before it was merged with the primary paper. 
