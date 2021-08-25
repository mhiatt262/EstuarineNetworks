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

# Script arguments...
## 04
ChannelCenters = "D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\Workspace_yahngze.gdb\\smooth_yangtze_MNDWI16" 
NotChannel = "D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\reclass_yangtze.tif"
Distance = "D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\Distance.img"

# Local variables...
## 04
chwdth = "D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\chwdth"
outTable = "D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\ZonalStats.dbf"

Output_direction_raster = ""
   
## 04 ADD WIDTHS TO THE CENTERLINES

# Process: Delete extra fields...
##print "Deleting fields..."
####arcpy.DeleteField_management(ChannelCenters, "arcid;grid_code;from_node;to_node")
##
### Process: Euclidean Distance...
##print "Calculating Distance..."
##gp.EucDistance_sa(NotChannel, Distance, "", "30", Output_direction_raster)
##
### Process: Single Output Map Algebra...
##gp.SingleOutputMapAlgebra_sa("INT ( %s * 2.0 )" % Distance, chwdth, Distance)
##
### Process: Build Raster Attribute Table...
##gp.BuildRasterAttributeTable_management(chwdth, "NONE")
##
### Process: Add Field for Unique ID...
##print "Link IDs..."
##gp.AddField_management(ChannelCenters, "Line_ID", "SHORT", "", "", "", "", "NULLABLE", "NON_REQUIRED", "")
##
### Create Unique counter...
##print "Unique IDs..."
##gp.CalculateField_management(ChannelCenters, "Line_ID", "!OBJECTID!", "PYTHON_9.3", "")
##
### Process: ZonalStatistics as a Table...
##print "Assigning width statistics to centerline features..."
##gp.ZonalStatisticsAsTable(ChannelCenters, "Line_ID", chwdth, outTable, "DATA", "ALL")
##
### Process: Join Table To Centerlines
##print "Joining table..."
##gp.JoinField_management(ChannelCenters, "Line_ID", outTable, "Line_ID")
##
##
#### 05 CREATION OF NODES, NUMBERING SCHEME, ASSIGNMENT TO LINK FEATURE CLASS, AND LAYING THE GROUNDWORK FOR ADJACENCY MATRIX
### Assign the name of the polyline file to which the adjacency matrix will be assigned
### Suggest not to edit any lines in this section unless specified
##fc = ChannelCenters # This can be edited
##
### Create node feature class
##out_path = "D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\"  # This can be edited
##out_name = "nodes_yangtze.shp"
##geometry_type = "POINT"
##template = ""
##has_m = ""
##has_z = ""
##spatial_reference = arcpy.Describe(fc).spatialReference
##print "Creating node shapefile..."
##arcpy.CreateFeatureclass_management(out_path, out_name, geometry_type, template, has_m, has_z, spatial_reference)
##
### Path & name for the node feature class 
##fc2 = out_path + out_name
##
### Add fields to the link array for the starting and ending node identifier
##fieldname1 = "StartNode"
##fieldname2 = "EndNode"
##fieldtype = "LONG"
##arcpy.AddField_management(fc, fieldname1, fieldtype, "", "", "", "", "", "")
##arcpy.AddField_management(fc, fieldname2, fieldtype, "", "", "", "", "", "")
##
### Create node identifier
##arcpy.AddField_management(fc2, "NODE_ID", fieldtype, "", "", "", "", "", "")
##
#### Automatically identify link endpoints and create nodes
##current_id = 0
##nodes = {}
####### Set up search cursor to go through the attribute table of the network link feature class
##print "Assigning node IDs..."
##with arcpy.da.UpdateCursor(fc,['SHAPE@']) as sc:
##    for row in sc:
##        # Identify the starting and each points of each feature class geometry element
##        startx = round(row[0].firstPoint.X,-1)
##        starty = round(row[0].firstPoint.Y,-1)
##        endx = round(row[0].lastPoint.X,-1)
##        endy = round(row[0].lastPoint.Y,-1)
##        # Another cursor to insert unique identifier associated with each start/endpoint
##        with arcpy.da.InsertCursor(fc2,["NODE_ID","SHAPE@XY"]) as ic:
##            # The if loop is included to handle any duplicates
##            if (startx,starty) not in nodes:
##                nodes[(startx,starty)] = current_id+1
##                xy1 = (startx,starty)
##                ic.insertRow([current_id+1,xy1])
##                current_id += 1
##            if (endx,endy) not in nodes:
##                nodes[(endx,endy)] = current_id+1
##                xy2 = (endx,endy)
##                ic.insertRow([current_id+1,xy2])
##                current_id += 1
##
####				
###### Automatically assign node identifiers to associated links##
##print "Assigning node IDs to links..."##
##with arcpy.da.UpdateCursor(fc,["StartNode","EndNode",'SHAPE@']) as sc:
##    for row in sc:
##        sc.updateRow(row)
##        startx = round(row[2].firstPoint.X,-1)
##        starty = round(row[2].firstPoint.Y,-1)
##        endx = round(row[2].lastPoint.X,-1)
##        endy = round(row[2].lastPoint.Y,-1)
##        with arcpy.da.InsertCursor(fc2,["NODE_ID","SHAPE@XY"]) as ic:
##            for key in nodes:
##                xy1 = (startx,starty)
##                xy2 = (endx,endy)
##                if key==xy1:
##                    row[0] = nodes[key]
##                    sc.updateRow(row)
##                if key==xy2:
##                    row[1] = nodes[key]
##                    sc.updateRow(row)
##
### Process: Add Field for DirectionIndex...
##print "DirectionIndex..."
##gp.AddField_management(ChannelCenters, "DirectionIndex", "SHORT", "", "", "", "", "NULLABLE", "NON_REQUIRED", "")
##                    

## 06 EXPORT TO TEXTFILE FOR MATLAB POST-PROCESSING
# Specify the output text file name
Output_ASCII_File="D:\\MattData\Estuary_Images\\LandSat8_OLI\\Yangtze\\Extracted_Channels\\Final_export.txt"
# Specify the attributes to be exported
Value_Field="Shape_Length;Line_ID;MIN;MAX;RANGE;MEAN;STD;SUM;VARIETY;MAJORITY;MINORITY;MEDIAN;StartNode;EndNode;DirectionIndex"
# Export!
arcpy.ExportXYv_stats(ChannelCenters, Value_Field, "SEMI-COLON", Output_ASCII_File,"NO_FIELD_NAMES")

