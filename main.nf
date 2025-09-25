nextflow.enable.dsl = 2

workflow {

    bam = Channel.fromPath(params.bam)
    ch_ref = Channel.fromPath(params.ref)

    run_dragen(
        bam,
        ch_ref
    )
}

process run_dragen {

    label 'dragen'

    secret 'DRAGEN_USERNAME'
    secret 'DRAGEN_PASSWORD'

    publishDir "${params.output_dir}", mode: 'copy'
    
    input:
    path bam
    path ref_gz

    output:
    path("${params.output_dir}")

    script:
    """
    mkdir ref_data
    tar xvfz $ref_gz -C ref_data

    mkdir -p ${params.prefix}
    mkdir -p ${params.output_dir}
    mkdir -p ${params.intermediate_dir}

    /opt/edico/bin/dragen \\
        -r ref_data \\
        --tumor-bam-input ${bam} \\
        --enable-map-align false \\
        --enable-map-align-output true \\
        --enable-cnv true \\
        --enable-variant-caller false \\
        --cnv-enable-gcbias-correction false \\
        --vc-skip-germline-tagging true \\
        --cnv-target-bed ${params.target_bed} \\
        --cnv-combined-counts ${params.combined_counts} \\
        --cnv-population-b-allele-vcf ${params.population_b_allele_vcf} \\
        --intermediate-results-dir ${params.intermediate_dir} \\
        --output-file-prefix ${params.prefix} \\
        --output-directory ${params.output_dir} \\
        --lic-server ${params.lic}
    """
}
