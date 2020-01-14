clc; % Clear the command window.
close all; % Close all figures (except those of imtool.)
imtool close all; % Close all imtool figures.
clear; % Erase all existing variables.
debugDisplay = 0;

%% Read image
originalImage = imread('img/5.png');
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
  if (abs(STATS(i).BoundingBox(3) - STATS(i).BoundingBox(4)) < 0.1)
    if (abs(STATS(i).Extent) > 0.95)
      STATS(i).Shape = 'Square';
    elseif ((abs(STATS(i).Extent) > 0.70) && (abs(STATS(i).Metric) > 0.95))
      STATS(i).Shape = 'Circle';
    elseif ((abs(STATS(i).Extent) > 0.70) && (abs(STATS(i).Metric) > 0.70))
      STATS(i).Shape = 'Rhombus';
    else
      STATS(i).Shape = 'Triangle';
    end
  elseif (abs(STATS(i).BoundingBox(3) - STATS(i).BoundingBox(4)) > 0.1)
    if (abs(STATS(i).Extent) > 0.95)
      STATS(i).Shape = 'Rectangle';
    elseif ((abs(STATS(i).Extent) > 0.78) && (abs(STATS(i).Metric) > 0.64))
      STATS(i).Shape = 'Ellipsis';
    elseif (abs(STATS(i).Extent) < 0.6) && (0.65 > abs(STATS(i).Metric) && (abs(STATS(i).Metric) > 0.40))
      STATS(i).Shape = 'Triangle';
    elseif (abs(STATS(i).Metric) > 0.70)
      STATS(i).Shape = 'Rhombus';
    else
      STATS(i).Shape = 'Other2';
    end
  else
    STATS(i).Shape = 'Other1';
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
    case {'Rectangle', 'Rhombus'}
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
