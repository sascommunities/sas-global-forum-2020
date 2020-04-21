### plotly 3D plot with SAS9API ###

devtools::install_github("anlaytium-group/rsas9api")
library(rsas9api)
library(plotly)
library(RColorBrewer)

## get data from SAS
data_quakes1 <- retrieve_data(url = "your_url",
                              serverName = "your_server",
                              libraryName = "SASHELP",
                              datasetName = "QUAKES",
                              limit = 10000, offset = 0,
                              asDataFrame = TRUE)

data_quakes2 <- retrieve_data(url = "your_url",
                              serverName = "your_server",
                              libraryName = "SASHELP",
                              datasetName = "QUAKES",
                              limit = 10000, offset = 10000,
                              asDataFrame = TRUE)

data_quakes <- rbind(data_quakes1, data_quakes2)

## create 3D plot
plot_ly(data = data_quakes,
        x = ~Latitude,
        y = ~Longitude,
        z = ~Depth*-1,
        intensity = ~Depth*-1,
        colors = "PRGn",
        type = "mesh3d")  %>%
    layout(title = "SASHELP.QUAKES dataset")


