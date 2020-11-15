library(dplyr)
library(plyr)
library(purrr)
library(janitor)
library(knitr)
library(readxl)
library(esquisse)

#setwd("~/coding/dyplr_fundamentals")

#Load one at a time

salary2017 <- read_excel("data/salarydata/2017.xlsx")
salary2018 <- read_excel("data/salarydata/2018.xlsx")
salary2019 <- read_excel("data/salarydata/2019.xlsx")

names <- c("organization", "unit", "job", "first_name","last_name","work_percentage","official_salary", "special_salary", "other_salary", "total_salary","period","change_in_position")
colnames(salary2017) <- names
colnames(salary2018) <- names
colnames(salary2019) <- names


#Load as a list
file.list <- list.files(path="./data/salarydata", pattern='*.xlsx')
df.list <- sapply(file.list, read_excel, simplify=FALSE)


#This is just to show what the less nice col look like
compare_df_cols(df.list)

#Clean up the column names
df.list <- lapply(df.list, clean_names)

#Double check that all the columns are the same
compare_df_cols(df.list)

#Bind together data
salary_combined <- bind_rows(df.list, .id = "id")

#Let's explore the data a bit
head(tabyl(salary2017$job) %>% arrange(desc(n)), 10) %>% kable()
head(tabyl(salary2017$organization) %>% arrange(desc(n)), 10) %>% kable()
salary2017 %>% count(organization, sort = T)
test <- salary2017 %>% group_by(unit, organization) %>% summarise(n=n(), Mean = mean(total_salary, na.rm=TRUE)) %>% arrange(desc(n))

#Let's write a function to help us analyze future data
salary_analysis <- function(.df, .group_vars, .summary_vars) {
 summary_vars <- enquo(.summary_vars)
 andmed <-  .df %>% group_by_at(.group_vars) %>% summarise(n=n(), Average = mean(!!summary_vars, na.rm=T)) %>% arrange(desc(n))
 return(andmed)
}

andmed <- salary_analysis(salary2017, c("organization","job"), total_salary)


## Experiment with joins and anti joins
salary_comb <- salary2017 %>% select(c("organization","unit", "first_name", "last_name", "total_salary"))
joined <- left_join(salary_comb,salary2018[, c("organization", "first_name", "last_name", "total_salary")], by = c("organization" = "organization" , "first_name" = "first_name", "last_name" = "last_name"))
joined <- left_join(joined,salary2019[, c("organization", "first_name", "last_name", "total_salary")], by = c("organization" = "organization" , "first_name" = "first_name", "last_name" = "last_name"))

salary_comb2 <- salary2017 %>% select(c("organization","unit", "first_name", "last_name", "total_salary"))
joined2 <- inner_join(salary_comb2,salary2018[, c("organization", "first_name", "last_name", "total_salary")], by = c("organization" = "organization" , "first_name" = "first_name", "last_name" = "last_name"))
joined2 <- inner_join(joined2,salary2019[, c("organization", "first_name", "last_name", "total_salary")], by = c("organization" = "organization" , "first_name" = "first_name", "last_name" = "last_name"))


antijoined <- anti_join(salary2017,salary2018, by = c("organization" = "organization" , "first_name" = "first_name", "last_name" = "last_name"))
antijoined2 <- anti_join(joined,joined2, by = c("organization" = "organization" , "first_name" = "first_name", "last_name" = "last_name"))



## Quick grepl examples

grep("Kaja", salary2017$first_name, value = T)
name_is_kaja <- salary2017 %>% filter(grepl("Kaja", first_name))
name_is_not_kaja <- salary2017 %>% filter(!grepl("Kaja", first_name))

salary2017 %>% 
  group_by(.dots=grep(pattern="organization", x = colnames(.),
                      value = T, ignore.case = T
  )) %>% tally(sort = T) 


#Uncomment below to experiment with easier data visualization
#esquisser()

