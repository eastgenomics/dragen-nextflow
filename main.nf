nextflow.enable.dsl = 2

workflow {

    bam = Channel.fromPath(params.bam)
    ch_ref = Channel.fromPath(params.ref)
    bed = Channel.fromPath(params.target_bed)
    combined_counts = Channel.fromPath(params.combined_counts)
    population_b_allele_vcf = Channel.fromPath(params.population_b_allele_vcf)
    intermediate_dir = Channel.value(params.intermediate_dir)
    prefix = Channel.value(params.prefix)
    output_dir = Channel.value(params.output_dir)
    lic = Channel.value(params.lic)

    run_dragen(
        bam,
        ch_ref,
        bed,
        combined_counts,
        population_b_allele_vcf,
        intermediate_dir,
        prefix,
        output_dir,
        lic
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
    path target_bed
    path combined_counts
    path population_b_allele_vcf
    val intermediate_dir
    val prefix
    val output_dir
    val lic

    output:
    path("${params.output_dir}")

    script:
    """
    mkdir ref_data
    tar xvfz $ref_gz -C ref_data

    mkdir ${params.output_dir}
    mkdir ${params.intermediate_dir}

    /opt/edico/bin/dragen \\
        -r ref_data \\
        --tumor-bam-input ${bam} \\
        --enable-map-align false \\
        --enable-map-align-output true \\
        --enable-cnv true \\
        --enable-variant-caller false \\
        --cnv-enable-gcbias-correction false \\
        --vc-skip-germline-tagging true \\
        --cnv-target-bed ${target_bed} \\
        --cnv-combined-counts ${combined_counts} \\
        --cnv-population-b-allele-vcf ${population_b_allele_vcf} \\
        --intermediate-results-dir ${intermediate_dir} \\
        --output-file-prefix ${prefix} \\
        --output-directory ${output_dir} \\
        --max-base-quality 63 \\
        --lic-server ${lic}
    """
}
