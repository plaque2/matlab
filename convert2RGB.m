function outputRGB = convert2RGB(inputImage,colorWeight)
%description
%input
%output
if nargin <1
    error('NumberOfInputArgumentsError','ERROR: Not Enough input arguments');
end

if nargin<2
    colorWeight = [1 1 1];
end

outParams = whos('inputImage');
switch  outParams.class
    
    case 'uint16'
        processedImage =  im2uint8(inputImage);
        outputRGB(:,:,1)= processedImage.*colorWeight(1);
        outputRGB(:,:,2)=processedImage.*colorWeight(2);
        outputRGB(:,:,3)=processedImage.*colorWeight(3);
        
    case 'uint8'
        processedImage = inputImage;
        outputRGB(:,:,1)= processedImage.*colorWeight(1);
        outputRGB(:,:,2)=processedImage.*colorWeight(2);
        outputRGB(:,:,3)=processedImage.*colorWeight(3);
        
    case 'logical'
         processedImage = im2uint8(inputImage);
        outputRGB(:,:,1)= processedImage.*colorWeight(1);
        outputRGB(:,:,2)=processedImage.*colorWeight(2);
        outputRGB(:,:,3)=processedImage.*colorWeight(3);
        
    otherwise
        error('InputImageError','ERROR: The specified image is not a grayscale or black and white image');
end

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