library(shiny)
library(googleVis)
library(dplyr)
library(data.table)
library(DT)
library(ggplot2)

ui <- navbarPage("Analysis of mortality data from EUROSTAT",
                 tabPanel("Time series chart",
                          sidebarLayout(
                            sidebarPanel(
                              actionButton("loadData", "Download fresh data"),
                              selectInput("selectedCountries", "Choose countries:",
                                          choices = NULL,
                                          selected = "PL",
                                          multiple = TRUE),
                              selectInput("selectedYears", "Choose years:",
                                          choices = NULL,
                                          selected = c("2020", "2021", "2022", "2023"),
                                          multiple = TRUE),
                              checkboxGroupInput("selectedGenders", "Choose gender:",
                                                 choices = c("Male" = "m", "Female" = "f"),
                                                 selected = c("m", "f"))
                            ),
                            mainPanel(
                              plotOutput("timeSeriesPlot")
                            )
                          )
                 ),
                 tabPanel("Data table",
                          DTOutput("data_table")
                 ),
                 tabPanel("EU map",
                          htmlOutput("euMap")
                 )
)
