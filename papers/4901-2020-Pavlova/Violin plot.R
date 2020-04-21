### R ggplot violin with SAS9API ###

devtools::install_github("anlaytium-group/rsas9api")
library(rsas9api)
library(ggplot2)
library(RColorBrewer)

## get data from SAS
data_cars <- retrieve_data(url = "your_url", 
                           serverName = "your_server",
                           libraryName = "SASHELP", 
                           datasetName = "CARS",
                           limit = 10000, 
                           offset = 0, 
                           asDataFrame = TRUE)
head(data_cars)

## create violin plot
ggplot(data_cars, aes(x = Type, y = MPG_City, fill = Type)) +
  geom_violin(trim = FALSE, lwd = 0.75) +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "City Mileage per Type of vehicle",
       x = "Type of Vehicle",
       y = "City Mileage") +
  theme_bw() +
  theme(legend.position = "none")

