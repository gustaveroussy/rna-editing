"""
##########################################################################
These rules make the editing analysis by SPRINT
##########################################################################
"""

"""
This rule makes the SPRINT index for BWA
"""
REF = config["reference"]
if REF == "hg38": REI_FA = "/bin/AEI/RNAEditingIndexer/Resources/Genomes/HomoSapiens/ucscHg38Genome.fa"
if REF == "hg19": REI_FA = "/bin/AEI/RNAEditingIndexer/Resources/Genomes/HomoSapiens/ucscHg19Genome.fa"
if REF == "mm10": REI_FA = "/bin/AEI/RNAEditingIndexer/Resources/Genomes/MusMusculus/ucscMm10Genome.fa"
if REF == "mm9": REI_FA = "/bin/AEI/RNAEditingIndexer/Resources/Genomes/MusMusculus/ucscMM9Genome.fa"

rule SPRINT_index:
    output:
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".refGene.gtf"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.amb"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.ann"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.bwt"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.amb"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.ann"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.bwt"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.pac"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.sa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.amb"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.ann"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.bwt"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.pac"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.sa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.pac"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.sa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.amb"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.ann"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.bwt"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.loc"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.amb"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.ann"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.bwt"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.pac"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.sa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.amb"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.ann"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.bwt"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.pac"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.sa"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.pac"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.sa")
    threads:
        8
    resources:
        mem_mb = (lambda wildcards, attempt: attempt * 30720),
        time_min = (lambda wildcards, attempt: attempt * 1440)
    shell:
        """
        #wget http://hgdownload.soe.ucsc.edu/goldenPath/{REF}/bigZips/{REF}.fa.gz && gunzip {REF}.fa.gz 
        singularity exec --no-home -B{OUTPUT_DIR} {PIPELINE_DIR}/envs/singularity/RNAEditingIndexer.simg \
        cp {REI_FA} {OUTPUT_DIR}/SPRINT/index/{REF}.fa
        
        cd {OUTPUT_DIR}/SPRINT/index/
        WGET_GTF='http://hgdownload.soe.ucsc.edu/goldenPath/{REF}/bigZips/genes/{REF}.refGene.gtf.gz'
        wget $WGET_GTF
        gunzip {REF}.refGene.gtf.gz

        singularity exec --no-home -B{OUTPUT_DIR} {PIPELINE_DIR}/envs/singularity/SPRINT.simg \
        sprint prepare \
        -t {OUTPUT_DIR}/SPRINT/index/{REF}.refGene.gtf \
        {OUTPUT_DIR}/SPRINT/index/{REF}.fa \
        bwa

        """


"""
This rule makes the SPRINT analysis
"""

rule SPRINT:
    input:
        R1_fq = os.path.normpath(OUTPUT_DIR + "/fastp/trimmed/{sample_name}_R1.fastq.gz"),
        R2_fq = os.path.normpath(OUTPUT_DIR + "/fastp/trimmed/{sample_name}_R2.fastq.gz"),
        reference_fa = os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa"),
        ref_files =[
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".refGene.gtf"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.amb"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.ann"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.bwt"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.amb"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.ann"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.bwt"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.pac"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskAG.fa.sa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.amb"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.ann"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.bwt"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.pac"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.mskTC.fa.sa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.pac"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.sa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.amb"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.ann"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.bwt"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.loc"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.amb"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.ann"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.bwt"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.pac"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskAG.fa.sa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.amb"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.ann"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.bwt"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.pac"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.mskTC.fa.sa"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.pac"),
            os.path.normpath(OUTPUT_DIR + "/SPRINT/index/" + REF + ".fa.trans.fa.sa")
        ]
    output:
        bam=os.path.normpath(OUTPUT_DIR + "/SPRINT/{sample_name}/{sample_name}.bam"),
        PARAMETER=os.path.normpath(OUTPUT_DIR + "/SPRINT/{sample_name}/PARAMETER.txt"),
        SPRINT_identified_all=os.path.normpath(OUTPUT_DIR + "/SPRINT/{sample_name}/SPRINT_identified_all.res"),
        SPRINT_identified_hyper=os.path.normpath(OUTPUT_DIR + "/SPRINT/{sample_name}/SPRINT_identified_hyper.res"),
        SPRINT_identified_regular=os.path.normpath(OUTPUT_DIR + "/SPRINT/{sample_name}/SPRINT_identified_regular.res")
    threads:
        8
    resources:
        mem_mb = (lambda wildcards, attempt: attempt * 30720),
        time_min = (lambda wildcards, attempt: attempt * 2880)
    params:
        path_ref = OUTPUT_DIR + "/SPRINT/index/"
    shell:
        """
        singularity exec --no-home -B{OUTPUT_DIR},{params.path_ref} {PIPELINE_DIR}/envs/singularity/SPRINT.simg \
        sprint main \
        -1 {input.R1_fq} -2 {input.R2_fq} \
        -p {threads} \
        {input.reference_fa}
        {OUTPUT_DIR}/SPRINT/ \
        bwa samtools

        """


"""
This rule makes the SPRINT graphs and table ### to do: finish
"""
rule SPRINT_summary:
    input:
        expand(os.path.normpath(OUTPUT_DIR + "/SPRINT/{sample_name}/SPRINT_identified_hyper.res"),sample_name=SAMPLE_NAME)
    output:
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Number_of_all_edition_by_sample.png"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Number_of_each_edition_by_sample_log_y_scale.png"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Number_of_each_edition_by_sample.png"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Number_of_reads_supporting_the_edition_for_each_sample.png"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Percentages_of_reads_supporting_the_edition_for_each_sample.png"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Summary_table_counts_SPRINT_by_strand.tsv"),
        os.path.normpath(OUTPUT_DIR + "/SPRINT/Summary_table_counts_SPRINT.tsv")
    threads:
        1
    resources:
        mem_mb = (lambda wildcards, attempt: attempt * 5000),
        time_min = (lambda wildcards, attempt: attempt * 60)
    params:
        samples_order_for_ggplot=config["samples_order_for_ggplot"]
    shell:
        """
        singularity exec --no-home -B{PIPELINE_DIR},{OUTPUT_DIR} {PIPELINE_DIR}/envs/singularity/R_graphs.simg \
        RScript {PIPELINE_DIR}/script/SPRINT_summary_results.R --SPRINT_path {OUTPUT_DIR}/SPRINT/ --samples_order_for_ggplot {params.samples_order_for_ggplot}

        """