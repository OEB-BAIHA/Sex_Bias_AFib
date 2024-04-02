process TRAINING_COMPUTE_METRICS {

    """
    Description:
    ----------------------------------------
    

    Inputs:
        - meta: Metadata 
        - validated_input: Path to training_dataset_validation.json
        - validation_status: true if input is validated

    Outputs:
        - assess_json: Metadata and training_dataset_assessment.json

    """

	input:
        tuple val(meta), path(validated_input)
        val( validation_status )

	output:
        tuple val(meta), path("${params.assessment_results}"), emit: assess_json
	
    when:
	validation_status == true

	script:
	"""
	python3 /app/training_dataset_test.py -i ${validated_input} -p ${meta.participant_id} -com ${meta.community_id} -c ${meta.challenges_ids} -o ${params.assessment_results}
	"""
}