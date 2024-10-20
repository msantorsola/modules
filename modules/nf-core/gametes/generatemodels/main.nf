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
    // dictionary to convert general parameters from csv into gametes-specific parameters, for creating model file

    //key_yml="output_key_values.yml"
    declare -A values

    // split by :, remove spaces

    IFS=":" read -r key value

    // associate gametes parameters with the general parameters in the yam, and then the value
    case \$key in
        "--randomSeed") values["r"]="\$value" ;;
        "--attributeAlleleFrequency") values["a"]="\$value" ;;
        "--prevalence") values["p"]="\$value" ;;
        "--heritability") values["h"]="\$value" ;;
        "--useOddsRatio") values["d"]="\$value" ;;
        "--quantile_counts") values["q"]="\$value" ;;
        "--population_counts") values["pp"]="\$value" ;;
        "--trycount") values["t"]="\$value" ;;
        "--proportion") values["f"]="\$value" ;;
    esac
    done < $key_yml

    gametes -M \
    "--h \${values[h]} --p \${values[p]} --a \${values[a]} --f \${values[f]} --d \${values[d]} -o \$prefix\" \
    -p \${values[pp]} -q \${values[q]} -t \${values[t]} -r \${values[r]}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametes: $VERSION
    END_VERSIONS
    """

}


