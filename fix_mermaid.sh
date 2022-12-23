#!/bin/bash

# Define the word
word="mermaid"

# Set the directory to iterate over
directory="."

# Iterate over all files in the directory and its subdirectories
find $directory -name "*.md" -type f | while read file
do
  # Print the filename
  echo $file
  sed -i 's/mermaid/{mermaid}/g' $file
done