#First of all, please download the .zip file from 
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#and unzip this folder in your Coursera working directory (for example "User/Desktop/Coursera/")

#set the new folder as workind directory and list the files

setwd("UCI HAR Dataset/")
list.files()

#read the files from test folder with the data from the test subjects
sub_test<-read.table("test/subject_test.txt") #create a data.frame for subjects
activity_test<-read.table("test/y_test.txt") #create a data.frame for activities
data_test<-read.table("test/X_test.txt") #create a data.frame for measurements

#column bind all these data.frame in the TEST table
TEST<-cbind(sub_test,activity_test,data_test)

#read the files from train folder with the data from the train subjects
sub_train<-read.table("train/subject_train.txt") #create a data.frame for subjects
activity_train<-read.table("train/y_train.txt") #create a data.frame for activities
data_train<-read.table("train/X_train.txt") #create a data.frame for measurements

#column bind all these data.frame in the TRAIN table
TRAIN<-cbind(sub_train,activity_train,data_train)

#row bind all these data.frame in one, called MERGED, with all subjects
MERGED<-rbind(TEST,TRAIN)
#clean your workspace
rm (activity_test,activity_train,data_test,data_train,sub_test,sub_train,TRAIN,TEST)

#read table features (or measurement), create a vector with label
features<-read.table("features.txt")
features<-features[,2]
features<-as.vector(features)
#create a column Names vector with subject, activity and label of measurement
#remember that we put subject id and activity id as first and second column
colNames <- c("subject", "activity", features)
#substitute column Names
names(MERGED) <-colNames
names(MERGED)

#select column with words mean and sted
meanstdfeatures<-grep("-(mean|std)\\(\\)", colNames)
#the previous command select column in which we have word mean and std
#we need to add column 1 and 2 to preserve subject and activity
meanstdfeatures<-c(1,2,meanstdfeatures)
MERGED<-MERGED[,meanstdfeatures]

#it's better to have the column in order, just standardize the names and delete useless signs
names(MERGED) = gsub('-mean', 'Mean', names(MERGED))
names(MERGED) = gsub('-std', 'Std', names(MERGED))
names(MERGED) = gsub('[-()]', '', names(MERGED))

#now label the activity column using the file in folder
#set this variable as a factor
activity_lab<-read.table("activity_labels.txt")
MERGED$activity <- factor(MERGED$activity, levels = activity_lab[,1], labels = activity_lab[,2])
#set the subject variable as a factor
MERGED$subject <- as.factor(MERGED$subject)

#if library dplyr is not installed pleas installed it
install.packages("dplyr")
library(dplyr)

#just clean your workspace if you want
rm (activity_lab,colNames,features,meanstdfeatures)

#create a new data.frame using dplyr package
#using the verb group_by set this new data.frame grouped for subject and activity
merged_group<-group_by(MERGED,subject,activity)

#calculate the mean of all the column (by subject and activity)
#using the verbs summarise_each on the last data.frame
tidy<-summarise_each(merged_group, funs(mean))

#export this last file (the dity dataset) to the working directory
write.table(tidy, "tidy.txt", row.names = FALSE, quote = FALSE)
