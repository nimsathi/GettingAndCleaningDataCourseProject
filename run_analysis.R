library(dplyr);

#load data frames
activities <- read.table('./UCI HAR Dataset/activity_labels.txt', header=FALSE, col.names=c('activityId', 'activity'));
features <- read.table('./UCI HAR Dataset/features.txt', header=FALSE, col.names = c('featureId', 'feature'))
XTrain <- read.table('./UCI HAR Dataset/train/X_train.txt', header=FALSE, col.names=features$feature)
XTest <- read.table('./UCI HAR Dataset/test/X_test.txt', header=FALSE, col.names=features$feature)
yTrain <- read.table('./UCI HAR Dataset/train/y_train.txt', header=FALSE, col.names=c('activityId'))
yTest <- read.table('./UCI HAR Dataset/test/y_test.txt', header=FALSE, col.names=c('activityId'))
subjectTrain <- read.table('./UCI HAR Dataset/train/subject_train.txt', header=FALSE, col.names=c('subject'))
subjectTest <- read.table('./UCI HAR Dataset/test/subject_test.txt', header=FALSE, col.names=c('subject'))

#merge train and test data
data <- bind_rows(XTrain, XTest)
activityIds <- bind_rows(yTrain, yTest)
subjects <- bind_rows(subjectTrain, subjectTest)
mergedData <- activityIds %>%
  bind_cols(subjects) %>%
  bind_cols(data)

#extract only the columns we want
tidyData <- mergedData %>%
  select('activityId', 'subject', contains('mean'), contains('std'))

#add descriptive activity names
tidyData$activityId = activities[tidyData$activityId,2]
names(tidyData)[1] <- 'activity'

#add descriptive variable names
names(tidyData) <- gsub('^t', 'Time', names(tidyData))
names(tidyData) <- gsub('^f', 'Frequency', names(tidyData))
names(tidyData) <- gsub('.mean...', 'Mean', names(tidyData), fixed=TRUE)
names(tidyData) <- gsub('.std...', 'STD', names(tidyData), fixed=TRUE)
names(tidyData) <- gsub('.std..', 'STD', names(tidyData), fixed=TRUE)
names(tidyData) <- gsub('Gyro', 'Gyroscope', names(tidyData))
names(tidyData) <- gsub('Acc', 'Accelerometer', names(tidyData))
names(tidyData) <- gsub('Mag', 'Magnitude', names(tidyData))
names(tidyData) <- gsub('BodyBody', 'Body', names(tidyData))

##### Step 5 ######

#get the average for each variable by activity and subject
summaryData <- tidyData %>%
  group_by(activity, subject) %>%
  summarise_all(mean);

#write summartData to tidy.txt
write.table(summaryData, file = "tidy.txt", row.names=FALSE, quote=FALSE)
