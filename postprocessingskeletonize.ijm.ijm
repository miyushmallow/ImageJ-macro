// SkeletonizeZStacksMacro.java
// This ImageJ macro processes a batch of Z-stacks from a directory and applies skeletonization to each slice.

inputDir = getDirectory("Choose a Directory of Processed Images");
outputDir = inputDir + "Skeletonized/";
File.makeDirectory(outputDir);
fileList = getFileList(inputDir);

for (i = 0; i < fileList.length; i++) {
    open(inputDir + fileList[i]);

    // Check if the image was opened successfully
    if (getTitle() == "") {
        print("Could not open: " + fileList[i]);
        continue;
    }

    selectWindow(fileList[i]);
    run("8-bit");

    // Get stack dimensions
    Stack.getDimensions(width, height, channels, slices, frames);

    // Loop through each Z slice in the stack
    for (z = 1; z <= slices; z++) {
        Stack.setSlice(z);

        // Duplicate the current slice
        run("Duplicate...", "title=Slice_" + z);
        selectWindow("Slice_" + z);

        // Apply Skeletonization to the duplicated slice
        run("Skeletonize");

        // Copy the skeletonized slice back into the original stack
        run("Select All");
        run("Copy");
        selectWindow(fileList[i]);
        Stack.setSlice(z);
        run("Paste");

        // Close the duplicate slice window
        selectWindow("Slice_" + z);
        close();
    }

    // Save the skeletonized stack to the output directory
    saveAs("Tiff", outputDir + "Skeletonized_" + fileList[i]);

    // Close the current image to free up memory
    close();
}
