# Load the packages
library("jsonlite", lib.loc="~/anaconda3/lib/R/library")

# Import the data in JSON format
url = "http://ergast.com/api/f1/2018/6/laps.json?limit=2000"
data <- fromJSON(url)

# Get the laps from the data
laps <- data[["MRData"]][["RaceTable"]][["Races"]][["Laps"]]

# Get the times and positions from laps
times_positions <- laps[[1]][["Timings"]]

# Get the lap numbers
lap_numbers <- laps[[1]][["number"]]
lap_numbers <- as.numeric(lap_numbers)

# Convert into a single data frame
times_positions <- do.call("rbind", times_positions)

# Load the stringr package
library("stringr", lib.loc="~/anaconda3/lib/R/library")

# Write a function which calculates the time column as an number
time_numeric_seconds <- function(x){
  
  # Get the first character and convert to a time in seconds
  minute <- as.numeric(str_sub(x, 1, 1))
  
  # Get the seconds and milliseconds
  seconds <- as.numeric(str_sub(x, 3))
  
  # Find the time
  time <- 60*minute + seconds
}

# Convert the time column into seconds in numeric form
time_numeric <- sapply(times_positions$time, time_numeric_seconds)

# Bind to the dataframe and drop the original column
times_positions <- times_positions[,-3]
times_positions <- cbind(times_positions, time = time_numeric)

# Convert the position column to numeric
times_positions$position <- as.numeric(times_positions$position)

# Load the dplyr and tibble package
library("dplyr", lib.loc="~/anaconda3/lib/R/library")
library("tibble", lib.loc="~/anaconda3/lib/R/library")

# Convert data.frame to tibble
times_positions <- as_tibble(times_positions)

# Add the lap numbers using dplyr
times_positions_laps <- times_positions %>%
 group_by(driverId) %>%
 mutate(lap = row_number())

# Filter by Daniel Ricciardo
ricciardo <- times_positions_laps %>%
 filter(driverId == "ricciardo")
  
# Find some lap statistics for all the drivers using dplyr
lap_statistics <- times_positions_laps %>%
  group_by(driverId) %>%
  summarise(medianLapTime = median(time), maxLapTime = max(time), minLapTime = min(time))

# Load ggplot2
library("ggplot2", lib.loc="~/anaconda3/lib/R/library")

# Try plotting for all the drivers by position
ggplot(times_positions_laps, aes(x = lap, y = position, group=driverId, colour=driverId)) + geom_line() + scale_y_reverse() + expand_limits(y=c(1,20))

# Plot line graph for ricciardo lap times
ggplot(ricciardo, aes(x = lap, y = time)) + geom_line()

# Box plot for the drivers
ggplot(times_positions_laps, aes(x = driverId, y = time)) + geom_boxplot() + coord_flip()


# Create a function to plot a bar chart with driverId on the y and variable on x
plot_lap_statistics <- function(lap_statistics_df, colName){
  ggplot(lap_statistics_df, aes(x = reorder(driverId, -lap_statistics_df[[colName]]), y = lap_statistics_df[[colName]])) + 
    geom_col() + coord_flip() + labs(x = "driver", y = "time", title = colName)
}

# Plot the max, median and min lap times for each driver
plot_lap_statistics(lap_statistics, "maxLapTime")
plot_lap_statistics(lap_statistics, "medianLapTime")
plot_lap_statistics(lap_statistics, "minLapTime")