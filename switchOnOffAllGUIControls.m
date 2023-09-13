function switchOnOffAllGUIControls(varargin)
%disables all buttons in the current figure handle if the  parentHandle is
%not specified it takes as input 0 which is the highest in the matlab
%hierarchy
nargin
if nargin < 1
    listOfAllHandles =  findall(0);
   
else
    % if (~isnumeric(varargin{1}))
    %     error('NonNumericInput','ERROR: Non-numeric handle entered');
    % end
    parentHandle = varargin{1};
    listOfAllHandles = findall(parentHandle);
end

indexesOfUIControls = (strcmp(get(listOfAllHandles,'type'),'uicontrol'));

if strcmp(get(listOfAllHandles(indexesOfUIControls),'Enable'),'off')
set(listOfAllHandles(indexesOfUIControls),'Enable','on');
else
 set(listOfAllHandles(indexesOfUIControls),'Enable','off');
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
