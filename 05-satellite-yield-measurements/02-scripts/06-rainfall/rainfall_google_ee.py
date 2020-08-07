# -*- coding: utf-8 -*-

import ee 

ee.Initialize()

###############################################################
# ENTER USER INPUTS HERE  
###############################################################
plot_boundaries = ee.FeatureCollection('') # Upload plot boundary data (e.g. using the Google Earth Engine console) and insert the asset ID here, in single or double quotes
aoi = ee.FeatureCollection('') # Upload AOI polygon (e.g. using the Google Earth Engine console) and insert the asset ID here, in single or double quotes
# The AOI can contain multiple polygons, but should be relatively simple. A bounding box or convex hull around all plot boundaries is appropriate

# Start and end dates for image search (YYYY-MM-DD)
begin = ee.Date('2010-06-01') # E.g. '2019-08-01'
end = ee.Date('2019-11-01') # E.g. '2019-12-15'

# Export information (to Google Drive)
output_folder = ''  # Folder name to save outputs in Google drive. The folder should be created before running the script.
output_file = '' # Output file name  

##############################################################
# END USER INPUTS 
##############################################################

# Create filter to only extract data from June 1st- November 1st for each year (modification from template script)
filter_2010 = ee.Filter.date('2010-06-01','2010-11-01')
filter_2011 = ee.Filter.date('2011-06-01','2011-11-01')
filter_2012 = ee.Filter.date('2012-06-01','2012-11-01')
filter_2013 = ee.Filter.date('2013-06-01','2013-11-01')
filter_2014 = ee.Filter.date('2014-06-01','2014-11-01')
filter_2015 = ee.Filter.date('2015-06-01','2015-11-01')
filter_2016 = ee.Filter.date('2016-06-01','2016-11-01')
filter_2017 = ee.Filter.date('2017-06-01','2017-11-01')
filter_2018 = ee.Filter.date('2018-06-01','2018-11-01')
filter_2019 = ee.Filter.date('2019-06-01','2019-11-01')

allYearsFilter = ee.Filter.Or(filter_2010, filter_2011, filter_2012, filter_2013, filter_2014, 
                              filter_2015, filter_2016, filter_2017, filter_2018, filter_2019)

# Import GPM rainfall data and SRTM elevation data 
gpm = ee.ImageCollection('NASA/GPM_L3/IMERG_V06').filter(allYearsFilter)\
    .filterMetadata('status', 'equals', 'permanent')

# Create a separate image collection by day
number_of_days = end.difference(begin, 'day')
def calculateDays(day):
    return begin.advance(day,'day')

list_of_days = ee.List.sequence(0, number_of_days.subtract(1)).map(calculateDays)

# Calculate average rainfall for each day (mm/hr)
def averageDailyRainfall(date, newlist):
	# Cast values
    date = ee.Date(date)
    newlist = ee.List(newlist)
    
    # Filter collection between date and the next day
    filtered_day = gpm.filterDate(date, date.advance(1,'day'))
    image = filtered_day.mean().select('precipitationCal').clip(aoi).set({'Date': date}).rename('average_rainfall')

    # Add the mosaic to a list only if the collection has images
    return ee.List(ee.Algorithms.If(filtered_day.size(), newlist.add(image), newlist))

rain_by_day = ee.ImageCollection(ee.List(list_of_days.iterate(averageDailyRainfall, ee.List([]))))

# Calculate rainfall for each plot and day
# Note: for GPM we have to specify a scale below the native resolution because pixel sizes are much larger than plot size
# Nearest neighbor resampling (the default) is used, so there is no transformation to the data
def zonalStats(image):
    date = image.get("Date")
    toReturn = image.reduceRegions(reducer=ee.Reducer.mean(), collection=plot_boundaries, scale=20)
    return toReturn.set('Date', date)

zonal_stats = rain_by_day.map(zonalStats)

#  Remove geometry from the zonal stats
def processFeature(feature):
    return feature.setGeometry(None)

def removeGeometry(featureCollection):
    fc = ee.FeatureCollection(featureCollection)  # Cast
    fc_date = ee.Date(fc.get('Date')).format('yyyy-MM-dd')  # Get date to assign
    fc_no_geometry = fc.map(processFeature)
    toReturn = fc_no_geometry.map(lambda x: x.set({'Date': fc_date}))
    return toReturn

zonal_stats_no_geometry = zonal_stats.map(removeGeometry).flatten()

# Export the data to Google Drive
task = ee.batch.Export.table.toDrive(collection=zonal_stats_no_geometry, description=output_file, 
                        fileFormat='CSV', fileNamePrefix=output_file,
                        folder=output_folder)

task.start()    


