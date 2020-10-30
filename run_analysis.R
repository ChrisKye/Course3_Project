library(data.table)
library(plyr)
library(reshape2)

#Download data
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

#Extracting Measurements
features <- read.table(file.path(path,"UCI HAR Dataset/features.txt"), 
                       col.names = c("index", "featureNames"))
featuresActual <- grep("(mean|std)\\(\\)", features[,"featureNames"])
measurements <- features[featuresActual,"featureNames"]
measurements <- gsub("[()]","", measurements)

#reading & merging training data
subject_train <- read.table(file.path(path,"UCI HAR Dataset/train/subject_train.txt"))
x_train <- read.table(file.path(path,"UCI HAR Dataset/train/X_train.txt"))[,featuresActual]
y_train <- read.table(file.path(path,"UCI HAR Dataset/train/y_train.txt"))
train <- cbind(subject_train,x_train, y_train)
colnames(train) = c("subject",measurements,"activity")

#reading & merging testing data
subject_test <- read.table(file.path(path,"UCI HAR Dataset/test/subject_test.txt"))
x_test <- read.table(file.path(path,"UCI HAR Dataset/test/X_test.txt"))[,featuresActual]
y_test <- read.table(file.path(path,"UCI HAR Dataset/test/y_test.txt"))
test <- cbind(subject_test,x_test, y_test)
colnames(test) = c("subject",measurements,"activity")

#combine train set & test set
combinedSet <- rbind(train, test)

#activities and subjects as factors 
Labels <- read.table(file.path(path, "UCI HAR Dataset/activity_labels.txt"), 
                     col.names = c("classLabels", "activityName"))
combinedSet["activity"] <- factor(combinedSet[, "activity"]
                                  , levels = Labels[["classLabels"]]
                                  , labels = Labels[["activityName"]])
combinedSet["subject"] <- as.factor(combinedSet[,"subject"])

#returning tidy dataset
tidySet <- reshape2::melt(data = combinedSet, id.vars = c("subject", "activity"))
tidySet <- reshape2::dcast(data = tidySet, subject + activity ~ "variable", mean)

#write dataset into csv
write.table(tidySet, file.path(path, "tidyDataSet.txt"), row.names = FALSE)
