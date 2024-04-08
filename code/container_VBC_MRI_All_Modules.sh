#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

if [[ -d /mnt_fp/fsaverage ]]; then
	printf "fsaverage directory has been checked.\n"
else
	cp -r /opt/freesurfer/subjects/fsaverage /mnt_fp/
	printf "fsaverage directory has been copied.\n"
fi

# Part 1: SC Preprocessing
# ------------------------
printf "/mnt_sw/code/container_SC_preprocess.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_preprocess.sh ${input} ${threads} ${sbj}
wait

# Part 2: Tractography
# --------------------
printf "/mnt_sw/code/container_SC_tractography.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_tractography.sh ${input} ${threads} ${sbj}
wait

# Part 3: Atlas transformation
# ----------------------------
printf "/mnt_sw/code/container_SC_atlas_transformation.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_atlas_transformation.sh ${input} ${threads} ${sbj}
wait

# Part 4: Reconstruct
# -------------------
printf "/mnt_sw/code/container_SC_reconstruct.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_reconstruct.sh ${input} ${threads} ${sbj}
wait