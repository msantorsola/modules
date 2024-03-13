#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GAMETES_GENERATEDATASETS } from '../../../../../modules/nf-core/gametes/generatedatasets/main.nf'

workflow test_gametes_generatedatasets {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    GAMETES_GENERATEDATASETS ( input )
}
