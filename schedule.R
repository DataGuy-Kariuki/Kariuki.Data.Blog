# Install taskscheduleR if not already installed
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
