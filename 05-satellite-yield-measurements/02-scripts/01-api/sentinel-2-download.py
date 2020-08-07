# -*- coding: utf-8 -*-
"""
Created on Wed Jul 11 13:49:16 2018
@author: gkilleen
Python 3.6
Downloads data from Sentinel-2 for ATAI year 2
"""

import os
from sentinelsat import SentinelAPI, read_geojson, geojson_to_wkt


#Change directory to a folder we want the data to download to 
os.chdir('INSERT RAW IMAGERY DIRECTORY')

## Download satellite files from the API

api = SentinelAPI('USERNAME', 'PASSWORD','https://scihub.copernicus.eu/dhus')



# search by polygon, time, and SciHub query keywords
footprint = geojson_to_wkt(read_geojson('PATH-TO-CONVEX-HULL'))

products = api.query(footprint,
                     date = ('20181027', '20181029'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 5))

# download all results from the search
api.download_all(products)

products = api.query(footprint,
                     date = ('20181103', '20181105'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 5))

api.download_all(products)

products = api.query(footprint,
                     date = ('20181106', '20181108'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 5))

api.download_all(products)

products = api.query(footprint,
                     date = ('20171106', '20171108'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 5))

api.download_all(products)

products = api.query(footprint,
                     date = ('20171101', '20171103'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 5))

api.download_all(products)

products = api.query(footprint,
                     date = ('20171027', '20171029'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 10))

api.download_all(products)

products = api.query(footprint,
                     date = ('20180927', '20180929'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 10))

api.download_all(products)

products = api.query(footprint,
                     date = ('20181002', '20181004'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 10))

api.download_all(products)

products = api.query(footprint,
                     date = ('20181012', '20181014'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 10))

api.download_all(products)

products = api.query(footprint,
                     date = ('20181017', '20181019'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 10))

api.download_all(products)

products = api.query(footprint,
                     date = ('20181022', '20181024'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 10))

api.download_all(products)

products = api.query(footprint,
                     date = ('20171007', '20171009'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 20))

api.download_all(products)

products = api.query(footprint,
                     date = ('20161027', '20161029'),
                     platformname = 'Sentinel-2',
                     cloudcoverpercentage = (0 , 20))

api.download_all(products)

