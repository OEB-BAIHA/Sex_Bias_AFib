#!/usr/bin/env nextflow

process MODEL_VALIDATION {

    """
    Description:
    ----------------------------------------
    

    Inputs:
        - validated_meta, assess_meta: Metadata 
        - validated_json: Path to training_dataset_validation.json
        - assess_json: Path to training_dataset_assessment.json
        - assess_dir: Paths to other_participant_data

    Outputs:
        - consolidated_json: Metadata and training_dataset_consolidation.json

    """

	input:
	    tuple val(meta), path(input)

	output:
        tuple val(meta), path("${params.validation_result}"), emit: validated_json
        val(true),                                            emit: execution_status

	script:
	"""
	python3 /app/model_output_validation.py -i ${input} -c ${meta.challenges_ids} -p ${meta.participant_id} -com ${meta.community_id}  -o ${params.validation_result}
	"""
}