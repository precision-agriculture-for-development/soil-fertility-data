# Satellite yield measurements

Since the construction of satellite yield measurements depends on personally identifying GPS data, the most data is omitted from this folder. However, we included as much data and code as possible without risking the exposure of PII. We also outline the remote sensing steps in this file.

## Yield analysis 

### Data acquisition

- All satellite imagery we used in the final paper is from the European Space Agency's Sentinel-2 mission. We also examined PlanetScope imagery, but did not include it in our final analysis because it did not offer improved results.

- We downloaded the Sentinel data using the script `05-satellite-yield-measurements/02-scripts/01-api/sentinel-2-download.py`. The script uses GPS data that is excluded to protect PII.  

### Data processing 

- We downloaded Sentinel-2 data in L1C format, which is top-of-atmosphere corrected. 

- We use bottom-of-atmosphere corrected (L2A) data in the analysis. We  used version 2.5.5 of the Sen2Cor program to process the L1C data to Level 2A. The ESA describes the Sen2Cor program as follows: 

>> Sen2Cor is a processor for Sentinel-2 Level 2A product generation and formatting; it performs the atmospheric-, terrain and cirrus correction of Top-Of- Atmosphere Level 1C input data. Sen2Cor creates Bottom-Of-Atmosphere, optionally terrain- and cirrus corrected reflectance images; additional, Aerosol Optical Thickness-, Water Vapor-, Scene Classification Maps and Quality Indicators for cloud and snow probabilities. Its output product format is equivalent to the Level 1C User Product: JPEG 2000 images, three different resolutions, 60, 20 and 10 m.

- When we processed the data, Sen2Cor was an unofficial third party program. Shortly after we did so, it was officially adopted and is now used by the ESA to generate L2A data.

- The program requires a configuration file. A copy of the configuration used is in `05-satellite-yield-measurements/02-scripts/02-sen2cor/config/L2A_GIPP.xml`. We used the script `05-satellite-yield-measurements/02-scripts/02-sen2cor/batchSen2Cor.py` to execute the program in parallel. 

- We then calculated vegetation indices from the L2A data. For reNDVI, MTCI, and LAI, we used tools in the [SNAP](https://step.esa.int/main/toolboxes/snap/) program designed for analyzing Sentinel-2 data. We calculated NDVI and GCVI using `05-satellite-yield-measurements/02-scripts/03-calculate-indices/calculate-vis.py`. We checked them against images generated from SNAP. 

- The Sen2Cor program also produces a scene classification which we used to mask out clouds in the case of each index excluding LAI. We found the cloud classification from Sen2Cor to be very reliable in this sample. The LAI calculation in SNAP includes a mask layer, which we used in the case of that index. The masking code is included in `05-satellite-yield-measurements/02-scripts/03-calculate-indices/calculate-vis.py`. 

- We next mosaiced the imagery (merged all of the images for a given index and date) using the code in `05-satellite-yield-measurements/02-scripts/04-mosaic-imagery/mosaic.py`

- We then calculated zonal statistics for each index, date, and plot using the code in `05-satellite-yield-measurements/02-scripts/05-calc-zonal-stats/calc-zonal-stats.py`. The outputs are included in `05-satellite-yield-measurements/03-intermediate-data/Endline`

- This directory also has area calculations for each shapefile polygon. Area is in acres and was calculated using `05-satellite-yield-measurements/02-scripts/07-area/calculate-area.py`. 

- We calculated rainfall for each plot using the Google Earth Engine. The script used is included in `05-satellite-yield-measurements/02-scripts/06-rainfall/rainfall_google_ee.py`. We copied the output to `05-satellite-yield-measurements/03-intermediate-data/Endline-Rain-Google-EE/atai_rainfall_ee.csv` from Google Drive.

- We constructed placebo plot boundary data by taking a polygon containing the area within a 200 meter radius of each plot and subtracting the area within a 100 meter radius. We did this in a Jupyter Notebook that reveals PII, so it's not included. We used Geopandas, and we present the following 

```python
plot_boundary_data_aea = plot_boundary_data.to_crs({'proj' : 'aea', 'lat_1' : 15, 
                                                'lat_2' : 65, 'lat_0' : 30, 
                                                'lon_0' : 95, 'x_0' : 0, 'y_0' : 0, 
                                                'ellps' : 'WGS84', 'datum' : 'WGS84', 
                                                'units' : 'm', 'no_defs' : True})
buffer_200 = plot_boundary_data_aea.geometry.buffer(200)
buffer_100 = plot_boundary_data_aea.geometry.buffer(100)
ring = buffer_200.difference(buffer_100)
```

- We then calculated zonal stats using the placebo shapefile. The script is identical to that in `05-satellite-yield-measurements/02-scripts/05-calc-zonal-stats/calc-zonal-stats.py` other than the shapefile data source. The output is in `05-satellite-yield-measurements/03-intermediate-data/Placebo`

- We finally used the Stata `.do` file `05-satellite-yield-measurements/02-scripts/08-create-final-data/merge.do` to combine everything. The outputs are provided in  `05-satellite-yield-measurements/04-output-data`. These are the unmodified data sets used in later analysis.

