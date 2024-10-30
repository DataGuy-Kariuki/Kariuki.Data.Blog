#start by loading the packages

#install.packages("rvest")  # For web scraping
#install.packages("dplyr")  # For data manipulation

# Load necessary libraries
library(rvest)  # For web scraping
library(dplyr)  # For data manipulation

# Define a function to scrape iPhone data
scrape_iphone_data <- function() {
  # Load the Amazon page with iPhone listings
  amazon <- read_html("https://www.amazon.in/s?k=iphone&crid=154N2SMA50ZCL&sprefix=iphone%2Caps%2C321&ref=nb_sb_noss_1")
  
  # Extract titles of iPhones
  titles <- amazon %>% html_nodes(".a-size-medium") %>% html_text(trim = TRUE)
  
  # Extract ratings
  ratings <- amazon %>% html_nodes(".a-icon-alt") %>% html_text(trim = TRUE)
  
  # Extract costs (prices)
  costs <- amazon %>% html_nodes(".a-price-whole") %>% html_text(trim = TRUE)
  
  # Find the minimum length to align all data
  min_length <- min(length(titles), length(ratings), length(costs))
  
  # If there is no data, return a message and NULL
  if (min_length == 0) {
    message("No data scraped. Please check the website structure or your internet connection.")
    return(NULL)
  }
  
  # Align data lengths
  titles <- titles[1:min_length]
  ratings <- ratings[1:min_length]
  costs <- costs[1:min_length]
  
  # Add a timestamp to track the scraping time
  timestamp <- Sys.time()
  
  # Create a data frame with the scraped data
  iphone_data <- data.frame(
    Timestamp = rep(timestamp, min_length),
    Titles = titles,
    Ratings = ratings,
    Cost = costs,
    stringsAsFactors = FALSE
  )
  
  # Define the file path for the CSV file
  csv_file_path <- "C:/Users/XaviourAluku.BERRY/Documents/model7/Amazon.iPhone.Scraping/iphone_data.csv"
  
  # Save to CSV (append if file exists)
  write.table(
    iphone_data,
    file = csv_file_path,
    sep = ",",
    row.names = FALSE,
    col.names = !file.exists(csv_file_path),
    append = TRUE
  )
  
  return(iphone_data)
}

# Run the scraping function
scraped_data <- scrape_iphone_data()

# Check if data was successfully scraped and print it
if (!is.null(scraped_data)) {
  print(scraped_data)
} else {
  message("No data available to display.")
}


#Install taskscheduleR if not already installed
# install.packages("taskscheduleR")

library(taskscheduleR)

# Specify the path to your R script (including the .R extension)
script_path <- "C:/Users/XaviourAluku.BERRY/Documents/model7/Amazon.iPhone.Scraping"

# Check if the task already exists and delete it if necessary
if ("daily_iphone_scrape" %in% taskscheduler_ls()$taskname) {
  taskscheduler_delete(taskname = "daily_iphone_scrape")
}

# Schedule the task to run daily at 8 AM
taskscheduler_create(
  taskname = "daily_iphone_scrape",
  rscript = script_path,
  schedule = "DAILY",
  starttime = "08:00"
)

# List scheduled tasks to verify
scheduled_tasks <- taskscheduler_ls()
print(scheduled_tasks)


#web app to show this data now 
library(shiny)
library(ggplot2)
library(dplyr)

# Set the working directory (ensure it points to the correct location)
setwd("C:/Users/XaviourAluku.BERRY/Documents/model7/Amazon.iPhone.Scraping")

# Set the local time zone
Sys.setenv(TZ = "Africa/Nairobi")

ui <- fluidPage(
  titlePanel("iPhone Data"),
  
  # Create a sidebar layout
  sidebarLayout(
    sidebarPanel(
      downloadButton("download_data", "Download Data as CSV")  # Download button
    ),
    mainPanel(
      plotOutput("cost_plot"),              # Output for the cost plot at the top
      tableOutput("iphone_table"),          # Table of iPhone data below the plot
      verbatimTextOutput("error_message"),
      verbatimTextOutput("current_time")     # Display current local time
    )
  )
)

server <- function(input, output) {
  output$iphone_table <- renderTable({
    if (file.exists("iphone_data.csv")) {
      iphone_data <- read.table("iphone_data.csv", sep = ",", header = TRUE)
      return(iphone_data)
    } else {
      output$error_message <- renderText({
        "File 'iphone_data.csv' not found. Please ensure the file exists."
      })
      return(NULL)
    }
  })
  
  output$current_time <- renderText({
    format(Sys.time(), tz = "Africa/Nairobi", usetz = TRUE)  # Show current local time
  })
  
  output$cost_plot <- renderPlot({
    if (file.exists("iphone_data.csv")) {
      iphone_data <- read.table("iphone_data.csv", sep = ",", header = TRUE)
      
      # Convert Cost to numeric after removing any non-numeric characters (e.g., commas)
      iphone_data$Cost <- as.numeric(gsub(",", "", iphone_data$Cost))
      
      # Create a bar plot for average cost
      ggplot(iphone_data, aes(x = Titles, y = Cost)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        labs(title = "Average Cost of iPhones",
             x = "iPhone Models",
             y = "Cost (in local currency)") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste("iphone_data_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      if (file.exists("iphone_data.csv")) {
        file.copy("iphone_data.csv", file)
      } else {
        stop("File 'iphone_data.csv' not found. Please ensure the file exists.")
      }
    }
  )
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
