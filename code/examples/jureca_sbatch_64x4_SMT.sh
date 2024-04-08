#!/bin/bash
#SBATCH -J HCP_YA_sc
#SBATCH -o /p/scratch/cjinm71/Rauland/data/HCP_YA/pipeline_outputs/slurm_logs/HCP_YA_Job_%j.out
#SBATCH -e /p/scratch/cjinm71/Rauland/data/HCP_YA/pipeline_outputs/slurm_logs/HCP_YA_Job_%j.err
#SBATCH -A jinm71
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=4
#SBATCH --time=23:00:00
#SBATCH --mail-user=a.rauland@fz-juelich.de 
#SBATCH --mail-type=ALL
#SBATCH --partition=dc-cpu

# For SMT (simultaneous multithreading)
# -------------------------------------
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

fn=${1} # Path to a text file with subject IDs. One ID per line.
startNum=${2} # Index of first subject ID to use.
endNum=${3} # Index of last subject ID to use. For jureca, usually 64 IDs are passed at a time for optimal use of capacity

SIMG_DIR='/p/scratch/cjinm71/Rauland/Container_VBC_MRI_pipeline_20220307.simg'
SOFTWARE_DIR='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline'
DATA_DIR='/p/scratch/cjinm71/Rauland/data/HCP_YA'
ATLAS_DIR='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/classifiers'
OUTPUT_SC_DIR='/p/scratch/cjinm71/Rauland/data/HCP_YA/pipeline_outputs'
OUTPUT_FC_DIR='/p/scratch/cjinm71/Rauland/data/HCP_YA/pipeline_outputs'
FREESURFER_OUTPUT='/p/scratch/cjinm71/Rauland/data/HCP_YA/pipeline_outputs'

INPUT_PARAMETERS_031='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input031.txt'
INPUT_PARAMETERS_038='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input038.txt'
INPUT_PARAMETERS_048='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input048.txt'
INPUT_PARAMETERS_056C='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input056C.txt'
INPUT_PARAMETERS_056M='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input056M.txt'
INPUT_PARAMETERS_070='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input070.txt'
INPUT_PARAMETERS_079='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input079.txt'
INPUT_PARAMETERS_086='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input086.txt'
INPUT_PARAMETERS_092='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input092.txt'
INPUT_PARAMETERS_096='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input096.txt'
INPUT_PARAMETERS_100='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input100.txt'
INPUT_PARAMETERS_103='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input103.txt'
INPUT_PARAMETERS_108='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input108.txt'
INPUT_PARAMETERS_150='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input150.txt'
INPUT_PARAMETERS_156='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input156.txt'
INPUT_PARAMETERS_160='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input160.txt'
INPUT_PARAMETERS_167='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input167.txt'
INPUT_PARAMETERS_200='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input200.txt'
INPUT_PARAMETERS_210='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/input210.txt'

RUN_SCRIPT='/p/scratch/cjinm71/Rauland/SC-calculation-pipeline/code/container_VBC_MRI_All_Modules.sh'
FREESURFER_LICENSE='/p/scratch/cjinm71/Rauland/workbench/freesurfer/license.txt'

NTHREAD=${OMP_NUM_THREADS}

########## 031-MIST ############
nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_031}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_031}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done

# DO NOT COMMENT THIS OUT!
# ------------------------
wait
# ------------------------

########## 038-Craddock ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_038}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_038}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 048-HarvardOxford ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_048}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_048}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 056-Craddock ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_056C}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_056C}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 056-MIST ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_056M}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_056M}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 070-DK ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_070}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_070}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 079-Shen ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_079}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_079}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 086-Economo ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_086}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_086}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 092-AAL ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_092}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_092}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 096-HarvardOxford ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_096}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_096}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 100-Schaefer ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_100}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_100}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 103-MIST ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_103}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_103}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 108-Craddock ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_108}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_108}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 150-Destrieux ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_150}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_150}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 156-Shen ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_156}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_156}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 160-Craddock ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_160}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_160}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 167-MIST ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_167}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_167}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 200-Schaefer ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_200}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_200}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait

########## 210-Brainnetome ############
# nTask=0
for (( i = startNum; i < endNum + 1 ; i++ )); do
	sbj=$(sed -n $((i))p ${DATA_DIR}/${fn})
	(( nTask++ ))
	printf "[+] Running task ${nTask} - loop index ${i} ... "
	printf "srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_210}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} \n\n"
	srun --exclusive -n 1 --cpus-per-task=${NTHREAD} singularity exec --cleanenv -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${ATLAS_DIR}:/mnt_ap,${INPUT_PARAMETERS_210}:/opt/input.txt,${RUN_SCRIPT}:/opt/script.sh ${SIMG_DIR} /opt/script.sh /opt/input.txt ${NTHREAD} ${sbj} &
	if [[ ${nTask} -eq 64 ]]; then
		wait
		nTask=0
	fi
done
wait