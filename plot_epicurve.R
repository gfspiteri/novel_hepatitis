dataset_agg = dataset %>% 
  filter(EeuEeaStatus %in% c("EU", "EEA")) %>%
  mutate(DatePlot = str_sub(date2ISOweek(DatePlot), 1, 8)) %>%  group_by(DatePlot, DatePlotType) %>% count() %>%
  mutate(template = ifelse(n == 1,
                                '%{text}: %{y} case<extra></extra>',
                                '%{text}: %{y} cases<extra></extra>'))

first_dataset_date = min(dataset$DateOnset, dataset$DateRep, dataset$DateHospit, na.rm = T)
last_dataset_date = max(dataset$DateOnset, dataset$DateRep, dataset$DateHospit, na.rm = T)

report_weeks = unique(str_sub(date2ISOweek(seq.Date(from = first_dataset_date, to = last_dataset_date, by = "day")), 1, 8))
report_weeks = as.data.frame(report_weeks) %>% rename(DatePlot = report_weeks)

dataset_agg = dataset_agg %>% bind_rows(report_weeks) %>% mutate(DatePlotType = ifelse(is.na(DatePlotType), "Reporting date", DatePlotType),
                                                                 n = ifelse(is.na(n), 0, n))
  
  
plot_ly() %>% 
  add_trace(
        x = dataset_agg$DatePlot,
        y = dataset_agg$n,
        type = "bar",
        color = dataset_agg$DatePlotType,
        text = dataset_agg$DatePlotType,
        hovertemplate = dataset_agg$template) %>% 
  layout(barmode = "stack", 
         yaxis = list(title = 'Number of cases'),
         xaxis = list(title = 'Date'),
         legend = list(x = 0, y = 1, bgcolor = 'rgba(255, 255, 255, 0)', bordercolor = 'rgba(255, 255, 255, 0)'))
