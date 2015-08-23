README.md
---------------------------------------------------------------------------------------------------------------------------
* Author: doug3230
* Version: August 23, 2015
* Email: doug3230@mylaurier.ca
* Description: This file provides an in-depth overview of the way that the run_analysis.R script is meant to be used.
			 Both user and developer perspectives are considered. That is, if a developer should wish to change/debug
			 the script, this file aims to be helpful by describing the intent behind the way certain things were written.

What run_analysis.R is expected to do
-------------------------------------------
run_analysis.R is expected to create or update two text files in the "Clean Dataset" folder.

The first, called "merged_data_set.txt" has the subject column, activity name column, and mean / std feature columns
from both the test and train data sets. The test data appears before the train data.

The second, called "average_data_set.txt" has the average feature value in "merged_data_set.txt" (for each feature column)
computed for each subject and for every activity.

Important Note: If the script's performance is unacceptable, see the summarize_data function as that is where the bottle neck is.

How to use run_analysis.R
---------------------------
It is expected that the working directory where the script is run contains the "UCI HAR Dataset" folder
and that another folder called "Clean Dataset" exists. run_analysis.R is crude in that if the clean dataset
directory does not exist, the program will not work and will throw an error.

It is also assumed that the test data is kept in a subfolder of "UCI HAR Dataset" called "test"
and that the training data is kept in a subfolder called "train". The data measurements are expected
to be in files in the subfolder with name of form "X_{subfolder}.txt" where {subfolder} is either "test"
or "train". The X files contain all columns of the data except for the subject column and the activity
column which are respectively expected to be stored in files of form "subject_{subfolder}.txt" and
"y_{subfolder}.txt".

The activity labels are assumed to be in the "UCI HAR Dataset" folder in a file called "activity_labels.txt".
The feature names are assumed to be in the "UCI HAR Dataset" folder in a file called "features.txt".

In the UCI HAR Dataset folder you do not need to include the Inertial Signals folders found in the test and train subfolders.
These are unused by the script as it only deals with mean and standard deviation features with "mean()" or "std()" in their names

Should the file locations and directory structure be changed, the script can in theory be modified to accomodate this.
The script makes use of constants that are described in the next section.

Important Note: If the script's performance is unacceptable, see the summarize_data function as that is where the bottle neck is.

How run_analysis.R works
--------------------------
What follows is a description of every constant and function defined in the script.
Important Note: If the script's performance is unacceptable, see the summarize_data function as that is where the bottle neck is.

Constants
----
* DIRTY_DIR: The directory where the original data is expected to be. In our case, "UCI HAR Dataset".
* CLEAN_DIR: The directory where the merged data and second independent data set will be output. In our case, "Clean Dataset".
* TEST_DIR: The subdirectory of DIRTY_DIR where the test data is kept. In our case, "test".
* TRAIN_DIR: The subdirectory of DIRTY_DIR where the training data is kept. In our case, "train".
* DATA_FILE: The name used to refer to the file where most of the dirty data's columns are kept. In our case, "X".
* ACTIVITY_FILE: The name used to refer to the file where the activity column is kept. In our case, "y".
* SUBJECT_FILE: The name used to refer to the file where the subject column is kept. In our case, "subject".
* FEATURE_FILE: The name used to refer to the file where the names of the features are kept. In our case, "features".
* ACTIVITY_LABEL_FILE: The name used to refer to the file where the names of the activities are kept. In our case, "activity_labels".
* FULL_DATA_FILE: The name used to refer to the file where the merged data set will be written. In our case, "merged_data_set".
* SUMMARY_DATA_FILE: The name used to refer to the file where the second independent data set (with the average feature values) will be written. In our case, "average_data_set".
* FILES_TO_MERGE: A convenient list that indicates what file names should be passed to the merge_file function.
				In our case DATA_FILE, ACTIVITY_FILE, and SUBJECT_FILE
* FILE_EXTENSION: All files are expected to use the same file extension. In our case, ".txt"
* COLS: The columns of DATA_FILE that correspond to features with "mean()" and "std()".
	  This value is hardcoded by inspection and could thus be mistaken. It would be wiser to determine COLS
	  programmatically.

Helper Functions
----
* concat(...) <- concatenates strings together. The original developer finds concat more intuitive
		  to read than paste(..., sep="")
* dirty_path(file_name) <- returns the relative path to a file named file_name assumed to be located in DIRTY_DIR
* clean_path(file_name) <- returns the relative path to a file named file_name assumed to be located in CLEAN_DIR
* test_path(file_name) <- returns the relative path to a file named file_name assumed to be located in TEST_DIR
* train_path(file_name) <- returns the relative path to a file named file_name assumed to be located in TRAIN_DIR
* rename_feature(feature_name) <- returns a string based off of feature_name that is used for naming the features in the merged data set
* feature_names() <- returns a vector of all the feature names found in FEATURE_FILE
* col_names(file_name) <- given a file_name in FILES_TO_MERGE, returns the names of the columns to use in the merged data set.
						Throws an error if it receives an unexpected file_name

Main Functions
----
* merge_file(file_name) <- writes a file to CLEAN_DIR named file_name containing the merged data
						 from in test's file_name file and train's file_name file.
						 If file_name is DATA_FILE then the non-mean and non-std columns are ignored.
* merge_files() <- calls merge_file() for each file in FILES_TO_MERGE
* remove_unnecessary_files() <- called near the end of the program for deleting any temporary files that are no longer needed.
* label_activities() <- Assuming the ACTIVITY_FILEs in TEST_DIR and TRAIN_DIR have been merged into CLEAN_DIR/ACTIVITY_FILE,
					  replaces the activity ids in CLEAN_DIR/ACTIVITY_FILE with the corresponding labels found in ACTIVITY_LABEL_FILE
* join_columns() <- This is meant to be called after merge_files() has been called. This function combines all of the merged files into a
				  consolidated file in CLEAN_DIR called FULL_DATA_FILE
* summarize_data() <- Reads the data from FULL_DATA_FILE and computes the average for every mean and std feature
					for each subject for every activity. The summarized data is written to a file in CLEAN_DIR called
					SUMMARY_DATA_FILE.
					
					Important Note: This function performs very slowly because it was written with crude for each loops and calls
					to rbind and cbind, and does not make use of functions optimized this purpose such as sapply.
					
* main() <- the main program that executes all the expected steps in the script.
		  Prints "Done!" if the script was executed successfully.
		  Returns the SUMMARY_DATA_FILE data set in data frame format.
