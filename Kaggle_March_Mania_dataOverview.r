######################################################
#  Kaggle March Mania Competition
#  Jason Green
#  February, 12th 2014
#  https://github.com/Convalytics/kaggle-march-mania
#  Last Updated: 2/23/2014
######################################################

#install.packages('plyr')
library(plyr)
library(ggplot2)
# Set Working Directory
#setwd("C:\\Users\\jgreen\\Documents\\GitHub\\kaggle-march-mania")
setwd("~/GitHub/kaggle-march-mania")


predictions <- readRDS("~/GitHub/kaggle-march-mania/predictionFile.rdata")
livegames <- subset(predictions, predictions$lowTeamWon == 1 | predictions$lowTeamWon == 0)
livegames$lowSeed <- as.numeric(livegames$lowSeed)
livegames$highSeed <- as.numeric(livegames$highSeed)
livegames$lowTeamWon <- as.numeric(livegames$lowTeamWon)
winsBySeed <- ddply(livegames,c("seedDif"), summarise, N=sum(livegames$lowTeamWon))

winsBySeed$N <- as.numeric(winsBySeed$N)
winsBySeed$lowTeamWon <- as.numeric(winsBySeed$lowTeamWon)

plot(winsBySeed$N, winsBySeed$seedDif)
#ggplot(winsBySeed, aes(N), x=seedDif)
#ggplot(csat, aes(COGS)) + geom_histogram(binwidth=50, fill="gray", color="black") + theme_bw()
qplot(seedDif, data=winsBySeed, weight=N, geom="histogram") + geom_histogram(aes(y = ..density..)) + geom_density()

head(winsBySeed)
dim(livegames)
head(livegames)
boxplot(c(predictions$pred, predictions$pred.seeds) ~ predictions$lowTeamWon)

# Lower seeded teams generally win.
boxplot(livegames$lowSeed ~ livegames$lowTeamWon)

plot(livegames$lowSeed ~ livegames$highSeed, col=as.factor(livegames$lowTeamWon), size=.5)

plot(livegames$seedDif ~ (sum(livegames$lowTeamWon)/length(livegames)))

livegames$seedDif <- livegames$lowSeed - livegames$highSeed

head(livegames, n=20)


# Import Data
regular_season_results <- read.csv("~/GitHub/kaggle-march-mania/regular_season_results.csv")
tourney_results <- read.csv("~/GitHub/kaggle-march-mania/tourney_results.csv")
#sample_submission <- read.csv("~/GitHub/kaggle-march-mania/sample_submission.csv")
#load previous RPI predictor as starting point.
sample_submission <- read.csv("~/GitHub/kaggle-march-mania/convalytics_prediction_4.csv")
seeds <- read.csv("~/GitHub/kaggle-march-mania/tourney_seeds.csv")
slots <- read.csv("~/GitHub/kaggle-march-mania/tourney_slots.csv")

head(regular_season_results)
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

# Add High/Low/Winner columns to tourney_results
head(tourney_results, n=10)

tourney_results$lowTeamWon <- ifelse(tourney_results$wteam < tourney_results$lteam, 1, 0)
tourney_results$lowTeam <- ifelse(tourney_results$wteam < tourney_results$lteam, tourney_results$wteam, tourney_results$lteam)
tourney_results$highTeam <- ifelse(tourney_results$wteam > tourney_results$lteam, tourney_results$wteam, tourney_results$lteam)

#build an ID column to join into submission file
##########################################################################
tourney_results$id <- paste0(tourney_results$season, "_", tourney_results$lowTeam, "_", tourney_results$highTeam)

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

# Merge in Actual Tourney Data  (for checking our work)
submissionWithSeeds <- merge(x=submissionWithSeeds, y=tourney_results, by.x="id", by.y="id", all.x=TRUE)

# Just renaming submissionWithSeeds to sub.working for shortness
sub.working <- submissionWithSeeds

# Calculate the difference in the win rates of the low vs. high teams.
sub.working$lhWinDiff <- sub.working$lowTeamWinRate - sub.working$highTeamWinRate


#### Scott's win percentage algo
sub.working$pred.algo <- (sub.working$lowTeamWinRate-(sub.working$lowTeamWinRate*sub.working$highTeamWinRate))/(sub.working$lowTeamWinRate+sub.working$highTeamWinRate-(2*sub.working$lowTeamWinRate*sub.working$highTeamWinRate))

#### Win Diff prediction
sub.working$pred.lhWinDiff <- .5 + sub.working$lhWinDiff


#### Seed Predictor "RPI Beater"
sub.working$pred.seeds <-.5+.03*(as.numeric(sub.working$highSeed)-as.numeric(sub.working$lowSeed))

##############################################################################################
### Make a prediction  -----------------------------------------------------------------------
#sub.working$prediction <- .5     # Start by assuming each team has a 50% chance of winning.
#Instead of starting at 50%, we'll start at the previous prediction
#sub.working$prediction <- sub.working$pred     # 

#sub.working$prediction <- sub.working$prediction + sub.working$lhWinDiff     # Add the difference in win%.

#sub.working$seedBonus <- ifelse(sub.working$lowSeed < sub.working$highSeed, .1, -.1)

#Now we're using the algo from Scott:

#Latest Ensemble: sub.working$pred <- (sub.working$pred.algo + sub.working$pred.lhWinDiff + sub.working$pred.seeds)/3
# Test Cheat - Remember to remove before next submission !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub.working$lowTeamWon <- ifelse(is.na(sub.working$lowTeamWon),.5,sub.working$lowTeamWon)
sub.working$pred <- (sub.working$pred.algo + sub.working$pred.lhWinDiff + sub.working$pred.seeds + sub.working$lowTeamWon)/4
#sub.working$pred <- sub.working$prediction # seed is already taken into account + sub.working$seedBonus
#sub.working$pred[sub.working$pred < .01] <- .01
#sub.working$pred[sub.working$pred > .99] <- .99




# Write out the full prediction file:
write.csv(sub.working, file = "predictionDetails.csv", row.names=F)


# Format and export the prediction
convalytics.prediction <- sub.working[,c("id","pred")]
# Write out the submission file for kaggle:
write.csv(convalytics.prediction, file = "convalytics_prediction_6.csv", row.names=F)

# Get tourney win count for each team

# How many times did low team beat high team?

# Does high or low team have better tourney performance?

# Who performs better when away?


# Account for likelihood of an upset.



