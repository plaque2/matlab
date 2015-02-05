function parseOutput = parseImageFilenames(inputFolder,pattern)
% Description
%parses and returns image filenames that correspond to the given pattern
%if  the pattern contains (?<wellName>[A-Z][0-9]*), (?<siteName>s[0-9]*),(?<channelName>w[0-9]*)
%also returns all the unique values these tokens have in filenames
if(isdir(inputFolder))
allFileNames  = extractfield(dir(inputFolder), 'name');
[matchedFileNames tokenNames] = regexp(allFileNames,pattern,'match','names');

validFileNameIndexes = find(~cellfun(@isempty,matchedFileNames));

if(validFileNameIndexes)
    matchedFileNames= [allFileNames(validFileNameIndexes)]';
    tokenNames = cell2mat(tokenNames');
    
    parseOutput.matchedFileNames = matchedFileNames;
    
    if(isfield(tokenNames,'wellName'))
        
        [wellCollumns wellRows]  = regexp({tokenNames.wellName},'\d+','match','split');
        
        parseOutput.wellRows = unique(cellfun(@(currentCellEllement) currentCellEllement{1},wellRows, 'UniformOutput', false));
        parseOutput.wellCollumns =  unique(cellfun(@(currentCellEllement) currentCellEllement{1},wellCollumns, 'UniformOutput', false));
        
    end
    
    
    if(isfield(tokenNames,'siteName'))
        parseOutput.siteNames  = unique({tokenNames.siteName});
        
    end
    if(isfield(tokenNames,'channelName'))
        parseOutput.channelNames  = unique({tokenNames.channelName});
    end
    
else
    parseOutput = [];
end
else
      parseOutput = [];
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