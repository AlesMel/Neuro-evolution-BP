function [BWImage] = processImg()
    image = imread("BWMapReversed.png");
    grayImage = rgb2gray(image);
    BWImage = grayImage > 123;
end
