#!/bin/bash
startNum=${1}
totalNum=${2}

VBC_DWMRI='/data/project/Container/Singularity/Container_VBC_MRI_pipeline_20220307.simg'
DATA_DIR='/data/project/data/HCP_YA'
ATLAS_DIR='/data/project/SC-calculation-pipeline/classifiers'
OUTPUT_DIR='/data/project/data/HCP_YA/pipeline_outputs'
FREESURFER_OUTPUT='/data/project/data/HCP_YA/pipeline_outputs'
FREESURFER_LICENSE='/opt/freesurfer/6.0/license.txt'
RUN_SHELLSCRIPT='/data/project/SC-calculation-pipeline/code/examples/multiple_subjects.sh'
SUBJECTS_LIST='/data/project/data/HCP_YA/subjects.txt'

# Condition 1
# -----------
INPUT_PARAMETERS=$(pwd)/input031.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 2
# -----------
INPUT_PARAMETERS=$(pwd)/input038.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 3
# -----------
INPUT_PARAMETERS=$(pwd)/input048.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 4
# -----------
INPUT_PARAMETERS=$(pwd)/input056C.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 5
# -----------
INPUT_PARAMETERS=$(pwd)/input056M.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 6
# -----------
INPUT_PARAMETERS=$(pwd)/input070.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 7
# -----------
INPUT_PARAMETERS=$(pwd)/input079.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 8
# -----------
INPUT_PARAMETERS=$(pwd)/input086.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 9
# -----------
INPUT_PARAMETERS=$(pwd)/input092.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 10
# -----------
INPUT_PARAMETERS=$(pwd)/input096.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 11
# -----------
INPUT_PARAMETERS=$(pwd)/input100.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 12
# -----------
INPUT_PARAMETERS=$(pwd)/input103.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 13
# -----------
INPUT_PARAMETERS=$(pwd)/input108.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 14
# -----------
INPUT_PARAMETERS=$(pwd)/input150.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 15
# -----------
INPUT_PARAMETERS=$(pwd)/input156.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 16
# -----------
INPUT_PARAMETERS=$(pwd)/input160.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 17
# -----------
INPUT_PARAMETERS=$(pwd)/input167.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 18
# -----------
INPUT_PARAMETERS=$(pwd)/input200.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 19
# -----------
INPUT_PARAMETERS=$(pwd)/input210.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}