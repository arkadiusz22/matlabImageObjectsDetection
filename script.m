clc; % Clear the command window.
close all; % Close all figures (except those of imtool.)
imtool close all; % Close all imtool figures.
clear; % Erase all existing variables.
debugDisplay = 0;

%% Read image
originalImage = imread('img/4.png');
if debugDisplay == 1
  figure;
  imshow(originalImage);
  title('Original color Image');
end

%% Convert to grey
grayImage = rgb2gray(originalImage);
if debugDisplay == 1
  figure;
  imshow(grayImage);
  title('Converted to gray scale');
end

%% Binarize image
binarizedImage = imbinarize(grayImage, 0.9);
if debugDisplay == 1
  figure;
  imshow(binarizedImage);
  title('Converted to binary image');
end

%% Detect closed regions
[B, L] = bwboundaries(~ binarizedImage, 'noholes');
if debugDisplay == 1
  figure;
  imshow(originalImage);
  hold on
  for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:, 2), boundary(:, 1), 'red', 'LineWidth', 2)
  end
  title('Detected boundries of regions');
end

%% Get properties of detected regions
STATS = regionprops(L, 'Area', 'Centroid', 'Perimeter', 'Extent', 'BoundingBox');
numberOfShapes = length(STATS);

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

%% Prepare results figure
figure;
imshow(originalImage),
title('Results');
hold on;

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
