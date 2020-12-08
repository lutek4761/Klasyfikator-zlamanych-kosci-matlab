clc, clear, close all
for i=1:27
    name = "broken"+i;
    img = imread(".\dataset\broken\"+name+".jpg");
    img = im2gray(img);
    img = imresize(img, [128,128]);
    imwrite(img, ".\dataset\broken_preprocessed\"+name+".jpg");
end
for i=1:27
    name = "notbroken"+i;
    img = imread(".\dataset\notbroken\"+name+".jpg");
    img = im2gray(img);
    img = imresize(img, [128,128]);
    imwrite(img, ".\dataset\notbroken_preprocessed\"+name+".jpg");
end