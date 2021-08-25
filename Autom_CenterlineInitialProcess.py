# Import system modules
import sys, string, os, arcgisscripting, arcpy
from arcpy import env

# Create the Geoprocessor object
gp = arcgisscripting.create()

# Set the necessary product code
gp.SetProduct("ArcInfo")

# Check out any necessary licenses
gp.CheckOutExtension("spatial")

# Load required toolboxes...
gp.AddToolbox("C:\Program Files (x86)\ArcGIS\Desktop10.4\ArcToolbox\Toolboxes\Spatial Analyst Tools.tbx")
gp.AddToolbox("C:\Program Files (x86)\ArcGIS\Desktop10.4\ArcToolbox\Toolboxes\Data Management Tools.tbx")
gp.AddToolbox("C:\Program Files (x86)\ArcGIS\Desktop10.4\ArcToolbox\Toolboxes\Conversion Tools.tbx")
#gp.AddToolbox("C:\Program Files (x86)\ArcGIS\Desktop10.4\ArcToolbox\Toolboxes\Coverage Tools.tbx")

gp.overwriteoutput = 1

## Convert the raster output from the RivaMap into a feature class
env.workspace = "D:\\MattData\\Estuary_Images\\LandSat8_OLI\\Ireland\\Extracted_Channels\\"

#Set local variables
inRaster = "centers_Bannow_export.tif"
outLines = "D:\\MattData\\Estuary_Images\\LandSat8_OLI\\Ireland\\Extracted_Channels\\Workspace_Bannow.mdb\\cen_raw_Bannow_MNDWI4"
backgrdVal = "Zero"
dangleTol = 240
simplify = "NO_SIMPLIFY"
field = "VALUE"

# Execute RasterToPolygon
arcpy.RasterToPolyline_conversion(inRaster, outLines, backgrdVal,dangleTol, simplify, field)

# Reclassify binary mask
binary = "D:\\MattData\\Estuary_Images\\LandSat8_OLI\\Ireland\\Extracted_Channels\\binary_Bannow_export.tif"
arcpy.gp.Reclassify_sa(binary, "Value", "0 1;0 1 NODATA", "D:\\MattData\\Estuary_Images\\LandSat8_OLI\\Ireland\\Extracted_Channels\\reclass_Bannow.tif", "DATA")

## From here the remaining connectivity needs to be drawn manually
