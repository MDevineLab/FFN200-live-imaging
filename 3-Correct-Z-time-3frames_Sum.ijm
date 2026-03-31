/*
 This is the example of the text file to open
1-2-3-4,2-4-3-5,3-5-4-3,4-3-2-4,5-3-4-1,6-3-4-2,7-3-4-2,
8-2-3-4,9-4-3-2,10-4-1-1,11-2-4-1,12-2-4-5,13-2-1-3,
14-4-2-1,15-4-2-5,16-2-5-1,17-4-3-2,18-3-4-2,19-4-3-1,
20-4-5-3,21-2-4-3,22-3-4-2,23-3-5-4,24-5-4-1,25-2-3-4,
26-2-3-1,27-1-2-3,28-2-4-1,29-5-3-1,30-3-4-5,31-5-2-3,
32-5-2-1,33-4-3-5,34-4-5-3,35-2-3-1

The first number correspond to the frame, the other three numbers correspond to the
3 best r from Pearson corr.
*/

setBatchMode(true);
waitForUser("Did you run the Python script to rearrange the Pearson file?");
waitForUser("Open image to analyse.");
run("Bio-Formats Importer");
dir = getDirectory("image");
image = getTitle();
file = File.openAsString(dir+"selected-frames.csv");
file = split(file, ",");

str = ""; //to add the images for the concatenate command
for (i = 0; i < lengthOf(file); i++) {
	img = split(file[i], '-');
	frame = img[0];
	slice1 = img[1];
	slice2 = img[2];
	slice3 = img[3];
	selectImage(image);
	run("Duplicate...", "title=copy-"+ toString(frame) + "-" + toString(slice1) + " duplicate slices="+toString(slice1)+" frames="+toString(frame));
	run("Duplicate...", "title=copy-"+ toString(frame) + "-" + toString(slice2) + " duplicate slices="+toString(slice2)+" frames="+toString(frame));
	run("Duplicate...", "title=copy-"+ toString(frame) + "-" + toString(slice3) + " duplicate slices="+toString(slice3)+" frames="+toString(frame));
	run("Concatenate...", " title=copy-"+ toString(frame) +" open image1=copy-"+ toString(frame) + "-" + toString(slice1) + " image2=copy-"+ toString(frame) + "-" + toString(slice2) + " image3=copy-"+ toString(frame) + "-" + toString(slice3) + " image4=[-- None --]");
	run("Z Project...", "projection=[Sum Slices]");
	str += "image" + toString(i+1) + "=[" +"SUM_copy-"+ toString(frame)+ "] ";
	close("copy-"+ toString(frame));
}

run("Concatenate...", " keep open "+str+"image"+ toString(lengthOf(file)) +"=[-- None --]");
image = getTitle();
setOption("ScaleConversions", true);
run("StackReg ", "transformation=[Rigid Body]");
setOption("ScaleConversions", true);
run("StackReg ", "transformation=[Rigid Body]");
setOption("ScaleConversions", true);
run("StackReg ", "transformation=[Rigid Body]");
close("Log");

close("\\Others");
saveAs("tiff", dir + "registered-corrected.tiff");
run("Close All");
setBatchMode(false);
print("Command finished!");