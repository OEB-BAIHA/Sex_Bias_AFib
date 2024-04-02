#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LOAD MAIN PATHS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

    assess_dir = Channel.fromPath( params.assess_dir, type: 'dir', checkIfExists: true ) 

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

    include { MODEL_VALIDATION      } from '../modules/model/validation'
    include { MODEL_COMPUTE_METRICS } from '../modules/model/metrics'
    include { MODEL_CONSOLIDATION   } from '../modules/model/consolidaton'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BENCHMARKING_MODEL {

    take:
        input
        gold_standard
    
    main:

        // Perform training validation
        MODEL_VALIDATION ( input )
        validations = MODEL_VALIDATION.out.validated_json.collect()


        // input_with_gold_standard: [ meta, input, gold_standard ]
        input | combine(gold_standard)
              | map { metainput, input, metags, gold_standard ->
                if ( metainput.challenges_ids == metags.challenges_ids ) {
                        return [ metainput, input, gold_standard ]
                    }  
              }
              | set { input_with_gold_standard }
        
        
        // Compute metrics for training
        MODEL_COMPUTE_METRICS ( input_with_gold_standard, MODEL_VALIDATION.out.execution_status )
        assessment = MODEL_COMPUTE_METRICS.out.assess_json.collect()

        
        // Consolidate validation results and assessment
        MODEL_CONSOLIDATION ( validations, assessment, assess_dir )
}