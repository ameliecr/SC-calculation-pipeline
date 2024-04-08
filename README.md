# Containerized structural and functional MRI pipeline

## REQUIREMENTS

1. To use the containerized pipeline, please install 'singularity' on your computing system: https://sylabs.io/guides/3.3/user-guide/installation.html

2. This pipeline uses Freesurfer. If you do not have a license, please register for Freesurfer: https://surfer.nmr.mgh.harvard.edu/registration.html

3. Essential files

- `code/Singularity.def`: Recipe file to be used with `singularity build` to generate a container image.
- `code/input.txt`: Example pipeline parameter specification. It should be prepared for a purpose of the user.
- `code/examples/get_condor_submit.sh`: Example CONDOR submission script for a HTC system (functional pipeline).
- `code/examples/container_SC_pipeline_JURECA.sh`: Example SLURM submission script for the JURECA HPC system (structural pipeline).

4. The NeuroDebian package repository in the `code/Singularity.def` might be changed incidentally. If so, please check the site: https://neuro.debian.net/install_pkg.html?p=singularity-container and choose 'Debian GNU/Linux 9.0 (stretch)' and a download server close to you. Then select 'all software' in the desired components. Finally, please update the address of the download server with the selected one and check the keyserver.

## INSTRUCTION

### 1. ARGUMENTS

There are three main paths for this pipeline: working path, raw data path, and target (result) path. These paths have to be specified by the end-users based on their own computing system.

The containerized pipeline consists of four modules: structural preprocessing, tractography, atlas transformation and reconstruction. The containerized pipeline uses 4 arguments (module script, input file, No. threads, and subject ID) as below.

    singularity exec --bind /mount/path:/mnt Container_MRI.simg ${module.sh} ${input.txt} ${n_threads} ${subject_id}

### 2. INPUT (an example for the Schaefer atlas)

An example of an input text file is the following.

    # Freesurfer license
    # ------------------
    email=user@your-institute.de
    digit=xxxxx
    line1=xxxxxxxxxxxxx
    line2=xxxxxxxxxxxxx

    # Input variables
    # ---------------
    grp=INM                                 # Name of dataset
    tract=100000                            # Total number of streamlines for whole-brain tractography
    atlname=atlas_prefix                    # Name of atlas for prefixing results
    numparc=100                             # Total number of regions in a given atlas
    shells=0,1000,2000,3000                 # shells=0,1000,2000,3000 for HCP dwMRI, i.e., b-values
    non_zero_shells=1000,2000,3000          # shells=1000,2000,3000 for HCP dwMRI

    # Paths setting
    # -------------
    sp=/mnt_sp                                                              # Source (raw) data path
    fp=/mnt_fp                                                              # Subject's path for freesurfer
    ap=/mnt_ap                                                              # Atlas path
    ppsc=/mnt_sc                                                            # Output directory for structural connectivity
    ppfc=/mnt_fc                                                            # Output directory for functional connectivity
    atlas=atlas.nii.gz                                                      # Atlas on the MNI 1mm space (6th generation in FSL)
    atlas=atlas.nii.gz                                                      # Provide a filename of an atlas on the MNI 1mm space (6th generation in FSL)
    mni=/usr/share/fsl/5.0/data/standard/MNI152_T1_1mm.nii.gz               # Standard template for registration
    mni_brain=/usr/share/fsl/5.0/data/standard/MNI152_T1_1mm_brain.nii.gz   # Standard brain template for registration

The parameters can be modified by the users. For licensing Freesurfer, they should get a license code via a registration with a license agreement and put the license code in the input text file. Input files should be prepared for each condition.

### 3. DATA STRUCTURE

The raw data is expected to be in the format as provided with the HCP-YA dataset.
The files listed below are required to run the pipeline and are part of the provided HCP data.

    DATA_DIR (/mnt_sp)
    ├── sub-ID
    │   ├── T1w
    │   │   ├── T1w_acpc_dc_restore_brain.nii.gz
    │   │   ├── Diffusion
    │   │   │   ├── bvals
    │   │   │   ├── bvecs
    │   │   │   ├── data.nii.gz
    │   │   │   └── nodif_brain_mask.nii.gz
    │   │   ├── sub-ID
    │   │   │   ├── mri
    │   │   │   │   ├── aseg.mgz
    │   │   │   │   ├── nu.mgz
    │   │   │   │   └── ribbon.mgz
    │   │   │   ├── surf
    │   │   │   │   ├── lh.sphere.reg
    │   │   │   │   ├── rh.sphere.reg
    │   │   │   │   ├── lh.smoothwm
    │   │   │   │   ├── rh.smoothwm
    │   │   │   │   ├── lh.white
    │   │   │   │   ├── rh.white
    │   │   │   │   ├── lh.pial
    │   │   │   │   └── rh.pial
    │   │   │   ├── label
    │   │   │   │   ├── lh.cortex.label
    │   │   │   │   └── rh.cortex.label
    .   .   .
    .   .   .
    .   .   .

### 4. EXAMPLE SCRIPT FOR THE SLURM (structural pipeline)

Based on the optimized configuration for the structural modules of the containerized pipeline on JURECA at Forschungszentrum Jülich, we provide a script to run the structural pipeline, `code/examples/jureca_sbatch_64x4_SMT.sh`. With a modification of one line in it, you can use the script on JURECA. This script uses 3 arguments: path to a text file containing the subject IDs, index of the first subject ID to use, index of the last subject ID to use

    SIMG_DIR=/path/to/container/Container_MRI.simg
    
The above example is a script for the SLURM system on JURECA. To execute a file like this run `sbatch code/examples/jureca_sbatch_64x4_SMT.sh subjectIDs.txt indxIDstart indxIDend` from the terminal.

### 5. EXAMPLE SCRIPT FOR RUNNING THE PIPELINE LOCALLY IN THE CONTAINER
`code/examples/run_script_for19WBTs_in_container.sh` runs the entire pipeline in the container for multiple subjects. This script uses two arguments: the index of the first subject ID to use and the index of the last subject ID to use. The path to the text file containing the subject IDs of interest is defined within the script.


## TROUBLESHOOT

If you have a problem to use the containerized pipeline please contact Amelie Rauland (a.rauland@fz-juelich.de) or Kyesam Jung (k.jung@fz-juelich.de).

## Acknowledgements

This pipeline is based on work by Kyesam Jung: https://jugit.fz-juelich.de/inm7/public/vbc-mri-pipeline
The links and scripts to calculate the classifier images were adopted from work by Justin Domhof: https://doi.org/10.25493/81EV-ZVT
