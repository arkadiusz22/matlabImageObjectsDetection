clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.

%% Prepare figure - fullscreen
figure;
% fig=gcf;
% fig.Units='normalized';
% fig.OuterPosition=[0 0 1 1];

%% Read image
originalImage = imread('img/4.png');
subplot(3, 3, 1);
imshow(originalImage);
title('Original color Image'); 

%% Convert to grey
grayImage = rgb2gray(originalImage);
subplot(3, 3, 2);
imshow(grayImage);
title('Converted to gray scale');

%% Binarize image
binarizedImage = imbinarize(grayImage, 0.9);
subplot(3, 3, 3);
imshow(binarizedImage);
title('Converted to binary image');

%% Canny edge detection
cannyImage = edge(binarizedImage,'canny');
subplot(3, 3, 4);
imshow(cannyImage);
title('Canny Edge Image');

%% Sobel edge detection
sobelImage = edge(binarizedImage,'sobel');
subplot(3, 3, 5);
imshow(sobelImage);
title('Sobel Edge Image');

%% Prewitt edge detection
prewittImage = edge(binarizedImage,'prewitt');
subplot(3, 3, 6);
imshow(prewittImage);
title('Prewitt Edge Image');

%% Added edges
allEdgesMethods = cannyImage+sobelImage+prewittImage;
subplot(3, 3, 7);
imshow(allEdgesMethods);
title('Added all detected edges');

%% Fill detected holes (figures)
filledHoles = imfill(allEdgesMethods,'holes');
subplot(3, 3, 8);
imshow(filledHoles)
title('Filled Image')

%% Figures properties detection 
[B,L] = bwboundaries(filledHoles, 'noholes');
STATS = regionprops(L, 'all'); % we need 'BoundingBox' and 'Extent'

%% Prepare results figure
figure;
imshow(originalImage),
title('Results');
hold on

%% Analyze each figure properties and display according label
for i = 1 : length(STATS)
  if (uint8(abs(STATS(i).BoundingBox(3)-STATS(i).BoundingBox(4)) < 0.1))
% squerish 
   if (abs(STATS(i).Extent - 1) < 0.05)
% square
         W(i) = 1;
   elseif (abs(STATS(i).Extent - 1) < 0.30)
% circle
         W(i) = 2;
   end
  elseif (uint8(abs(STATS(i).BoundingBox(3)-STATS(i).BoundingBox(4)) < 0.3))
     W(i) = 0;
  else 
     W(i) = 0;
  end
  
  centroid = STATS(i).Centroid;
 
  switch W(i)
     case 1
        txt = 'Square';
     case 2
        txt = 'Circle';
     otherwise
        txt = 'Other';
  end 
  t = text(centroid(1)-25,centroid(2),txt);
  t.Color = 'white';
  t.FontSize = 10;
end

