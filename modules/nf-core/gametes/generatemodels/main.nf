process GAMETES_GENERATEMODELS {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gametes:2.1--py310h7cba7a3_0':
        'biocontainers/gametes:2.1--py310h7cba7a3_0' }"

    input:
    tuple val(meta)

    output:
    tuple val(meta), path("*_EDM_Scores.txt"),       optional: true, emit: edm_scores
    tuple val(meta), path("*_OddsRatio_Scores.txt"), optional: true, emit: oddsratio_scores
    tuple val(meta), path("*_Models.txt")             ,              emit: models
    path "versions.yml"                               ,              emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    prefix = task.ext.prefix ?: "$meta.id"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    gametes \\
        -M  "\\
        -o $prefix \\
        $args" \\
        $args2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametes: $VERSION
    END_VERSIONS
    """

}


