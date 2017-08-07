rm(list=ls())
require(data.table)

setwd("/Users/vdpappu/Documents/Kaggle/In-Progress/AIR_BNB")

df_sessions <- fread("./input/df_sessions.csv",data.table = FALSE)
df_actionDetails <- fread("./input/df_actionDetails.csv",data.table = FALSE)
df_actionDetails$V1 <- NULL
names(df_actionDetails)[2] <- "unknown_actionDetails"

df_sessions <- merge(df_sessions,df_actionDetails,by="user_id")
write.csv(df_sessions,"./input/df_sessions_new.csv",row.names = FALSE)
