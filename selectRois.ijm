#@ File (label = "Red directory", style = "directory") input_red
#@ File (label = "Cell mask directory", style = "directory") input_cellmask
#@ File (label = "Blue directory", style = "directory") input_blue
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "Red file suffix", value = "gfac.tif") suffix
#@ int(label = "Square size", default=30) box_size

	bluelist = getFileList(input_blue);
	bluelist = Array.sort(bluelist);
	bluelist = Array.filter(bluelist,"1.tif");
	cellmasklist = getFileList(input_cellmask);
	cellmasklist = Array.sort(cellmasklist);
	cellmasks = Array.filter(cellmasklist,"cellmask");
	for (i = 0; i < bluelist.length; i++) {
		subname=split(bluelist[i],".");
		subname=substring(subname[0], 0, lengthOf(subname[0])-1);
		red_name=subname+"0-"+suffix;
		run("TIFF Virtual Stack...", "open=["+input_blue+File.separator+bluelist[i]+"]");
		blue_stack=getTitle();
		run("Duplicate...", "title=blue_substack duplicate range=2-4");
		run("32-bit");
		selectWindow(blue_stack);
		close();
		if (i==0){
			getPixelSize(unit, pixelWidth, pixelHeight);
		}
		open(input_cellmask+File.separator+cellmasks[i]);
		cellmask_image=getTitle();
		selectWindow("blue_substack");
		setTool("multipoint");
		waitForUser("Select Points", "Add multipoints to ROI manager, click OK when done");
		while (roiManager("count")<1){
			waitForUser("Select Points", "ROI manager empty, please add multipoints.");
		}
		roiManager("deselect");
		run("Set Measurements...", "centroid stack redirect=None decimal=9");
		roiManager("measure");
		count = nResults();
		for (j = 0; j < count; j++) {
    		x = getResult('X', j);
    		y = getResult('Y', j);
    		makeRectangle(um2px(x,pixelWidth)-box_size/2, um2px(y,pixelWidth)-box_size/2, box_size, box_size);
    		roiManager("Add");
		}
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("deselect");
		roiManager("Save", output+File.separator+subname+"_rois.zip");
		Table.create(subname);
		selectWindow("Results");
		run("Close");
		selectWindow("blue_substack");
		run("Set Measurements...", "mean stack display redirect=None decimal=9");
		roiManager("measure");
		IJ.renameResults("blue_measurments");
		selectWindow(cellmask_image);
		run("Set Measurements...", "mean min display redirect=None decimal=9");
		roiManager("measure");
		IJ.renameResults("cell_labels");
		slice=Table.get("Slice",0,"blue_measurments");
		open(input_red+File.separator+red_name);
		setSlice(slice);
		run("Set Measurements...", "mean stack display redirect=None decimal=9");
		roiManager("measure");
		IJ.renameResults("red_measurments");
		row_number=0;
		for (j = 0; j < count; j++) {
			meancell=Table.get("Mean",j,"cell_labels");
			maxcell=Table.get("Max",j,"cell_labels");
			if ((meancell==maxcell) & (meancell>0)){
				roi_label=Table.getString("Label",j,"blue_measurments");
				roi=split(roi_label,":");
				red_mean=Table.get("Mean",j,"red_measurments");
				blue_mean=Table.get("Mean",j,"blue_measurments");
				Table.set("ROI name",row_number,roi[1],subname);
				Table.set("Slice",row_number,slice+1,subname);
				Table.set("red_gfac_intensity",row_number,red_mean,subname);
				Table.set("blue_intensity",row_number,blue_mean,subname);
				gpmap=(blue_mean-red_mean)/(blue_mean+red_mean);
				Table.set("GP map",row_number,gpmap,subname);
				denom=blue_mean+red_mean;
				Table.set("Total_intensity",row_number,denom,subname);
				row_number++;
			}	
			Table.update(subname);
		}
		close("*");
		Table.save(output+File.separator+"rois_in_cell_"+subname+".csv","cell_labels");
		Table.save(output+File.separator+"measurments_"+subname+".csv",subname);
		selectWindow("red_measurments");
		run("Close");
		selectWindow("blue_measurments");
		run("Close");
		selectWindow("cell_labels");
		run("Close");
		selectWindow(subname);
		run("Close");
		roiManager("reset");
	}


function um2px(x,pixelWidth){
	y=Math.ceil(x/pixelWidth);
	return y;
}

