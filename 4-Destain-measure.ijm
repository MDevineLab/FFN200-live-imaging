function remove_duplicate(window) { 
	n = roiManager("count");
	selectImage(window);
	remove = newArray(n);
	for (i = 0; i < n; i++) {
	    roiManager("select", i);
	    roiManager("Measure");
	    repeated = getResult("Mean", i);
	    repeated = parseFloat(repeated);
	    if (repeated > 0) {
	    	remove[i] = 1;
	    }
	}
	n = roiManager("count");
	j=0;
	for (i = 0; i < n; i++) {
		if (remove[i]) {
			roiManager("select", i-j);
			roiManager("delete");
			j++;
		}
	}
}


function contains(array, value) {
    for (i=0; i<array.length; i++) 
        if ( array[i] == value ) return true;
    return false;
}


roiManager("reset");
run("Bio-Formats Importer");
dir = getDirectory("image");
if (!endsWith(dir, '/')) {
	dir+='/';
}
x = "Data/";
dir = dir + x;

image = getTitle();

run("Set Measurements...", "area mean standard min integrated limit display redirect=None decimal=3");


//If threshold is not good, try otsu and yen

run("Z Project...", "projection=[Max Intensity]");
resetMinAndMax();
run("Median...", "radius=2");

setAutoThreshold("Otsu dark no-rest");
run("Convert to Mask", "method=Otsu background=Dark calculate black");
setOption("BlackBackground", true);
run("Options...", "iterations=1 count=1 black do=Open");
run("Watershed");
run("Analyze Particles...", "size=0-2 display clear add composite");
roiManager("Show All");
roiManager("Combine");
setBackgroundColor(0, 0, 0);
run("Clear Outside");

Ns = roiManager("count");
if (Ns > 0) {
	roiManager("save", dir + "RoiSet-MinError.zip");
}


close("Results");
tit = getTitle();
roiManager("deselect");
run("Duplicate...", "title=min_error");
min_error = getTitle();
close(tit);

roiManager("reset");
selectImage(image);
run("Z Project...", "projection=[Max Intensity]");

resetMinAndMax();
run("Median...", "radius=2");
setAutoThreshold("Triangle dark no-rest");
run("Convert to Mask", "method=Triangle background=Dark calculate black");

setOption("BlackBackground", true);
run("Options...", "iterations=1 count=1 black do=Open");
run("Watershed");
run("Analyze Particles...", "size=0-2 display clear add composite");
close("Results");
roiManager("Show All");
roiManager("Combine");
setBackgroundColor(0, 0, 0);
run("Clear Outside");
tit = getTitle();
roiManager("deselect");
run("Duplicate...", "title=triangle");
triangle = getTitle();
close(tit);
remove_duplicate(min_error);

Ns = roiManager("count");
if (Ns > 0) {
	roiManager("save", dir + "RoiSet-triangle.zip");
}

roiManager("reset");
selectImage(image);
run("Z Project...", "projection=[Max Intensity]");
resetMinAndMax();
run("Median...", "radius=2");
setAutoThreshold("Moments dark no-rest");
run("Convert to Mask", "method=Moments background=Dark calculate black");
setOption("BlackBackground", true);
run("Options...", "iterations=1 count=1 black do=Open");
run("Watershed");
run("Analyze Particles...", "size=0-2 display clear add composite");
close("Results");
remove_duplicate(min_error);
close(min_error);
close("Results");
remove_duplicate(triangle);
close(triangle);
close("Results");

Ns = roiManager("count");
if (Ns > 0) {
	roiManager("save", dir + "RoiSet-moments.zip");
}

close();

roiManager("reset");

files = getFileList(dir);
if (contains(files, "RoiSet-MinError.zip")) {
	open(dir + "RoiSet-MinError.zip");
}
if (contains(files, "RoiSet-triangle.zip")) {
	open(dir + "RoiSet-triangle.zip");
}
if (contains(files, "RoiSet-moments.zip")) {
	open(dir + "RoiSet-moments.zip");
}

selectImage(image);
waitForUser("Select a background ROI");
roiManager("add");
n = roiManager("count");
roiManager("select", n-1);
roiManager("rename", "background");

waitForUser("Please check the ROIs and delete any that stands outside the frames and repeted ROIs");
n = roiManager("count");

pre=0;
for (j = 0; j < n; j++) {
	roiManager("select", j);
	
	if (Roi.getName != "background" && !startsWith(Roi.getName, "nonpre")) {
		roiManager("rename", toString(j));
		pre+=1;
		}
	
	roiManager("multi-measure measure_all one append");
	}

saveAs("results", dir + "destain1.csv");
close("Results");
roiManager("deselect");
roiManager("save", dir + "RoiSet1.zip");

presynapses = pre;
slice = nSlices;
non_pre = n - pre;
print("presynapses", "slices", "non_pre");
print(presynapses, slice, non_pre);
saveAs("text", dir + "presynapses-slices1.txt");

close("Log");
run("Close All");
print("Command finished!");