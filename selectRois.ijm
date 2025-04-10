#@ File (label = "Red gfac stack") input_red
#@ File (label = "Cell mask stack") input_cellmask
#@ File (label = "Blue cropped stack") input_blue
#@ File (label = "Output directory", style = "directory") output
#@ int(label = "Square size", default=30) box_size
	
		open(input_blue);
		blue_stack=getTitle();
		subname=substring(blue_stack,0,lengthOf(blue_stack)-4);
		getPixelSize(unit, pixelWidth, pixelHeight);
		open(input_cellmask);
		cellmask_image=getTitle();
		run("Specify...", "width=2200 height=2200 x=100 y=100 slice=1");
		run("Crop");
		selectWindow(blue_stack);
		setTool("multipoint");
		waitForUser("Select Points", "Add multipoints to ROI manager, click OK when done");
		while (roiManager("count")<1){
			waitForUser("Select Points", "ROI manager empty, please add multipoints.");
		}
		roiManager("deselect");
		run("Set Measurements...", "centroid stack redirect=None decimal=9");
		roiManager("Measure");
		count = nResults();
		for (j = 0; j < count; j++) {
    		x = getResult('X', j);
    		y = getResult('Y', j);
    		sample = getResult('Frame',j);
    		z = getResult('Slice',j);
    		makeRectangle(um2px(x,pixelWidth)-box_size/2, um2px(y,pixelWidth)-box_size/2, box_size, box_size);
    		Roi.setPosition(1, z, sample);
    		roiManager("Add");
		}
		roiManager("Select", newArray(count));
		roiManager("Delete");
		roiManager("deselect");
		roiManager("Save", output+File.separator+subname+"_rois.zip");
		IJ.renameResults("ROI positions");

		Table.create(subname);
		selectWindow(blue_stack);
		run("Set Measurements...", "mean stack display redirect=None decimal=9");
		roiManager("measure");
		IJ.renameResults("blue_measurments");
		open(input_red);
		run("Set Measurements...", "mean stack display redirect=None decimal=9");
		roiManager("measure");
		IJ.renameResults("red_measurments");
		
		run("Set Measurements...", "mean min display redirect=None decimal=9");
		selectWindow(cellmask_image);
		for (j = 0; j < count; j++) {
    		x = Table.get("X",j,"ROI positions");
    		y = Table.get("Y",j,"ROI positions");
    		sample = Table.get("Frame",j,"ROI positions");
    		z = Table.get("Slice",j,"ROI positions");
    		Stack.setPosition(1, z%3, sample);
    		makeRectangle(um2px(x,pixelWidth)-box_size/2, um2px(y,pixelWidth)-box_size/2, box_size, box_size);
			Roi.setPosition(1, z%3, sample);
			run("Measure");
		}
		IJ.renameResults("cell_labels");
		
		//organise results
		row_number=0;
		for (j = 0; j < count; j++) {
			meancell=Table.get("Mean",j,"cell_labels");
			maxcell=Table.get("Max",j,"cell_labels");
			if ((meancell==maxcell) & (meancell>0)){
				roi_label=Table.getString("Label",j,"blue_measurments");
				roi=split(roi_label,":");
				red_mean=Table.get("Mean",j,"red_measurments");
				blue_mean=Table.get("Mean",j,"blue_measurments");
				slice=Table.get("Slice",j,"blue_measurments");
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


function um2px(x,pixelWidth){
	y=Math.ceil(x/pixelWidth);
	return y;
}

