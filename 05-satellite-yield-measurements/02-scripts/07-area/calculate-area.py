# -*- coding: utf-8 -*-
"""
Created on Sun Apr 29 15:17:59 2018

Python 3
"""

import geopandas as gpd
import json
import csv
import os

def shpArea(shp,outfile):
    
    inShape = gpd.read_file(shp)
    
    tost = inShape.copy()
    tost.crs = {'init': 'epsg:4326'}
    tost = tost.to_crs({'proj' : 'aea', 'lat_1' : 15, 'lat_2' : 65, 'lat_0' : 30, 'lon_0' : 95, 'x_0' : 0, 'y_0' : 0, 'ellps' : 'WGS84', 'datum' : 'WGS84', 'units' : 'm', 'no_defs' : True})
    tost["area"] = tost['geometry'].area/ 4046.86 #convert from square meters to acres
    
    x = tost.to_json()
    x = json.loads(x)
    
    stats = [d["properties"] for d in x["features"]]
    keys = stats[0].keys()
    with open(outfile,'w') as output_file:
            dict_writer = csv.DictWriter(output_file, keys, lineterminator='\n')
            dict_writer.writeheader()
            dict_writer.writerows(stats)
    

# Set the working directory to the location of this file	
shpArea("PATH TO SHAPEFILE","OUTPUT PATH/area.csv")
