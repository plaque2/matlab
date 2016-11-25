function [sortedCellArray,sortedIndex] = naturalSort(inputCellArray,sortMode)
%sorts input cell array  in "natural" order taking into account the
%numerical values inside the cell array ellements.

% based on sort_nat written by Douglas M. Schwarz  https://uk.mathworks.com/matlabcentral/fileexchange/10959-sort-nat--natural-order-sort



% Set default value for sortMode if necessary.
 if nargin < 2
 	sortMode = 'ascending'; 
 end

% Make sure mode is either 'ascending' or 'ascending'
sortModes = strcmpi(sortMode,{'ascending','descending'});



if ~any(sortModes)
	error('naturalsort:sortDirection',...
 		'sorting direction must be ''ascend'' or ''descend''.');
end


isDescending = sortModes(2);
    

% Replace runs of digits with '0'.
tempCellArray = regexprep(inputCellArray,'\d+','0');

% Compute the char version of inputCellArray and locations of zeros.
charCellArray = char(tempCellArray);
locationCellArray = charCellArray == '0';



% Extract the runs of digits and their start and end indices.
[digits,firstIndices,lastIndices] = regexp(inputCellArray,'\d+','match','start','end');

% Create matrix of numerical values of runs of digits and a matrix of the
% number of digits in each run.
numberOfEllements = length(inputCellArray); 
sizeOfMaxString = size(charCellArray,2);
valueArray = NaN(numberOfEllements,sizeOfMaxString);
digitArray = NaN(numberOfEllements,sizeOfMaxString);
for i = 1:numberOfEllements
	valueArray(i,locationCellArray(i,:)) = sscanf(sprintf('%s ',digits{i}{:}),'%f');
	digitArray(i,locationCellArray(i,:)) = lastIndices{i} - firstIndices{i} + 1;
end

% Find columns that have at least one non-NaN.  Make sure activeCollumns is a
% 1-by-lengthOfActiveCollumns vector even if lengthOfActiveCollumns = 0.
activeCollumns = reshape(find(~all(isnan(valueArray))),1,[]);
lengthOfActiveCollumns = length(activeCollumns);

% Compute which columns in the composite matrix get the numbers.
numberOfCollumns = activeCollumns + (1:2:2*lengthOfActiveCollumns);

% Compute which columns in the composite matrix get the number of digits.
numberOfDigitCollumns = numberOfCollumns + 1;

% Compute which columns in the composite matrix get chars.
charCollumns = true(1,sizeOfMaxString + 2*lengthOfActiveCollumns);
charCollumns(numberOfCollumns) = false;
charCollumns(numberOfDigitCollumns) = false;

% Create and fill composite matrix
compositeMatrix = zeros(numberOfEllements,sizeOfMaxString + 2*lengthOfActiveCollumns);
compositeMatrix(:,charCollumns) = double(charCellArray);
compositeMatrix(:,numberOfCollumns) = valueArray(:,activeCollumns);
compositeMatrix(:,numberOfDigitCollumns) = digitArray(:,activeCollumns);

% Sort rows of composite matrix and use index to sort c in ascending or descending order
[unused,sortedIndex] = sortrows(compositeMatrix);
if isDescending
	sortedIndex = sortedIndex(end:-1:1);
end
sortedIndex = reshape(sortedIndex,size(inputCellArray));
sortedCellArray = inputCellArray(sortedIndex);

end