#@ File (label = "Cell images", style = "directory") input
#@ String (label = "Cellpose path", value="C:\\Users\\camdu\\miniconda3\\envs\\cellpose") cellpose_path
#@ String (label = "C0, C1 or C0-aligned") Cx
#@ File (label = "Output directory", style = "directory") output


	list = getFileList(input);
	list = Array.sort(list);
	list_Cx=Array.filter(list,Cx+".tif")
	for (i = 0; i < list_Cx.length; i++) {
		open(input+File.separator+list_Cx[i]);
		run("Z Project...", "projection=[Max Intensity]");
		run("Cellpose ...", "env_path="+cellpose_path+" env_type=conda model=cyto3 model_path= diameter=400 ch1=0 ch2=-1 additional_flags=--use_gpu");
		saveAs("Tiff", output+File.separator+"cellmask_"+list_Cx[i]);
		close("*");
	}


