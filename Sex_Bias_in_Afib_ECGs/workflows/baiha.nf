#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUTS CHANNELS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

    // BASE PARAMETERS
    
    // Input file

    ch_input = Channel.fromPath( params.input, checkIfExists: true ) 
                | map { input -> 

                    // metadata
                    meta = [ 
                        'challenges_ids': params.challenges_ids, 
                        'community_id': params.community_id, 
                        'participant_id': params.participant_id,
                        'offline_execution': params.offline
                    ]
                    return [ meta, input ]
                }

    ch_input | view { meta, input -> "[ SUCCESS: Loading File ] Input file $input.name for $meta.challenges_ids challenge" }


    // Gold Standard file

    ch_goldstandard = Channel.fromPath( "${params.goldstandard_dir}/*", checkIfExists: true ) 
                        | map { gold_standards -> 

                            // metadata
                            gsmeta = [ 
                                'community_id': params.community_id, 
                                'participant_id': params.participant_id,
                            ]

                            // Identify challenge
                            if (gold_standards.name.contains("training_dataset")){
                                return [ gsmeta + ['challenges_ids': "training_dataset"], gold_standards ] 
                            }

                            if (gold_standards.name.contains("model_output")){
                                return [ gsmeta + ['challenges_ids': "model_output"], gold_standards ] 
                            }                        
                        }

    ch_goldstandard | view { meta, goldstandard -> "[ SUCCESS: Loading File ] Input file $goldstandard.name for $meta.challenges_ids challenge" }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

    // SUBWORKFLOWS
    include { BENCHMARKING_TRAINING } from '../subworkflows/training_benchmarking'
    include { BENCHMARKING_MODEL    } from '../subworkflows/model_benchmarking'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BAIHA { 
    
    // Execution: training 

    if ( params.challenges_ids.contains("training_dataset") ){
        BENCHMARKING_TRAINING ( ch_input )
    }


    // Execution: model 

    if ( params.challenges_ids.contains("model_output") ){
        BENCHMARKING_MODEL ( ch_input, ch_goldstandard )
    }

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {

    println ( workflow.success ? "Done!" : "Oops .. something went wrong" )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/