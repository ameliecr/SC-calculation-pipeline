#!/bin/bash -x

input=${1}
threads=${2}
sbj=${3}

totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
# threads=${threads3}
num=${numparc}

# Path setting
# ------------
case ${parcellation} in
native )
	atlt1w=${ppsc}/${sbj}/${atlname}_to_fs_t1_${parcellation}+subctx.nii.gz
	atl=${ppsc}/${sbj}/${atlname}_to_dwi_${parcellation}+subctx.nii.gz
	;;
mni152 )
	atlt1w=${ppsc}/${sbj}/${atlname}_to_fs_t1_${parcellation}.nii.gz
	atl=${ppsc}/${sbj}/${atlname}_to_dwi_${parcellation}.nii.gz
	atlmni=${ap}/${atlas}
	;;
manual )
	atlt1w=${ppsc}/${sbj}/${atlname}_to_fs_t1_${parcellation}.nii.gz
	atl=${ppsc}/${sbj}/${atlname}_to_dwi_${parcellation}.nii.gz
	atlman=${ppsc}/${sbj}/${atlas}
	bg_t1w=${ppsc}/${sbj}/${atlas_background}
	;;
esac
gmneck=${ppsc}/${sbj}/fs_t1_neck_gm_mask_to_dwi.nii.gz
# tmp=${ppsc}/${sbj}/temp
tmp=/tmp/SC__${sbj}
aseg=${ppsc}/${sbj}/temp/aseg.nii.gz
dwi_avg=${ppsc}/${sbj}/dwi_avg.nii.gz

# Transform function for loops
# ----------------------------
Transform()
{
	idx=${1}
	mask1=${tmp}/temp_label${idx}_mask1.nii.gz
	mask2=${tmp}/temp_label${idx}_mask2.nii.gz
	mask3=${tmp}/temp_label${idx}_mask3.nii.gz
	mask4=${tmp}/temp_label${idx}_mask4.nii.gz

	case ${parcellation} in
	native )
		fslmaths ${atlt1w} -thr ${idx} -uthr ${idx} -bin ${mask1}
		applywarp -i ${mask1} -r ${dwi_avg} -o ${mask3} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
		;;

	mni152 )
		fslmaths ${atlmni} -thr ${idx} -uthr ${idx} -bin ${mask1}
		applywarp --ref=${ppsc}/${sbj}/fs_t1_brain.nii.gz --in=${mask1} --out=${mask2} --warp=${ppsc}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --interp=${reg_fnirt_interp}
		applywarp -i ${mask2} -r ${dwi_avg} -o ${mask3} --premat=${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat
		;;
	manual )
		fslmaths ${atlman} -thr ${idx} -uthr ${idx} -bin ${mask1}
		applywarp -i ${mask1} -r ${dwi_avg} -o ${mask3} --premat=${ppsc}/${sbj}/${atlname}_to_dwi.mat
		;;
	* )
	esac
	fslmaths ${mask3} -thr 0.5 -uthr 0.5 ${mask4}
	fslmaths ${mask3} -sub ${mask4} -thr 0.5 -bin -mul ${idx} ${mask3}
}

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

# Check directories
# -----------------
if [[ -d ${tmp} ]]; then
	printf "  + ${tmp} exists.\n"
else
	printf "  + Create ${tmp}.\n"
	mkdir -p ${tmp}
fi

# Start the SC atlas transformation
# ---------------------------------
startingtime=$(date +%s)
et=${ppsc}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC atlas transformation with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

if [[ -f ${atl} ]]; then
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - Atlas transformation was already performed!!!\n"
else
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - Transform the target atlas.\n"
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - Parcellation scheme is ${parcellation}.\n"
	fslmaths ${ppsc}/${sbj}/dwi_avg_bet_mask.nii.gz -mul 0 ${tmp}/temp_mask.nii.gz

	case ${parcellation} in

	# Atlas on the native T1 (Freesurfer)
	# -----------------------------------
	native )
		printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - Atlas: ${atlt1w}.\n"
		mris_ca_label -sdir ${sp}/${sbj}/T1w/ -l ${sp}/${sbj}/T1w/${sbj}/label/lh.cortex.label -seed 1234 ${sbj} lh ${sp}/${sbj}/T1w/${sbj}/surf/lh.sphere.reg ${ap}/${gcs_lh} ${sp}/${sbj}/T1w/${sbj}/label/lh.${atlname}.annot
		mris_ca_label -sdir ${sp}/${sbj}/T1w/ -l ${sp}/${sbj}/T1w/${sbj}/label/rh.cortex.label -seed 1234 ${sbj} rh ${sp}/${sbj}/T1w/${sbj}/surf/rh.sphere.reg ${ap}/${gcs_rh} ${sp}/${sbj}/T1w/${sbj}/label/rh.${atlname}.annot
		TMP_SUBJECTS_DIR=${SUBJECTS_DIR}
		export SUBJECTS_DIR=${sp}/${sbj}/T1w
		mri_aparc2aseg --s ${sbj} --o ${tmp}/temp_atlas.nii.gz --annot ${atlname}
		export SUBJECTS_DIR=${TMP_SUBJECTS_DIR}
		
		# Relabeling in ascending order
		# -----------------------------
		fslmaths ${tmp}/temp_atlas.nii.gz -mul 0 ${tmp}/temp.nii.gz
		case ${atlname} in

		# Schaefer 100-Parcel 7-Network
		# -----------------------------
		Schaefer2018_100Parcels_7Networks )
			nLabel=0
			for i in {1001..1050} {2001..2050}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 200-Parcel 7-Network
		# -----------------------------
		Schaefer2018_200Parcels_7Networks )
			nLabel=0
			for i in {1001..1100} {2001..2100}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Schaefer 300-Parcel 7-Network
		# -----------------------------
		Schaefer2018_300Parcels_7Networks )
			nLabel=0
			for i in {1001..1150} {2001..2150}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 400-Parcel 7-Network
		# -----------------------------
		Schaefer2018_400Parcels_7Networks )
			nLabel=0
			for i in {1001..1200} {2001..2200}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 500-Parcel 7-Network
		# -----------------------------
		Schaefer2018_500Parcels_7Networks )
			nLabel=0
			for i in {1001..1250} {2001..2250}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 600-Parcel 7-Network
		# -----------------------------
		Schaefer2018_600Parcels_7Networks )
			nLabel=0
			for i in {1001..1300} {2001..2300}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 700-Parcel 7-Network
		# -----------------------------
		Schaefer2018_700Parcels_7Networks )
			nLabel=0
			for i in {1001..1350} {2001..2350}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 800-Parcel 7-Network
		# -----------------------------
		Schaefer2018_800Parcels_7Networks )
			nLabel=0
			for i in {1001..1400} {2001..2400}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 900-Parcel 7-Network
		# -----------------------------
		Schaefer2018_900Parcels_7Networks )
			nLabel=0
			for i in {1001..1450} {2001..2450}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 1000-Parcel 7-Network
		# ------------------------------
		Schaefer2018_1000Parcels_7Networks )
			nLabel=0
			for i in {1001..1500} {2001..2500}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 100-Parcel 17-Network
		# ------------------------------
		Schaefer2018_100Parcels_17Networks )
			nLabel=0
			for i in {1001..1050} {2001..2050}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Schaefer 200-Parcel 17-Network
		# ------------------------------
		Schaefer2018_200Parcels_17Networks )
			nLabel=0
			for i in {1001..1100} {2001..2100}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Schaefer 300-Parcel 17-Network
		# ------------------------------
		Schaefer2018_300Parcels_17Networks )
			nLabel=0
			for i in {1001..1150} {2001..2150}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 400-Parcel 17-Network
		# ------------------------------
		Schaefer2018_400Parcels_17Networks )
			nLabel=0
			for i in {1001..1200} {2001..2200}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 500-Parcel 17-Network
		# ------------------------------
		Schaefer2018_500Parcels_17Networks )
			nLabel=0
			for i in {1001..1250} {2001..2250}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 600-Parcel 17-Network
		# ------------------------------
		Schaefer2018_600Parcels_17Networks )
			nLabel=0
			for i in {1001..1300} {2001..2300}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 700-Parcel 17-Network
		# ------------------------------
		Schaefer2018_700Parcels_17Networks )
			nLabel=0
			for i in {1001..1350} {2001..2350}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 800-Parcel 17-Network
		# ------------------------------
		Schaefer2018_800Parcels_17Networks )
			nLabel=0
			for i in {1001..1400} {2001..2400}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 900-Parcel 17-Network
		# ------------------------------
		Schaefer2018_900Parcels_17Networks )
			nLabel=0
			for i in {1001..1450} {2001..2450}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Schaefer 1000-Parcel 17-Network
		# -------------------------------
		Schaefer2018_1000Parcels_17Networks )
			nLabel=0
			for i in {1001..1500} {2001..2500}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
			
		# Harvard-Oxford 96-Parcel
		# ------------------------
		HarvardOxford_96Parcels )
			nLabel=0
			for i in $(seq 1001 2 1095) $(seq 2002 2 2096)
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Kleist 98-Parcel
		# ----------------
		Kleist_98Parcels )
			nLabel=0
			for i in {1001..1049} {2001..2049}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Flechsig 92-Parcel
		# ------------------
		Flechsig_92Parcels )
			nLabel=0
			for i in {1001..1046} {2001..2046}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Smith 88-Parcel
		# ---------------
		Smith_88Parcels )
			nLabel=0
			for i in {1001..1044} {2001..2044}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Brodmann 78-Parcel
		# ------------------
		Brodmann_78Parcels )
			nLabel=0
			for i in {1001..1039} {2001..2039}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Desikan-Killiany-Tourville (DKT) atlas
		# --------------------------------------
		DKTaparc.atlas.acfb40.noaparc.i12.2020-05-13 )
			nLabel=0
			for i in 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1034 1035 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2034 2035
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Desikan-Killiany (DK) atlas (xh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02)
		# ----------------------------------------------------------------------------
		DesikanKilliany_68Parcels )
			nLabel=0
			for i in 1001 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 2001 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# AICHA (Atlas of Intrinsic Connectivity of Homotopic Areas)
		# ----------------------------------------------------------
		aicha_7p1 )
			nLabel=0
			for i in {1002..1173} {2002..2173}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Shen atlas
		# ----------
		shen268cort_6p0 )
			nLabel=0
			for i in {1002..1115} {2002..2120}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		* )
			nLabel=0
			for i in ${labels}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		esac
		num=${nLabel}

		# Add subcortical areas
		# ---------------------
		for i in 10 11 12 13 17 18 26 49 50 51 52 53 54 58
		do
			(( nLabel++ ))
			fslmaths ${aseg} -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
		done
		num=${nLabel}

		mv ${tmp}/temp.nii.gz ${atlt1w}
		fslreorient2std ${atlt1w} ${atlt1w}
		if [[ -f ${atlt1w} ]]; then
			printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - ${atlt1w} has been saved.\n"
		else
			printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - ${atlt1w} has not been saved!!\n"
			exit 1
		fi
		;;

	# Atlas on the MNI152 T1 1mm (standard)
	# -------------------------------------
	mni152 )
		printf "${GRN}[Freesurfer & FSL]${RED} ID: ${sbj}${NCR} - Atlas: ${atlmni}.\n"
		nLabel=${num}
		;;
	
	# Atlas on the native T1 (volumetric manual)
	# ------------------------------------------
	manual )
		printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Atlas: ${atlman}.\n"
		nLabel=${num}
		flirt -in ${bg_t1w} -ref ${ppsc}/${sbj}/temp/t1w_bc_reori.nii.gz -omat ${ppsc}/${sbj}/temp/${atlname}_to_t1w_bc_reori.mat -out ${ppsc}/${sbj}/temp/${atlname}_to_t1w_bc_reori.nii.gz -dof 6 -cost normcorr
		flirt -in ${ppsc}/${sbj}/temp/t1w_acpc.nii.gz -ref ${ppsc}/${sbj}/fs_t1.nii.gz -omat ${ppsc}/${sbj}/temp/t1w_acpc_to_fs_t1.mat -dof 6 -cost normcorr

		convert_xfm -omat ${ppsc}/${sbj}/temp/${atlname}_to_t1w_acpc.mat -concat ${ppsc}/${sbj}/temp/acpc.mat ${ppsc}/${sbj}/temp/${atlname}_to_t1w_bc_reori.mat
		convert_xfm -omat ${ppsc}/${sbj}/temp/${atlname}_to_fs_t1.mat -concat ${ppsc}/${sbj}/temp/t1w_acpc_to_fs_t1.mat ${ppsc}/${sbj}/temp/${atlname}_to_t1w_acpc.mat
		convert_xfm -omat ${ppsc}/${sbj}/${atlname}_to_dwi.mat -concat ${ppsc}/${sbj}/dwi_to_fs_t1_invaffine.mat ${ppsc}/${sbj}/temp/${atlname}_to_fs_t1.mat
		;;
	* )
	esac
	
	# Transform an atlas to the diffusion space
	# -----------------------------------------
	nThr=0
	for (( i = 1; i < num + 1; i++ ))
	do
		Transform ${i} &
		(( nThr++ ))
        printf "[+] Running thread ${nThr} - index ${i}\n"
        if [[ ${nThr} -eq ${threads} ]]; then
            wait
            nThr=0
        fi
	done
	wait
	for (( i = 1; i < num + 1; i++ ))
	do
		fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_label${i}_mask3.nii.gz ${tmp}/temp_mask.nii.gz
	done
	fslmaths ${tmp}/temp_mask.nii.gz -mul ${gmneck} ${atl}
	rm -f ${tmp}/temp*.nii.gz
	if [[ -f ${atl} ]]; then
		printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - ${atl} has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - ${atl} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} ${atlname}" >> ${et}
fi

echo "[-] SC atlas transformation - $(date)" >> ${et}