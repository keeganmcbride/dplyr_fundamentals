library(dplyr)
library(data.table)
#Data from: https://www.kaggle.com/daliaresearch/basic-income-survey-european-dataset
## Read the codebook to understand the columns.

income <- fread("./code/basic_income_dataset_dalia.csv", enc = "UTF-8")



## Create two new datasets, one for those with children, and one for those with no children

children <- income %>% filter (dem_has_children == "yes") 
no_children <- income %>% filter(dem_has_children == "no")

#OR

income_split <- split(income, income$dem_has_children)
children <- income_split$no
no_children <- income_split$yes

## In the dataset for those with children, select only those who are from a rural environment

children <- children %>% filter(rural == "rural")


## Remove the "weight" variable

children <- children %>% select(-c(weight))

## Change the column names for fun
names(children) <- sub("^(.*?)_basic", "", names(children))


## Create a new column those who would vote for it, those who would vote against, and those who would not vote
children <- children %>% mutate(voting = case_when(
  income_vote == "I would not vote" ~ "no vote",
  income_vote == "I would vote against it" | income_vote ==  "I would probably vote against it" ~ "vote against",
  income_vote == "I would vote for it" | income_vote == "I would probably vote for it" ~ "vote for"
))


## Create a summary table for each group based on the previously created column


children %>% group_by(income_vote, country_code) %>% dplyr::summarise(n()) 



## Write a function that, given any list of variables, will filter and summarize the dataset and return an ordered table.

analysis <- function(.df, .group_vars, .summary_vars) {
  summary_vars <- enquo(.summary_vars)
  andmed <-  .df %>% group_by_at(.group_vars) %>% dplyr::summarise(n=n(), Average = mean(!!summary_vars, na.rm=T)) %>% arrange(desc(n))
  return(andmed)
}

test <- analysis(income, c("gender","age_group","country_code"), n())
