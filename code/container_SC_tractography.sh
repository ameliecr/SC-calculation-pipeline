#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done

# Path setting
# ------------
ftt=${ppsc}/${sbj}/5tt.nii.gz
wm=${ppsc}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
wmneck=${ppsc}/${sbj}/fs_t1_neck_wm_mask_to_dwi.nii.gz
gmwmneck=${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz
gmwmcsfneck=${ppsc}/${sbj}/dwi_gmwmcsf_mask.nii.gz

dwi=${sp}/${sbj}/T1w/Diffusion/data.nii.gz
bval=${sp}/${sbj}/T1w/Diffusion/bvals
bvec=${sp}/${sbj}/T1w/Diffusion/bvecs

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

# Check b-values for tracking algorithms
# --------------------------------------
if [[ ${tracking_algorithm} = dependent || ${fod_algorithm} = dependent ]]; then
	commas=$(echo ${shells} | awk -F "," '{print NF-1}')
	if [[ ${commas} -eq 0 ]]; then
		printf "${RED}Wrong b-values!!! Please set b-values in separate with commas, for example, shells=0,1000,2000,3000 in the input text file. \n"
		exit 1
	fi
	if [[ ${commas} -gt 1 ]]; then
		tracking_algorithm=dhollander   # tournier (valid for a single non-zero b-value), dhollander (valid for multiple non-zeo b-values), fa, manual, msmt_5tt, tax
		fod_algorithm=msmt_csd         	# csd for tournier, msmt_csd for dhollander or msmt_5tt
	elif [[ ${commas} -eq 1 ]]; then
		tracking_algorithm=tournier    	# tournier (valid for a single non-zero b-value), dhollander (valid for multiple non-zeo b-values), fa, manual, msmt_5tt, tax
		fod_algorithm=csd           	# csd for tournier, msmt_csd for dhollander or msmt_5tt
	fi
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - tracking_algorithm = ${tracking_algorithm}\n"
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - fod_algorithm = ${fod_algorithm}\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - tracking_algorithm = ${tracking_algorithm}\n"
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - fod_algorithm = ${fod_algorithm}\n"
fi

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Freesurfer license
# ------------------
if [[ -f /opt/freesurfer/license.txt ]]; then
	printf "Freesurfer license has been checked.\n"
else
	echo "${email}" >> $FREESURFER_HOME/license.txt
	echo "${digit}" >> $FREESURFER_HOME/license.txt
	echo "${line1}" >> $FREESURFER_HOME/license.txt
	echo "${line2}" >> $FREESURFER_HOME/license.txt
	printf "Freesurfer license has been updated.\n"
fi

if [[ ${tract} -gt 999999 ]]; then
	tractM=$((${tract}/1000000))M
else
	if [[ ${tract} -gt 999 ]]; then
		tractM=$((${tract}/1000))K
	else
		tractM=${tract}
	fi
fi

# Start the SC tractography
# -------------------------
startingtime=$(date +%s)
et=${ppsc}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC tractography for ${tractM} with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

# Files for MRtrix
# ----------------
tck=${ppsc}/${sbj}/WBT_${tractM}_ctx.tck
out=${ppsc}/${sbj}/WBT_${tractM}_seeds_ctx.txt
odfGM=${ppsc}/${sbj}/odf_gm.mif
odfWM=${ppsc}/${sbj}/odf_wm.mif
odfCSF=${ppsc}/${sbj}/odf_csf.mif
resGM=${ppsc}/${sbj}/response_gm.txt
resWM=${ppsc}/${sbj}/response_wm.txt
resSFWM=${ppsc}/${sbj}/response_sfwm.txt
resCSF=${ppsc}/${sbj}/response_csf.txt

# Response function estimation
# ----------------------------
if [[ -f  ${resWM} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${resWM} Response function was already estimated!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Estimate response functions.\n"
	case ${tracking_algorithm} in
	msmt_5tt )
	dwi2response msmt_5tt -shells ${shells} -force -nthreads ${threads} -voxels ${ppsc}/${sbj}/response_voxels.nii.gz -mask ${wmneck} -pvf 0.95 -fa 0.2 -wm_algo tournier -fslgrad ${bvec} ${bval} ${dwi} ${ftt} ${resWM} ${resGM} ${resCSF}
		;;
	tournier )
	dwi2response tournier ${dwi} ${resWM} -shells ${non_zero_shells} -force -nthreads ${threads} -voxels ${ppsc}/${sbj}/response_voxels.nii.gz -mask ${wmneck} -fslgrad ${bvec} ${bval}
	# Option: A mask should be only for WM.
	cp ${resWM} ${resSFWM}
		;;
	dhollander )
	fslmaths ${gmwmneck} -add ${ppsc}/${sbj}/fs_t1_csf_mask_to_dwi.nii.gz -thr 0.5 -bin ${gmwmcsfneck}
	dwi2response dhollander ${dwi} ${resWM} ${resGM} ${resCSF} -shells ${shells} -force -nthreads ${threads} -voxels ${ppsc}/${sbj}/response_voxels.nii.gz -mask ${gmwmcsfneck} -fslgrad ${bvec} ${bval} -erode 0 -fa 0.2 -sfwm 0.5 -gm 2 -csf 10
	# Option: erode = 0 for an accurate GM+WM+CSF mask, otherwise erode = 3 for whole-brain crude mask.
	if [[ -f ${resSFWM} ]]; then
		rm -f ${resSFWM}
	fi
	echo $(tail -n 1 ${resWM}) >> ${resSFWM}
		;;
	* )
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Invalid tracking algorithm for dwi2response!\n"
	exit 1
		;;
	esac
	if [[ -f ${resWM} ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${resWM} has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${resWM} has not been saved!!\n"
		exit 1
	fi
	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Response function estimation" >> ${et}
fi

# FOD estimation
# --------------
if [[ -f  ${odfWM} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - FOD (Fibre orientation distribution) was already estimated!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Estimate fibre orientation distributions using spherical deconvolution.\n"
	case ${fod_algorithm} in
	msmt_csd )
	dwi2fod ${fod_algorithm} -shells ${shells} -force -nthreads ${threads} -mask ${gmwmneck} -fslgrad ${bvec} ${bval} ${dwi} ${resWM} ${odfWM} ${resGM} ${odfGM} ${resCSF} ${odfCSF}
		;;
	csd )
	dwi2fod ${fod_algorithm} ${dwi} ${resSFWM} ${odfWM} -shells ${non_zero_shells} -force -nthreads ${threads} -mask ${gmwmneck} -fslgrad ${bvecs} ${bval}
		;;
	* )
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Invalid FOD algorithm for dwi2fod!\n"
	exit 1
		;;
	esac
	if [[ -f ${odfWM} ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${odfWM} has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${odfWM} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} FOD estimation" >> ${et}
fi

# Whole-brain tractography
# ------------------------
if [[ -f ${tck} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Whole brain tracking was already performed!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Start whole brain tracking.\n"
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Output: WBT_${tractM}_ctx.tck\n"
	tckgen -algorithm ${tckgen_algorithm} -select ${tract} -step ${tckgen_step} -angle ${tckgen_angle} -minlength ${tckgen_minlength} -maxlength ${tckgen_maxlength} -cutoff ${tckgen_cutoff} -trials ${tckgen_trials} -downsample ${tckgen_downsample} -seed_dynamic ${odfWM} -max_attempts_per_seed ${tckgen_max_attempts_per_seed} -output_seeds ${out} -act ${ftt} -backtrack -crop_at_gmwmi -samples ${tckgen_samples} -power ${tckgen_power} -fslgrad ${bvec} ${bval} -nthreads ${threads} ${odfWM} ${tck}
	if [[ -f ${tck} ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${tck} has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${tck} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Whole-brain tractography" >> ${et}
fi

echo "[-] SC tractography for ${tractM} - $(date)" >> ${et}