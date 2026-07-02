# Module 3 Project
library(lubridate)
library(ggplot2)
library(dplyr)
library(queueing)
library(tidyverse)
library(DescTools)


datp  <- read.csv("C:/Users/steve/Documents/R Projects/dat_P_sub_c (2).csv")
datf <- read.csv("C:/Users/steve/Documents/R Projects/dat_F_sub.csv")
basa <- read.csv("C:/Users/steve/Documents/R Projects/BASA_AUC_2028_912.csv")
years <- read.csv("C:/Users/steve/Documents/R Projects/years20262030.csv")


summary(datp)

summary(datf)


# Datf only has the AUC air field

unique(datf$Airfield)

# Step 1: Coordinate the datasets such that they have the same columns

# Basa: add flag columns, make sure date formats are consistent
# Datp: convert Departure Time into into proper format
# The date format that I want is 

# Basa_Clean

basa_clean <- basa
basa_clean$Act_Departure <- as.POSIXct(basa_clean$Act_Departure, format = "%Y-%m-%d %H:%M:%S")
basa_clean$Sch_Departure <- as.POSIXct(basa_clean$Sch_Departure, format = "%Y-%m-%d %H:%M:%S")
basa_clean$S2 <- as.POSIXct(basa_clean$S2, format = "%Y-%m-%d %H:%M:%S")
basa_clean$Departure_Time <- as.POSIXct(basa_clean$Departure_Time, origin = basa_clean$Departure_Date, tz = "UTC")
basa_clean$Departure_Time <- format(basa_clean$Departure_Time, "%H:%M:%S")
basa_clean$Period_of_Week <- ifelse(basa_clean$Period_of_Week == "1 - WEEKDAY", "2 - WEEKEND", "1 - WEEKDAY")

basa_clean <- basa_clean %>% mutate(WT_flag = ifelse(is.na(Wait_Time), 1, 0))
basa_clean <- basa_clean %>% mutate(S2_Sch_Flag = ifelse(S2 <= Sch_Departure, 0, 1))
basa_clean <- basa_clean %>% mutate(S2_Act_Flag = ifelse(S2 <= Act_Departure, 0, 1))
basa_clean <- basa_clean %>% mutate(Sch_Act_Flag = ifelse(Sch_Departure <= Act_Departure, 0, 1))
basa_clean <- basa_clean %>% mutate(Delay_in_Seconds = as.integer(Act_Departure - Sch_Departure))

# Years_Clean

years_clean <- years

years_clean$Act_Departure <- as.POSIXct(years_clean$Act_Departure, format = "%Y-%m-%d %H:%M")
years_clean$Sch_Departure <- as.POSIXct(years_clean$Sch_Departure, format = "%Y-%m-%d %H:%M")
years_clean$S2 <- as.POSIXct(years_clean$S2, format = "%Y-%m-%d %H:%M")
years_clean$Departure_Time <- format(years_clean$Act_Departure, "%H:%M:%S")
years_clean$Period_of_Week <- ifelse(years_clean$Period_of_Week == "1 - WEEKDAY", "2 - WEEKEND", "1 - WEEKDAY")


years_clean <- years_clean %>% mutate(WT_flag = ifelse(is.na(Wait_Time), 1, 0))
years_clean <- years_clean %>% mutate(S2_Sch_Flag = ifelse(S2 <= Sch_Departure, 0, 1))
years_clean <- years_clean %>% mutate(S2_Act_Flag = ifelse(S2 <= Act_Departure, 0, 1))
years_clean <- years_clean %>% mutate(Sch_Act_Flag = ifelse(Sch_Departure <= Act_Departure, 0, 1))
years_clean <- years_clean %>% mutate(Delay_in_Seconds = as.integer(Act_Departure - Sch_Departure))


# Datp

datp_clean <- datp

datp_clean$Act_Departure <- as.POSIXct(datp_clean$Act_Departure, format = "%Y-%m-%d %H:%M")
datp_clean$Sch_Departure <- as.POSIXct(datp_clean$Sch_Departure, format = "%Y-%m-%d %H:%M")
datp_clean$S2 <- as.POSIXct(datp_clean$S2, format = "%Y-%m-%d %H:%M")

datp_clean <- datp_clean %>% mutate(Departure_Time = format(datp_clean$Act_Departure, "%H:%M:%S"))

# show_flags <- function(df, yr){
#   df_new <- df
#   if(yr == 1){
#     df_new$Act_Departure <- as.POSIXct(df_new$Act_Departure, format = "%Y-%m-%d %H:%M")
#     df_new$Sch_Departure <- as.POSIXct(df_new$Sch_Departure, format = "%Y-%m-%d %H:%M")
#     df_new$S2 <- as.POSIXct(df_new$S2, format = "%Y-%m-%d %H:%M")
#     df_new$Departure_Time <- as.POSIXct(df_new$Departure_Time, "%H:%M:%S", tz = "UTC")
#     
#   }
#   else{
#     df_new$Act_Departure <- as.POSIXct(df_new$Act_Departure, format = "%Y-%m-%d %H:%M:%S")
#     df_new$Sch_Departure <- as.POSIXct(df_new$Sch_Departure, format = "%Y-%m-%d %H:%M:%S")
#     df_new$S2 <- as.POSIXct(df_new$S2, format = "%Y-%m-%d %H:%M:%S")
#     
#   }
#   if(yr == 0){
#     df_new$Departure_Time <- as.POSIXct(df_new$Departure_Time, origin = "1970-01-01", tz = "UTC")
#   }
#   
#   # Convert to Date Format
#   
#   if(yr != 2){
#     df_new <- df_new %>% mutate(WT_Flag = ifelse(is.na(Wait_Time), 1, 0))
#     df_new <- df_new %>% mutate(S2_Sch_Flag = ifelse(S2 <= Sch_Departure, 0, 1))
#     df_new <- df_new %>% mutate(S2_Act_Flag = ifelse(S2 <= Act_Departure, 0, 1))
#     df_new <- df_new %>% mutate(Sch_Act_Flag = ifelse(Sch_Departure <= Act_Departure, 0, 1))
#     df_new <- df_new %>% mutate(Delay_in_Seconds = as.integer(Act_Departure - Sch_Departure))
#   }
#   return(df_new)
# }


# table(basa$Season)
# 
# hist(datf$max)
# 
# weekend <- datf %>% group_by(Period_of_Week, Time_of_Day, Season) %>% 
#   summarise(mean_wait = mean(mean, na.rm = TRUE))
# 
# 
# season <- datf %>% group_by(Time_of_Day) %>% 
#   summarise(mean_wait = mean(mean, na.rm = TRUE))


# Basa Cleaning


# basa_clean <- show_flags(basa, 0)
# datp_clean <- show_flags(datp, 2)
# years_clean <- show_flags(years, 1)

# Merge Datasets
merged_df <- bind_rows(basa_clean, datp_clean, years_clean)

merged_clean <- merged_df %>% distinct(Pass_ID, Departure_Date, .keep_all = TRUE)

# Merge with the flight data
merge_df <- merge(merged_df, datf, by = "Flight_ID")


auc_clean <- merged_df  %>% filter(!is.na(Wait_Time)) %>% filter(S2_Sch_Flag == 0) %>% filter(Sch_Act_Flag == 0) %>%
  filter(Departure_Date >= as.Date("2028-09-01")) %>% mutate(S1 = S2 - Wait_Time*60) %>% filter(Airfield == "AUC")

auc_sub <- auc_clean %>% select(c("S1", "S2", "Wait_Time", "C_Start", "C0", "C_avg", "Departure_Date", "Period_of_Week",
                                  "Departure_Time", "Day_of_Week"))
auc_sub <- auc_sub[complete.cases(auc_sub),]


saf_clean <- merged_df  %>% filter(!is.na(Wait_Time)) %>% filter(S2_Sch_Flag == 0) %>% filter(Sch_Act_Flag == 0) %>%
  filter(Departure_Date >= as.Date("2028-09-01")) %>% mutate(S1 = S2 - Wait_Time*60) %>% filter(Airfield == "SAF")

saf_sub <- saf_clean %>% select(c("S1", "S2", "Wait_Time", "C_Start", "C0", "C_avg", "Departure_Date", "Period_of_Week",
                                  "Departure_Time", "Day_of_Week"))
saf_sub <- saf_sub[complete.cases(saf_sub),]


calc_service_rate <- function(lambda, wait, c){
  if(c == 1){
    return(1/wait + lambda)
  }
  # try out u values
  
  vals <- seq(0.1,2.5, by = 1/1000)
  diff <- c()
  for(i in vals){
    mu <- i
    rho <- lambda/(c*mu)
    
    if (rho >= 1) {
      diff <- append(diff, Inf)
    }
    else{
      
      n <- 0:(c - 1)
      sum_part <- sum((1 / factorial(n)) * (lambda / mu)^n)
      tail_part <- (1 / factorial(c)) * (lambda / mu)^c * ((c * mu) / ((c * mu) - lambda))
      P0 <- 1 / (sum_part + tail_part)
      
      Pq <- (1 / factorial(c)) * (lambda / mu)^c * ((c * mu) / ((c * mu) - lambda)) * P0
      
      Wq <- Pq / ((c * mu) - lambda)
      W <- Wq + (1 / mu)
      
      
      diff <- append(diff, abs(W - wait))
    }
  }
  return(vals[which.min(diff)])
}


arrival_rate_on_time <- function(df, time, period){
  df_new <- df %>% mutate(Hour = as.integer(substr(Departure_Time, start = 1, stop = 2)))
  df_new <- df_new %>% filter(between(Hour, time, time+3))
  df_new <- df_new %>% filter(Period_of_Week == period)
  time_duration <- length(unique(df_new$Departure_Date))*(4*60)
  
  
  return(list(Arrival_Rate = nrow(df_new)/time_duration,
              Wait_Time = mean(df_new$Wait_Time),
              Average_Servers = mean(df_new$C_avg),
              Mode_Servers = Mode(df_new$C0)[1],
              Service_Rate = calc_service_rate(nrow(df_new)/time_duration, mean(df_new$Wait_Time), 
                                               Mode(df_new$C0)[1])))
}

arrival_rate_on_time(auc_sub, 12, "1 - WEEKDAY")

#data.frame(Time_of_day = c("0:00 - 3:59", "4:00-7:59", "8:00-11:59", "12:00-15:59", "16:00-19:59", "20:00-23:59"),
#          Arrival_rate = c())

saf_arrival <- c()
saf_departure <- c()

arrival <- c()
departure <- c()
servers <- c()

for(i in c(2,3,4,5)){
  rates <- arrival_rate_on_time(auc_sub, i*4, "2 - WEEKEND")
  arrival <- append(arrival, round(rates$Arrival_Rate,3))
  departure <- append(departure, round(rates$Departure_Rate, 3))
  servers <- append(servers, rates$Mode_Servers)
}

df_result <- data.frame(Arrival_Rates = arrival,
                        Departure_Rates = departure,
                        Servers = servers)


calc_service_rate <- function(lambda, wait, c){
  if(c == 1){
    return(1/wait + lambda)
  }
  # try out u values
  
  vals <- seq(0.1,2.5, by = 1/1000)
  
  diff <- c()
  
  for(i in vals){
    mu <- i
    rho <- lambda/(c*mu)
    
    if (rho >= 1) {
      diff <- append(diff, Inf)
    }
    else{
      
      n <- 0:(c - 1)
      sum_part <- sum((1 / factorial(n)) * (lambda / mu)^n)
      tail_part <- (1 / factorial(c)) * (lambda / mu)^c * ((c * mu) / ((c * mu) - lambda))
      P0 <- 1 / (sum_part + tail_part)
      
      Pq <- (1 / factorial(c)) * (lambda / mu)^c * ((c * mu) / ((c * mu) - lambda)) * P0
      
      Wq <- Pq / ((c * mu) - lambda)
      W <- Wq + (1 / mu)
      
      
      diff <- append(diff, abs(W - wait))
    }
  }
  return(vals[which.min(diff)])
}

calc_service_rate(2.044792, 6.091244, 1)




df_auc <- data.frame(Departure_Date = unique(auc_sub$Departure_Date),
                     Arrival_Rate = add_arrival_rate(auc_sub))

df_saf <- data.frame(Departure_Date = unique(saf_sub$Departure_Date),
                     Arrival_Rate = add_arrival_rate(saf_sub))

time_duration_auc <- as.numeric(difftime(max(auc_sub$S2), min(auc_sub$S2), units = "mins"))
time_duration_saf <- as.numeric(difftime(max(saf_sub$S2), min(saf_sub$S2), units = "mins"))




lambda_auc <- nrow(auc_sub)/time_duration_auc
lambda_saf <- nrow(saf_sub)/time_duration_saf

mu_auc <- 1 / mean(auc_sub$Wait_Time)
mu_saf <- 1 / mean(saf_sub$Wait_Time)


model_auc <- NewInput.MMC(lambda = lambda_auc, mu = mu_auc, c = 6,  n = 0)
model_saf <- NewInput.MMC(lambda = lambda_saf, mu = mu_saf, c = 3, n = 0)

out_saf <- QueueingModel(model_saf)
out_auc <- QueueingModel(model_auc)
