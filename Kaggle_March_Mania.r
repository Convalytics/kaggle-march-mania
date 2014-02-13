######################################################
#  Kaggle March Mania Competition
#  Jason Green
#  February, 12th 2014
#  https://github.com/Convalytics/kaggle-march-mania
######################################################

#install.packages('plyr')
library(plyr)

# Set Working Directory
#setwd("C:\\Users\\jgreen\\Documents\\GitHub\\kaggle-march-mania")
setwd("~/GitHub/kaggle-march-mania")

# Import Data
regular_season_results <- read.csv("~/GitHub/kaggle-march-mania/regular_season_results.csv")
tourney_results <- read.csv("~/GitHub/kaggle-march-mania/tourney_results.csv")
sample_submission <- read.csv("~/GitHub/kaggle-march-mania/sample_submission.csv")

submission <- sample_submission
submission$lowTeam <- substr(submission$id,3,5)
submission$highTeam <- substr(submission$id,7,9)


# Summaries
summary(regular_season_results)
head(regular_season_results, n=5)


table(regular_season_results$wteam, regular_season_results$season)
count(regular_season_results$wteam,regular_season_results$season)

# Get total win % for each team


# Get tourney win count for each team

# How many times did low team beat high team?

# Does high or low team have better tourney performance?

# Who performs better when away?

# Account for likelihood of an upset.



