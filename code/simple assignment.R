library(dplyr)
library(data.table)
#Data from: https://www.kaggle.com/daliaresearch/basic-income-survey-european-dataset
## Read the codebook to understand the columns.

income <- fread("./code/basic_income_dataset_dalia.csv", enc = "UTF-8")



## Create two new datasets, one for those with children, and one for those with no children


## In the dataset for those with children, select only those who are from a rural environment


## Change the column names into something nicer


## Create a new column those who would vote for it, those who would vote against, and those who would not vote


## Create a summary table for each group based on the previously created column


## Write a function that, given any list of variables, will filter and summarize the dataset and return an ordered table.