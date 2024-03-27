nextflow.enable.dsl=2

if (params.help) {
	
	    log.info"""
	    ==============================================
	    BAIHA proof of concept: Sex bias in atrial fibrillation detection : Training Dataset
	    Author: Claire Furtick
	    Barcelona Supercomputing Center. Spain. 2023
	    ==============================================

        Run locally:
        nextflow run main.nf -profile docker 

        Specifications for inputs:
                --input					Training dataset to be assessed
                --participant_id        Name of the training dataset to be assessed
                --community_id          Name or OEB permanent ID for the benchmarking community
                --challenges_ids        Not sure we need this, hardcode for now as 'training_dataset'
                --assess_dir            Directory where performance metrics for other tools are stored
                --goldstandard_dir		Directory that contains the golden dataset with ground truths
 
        Specifications for outputs:
                --validation_result     The output path where the results from validation step will be saved
                --assessment_results    The output path where the results from the computed metrics step will be saved
                --consolidation_result  The output path where the output from consolidation step will be saved
                --outdir                The output directory where the final results will be saved (graphs and such)
                --statsdir              The output directory with nextflow statistics
                --otherdir              The output directory where custom results will be saved (no directory inside)
                --data_model_export_dir	All datasets generated during the workflow are merged into one JSON to be validated and pushed to Level 1
                --offline               

	    Flags:
                --help                  Display this message
	    """

	exit 1
} else {

	log.info """\
         ============================
         BAIHA BENCHMARKING PIPELINE
         ============================
         community name: ${params.community_id}
         challenge: ${params.challenges_ids}
         input file: ${params.input}
         gold standard directory: ${params.goldstandard_dir}
         participant id: ${params.participant_id}
         other participant results directory: ${params.assess_dir}
         validation results path: ${params.validation_result}
         metrics results path: ${params.assessment_results}
         output directory: ${params.outdir}
         statistics results about nextflow run: ${params.statsdir}
         community-specific directory: ${params.otherdir}
         consolidation results path: ${params.data_model_export_dir}
         offline: ${params.offline}
         """

}

// Input (setting these to files and directories that already exist)
input_file = file(params.input)
participant_id = params.participant_id.replaceAll("\\s","_")
challenge_id = params.challenges_ids // In OEB, challenges_ids is an array, but in our case, it will be one value (either training_dataset or model_output)
community_id = params.community_id
other_participant_data = Channel.fromPath(params.assess_dir, type: 'dir' )
gold_standard_dir = Channel.fromPath(params.goldstandard_dir, type: 'dir' )

// Output (setting these to names of files and directories that you want to be created)
output_dir = file(params.outdir, type: 'dir')
stats_dir = file(params.statsdir, type: 'dir')
validation_filename = file(params.validation_result)            // filepath including filename of where validation output should be saved
assessment_filename = file(params.assessment_results)           // filepath including filename of where metrics (assessment) output should be saved
consolidation_filename = file(params.data_model_export_dir)     // filepath including filename of where consolidation output should be saved
other_dir = file(params.otherdir, type: 'dir')
offline = params.offline


process dataset_validation {

    tag "Validating training dataset format"

    publishDir validation_filename.parent,
    mode: 'copy',
    overwrite: false,
    saveAs: { filename -> validation_filename.name }

    input:
    file input_file
    val participant_id
    val community_id
    val challenge_id

    output:
    val task.exitStatus, emit: validation_status
    path validation_file, emit: validation_file

    script:
    """
    python3 /app/training_dataset_validation.py -i $input_file -c $challenge_id -p $participant_id -com $community_id -o validation_file
    """
}

process dataset_compute_metrics {

    tag "Computing metrics for training dataset"

    publishDir assessment_filename.parent,
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> assessment_filename.name }

    input:
    val validation_status
    file input_file 
    val participant_id
    val community_id
    val challenge_id

    output:
    path "${input_file.baseName}.json", emit: ass_json
    
    when:
    validation_status == 0

    script:
    """
    python /app/training_dataset_test.py -i $input_file -p $participant_id -com $community_id -c $challenge_id -o "${input_file.baseName}.json"
    """
}

process dataset_consolidation {

    tag "Performing benchmark assessment and building plots"

    // publish full results from consolidation docker to community (other) directory under the folder name {participant_id}_results/{challenge_id}/
    publishDir other_dir, 
	pattern: "output_dir/${challenge_id}", 
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> "${participant_id}_results / ${challenge_id}" }

	// publish consolidated_results.json file to the correct folder where OEB is expecting
    publishDir consolidation_filename.parent,
    pattern: "consolidated_result.json",
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> consolidation_filename.name }

    input:
    path other_participant_data
    path ass_json
    val validation_file
    val challenge_id
    val offline
    
    output:
    path "output_dir/${challenge_id}"
    path "consolidated_result.json"

    script:
    """
    python /app/aggregation.py -b $other_participant_data -a $ass_json -o output_dir --offline $offline
    python /app/merge_data_model_files.py -v $validation_file -m $ass_json -c $challenge_id -a output_dir -o consolidated_result.json

    """
}

process output_validation {

    tag "Validating model output format"

    publishDir validation_filename.parent,
    mode: 'copy',
    overwrite: false,
    saveAs: { filename -> validation_filename.name }

    input:
    file input_file
    val participant_id
    val community_id
    val challenge_id

    output:
    val task.exitStatus, emit: validation_status
    path validation_file, emit: validation_file

    script:
    """
    python3 /app/model_output_validation.py -i $input_file -c $challenge_id -p $participant_id -com $community_id -o validation_file
    """
}

process output_compute_metrics {

    tag "Computing metrics for model output"

    publishDir assessment_filename.parent,
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> assessment_filename.name }

    input:
    val validation_status
    file input_file 
    path gold_standard_dir
    val participant_id
    val community_id
    val challenge_id

    output:
    path "${input_file.baseName}.json", emit: ass_json
    
    when:
    validation_status == 0

    script:
    """
    python /app/model_output_test.py -i $input_file -p $participant_id -com $community_id -c $challenge_id -o "${input_file.baseName}.json" -m "${gold_standard_dir}/${challenge_id}_standard.csv"
    """
}

process output_consolidation {

    tag "Performing benchmark assessment and building plots"

    // publish full results from consolidation docker to community (other) directory under the folder name {participant_id}_results/{challenge_id}/
    publishDir other_dir, 
	pattern: "output_dir/${challenge_id}", 
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> "${participant_id}_results / ${challenge_id}" } 

    // publish consolidated_results.json file to the correct folder where OEB is expecting
    publishDir consolidation_filename.parent,
    pattern: "consolidated_result.json",
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> consolidation_filename.name }

    input:
    path other_participant_data
    path ass_json
    val validation_file
    val challenge_id
    val offline
    
    output:
    path "output_dir/${challenge_id}"
    path "consolidated_result.json"

    script:
    """
    python /app/aggregation.py -b $other_participant_data -a $ass_json -o output_dir --offline $offline
    python /app/merge_data_model_files.py -v $validation_file -m $ass_json -c $challenge_id -a output_dir -o consolidated_result.json

    """
}

workflow {

    if ( challenge_id == 'training_dataset' ) {
        dataset_validation(input_file, participant_id, community_id, challenge_id)
        validations = dataset_validation.out.validation_file.collect()
        dataset_compute_metrics(dataset_validation.out.validation_status, input_file, participant_id, community_id, challenge_id)
        assessments = dataset_compute_metrics.out.ass_json.collect()
        dataset_consolidation(other_participant_data, assessments, validations, challenge_id, 1)
    }

    else if ( challenge_id == 'model_output' ) {
        output_validation(input_file, participant_id, community_id, challenge_id)
        validations = output_validation.out.validation_file.collect()
        output_compute_metrics(output_validation.out.validation_status, input_file, gold_standard_dir, participant_id, community_id, challenge_id)
        assessments = output_compute_metrics.out.ass_json.collect()
        output_consolidation(other_participant_data, assessments, validations, challenge_id, offline)
    }

    else {
        throw PermissionDeniedException("Invalid challenge ID: ${challenge_id}")
    }
}

workflow.onComplete { 
    println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}