process GAMETES_GENERATEMODELS {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gametes:2.1--py310h7cba7a3_0':
        'biocontainers/gametes:2.1--py310h7cba7a3_0' }"

    input:
    tuple val(meta), val(heritability)

    output:
    tuple val(meta), path("_EDM_Scores.txt"), emit: edm_scores, optional: true
    tuple val(meta), path("*_OddsRatio_Scores.txt"), emit: oddsratio_scores, optional: true
    tuple val(meta), path("*_Models.txt"), emit: models
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    gametes \\
        -M  "\\
        -o $prefix \\
        $args"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametes: $VERSION
    END_VERSIONS
    """
    
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    
    """
    touch ${prefix}_EDM_Scores.txt
    touch ${prefix}_OddsRatio_Scores.txt
    touch ${prefix}_Models.txt


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
       gametes: $VERSION
    END_VERSIONS
    """

}

