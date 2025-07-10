nextflow.enable.dsl = 2

workflow {

    ch_fastq1 = Channel.fromPath(params.fastq1)
    ch_fastq2 = Channel.fromPath(params.fastq2)
    ch_ref = Channel.fromPath(params.ref)

    run_dragen(
        ch_fastq1,
        ch_fastq2,
        ch_ref
    )
}

process run_dragen {

    tag "${params.rgsm}"
    publishDir "${params.output_dir}", mode: 'copy'
    
    input:
    path fastq1
    path fastq2
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
        --fastq-file1 ${fastq1} \\
        --fastq-file2 ${fastq2} \\
        --RGID ${params.rgid} \\
        --RGSM ${params.rgsm} \\
        --enable-map-align true \\
        --enable-map-align-output true \\
        --enable-duplicate-marking true \\
        --enable-variant-caller true \\
        --intermediate-results-dir ${params.intermediate_dir} \\
        --output-file-prefix ${params.prefix} \\
        --output-directory ${params.output_dir}
    """
}
