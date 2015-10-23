
#Start

library(data.table)
library(reshape2)


filename <- "getdata-projectfiles-UCI HAR Dataset.zip"

################ Download File################
if (!file.exists(filename)) {
        cat("Downloadin file...")
        fileURL <-
                "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename, method = "curl")
}  else
{
        cat("File already downloaded")
}

################Check if file unpacked################
if (!file.exists("UCI HAR Dataset")) {
        cat("Unpacking file...")
        unzip(filename)
}else
{
        cat("File already unpacked")
}

################Load activity labels################
activity_labels <- read.csv(
        "UCI HAR Dataset/activity_labels.txt",
        header = FALSE, sep = " ",
        colClasses = c("integer","character")
)
#To DataTable Activities
activity_labels <- data.table(activity_labels)


################Load features################
features <- read.csv(
        "UCI HAR Dataset/features.txt",
        header = FALSE, sep = " ",
        colClasses = c("integer","character")
)
#To DataTable features
features <- data.table(features)


##Get only the measurements on the mean and standard deviation for each measurement.
NeedFeatures <- grep(".*mean.*|.*std.*", features[,features$V2])
NeedFeatures.names <- features[NeedFeatures,V2]
NeedFeatures.names = gsub('-mean', 'Mean', NeedFeatures.names)
NeedFeatures.names = gsub('-std', 'Std', NeedFeatures.names)
NeedFeatures.names <- gsub('[-()]', '', NeedFeatures.names)




################Load Train datasets################
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[NeedFeatures]
trainDataActivities <-
        read.table("UCI HAR Dataset/train/Y_train.txt")
trainDataSubjects <-
        read.table("UCI HAR Dataset/train/subject_train.txt")
trainDataAll <-
        cbind(trainDataSubjects, trainDataActivities , trainData)


################Load Test datasets################
testData <- read.table("UCI HAR Dataset/test/X_test.txt")[NeedFeatures]
testDataActivities <-
        read.table("UCI HAR Dataset/test/Y_test.txt")
testDataSubjects <-
        read.table("UCI HAR Dataset/test/subject_test.txt")
testDataAll <-
        cbind(testDataSubjects, testDataActivities,  testData)

################Merge data################
MergedData <- rbind(trainDataAll, testDataAll)
cat("Total loaded rows: ",  nrow(MergedData))

#Use descriptive activity names to name the activities in the data set
colnames(MergedData) <- c("subject", "activity", NeedFeatures.names)


#Set names for Activities from dictionary
MergedData$activity <- factor(MergedData$activity, levels = activity_labels[,V1], 
                              labels = activity_labels[,V2])

MergedData$subject <- as.factor(MergedData$subject)


MergedData.melted <- melt(MergedData, id = c("subject", "activity"))
MergedData.mean <- dcast(MergedData.melted, subject + activity ~ variable, mean)

################Save################
write.table(MergedData.mean, "tidyData.txt", row.names = FALSE, quote = FALSE)







