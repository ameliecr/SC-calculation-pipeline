1. First the space of the atlas is checked. This is indeed the MNI152 nonlinear space

2. The resolution of the atlas image (4 mm) and the coordinates are not consistent with MNI templates. To make it consistent
    - because of the poor resolution, the image has to be diluted with a box of 12 mm
    - the atlas is reoriented to the standard orientation;
    - a 4 mm resolution variant of the MNI152 nonlinear template is made;
    - the atlas is co-registered to this template to accounts for wrong coordinates in the atlas image
    - the 4 mm resolution variant is linearly transformed to the 1mm variant and the transformation matrix is recorded;
    - the atlas image is warped to obtain its 1 mm variant.

3. The atlas is already in the MNI152 nonlinear template space, so no additional (nonlinear) transformations are necessary

4. The atlas contains cerebellar and sucortical regions, which are eliminated by
    - compiling a grey matter mask from the ribbon.mgz file of the MNI FreeSurfer "subject";
    - transforming this grey matter mask to the MNI152 nonlinear template coordinate system;
      1. First the brain image of the MNI FreeSurfer subject is acquired
      2. Subsequently, this image is reoriented to the standard orientation and co-registered with the valid MNI152 nonlinear template
      3. The transformation matrix of this coregistration is subsequently applied to the grey matter mask
      4. Finally, the mask is diluted
    - multiplying the atlas images with the warped grey matter masks;
    - eliminating invaluable labels from the parcellation scheme;
      - Here, the threshold is set to a minimum of 500 voxels that should be included in a parcel; otherwise, structural connectivity estimation is likely to fail
