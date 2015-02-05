 function maskOfTheWell = detectMaskAutomatically(inputImage,wellProperties)
%Description: Automatic well mask detection for round wells optimized for
%96 well Griener plates
%TODO: Generelize for arbitrary wells


if nargin <1 
    error('NotEnoughInputArguments' , 'ERROR: Not enough input arguments');
end

 if nargin <2
    wellProperties.radius = 2020;% radius in pixels of a well in Greiner 96-well plates
    wellProperties.threshold = 0.04;
    wellProperties.connectivity = 50;
end



% 
inputBW  = im2bw(inputImage,wellProperties.threshold);

%connect neighbours
inputBW = bwdist(inputBW) <= wellProperties.connectivity;

%
 imageProps = regionprops(inputBW,'Centroid','ConvexArea');

 % find the maximum area ellement in the image
 [~,maxEllementIndex] = max([imageProps.ConvexArea]);
 
 %get the center coordinates
 centroidArray = {imageProps.Centroid};
 % get the maximum area ellement center
center  = centroidArray{maxEllementIndex};

%create a circle with the specified radius a center
radius =  wellProperties.radius;
maskOfTheWell = createCircle(size(inputImage),center,radius);



function bw = createCircle(imageSize,center,radius)

[columnsInImage rowsInImage] = meshgrid(1:imageSize(1), 1:imageSize(1));

bw = (rowsInImage - center(2)).^2 ...
    + (columnsInImage - center(1)).^2 <= radius.^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     Plaque2.0 - a virological assay reloaded
%     Copyright (C) 2015  Artur Yakimovich, Vardan Andriasyan
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
