#!/bin/bash
fn=${1}
input=${2}
startNum=${3}
totalNum=${4}

threads=1
for (( i = startNum; i < totalNum + 1 ; i++ )); do
    sbj=$(sed -n ${i}p ${fn})

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
done