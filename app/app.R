
library(shiny)

# Set the working directory (ensure it points to the correct location)
setwd("C:/Users/XaviourAluku.BERRY/Documents/model7/Amazon.iPhone.Scraping")

ui <- fluidPage(
    titlePanel("iPhone Data"),
    mainPanel(
        tableOutput("iphone_table"),
        verbatimTextOutput("error_message")  # For displaying error messages
    )
)

server <- function(input, output) {
    output$iphone_table <- renderTable({
        # Check if the file exists before trying to read it
        if (file.exists("iphone_data.csv")) {
            iphone_data <- read.table("iphone_data.csv", sep = ",", header = TRUE)
            return(iphone_data)
        } else {
            output$error_message <- renderText({
                "File 'iphone_data.csv' not found. Please ensure the file exists."
            })
            return(NULL)  # Return NULL if the file doesn't exist
        }
    })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
