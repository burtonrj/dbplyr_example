library(tidyverse)
library(lubridate)
library(ggplot2)
library(dbplyr)
library(RSQLite)
library(DBI)
# Open a connection to the database. dbname should refer to where 
# the database file is located on your local machine
con <- dbConnect(SQLite(), dbname="/home/ross/ProjectBevan/ProjectBevan.db")

# List table names  
# More useful functions in DBI found here: https://db.rstudio.com/databases/sqlite/
dbListTables(con)
# For 99% of the tasks we do from now on, we can just use dplyr!

# Create a reference to a table using the tbl function (passing the connection as the
# first argument and the table name as the second)
events <- tbl(con, "Events")
patients <- tbl(con, "Patients") %>% as_tibble()
# We can then treat this reference as if it was a tibble
head(events, 5)
head(patients, 5)

# If we wanted to fetch the admissions from march onwards, we would use a command
# like this, were we use the general apparatus of the tidyverse to manipulate the data
admission_march_onwards <- events %>% 
  filter(event_type=="ADMISSION") %>%
  as_tibble() %>% # NOTE: before mutating a column, we must convert the reference into a 'acutal tibble'
  mutate(event_date = dmy(event_date)) %>%
  filter(event_date >= dmy("01-03-2020")) %>%
  arrange(event_date)

# If we want to use R commands within our searches, we must tell dbplyr that we 
# want it to be interpreted as R using the '!!' command
patients_admitted_march_onwards <- patients %>% 
  filter(patient_id %in% !! admission_march_onwards$patient_id
         & covid_status == "P")

# Here we filter out all patients that are covid pos and filter by date
covid_pos <- patients %>% 
              filter(covid_status == "P") %>%
              as_tibble() %>%
              mutate(event_date = dmy(covid_date_first_positive))

head(admission_march_onwards, 5)
# Always disconnect when you're finished!
dbDisconnect(con)
