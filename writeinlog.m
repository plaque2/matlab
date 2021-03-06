function writeinlog(logEdit,text)
if (~iscell(text))
    text= {text};
end
outCell =  cellfun(@(curCell) [datestr(now,'yy/mm/dd HH:MM:SS : ') num2str(curCell)],text,'UniformOutput',false);

oldText = get(logEdit,'String');
oldText = [outCell;oldText];

set(logEdit,'String',oldText);
drawnow
% guidata(handl es.logEdit,handles)

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
