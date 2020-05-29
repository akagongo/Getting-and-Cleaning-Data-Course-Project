# load the required libraries
library(dplyr)
library(tibble)

# read the required files
x_test <- read.table('UCI HAR Dataset/test/X_test.txt')
x_train <- read.table('UCI HAR Dataset/train/X_train.txt')
y_test <- read.table('UCI HAR Dataset/test/y_test.txt')
y_train <- read.table('UCI HAR Dataset/train/y_train.txt')
subject_train <- read.table('UCI HAR Dataset/train/subject_train.txt')
subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt')
activity_labels <- read.table('UCI HAR Dataset/activity_labels.txt')
features <- read.table('UCI HAR Dataset/features.txt')

# combine the test and train feature data
x_dataset <- rbind(x_test, x_train)

# combine the test and train activity data
y_dataset <- rbind(y_test, y_train)

# combine the test and train subject data
subject_dataset <- rbind(subject_test, subject_train)

# name the activity and subject columns
colnames(y_dataset) <- 'activity'
colnames(subject_dataset) <- 'subject'

# encode the activity data as labeled factors
factor_labels <- factor(y_dataset$activity, levels = activity_labels$V1, labels = activity_labels$V2)

# replace the coded activity values for labels
y_dataset <- mutate(y_dataset, activity = factor_labels)

# encode the subject data as a factor of subjects
subject_dataset$subject <- as.factor(subject_dataset$subject)

# combine the features, subject and activity datasets
dataset <- cbind(x_dataset, subject_dataset, y_dataset)

# turns the merged dataframe into a tibble
dataset <- as_tibble(dataset)

# search the indices of the features of interest 
indices <- grep('mean\\(|std\\(', features$V2)

# subset the name os the features of interest
features_name <- features$V2[indices]

# select the variables of interest, then rename the features
dataset <- dataset %>% select(subject, activity, num_range('V', indices)) %>%
    rename_at(vars(-activity, -subject), ~features_name)

# group the tibble by subject and activity, then summarize using the mean
grouped_dataset <- group_by(dataset, subject, activity) %>%
    summarize_all(mean)

write.table(grouped_dataset, file = 'grouped_dataset.txt', row.names = FALSE)

