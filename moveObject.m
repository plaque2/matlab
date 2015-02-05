function relativePosition = moveObject(objectHandle,fieldAxesHandle,movementBoundaries)

% gui = get(gcf,'UserData');

% Make a fresh figure window

setappdata
% Store gui object
set(objectHandle,'ButtonDownFcn',@startmovit);
set(gcf,'UserData',gui);
