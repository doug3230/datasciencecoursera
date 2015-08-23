#Constants
#-----------
DIRTY_DIR <- "UCI HAR Dataset"
CLEAN_DIR <- "Clean Dataset"
TEST_DIR <- "test"
TRAIN_DIR <- "train"
DATA_FILE <- "X"
ACTIVITY_FILE <- "y"
SUBJECT_FILE <- "subject"
FEATURE_FILE <- "features"
ACTIVITY_LABEL_FILE <- "activity_labels"
FULL_DATA_FILE <- "merged_data_set"
SUMMARY_DATA_FILE <- "average_data_set"
FILES_TO_MERGE <- list(DATA_FILE, ACTIVITY_FILE, SUBJECT_FILE)
FILE_EXTENSION <- ".txt"
COLS <- c(1, 2, 3, 4, 5, 6, 41, 42, 43, 44, 45,
          46, 81, 82, 83, 84, 85, 86, 121, 122,
          123, 124, 125, 126, 161, 162, 163, 164,
          165, 166, 201, 202, 214, 215, 227, 228,
          240, 241, 253, 254, 266, 267, 268, 269,
          270, 271, 345, 346, 347, 348, 349, 350,
          424, 425, 426, 427, 428, 429, 503, 504,
          516, 517, 529, 530, 542, 543)

#Helper Functions
#------------------
concat <- function (...) {paste(..., sep="")}
dirty_path <- function (file_name) {file.path(DIRTY_DIR, concat(file_name, FILE_EXTENSION))}
clean_path <- function (file_name) {file.path(CLEAN_DIR, concat(file_name, FILE_EXTENSION))}
test_path <- function (file_name) {file.path(DIRTY_DIR, TEST_DIR, concat(file_name, "_test", FILE_EXTENSION))}
train_path <- function (file_name) {file.path(DIRTY_DIR, TRAIN_DIR, concat(file_name, "_train", FILE_EXTENSION))}
rename_feature <- function (feature_name) {sub("(.*)-(mean|std)\\(\\)", "\\2-\\1", feature_name)}
feature_names <- function () {
  feature_file_name <- dirty_path(FEATURE_FILE)
  names <- read.table(feature_file_name)[COLS, 2]
  names <- rename_feature(names)
  names
}
col_names <- function (file_name) {
  if (file_name == DATA_FILE)
    feature_names()
  else if (file_name == ACTIVITY_FILE)
    "Activity"
  else if (file_name == SUBJECT_FILE)
    "Subject"
  else
    stop("Unexpected file_name: ", file_name)
}

#Main Functions
#----------------
merge_file <- function (file_name) {
  #process the corresponding file names for the test and train sets
  test_file_name <- test_path(file_name)
  train_file_name <- train_path(file_name)
  
  #read in the data
  if (file_name == DATA_FILE) {
    test_data <- read.table(test_file_name)[, COLS]
    training_data <- read.table(train_file_name)[, COLS]
  } else {
    test_data <- read.table(test_file_name)
    training_data <- read.table(train_file_name)
  }

  #merge the two data sets into a new data set
  merged_data <- rbind(test_data, training_data)
  
  #process the corresponding file name for the merged data set
  merged_file_name <- clean_path(file_name)
  
  #write the new data set to file
  write.table(merged_data, file=merged_file_name, row.names=FALSE, col.names=col_names(file_name))
  return()
}

merge_files <- function () {
  for (file_name in FILES_TO_MERGE) {
    merge_file(file_name)
  }
  return()
}

remove_unnecessary_files <- function () {
  for (file_name in FILES_TO_MERGE) {
    unlink(clean_path(file_name))
  }
  return()
}

label_activities <- function () {
  activity_labels <- read.table(dirty_path(ACTIVITY_LABEL_FILE))[, 2]
  activities <- read.table(clean_path(ACTIVITY_FILE), header=TRUE)
  activities[, 1] <- activity_labels[activities[, 1]]
  write.table(activities, file=clean_path(ACTIVITY_FILE), row.names=FALSE)
  return()
}

join_columns <- function () {
  main_data <- read.table(clean_path(DATA_FILE), header=TRUE)
  activity_data <- read.table(clean_path(ACTIVITY_FILE), header=TRUE)
  subject_data <- read.table(clean_path(SUBJECT_FILE), header=TRUE)
  joined_data <- cbind(subject_data, activity_data, main_data)
  write.table(joined_data, file=clean_path(FULL_DATA_FILE), row.names=FALSE)
  return()
}

summarize_data <- function () {
  features <- feature_names()
  header <- concat("avg-", features)
  features <- gsub("-", ".", features)
  header <- gsub("-", ".", header)
  header <- c("Subject", "Activity", header)
  subjects <- read.table(clean_path(SUBJECT_FILE), header=TRUE)
  activities <- read.table(clean_path(ACTIVITY_FILE), header=TRUE)
  subject_list <- unique(sort(subjects$Subject))
  activity_list <- unique(sort(activities$Activity))
  
  data <- read.table(clean_path(FULL_DATA_FILE), header=TRUE)
  summary_data <- c()
  for (subject in subject_list) {
    for (activity in activity_list) {
      row <- cbind(subject, activity)
      for (feature in features) {
        row <- cbind(row, mean(data[subjects$Subject == subject & activities$Activity == activity, feature], na.rm=TRUE))
      }
      summary_data <- rbind(summary_data, row)
    }
  }
  write.table(summary_data, file=clean_path(SUMMARY_DATA_FILE), row.names=FALSE, col.names=header)
  return()
}

#Main Program
#----------------
main <- function() {
  merge_files()
  label_activities()
  join_columns()
  summarize_data()
  remove_unnecessary_files()
  print("Done!")
}
main()