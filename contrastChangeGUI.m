function contrastChangeGUI
% imshow('C:\Users\Vardan\Desktop\t1.png')
% imtool('C:\Users\Vardan\Documents\MATLAB\plaque2.0\src\processing-data\D01_w1.TIF')
%%%PARENT FIGURE INITIALIZATION
bgColor = [0.512 0.512 0.512];
yOffset = 0.02;
testWindowHandleArray.mainHandle = figure('units','pixels',...
    'position',[100 100 600 600],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Test Mode',...
    'resize','off',...
    'renderer','opengl',...
    'Color',[0.314 0.314 0.314],...
    'BusyAction','cancel',...
    'Interruptible','off');





%%%IMAGE HOLDER
testWindowHandleArray.imageHolder = axes('units','pixels',...
    'Parent',testWindowHandleArray.mainHandle,...
    'position',[50 100 500 500],...
    'xtick',[],'ytick',[],'box','off','XColor',bgColor,'YColor',bgColor,'TickDir','out');



inputImage = imread('C:\Users\Vardan\Documents\MATLAB\plaque2.0\src\processing-data\D01_w1.TIF');
imshow(imresize(inputImage,1));

%%% Contrast related UI ellements
testWindowHandleArray.contrastPanel = uipanel('BorderType','line',...
    'Units','pixels','Position',[100 50 410 120],...
    'Title','Adjust Contrast','Fonts',10,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.applyContrast = uicontrol(testWindowHandleArray.contrastPanel,'Position',[355 4 50 25],...
    'Style', 'pushbutton','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'String','Apply','Fonts',10);

testWindowHandleArray.resetContrast = uicontrol(testWindowHandleArray.contrastPanel,'Position',[305 4 50 25],...
    'Style', 'pushbutton','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'String','Reset','Fonts',10);

testWindowHandleArray.minMaxContrast = uicontrol(testWindowHandleArray.contrastPanel,'Position',[255 4 50 25],...
    'Style', 'pushbutton','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'String','Auto','Fonts',10);

testWindowHandleArray.rangeStaticText = uicontrol(testWindowHandleArray.contrastPanel,'Style', 'text', 'String','Range','fonts',10,'Position',[5 4 50 20],...
    'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.lowerLimitEdit = uicontrol(testWindowHandleArray.contrastPanel,'Style','edit','fonts',10,'Position',[60 4 50 20],...
    'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.hyphenStaticText = uicontrol(testWindowHandleArray.contrastPanel,'Style','text','String','-','fonts',10,'Position',[115 4 10 20],...
    'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.upperLimitEdit = uicontrol(testWindowHandleArray.contrastPanel,'Style','edit','fonts',10,'Position',[130 4 50 20],...
    'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.histAxes = axes('units','pixels',...
    'Parent',testWindowHandleArray.contrastPanel,...
    'position',[5 30 400 80]);


initializeControlPanelAxes(testWindowHandleArray,[0 2^16-1]);

% hist(double(I(:)));
% get(histAxes

set(testWindowHandleArray.applyContrast,'Callback',{@applyContrastLimits,testWindowHandleArray});
set(testWindowHandleArray.resetContrast,'Callback',{@resetContrastLimits,testWindowHandleArray});
set(testWindowHandleArray.minMaxContrast,'Callback',{@minMaxContrastLimits,testWindowHandleArray});

function applyContrastLimits(src,event,testWindowHandleArray)

currentContrastLimits{1} = str2num(get(testWindowHandleArray.lowerLimitEdit,'String'));
currentContrastLimits{2} =str2num(get(testWindowHandleArray.upperLimitEdit,'String'));


if(isempty(currentContrastLimits{1})||isempty(currentContrastLimits{2}))
    
    currentContrastLimits = [0 2^16-1];
    
else
    currentContrastLimits =cell2mat(currentContrastLimits);
    if (any(currentContrastLimits<0)||any(currentContrastLimits>2^16-1))
        currentContrastLimits = [0,2^16-1];
    end
end

initializeControlPanelAxes(testWindowHandleArray,currentContrastLimits);


function resetContrastLimits(src,event,testWindowHandleArray)
 currentContrastLimits = [0 2^16-1];
initializeControlPanelAxes(testWindowHandleArray,currentContrastLimits);

function minMaxContrastLimits(src,evnt,testWindowHandleArray)
inputImage = getimage(testWindowHandleArray.imageHolder);
 currentContrastLimits(1) = min(inputImage(:));
 currentContrastLimits(2) = max(inputImage(:));
initializeControlPanelAxes(testWindowHandleArray,currentContrastLimits);


function initializeControlPanelAxes(testWindowHandleArray,newAxesXLimits)
cla(testWindowHandleArray.histAxes);
inputImage = getimage(testWindowHandleArray.imageHolder);
set(testWindowHandleArray.lowerLimitEdit,'String',num2str(newAxesXLimits(1)));
set(testWindowHandleArray.upperLimitEdit,'String',num2str(newAxesXLimits(2)));
set(testWindowHandleArray.imageHolder,'CLim',newAxesXLimits);
%HARDCODED%%
if(newAxesXLimits(2)<3000)
    nbins = newAxesXLimits(2);
else
    nbins = 1000;
end
%%%%%
hist(double(inputImage(:)),nbins);
histPatchObject = findobj(testWindowHandleArray.histAxes,'Type','patch');
set(histPatchObject,'FaceColor',[.532 .532 .532],'EdgeColor',[.532 .532 .532]);
set(testWindowHandleArray.histAxes,'xtick',[],'ytick',[],'box','off','XColor',[0.512 0.512 0.512],'YColor',[0.512 0.512 0.512],'TickDir','in');
set(testWindowHandleArray.histAxes,'XLim',newAxesXLimits);

histAxesXLim =  get(testWindowHandleArray.histAxes,'XLim');
histAxesYLim = get(testWindowHandleArray.histAxes,'YLim');


%  axis(testWindowHandleArray.histAxes,[0 axisWidth 0 axisHeight]);

% axisLimits = [axisWidth axisHeight];

sliderWidth =floor((histAxesXLim(2)-histAxesXLim(1))*1/100);

histAxesXLim=histAxesXLim + [-sliderWidth sliderWidth];
set(testWindowHandleArray.histAxes,'XLim',histAxesXLim);
sliderHeight = histAxesYLim(2)-histAxesYLim(1);
x0= histAxesXLim(1);
y0 = 0;

xdata = [x0 x0 x0+sliderWidth x0+sliderWidth];
ydata = [y0 y0+sliderHeight y0+sliderHeight y0];
disp(histAxesXLim(1));
Limits = [histAxesXLim(1) histAxesXLim(2)-sliderWidth];



lowerLimitHandle = patch(xdata,ydata,[1 0 0],'AlphaDataMapping','none','Parent',testWindowHandleArray.histAxes,'Tag','lowerLimit','LineStyle','none');
setappdata(lowerLimitHandle,'width',sliderWidth);
setappdata(lowerLimitHandle,'height',sliderHeight);
setappdata(lowerLimitHandle,'dragLimits',Limits);
setappdata(lowerLimitHandle,'imageHolder',testWindowHandleArray.imageHolder);
setappdata(lowerLimitHandle,'editBox',testWindowHandleArray.lowerLimitEdit);

x0= histAxesXLim(2)-sliderWidth;
y0 = 0;
xdata = [x0 x0 x0+sliderWidth x0+sliderWidth];
ydata = [y0 y0+sliderHeight y0+sliderHeight y0];
Limits = [histAxesXLim(1)+sliderWidth histAxesXLim(2)];

upperLimitHandle = patch(xdata,ydata,[1 0 0],'AlphaDataMapping','none','Parent',testWindowHandleArray.histAxes,'Tag','upperLimit','LineStyle','none');
setappdata(upperLimitHandle,'width',sliderWidth);
setappdata(upperLimitHandle,'height',sliderHeight);
setappdata(upperLimitHandle,'dragLimits',Limits);
setappdata(upperLimitHandle,'imageHolder',testWindowHandleArray.imageHolder);
setappdata(upperLimitHandle,'editBox',testWindowHandleArray.upperLimitEdit);
set(testWindowHandleArray.mainHandle,'WindowButtonDownFcn',{@hitTest,upperLimitHandle,lowerLimitHandle,histAxesXLim});

function hitTest(src,evnt,upperLimitHandle,lowerLimitHandle,axisXLimits)

if gco == upperLimitHandle
    
    lowerLimitXdata = get(lowerLimitHandle,'xdata');
    setappdata(upperLimitHandle,'dragLimits',[lowerLimitXdata(4) axisXLimits(2)]);
    set(upperLimitHandle,'ButtonDownFcn',@startDraggingSlider);
elseif gco == lowerLimitHandle
    upperLimitXdata = get(upperLimitHandle,'xdata');
    setappdata(lowerLimitHandle,'dragLimits',[axisXLimits(1) upperLimitXdata(1)]);
    set(lowerLimitHandle,'ButtonDownFcn',@startDraggingSlider);
else
    disp('');
end



