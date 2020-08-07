# -*- coding: utf-8 -*-
"""
Calculates the zonal stats from a shapefile input and writes to a csv
"""

from rasterstats import zonal_stats
import os
import csv
import glob
from osgeo import gdal

def calcZonalStats(shape, raster, outDir, allTouched = False, reprocess=False):

  exp_path = outDir + '/' + os.path.basename(raster)[:-4] + 'csv'
  if reprocess == False and os.path.isfile(exp_path):
    return 

  else:
    stats = zonal_stats(shape,raster,stats=['median','mean'],all_touched=allTouched,geojson_out=True)
    stats = [d['properties'] for d in stats]
    keys = stats[0].keys()
    with open(exp_path,'w',newline='') as output_file:
      dict_writer = csv.DictWriter(output_file, keys)
      dict_writer.writeheader()
      dict_writer.writerows(stats)

for x in glob.glob("PATH TO MOSAICED IMAGERY/*.virt"):
  calcZonalStats("PATH TO SHAPEFILE",
    x, "PATH TO STORE CSVs", False, True)
