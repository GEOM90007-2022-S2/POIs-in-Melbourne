# Helper functions

# Read POI dataset
Sys.setenv(OWM_API_KEY = "25396bb7b2590590fcb12cf2b69fbcc7")

wifi_data <- read.csv('data/Melbourne_wifi.csv')
city_circle <- read.csv('data/cleaned_city_circle.csv')
landmark_data <- read.csv('data/landmark_poi.csv')
gallery_data <- read.csv('data/gallery_poi.csv')
church_data <- read.csv('data/church_poi.csv')
leisure_data <- read.csv('data/leisure_poi.csv')
visitorcenter_data <- read.csv('data/visitor_poi.csv')
retail_data <- read.csv('data/retail_poi.csv')
fountain_data <- read.csv('data/Drinking_fountains.csv')
toilet_data <- read.csv('data/Public_toilets.csv')
tram_track <- readOGR('data/Tram tracks.geojson')
vic_arrival <- read.csv('data/vic-arrival.csv')
minmax_temp <- read.csv('data/min_max_average_temp.csv')
minmax_temp$date <- ymd(minmax_temp$date)
rainfall <- read.csv('data/average_rainfall.csv')
rainfall$month <- month.abb[rainfall$month]
sunshine_duration <- read.csv('data/sunshine_duration.csv')
sunshine_duration$month <- month.abb[sunshine_duration$month]

current_weather <- get_current("Melbourne, AU", units = "metric")
rain_measure <- ifelse(is.null(current_weather$rain$`1h`), 0, current_weather$rain$`1h`)

forecast_data <- get_forecast("Melbourne, AU", units = "metric")
forecast_df <- data.frame(
  tmstmp =  forecast_data$list$dt_txt,
  temp = forecast_data$list$main.temp,
  fl_temp = forecast_data$list$main.feels_like,
  humidity = forecast_data$list$main.humidity
)
forecast_df$tmstmp <- ymd_hms(forecast_df$tmstmp)
forecast_df$tmstmp <- as.POSIXlt(forecast_df$tmstmp, tz="Australia/Sydney")

# Read weather dataset
maxTemp_data <- read.csv('data/weather_data/max_temp.csv')
minTemp_data <- read.csv('data/weather_data/min_temp.csv')
rainfall_data <- read.csv('data/weather_data/rainfall.csv')
maxTemp_data$Date = as.Date(with(maxTemp_data, paste(Year,Month,Day,sep="-")),"%Y-%m-%d")
minTemp_data$Date = as.Date(with(minTemp_data, paste(Year,Month,Day,sep="-")),"%Y-%m-%d")
rainfall_data$Date = as.Date(with(rainfall_data, paste(Year,Month,Day,sep="-")),"%Y-%m-%d")

landmarkIcon <- makeIcon(
  "www/landmark.png",
  iconWidth = 20,
  iconHeight = 20
)

wifiIcon <- makeIcon(
  "www/wifi.png",
  iconWidth = 16,
  iconHeight = 16
)

tramIcon <- makeIcon(
  "www/tram.png",
  iconWidth = 16,
  iconHeight = 16
)

museumIcon <- makeIcon(
  "www/museum.png",
  iconWidth = 20,
  iconHeight = 20
)

churchIcon <- makeIcon(
  "www/church.png",
  iconWidth = 20,
  iconHeight = 20
)

retailIcon <- makeIcon(
  "www/retail.png",
  iconWidth = 20,
  iconHeight = 20
)

leisureIcon <- makeIcon(
  "www/leisure.png",
  iconWidth = 20,
  iconHeight = 20
)

visitorcentreIcon <- makeIcon(
  "www/information.png",
  iconWidth = 20,
  iconHeight = 20
)

fountainIcon <- makeIcon(
  "www/fountain.png",
  iconWidth = 20,
  iconHeight = 20
)

toiletIcon <- makeIcon(
  "www/toilet.png",
  iconWidth = 20,
  iconHeight = 20
)

landmarkLabels <- sprintf(
  "Location: <strong>%s</strong><br/>Location Type: <strong>%s</strong>
  <br/><img src=%s height='176.5' width='300'>",
  landmark_data$feature_name, landmark_data$theme, landmark_data$url
) %>% lapply(htmltools::HTML)

galleryLabels <- sprintf(
  "Location: <strong>%s</strong><br/>Location Type: <strong>%s</strong>
  <br/><img src=%s height='176.5' width='300'>",
  gallery_data$feature_name, gallery_data$theme, gallery_data$url
) %>% lapply(htmltools::HTML)

churchLabels <- sprintf(
  "Location: <strong>%s</strong><br/>Location Type: <strong>%s</strong>
  <br/><img src=%s height='176.5' width='300'>",
  church_data$feature_name, church_data$theme, church_data$url
) %>% lapply(htmltools::HTML)

leisureLabels <- sprintf(
  "Location: <strong>%s</strong><br/>Location Type: <strong>%s</strong>
  <br/><img src=%s height='176.5' width='300'>",
  leisure_data$feature_name, leisure_data$theme, leisure_data$url
) %>% lapply(htmltools::HTML)

visitorcenterLabels <- sprintf(
  "Location: <strong>%s</strong><br/>Location Type: <strong>%s</strong>
  <br/><img src=%s height='176.5' width='300'>",
  visitorcenter_data$feature_name, visitorcenter_data$theme, visitorcenter_data$url
) %>% lapply(htmltools::HTML)

retailLabels <- sprintf(
  "Location: <strong>%s</strong><br/>Location Type: <strong>%s</strong>
  <br/><img src=%s height='176.5' width='300'>",
  retail_data$feature_name, retail_data$theme, retail_data$url
) %>% lapply(htmltools::HTML)

# Theme for dashboard
customTheme <- shinyDashboardThemeDIY(
  ### general
  appFontFamily = "Optima"
  ,appFontColor = "#2D2D2D"
  ,primaryFontColor = "#000000"
  ,infoFontColor = "#000000"
  ,successFontColor = "#0F0F0F"
  ,warningFontColor = "#D41A1A"
  ,dangerFontColor = "#D41A1A"
  ,bodyBackColor = "#FFFFFF"
  
  ### header
  ,logoBackColor = "#FFFFFF"
  
  ,headerButtonBackColor = "#FFFFFF"
  ,headerButtonIconColor = "#000000"
  ,headerButtonBackColorHover = "#CAE0E6"
  ,headerButtonIconColorHover = "#000000"
  
  ,headerBackColor = "#FFFFFF"
  ,headerBoxShadowColor = ""
  ,headerBoxShadowSize = "0px 0px 0px"
  
  ### sidebar
  ,sidebarBackColor = "#F0F0F0"
  ,sidebarPadding = "3"
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = "2"
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = ""
  ,sidebarShadowColor = "0px 0px 0px"
  
  ,sidebarUserTextColor = "#737373"
  
  ,sidebarSearchBackColor = "#FFFFFF"
  ,sidebarSearchIconColor = "#000000"
  ,sidebarSearchBorderColor = "#DCDCDC"
  
  ,sidebarTabTextColor = "#737373"
  ,sidebarTabTextSize = "15"
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = "0"
  
  ,sidebarTabBackColorSelected = "#D1D1D1"
  ,sidebarTabTextColorSelected = "#000000"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "#F5F5F5"
  ,sidebarTabTextColorHover = "#000000"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "#C8C8C8"
  ,sidebarTabBorderWidthHover = "4"
  ,sidebarTabRadiusHover = "0px"
  
  ### boxes
  ,boxBackColor = "#FFFFFF"
  ,boxBorderRadius = "5"
  ,boxShadowSize = "none"
  ,boxShadowColor = ""
  ,boxTitleSize = "20"
  ,boxDefaultColor = "#E1E1E1"
  ,boxPrimaryColor = "#5F9BD5"
  ,boxInfoColor = "#B4B4B4"
  ,boxSuccessColor = "#70AD47"
  ,boxWarningColor = "#ED7D31"
  ,boxDangerColor = "#E84C22"
  
  ,tabBoxTabColor = "#F8F8F8"
  ,tabBoxTabTextSize = "15"
  ,tabBoxTabTextColor = "#646464"
  ,tabBoxTabTextColorSelected = "#2D2D2D"
  ,tabBoxBackColor = "#F8F8F8"
  ,tabBoxHighlightColor = "#C8C8C8"
  ,tabBoxBorderRadius = "5"
  
  ### inputs
  ,buttonBackColor = "#E2D2FA"
  ,buttonTextColor = "#2D2D2D"
  ,buttonBorderColor = "#FFFFFF"
  ,buttonBorderRadius = "9"
  
  ,buttonBackColorHover = "#BEBEBE"
  ,buttonTextColorHover = "#000000"
  ,buttonBorderColorHover = "#969696"
  
  ,textboxBackColor = "#FFFFFF"
  ,textboxBorderColor = "#6C6C6C"
  ,textboxBorderRadius = "9"
  ,textboxBackColorSelect = "#F5F5F5"
  ,textboxBorderColorSelect = "#6C6C6C"
  
  ### tables
  ,tableBackColor = "#F8F8F8"
  ,tableBorderColor = "#EEEEEE"
  ,tableBorderTopSize = "5"
  ,tableBorderRowSize = "4"
)