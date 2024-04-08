#!/bin/bash

# Script used to keep only the cortical parcels of the MIST atlas (36 parcels)

# Define some initial parameters
atlas_name=048-HarvardOxfordMaxProbThr0
orig_file=HarvardOxford-cort-maxprob-thr0
n_parcels=36
threshold=50
dilution=3

# Atlas image in standard resolution and coordinate space

# Atlas image cortical, but needs to be thinned

echo ""
echo "Compile the grey matter mask"
cp $SUBJECTS_DIR/MNI/mri/ribbon.mgz ribbon.mgz
mri_convert ribbon.mgz ribbon.nii.gz > /dev/null
fslreorient2std ribbon ribbon
fslmaths ribbon -thr 3 -uthr 3 -bin grey_mask
fslmaths ribbon -thr 42 -uthr 42 -bin temp
fslmaths grey_mask -add temp grey_mask

echo ""
echo "Determine the transformation matrices for the grey matter mask"
cp $SUBJECTS_DIR/MNI/mri/brain.mgz brain.mgz
mri_convert brain.mgz brain.nii.gz > /dev/null
fslreorient2std brain brain
flirt \
    -in brain \
    -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain \
    -omat to_mni_1mm.mat \
    -interp trilinear \
    -cost mutualinfo \
    -dof 6

echo ""
echo "Warp the grey matter mask to the valid MNI152 nonlinear template spaces"
applywarp \
    -i grey_mask \
    -r $FSLDIR/data/standard/MNI152_T1_1mm_brain \
    -o grey_mask-MNI-1mm \
    --interp=nn \
    --premat=to_mni_1mm.mat

echo ""
echo "Dilute the grey matter mask with the specified dilution size"
fslmaths grey_mask-MNI-1mm -kernel box $dilution -dilD grey_mask-MNI-1mm

echo ""
echo "Multiply the atlas images with the grey matter masks"
fslmaths $orig_file-1mm -mul grey_mask-MNI-1mm $atlas_name-1mm

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

# Clean up
rm \
    *.mat \
    brain* \
    grey_mask* \
    ribbon* \
    temp*
