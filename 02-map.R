#Load packages
library(tidyverse)
library(here)

rm(list = ls()) #Clean out workspace

file_names <- list.files("data_example_1_2", pattern = ".txt",full.names = T)

#map applies a function to each element of a list or vector
map(file_names, toupper)

#map let's you define functions on the fly using ~, where '.x' serves as the item from the list/vector
map(file_names, ~toupper(.x))

#Use map to get the full file path of each "short file" name
file_names_short <- list.files("data_example_1_2", pattern = ".txt",full.names = F)
map(file_names, ~here("data_example_1_2",.x))

#This isn't quite what we want. Map returns a list by default
ds <- map(file_names, ~ read_tsv(.x,  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct")))
ds <- bind_rows(ds) #This fixes it, but there's an easier way

#Map dfr is a variant of map that returns a dataframe
ds <- map_dfr(file_names, ~ read_tsv(.x,  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct")) %>% mutate(file = .x))

#Can we make this a bit cleaner?

#Make a custom function that reads the data and adds the filename to it
read_our_data <- function(fname) {
  data <- read_tsv(fname,  skip = 8, col_names = c("trial", "speed_actual", "speed_faster", "correct"))
  data <- data %>% mutate(file = fname)
  data <- data %>% separate(file, into = c(NA, NA, NA, NA, "id","block", NA))
  data <- data %>% mutate(file = paste(id,block,sep = "_"))
}

temp <- read_our_data(file_names[1])

#Map file_names to our new function
ds <- map_dfr(file_names, ~ read_our_data(.x))


#Use the short file names to write each subset of data to a new file
short_files <- ds %>% distinct(file) %>% pull
map(short_files, ~ write_csv(filter(ds, file == .x), paste0("data_cleaned/",.x,".csv")))

#break these parts down
map(short_files, ~ filter(ds, file == .x)) #data filtered by short_file name
map(short_files, ~ paste0("data_cleaned/",.x,".csv")) #file name built by short_file name
