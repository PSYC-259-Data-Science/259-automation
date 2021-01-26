#Load packages
library(tidyverse)

rm(list = ls()) #Clean out workspace

#Get all files in the data_example 1 directory
file_names <- list.files("data_example_1_2", pattern = ".txt",full.names = T)

#file_names is a character vector, with elements that can be accessed with [1], [2], etc.
file_names[1]

#We can read in data for each element, but it would be tedious
ds1 <- read_tsv(file_names[1],  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct"))
ds2 <- read_tsv(file_names[2],  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct"))
ds3 <- read_tsv(file_names[3],  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct"))
#...and so on

#Any time we are iterating over a vector, a for loop can automate things
#for each (*thing* in *list of things*) do 
    #{actions in a loop}

for (file in file_names) {
  print(file)
}

#Now let's do something with each file name

#First, let's set up a place to put the data as it comes in
#Create a tibble with the right structure, then use filter(FALSE) to delete all the data
ds <- read_tsv(file_names[1],  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct"))
ds$file <- "file" #Create a place to put the filename in our template
ds <- ds %>% filter(FALSE)

#Loop through file names
for (file in file_names) {
  #Read the new data into a temporary dataset
  temp_ds <- read_tsv(file,  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct"))
  #Add the file name to the dataset
  temp_ds$file <- file 
  #Bind (append) the new data to the dataset
  ds <- bind_rows(ds, temp_ds)
}
