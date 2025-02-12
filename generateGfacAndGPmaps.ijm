#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Gfac blue") gfac_blue
#@ File (label = "Gfac red") gfac_red
#@ File (label = "DMSO blue") dmso_blue
#@ File (label = "DMSO red") dmso_red
#@ File (label = "Output directory", style = "directory") output

close("*");
list = getFileList(input);
list_C0=order_files(Array.filter(list,"C0.tif"));
gfac_image=create_gfac(gfac_blue,dmso_blue,gfac_red,dmso_red);
for (i = 0; i < list_C0.length; i++) {
	open(input + File.separator + list_C0[i]);
	run("32-bit");
	run("Duplicate...", "ignore duplicate range=2-4");
	title_C0=getTitle();
	core_name=split(list_C0[i],"C");
	open(input+File.separator+"C" + core_name[0] + "C1.tif");
	run("32-bit");
	run("Duplicate...", "ignore duplicate range=2-4");
	title_C1=getTitle();
	register_red(title_C0,title_C1,core_name,output);
	title_C0=getTitle();
	create_gmap(title_C0,title_C1,dmso_red,dmso_blue,gfac_image,output,core_name);
}

function order_files(list){
	numbers=newArray(list.length);
	for(l=0; l<list.length; l++){
		index = lastIndexOf(list[l], "-");
		number = IJ.pad(substring(list[l], index+2),10);
		numbers[l]=number;
	}
	Array.sort(numbers, list);
	return list;
}

function create_gmap(title_C0,title_C1,dmso_red,dmso_blue,gfac_image,output,core_name){
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
	saveAs("Tiff", output+File.separator+"C" + core_name[0]+"C0-gfac.tif");
	rename("red-gfac");
	imageCalculator("Subtract create stack", "blue_bg","red-gfac");
	rename("gpmap_nom");
	imageCalculator("Add create stack", "blue_bg","red-gfac");
	rename("gpmap_denom");
	imageCalculator("Divide create stack", "gpmap_nom","gpmap_denom");
	saveAs("Tiff", output+File.separator+"C" + core_name[0]+"GPmap.tif");
	selectWindow(gfac_image);
	close("\\Others");
}

function register_red(title_C0,title_C1,core_name,output){
	run("MultiStackReg", "stack_1=["+title_C1+"] action_1=[Use as Reference] file_1=[] stack_2=["+title_C0+"] action_2=[Align to First Stack] file_2=["+output+File.separator+"C"+core_name[0]+"_TransformationMatrix.txt"+"] transformation=[Rigid Body] save");
	if (i==0){
	//display the first as composite and check user happy.
	selectWindow(title_C0);
	run("Merge Channels...", "c1=["+title_C0+"] c2=["+title_C1+"] create keep");
	run("Brightness/Contrast...");
	waitForUser("Happy with result? Click OK to proceed");
	close();
	setBatchMode(true);
	}
	selectWindow(title_C0);
	save(output+File.separator+"C" + core_name[0]+"C0-aligned.tif");
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

