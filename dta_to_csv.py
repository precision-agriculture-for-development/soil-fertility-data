# -*- coding: utf-8 -*-

import os 
import pandas as pd 
import glob 


# Change working directory to the location of this file 
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)


# Find all .dta files 
for dirpath, dirnames, filenames in os.walk("."):
    for filename in [f for f in filenames if f.endswith(".dta")]:
        full_path = os.path.join(dirpath, filename)
        if '99-paper' in full_path:
            pass
        else:
            df = pd.read_stata(full_path)
            csv_path = os.path.join(dirpath, 'csv')
            if not os.path.isdir(csv_path):
                os.mkdir(csv_path)
            csv_name = os.path.splitext(filename)[0] + '.csv'
            full_csv_path = os.path.join(csv_path, csv_name)
            df.to_csv(full_csv_path, index=False)

