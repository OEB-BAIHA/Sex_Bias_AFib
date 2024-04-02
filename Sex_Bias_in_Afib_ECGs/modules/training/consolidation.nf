#!/usr/bin/env nextflow

process TRAINING_CONSOLIDATION {

    """
    Description:
    ----------------------------------------
    Processes training_dataset challenge participant evaluation data, performing 
    aggregations and generating corresponding JSON files and graphs.
    Finally  merges JSON files from different sources, such as validation data, 
    metrics and benchmark summaries, into a single consolidated file.

    Inputs:
        - validated_meta, assess_meta: Metadata 
        - validated_json: Path to training_dataset_validation.json
        - assess_json: Path to training_dataset_assessment.json
        - assess_dir: Paths to other_participant_data

    Outputs:
        - consolidated_json: Metadata and training_dataset_consolidation.json

    """

	input:
        tuple val(validated_meta), path(validated_json)
        tuple val(assess_meta), path(assess_json)
        path assess_dir
	
	output:
        tuple val(validated_meta), path("${params.data_model_export_dir}"), emit: consolidated_json
        path 'other_dir', type: 'dir'

	script:
	"""
	python3 /app/aggregation.py -b ${assess_dir} -a ${assess_json} -o other_dir --offline ${validated_meta.offline_execution}
	python3 /app/merge_data_model_files.py -v ${validated_json} -m ${assess_json} -c ${assess_meta.challenges_ids} -a other_dir -o ${params.data_model_export_dir}
	"""
}
