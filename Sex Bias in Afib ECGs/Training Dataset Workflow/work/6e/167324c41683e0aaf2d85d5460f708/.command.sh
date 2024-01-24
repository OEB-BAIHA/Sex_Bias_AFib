#!/bin/bash -ue
full_file_path=$(realpath ${assessment_dir}/${assessment_filename)
python /app/aggregation.py -b metrics_output -a $full_file_path -o results_dir --offline 1
python /app/merge_data_model_files.py -v Nuubo_validation.json -m metrics_output -c training_dataset -a results_dir -o consolidated_result.json