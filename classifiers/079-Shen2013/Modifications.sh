#!/bin/bash

# Script used to keep only the cortical parcels of the MIST atlas (36 parcels)

# Define some initial parameters
general_name=Shen2013
orig_file=fconn_atlas_50_1mm
n_parcels=93
threshold=500
dilution=3

# Atlas image not in standard resolution and coordinate space, so (read echo's for explanation)

echo ""
echo "Dilute the atlas image"
fslmaths $orig_file -kernel box 3 -dilD $orig_file-dil

echo ""
echo "Reorient atlas to standard orientation"
fslreorient2std $orig_file-dil $orig_file-reoriented

echo ""
echo "Linearly transform the atlas image to the MNI152 non-linear template with 1 mm resolution"
flirt \
    -in $orig_file-reoriented \
    -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain \
    -out $orig_file-MNI-1mm \
    -interp nearestneighbour \
    -cost mutualinfo \
    -dof 6 \
    > /dev/null

# Atlas image not cortical, so eliminate subcortical and cerebellar regions (read echo's for explanation)

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
fslmaths $orig_file-MNI-1mm -mul grey_mask-MNI-1mm $orig_file-MNI-1mm-cort

echo ""
echo "Determine which parcels should remain in the parcellation scheme"
for (( p=1 ; p<=$n_parcels ; p++ ))
do
    fslmaths $orig_file-MNI-1mm-cort -thr $p -uthr $p temp_1mm
    v=$(fslstats temp_1mm -V | cut -d " " -f 1)
    if [ $v -gt $(($threshold-1)) ]
    then
        i=$(($i+1))
        fslmaths temp_1mm -bin -mul $i temp_1mm
        if [ $i -eq 1 ]
        then
            cp temp_1mm.nii.gz temp_atlas.nii.gz
        else
            fslmaths temp_atlas -add temp_1mm temp_atlas
        fi
    fi
done
atlas_name=$(printf "%03d" $i)-$general_name
mv temp_atlas.nii.gz $atlas_name-1mm.nii.gz

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
    $orig_file-* \
    MNI152_T1_4mm_brain.nii.gz \
    ribbon* \
    temp*
