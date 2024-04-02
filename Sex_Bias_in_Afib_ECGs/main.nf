#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/rnaseq
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github :    https://github.com/OEB-BAIHA/Sex_Bias_AFib
    OpenEBench: https://openebench.bsc.es/ 
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (params.help) {
	
	    log.info"""
	    ==============================================
	    BAIHA proof of concept: Sex bias in atrial fibrillation detection
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
				--input					File path dataset to be assessed
                --public_ref_dir        Directory that contains one or more reference files used to validate input data. Ej: reference public databases
				--participant_id        Name of the training dataset to be assessed
                --goldstandard_dir		Directory that contains the golden dataset with ground truths 
                --challenge_ids         Dataset types for which the benchmark has to be performed
                --assess_dir            Directory where performance metrics for other participants are stored (for consolidation with new results)
				--community_id          Name or OEB permanent ID for the benchmarking community

	    Specifications for outputs:
            (provided by OpenEBench)
                --validation_result     File path where the validated (corrected/updated) participant dataset is written.
                --assessment_results    File path where where the computed metrics of participant is written.
				--outdir                The output directory where the final results will be saved (graphs and such)
                --statsdir              The output directory with nextflow statistics
                --otherdir              The output directory where custom results will be saved (no directory inside)
				--data_model_export_dir	All datasets generated during the workflow are merged into one JSON to be validated and pushed to Level 1

	    Flags:
                --help                  Display this message
	    """

	exit 1

} else {

	log.info """\
        ============================
        BAIHA BENCHMARKING PIPELINE
        ============================
        Input: ${params.input}
        Public reference directory: ${params.public_ref_dir}
        Participant id: ${params.participant_id}
        Gold standard directory: ${params.goldstandard_dir}
        Challenge ids: ${params.challenges_ids}
        Benchmark data: ${params.assess_dir}
        Benchmarking community: ${params.community_id}
        Consolidated benchmark results directory: ${params.outdir}
        Statistics results about nextflow run: ${params.statsdir}
        Benchmarking data model file location:  ${params.otherdir}
        Validation results directory: ${params.validation_result}
        assessment results directory: ${params.assessment_results}
        Directory with community-specific results: ${params.data_model_export_dir}
        """

}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BAIHA } from './workflows/baiha'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    BAIHA ()
}
