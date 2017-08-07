rm(list=ls())
library(readr)
library(data.table)
library(dplyr)
library(reshape)
library(reshape2)

setwd("/Users/vdpappu/Documents/Kaggle/In-Progress/AIR_BNB")

df_sessions <- read_csv("./input/sessions.csv")

user_sess <- subset(df_sessions,select=c("user_id","secs_elapsed"))
df_sessionTime <- user_sess %>%
                  group_by(user_id) %>%
                  summarise(total_time = sum(secs_elapsed,na.rm=TRUE))
rm(user_sess)

temp_action_detail <- subset(df_sessions,select=c("user_id","action_detail"))
temp_action_detail <- temp_action_detail[complete.cases(temp_action_detail),]
temp_action_detail$count <- 1

df_actionDetails <- cast(temp_action_detail,user_id~action_detail)
#write.csv(df_actionDetails,"./input/df_actionDetails.csv")

temp_actionType <- subset(df_sessions,select=c("user_id","action_type"))
temp_actionType <- temp_actionType[complete.cases(temp_actionType),]
temp_actionType$count <- 1

df_actionType <- cast(temp_actionType,user_id~action_type)
names(df_actionType)[2] <- 'unknown_action'
rm(temp_actionType)

for(i in 1:ncol(df_actionType))
{
  print(paste(names(df_actionType)[i],length(unique(df_actionType[,i])),sep=" : "))
}

df_actionType$booking_response <- NULL

temp_device_type <- subset(df_sessions,select=c(user_id,device_type))
temp_device_type <- temp_device_type[complete.cases(temp_device_type),]
temp_device_type$count <- 1

df_deviceType <- cast(temp_device_type,user_id~device_type)
names(df_deviceType)[2] <- 'unknown_device'
myvars <- names(df_deviceType) %in% c('Blackberry','Opera Phone','iPodtouch','Windows Phone')
df_deviceType <- df_deviceType[!myvars]

df_sessions_md <- merge(df_actionType,df_deviceType,by="user_id")
df_sessions_md1 <- merge(df_sessions_md,df_actionDetails,by="user_id")
#write.csv(df_sessions_md,"df_sessions_new.csv",row.names=FALSE)
