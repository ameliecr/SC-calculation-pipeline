1. First the space of the atlas is checked. This is indeed the MNI152 nonlinear space

2. The resolution of the atlas image and the coordinates are consistent with MNI templates.

3. The atlas is already in the MNI152 nonlinear template space, so no additional (nonlinear) transformations are necessary

4. The atlas contains only cortical regions, so the image only needs to be thinned.
   - compiling a grey matter mask from the ribbon.mgz file of the MNI FreeSurfer "subject";
    - transforming this grey matter mask to the MNI152 nonlinear template coordinate system;
      1. First the brain image of the MNI FreeSurfer subject is acquired
      2. Subsequently, this image is reoriented to the standard orientation and co-registered with the valid MNI152 nonlinear template
      3. The transformation matrix of this coregistration is subsequently applied to the grey matter mask
      4. Finally, the mask is diluted
    - multiplying the atlas images with the warped grey matter masks;