# bigr_rna_editing
This pipeline uses SPRINT and RNAEditingIndexer to identify editing events from paired-end RNA-seq data.

## Installation
The pipeline is already installed on the Flamingo cluster of Gustave Roussy.  
It is localized here: /mnt/beegfs/pipelines/bigr_rna_editing/<version>

## Using
You need to make 2 files: a design file and a configuration file.   
### Configuration file
- **design**: absolute path to your design.csv file.
- **output_dir**: absolute path to the output directory where results will be saved.
- **reference**: the reference to use for the alignment and the idetification of editing events. Possible choices are hg19, hg38, mm10 or mm9. The reference will be downloaded from the UCSC web site.
- **samples_order_for_ggplot**: the order of samples for the x axis of graphs (you can order samples by condition for example). Default is alphabetical order.
- **SPRINT_extra**: extra parameters for "SPRINT main" command.
- **RNAEditingIndexer_extra**: extra parameters for "RNAEditingIndexer" command.

Example:
```
design: "/mnt/beegfs/scratch/m_aglave/Editing_analysis/script/design.csv"
output_dir: "/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_output/"
reference: "hg38"
samples_order_for_ggplot: "S1_patient,S3_patient,S2_patient"
SPRINT_extra: ""
RNAEditingIndexer_extra: ""
```
### Design file
It must be a comma separated file (.csv where comma is ",") with 3 columns:
- **sample_id**: the sample name of you sample (it could be different that your fastq files).
- **R1_fastq**: absolute path to the R1.fastq.gz file.
- **R2_fastq**: absolute path to the R2.fastq.gz file.

Example:
```
sample_id,R1_fastq,R2_fastq
S1_patient,/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_input/S1-patient_R1.fastq.gz,/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_input/S1-patient_R2.fastq.gz
S2_patient,/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_input/S2-patient_R1.fastq.gz,/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_input/S2-patient_R2.fastq.gz
S3_patient,/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_input/S3-patient_R1.fastq.gz,/mnt/beegfs/scratch/m_aglave/Editing_analysis/data_input/S3-patient_R2.fastq.gz
```
> Notes:
> - sample names mustn't contain special characters or spaces.
> - fastq files must be gzipped.

### Run
You need snakemake (via conda) and singularity (via module load). They are already installed for you on Flamingo, just follow the example below.  
Don't forget to change the version of the pipeline and the path to your configuration file.  
Example of script:
```
#!/bin/bash
#using: sbatch run.sh
#SBATCH --job-name=Editing_analysis
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=250M
#SBATCH --partition=longq

source /mnt/beegfs/software/miniconda/24.3.0/etc/profile.d/conda.sh
conda activate /mnt/beegfs/pipelines/bigr_rna_editing/<version>/envs/conda/snakemake
module load singularity
Editing_pipeline="/mnt/beegfs/pipelines/bigr_rna_editing/<version>/"

snakemake --profile ${Editing_pipeline}/profiles/slurm \
          -s ${Editing_pipeline}/Snakefile \
          --configfile <path_to/my_configuration_file.yaml>
```

## Steps of the pipeline
1. Symbolic link of fastq files
2. QC & Trimming (fastQC, fastp & multiqc)
3. BWA index generation (via SPRINT)
3. BWA alignement (via SPRINT)
4. Identification of Editing events (SPRINT) (this step takes 2-3 days!)
5. Summary of SPRINT results (R)
6. Bam sorting (Samtools)
7. Identification of Editing events (RNAEditingIndexer)
8. Summary of RNAEditingIndexer results (R)

Information about Editing tools:  
SPRINT:  
https://github.com/jumphone/SPRINT  
https://academic.oup.com/bioinformatics/article/33/22/3538/4004872  
RNAEditingIndexer:  
https://github.com/a2iEditing/RNAEditingIndexer  
https://pubmed.ncbi.nlm.nih.gov/31636457/  
