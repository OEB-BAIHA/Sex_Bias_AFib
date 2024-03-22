nextflow.enable.dsl=2

if (params.help) {
	
	    log.info"""
	    ==============================================
	    BAIHA proof of concept: Sex bias in atrial fibrillation detection : Model Output
	    Author: Claire Furtick
	    Barcelona Supercomputing Center. Spain. 2023
	    ==============================================
	    Usage:
	    Run the pipeline with default parameters:
	    nextflow run main.nf -profile docker

		Run locally:
		nextflow run main.nf -profile docker --input ../input_data/Nuubo_output.csv --participant_id Nuubo --challenge_ids model-output --consolidation_result ./consolidation_output --validation_result ./validation_output --assessment_result ./metrics_output --aggreg_dir ./benchmark_data --goldstandard_dir ../gold_standard/key.csv


	    Specifications for inputs:
		(provided by OpenEBench)
		--input			Training dataset to be assessed
		--participant_id        Name of the training dataset to be assessed
                --community_id          Name or OEB permanent ID for the benchmarking community
                --challenge_ids         Not sure we need this, hardcode for now as 'training_dataset'
                --aggreg_dir            Directory where performance metrics for other tools are stored (for consolidation with new results)
		--goldstandard_dir	Directory that contains the golden dataset with ground truths
		--public_ref_dir	Directory that contains one or more reference files used to validate input data. Ej: reference public databases

	    Specifications for outputs:
		(provided by OpenEBench)
                --assessment_results    The output directory where the results from the computed metrics step will be saved
		--outdir                The output directory where the final results will be saved (graphs and such)
                --statsdir              The output directory with nextflow statistics
                --otherdir              The output directory where custom results will be saved (no directory inside)
		--data_model_export_dir	All datasets generated during the workflow are merged into one JSON to be validated and pushed to Level 1
                --validation_result     File path where the validated (corrected/updated) participant dataset is written.

	    Flags:
                --help                  Display this message
	    """

	exit 1
} else {

	log.info """\
         ============================
         BAIHA BENCHMARKING PIPELINE
         ============================
         benchmarking community: ${params.community_id}
         challenge: ${params.challenge_ids}
         input directory: ${params.input}
         gold standard directory: ${params.goldstandard_dir}
         participant id: ${params.participant_id}
         other participant results directory: ${params.aggreg_dir}
         validation results directory: ${params.validation_result}
         metrics results directory: ${params.assessment_results}
         overall results directory: ${params.outdir}
         statistics results about nextflow run: ${params.statsdir}
         directory with community-specific results: ${params.otherdir}
         output for level 1 directory: ${params.data_model_export_dir}
         """

}

// Input
input_file = file(params.input)
tool_name = params.participant_id.replaceAll("\\s","_")
challenge_id = params.challenge_ids // In OEB, challenges_ids is an array, but in our case, it will always be one value
community_id = params.community_id
benchmark_data = Channel.fromPath(params.aggreg_dir, type: 'dir' )
gold_standard = file(params.goldstandard_dir)

// Output
validation_dir = file(params.validation_result, type: 'dir')
assessment_dir = file(params.assessment_results, type: 'dir')
//consolidation_dir = file(params.consolidation_result, type: 'dir')
results_dir = file(params.outdir, type: 'dir')
stats_dir = file(params.statsdir, type: 'dir')
//other_dir = file(params.otherdir, type: 'dir')
//data_model_export_dir = file(params.data_model_export_dir, type: 'dir')

// Output filenames
validation_filename = "${params.participant_id}_validation.json"
assessment_filename = "${params.participant_id}_assessment.json"
consolidation_filename = "${params.participant_id}_consolidation.json"
//assessment_filepath = file("${params.assessment_result}/${assessment_filename}", type: 'dir')


process validation {

	// validExitStatus 0,1
	tag "Validating training dataset format"

	publishDir validation_dir,
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> validation_filename }

	input:
	file input_file
	val tool_name
	val community_id
	val challenge_id
	val validation_filename

	output:
	val task.exitStatus, emit: validation_status
	path validation_filename, emit: vf

	script:
	"""
	python3 /app/model_output_validation.py -i $input_file -c $challenge_id -p $tool_name -com $community_id -o $validation_filename
	"""
}

process compute_metrics {

	tag "Computing metrics for training dataset"

	publishDir assessment_dir,
	mode: 'copy',
	overwrite: false,
	saveAs: { filename -> assessment_filename }

	input:
	val validation_status
	file input_file 
	file gold_standard
	val tool_name
	val community_id
	val challenge_id
	val assessment_filename

	output:
	path assessment_filename, emit: af
	
	when:
	validation_status == 0

	script:
	"""
	echo $input_file
	python /app/model_output_test.py -i $input_file -p $tool_name -com $community_id -c $challenge_id -o $assessment_filename -m $gold_standard
	"""
}

//assessments needs to be a path but validation_file is a val, not sure why, maybe something to do with the aggregation python script?
process consolidation {

	tag "Performing benchmark assessment and building plots"

	//TODO: Make sure exports of results are correct
	publishDir results_dir

	// publishDir consolidation_dir,
	// pattern: "consolidated_result.json",
	// mode: 'copy',
	// overwrite: false,
	// saveAs: { filename -> consolidation_filename }

	input:
	path benchmark_data
	path assessments
	val validations
	val challenge_id
	val offline
	//path consolidation_dir
	
	output:
	path results_dir
	path "consolidated_result.json"

	script:
	"""
	python /app/aggregation.py -b $benchmark_data -a $assessments -o results_dir --offline $offline
	python /app/merge_data_model_files.py -v $validations -m $assessments -c $challenge_id -a results_dir -o consolidated_result.json

	"""
}


workflow {
	validation(input_file, tool_name, community_id, challenge_id, validation_filename)
	validations = validation.out.vf.collect()
	compute_metrics(validation.out.validation_status, input_file, gold_standard, tool_name, community_id, challenge_id, assessment_filename)
	assessments = compute_metrics.out.af.collect()
    //consolidation(benchmark_data, assessments, validations, challenge_id, 1, consolidation_dir)
	consolidation(benchmark_data, assessments, validations, challenge_id, 1)
}

workflow.onComplete { 
	println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}
