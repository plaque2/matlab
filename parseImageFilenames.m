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
    
    parseOutput.matchedFileNames = naturalSort(matchedFileNames);
    
if(isfield(tokenNames,'wellName'))
        
        [wellCollumns wellRows]  = regexp({tokenNames.wellName},'\d+','match','split');
        
        parseOutput.wellRows = unique(cellfun(@(currentCellEllement) currentCellEllement{1},wellRows, 'UniformOutput', false));
        parseOutput.wellCollumns =  unique(cellfun(@(currentCellEllement) currentCellEllement{1},wellCollumns, 'UniformOutput', false));
        
end
    
    
    
    if(isfield(tokenNames,'siteName'))
        parseOutput.siteNames  = naturalSort(unique({tokenNames.siteName}));
        
    end
    if(isfield(tokenNames,'channelName'))
        parseOutput.channelNames  = naturalSort(unique({tokenNames.channelName}));
    end
    
else
    parseOutput = [];
end
else
      parseOutput = [];
end