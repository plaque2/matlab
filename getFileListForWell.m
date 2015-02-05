function varargout = getFileListForWell(inputFileList,inputPattern,varargin)
 

if (nargin == 3)
    channelValue = varargin{1};
elseif (nargin == 5)
     wellRowValue = varargin{1};
     wellCollumnValue = varargin{2};
     channelValue = varargin{3};
     inputPattern = regexprep(inputPattern,regexptranslate('escape','(?<wellName>[A-Z][0-9]*)'),[wellRowValue wellCollumnValue]);
else
   error('NotEnoughInputArguments','Not enough input arguments'); 
end
inputPattern = regexprep(inputPattern,regexptranslate('escape','(?<channelName>w[0-9]*)'),channelValue);



[outputFileList tokenNames] = regexp(inputFileList,inputPattern,'match','names');
 tokenNames = cell2mat(tokenNames');
if (nargin == 3)
[wellCollumns wellRows]  = regexp({tokenNames.wellName},'\d+','match','split');
  wellRows = (cellfun(@(currentCellEllement) currentCellEllement{1},wellRows, 'UniformOutput', false))';
  wellCollumns =  (cellfun(@(currentCellEllement) currentCellEllement{1},wellCollumns, 'UniformOutput', false))';
else
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