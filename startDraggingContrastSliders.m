function startDraggingContrastSliders(objectHandle,event)
%onMouseDown event
% Unpack gui object

figureUserData = get(gcf,'UserData');

% Remove mouse pointer
% set(gcf,'PointerShapeCData',nan(16,16));
set(gcf,'Pointer','left');

% Set callbacks
figureUserData.currentObjectHandle = objectHandle;
thisfig = gcbf();
set(thisfig,'WindowButtonMotionFcn',@Drag);
set(thisfig,'WindowButtonUpFcn',@stopDragging);

% Store starting point of the object
figureUserData.startpoint = get(gca,'CurrentPoint');

set(figureUserData.currentObjectHandle,'UserData',{get(figureUserData.currentObjectHandle,'XData') get(figureUserData.currentObjectHandle,'YData')});

% Store gui object
set(gcf,'UserData',figureUserData);



function Drag(callerHandle,event)
% Unpack gui object
figureUserData = get(gcf,'UserData');

% Do "smart" positioning of the object, relative to starting point...
curPoint = get(gca,'CurrentPoint');
% getappdata(gui.currentObjectHandle,'dragLimits');
dragLimits = getappdata(figureUserData.currentObjectHandle,'dragLimits');
objectWidth = getappdata(figureUserData.currentObjectHandle,'width');
objectHeight = getappdata(figureUserData.currentObjectHandle,'height');
editBox = getappdata(figureUserData.currentObjectHandle,'editBox');
pos = curPoint-figureUserData.startpoint;

XYData = get(figureUserData.currentObjectHandle,'UserData');

if(double( XYData{1}(1) + pos(1,1))>dragLimits(1) && double(XYData{1}(1) + pos(1,1))< dragLimits(2))
    % xMinLimit = XYData{1};
    % if(xMinLimit(1)>=0);
    set(figureUserData.currentObjectHandle,'XData',XYData{1} + pos(1,1));
    % end
    % set(gui.currenthandle,'YData',XYData{2} + pos(1,2));
else
    if( XYData{1}(2) + pos(1,1)<=dragLimits(1))
        set(figureUserData.currentObjectHandle,'XData',[dragLimits(1) dragLimits(1) dragLimits(1)+objectWidth dragLimits(1)+objectWidth]);
    end
    if( XYData{1}(2) + pos(1,1)>=dragLimits(2))
        set(figureUserData.currentObjectHandle,'XData',[dragLimits(2)-objectWidth dragLimits(2)-objectWidth dragLimits(2) dragLimits(2)]);
    end
end


%CONTRAST CHANGE OCCURS HERE
currentObjectTag = get(figureUserData.currentObjectHandle,'Tag');
imageHolder = getappdata(figureUserData.currentObjectHandle,'imageHolder');
axisXLims  = get(gca,'XLim');
xdata  = get(figureUserData.currentObjectHandle,'xdata');
clim = get(imageHolder,'CLim');

if strcmp(currentObjectTag,'upperLimit')
    clim(2) = xdata(1);
    
end

if strcmp(currentObjectTag,'lowerLimit')
    clim(1) = (xdata(4));
end
%HARCODED%%%
if(clim(1)<0)
    clim(1) =0;
end
if(clim(2)>2^16-1)
    clim(2) = 2^16-1;
end

if(clim(1)>= 2^16-1)
    clim(1) = 2^16-2;
end

if(clim(2)<= 0)
    clim(2) =1;
end


if(clim(2)<= clim(1))
    disp(clim);
    
    clim(2) =round(clim(1))+1;
    clim(1) = clim(2)-1;
     disp(clim);
    
end
%%%%%%%%%%%%
if strcmp(currentObjectTag,'upperLimit')
    
    set(editBox,'String',num2str(ceil(clim(2))));
    
end
if strcmp(currentObjectTag,'lowerLimit')
    set(editBox,'String',num2str(floor(clim(1))));
end
%END
set(imageHolder,'CLim',clim);
% Store gui object
set(gcf,'UserData',figureUserData);


function stopDragging(callerHandle,event)

% Clean up the evidence ...

currentFigure = gcbf();
figureUserData = get(gcf,'UserData');
set(gcf,'Pointer','arrow');
set(currentFigure,'WindowButtonUpFcn','');
set(currentFigure,'WindowButtonMotionFcn','');
drawnow;
set(figureUserData.currentObjectHandle,'UserData','');
set(gcf,'UserData',[]);

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
