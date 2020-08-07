# -*- coding: utf-8 -*-
"""
Python 3.7 (works in other versions but then the concurrent.futures package 
is not default)
"""

import shutil
import glob
import multiprocessing
import subprocess
import os
import shlex

#Get number of workers from system 
num_workers = os.getenv('LSB_DJOB_NUMPROC', 2)
print(num_workers)

#Define the import directory with the .SAFE files
fileList = glob.glob("DIRECTORY TO DOWNLOADED SENTINEL-2 IMAGERY/S2*MSIL1C_20161028*.SAFE")

#Create a list of the commands that we want to run 
commands = ['L2A_Process "' + file + '"' for file in fileList] 

#Specify the maximum number of retry attempts per file
maxAttempts = 5

#Make sure no more cores are used than the number of files to process
maxCores = min(len(fileList),8,int(num_workers))
print(maxCores)

def process(command):
	attempt = 1 		
			
	#Give each tile maxAttempts possible tries and 2 hours to run
	while attempt < maxAttempts:
		try:
			subprocess.check_call(shlex.split(command), timeout=180*60)
			break
			
		except subprocess.CalledProcessError:
			attempt += 1
				
#Use a multiprocessing pool for parallel processing 
hPool = multiprocessing.Pool(processes=maxCores)

# Run function in parallel
hPool.imap_unordered(
	func=process, iterable=commands)

hPool.close()    # Prevent new jobs from running
hPool.join()    # Wait for workers to complete all jobs
			
#Finally move all of the processed images to a new folder
for processedImage in glob.glob("PATH TO DOWNLOADED SENTINEL-2 IMAGERY/S2*L2A*20161028*.SAFE"):
	 outPath = os.path.join("LOCATION TO SAVE PROCESSED IMAGERY/",os.path.basename(processedImage))	
	 shutil.move(processedImage,outPath)
