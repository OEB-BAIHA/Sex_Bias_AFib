#!/bin/bash -ue
echo assessment_dir
echo assessment_filepath
python /app/aggregation.py -b metrics_output -a Nuubo_assessment.json -o results_dir --offline 1
