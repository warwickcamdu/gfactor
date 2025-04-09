#@ File (label = "Input registered red image stack") input_C0
#@ File (label = "Input blue image stack") input_C1
#@ File (label = "Input cellmask stack") cellmask_input
#@ File (label = "Gfac red") gfac_red
#@ File (label = "Gfac blue") gfac_blue
#@ File (label = "DMSO red") dmso_red
#@ File (label = "DMSO blue") dmso_blue
#@ File (label = "Output directory", style = "directory") output

close("*");
gfac_image=create_gfac(gfac_blue,dmso_blue,gfac_red,dmso_red);
open(input_C0);
C0stack=getTitle();
run("32-bit");
open(input_C1);
C1stack=getTitle();
run("32-bit");
core_name_string="test"
create_gmap(C0stack,C1stack,dmso_red,dmso_blue,gfac_image,output,core_name_string);
open(cellmask_input);
cellmask_stack=getTitle();
for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=z"+i+"_r%03d");
}
selectWindow(cellmask_stack);
close();
clear_bg_set_LUT_and_save("C0-gfac")
clear_bg_set_LUT_and_save("total_intensity")
clear_bg_set_LUT_and_save("GPmap")
close("*");

function create_gmap(title_C0,title_C1,dmso_red,dmso_blue,gfac_image,output,core_name_string){
	open(dmso_red);
	run("32-bit");
	dsmo_red_image=getTitle();
	imageCalculator("Subtract create stack", title_C0,dsmo_red_image);
	rename("red_aligned_bg");
	open(dmso_blue);
	run("32-bit");
	dsmo_blue_image=getTitle();
	imageCalculator("Subtract create stack", title_C1,dsmo_blue_image);
	rename("blue_bg");
	imageCalculator("Multiply create stack", "red_aligned_bg",gfac_image);
	image=getTitle();
	rename("C0-gfac");
	imageCalculator("Subtract create stack", "blue_bg","C0-gfac");
	rename("gpmap_nom");
	imageCalculator("Add create stack", "blue_bg","C0-gfac");
	rename("total_intensity");
	imageCalculator("Divide create stack", "gpmap_nom","total_intensity");
	rename("GPmap");
}


function create_gfac(gfac_blue,dmso_blue,gfac_red,dmso_red){
open(gfac_blue)
run("32-bit");
title_gfac=getTitle();
open(dmso_blue)
run("32-bit");
title_dmso=getTitle();
imageCalculator("Subtract create", title_gfac,title_dmso);
rename("blueldn_bg");
selectWindow(title_gfac);
selectWindow(title_dmso);

open(gfac_red)
run("32-bit");
title_gfac=getTitle();
open(dmso_red)
run("32-bit");
title_dmso=getTitle();
imageCalculator("Subtract create", title_gfac,title_dmso);
rename("redldn_bg");
selectWindow(title_gfac);
selectWindow(title_dmso);

imageCalculator("Subtract create", "blueldn_bg","redldn_bg");
rename("gpmes_num");
imageCalculator("Add create", "blueldn_bg","redldn_bg");
rename("gpmes_denom");
run("Calculator Plus", "i1=gpmes_num i2=gpmes_denom operation=[Divide: i2 = (i1/i2) x k1 + k2] k1=1 k2=0 create");
rename("gpmes");
selectImage("gpmes_num");
close();
selectImage("gpmes_denom");
close();
saveAs("Tiff", output+File.separator+"gpmes.tif");
selectImage("gpmes.tif");
close("\\Others");
run("Duplicate...", "title=gpmes");
run("Multiply...", "value=207");
rename("gpmes*ref");

run("Duplicate...", "title=gpmes*ref");
run("Add...", "value=0.207");
rename("gpmes*refplus");

imageCalculator("Subtract", "gpmes*refplus","gpmes.tif");
run("Subtract...", "value=1");
rename("gfac_num");

selectImage("gpmes*ref");
imageCalculator("Add", "gpmes*ref","gpmes.tif");
run("Subtract...", "value=0.207");
run("Subtract...", "value=1");
rename("gfac_denom");

selectImage("gpmes.tif");
close();

run("Calculator Plus", "i1=gfac_num i2=gfac_denom operation=[Divide: i2 = (i1/i2) x k1 + k2] k1=1 k2=0 create");
rename("gfac");
saveAs("Tiff", output+File.separator+"gfac.tif");
gfac_name=getTitle();
close("\\Others");
return gfac_name;
}


function clear_bg_set_LUT_and_save(image){
	selectImage(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= frames; i++) {
    	roiArray=findRoisWithName("z"+i+"_");
    	roiManager("Select", roiArray);	
    	roiManager("combine");
    	run("Make Inverse");
    	for (j = 1; j <= 3; j++) {
    		Stack.setPosition(1, j, i);
    		run("Set...", "value=NaN slice");
		}
		run("Select None");
	}
	run("mpl-viridis");
	run("Specify...", "width=2200 height=2200 x=100 y=100 slice=1");
	run("Crop");
	saveAs("Tiff", output+File.separator+image+".tif");
	//run("Calibration Bar...", "location=[Separate Image] fill=White label=Black number=5 decimal=1 font=12 zoom=3 overlay");
	//saveAs("Tiff", output+File.separator+image+"_cbar.tif");
}

function findRoisWithName(roiName) { 
	nR = roiManager("Count"); 
	roiIdx = newArray(nR); 
	k=0; 
	clippedIdx = newArray(0); 
	 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (rName.startsWith(roiName)) { 
			roiIdx[k] = i; 
			k++; 
		} 
	} 
	if (k>0) { 
		clippedIdx = Array.trim(roiIdx,k); 
	} 
	 
	return clippedIdx; 
} 