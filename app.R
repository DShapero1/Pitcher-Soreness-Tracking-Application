library(shiny)
library(dplyr)
library(shinydashboard)
library(googledrive)
library(googlesheets4)
library(shinythemes)
library(readr)
library(data.table)
library(DT)

# Read List of Pitchers
pitchers <- read_csv("PitcherList.csv")

# Google Sheets Authentication
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "d.shapero19@gmail.com")
gs4_auth(token = drive_token())

# UI Interface 
ui <- dashboardPage(
    skin = "black",
    dashboardHeader(
        title = "Pain Management",
        dropdownMenu(type = "messages",
                     messageItem(
                         from = "Hunter Gross",
                         message = "Please Describe Arm Pain"
                     )
        )
    ),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Form", tabName = "Form"),
            menuItem("Responses", tabName = "Res"),
            dateInput('date',
                          label = 'Date',
                          value = Sys.Date()),
            actionButton("save", "Save Response", icon = icon("save"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Form",
                    fluidRow(
                        box(selectInput("name", "Select Your Name", choices = sort(unique(pitchers$Name)))),
                        
                        box(selectInput("pain", "Overall Soreness", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput("shoulder1", "Front of Shoulder", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput("Shoulder2", "Back of Shoulder", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput("elbow", "Elbow", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput('bicep', "Bicep", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput('tricep', "Tricep", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput('forearm', "Forearm", choices = c(0, 1,2,3,4,5,6,7,8,9,10))),
                        
                        box(selectInput('lat', "Lat", choices = c(0, 1,2,3,4,5,6,7,8,9,10)))
                        
                        #box(dateInput('date',
                                      #label = 'Date',
                                      #value = Sys.Date())),

                        #box(actionButton("save", "Save Response", icon = icon("save")))
                        
                        #DT::dataTableOutput("data")
                    )),
            tabItem(tabName = "Res",
                    #DT::dataTableOutput("data")
                    box(textInput("text", "Specific Areas of Soreness", "")),
                    
                    box(textInput("text2", "Yesterday's Throwing", ""))
                    )
        )
    )
)

table_data <- data.frame(Name = as.character(), Date = as.Date(as.character()), OverallSoreness = as.integer(), FrontShoulder = as.integer(), BackShoulder = as.integer(),
                         Elbow = as.integer(), Bicep = as.integer(), Tricep = as.integer(), Forearm = as.integer(), Lat = as.integer(), Text = as.character(),
                         Text2 = as.character(),
                         check.names = F)
# Server running App
server <- shinyServer(function(input, output) {
    #Create Reactive to Store Data in Data Frame
    # values <- eventReactive(input$save, {
    #     Name <- as.character(input$name)
    #     OverallPain <- as.integer(input$pain)
    #     FrontShoulder <- as.integer(input$shoulder1)
    #     BackShoulder <- as.integer(input$Shoulder2)
    #     Elbow <- as.integer(input$elbow)
    #     Bicep <- as.integer(input$bicep)
    #     Tricep <- as.integer(input$tricep)
    #     Forearm <- as.integer(input$forearm)
    #     Lat <- as.integer(input$lat)
    #     
    #     values_bind <- cbind(Name, OverallPain, FrontShoulder, BackShoulder, Elbow, Bicep, Tricep, Forearm, Lat)
    #     df <- data.frame(values_bind)
    #     
    # })
    # output$data <- renderDataTable(values())
    
    
    # Create Table Values for Data Table / Append New Rows
        values <- reactiveValues()
        values$df <- data.frame(Name = as.character(), Date = as.Date(as.character()), OverallSoreness = as.integer(), FrontShoulder = as.integer(), BackShoulder = as.integer(),
                                Elbow = as.integer(), Bicep = as.integer(), Tricep = as.integer(), Forearm = as.integer(), Lat = as.integer(), Text = as.character(), Text2 = as.character())

        observeEvent(input$save, {
            new_row <- data.frame(Name = input$name, Date = input$date, Text2 = input$text2, OverallSoreness = input$pain, FrontShoulder = input$shoulder1, BackShoulder = input$Shoulder2,
                                  Elbow = input$elbow, Bicep = input$bicep, Tricep = input$tricep, Forearm = input$forearm, Lat = input$lat, Text = input$text, Text2 = input$text2)
            
            values$df <- rbind(values$df, new_row)
        })


        output$data <- DT::renderDataTable({values$df})
        
        text <- reactive({
            data.frame(Name = input$name, Date = input$date, Text2 = input$text2, OverallSoreness = input$pain, FrontShoulder = input$shoulder1, BackShoulder = input$Shoulder2,
                       Elbow = input$elbow, Bicep = input$bicep, Tricep = input$tricep, Forearm = input$forearm, Lat = input$lat, Text = input$text)
        })
        
        observeEvent(input$save, {
            ss <- gs4_get("https://docs.google.com/spreadsheets/d/1iO1DVE7WnxMfG0t0whLZEVQHtm_-zF3IkzBwAfXW6DM/edit#gid=0")
            sheet_append(ss, data = text(), sheet = 1)
        })
})
# Run the application 
shinyApp(ui = ui, server = server)