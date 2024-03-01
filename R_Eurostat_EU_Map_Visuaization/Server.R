library(shiny)
library(googleVis)
library(dplyr)
library(data.table)
library(DT)
library(ggplot2)

loadData <- function() {
  dataDir <- getwd()
  download.file(url="https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/demo_r_mwk_ts/?format=TSV&compressed=true&i",
                destfile=file.path(dataDir,"demo_r_mwk_ts.tsv.gz"), method="curl")
  d <- read.table(file=file.path(dataDir,"demo_r_mwk_ts.tsv.gz"), sep="\t", dec=".", header=T)
  
  country_codes <- unique(gsub(".*,(.*)$", "\\1", d[,1]))
  x <- as.data.frame(rbindlist(lapply(country_codes, function(country){
    x <- t(d[grep(country, d[,1]),])
    x <- x[-1,]
    options(warn=-1)
    x <- data.frame(
      week = gsub("X","",rownames(x)), 
      f = as.integer(gsub(" p","",x[,1])),
      m = as.integer(gsub(" p","",x[,2])),
      t = as.integer(gsub(" p","",x[,3])),
      c = country
    )
    options(warn=0)
    rownames(x) <- NULL
    x <- x[order(x$week),]
    return(x)
  })))
  return(x)
}

# Definicja logiki serwera
server <- function(input, output, session) {
  data <- reactiveVal()
  
  observeEvent(input$loadData, {
    data(loadData())
    updateSelectInput(session, "selectedCountries", choices = unique(data()$c))
    updateSelectInput(session, "selectedYears", choices = unique(substr(data()$week, 1, 4)))
  })
  
  filteredData <- reactive({
    req(data())
    data_filtered <- data()[data()$c %in% input$selectedCountries & substr(data()$week, 1, 4) %in% input$selectedYears, ]
    
    if ("m" %in% input$selectedGenders & "f" %in% input$selectedGenders) {
      return(data_filtered)
    } else if ("m" %in% input$selectedGenders) {
      data_filtered$t <- data_filtered$m
      return(data_filtered)
    } else if ("f" %in% input$selectedGenders) {
      data_filtered$t <- data_filtered$f
      return(data_filtered)
    } else {
      return(data.frame())
    }
  })
  
  output$timeSeriesPlot <- renderPlot({
    ggplot(data = filteredData(), aes(x = as.integer(factor(week)), y = t, group = c, color = c)) +
      geom_line() +
      facet_wrap(~c, ncol = 1, scales = "free_y") +
      geom_smooth(se = FALSE) +
      theme_minimal()
  })
  
  output$data_table <- renderDT({
    filteredData() %>%
      transform(Gender = ifelse(f == t, "Female", "Male")) %>%
      select(Country = c, Gender, Week = week, Number = t)
  }, options = list(pageLength = 25))
  
  output$euMap <- renderGvis({
    req(data())
    aggregated_data <- data() %>%
      filter(c %in% input$selectedCountries) %>%
      group_by(c) %>%
      summarise(Suma = sum(t, na.rm = TRUE))
    
    # Stworzenie mapy
    gvis_map <- gvisGeoChart(aggregated_data, 
                             locationvar="c", 
                             colorvar="Suma", 
                             options=list(region="150", 
                                          displayMode="regions", 
                                          resolution="countries"))
    
    return(gvis_map)
  })
}
