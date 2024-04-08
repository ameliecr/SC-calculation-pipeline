1. First the space of the atlas is checked. This is not the MNI152 nonlinear space.

2. As the atlas is not in the MNI152 nonlinear template space, checking its coordinates and resolution is irrelevant.

3. Since the atlas is not in the MNI152 nonlinear template space, it first has to be transformed to it:
    - The atlas and template images are reoriented to the right orientation
    - The brain is extracted from the template by multiplying it with the mask
    - Subsequently the resolution of the original template is decreased to 2mm to make it compatible with the MNI152 nonlinear template with 2 mm resolution (easier with respect to nonlinear transformation)
    - The template brain is co-registered with the MNI152 nonlinear template brain with 2mm resolution; the transformation matrix is recorded
    - The template brain is nonlinearly transformed to the MNI152 nonlinear template brain with 2 mm resolution; FSL has a configuration file for this transformation
    - The atlas image is warped to the MNI152 nonlinear template space with 2mm resolution
    - The MNI152 nonlinear template with 2mm resolution is co-registered with its 1 mm variant and the transformation matrix is record.
    - The atlas image is warped to the 1 mm MNI152 nonlinear template space.

4. The atlas contains cerebellar and sucortical regions, which are eliminated by
    - compiling a grey matter mask from the ribbon.mgz file of the MNI FreeSurfer "subject";
    - transforming this grey matter mask to the MNI152 nonlinear template coordinate system;
      1. First the brain image of the MNI FreeSurfer subject is acquired.
      2. Subsequently, this image is reoriented to the standard orientation and co-registered with the valid MNI152 nonlinear template.
      3. The transformation matrix of this coregistration is subsequently applied to the grey matter mask
    - multiplying the atlas images with the warped grey matter masks;
    - eliminating invaluable labels from the parcellation scheme;
      - Here, the threshold is set to a minimum of 500 voxels that should be included in a parcel; otherwise, structural connectivity estimation is likely to fail
    - diluting the atlas image to ensure that all gray matter would be considered in the extraction of the empirical data from the MRI images
