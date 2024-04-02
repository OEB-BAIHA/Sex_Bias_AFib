#!/usr/bin/env nextflow

process MODEL_COMPUTE_METRICS{

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
        tuple val(meta), path(validated_input), path(gold_standard)
        val( validation_status )

    output:
        tuple val(meta), path("${params.assessment_results}"), emit: assess_json

    when:
        validation_status == true

    script:
    """
    python3 /app/model_output_test.py -i ${validated_input} -p ${meta.participant_id} -com ${meta.community_id} -c ${meta.challenges_ids} -o "${params.assessment_results}" -m "${gold_standard}"
    """
}



