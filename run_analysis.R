# Load library reshape2
library(reshape2)
#Download and unzip the file.
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
filename <- "dataset.zip"
if(!file.exists(filename)){
    download.file(url,filename, mode = "wb")
}
filepath <- "UCI HAR Dataset"
if(!file.exists(filepath)){
    unzip(filename)
}
#Reading data from train folder.
tr_sub<-read.table(file.path(filepath,"train","subject_train.txt"))
tr_y<-read.table(file.path(filepath,"train","Y_train.txt"))
tr_x<-read.table(file.path(filepath,"train","X_train.txt"))

# Reading Data from Test folder

test_sub<-read.table(file.path(filepath,"test","subject_test.txt"))
test_y<-read.table(file.path(filepath,"test","Y_test.txt"))
test_x<-read.table(file.path(filepath,"test","X_test.txt"))

#Reading features and activity labels

features<-read.table(file.path(filepath, "features.txt"), as.is = TRUE)
activities_labels<-read.table(file.path(filepath, "activity_labels.txt"))
activities_labels[,2]<-as.character(activities_labels[,2])

# Merging the datasets
X_data<-rbind(tr_x,test_x)
Y_data<-rbind(tr_y,test_y)
sub_data<-rbind(tr_sub,test_sub)

#Extract the Columns related to mean and standard deviation.

Cols <- grep("-(mean|std).*", as.character(features[,2]))
selColNames <- features[Cols, 2]
selColNames <- gsub("-mean", "Mean", selColNames)
selColNames <- gsub("-std", "Std", selColNames)
selColNames <- gsub("[-()]", "", selColNames)

#Extracting the data using columns ectracted and adding names to descriptive columns.

X_data <- X_data[Cols]
data<-cbind(sub_data,Y_data,X_data)
colnames(data)<-c("Subject","Activity",selColNames)

#Converting the Activities and Subject as facors

data$Activity<-factor(data$Activity, labels = activities_labels[,2], levels = activities_labels[,1])

#generating a tidy data set using melt and decast.

melted_Data <- melt(data, id = c("Subject", "Activity"))
tidy_Data <- dcast(melted_Data, Subject + Activity ~ variable, mean)
 #writng the test file.
write.table(tidy_data, "tidy.txt", row.names = FALSE, quote = FALSE)
