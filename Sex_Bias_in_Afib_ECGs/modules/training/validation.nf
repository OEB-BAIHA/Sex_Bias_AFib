#!/usr/bin/env nextflow

process TRAINING_VALIDATION {

    """
    Description:
    ----------------------------------------
    

    Inputs:
        - meta: Metadata
        - input: Path to input training dataset

    Outputs:
        - validated_json: Metadata and training_dataset_validation.json
        - execution_status: true if input is validated

    """

	input:
        tuple val(meta), path(input)

	output:
        tuple val(meta), path("${params.validation_result}"), emit: validated_json
        val(true),                                            emit: execution_status

	script:
    """
	python3 /app/training_dataset_validation.py -i ${input} -c ${meta.challenges_ids} -p ${meta.participant_id} -com ${meta.community_id}  -o ${params.validation_result}
	"""
}