// ImageProcessingMacro.java
// This ImageJ macro processes a batch of images from a directory and applies multiple filters to each slice in Z-stacks.

inputDir = getDirectory("Choose a Directory of Images");
outputDir = inputDir + "Processed/";
File.makeDirectory(outputDir);
fileList = getFileList(inputDir);

for (i = 0; i < fileList.length; i++) {
    open(inputDir + fileList[i]);

    if (getTitle() == "") {
        print("Could not open: " + fileList[i]);
        continue;
    }

    selectWindow(fileList[i]);
    run("8-bit");

    // Get stack dimensions
    width = 0; height = 0; channels = 0; slices = 0; frames = 0;
    Stack.getDimensions(width, height, channels, slices, frames);

    // Loop through each Z slice in the stack
    for (z = 1; z <= slices; z++) {
        Stack.setSlice(z); // Set to the current slice
        
        // Duplicate and process each slice separately
        run("Duplicate...", "title=Slice_" + z);
        selectWindow("Slice_" + z);

        run("Subtract Background...", "rolling=15.17");
        run("Sigma Filter Plus", "radius=1.138");
        run("Enhance Local Contrast (CLAHE)", "blocksize=64 max slope=1.25");
        run("Gamma...", "value=0.90");
        run("adaptiveThr ", "using=Mean from=15 then=-27");
        run("Despeckle");
        run("Remove Outliers...", "block radius x=1.707 block radius y=1.707 standard deviation=3");

        // Copy the processed slice back into the original stack
        run("Select All");
        run("Copy");
        selectWindow(fileList[i]);
        Stack.setSlice(z);
        run("Paste");

        // Close the duplicate slice window
        selectWindow("Slice_" + z);
        close();
    }

    // Save the fully processed image stack to the output directory
    saveAs("Tiff", outputDir + "Processed_" + fileList[i]);

    // Close the current image to free up memory
    close();
}

