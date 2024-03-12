
process GAMETES_GENERATEDATASETS {
    tag "$meta.id"
    label 'process_medium'

    
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gametes:2.1--py310h7cba7a3_0':
        'biocontainers/gametes:2.1--py310h7cba7a3_0' }"

    
    input:
    tuple val(meta), path(model)
    val dataset
    val total_attribute_count
    val case_count
    val control_count
    val replicate_count   

    output:
    tuple val(meta), path("${prefix}") , emit: results
    path "versions.yml"           , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def seed = task.ext.seed ?: "${meta.seed}"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    gametes \\
    	--randomSeed $seed \\
	--modelInputFile $model \\
	--dataset \\
        "--alleleFrequencyMin $allele_frequency_min \\
 	--alleleFrequencyMax $allele_frequency_max \\
        --totalAttributeCount $total_attribute_count \\
        --caseCount $case_count \\ 
        --controlCount $control_count \\
	--replicateCount $replicate_count \\
	-o $prefix"


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametes: $VERSION
    END_VERSIONS
    """    
}
