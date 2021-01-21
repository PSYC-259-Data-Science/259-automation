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

#Correlations of one variable to a list of variable names
vars <- c("x_sum","y_sum","z_sum", "diff_xy","diff_xz", "diff_yz")

#We want to know how each variable is correlated with a reference variable "a_sum"
cor(ds$a_sum, ds$x_sum)
cor(ds$a_sum, ds$y_sum)
cor(ds$a_sum, ds$z_sum)


res <- map(vars, ~ cor(ds$a_sum, select(ds, .x)))
res$x_sum

res <- map(vars, ~ cor(ds$a_sum, select(ds, .x))) %>% set_names(vars)
res$x_sum


#Linear models on splits of a data frame

ds_class <- split(ds, ds$class)
map(ds_class, ~ lm(x_sum ~ y_sum, data = .x))

#Create a new factor that combines existing ones
ds$class_half <- fct_cross(ds$class, ds$half)
ds_class <- split(ds, ds$class_half)
map(ds_class, ~ lm(x_sum ~ y_sum, data = .x))
