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
sample_submission <- read.csv("~/GitHub/kaggle-march-mania/sample_submission.csv")
seeds <- read.csv("~/GitHub/kaggle-march-mania/tourney_seeds.csv")
slots <- read.csv("~/GitHub/kaggle-march-mania/tourney_slots.csv")


# Summarize the imported data
head(regular_season_results, n=10)
head(tourney_results, n=10)
head(sample_submission, n=10)
head(seeds, n=10)
head(slots, n=10)


# Start with the sample_submission file and append additional data to make our final prediction
submission <- sample_submission                           # Rename sample_submission to submission for shortness
submission$lowTeam <- substr(submission$id,3,5)           # Extract the teams from the id field
submission$highTeam <- substr(submission$id,7,9)
submission$season <- substr(submission$id,1,1)            # Extract the season from the id field

#Add seed numbers  (merge the seeds table with the submission file)
submissionWithSeeds <- merge(x = submission, y = seeds, by.x=c("lowTeam","season"), by.y=c("team","season"))
submissionWithSeeds <- rename(submissionWithSeeds, c("seed" = "lowTeamSeed"))
submissionWithSeeds <- merge(x = submissionWithSeeds, y = seeds, by.x=c("highTeam","season"), by.y=c("team","season"))
submissionWithSeeds <- rename(submissionWithSeeds, c("seed" = "highTeamSeed"))

# Remove all letters from the seed number. We're just looking for a number to rank teams. # gsub is a regex substitute function.
submissionWithSeeds$lowSeed <- gsub("[^0-9]","",submissionWithSeeds$lowTeamSeed)
submissionWithSeeds$highSeed <- gsub("[^0-9]","",submissionWithSeeds$highTeamSeed)


#Add regular season win/loss counts

#Win/Loss/% by Season/Team
Reg.Wins <- ddply(regular_season_results,c("season", "wteam"), summarise, N=length(wteam))
Reg.Losses <- ddply(regular_season_results,c("season","lteam"),summarise, N=length(lteam))

#Merge wins/losses by lowTeam/highTeam into the submission file
submissionWithSeeds <- merge(x = submissionWithSeeds, y = Reg.Wins, by.x=c("lowTeam","season"), by.y=c("wteam","season"))
submissionWithSeeds <- rename(submissionWithSeeds, c("N" = "lowTeamWins"))

submissionWithSeeds <- merge(x = submissionWithSeeds, y = Reg.Losses, by.x=c("lowTeam","season"), by.y=c("lteam","season"))
submissionWithSeeds <- rename(submissionWithSeeds, c("N" = "lowTeamLosses"))

submissionWithSeeds <- merge(x = submissionWithSeeds, y = Reg.Wins, by.x=c("highTeam","season"), by.y=c("wteam","season"))
submissionWithSeeds <- rename(submissionWithSeeds, c("N" = "highTeamWins"))

submissionWithSeeds <- merge(x = submissionWithSeeds, y = Reg.Losses, by.x=c("highTeam","season"), by.y=c("lteam","season"))
submissionWithSeeds <- rename(submissionWithSeeds, c("N" = "highTeamLosses"))

# Calculate regular season win pct
submissionWithSeeds$lowTeamWinRate <- submissionWithSeeds$lowTeamWins/(submissionWithSeeds$lowTeamWins + submissionWithSeeds$lowTeamLosses)
submissionWithSeeds$highTeamWinRate <- submissionWithSeeds$highTeamWins/(submissionWithSeeds$highTeamWins + submissionWithSeeds$highTeamLosses)

# Just renaming submissionWithSeeds to sub.working for shortness
sub.working <- submissionWithSeeds

# Calculate the difference in the win rates of the low vs. high teams.
sub.working$lhWinDiff <- sub.working$lowTeamWinRate - sub.working$highTeamWinRate

### Make a prediction
sub.working$prediction <- .5     # Start by assuming each team has a 50% chance of winning.

sub.working$prediction <- sub.working$prediction + sub.working$lhWinDiff     # Add the difference in win%.

# There has to be a better way to do this.
sub.working$seedBonus[sub.working$lowSeed > sub.working$highSeed] <- .1
sub.working$seedBonus[sub.working$lowSeed < sub.working$highSeed] <-  -.1

sub.working$prediction <- sub.working$prediction + sub.working$seedBonus

# Format and export the prediction
convalytics.prediction <- sub.working[,c("id","prediction")]

write.csv(convalytics.prediction, file = "convalytics_prediction.csv")

# Get tourney win count for each team

# How many times did low team beat high team?

# Does high or low team have better tourney performance?

# Who performs better when away?

# Account for likelihood of an upset.



