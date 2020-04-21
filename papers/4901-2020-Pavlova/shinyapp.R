## R Shiny app with SAS9API ##

devtools::install_github("anlaytium-group/rsas9api")
library(shiny)
library(rsas9api)
library(ggplot2)

## get data from SAS
data <- retrieve_data(url = "your_url",
                      serverName = "your_server",
                      libraryName = "SASHELP",
                      datasetName = "STOCKS",
                      asDataFrame = TRUE,
                      limit = 10000,
                      offset = 0)

## create Shiny app
ui <- fluidPage(
            titlePanel("SASHELP.STOCKS"),

            fluidRow(column(width = 4,
                            selectInput(inputId = "selectStock",
                                        label = "Select stock",
                                        choices = c("IBM", "Intel", "Microsoft")),
                            dateRangeInput(inputId = "Dates",
                                   label = "Select date period",
                                   start = "1986-08-01",
                                   end = "2005-12-01")
                            ),

                     column(width = 7, offset = 1,
                            strong("Number of records for the period:"),
                            textOutput("number"),
                            strong("Average of Open for the period:"),
                            textOutput("av_open"),
                            strong("Average of Close for the period:"),
                            textOutput("av_close"),
                            strong("Minimum of Low for the period:"),
                            textOutput("min_low"),
                            strong("Maximum of High for the period:"),
                            textOutput("max_high")
                            )
                     ),

            fluidRow(column(width = 12,
                            plotOutput("plot1")
                            )
                    ),

            fluidRow(column(width = 12,
                            dataTableOutput("table1")
                            )
                     )
)

server <- function(input, output) {
            datasubset <- reactive({
                data$Date <- as.Date(data$Date)
                subset(data, Date >= input$Dates[1] & Date <= input$Dates[2]
                       & Stock == input$selectStock)
            })

            output$number <- renderText({nrow(datasubset())})
            output$av_adjclose <- renderText({mean(datasubset()$AdjClose)})
            output$av_close <- renderText({mean(datasubset()$Close)})
            output$max_high <- renderText({max(datasubset()$High)})
            output$min_low <- renderText({min(datasubset()$Low)})
            output$av_open <- renderText({mean(datasubset()$Open)})
            output$av_volume <- renderText({mean(datasubset()$Volume)})
            output$plot1 <- renderPlot({ggplot(datasubset(),
                                                    aes(x = Date, y = Close,
                                                        group = Stock)) +
                                        geom_line() +
                                        geom_smooth(method = loess, se = FALSE,
                                                    colour = "red") +
                                        theme_classic()})
            output$table1 <- renderDataTable({datasubset()})
}

## run Shiny app
shinyApp(ui = ui, server = server)
