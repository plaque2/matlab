function varargout = getFileListForWell(inputFileList,inputPattern,varargin)


if (nargin == 3)
    channelValue = varargin{1};
elseif (nargin == 4)
    wellNameValue = varargin{1};
    channelValue = varargin{2};
    inputPattern = regexprep(inputPattern,'\(\?<wellName>[^\(]+\)',wellNameValue);
elseif (nargin == 5)
    wellRowValue = varargin{1};
    wellCollumnValue = varargin{2};
    channelValue = varargin{3};
    inputPattern = regexprep(inputPattern,'\(\?<wellName>[^\(]+\)',[wellRowValue wellCollumnValue]);
else
    error('NotEnoughInputArguments','Not enough input arguments');
end
inputPattern = regexprep(inputPattern,'\(\?<channelName>[^\(]+\)',channelValue);


inputFileList= naturalSort(inputFileList); %sort input filelist in natural order
[outputFileList tokenNames] = regexp(inputFileList,inputPattern,'match','names');
tokenNames = cell2mat(tokenNames');
if (nargin == 3)
    [wellCollumns wellRows]  = regexp({tokenNames.wellName},'\d+','match','split');
    wellRows = (cellfun(@(currentCellEllement) currentCellEllement{1},wellRows, 'UniformOutput', false))';
    wellCollumns =  (cellfun(@(currentCellEllement) currentCellEllement{1},wellCollumns, 'UniformOutput', false))';
elseif (nargin == 5)
    wellRows  = wellRowValue;
    wellCollumns = wellCollumnValue;
end




outputFileList = inputFileList(find(~cellfun(@isempty,outputFileList)));


if nargout== 1
    varargout{1} = outputFileList;
end
if nargout == 3
    varargout{1} = outputFileList;
    varargout{2} = wellRows;
    varargout{3} =  wellCollumns;
end