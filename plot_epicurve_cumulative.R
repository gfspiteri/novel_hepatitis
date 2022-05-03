dataset_agg_cum = dataset %>% 
  filter(EeuEeaStatus %in% c("EU", "EEA")) %>%
  mutate(DatePlot = str_sub(date2ISOweek(DatePlot), 1, 8)) %>%  group_by(DatePlot) %>% count() %>%
  ungroup()

first_dataset_date_cum = min(dataset$DateOnset, dataset$DateRep, dataset$DateHospit, na.rm = T)
last_dataset_date_cum = max(dataset$DateOnset, dataset$DateRep, dataset$DateHospit, na.rm = T)

report_weeks = unique(str_sub(date2ISOweek(seq.Date(from = first_dataset_date, to = last_dataset_date, by = "day")), 1, 8))
report_weeks = report_weeks[!report_weeks %in% dataset_agg_cum$DatePlot]
report_weeks = as.data.frame(report_weeks) %>% rename(DatePlot = report_weeks)

dataset_agg_cum = dataset_agg_cum %>% bind_rows(report_weeks) %>% mutate(n = ifelse(is.na(n), 0, n)) %>%
  arrange(DatePlot) %>%
  mutate(n = cumsum(n)) %>%
  mutate(template = ifelse(n == 1,
                           '%{y} case<extra></extra>',
                           '%{y} cases<extra></extra>')) 


plot_ly() %>% 
  add_trace(
    x = dataset_agg_cum$DatePlot,
    y = dataset_agg_cum$n,
    type = "bar",
    hovertemplate = dataset_agg_cum$template) %>% 
  layout(barmode = "stack", 
         yaxis = list(title = 'Number of cases'),
         xaxis = list(title = 'Date'),
         legend = list(x = 0, y = 1, bgcolor = 'rgba(255, 255, 255, 0)', bordercolor = 'rgba(255, 255, 255, 0)'))
