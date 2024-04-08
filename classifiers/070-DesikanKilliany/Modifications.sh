#!/bin/bash

# Define variables required to run the scripts
atlas_name=070-DesikanKilliany
class_name=curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs
subject=MNI
num_par=70
dilution=3

# Create the volumetric atlas in FreeSurfer coordinates

echo ""
echo "Create annotation files for subject $subject"
mris_ca_label $subject lh sphere.reg lh.$class_name lh.$atlas_name.annot > /dev/null
mris_ca_label $subject rh sphere.reg rh.$class_name rh.$atlas_name.annot > /dev/null

echo ""
echo "Create volumetric atlas file (.mgz) for subject $subject"
mri_aparc2aseg \
    --s $subject \
    --o $atlas_name.mgz \
    --annot $atlas_name \
    > /dev/null 2>&1

# Transform atlas image from FreeSurfer space to valid MNI152 nonlinear template space (1 mm)

echo ""
echo "Convert the volumetric atlas file to a nifti image and reorient it"
mri_convert $atlas_name.mgz $atlas_name.nii.gz > /dev/null
fslreorient2std $atlas_name $atlas_name >> /dev/null

echo ""
echo "Retrieve brain image and converting and reorient it"
mri_convert $SUBJECTS_DIR/$subject/mri/brain.mgz brain.nii.gz >> /dev/null
fslreorient2std brain brain >> /dev/null
fslreorient2std $atlas_name $atlas_name >> /dev/null

echo ""
echo "Transform the brain to valid MNI152 nonlinear template space (1 mm)"
flirt \
    -in brain \
    -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain \
    -omat to_mni_1mm.mat \
    -interp trilinear \
    -cost mutualinfo \
    -dof 6

echo ""
echo "Warp the atlas image with this transformation matrix"
applywarp \
    -i $atlas_name \
    -r $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz \
    -o $atlas_name \
    --interp=nn \
    --premat=to_mni_1mm.mat

# Convert the FreeSurfer volumetric atlas file to a nifti image with valid labels

echo ""
echo "Converting the volumetric atlas file to a nifti image with valid labels"
fslmaths $atlas_name -thr 1001 -uthr 1999 leftgm
fslmaths $atlas_name -thr 2001 -uthr 2999 rightgm
fslmaths leftgm -sub 1000 -thr 0 leftgm
fslmaths rightgm -sub 2000 -add $(($num_par/2)) -thr 0 rightgm
cp leftgm.nii.gz $atlas_name.nii.gz
fslmaths $atlas_name -add rightgm $atlas_name

echo ""
echo "Dilate the atlas image"
fslmaths $atlas_name -kernel box $dilution -dilD $atlas_name-1mm

echo ""
echo "Create 2 mm variant of atlas image"
flirt \
    -in $atlas_name-1mm \
    -ref $atlas_name-1mm \
    -out $atlas_name-2mm \
    -applyisoxfm 2 \
    -interp nearestneighbour \
    -cost mutualinfo \
    -dof 6

# Clean up the temporary files
echo ""
echo "Cleaning up the temporary files"
rm \
    $atlas_name.mgz \
    $atlas_name.nii.gz \
    brain* \
    left* \
    right* \
    to*
