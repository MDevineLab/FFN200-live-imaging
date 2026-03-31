setBatchMode(true);


run("Bio-Formats Importer");
original = getTitle();
dir = getDirectory("image");
run("Duplicate...", "title=Channel-2 duplicate");

close(original);
saveAs("tiff", dir + "Channel-2.tiff");
x = "Data/";
File.makeDirectory(dir + x);
dir = dir + x;
image = getTitle();

getDimensions(width, height, channels, slices, frames);
print("width, height, channels, slices, frames");
print(width, height, channels, slices, frames);
saveAs("text", dir + "Dimensions.txt");
close("Log");

if (slices%2) {
	mid_slice = (slices+1)/2;
} else {
	mid_slice = slices/2;
}

if (frames%2) {
	mid_frame = (frames+1)/2;
} else {
	mid_frame = frames/2;
}

selectImage(image);
setSlice(mid_slice);
Stack.setFrame(mid_frame);
run("Duplicate...", "title=mid");

selectImage(image);
for (frame = 1; frame <= frames; frame++) {
	selectImage(image);
	Stack.setFrame(frame);
    for (slice = 1; slice <= slices; slice++) {

		selectImage(image);
    	setSlice(slice);

    	run("Duplicate...", "title=copy-"+ toString(frame) + "-" + toString(slice) + " duplicate slices="+toString(slice)+" frames="+toString(frame));
    	new = getTitle();  	
    	run("Concatenate...", "  title=concat-"+ toString(frame) + "-" + toString(slice)+ " keep open image1=[mid] image2=["+ new +"] image3=[-- None --]");
		concat=getTitle();
		setOption("ScaleConversions", true);
		run("StackReg ", "transformation=[Rigid Body]");
		reg = getTitle();
		n = nSlices;
		setSlice(n);
		run("Duplicate...", "title=reg-"+ toString(frame) + "-" + toString(slice));
		close(new);
		close(concat);
		close(reg);
    }
}

first = getBoolean("Is this the first half of analysis?");

if (first) {
	for (frame = 1; frame <= mid_frame; frame++) {

		for (slice = 1; slice <= slices; slice++) {
			run("JACoP ", "imga=[mid] imgb=[reg-"+ toString(frame) + "-" + toString(slice) +"] pearson");
			close("reg-"+ toString(frame) + "-" + toString(slice));
		}
	}
	selectWindow("Log");
	saveAs("text", dir + "Pearson-mid1.txt");
	close("Log");
	
} else {
	for (frame = 1; frame <= frames; frame++) {
		if (frame <= mid_frame) {
			continue;
		}

		for (slice = 1; slice <= slices; slice++) {
			run("JACoP ", "imga=[mid] imgb=[reg-"+ toString(frame) + "-" + toString(slice) +"] pearson");
			close("reg-"+ toString(frame) + "-" + toString(slice));
		}
	}
	selectWindow("Log");
	saveAs("text", dir + "Pearson-mid2.txt");
	close("Log");
}

run("Close All");

setBatchMode(false);
print("Command finished!");