rm(list=ls())
library(xgboost)
library(readr)
library(stringr)
library(caret)
library(car)
library(data.table)
library(tidyr)
library(dplyr)

setwd("/Users/vdpappu/Documents/Kaggle/In-Progress/AIR_BNB")
set.seed(1)

# load data
df_train = fread("./input/train_users.csv",data.table = FALSE,integer64 = "character")
df_test = fread("./input/test_users.csv",data.table = FALSE,integer64 = "character")
df_age_gender_bkts <- fread("./input/age_gender_bkts.csv",data.table=FALSE)
df_countries <- fread("./input/countries.csv",data.table=FALSE)
df_userActions <- fread("./input/user-action-time.csv",data.table=FALSE)
names(df_userActions) <- df_userActions[1,]
df_userActions[,1] <- NULL
df_userActions <- df_userActions[-c(1),]
df_sessions <- fread("./input/sessions.csv",data.table=FALSE)
# df_sessions$action <- lapply(df_sessions$action,
#                              function(x) gsub())
  
#Analyze sessions data to see for which users sessions data was captured
df_sessionTimes <- data.frame(table(df_train$country_destination))
#df_sessionTimes <- df_sessionTimes[order(df_sessionTimes$Freq,decreasing=TRUE),]
names(df_sessionTimes) <- c("Country","All_Data")

users_with_sessions <- unique(df_userActions$user_id)
df_train_withSessions <- subset(df_train,df_train$id %in% users_with_sessions)
temp_sess <- data.frame(table(df_train_withSessions$country_destination))
names(temp_sess) <- c("Country","Only_Session")

df_sessionTimes <- merge(df_sessionTimes,temp_sess,by="Country")
df_sessionTimes <- df_sessionTimes[order(df_sessionTimes$All_Data,decreasing=TRUE),]
rm(temp_sess)

#what state transition are frequent in users who booked a destination
df_train_withSessions$isBookingMade <- df_train_withSessions$country_destination != 'NDF'
table(df_train_withSessions$isBookingMade)

#actual sessions data for users who made reservation
users_reservations <- unique(subset(df_train_withSessions,
                                    df_train_withSessions$isBookingMade == TRUE))$id

df_sessions_booking <- subset(df_sessions,df_sessions$user_id %in% users_reservations)

merged_actions = df_sessions %>%
                 group_by(user_id) %>%
                 summarise(n = n(), agg_actions = paste(action,collapse = " "))

merged_actions <- merged_actions[-c(1),]
merged_actions_train <- subset(merged_actions,
                               merged_actions$user_id %in% unique(df_train_withSessions$id))

temp_bookingtag <- subset(df_train_withSessions,select=c('id','isBookingMade'))
names(temp_bookingtag)[1] <- "user_id"
merged_actions_train <- merge(merged_actions_train,temp_bookingtag,by='user_id')
rm(temp_bookingtag)

#plot n vs is booking made for both True and False
