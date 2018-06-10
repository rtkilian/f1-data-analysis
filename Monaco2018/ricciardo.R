# Load the packages
library("jsonlite", lib.loc="~/anaconda3/lib/R/library")

# Import the data for Daniel Ricciardo the API in JSON format
url = "http://ergast.com/api/f1/2018/6/drivers/ricciardo/laps.json?limit=100"
data <- fromJSON(url)

# Get the laps from the data
laps <- data[["MRData"]][["RaceTable"]][["Races"]][["Laps"]]

# Get the times and positions from laps
times_positions <- laps[[1]][["Timings"]]

# Convert into a single data frame
times_positions <- do.call("rbind", times_positions)

# Remove the driverId column
times_positions <- times_positions[-1]

# Coerce the time column to a duration
options(digits.secs=3) # We want 3 decimal places for fractions of a second
times_positions$time <- strptime(times_positions$time, "%M:%OS")



