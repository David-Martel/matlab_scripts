run("Set Scale...", "distance=3.65 known=1 pixel=1 unit=um global");
run("Measure");
run("Split Channels");
close();
close();

run("Enhance Contrast...", "saturated=0.2 normalize");
run("Subtract Background...", "rolling=10");
run("Auto Threshold...", "method=MaxEntropy white");
run("Invert");
run("Watershed");
run("Analyze Particles...", "size=5-Infinity pixel show=Outlines summarize");
