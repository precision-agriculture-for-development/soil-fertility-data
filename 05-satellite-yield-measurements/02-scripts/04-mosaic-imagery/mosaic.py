# -*- coding: utf-8 -*-
"""
Creates merged vrts for ATAI endline data
"""

import os
import glob
from osgeo import gdal

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)
os.chdir('../..')

#First build VRTs containing  the merged raster stat data for each index/date 
indices = ['ndvi','re705','gcvi','ndwi','mtci','lai']
dates = ['20171107','20171028','20181107','20181104','20181028','20171102','20180928',
	'20181018','20181003','20181023','20171008', '20161028']

for i in indices:
  for d in dates:
    tiles = []
    path = 'PATH TO VI IMAGES/*' + d + '*' + i + '.tif'

    vrtPath = 'PATH TO STORE MOSAICED IMAGERY/' + i +'_' + d + '.virt'

    if os.path.isfile(vrtPath):
    	continue

    for x in glob.glob(path): 
      tiles.append(x)

    gdal.BuildVRT(vrtPath, tiles, srcNodata=0,VRTNodata=0)
