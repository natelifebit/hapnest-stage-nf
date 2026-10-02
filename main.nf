nextflow.enable.dsl=2

/*
 * hapnest-stage-nf — lands the pre-staged HAPNEST synthetic UKB-like example
 * dataset (EBI BioStudies S-BSST936; 600 synthetic individuals, ~6.8M variants)
 * into workspace storage, ready for genepi/nf-gwas:
 *   - hapnest600.{bed,bim,fam}        merged genome-wide PLINK fileset (REGENIE step 1)
 *   - hapnest600_assoc.bgen/.sample   BGEN v1.2 association input (REGENIE step 2)
 *   - phenotype.txt                   FID IID Y1 Y2 Y3
 * Files are fetched from this repo's v1 release assets (built by the
 * "Stage HAPNEST example dataset" GitHub Action from the public EBI source).
 */

params.base   = 'https://github.com/natelifebit/hapnest-stage-nf/releases/download/v1'
params.outdir = 'results'

process FETCH {
    container 'quay.io/biocontainers/plink2:2.0.0a.6.9--h9948957_0'
    publishDir params.outdir, mode: 'copy'
    cpus 2
    memory '4 GB'

    input:
    path staged

    output:
    path '*', includeInputs: true

    script:
    '''
    ls -la
    '''
}

workflow {
    files = Channel.fromList([
        'hapnest600.bed', 'hapnest600.bim', 'hapnest600.fam',
        'hapnest600_assoc.bgen', 'hapnest600_assoc.sample',
        'phenotype.txt'
    ].collect { "${params.base}/${it}" }).map { file(it) }.collect()

    FETCH(files)
}
