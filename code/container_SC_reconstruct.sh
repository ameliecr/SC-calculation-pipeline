#!/bin/bash -x

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
case ${parcellation} in
native )
	atl=${ppsc}/${sbj}/${atlname}_to_dwi_${parcellation}+subctx.nii.gz
;;
mni152 )
	atl=${ppsc}/${sbj}/${atlname}_to_dwi_${parcellation}.nii.gz
;;
manual )
	atl=${ppsc}/${sbj}/${atlname}_to_dwi_${parcellation}.nii.gz
;;
esac

# Tensor images
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

if [[ ${tract} -gt 999999 ]]; then
	tractM=$((${tract}/1000000))M
else
	if [[ ${tract} -gt 999 ]]; then
		tractM=$((${tract}/1000))K
	else
		tractM=${tract}
	fi
fi

# Start the SC reconstruct
# ------------------------
startingtime=$(date +%s)
et=${ppsc}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC reconstruct for ${tractM} with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

tck=${ppsc}/${sbj}/WBT_${tractM}_ctx.tck
odfWM=${ppsc}/${sbj}/odf_wm.mif
counts_sift2=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_countsift2.csv
sift2_weight_per_streamline=${ppsc}/${sbj}/${tractM}_sift2weight_per_streamline.csv
counts=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_count.csv
lengths=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_length.csv
fas=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_fa.csv
mean_fa_per_streamline=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_mean_fa_per_streamline.csv
mds=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_md.csv
mean_md_per_streamline=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_mean_md_per_streamline.csv
ads=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_ad.csv
mean_ad_per_streamline=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_mean_ad_per_streamline.csv
rds=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_rd.csv
mean_rd_per_streamline=${ppsc}/${sbj}/${atlname}_${tractM}_${parcellation}_mean_rd_per_streamline.csv

# SC Reconstruct SIFT2 filtered
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (counts - SIFT2 filtered).\n"
if [[ -f ${sift2_weight_per_streamline} ]]; then
	printf "SIFT2 weighting per streamline has already been calcuated. Skipping this step.\n"
else
	tcksift2 -force -nthreads ${threads} ${tck} ${odfWM} ${sift2_weight_per_streamline}
fi
tck2connectome -symmetric -force -nthreads ${threads} -assignment_radial_search ${tck2connectome_assignment_radial_search} -tck_weights_in ${sift2_weight_per_streamline} ${tck} ${atl} ${counts_sift2}
if [[ -f ${counts_sift2} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${counts_sift2} has been saved.\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${counts_sift2} has not been saved!!\n"
	exit 1
fi

# SC Reconstruct
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (counts).\n"
tck2connectome -symmetric -force -nthreads ${threads} -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${counts}
if [[ -f ${counts} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${counts} has been saved.\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${counts} has not been saved!!\n"
	exit 1
fi

# PL Reconstruct
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (lengths).\n"
tck2connectome -symmetric -force -nthreads ${threads} -scale_length -stat_edge mean -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${lengths}
if [[ -f ${lengths} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${lengths} has been saved.\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${lengths} has not been saved!!\n"
	exit 1
fi


# FA Reconstruct
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (FA).\n"
echo ${tck}
echo ${fa}
echo ${fas}
echo ${mean_fa_per_streamline}
tcksample ${tck} ${fa} ${mean_fa_per_streamline} -stat_tck mean
tck2connectome -symmetric -force -nthreads ${threads} -scale_file ${mean_fa_per_streamline} -stat_edge mean -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${fas}
if [[ -f ${fas} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${fas} has been saved.\n"
	if [[ -f ${mean_fa_per_streamline} ]]; then
		rm ${mean_fa_per_streamline}
	fi
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${fas} has not been saved!!\n"
	exit 1
fi

# MD Reconstruct
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (MD).\n"
tcksample ${tck} ${md} ${mean_md_per_streamline} -stat_tck mean
tck2connectome -symmetric -force -nthreads ${threads} -scale_file ${mean_md_per_streamline} -stat_edge mean -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${mds}
if [[ -f ${mds} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${mds} has been saved.\n"
	if [[ -f ${mean_md_per_streamline} ]]; then
		rm ${mean_md_per_streamline}
	fi
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${mds} has not been saved!!\n"
	exit 1
fi

# AD Reconstruct
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (AD).\n"
tcksample ${tck} ${ad} ${mean_ad_per_streamline} -stat_tck mean
tck2connectome -symmetric -force -nthreads ${threads} -scale_file ${mean_ad_per_streamline} -stat_edge mean -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${ads}
if [[ -f ${ads} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${ads} has been saved.\n"
	if [[ -f ${mean_ad_per_streamline} ]]; then
		rm ${mean_ad_per_streamline}
	fi
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${ads} has not been saved!!\n"
	exit 1
fi

# RD Reconstruct
# --------------
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Reconstruct structural connectivity (RD).\n"
tcksample ${tck} ${rd} ${mean_rd_per_streamline} -stat_tck mean
tck2connectome -symmetric -force -nthreads ${threads} -scale_file ${mean_rd_per_streamline} -stat_edge mean -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${rds}
if [[ -f ${rds} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${rds} has been saved.\n"
	if [[ -f ${mean_rd_per_streamline} ]]; then
		rm ${mean_rd_per_streamline}
	fi
else
	printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - ${rds} has not been saved!!\n"
	exit 1
fi

# Elapsed time
# ------------
elapsedtime=$(($(date +%s) - ${startingtime}))
printf "${GRN}[MRtrix]${RED} ID: ${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
echo "    ${elapsedtime} tck2connectome" >> ${et}

echo "[-] SC reconstruct for ${tractM} - $(date)" >> ${et}