clc; % Clear the command window.
close all; % Close all figures (except those of imtool.)
imtool close all; % Close all imtool figures.
clear; % Erase all existing variables.

%% Read image
figure;
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
cannyImage = edge(binarizedImage, 'canny');
subplot(3, 3, 4);
imshow(cannyImage);
title('Canny Edge Image');

%% Sobel edge detection
sobelImage = edge(binarizedImage, 'sobel');
subplot(3, 3, 5);
imshow(sobelImage);
title('Sobel Edge Image');

%% Prewitt edge detection
prewittImage = edge(binarizedImage, 'prewitt');
subplot(3, 3, 6);
imshow(prewittImage);
title('Prewitt Edge Image');

%% Added edges
allEdgesMethods = cannyImage + sobelImage + prewittImage;
subplot(3, 3, 7);
imshow(allEdgesMethods);
title('Added all detected edges');

%% Fill detected holes (figures)
filledHoles = imfill(allEdgesMethods, 'holes');
subplot(3, 3, 8);
imshow(filledHoles)
title('Filled Image')

%% Figures properties detection
[B, L] = bwboundaries(filledHoles, 'noholes');
STATS = regionprops(L, 'all'); % we need 'BoundingBox' and 'Extent'
numberOfShapes = length(STATS);
shapes = zeros(size(numberOfShapes));

%% Prepare results figure
figure;
imshow(originalImage),
title('Results');
hold on;

%% Analyze each figure properties
for i = 1 : numberOfShapes
  if (abs(STATS(i).BoundingBox(3) - STATS(i).BoundingBox(4)) < 0.1) && (abs(STATS(i).Extent) > 0.95)
    shapes(i) = 1; % square
  elseif (abs(STATS(i).Extent) > 0.95)
    shapes(i) = 2; % rectangle
  elseif (abs(STATS(i).BoundingBox(3) - STATS(i).BoundingBox(4)) < 0.1) && (abs(STATS(i).Extent) > 0.70)
    shapes(i) = 3; % circle
  elseif (abs(STATS(i).Extent) > 0.25) && (abs(STATS(i).Extent) < 0.6)
    shapes(i) = 4; % triangle
  else
    shapes(i) = 0; % other
  end
end

%% Display name of each shape
for i = 1 : numberOfShapes
  txtOffset = 25;
  switch shapes(i)
    case 1
      txt = 'Square';
    case 2
      txt = 'Rectangle';
      txtOffset = 35;
    case 3
      txt = 'Circle';
    case 4
      txt = 'Triangle';
      txtOffset = 30;
    otherwise
      txt = 'Other';
  end
  centroid = STATS(i).Centroid;
  t = text(centroid(1) - txtOffset, centroid(2), txt);
  t.Color = 'white';
  t.FontSize = 10;
end
