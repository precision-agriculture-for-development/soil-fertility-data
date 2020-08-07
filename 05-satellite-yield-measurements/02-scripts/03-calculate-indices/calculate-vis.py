# -*- coding: utf-8 -*-
from __future__ import print_function

from osgeo import gdal 
from osgeo import gdalconst
import os
import rasterio
import numpy
import itertools
import glob
import multiprocessing
from skimage.transform import resize
import tempfile

#Set directory
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)
os.chdir('../..')

#resample
def resample(inputfile, referencefile):
    input = gdal.Open(inputfile, gdalconst.GA_ReadOnly)
    inputProj = input.GetProjection()
    inputTrans = input.GetGeoTransform()

    reference = gdal.Open(referencefile, gdalconst.GA_ReadOnly)
    referenceProj = reference.GetProjection()
    referenceTrans = reference.GetGeoTransform()
    bandreference = reference.GetRasterBand(1)    
    x = reference.RasterXSize 
    y = reference.RasterYSize

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    driver= gdal.GetDriverByName('GTiff')
    output = driver.Create(tmp.name, x, y, 1, bandreference.DataType)
    output.SetGeoTransform(referenceTrans)
    output.SetProjection(referenceProj)

    gdal.ReprojectImage(input, output, inputProj, referenceProj, gdalconst.GRA_Bilinear)

    return tmp.name 


def downsample(inputfile, referencefile):
    input = gdal.Open(inputfile, gdalconst.GA_ReadOnly)
    inputProj = input.GetProjection()
    inputTrans = input.GetGeoTransform()

    reference = gdal.Open(referencefile, gdalconst.GA_ReadOnly)
    referenceProj = reference.GetProjection()
    referenceTrans = reference.GetGeoTransform()
    bandreference = reference.GetRasterBand(1)    
    x = reference.RasterXSize 
    y = reference.RasterYSize

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    driver= gdal.GetDriverByName('GTiff')
    output = driver.Create(tmp.name, x, y, 1, bandreference.DataType)
    output.SetGeoTransform(referenceTrans)
    output.SetProjection(referenceProj)

    gdal.ReprojectImage(input, output, inputProj, referenceProj, gdalconst.GRA_Average)

    return tmp.name 



def calc_ndvi(product, saveDir, masking=True, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_ndvi.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_ndvi.tif'
        print(x, " exists, skipping")
        return

    bandPath = product + '/GRANULE/L*/IMG_DATA/R10m/'
    b4_path = bandPath+'*B04*.jp2'
    for x in glob.glob(b4_path):
        b4_path = x
    with rasterio.open(b4_path) as f:
        b4 = f.read(1)
    b8_path = bandPath+'*B08*.jp2'
    for x in glob.glob(b8_path):
        b8_path = x
    with rasterio.open(b8_path) as f:
        b8 = f.read(1)

    if "L2A" in os.path.basename(product):
        maskPath = product + '/GRANULE/L*/IMG_DATA/R20m/*SCL*.jp2'
        for x in glob.glob(maskPath):
            maskPath = x
        with rasterio.open(maskPath) as f:
            classification = f.read(1)
        classification = resize(classification, b8.shape,order=0, preserve_range=True)

    else:
        raise Exception("Input has not been processed. Program may fail.")

    if "L2A" in os.path.basename(product):
        classification[classification == 1] = 0
        classification[classification == 3] = 0
        classification[classification == 8] = 0
        classification[classification == 9] = 0
        mask = (classification==0)
    # see http://step.esa.int/thirdparties/sen2cor/2.5.5/docs/S2-PDGS-MPC-L2A-IODD-V2.5.5.pdf page 23

    # Allow division by zero
    numpy.seterr(divide='ignore', invalid='ignore')
    ndvi = (b8.astype(float) - b4.astype(float)) / (b8 + b4)

    if masking == True:
        ndvi[mask] = 0

    # Set spatial characteristics of the output object to mirror the input
    with rasterio.open(b8_path) as src:
        kwargs = src.meta
    kwargs.update(
        dtype=rasterio.float32,
        driver='GTiff',
        count = 1,
        nodata = 0)

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    with rasterio.open(tmp.name, 'w', **kwargs) as dst:
        dst.write_band(1, ndvi.astype(rasterio.float32))

    save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_ndvi.tif'

    gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
    os.remove(tmp.name)


def true_color(product, saveDir, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_true_color.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_true_color.tif'
        print(x, " exists, skipping")
        return

    else:

        bandPath = product + '/GRANULE/L*/IMG_DATA/R10m/'

        b2_path = bandPath+'*B02*.jp2'
        for x in glob.glob(b2_path):
            b2_path = x
        with rasterio.open(b2_path) as f:
            b2 = f.read(1)

        b3_path = bandPath+'*B03*.jp2'
        for x in glob.glob(b3_path):
            b3_path = x
        with rasterio.open(b3_path) as f:
            b3 = f.read(1)

        b4_path = bandPath+'*B04*.jp2'
        for x in glob.glob(b4_path):
            b4_path = x
        with rasterio.open(b4_path) as f:
            b4 = f.read(1)

        # Set spatial characteristics of the output object to mirror the input
        with rasterio.open(b4_path) as src:
            kwargs = src.meta
        kwargs.update(
            driver='GTiff',
            count = 3,
            nodata = 0)

        tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
        tmp.close()

        with rasterio.open(tmp.name, 'w', **kwargs) as dst:
            dst.write_band(3, b2)
            dst.write_band(2, b3)
            dst.write_band(1, b4)

        save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_true_color.tif'

        gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
        os.remove(tmp.name)

def false_color(product, saveDir, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_false_color.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_false_color.tif'
        print(x, " exists, skipping")
        return

    else:

        bandPath = product + '/GRANULE/L*/IMG_DATA/R10m/'

        b8_path = bandPath+'*B08*.jp2'
        for x in glob.glob(b8_path):
            b8_path = x
        with rasterio.open(b8_path) as f:
            b8 = f.read(1)

        b3_path = bandPath+'*B03*.jp2'
        for x in glob.glob(b3_path):
            b3_path = x
        with rasterio.open(b3_path) as f:
            b3 = f.read(1)

        b4_path = bandPath+'*B04*.jp2'
        for x in glob.glob(b4_path):
            b4_path = x
        with rasterio.open(b4_path) as f:
            b4 = f.read(1)

        # Set spatial characteristics of the output object to mirror the input
        with rasterio.open(b4_path) as src:
            kwargs = src.meta
        kwargs.update(
            driver='GTiff',
            count = 3,
            nodata = 0)

        tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
        tmp.close()

        with rasterio.open(tmp.name, 'w', **kwargs) as dst:
            dst.write_band(3, b3)
            dst.write_band(2, b4)
            dst.write_band(1, b8)

        save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_false_color.tif'

        gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
        os.remove(tmp.name)


def reproject_mtci(product, saveDir, masking=True, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_mtci.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_mtci.tif'
        print(x, " exists, skipping")
        return

    mtci_path = product.replace('atai_endline/', 'atai_endline_mtci/') 
    mtci_path = mtci_path.replace('.SAFE', '.tif')

    with rasterio.open(mtci_path) as f:
        mtci = f.read(1)
        kwargs = f.meta 

    if "L2A" in os.path.basename(product):
        maskPath = product + '/GRANULE/L*/IMG_DATA/R20m/*SCL*.jp2'
        for x in glob.glob(maskPath):
            maskPath = x
        with rasterio.open(maskPath) as f:
            classification = f.read(1)
        classification = resize(classification, mtci.shape, order=0, preserve_range=True)

    else:
        raise Exception("Input has not been processed. Program may fail.")

    if "L2A" in os.path.basename(product):
        classification[classification == 1] = 0
        classification[classification == 3] = 0
        classification[classification == 8] = 0
        classification[classification == 9] = 0
        mask = (classification==0)
    # see http://step.esa.int/thirdparties/sen2cor/2.5.5/docs/S2-PDGS-MPC-L2A-IODD-V2.5.5.pdf page 23

    if masking == True:
        mtci[mask] = 0

    kwargs.update(
        dtype=rasterio.float32,
        driver='GTiff',
        count = 1,
        nodata = 0)

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    with rasterio.open(tmp.name, 'w', **kwargs) as dst:
        dst.write_band(1, mtci.astype(rasterio.float32))

    save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_mtci.tif'

    gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
    os.remove(tmp.name)


def reproject_re705(product, saveDir, masking=True, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_re705.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_re705.tif'
        print(x, " exists, skipping")
        return

    re705_path = product.replace('atai_endline/', 'atai_endline_re705/') 
    re705_path = re705_path.replace('.SAFE', '.tif') 

    with rasterio.open(re705_path) as f:
        re705 = f.read(1)
        kwargs = f.meta 

    if "L2A" in os.path.basename(product):
        maskPath = product + '/GRANULE/L*/IMG_DATA/R20m/*SCL*.jp2'
        for x in glob.glob(maskPath):
            maskPath = x
        with rasterio.open(maskPath) as f:
            classification = f.read(1)
        classification = resize(classification, re705.shape, order=0, preserve_range=True)

    else:
        raise Exception("Input has not been processed. Program may fail.")

    if "L2A" in os.path.basename(product):
        classification[classification == 1] = 0
        classification[classification == 3] = 0
        classification[classification == 8] = 0
        classification[classification == 9] = 0
        mask = (classification==0)
    # see http://step.esa.int/thirdparties/sen2cor/2.5.5/docs/S2-PDGS-MPC-L2A-IODD-V2.5.5.pdf page 23

    if masking == True:
        re705[mask] = 0

    kwargs.update(
        dtype=rasterio.float32,
        driver='GTiff',
        count = 1,
        nodata = 0)

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    with rasterio.open(tmp.name, 'w', **kwargs) as dst:
        dst.write_band(1, re705.astype(rasterio.float32))

    save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_re705.tif'

    gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
    os.remove(tmp.name)


def calc_ndwi(product, saveDir, masking=True, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_ndwi.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_ndwi.tif'
        print(x, " exists, skipping")
        return

    r10path = product + '/GRANULE/L*/IMG_DATA/R10m/'
    r20path = product + '/GRANULE/L*/IMG_DATA/R20m/'
    b8_path = r10path+'*B08*.jp2'
    for x in glob.glob(b8_path):
        b8_path = x
    with rasterio.open(b8_path) as f:
        b8 = f.read(1)
    b11_path = r20path +'*B11*.jp2'
    for x in glob.glob(b11_path):
        b11_path = x

    resampled_b11_path = resample(b11_path, b8_path)
    with rasterio.open(resampled_b11_path) as f:
        b11 = f.read(1)

    if "L2A" in os.path.basename(product):
        maskPath = product + '/GRANULE/L*/IMG_DATA/R20m/*SCL*.jp2'
        for x in glob.glob(maskPath):
            maskPath = x
        with rasterio.open(maskPath) as f:
            classification = f.read(1)
        classification = resize(classification, b8.shape,order=0, preserve_range=True)

    else:
        raise Exception("Input has not been processed. Program may fail.")

    if "L2A" in os.path.basename(product):
        classification[classification == 1] = 0
        classification[classification == 3] = 0
        classification[classification == 8] = 0
        classification[classification == 9] = 0
        mask = (classification==0)
    # see http://step.esa.int/thirdparties/sen2cor/2.5.5/docs/S2-PDGS-MPC-L2A-IODD-V2.5.5.pdf page 23

    # Allow division by zero
    numpy.seterr(divide='ignore', invalid='ignore')

    ndwi = (b8.astype(float) - b11.astype(float)) / (b8 + b11)

    if masking == True:
        ndwi[mask] = 0

    # Set spatial characteristics of the output object to mirror the input
    with rasterio.open(b8_path) as src:
        kwargs = src.meta
    kwargs.update(
        dtype=rasterio.float32,
        driver='GTiff',
        count = 1,
        nodata = 0)

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    with rasterio.open(tmp.name, 'w', **kwargs) as dst:
        dst.write_band(1, ndwi.astype(rasterio.float32))

    save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_ndwi.tif'

    gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
    os.remove(tmp.name)


def calc_gcvi(product, saveDir, masking=True, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_gcvi.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_gcvi.tif'
        print(x, " exists, skipping")
        return

    r10path = product + '/GRANULE/L*/IMG_DATA/R10m/'
    b8_path = r10path+'*B08*.jp2'
    for x in glob.glob(b8_path):
        b8_path = x
    with rasterio.open(b8_path) as f:
        b8 = f.read(1)
    b3_path = r10path+'*B03*.jp2'
    for x in glob.glob(b3_path):
        b3_path = x
    with rasterio.open(b3_path) as f:
        b3 = f.read(1)

    if "L2A" in os.path.basename(product):
        maskPath = product + '/GRANULE/L*/IMG_DATA/R20m/*SCL*.jp2'
        for x in glob.glob(maskPath):
            maskPath = x
        with rasterio.open(maskPath) as f:
            classification = f.read(1)
        classification = resize(classification, b8.shape,order=0, preserve_range=True)

    else:
        raise Exception("Input has not been processed. Program may fail.")

    if "L2A" in os.path.basename(product):
        classification[classification == 1] = 0
        classification[classification == 3] = 0
        classification[classification == 8] = 0
        classification[classification == 9] = 0
        mask = (classification==0)
    # see http://step.esa.int/thirdparties/sen2cor/2.5.5/docs/S2-PDGS-MPC-L2A-IODD-V2.5.5.pdf page 23

    # Allow division by zero
    numpy.seterr(divide='ignore', invalid='ignore')

    gcvi = (b8.astype(float) / b3.astype(float)) - 1

    if masking == True:
        gcvi[mask] = 0

    # Set spatial characteristics of the output object to mirror the input
    with rasterio.open(b8_path) as src:
        kwargs = src.meta
    kwargs.update(
        dtype=rasterio.float32,
        driver='GTiff',
        count = 1,
        nodata = 0)

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    with rasterio.open(tmp.name, 'w', **kwargs) as dst:
        dst.write_band(1, gcvi.astype(rasterio.float32))

    save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_gcvi.tif'

    gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
    os.remove(tmp.name)


def reproject_lai(product, saveDir, masking=True, reprocess=False):

    if reprocess==False and os.path.isfile(saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_lai.tif'):
        x = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_lai.tif'
        print(x, " exists, skipping")
        return

    with rasterio.open(product) as f:
        lai = f.read(1)
        raw_mask = f.read(2)
        kwargs = f.meta 

    mask = (raw_mask==1)
    lai[mask] = 0

    kwargs.update(
        dtype=rasterio.float32,
        driver='GTiff',
        count = 1,
        nodata = 0)

    tmp = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
    tmp.close()

    with rasterio.open(tmp.name, 'w', **kwargs) as dst:
        dst.write_band(1, lai.astype(rasterio.float32))

    save = saveDir +'/' + os.path.splitext(os.path.basename(product))[0] + '_lai.tif'

    gdal.Warp(save,tmp.name,dstSRS='EPSG:4326',srcNodata=0,dstNodata=0)
    os.remove(tmp.name)


def calc_all(product, fileFolder, masking=True, reprocess=False):
    calc_ndvi(product,fileFolder,masking=masking, reprocess=reprocess)
    reproject_mtci(product,fileFolder,masking=masking, reprocess=reprocess) # Note: raster calculated in snap
    reproject_re705(product,fileFolder,masking=masking, reprocess=reprocess) # Note: raster calculated in snap
    calc_gcvi(product,fileFolder,masking=masking, reprocess=reprocess)
    calc_ndwi(product,fileFolder,masking=masking, reprocess=reprocess)
    true_color(product, fileFolder, reprocess=reprocess)
    false_color(product, fileFolder, reprocess=reprocess)
    return None

def wrapper(item):
    return calc_all(*item)

def sentinelBandMath(MASTER_DIRECTORY, OUT_DIR, MASKING = True, PARALLEL = False, NUMBER_OF_CORES = 2, REPROCESS=False):

    if PARALLEL == True:
        print("Parallel processing")

        #Get number of workers from system
        num_workers = os.getenv('LSB_DJOB_NUMPROC',8)

        maxCores = min(len(MASTER_DIRECTORY),8,int(num_workers),NUMBER_OF_CORES)
        to_process = []
        for x in glob.glob(MASTER_DIRECTORY):
            if 'processed' in os.path.basename(x):
                pass
            else:
                to_process.append(x)

        #Use a multiprocessing pool for parallel processing
        hPool = multiprocessing.Pool(processes=maxCores)

        hPool.imap_unordered(
            func=wrapper, iterable=zip(to_process, itertools.repeat(OUT_DIR),
            itertools.repeat(MASKING), itertools.repeat(REPROCESS)))

        hPool.close()    # Prevent new jobs from running
        hPool.join()    # Wait for workers to complete all jobs

    else:

        for x in glob.glob(MASTER_DIRECTORY):
            if 'processed' in os.path.basename(x):
                pass
            else:
                calc_all(x, OUT_DIR, MASKING, REPROCESS)

sentinelBandMath("L2A DATA PATH/S2*.SAFE",
    "FOLDER TO SAVE VI IMAGES", True, False, 4, False)

for x in glob.glob("PATH WITH LAI IMAGES FROM SNAP/*.tif"):
    reproject_lai(x, "FOLDER TO SAVE VI IMAGES", True, False)

