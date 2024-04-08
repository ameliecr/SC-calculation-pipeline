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
wp=$(pwd)
tmp=${ppsc}/${sbj}/temp
aseg=${tmp}/aseg.nii.gz
parcseg=${tmp}/aparc.a2009s+aseg.nii.gz

t1=${sp}/${sbj}/T1w/T1w_acpc_dc_restore_brain.nii.gz
dwi=${sp}/${sbj}/T1w/Diffusion/data.nii.gz
bval=${sp}/${sbj}/T1w/Diffusion/bvals
bvec=${sp}/${sbj}/T1w/Diffusion/bvecs
brain_mask=${sp}/${sbj}/T1w/Diffusion/nodif_brain_mask.nii.gz

fs_aseg=${sp}/${sbj}/T1w/${sbj}/mri/aseg.mgz
fs_nu=${sp}/${sbj}/T1w/${sbj}/mri/nu.mgz

mc_bval=${sp}/${sbj}/T1w/Diffusion/bvals # since data comes pre-processed, bvals are already mc
mc_bvec=${sp}/${sbj}/T1w/Diffusion/bvecs # since data comes pre-processed, bvecs are already mc
ctx=${ppsc}/${sbj}/fs_t1_ctx_mask_to_dwi.nii.gz
sub=${ppsc}/${sbj}/fs_t1_subctx_mask_to_dwi.nii.gz
csf=${ppsc}/${sbj}/fs_t1_csf_mask_to_dwi.nii.gz
wm=${ppsc}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
wmneck=${ppsc}/${sbj}/fs_t1_neck_wm_mask_to_dwi.nii.gz
gmneck=${ppsc}/${sbj}/fs_t1_neck_gm_mask_to_dwi.nii.gz
ftt=${ppsc}/${sbj}/5tt.nii.gz
tensor=${tmp}/dt.mif
fa=${ppsc}/${sbj}/FA.mif
md=${ppsc}/${sbj}/MD.mif
ad=${ppsc}/${sbj}/AD.mif
rd=${ppsc}/${sbj}/RD.mif

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

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

# Target folder check
# -------------------
if [[ -d ${ppsc}/${sbj} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${sbj}${NCR} - Target folder exists, so the process will overwrite the files in the target folder.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${sbj}${NCR} - Create a target folder.\n"
	mkdir -p ${ppsc}/${sbj}
fi

# Temporary folder check
# ----------------------
if [[ -d ${tmp} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${sbj}${NCR} - Temporary folder exists, so the process will overwrite the files in the target folder.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${sbj}${NCR} - Create a temporary folder.\n"
	mkdir -p ${tmp}
fi

# Start the SC preprocessing
# --------------------------
startingtime=$(date +%s)
et=${ppsc}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC preprocessing with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

# Check T1-weighted image
# -----------------------
if [[ -f ${t1} ]]; then
	printf "${GRN}[T1-weighted]${RED} ID: ${sbj}${NCR} - Check file: ${t1}\n"
else
	printf "${RED}[T1-weighted]${RED} ID: ${sbj}${NCR} - There is not T1-weighted image!!! ${t1}\n"
	exit 1
fi

# Calculate diffusion tensor
# -------------------------------------------------------
if [[ -f ${tensor} ]]; then
	printf "${GRN}[MRtrix & DT]${RED} ID: ${sbj}${NCR} - Diffusion tensor (MRtrix output) exist!!!\n"
else
	printf "${GRN}[MRtrix & DT]${RED} ID: ${sbj}${NCR} - Calculate diffusion tensor (MRtrix output output).\n"
	dwi2tensor ${dwi} ${tensor}  -fslgrad ${bvec} ${bval} -mask ${brain_mask}
fi

# Calculate Fractional Anisotropy (FA)
# -------------------------------------------------------
if [[ -f ${fa} ]]; then
	printf "${GRN}[MRtrix & FA]${RED} ID: ${sbj}${NCR} - FA file (MRtrix output) exist!!!\n"
else
	printf "${GRN}[MRtrix & FA]${RED} ID: ${sbj}${NCR} - Calculate FA from diffusion tensor (MRtrix output output).\n"
	tensor2metric ${tensor} -fa ${fa} -mask ${brain_mask}
fi

# Calculate Mean Diffusivity (MD)
# -------------------------------------------------------
if [[ -f ${md} ]]; then
	printf "${GRN}[MRtrix & MD]${RED} ID: ${sbj}${NCR} - MD file (MRtrix output) exist!!!\n"
else
	printf "${GRN}[MRtrix & MD]${RED} ID: ${sbj}${NCR} - Calculate MD from diffusion tensor (MRtrix output output).\n"
	tensor2metric ${tensor} -adc ${md} -mask ${brain_mask}
fi

# Calculate Mean Diffusivity (AD)
# -------------------------------------------------------
if [[ -f ${ad} ]]; then
	printf "${GRN}[MRtrix & AD]${RED} ID: ${sbj}${NCR} - AD file (MRtrix output) exist!!!\n"
else
	printf "${GRN}[MRtrix & AD]${RED} ID: ${sbj}${NCR} - Calculate AD from diffusion tensor (MRtrix output output).\n"
	tensor2metric ${tensor} -ad ${ad} -mask ${brain_mask}
fi

# Calculate Mean Diffusivity (RD)
# -------------------------------------------------------
if [[ -f ${rd} ]]; then
	printf "${GRN}[MRtrix & RD]${RED} ID: ${sbj}${NCR} - RD file (MRtrix output) exist!!!\n"
else
	printf "${GRN}[MRtrix & RD]${RED} ID: ${sbj}${NCR} - Calculate RD from diffusion tensor (MRtrix output output).\n"
	tensor2metric ${tensor} -rd ${rd} -mask ${brain_mask}
	rm ${tensor}
fi

# Create brain masks on T1 space (Freesurfer output)
# --------------------------------------------------
if [[ -f ${tmp}/fs_t1_gmwm_mask.nii.gz ]]; then
	printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - Brain masks on T1 space (Freesurfer output) exist!!!\n"
else
	printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - Create brain masks on T1 space (Freesurfer output).\n"
	mri_convert ${fs_aseg} ${aseg}

	# White-matter mask with a neck
	# -----------------------------
	for i in 2 7 16 28 41 46 60 77 251 252 253 254 255
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 2 ]]; then
			cp ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${tmp}/temp_mask.nii.gz -bin ${tmp}/fs_t1_neck_wm_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_neck_wm_mask.nii.gz ${tmp}/fs_t1_neck_wm_mask.nii.gz
	if [[ -f ${tmp}/fs_t1_neck_wm_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_neck_wm_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_neck_wm_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# White-matter
	# ------------
	fslmaths ${tmp}/temp_roi_2.nii.gz -add ${tmp}/temp_roi_41.nii.gz -add ${tmp}/temp_roi_77.nii.gz -add ${tmp}/temp_roi_251.nii.gz -add ${tmp}/temp_roi_252.nii.gz -add ${tmp}/temp_roi_253.nii.gz -add ${tmp}/temp_roi_254.nii.gz -add ${tmp}/temp_roi_255.nii.gz -bin ${tmp}/fs_t1_wm_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_wm_mask.nii.gz ${tmp}/fs_t1_wm_mask.nii.gz
	if [[ -f ${tmp}/fs_t1_wm_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_wm_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_wm_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Cortical mask
	# -------------
	for i in 3 8 42 47
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 3 ]]; then
			cp ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${tmp}/temp_mask.nii.gz -bin ${tmp}/fs_t1_ctx_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_ctx_mask.nii.gz ${tmp}/fs_t1_ctx_mask.nii.gz
	if [[ -f ${tmp}/fs_t1_ctx_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_ctx_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_ctx_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Subcortical mask
	# ----------------
	for i in 10 11 12 13 17 18 26 49 50 51 52 53 54 58
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 10 ]]; then
			cp ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${tmp}/temp_mask.nii.gz -bin ${tmp}/fs_t1_subctx_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_subctx_mask.nii.gz ${tmp}/fs_t1_subctx_mask.nii.gz
	if [[ -f ${tmp}/fs_t1_subctx_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_subctx_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_subctx_mask.nii.gz has not been saved!!\n"
		exit 1
	fi
	
	# Cerebrospinal fluid (CSF)
	# -------------------------
	for i in 4 5 14 15 24 31 43 44 63
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 4 ]]; then
			cp ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_roi_${i}.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${tmp}/temp_mask.nii.gz -bin ${tmp}/fs_t1_csf_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_csf_mask.nii.gz ${tmp}/fs_t1_csf_mask.nii.gz
	if [[ -f ${tmp}/fs_t1_csf_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_csf_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_csf_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Brain-tissue
	# ------------
	fslmaths ${tmp}/fs_t1_ctx_mask.nii.gz -add ${tmp}/fs_t1_subctx_mask.nii.gz -bin ${tmp}/fs_t1_neck_gm_mask.nii.gz
	fslmaths ${tmp}/fs_t1_neck_gm_mask.nii.gz -add ${tmp}/fs_t1_neck_wm_mask.nii.gz -bin ${tmp}/fs_t1_gmwm_mask.nii.gz
	if [[ -f ${tmp}/fs_t1_gmwm_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_gmwm_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${sbj}${NCR} - ${tmp}/fs_t1_gmwm_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Creating tissue masks" >> ${et}
fi

# Averaged DWIs
# -------------
if [[ -f ${ppsc}/${sbj}/dwi_avg.nii.gz ]]; then
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${sbj}${NCR} - An averaged DWI was already created!!!\n"
else
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${sbj}${NCR} - Make an averaged DWI.\n"
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${sbj}${NCR} - b-vec file: ${mc_bvec}\n"
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${sbj}${NCR} - b-val file: ${mc_bval}\n"
	echo ${non_zero_shells}
	echo ${mc_bvec}
	echo ${mc_bval}
	echo ${threads}
	echo ${dwi}
	echo ${ppsc}/${sbj}/dwi_nonzero_bval.nii.gz
	dwiextract -shells ${non_zero_shells} -fslgrad ${mc_bvec} ${mc_bval} -nthreads ${threads} ${dwi} ${ppsc}/${sbj}/dwi_nonzero_bval.nii.gz
	fslmaths ${ppsc}/${sbj}/dwi_nonzero_bval.nii.gz -Tmean ${tmp}/raw_dwi_avg.nii.gz

	# 4-time iterative bias-field corrections, because of possibly dark in the center of the brain.
	# ---------------------------------------------------------------------------------------------
	N4BiasFieldCorrection -i ${tmp}/raw_dwi_avg.nii.gz -o [${tmp}/dwi_bc1.nii.gz,${tmp}/dwi_bf1.nii.gz]
	N4BiasFieldCorrection -i ${tmp}/dwi_bc1.nii.gz -o [${tmp}/dwi_bc2.nii.gz,${tmp}/dwi_bf2.nii.gz]
	N4BiasFieldCorrection -i ${tmp}/dwi_bc2.nii.gz -o [${tmp}/dwi_bc3.nii.gz,${tmp}/dwi_bf3.nii.gz]
	N4BiasFieldCorrection -i ${tmp}/dwi_bc3.nii.gz -o [${tmp}/dwi_bc4.nii.gz,${tmp}/dwi_bf4.nii.gz]

	cp ${tmp}/dwi_bc4.nii.gz ${ppsc}/${sbj}/dwi_avg.nii.gz
	rm -rf ${tmp}/dwi_bc*.nii.gz
	rm -rf ${tmp}/dwi_bf*.nii.gz
	rm -rf ${tmp}/raw_dwi_avg.nii.gz

	if [[ -f ${ppsc}/${sbj}/dwi_avg.nii.gz ]]; then
		printf "${GRN}[Averaged DWI]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/dwi_avg.nii.gz has been saved.\n"
	else
		printf "${GRN}[Averaged DWI]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/dwi_avg.nii.gz has not been saved!!\n"
		exit 1
	fi
fi

# Co-registration (from T1WI to averaged DWI)
# -------------------------------------------
if [[ -f ${ppsc}/${sbj}/fs_t1_to_dwi.nii.gz ]]; then
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Coregistration from T1WI in Freesurfer to DWI space was already performed!!!\n"
else
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Start coregistration.\n"
	mri_convert ${fs_nu} ${tmp}/fs_t1.nii.gz
	fslreorient2std ${tmp}/fs_t1.nii.gz ${tmp}/fs_t1.nii.gz

	# Dilate the brain-tissue mask
	# ----------------------------
	mri_binarize --i ${tmp}/fs_t1_gmwm_mask.nii.gz --min 0.5 --max 1.5 --dilate 20 --o ${tmp}/fs_t1_gmwm_mask_dilate.nii.gz
	fslmaths ${tmp}/fs_t1.nii.gz -mas ${tmp}/fs_t1_gmwm_mask_dilate.nii.gz ${ppsc}/${sbj}/fs_t1.nii.gz
	fslmaths ${tmp}/fs_t1.nii.gz -mas ${tmp}/fs_t1_gmwm_mask.nii.gz ${ppsc}/${sbj}/fs_t1_brain.nii.gz

	# AC-PC alignment of DWI
	# ----------------------
	# fslreorient2std -m ${tmp}/dwi_to_dwi_reori.mat ${ppsc}/${sbj}/dwi_avg.nii.gz ${tmp}/dwi_reori.nii.gz
	fslreorient2std ${ppsc}/${sbj}/dwi_avg.nii.gz ${tmp}/dwi_reori.nii.gz
	flirt -in ${ppsc}/${sbj}/dwi_avg.nii.gz -ref ${tmp}/dwi_reori.nii.gz -omat ${tmp}/dwi_to_dwi_reori.mat -dof 6 -finesearch 90 -coarsesearch 90
	robustfov -i ${tmp}/dwi_reori.nii.gz -b 170 -m ${tmp}/dwi_acpc_roi2full.mat -r ${tmp}/dwi_acpc_robustroi.nii.gz
	flirt -interp spline -in ${tmp}/dwi_acpc_robustroi.nii.gz -ref ${mni_brain} -omat ${tmp}/dwi_acpc_roi2std.mat -out ${tmp}/dwi_acpc_roi2std.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30
	convert_xfm -omat ${tmp}/dwi_acpc_full2roi.mat -inverse ${tmp}/dwi_acpc_roi2full.mat
	convert_xfm -omat ${tmp}/dwi_acpc_full2std.mat -concat ${tmp}/dwi_acpc_roi2std.mat ${tmp}/dwi_acpc_full2roi.mat
	aff2rigid ${tmp}/dwi_acpc_full2std.mat ${tmp}/dwi_acpc.mat
	applywarp --rel --interp=spline -i ${tmp}/dwi_reori.nii.gz -r ${mni_brain} --premat=${tmp}/dwi_acpc.mat -o ${tmp}/dwi_acpc.nii.gz

	# Co-registration
	# ---------------
	flirt -in ${tmp}/dwi_acpc.nii.gz -ref ${ppsc}/${sbj}/fs_t1_brain.nii.gz -out ${tmp}/dwi_acpc_to_fs_t1_affine.nii.gz -omat ${tmp}/dwi_acpc_to_fs_t1_affine.mat -dof ${coreg_flirt_dof} -cost ${coreg_flirt_cost}
	convert_xfm -omat ${tmp}/dwi_acpc_to_fs_t1_invaffine.mat -inverse ${tmp}/dwi_acpc_to_fs_t1_affine.mat
	# applywarp -i ${tmp}/fs_t1.nii.gz -r ${tmp}/dwi_acpc.nii.gz -o ${tmp}/fs_t1_to_dwi_acpc.nii.gz --premat=${tmp}/dwi_acpc_to_fs_t1_invaffine.mat
	# applywarp -i ${ppsc}/${sbj}/fs_t1_brain.nii.gz -r ${tmp}/dwi_acpc.nii.gz -o ${tmp}/fs_t1_brain_to_dwi_acpc.nii.gz --premat=${tmp}/dwi_acpc_to_fs_t1_invaffine.mat

	# Warp to dwi directly
	# --------------------
	convert_xfm -omat ${tmp}/dwi_to_dwi_reori_invaffine.mat -inverse ${tmp}/dwi_to_dwi_reori.mat
	convert_xfm -omat ${tmp}/dwi_acpc_invaffine.mat -inverse ${tmp}/dwi_acpc.mat
	convert_xfm -omat ${tmp}/fs_t1_to_dwi_reori.mat -concat ${tmp}/dwi_acpc_invaffine.mat ${tmp}/dwi_acpc_to_fs_t1_invaffine.mat
	convert_xfm -omat ${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat -concat ${tmp}/dwi_to_dwi_reori_invaffine.mat ${tmp}/fs_t1_to_dwi_reori.mat
	applywarp -i ${tmp}/fs_t1.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/fs_t1_to_dwi.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	applywarp -i ${ppsc}/${sbj}/fs_t1_brain.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/fs_t1_brain_to_dwi.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	
	# Linear registration
	# -------------------
	# flirt -in ${ppsc}/${sbj}/dwi_avg.nii.gz -ref ${ppsc}/${sbj}/fs_t1_brain.nii.gz -out ${ppsc}/${sbj}/dwi_to_fs_t1_affine.nii.gz -omat ${ppsc}/${sbj}/dwi_to_fs_t1_affine.mat -dof ${coreg_flirt_dof} -cost ${coreg_flirt_cost}
	# convert_xfm -omat ${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat -inverse ${ppsc}/${sbj}/dwi_to_fs_t1_affine.mat
	# applywarp -i ${ppsc}/${sbj}/fs_t1.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/fs_t1_to_dwi.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	# applywarp -i ${ppsc}/${sbj}/fs_t1_brain.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/fs_t1_brain_to_dwi.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	if [[ -f ${ppsc}/${sbj}/fs_t1_to_dwi.nii.gz ]]; then
		printf "${GRN}[FSL Co-registration]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/fs_t1_to_dwi.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Co-registration]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/fs_t1_to_dwi.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Co-registration" >> ${et}
fi

# Registration from MNI space to DWI space
# ----------------------------------------
if [[ -f ${ppsc}/${sbj}/mni_to_dwi.nii.gz ]]; then
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Registration from MNI to DWI space was already performed!!!\n"
else
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Start registration from MNI to T1WI space.\n"
	
	# From T1 (Freesurfer) to MNI152 1mm
	# ----------------------------------
	flirt -ref ${mni_brain} -in ${ppsc}/${sbj}/fs_t1_brain.nii.gz -omat ${ppsc}/${sbj}/fs_t1_to_mni_affine.mat -dof ${reg_flirt_dof}
	fnirt --in=${ppsc}/${sbj}/fs_t1_brain.nii.gz --aff=${ppsc}/${sbj}/fs_t1_to_mni_affine.mat --cout=${ppsc}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --config=T1_2_MNI152_2mm
	
	# From MNI152 1mm to T1 (Freesurfer) - inverse
	# --------------------------------------------
	invwarp --ref=${ppsc}/${sbj}/fs_t1_brain.nii.gz --warp=${ppsc}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --out=${ppsc}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz
	applywarp --ref=${ppsc}/${sbj}/fs_t1_brain.nii.gz --in=${mni_brain} --warp=${ppsc}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --out=${ppsc}/${sbj}/mni_brain_to_fs_t1.nii.gz --interp=${reg_fnirt_interp}
	applywarp --ref=${ppsc}/${sbj}/fs_t1_brain.nii.gz --in=${mni} --warp=${ppsc}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --out=${ppsc}/${sbj}/mni_to_fs_t1.nii.gz --interp=${reg_fnirt_interp}

	# Rigid transform from T1 (Freesurfer) to DWI space
	# -------------------------------------------------
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Start registration from MNI to DWI space.\n"
	applywarp -i ${ppsc}/${sbj}/mni_to_fs_t1.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/mni_to_dwi.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	applywarp -i ${ppsc}/${sbj}/mni_brain_to_fs_t1.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/mni_brain_to_dwi.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	if [[ -f ${ppsc}/${sbj}/mni_to_dwi.nii.gz ]]; then
		printf "${GRN}[FSL Non-linear registration]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/mni_to_dwi.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Non-linear registration]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/mni_to_dwi.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Non-linear registration" >> ${et}
fi

# Transform tissue masks (from aseg.mgz) to the diffusion space
# -------------------------------------------------------------
if [[ -f ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz ]]; then
	printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - A cortical mask of Destrieux in Freesurfer exists!!!\n"
else
	printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - Make a cortical mask of Destrieux in Freesurfer.\n"

	# Cortical gray-matter mask (Cerebrum + Cerebellum)
	# -------------------------------------------------
	applywarp -i ${tmp}/fs_t1_ctx_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ctx} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${ctx} -thr 0.5 -bin ${ctx}
	if [[ -f ${ctx} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${ctx} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${ctx} has not been saved!!\n"
		exit 1
	fi

	# Gray-matter mask (Cortex + Subcortical areas)
	# ---------------------------------------------
	applywarp -i ${tmp}/fs_t1_neck_gm_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${gmneck} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${gmneck} -thr 0.5 -bin ${gmneck}
	if [[ -f ${gmneck} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${gmneck} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${gmneck} has not been saved!!\n"
		exit 1
	fi

	# White-matter
	# ------------
	applywarp -i ${tmp}/fs_t1_wm_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${wm} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${wm} -thr 0.5 -bin ${wm}
	if [[ -f ${wm} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${wm} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${wm} has not been saved!!\n"
		exit 1
	fi

	# White-matter with a neck
	# ------------------------
	applywarp -i ${tmp}/fs_t1_neck_wm_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${wmneck} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${wmneck} -thr 0.5 -bin ${wmneck}
	if [[ -f ${wmneck} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${wmneck} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${wmneck} has not been saved!!\n"
		exit 1
	fi

	# Subcortical areas
	# -----------------
	applywarp -i ${tmp}/fs_t1_subctx_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${sub} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${sub} -thr 0.5 -bin ${sub}
	if [[ -f ${sub} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${sub} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${sub} has not been saved!!\n"
		exit 1
	fi

	# Cerebrospinal fluid (CSF)
	# -------------------------
	applywarp -i ${tmp}/fs_t1_csf_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${csf} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${csf} -thr 0.5 -bin ${csf}
	if [[ -f ${csf} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${csf} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${csf} has not been saved!!\n"
		exit 1
	fi

	# Brain extraction mask (BET)
	# ---------------------------
	applywarp -i ${tmp}/fs_t1_gmwm_mask.nii.gz -r ${ppsc}/${sbj}/dwi_avg.nii.gz -o ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
	fslmaths ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz -thr 0.5 -bin ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz
	if [[ -f ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Clear temporary files
	# ---------------------
	rm -f ${tmp}/temp_*.nii.gz

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Cortical masks" >> ${et}
fi

# Make 5TT (Five-type tissues)
# ----------------------------
if [[ -f ${ftt} ]]; then
	printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - 5TT image exists!!!\n"
else
	printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - Make a 5TT image.\n"
	cp ${csf} ${tmp}/temp.nii.gz
	fslmaths ${tmp}/temp.nii.gz -mul 0 -bin ${tmp}/temp.nii.gz
	fslmerge -t ${ppsc}/${sbj}/5tt_xsub.nii.gz ${ctx} ${tmp}/temp.nii.gz ${wmneck} ${csf} ${tmp}/temp.nii.gz
	fslmerge -t ${ftt} ${ctx} ${sub} ${wmneck} ${csf} ${tmp}/temp.nii.gz
	if [[ -f ${ftt} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${ftt} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${sbj}${NCR} - ${ftt} has not been saved!!\n"
		exit 1
	fi
	rm -f ${tmp}/temp.nii.gz

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} 5-tissue type images" >> ${et}
fi

echo "[-] SC preprocessing - $(date)" >> ${et}