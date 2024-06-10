# --------------------------------------------------
# Assignment 04.1: Implement a Relational Database
# Rashaad Mohammed Mirza | mirza.ra@northeastern.edu

# CS 5200 – DBMS Su24 | June 04, 2024
# Dr. Martin Schedlbauer | Northeastern University
# --------------------------------------------------

# --------------------------------------------------
# Step 1: Load Required Libraries and Connect to the SQLite Database
# --------------------------------------------------

# Install and load required libraries: uncomment the next line if RSQLite is not already installed
#install.packages("RSQLite")

# Load the RSQLite package
library(RSQLite)

# Create a connection to the SQLite database
db <- dbConnect(SQLite(), dbname = "lessonDB-MirzaR.sqlitedb")

# --------------------------------------------------
# Step 2: Define the Schema and Create Tables
# --------------------------------------------------

# Function to drop existing tables if they exist
drop_existing_tables <- function(db) {
  dbExecute(db, "DROP TABLE IF EXISTS Lesson")
  dbExecute(db, "DROP TABLE IF EXISTS Module")
  dbExecute(db, "DROP TABLE IF EXISTS Prerequisite")
  dbExecute(db, "DROP TABLE IF EXISTS ModuleLesson")
}

# Function to create tables
create_tables <- function(db) {
  # Create Module table
  dbExecute(db, "
  CREATE TABLE Module (
      mid TEXT PRIMARY KEY,
      title TEXT,
      lengthInMinutes INTEGER,
      difficulty TEXT CHECK(difficulty IN ('beginner', 'intermediate', 'advanced')) DEFAULT 'beginner'
  )
  ")
  
  # Create Lesson table
  dbExecute(db, "
  CREATE TABLE Lesson (
      category INTEGER,
      number INTEGER,
      title TEXT,
      PRIMARY KEY (category, number)
  )
  ")
  
  # Create Prerequisite table for many-to-many relationship of prerequisites
  dbExecute(db, "
  CREATE TABLE Prerequisite (
      category INTEGER,
      number INTEGER,
      prerequisite_category INTEGER,
      prerequisite_number INTEGER,
      FOREIGN KEY (category, number) REFERENCES Lesson(category, number),
      FOREIGN KEY (prerequisite_category, prerequisite_number) REFERENCES Lesson(category, number),
      PRIMARY KEY (category, number, prerequisite_category, prerequisite_number)
  )
  ")
  
  # Create ModuleLesson junction table
  dbExecute(db, "
  CREATE TABLE ModuleLesson (
      mid TEXT,
      category INTEGER,
      number INTEGER,
      FOREIGN KEY (mid) REFERENCES Module(mid),
      FOREIGN KEY (category, number) REFERENCES Lesson(category, number),
      PRIMARY KEY (mid, category, number)
  )
  ")
}

# --------------------------------------------------
# Step 3: Insert Sample Data
# --------------------------------------------------

# Function to insert sample data
insert_sample_data <- function(db) {
  # Insert sample data into Module table
  dbExecute(db, "
  INSERT INTO Module (mid, title, lengthInMinutes, difficulty) VALUES
  ('M1', 'Introduction to R', 60, 'beginner'),
  ('M2', 'Advanced R Programming', 90, 'advanced')
  ")
  
  # Insert sample data into Lesson table
  dbExecute(db, "
  INSERT INTO Lesson (category, number, title) VALUES
  (1, 101, 'Basic R Syntax'),
  (1, 102, 'Data Structures in R'),
  (2, 201, 'Functions in R'),
  (2, 202, 'Advanced Data Manipulation in R')
  ")
  
  # Insert sample data into Prerequisite table
  dbExecute(db, "
  INSERT INTO Prerequisite (category, number, prerequisite_category, prerequisite_number) VALUES
  (2, 201, 1, 101),
  (2, 202, 1, 102)
  ")
  
  # Insert sample data into ModuleLesson table
  dbExecute(db, "
  INSERT INTO ModuleLesson (mid, category, number) VALUES
  ('M1', 1, 101),
  ('M1', 1, 102),
  ('M2', 2, 201),
  ('M2', 2, 202)
  ")
}

# --------------------------------------------------
# Step 4: Verify the Tables and Data
# --------------------------------------------------

# Function to print table contents with a title
print_table <- function(db, table_name) {
  cat(sprintf("\n--- %s Table ---\n", table_name))
  result <- dbGetQuery(db, sprintf("SELECT * FROM %s", table_name))
  print(result)
}

# --------------------------------------------------
# Step 5: Main function to run the script
# --------------------------------------------------
main <- function() {
  # Drop existing tables if they exist
  drop_existing_tables(db)
  # Create tables
  create_tables(db)
  # Insert sample data
  insert_sample_data(db)
  # Verify Module table
  print_table(db, "Module")
  # Verify Lesson table
  print_table(db, "Lesson")
  # Verify Prerequisite table
  print_table(db, "Prerequisite")
  # Verify ModuleLesson table
  print_table(db, "ModuleLesson")
  # Disconnect from the database
  dbDisconnect(db)
}

# Run the main function
main()