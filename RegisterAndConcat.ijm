/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ boolean (label = "Find and keep 2, 3 and 4 planes only?") checkbox

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

close("*");
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	substrs=newArray("C0","C1");
	list = getFileList(input);
	list_C0=order_files(Array.filter(list,"C0.tif"));
	list_C1=order_files(Array.filter(list,"C1.tif"));
	if (list_C0.length != list_C1.length){
		exit("There are different numbers of red/C0 and blue/C1 images. Stopping Macro)"
	}
	for (i = 0; i < list_C0.length; i++) {	
		open(input + File.separator + list_C0[i]);
		title=getTitle();
		core_name=substring(title,0,lengthOf(title)-6);
		C0_title=get_substack(title);
		open(input + File.separator + list_C1[i]);
		title=getTitle();
		C1_title=get_substack(title);
		register_red(C0_title,C1_title,core_name,output);
		close("*");
	}
	setBatchMode(false);
	for (i = 0; i < list_C1.length; i++) {	
		open(input + File.separator + list_C1[i]);
		title=getTitle();
		C1_title=get_substack(title);
	}
	concatenate(core_name,output,"C1.tif");
	for (i = 0; i < list_C0.length; i++) {	
		filename=substring(list_C0[i],0,lengthOf(list_C0[i])-4);
		open(output + File.separator +filename+"-reg.tif");
	}
	concatenate(core_name,output,"C0-aligned.tif");
	
}

function register_red(title_C0,title_C1,core_name,output){
	run("MultiStackReg", "stack_1=["+title_C1+"] action_1=[Use as Reference] file_1=[] stack_2=["+title_C0+"] action_2=[Align to First Stack] file_2=["+output+File.separator+core_name+"_TransformationMatrix.txt"+"] transformation=[Rigid Body] save");
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
	saveAs("Tiff",output+File.separator+core_name+"C0-reg.tif");
}


function get_substack(orig_title){
	if(checkbox){
		orig_title=getTitle();
		title=substring(orig_title,0,lengthOf(orig_title)-4);
		run("Duplicate...", "title=["+title+"_dup] ignore duplicate range=2-4");
		selectWindow(orig_title);
		close();
		selectWindow(title+"_dup");
		rename(orig_title);
	}
	return orig_title;
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

function concatenate(core_name,output,filter){
		core_name_sub=substring(core_name,0,lengthOf(core_name)-5);
		run("Concatenate...", "all_open title=concat open");
		saveAs("Tiff", output+File.separator+"concat_"+core_name_sub+filter);
		close("*");
}