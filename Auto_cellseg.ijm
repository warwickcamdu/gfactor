#@ File (label = "Cell images") input
#@ String (label = "Cellpose path", value="C:\\Users\\camdu\\miniconda3\\envs\\cellpose") cellpose_path
#@ File (label = "Output directory", style = "directory") output

		open(input);
		original_stack=getTitle();
		run("Z Project...", "projection=[Max Intensity] all");
		title=getTitle();
		selectWindow(original_stack);
		close();
		selectWindow(title);
		run("Cellpose ...", "env_path="+cellpose_path+" env_type=conda model=cyto3 model_path= diameter=400 ch1=0 ch2=-1 additional_flags=--use_gpu");
		selectWindow(title);
		close();
		saveAs("Tiff", output+File.separator+"cellmask_"+original_stack);


