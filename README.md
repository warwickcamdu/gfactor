# gfactor
Laura Cooper, camdu@warwick.ac.uk

ImageJ macros to calculate gfactor and gmap values for cell images

Requires: [MorphoLibJ](https://imagej.net/plugins/morpholibj), [MultiStackReg](https://github.com/miura/MultiStackRegistration), [ijl-utilities-wrappers](https://github.com/BIOP/ijl-utilities-wrappers) for [cellpose](https://github.com/MouseLand/cellpose)

## 1. RegisterAndConcat

Register the image stacks and concatenate the different stacks to a single hyperstack. Run this before Auto_cellseg.

## Auto_cellseg

Uses cellpose to automatically segment cells. Need to run this before generateGfacAndGPmaps.

## generateGfacAndGPmaps

Takes blue and red image stacks and and calculated gfactor and gpmaps. Need to run this before selectRois.

## selectRois

Allows the users to use the multipoint tool to choose place square ROIs in the cells to measure intensity in blue and red_gfac images and create a table for plotting.

# References

Schindelin, J., Arganda-Carreras, I., Frise, E. et al. Fiji: an open-source platform for biological-image analysis. Nat Methods 9, 676–682 (2012). https://doi.org/10.1038/nmeth.2019

P. Thévenaz, U.E. Ruttimann, M. Unser, A Pyramid Approach to Subpixel Registration Based on Intensity, IEEE Transactions on Image Processing, vol. 7, no. 1, pp. 27-41, January 1998.

Stringer, C., Wang, T., Michaelos, M., & Pachitariu, M. (2021). Cellpose: a generalist algorithm for cellular segmentation. Nature methods, 18(1), 100-106.

Stringer, C. & Pachitariu, M. (2024). Cellpose3: one-click image restoration for improved segmentation. bioRxiv.

David Legland, Ignacio Arganda-Carreras, Philippe Andrey, MorphoLibJ: integrated library and plugins for mathematical morphology with ImageJ, Bioinformatics, Volume 32, Issue 22, November 2016, Pages 3532–3534, https://doi.org/10.1093/bioinformatics/btw413
