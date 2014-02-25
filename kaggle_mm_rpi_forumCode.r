# Sample from forum to take on RPI Benchmark

######################################################
#  Kaggle March Mania Competition
#  Jason Green
#  February, 12th 2014
#  https://github.com/Convalytics/kaggle-march-mania
#  Last Updated: 2/23/2014
######################################################

#install.packages('plyr')
library(plyr)

# Set Working Directory
#setwd("C:\\Users\\jgreen\\Documents\\GitHub\\kaggle-march-mania")
setwd("~/GitHub/kaggle-march-mania")

# Import Data
regular_season_results <- read.csv("~/GitHub/kaggle-march-mania/regular_season_results.csv")
tourney_results <- read.csv("~/GitHub/kaggle-march-mania/tourney_results.csv")
submission <- read.csv("~/GitHub/kaggle-march-mania/sample_submission.csv")
seeds <- read.csv("~/GitHub/kaggle-march-mania/tourney_seeds.csv")
slots <- read.csv("~/GitHub/kaggle-march-mania/tourney_slots.csv")


seeds$seed<-substr(seeds$seed,2,3)
submission$season<-substr(submission[,1],1,1)
submission$team<-as.numeric(substr(submission[,1],3,5))
submission<-merge(submission,seeds)

submission$team<-as.numeric(substr(submission[,3],7,9))
names(seeds)<-c("season","seed2","team")
submission<-merge(submission,seeds)
submission$pred<-.5+.03*(as.numeric(submission$seed2)-as.numeric(submission$seed))

submission<-submission[,3:4]
write.csv(submission,"convalytics_prediction_4.csv", row.names=F)

