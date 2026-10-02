nextflow.enable.dsl=2

/*
 * hapnest-stage-nf — stages the HAPNEST synthetic UKB-like example dataset
 * (EBI BioStudies S-BSST936: 600 individuals, ~6.8M variants, 22 chromosomes)
 * into analysis-ready inputs for nf-gwas:
 *   - hapnest600.{bed,bim,fam}   merged genome-wide PLINK fileset (REGENIE step 1)
 *   - hapnest600_assoc.bgen      BGEN v1.2 for association testing (REGENIE step 2)
 *   - phenotype.txt              FID IID Y1 Y2 Y3 (quantitative liabilities)
 */

params.base   = 'https://ftp.ebi.ac.uk/biostudies/fire/S-BSST/936/S-BSST936/Files/example'
params.outdir = 'results'

process MERGE_AND_EXPORT {
    container 'quay.io/biocontainers/plink2:2.0.0a.6.9--h9948957_0'
    publishDir params.outdir, mode: 'copy'
    cpus 4
    memory '14 GB'

    input:
    path genofiles
    path phenofiles

    output:
    path 'hapnest600.*'
    path 'hapnest600_assoc.*'
    path 'phenotype.txt'

    script:
    '''
    for c in $(seq 1 22); do echo synthetic_small_v1_chr-$c; done > merge.txt
    plink2 --pmerge-list merge.txt bfile --make-bed --out hapnest600 --memory 12000 --threads 4
    plink2 --bfile hapnest600 --export bgen-1.2 bits=8 --out hapnest600_assoc --memory 12000 --threads 4
    cut -f1 synthetic_small_v1.pheno1 > c0
    cut -f5 synthetic_small_v1.pheno1 > c1
    cut -f5 synthetic_small_v1.pheno2 > c2
    cut -f5 synthetic_small_v1.pheno3 > c3
    paste c0 c0 c1 c2 c3 | tail -n +2 > body.txt
    printf 'FID\\tIID\\tY1\\tY2\\tY3\\n' > phenotype.txt
    cat body.txt >> phenotype.txt
    rm -f c0 c1 c2 c3 body.txt merge.txt
    '''
}

workflow {
    geno = Channel.fromList(
        (1..22).collectMany { c -> ['bed','bim','fam'].collect { e -> "${params.base}/synthetic_small_v1_chr-${c}.${e}" } }
    ).map { file(it) }.collect()

    pheno = Channel.fromList(
        (1..3).collect { p -> "${params.base}/synthetic_small_v1.pheno${p}" }
    ).map { file(it) }.collect()

    MERGE_AND_EXPORT(geno, pheno)
}
