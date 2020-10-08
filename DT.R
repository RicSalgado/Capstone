library(dplyr)
library(explore)

mtcars %>% 
  explain_tree(target = hp, minsplit=15)
