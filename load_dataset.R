url = "http://dms.ecdcnet.europa.eu/sites/srs/eir/eieo/eidb/hepatitis/Hepatitis_unknown_aetiology_Multicountry_2022_CaseB_DataSet.xlsm"

if(Sys.info()["sysname"] == "Windows"){
  httr::GET(url, httr::authenticate(":", ":", type="ntlm"), httr::write_disk(tf <- tempfile(fileext = ".xlsm")))
} else if(Sys.info()["sysname"] == "Linux"){
  httr::GET(url, httr::authenticate(
    "rsrvfil",
    "S8toGEHw4vaURm2cWeyL",
    type="ntlm"), httr::write_disk(tf <- tempfile(fileext = ".xlsm")))
}

dataset = read.xlsx(tf, sheet = "Dataset", detectDates = T) %>%
  mutate(DatePlot = case_when(
    !is.na(DateOnset) ~ DateOnset,
    !is.na(DateHospit) ~ DateHospit,
    TRUE ~ DateRep
  ),
  DatePlotType = case_when(
    !is.na(DateOnset) ~ "Date of onset",
    !is.na(DateHospit) ~ "Date of hospitalisation",
    TRUE ~ "Reporting date"
  ))