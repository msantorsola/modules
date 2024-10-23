process GAMETES_GENERATEMODELS {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gametes:2.1--py310h7cba7a3_0':
        'biocontainers/gametes:2.1--py310h7cba7a3_0' }"

    input:
    tuple val(meta), path(key_yml)

    output:
    tuple val(meta), path("*_EDM_Scores.txt"),       optional: true, emit: edm_scores
    tuple val(meta), path("*_OddsRatio_Scores.txt"), optional: true, emit: oddsratio_scores
    tuple val(meta), path("*_Models.txt")             ,              emit: models
    path "versions.yml"                               ,              emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    //def args = task.ext.args ?: ''
    //def args2 = task.ext.args2 ?: ''
    prefix = task.ext.prefix ?: "$meta.id"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.


    """
    declare -A gametespar=(
        [r]="--randomSeed"
        [a]="--attributeAlleleFrequency"
        [p]="--prevalence"
        [h]="--heritability"
        [d]="--useOddsRatio"
        [q]="--quantile_counts"
        [z]="--population_counts"
        [t]="--trycount"
        [f]="--proportion"
        )


    declare -A args=()

    while IFS=":" read -r params value; do
        params=\$(echo "\$key" | tr -d '"' | xargs)
        value=\$(echo "\$value" | tr -d '"' | xargs)
        case "\$params" in
            "--randomSeed") args["-r"]="\$value" ;;
            "--attributeAlleleFrequency") args["-a"]="\$value" ;;
            "--prevalence") args["-p"]="\$value" ;;
            "--heritability") args["-h"]="\$value" ;;
            "--useOddsRatio") args["-d"]="\$value" ;;
            "--quantile_counts") args["-q"]="\$value" ;;
            "--population_counts") args["-z"]="\$value" ;;
            "--trycount") args["-t"]="\$value" ;;
            "--proportion") args["-f"]="\$value" ;;
        esac
    done <  $key_yml


    eval gametes -M "-h "\${args[h]:-""}" -p "\${args[p]:-""}" -a "\${args[a]:-""}" -f "\${args[f]:-""}" -d "\${args[d]:-""}" -o $prefix" --population_counts "\${args["z"]:-""}" -q "\${args[q]:-""}" -t "\${args[t]:-""}" -r "\${args[r]:-""}"


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametes: $VERSION
    END_VERSIONS
    """

}


