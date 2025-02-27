#@ File (label = "Input image directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output

close("*");
list = getFileList(input);
list_C0=order_files(Array.filter(list,"C0.tif"));
for (i = 0; i < list_C0.length; i++) {
	open(input + File.separator + list_C0[i]);
	run("Duplicate...", "ignore duplicate range=2-4");
	title_C0=getTitle();
	core_name=split(list_C0[i],"C");
	open(input+File.separator+"C" + core_name[0] + "C1.tif");
	run("Duplicate...", "ignore duplicate range=2-4");
	title_C1=getTitle();
	register_red(title_C0,title_C1,core_name,output);
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
	saveAs("Tiff",output+File.separator+"C" + core_name[0]+"C0-aligned.tif");
}

