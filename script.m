clc; % Clear the command window.
close all; % Close all figures (except those of imtool.)
imtool close all; % Close all imtool figures.
clear; % Erase all existing variables.
debugDisplay = 0;

%% Read image
originalImage = imread('img/4.png');
if debugDisplay == 1
  figure;
  subplot(3, 3, 1);
  imshow(originalImage);
  title('Original color Image');
end

%% Convert to grey
grayImage = rgb2gray(originalImage);
if debugDisplay == 1
  subplot(3, 3, 2);
  imshow(grayImage);
  title('Converted to gray scale');
end

%% Binarize image
binarizedImage = imbinarize(grayImage, 0.9);
if debugDisplay == 1
  subplot(3, 3, 3);
  imshow(binarizedImage);
  title('Converted to binary image');
end

%% Canny edge detection
cannyImage = edge(binarizedImage, 'canny');
if debugDisplay == 1
  subplot(3, 3, 4);
  imshow(cannyImage);
  title('Canny Edge Image');
end

%% Sobel edge detection
sobelImage = edge(binarizedImage, 'sobel');
if debugDisplay == 1
  subplot(3, 3, 5);
  imshow(sobelImage);
  title('Sobel Edge Image');
end

%% Prewitt edge detection
prewittImage = edge(binarizedImage, 'prewitt');
if debugDisplay == 1
  subplot(3, 3, 6);
  imshow(prewittImage);
  title('Prewitt Edge Image');
end

%% Added edges
allEdgesMethods = cannyImage + sobelImage + prewittImage;
if debugDisplay == 1
  subplot(3, 3, 7);
  imshow(allEdgesMethods);
  title('Added all detected edges');
end

%% Fill detected holes (figures)
filledHoles = imfill(allEdgesMethods, 'holes');
if debugDisplay == 1
  subplot(3, 3, 8);
  imshow(filledHoles)
  title('Filled Image')
end

%% Figures properties detection
[B, L] = bwboundaries(filledHoles, 'noholes');
STATS = regionprops(L, 'all'); % we need 'BoundingBox' and 'Extent'
numberOfShapes = length(STATS);

%% Prepare results figure
figure;
imshow(originalImage),
title('Results');
hold on;

%% Calculate metric for each shape
for i = 1 : numberOfShapes
  STATS(i).Metric = 4 * 3.14 * STATS(i).Area / (STATS(i).Perimeter * STATS(i).Perimeter);
end

%% Analyze each figure properties
for i = 1 : numberOfShapes
  if (abs(STATS(i).BoundingBox(3) - STATS(i).BoundingBox(4)) < 0.1) && (abs(STATS(i).Extent) > 0.95)
    STATS(i).Shape = 'Square';
  elseif (abs(STATS(i).Extent) > 0.95)
    STATS(i).Shape = 'Rectangle';
  elseif (abs(STATS(i).BoundingBox(3) - STATS(i).BoundingBox(4)) < 0.1) && (abs(STATS(i).Extent) > 0.70)
    STATS(i).Shape = 'Circle';
    %   elseif (abs(STATS(i).Extent) > 0.70)
    %     STATS(i).Shape = 'Ellipsis';
  elseif (abs(STATS(i).Extent) > 0.25) && (abs(STATS(i).Extent) < 0.6)
    % elseif (STATS(i).Area * 0.95 < STATS(i).BoundingBox(3) * STATS(i).BoundingBox(4) * 0.5) && ...
    %   (STATS(i).Area * 1.05 > STATS(i).BoundingBox(3) * STATS(i).BoundingBox(4) * 0.5)
    % not working for rotated triangles
    STATS(i).Shape = 'Triangle';
  else
    STATS(i).Shape = 'Other';
  end
end

%% Display name of each shape
for i = 1 : numberOfShapes
  txtOffset = 25;
  txt = STATS(i).Shape;
  switch STATS(i).Shape
    case 'Rectangle'
      txtOffset = 35;
    case {'Ellipsis', 'Triangle'}
      txtOffset = 30;
  end
  centroid = STATS(i).Centroid;
  t = text(centroid(1) - txtOffset, centroid(2), txt);
  t.Color = 'white';
  t.FontSize = 10;
  rectangle(...
    'Position', ...
    [STATS(i).BoundingBox(1) ...
    STATS(i).BoundingBox(2) ...
    STATS(i).BoundingBox(3) ...
    STATS(i).BoundingBox(4)], ...
    'EdgeColor', 'blue', ...
    'LineStyle', '--', ...
    'LineWidth', 1 ...
    );
end
