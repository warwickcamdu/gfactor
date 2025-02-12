/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output with filename but no suffix") output
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
	concatenate(input,list_C0,output,"C0.tif")
	list_C1=order_files(Array.filter(list,"C1.tif"));
	concatenate(input,list_C1,output,"C1.tif")
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

//Remove std, concatenate just slices 2,3, and 4
function concatenate(input,list,output,filter){
	setBatchMode(true);
		for (i = 0; i < list.length; i++) {	
			if (endsWith(list[i], suffix)){
				open(input + File.separator + list[i]);
				if(checkbox){
					title=getTitle();
					run("Duplicate...", "ignore duplicate range=2-4");
					selectWindow(title);
					close();
				}
			}
		}
		run("Concatenate...", "all_open title=concat open");
		saveAs("Tiff", output+"_"+filter);
		close("*");
		setBatchMode(false);
}