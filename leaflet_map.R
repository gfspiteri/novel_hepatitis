
con <- dbConnect(odbc(), Driver = "ODBC Driver 17 for SQL Server", Server = "nvsql3t.ecdcnet.europa.eu", Database = "ref",
                 uid = "NCOV_Shiny", pwd = "Pandemonium$9000")
con_pop <- dbConnect(odbc(), Driver = "ODBC Driver 17 for SQL Server", Server = "nsql3.ecdcnet.europa.eu", Database = "DM_ref",
                     uid = "NCOV_Shiny", pwd = "Pandemonium$9000")

shapes <- dbGetQuery(con,"select [LocationGeometryPLGId]
      ,[LocationCode]
      ,[LocationType]
      ,[Shape_PLG_WKT_WGS84] 
      from [ref].[dLocationGeometryPLG]
                     where LocationType = 'Country'")

coordinates <- dbGetQuery(con, "SELECT [LocationCode]
	   ,[LocationName]
      ,[CountryISO2Code]
      ,[CentroidLatitude]
      ,[CentroidLongitude]
      ,[Centroid_PNT]
      ,[Centroid_PNT_WKT_LAEA]
      ,[Centroid_PNT_WKT_WGS84]  
      FROM [REF].[ref].[dLocationGeometryPNT]
  where LocationType = 'Country'")

dataset_map = dataset %>% 
  group_by(GeoId) %>%
  count() %>%
  rename(LocationCode = GeoId) %>%
  mutate(PopupText = paste0("Number of cases in ", LocationCode, ": ", n)) %>%
  left_join(shapes) %>%
  st_as_sf(wkt = "Shape_PLG_WKT_WGS84")

shapes = shapes %>% 
  filter(LocationCode != "AQ") %>%
  st_as_sf(wkt = "Shape_PLG_WKT_WGS84")

leaflet() %>% 
  addPolygons(data = shapes, 
              stroke = F,
              highlightOptions = highlightOptions(
                weight = 5,
                color = "#666",
                fillOpacity = 1,
                bringToFront = F),
              layerId = ~LocationCode) %>%
  # addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
  addPolygons(data = dataset_map, 
              fillColor = ~n,
              stroke = F,
              highlightOptions = highlightOptions(
                weight = 5,
                color = "#666",
                fillOpacity = 0.7,
                bringToFront = T),
              popup = ~PopupText,
              layerId = ~LocationCode) 
