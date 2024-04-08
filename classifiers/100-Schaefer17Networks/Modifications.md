1. First the space of the atlas is checked. This is indeed the MNI152 nonlinear space as we are dealing with a native atlas.

2. The resolution but not the coordinates of the atlas image are consistent with MNI templates. The atlas is therefore transformed to the standard coordinate space via the `brain.mgz` file from the FreeSurfer MNI subject.
    1. First the brain image of the MNI FreeSurfer subject is acquired
    2. Subsequently, this image is reoriented to the standard orientation and co-registered with the valid MNI152 nonlinear template
    3. The transformation matrix of this coregistration is subsequently applied to the atlas image
       - interpolation method: nearest-neighbour
       - cost function: mutual information
       - degrees of freedom: 6

3. The atlas is already in the MNI152 nonlinear template space, so no additional (nonlinear) transformations are necessary

4. The atlas contains subcortical and cerebellar regions, so these are eliminated from the atlas
    - It is a native atlas, so subcortical, cerebellar and white matter structures are easily removed using mathematical operations
    - The atlas image is diluted with a 3 mm box to ensure coverage