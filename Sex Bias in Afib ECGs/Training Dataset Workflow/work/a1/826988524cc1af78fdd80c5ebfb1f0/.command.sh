#!/bin/bash -ue
echo challenge_id
python /app/training_dataset_test.py -i Nuubo_dataset.csv -p Nuubo -com BAIHA -c training-datasets -o Nuubo_assessment.json > output.log