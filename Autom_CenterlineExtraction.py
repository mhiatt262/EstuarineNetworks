# Import system modules
import sys, string, os, arcgisscripting

# Create the Geoprocessor object
gp = arcgisscripting.create()

# Check out any necessary licenses
gp.CheckOutExtension("spatial")

# Load required toolboxes...
gp.AddToolbox("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/Spatial Analyst Tools.tbx")
gp.AddToolbox("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/Data Management Tools.tbx")
gp.AddToolbox("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/Conversion Tools.tbx")

gp.overwriteoutput = 1

datelist=['20030227']

for date in datelist:
    
    # Script arguments...
    ## 01
    NotChannel_yyyymmdd_u_img = "U:\\MSc_Thesis\\Networkextraction\\02SelectedObjects\\NotChannel_%s_u.img" % date # provide a default value if unspecified
    Channel_yyyymmdd_u_img = "U:\\MSc_Thesis\\Networkextraction\\02SelectedObjects\\Channel_%s_u.img" % date # provide a default value if unspecified
    Clean_YYYYMMDD_img = "U:\\MSc_Thesis\\Networkextraction\\01Cleanclassified\\Clean_%s.img" % date # provide a default value if unspecified
    ClassifiedImage = "U:\\MSc_Thesis\\Classified\\TassCap\\Classified\\%s.img" % date

    ## 02
    Centerlines_yyymmdd = "U:\\MSc_Thesis\\Networkextraction\\03Centerlines\\Centerlines_%s.shp" % date # provide a default value if unspecified
    Channel_yyymmdd_u = "U:\\MSc_Thesis\\Networkextraction\\02SelectedObjects\\Channel_%s_u.img" % date # provide a default value if unspecified
    centerlines_yyyymmdd_e_shp = "U:\\MSc_Thesis\\Networkextraction\\03Centerlines\\centerlines_%s_e.shp" % date # provide a default value if unspecified


  
    # Local variables...
    ## 01
    IsWater = "U:\\MSc_Thesis\\TEMP\\SingleOutput1"
    WaterRegions = "U:\\TEMP\\RegionG_Sing1"
    WaterAreas = "U:\\TEMP\\ZonalGe_Regi1"
    Channel_YYYMMDD_r = "U:\\MSc_Thesis\\TEMP\\Channel__r.img"
    Channel_yyyymmdd_c_img = "U:\\MSc_Thesis\\TEMP\\Channel__c.img"
    NotChannel_yyyymmdd_c_img = "U:\\MSc_Thesis\\TEMP\\NotChannel__c.img"
    BarArea = "U:\\MSc_Thesis\\TEMP\\BarArea_.img"
    RegionG_NotC1 = "U:\\MSc_Thesis\\TEMP\\RegionG_NotC1"
    No_Bridge = "U:\\MSc_Thesis\\TEMP\\Nibble_200112"
    Bridge_Mask = "U:\\MSc_Thesis\\Networkextraction\\99BridgeMask\\bridge_mask.img"
    Clouds_Mask = "U:\\MSc_Thesis\\TEMP\\SingleOutput1"

    ## 02
    First_Result = "U:\\MSc_Thesis\\TEMP\\Thin_Channel1"
    Expanded = "U:\\MSc_Thesis\\TEMP\\Expand_Thin_2"
    CentPix_yyymmdd = "U:\\MSc_Thesis\\TEMP\\CentPix_.img"
    Expanded_SetNull = "U:\\MSc_Thesis\\TEMP\\SingleOutput1"


    ## 01
    # Process: Remove Bridge...
    gp.Nibble_sa(ClassifiedImage, Bridge_Mask, No_Bridge, "ALL_VALUES")

    # Process: Create Cloud Mask...
    gp.SingleOutputMapAlgebra_sa("SetNull ( %s == 4 OR %s == 0, 1 )" % (ClassifiedImage,ClassifiedImage), Clouds_Mask, "''")

    # Process: Remove Clouds...
    gp.Nibble_sa(No_Bridge, Clouds_Mask, Clean_YYYYMMDD_img, "ALL_VALUES")

    # Process: Select Water...
    gp.SingleOutputMapAlgebra_sa("SetNull ( %s <> 1 , 1 )" % Clean_YYYYMMDD_img, IsWater, "U:\\MSc_Thesis\\Networkextraction\\01Cleanclassified\\Clean_.img")

    # Process: Region Group...
    gp.RegionGroup_sa(IsWater, WaterRegions, "EIGHT", "WITHIN", "ADD_LINK", "")

    # Process: Zonal Geometry...
    gp.ZonalGeometry_sa(WaterRegions, "VALUE", WaterAreas, "AREA", "30")

    # Process: Select largest waterbody...
    gp.SingleOutputMapAlgebra_sa("SetNull ( %s < 350000000 , 1 )" % WaterAreas, Channel_YYYMMDD_r, "U:\\TEMP\\ZonalGe_Regi1")

    # Process: Boundary Clean (2)...
    gp.BoundaryClean_sa(Channel_YYYMMDD_r, Channel_yyyymmdd_c_img, "DESCEND", "ONE_WAY")

    # Process: Single Output Map Algebra...
    gp.SingleOutputMapAlgebra_sa("SetNull ( IsNull ( %s ) == 0 , 1 )" % Channel_yyyymmdd_c_img, NotChannel_yyyymmdd_c_img, "U:\\MSc_Thesis\\TEMP\\Channel__c.img")

    # Process: Region Group (2)...
    gp.RegionGroup_sa(NotChannel_yyyymmdd_c_img, RegionG_NotC1, "FOUR", "WITHIN", "ADD_LINK", "")

    # Process: Zonal Geometry (2)...
    gp.ZonalGeometry_sa(RegionG_NotC1, "VALUE", BarArea, "AREA", "30")

    # Process: Single Output Map Algebra (2)...
    gp.SingleOutputMapAlgebra_sa("Setnull ( ( %s > 21600 ) == 0, 1 )" % BarArea, NotChannel_yyyymmdd_u_img, "U:\\MSc_Thesis\\TEMP\\BarArea_.img")

    # Process: Single Output Map Algebra (3)...
    gp.SingleOutputMapAlgebra_sa("Setnull ( IsNull ( %s ) == 0 , 1 )" % NotChannel_yyyymmdd_u_img, Channel_yyyymmdd_u_img, "U:\\MSc_Thesis\\Networkextraction\\02SelectedObjects\\NotChannel__u.img")


    ## 02
    # Process: Thin...
    gp.Thin_sa(Channel_yyymmdd_u, First_Result, "NODATA", "NO_FILTER", "ROUND", "300")

    # Process: Expand...
    gp.Expand_sa(First_Result, Expanded, "2", "1")

    # Process: Single Output Map Algebra...
    gp.SingleOutputMapAlgebra_sa("SetNull ( %s == 0 , 1 )" % Expanded, Expanded_SetNull, "U:\\MSc_Thesis\\TEMP\\Expand_Thin_2")

    # Process: Thin (2)...
    gp.Thin_sa(Expanded_SetNull, CentPix_yyymmdd, "NODATA", "NO_FILTER", "ROUND", "300")

    # Process: Raster to Polyline...
    gp.RasterToPolyline_conversion(CentPix_yyymmdd, Centerlines_yyymmdd, "ZERO", "2000", "NO_SIMPLIFY", "VALUE")

    # Process: Copy Features...
    gp.CopyFeatures_management(Centerlines_yyymmdd, centerlines_yyyymmdd_e_shp, "", "0", "0", "0")
    

