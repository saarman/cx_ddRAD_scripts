#!/bin/bash

# Replace "input_folder" with the actual path to your folder containing FastQC HTML files
input_folder="path/to/your/folder"

# Replace "summary_file.txt" with the desired path for the summary file
summary_file="path/to/your/summary_file.txt"

# Check if the input folder exists
if [ ! -d "$input_folder" ]; then
    echo "Error: Input folder not found."
    exit 1
fi

# Extract summary information from each FastQC HTML file
echo -e "File\tBasic Statistics\tPer Base Sequence Quality\tPer Sequence Quality Scores\tPer Base Sequence Content" > "$summary_file"

for html_file in "$input_folder"/*.html; do
    if [ -f "$html_file" ]; then
        # Extract relevant information using awk (you can customize this based on your needs)
        file_name=$(basename "$html_file" .html)
        basic_stats=$(awk '/<div id="basic_stats"/,/<\/div>/' "$html_file" | grep -A 6 "Basic Statistics")
        per_base_quality=$(awk '/<div id="per_base_quality"/,/<\/div>/' "$html_file" | grep -A 20 "Per Base Sequence Quality")
        per_seq_quality=$(awk '/<div id="per_sequence_quality"/,/<\/div>/' "$html_file" | grep -A 5 "Per sequence quality scores")
        per_base_content=$(awk '/<div id="per_base_content"/,/<\/div>/' "$html_file" | grep -A 20 "Per base sequence content")

        # Combine the information into a single line
        echo -e "$file_name\t$basic_stats\t$per_base_quality\t$per_seq_quality\t$per_base_content" >> "$summary_file"
    fi
done

echo "Summary file created: $summary_file"
