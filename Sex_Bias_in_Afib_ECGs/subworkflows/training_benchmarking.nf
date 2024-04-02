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

    include { TRAINING_VALIDATION      } from '../modules/training/validation'
    include { TRAINING_COMPUTE_METRICS } from '../modules/training/metrics'
    include { TRAINING_CONSOLIDATION   } from '../modules/training/consolidation'
    
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BENCHMARKING_TRAINING {

    take:
        input 
    
    main:

        // Perform training validation
        TRAINING_VALIDATION (input)
        validations = TRAINING_VALIDATION.out.validated_json.collect()
        
        // Compute metrics for training
        TRAINING_COMPUTE_METRICS (input, TRAINING_VALIDATION.out.execution_status)
        assessment = TRAINING_COMPUTE_METRICS.out.assess_json.collect()

        // Consolidate validation results and assessment
        TRAINING_CONSOLIDATION (validations, assessment, assess_dir)


}