library(tidyverse) #dplyr, tidyr, ggplot2, readr
library(here)

rm(list = ls()) #Clean out workspace

##### FILE SETUP FROM LAST WEEK ------------
ds <- read_csv(here("data_example_3","training_data.csv"), n_max = 2000)

#store a vector of category numbers
class_num <- c(1,2,3,4,5,6,7,8,9,10) # class_num <- 1:10
#store a vector of category labels as strings
class_lab <- c("upright", "walking", "prone", "crawling","held_walk",
               "held_stat","sit_surf","sit_cg","sit_rest","supine")
ds$class <- factor(ds$class, levels = class_num, labels = class_lab)
ds$class_rel <- factor(ds$class_rel, levels = class_num, labels = class_lab)
ds$class <- fct_drop(ds$class)
ds$class_rel <- fct_drop(ds$class_rel)

ds$class <- fct_collapse(ds$class, 
                         prone = "prone", supine = "supine",         
                         held = c("held_walk","held_stat"),          
                         sit = c("sit_surf", "sit_cg", "sit_rest"))
ds$class_rel <- fct_collapse(ds$class_rel, 
                         prone = "prone", supine = "supine",
                         held = c("held_walk","held_stat"),
                         sit = c("sit_surf", "sit_cg", "sit_rest"))

#Make a factor (1st half, time is < median, 2nd half, time is > median)
temp_var <-  ds$time > median(ds$time)
temp_var <- factor(temp_var, levels = c(FALSE, TRUE), labels = c("1st", "2nd"))
ds <- ds %>% mutate(half = temp_var, .before = "class") 

##### MAP ANALYSES --------- 

ds %>% group_split(class) -> ds_class
map(ds_class, ~ lm(x_sum ~ y_sum, data = .x))

ds %>% group_by(class) %>% group_map(~ lm(x_sum ~ y_sum, data = .x))
   