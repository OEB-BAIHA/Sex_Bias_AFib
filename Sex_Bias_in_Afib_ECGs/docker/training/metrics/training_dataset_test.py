# METRICS:
# Class Imbalance- What proportion of the dataset is one class vs the other (male/female)
#   - (number of A - number of B)/(number of A + number of B)
#   - positive means class A has more training samples, 0 equal, negative means class B has more
# Label Imbalance-  What percentage of 'positive' labels are male/female
#   - positive value means class A has a higher proportion of positive/negative outcomes than class B
#   - negative value means class B has a higher proportion of positive/negative outcomes than class A
#   - zero means equal proportions of positive/negative outcomes between classes
# Conditional Demographic Disparity - determines whether males/females have a
#   larger proportion of 'rejected' outcomes in the data set than of the 'accepted' outcomes 
#   - proportion of negative outcomes for class B minus the proportion of positive outcomes for class B
#   - positive values indicate that class B have a greater proportion of negative
#   outcomes in the dataset than positive outcomes
#   - negative values indiciate that class B jave a greater proportion of positive 
#   outcomes in the dataset than rejected outcomes
#   - zero is balanced

# DATA FORMAT:
# - column labeled 'Sexo' that has sex of patient
# - column labeled 'diagnosis' that has 'Yes' for atrial fibrillation and 'No' for no atrial fibrillation

import numpy as np
import os
import pandas as pd
import math
import io
import json
from argparse import ArgumentParser
from JSON_templates import JSON_templates


parser = ArgumentParser()
parser.add_argument("-i", "--input", help="path to input dataset to be validated", required=True)
parser.add_argument("-com", "--community_name", help="name of benchmarking community", required=True)
parser.add_argument("-c", "--challenge", help="the challenge that this input data is for", required=True)
parser.add_argument("-p", "--participant_name", help="name of the tool used for prediction", required=True)
parser.add_argument("-o", "--output", help="output path where participant JSON file will be written", required=True)
    
args = parser.parse_args()


def main(args):

    # input parameters
    input_dataset = args.input
    community = args.community_name
    challenge = args.challenge
    participant_name = args.participant_name
    out_path = args.output

    # Assuring the output path does exist
    if not os.path.exists(os.path.dirname(out_path)):
        try:
            os.makedirs(os.path.dirname(out_path))
            with open(out_path, mode="a"):
                pass
        except OSError as exc:
            print("OS error: {0}".format(exc) + "\nCould not create output path: " + out_path)

    compute_metrics(input_dataset, challenge, participant_name, community, out_path)


# IMPORTANT: This code is currently does not consider Null entries for Sex and AF in these calculations
#               Also, all standard errors are set to 0, ask about this

def compute_metrics(input_dataset, challenge, participant_name, community, out_path):

    df = pd.read_csv(input_dataset, header=0) 

    # Calculate metrics
    male_count = len(df[df['Sexo'] == 'Male'])
    female_count = len(df[df['Sexo'] == 'Female'])
    overall_positive = len(df[df['AF'] == 1])
    overall_negative = len(df[df['AF'] == 0])

    m_positive = len(df[(df['Sexo'] == 'Male') & (df['AF'] == 'Yes')])
    m_negative = len(df[(df['Sexo'] == 'Male') & (df['AF'] == 'No')])
    f_positive = len(df[(df['Sexo'] == 'Female') & (df['AF'] == 'Yes')])
    f_negative = len(df[(df['Sexo'] == 'Female') & (df['AF'] == 'No')])
    
    class_imbalance = (male_count - female_count) / (male_count + female_count) if (male_count + female_count) != 0 else 0

    f_positive_label_percentage = f_positive / overall_positive if overall_positive != 0 else 0
    f_negative_label_percentage = f_negative / overall_negative if overall_negative != 0 else 0

    positive_label_imbalance = (m_positive / male_count if male_count != 0 else 0) - (f_positive / female_count if female_count != 0 else 0)
    negative_label_imbalance = (m_negative / male_count if male_count != 0 else 0) - (f_negative / female_count if female_count != 0 else 0)

    f_conditional_demographic_disparity = (f_negative / (m_negative + f_negative) if (m_negative + f_negative) != 0 else 0) - (f_positive / (m_positive + f_positive) if (m_positive + f_positive) != 0 else 0)
    m_conditional_demographic_disparity = (m_negative / (m_negative + f_negative) if (m_negative + f_negative) != 0 else 0) - (m_positive / (m_positive + f_positive) if (m_positive + f_positive) != 0 else 0)

    # Export metrics in correct format
    ALL_ASSESSMENTS = []
    assessment_data = {'participant': participant_name, 'Class Imbalance': class_imbalance, 'Female Positive Label Percentage': f_positive_label_percentage, 
                       'Female Negative Label Percentage': f_negative_label_percentage, 'Positive Label Imbalance': positive_label_imbalance, 'Negative Label Imbalance': negative_label_imbalance, 
                       'Female Conditional Demography': f_conditional_demographic_disparity, 'Male Conditional Demography': m_conditional_demographic_disparity}
    
    for key, value in assessment_data.items():
        if key != 'participant':
            data_id = community + ":" + "_" + key.replace(" ", "_") + "_" + participant_name + "_A"
            assessment = JSON_templates.write_assessment_dataset(data_id, community, challenge, participant_name, key, value, 0)
            # push the assessment datasets for each metric to the main dataset array
            ALL_ASSESSMENTS.append(assessment)

    # once all assessments have been added, print to json file
    with io.open(out_path,
                 mode='w', encoding="utf-8") as f:
        jdata = json.dumps(ALL_ASSESSMENTS, sort_keys=True, indent=4, separators=(',', ': '))
        f.write(jdata)


if __name__ == '__main__':

    main(args)