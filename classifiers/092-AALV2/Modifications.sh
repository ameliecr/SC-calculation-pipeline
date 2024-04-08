#!/bin/bash

# Script used to keep only the cortical parcels of the AAL atlas

# Define some initial parameters
general_name=AALV2
orig_file=aal2
orig_template=colin27_t1_tal_lin
orig_mask=colin27_t1_tal_lin_mask
n_parcels=120
threshold=500
dilution=3

# As the atlas is not in the MNI152 nonlinear template space, transform it to it

echo ""
echo "Reorient all files to the standard orientation to avoid mistakes"
fslreorient2std $orig_file $orig_file-reoriented
fslreorient2std $orig_template $orig_template-reoriented
fslreorient2std $orig_mask $orig_mask-reoriented

echo ""
echo "Extract the brain from the template image"
fslmaths $orig_template-reoriented -mul $orig_mask-reoriented $orig_template-betted

echo ""
echo "Decrease the resolution of the original template to make it compatible with the atlas"
flirt \
	-in $orig_template-betted \
	-ref $orig_template-betted \
	-out $orig_template-downsampled \
	-applyisoxfm 2 \
	-interp trilinear \
	> /dev/null

echo ""
echo "Co-register the original template to the MNI152 2 mm template"
flirt \
	-in $orig_template-downsampled \
	-ref $FSLDIR/data/standard/MNI152_T1_2mm_brain \
	-omat colin_to_MNI_2mm.mat \
	-interp trilinear \
	-cost mutualinfo \
	-dof 6 \
	> /dev/null

echo ""
echo "Non-linearly transform the original template to the MNI152 2mm template"
fnirt \
	--in=$orig_template-downsampled \
	--ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain \
	--aff=colin_to_MNI_2mm.mat \
	--config=T1_2_MNI152_2mm \
	--iout=colin_MNIzed \
	--cout=colin_to_MNI_2mm

echo ""
echo "Warp atlas image co-registered to the original template to the MNI152 2mm template space"
applywarp \
	--in=$orig_file-reoriented \
	--ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain \
	--out=$orig_file-MNI-2mm \
	--warp=colin_to_MNI_2mm \
	--premat=colin_to_MNI_2mm.mat \
	--interp=nn

echo ""
echo "Co-register the MNI152 nonlinear template with 2 mm resolution with the one with 1 mm resolution"
flirt \
	-in $FSLDIR/data/standard/MNI152_T1_2mm_brain \
	-ref $FSLDIR/data/standard/MNI152_T1_1mm_brain \
	-omat 2mm_to_1mm.mat \
	-interp trilinear \
	-cost mutualinfo \
	-dof 6 \
	> /dev/null

echo ""
echo "Warp the atlas image to the standard MNI152 nonlinear template space with 1 mm resolution"
applywarp \
	--in=$orig_file-MNI-2mm \
	--ref=$FSLDIR/data/standard/MNI152_T1_1mm_brain \
	--out=$orig_file-MNI-1mm \
	--interp=nn \
	--premat=2mm_to_1mm.mat

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
	colin_* \
	colin27_t1_tal_lin-* \
	colin27_t1_tal_lin_mask-* \
	grey_mask* \
	$orig_file-* \
	ribbon* \
	temp*
