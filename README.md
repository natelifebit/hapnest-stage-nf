# hapnest-stage-nf

Stages the publicly available HAPNEST synthetic UKB-like example dataset
([EBI BioStudies S-BSST936](https://www.ebi.ac.uk/biostudies/studies/S-BSST936),
600 individuals, ~6.8M variants across 22 chromosomes, synthetic — no real people)
into analysis-ready inputs for [genepi/nf-gwas](https://github.com/genepi/nf-gwas):

- `hapnest600.{bed,bim,fam}` — merged genome-wide PLINK fileset (REGENIE step 1)
- `hapnest600_assoc.bgen` — BGEN v1.2, 8-bit (REGENIE step 2 association input)
- `phenotype.txt` — `FID IID Y1 Y2 Y3` quantitative phenotypes

Run with no parameters. Downloads ~1.3 GB from EBI at runtime.
