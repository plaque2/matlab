function varargout = plaque2GUIpc(varargin)
% PLAQUE2GUIPC MATLAB code for plaque2GUIpc.fig
%      PLAQUE2GUIPC, by itself, creates a new PLAQUE2GUIPC or raises the existing
%      singleton*.
%
%      H = PLAQUE2GUIs returns the handle to a new PLAQUE2GUIPC or the handle to
%      the existing singleton*.
%s
%      PLAQUE2GUIPC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAQUE2GUIPC.M with the given input arguments.
%
%      PLAQUE2GUIPC('Property','Value',...) creates a new PLAQUE2GUIPC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plaque2GUIpc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plaque2GUIpc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plaque2GUIpc

% Last Modified by GUIDE v2.5 17-Nov-2014 12:25:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @plaque2GUIpc_OpeningFcn, ...
    'gui_OutputFcn',  @plaque2GUIpc_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%Initialize starting dir
if isdeployed % Stand-alone mode.
    
    [status, result] = system('path'); 
    currentDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    cd(currentDir);
else % MATLAB mode.
    currentDir = pwd;
end
setappdata(0,'currentDir',currentDir);





% --- Executes just before plaque2GUIpc is made visible.
function plaque2GUIpc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plaque2GUIpc (see VARARGIN)





logoImage = imread('logo.png');
 imshow(logoImage);



% Choose default command line output for plaque2GUIpc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plaque2GUIpc wait for user response (see UIRESUME)
% uiwait(handles.backgroundFig);

% change cursor appeareance
set(handles.backgroundFig,'Pointer','arrow');


%Set global variable to track if the analysis has been started
setappdata(0,'isAnalysisRunning',0);

%set


%initialization
set(handles.stitchPanel,'Visible','on');
set(handles.maskPanel,'Visible','off');
set(handles.nucleiPanel,'Visible','off');
set(handles.virusPanel,'Visible','off');


%allign all panels on top of each other to imitate tab 

stitchPanelPosition =  get(handles.stitchPanel,'Position');
set(handles.maskPanel,'Position',stitchPanelPosition);
set(handles.nucleiPanel,'Position',stitchPanelPosition);
set(handles.virusPanel,'Position',stitchPanelPosition);

% %Resize the window

set(hObject,'Units','pixels'); % change units to pixels
set(hObject,'Position',[100 432 950 750]);


% --- Outputs from this function are returned to the command line.
function varargout = plaque2GUIpc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in stitchTab.
function stitchTab_Callback(hObject, eventdata, handles)
% hObject    handle to stitchTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stitchTab

% curVal = get(hObject,'Value');


set(handles.stitchPanel,'Visible','on');
set(handles.maskPanel,'Visible','off');
set(handles.nucleiPanel,'Visible','off');
set(handles.virusPanel,'Visible','off');
set(handles.stitchTab,'Value',1);
set(handles.maskTab,'Value',0);
set(handles.nucleiTab,'Value',0);
set(handles.virusTab,'Value',0);





% --- Executes on button press in maskTab.
function maskTab_Callback(hObject, eventdata, handles)
% hObject    handle to maskTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of maskTab

set(handles.stitchPanel,'Visible','off');
set(handles.maskPanel,'Visible','on');
set(handles.nucleiPanel,'Visible','off');
set(handles.virusPanel,'Visible','off');
set(handles.stitchTab,'Value',0);
set(handles.maskTab,'Value',1);
set(handles.nucleiTab,'Value',0);
set(handles.virusTab,'Value',0);


[matchedFileNames channelList] = getChannelList(handles);
if(~isempty(matchedFileNames))
    set(handles.maskTestBtn,'Enable','on');
    if(isempty(channelList))
        channelList ='';
        set(handles.maskChannelPopupTxt,'Enable','off');
    else
        set(handles.maskChannelPopupTxt,'Enable','on');
    end
    set(handles.maskChannelPopup,'String',channelList,'Enable','on');
else
    set(handles.maskChannelPopupTxt,'Enable','off');
    set(handles.maskChannelPopup,'String','N/A','Enable','inactive');
    set(handles.maskTestBtn,'Enable','off');
    errordlg('Entered Processing Folder is not a valid directory and cannot be parsed','Parse Error');
    error('NotADir','Entered Processing Folder does not contain any images matching images with the current pattern');
end
% --- Executes on button press in nucleiTab.
function nucleiTab_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
% Hint: get(hObject,'Value') returns toggle state of nucleiTab

set(handles.stitchPanel,'Visible','off');
set(handles.maskPanel,'Visible','off');
set(handles.nucleiPanel,'Visible','on');
set(handles.virusPanel,'Visible','off');
set(handles.stitchTab,'Value',0);
set(handles.maskTab,'Value',0);
set(handles.nucleiTab,'Value',1);
set(handles.virusTab,'Value',0);

[matchedFileNames channelList] = getChannelList(handles);
if(~isempty(matchedFileNames))
    set(handles.nucleiTestBtn,'Enable','on');
    if(isempty(channelList))
        channelList ='';
        set(handles.nucleiChannelPopupTxt,'Enable','off');
    else
        set(handles.nucleiChannelPopupTxt,'Enable','on');
    end
    set(handles.nucleiChannelPopup,'String',channelList,'Enable','on');
else
    set(handles.nucleiChannelPopupTxt,'Enable','off');
    set(handles.nucleiChannelPopup,'String','N/A','Enable','inactive');
    set(handles.nucleiTestBtn,'Enable','off');
    errordlg('Entered Processing Folder does not contain any images matching images with the current pattern','Parse Error');
    error('NotADir','Entered Processing Folder does not contain any images matching images with the current pattern');
end

% --- Executes on button press in virusTab.
function virusTab_Callback(hObject, eventdata, handles)
% hObject    handle to virusTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of virusTab

set(handles.stitchPanel,'Visible','off');
set(handles.maskPanel,'Visible','off');
set(handles.nucleiPanel,'Visible','off');
set(handles.virusPanel,'Visible','on');
set(handles.stitchTab,'Value',0);
set(handles.maskTab,'Value',0);
set(handles.nucleiTab,'Value',0);
set(handles.virusTab,'Value',1);

[matchedFileNames channelList] = getChannelList(handles);
if(~isempty(matchedFileNames))
    set(handles.virusTestBtn,'Enable','on');
    if(isempty(channelList))
        channelList ='';
        set(handles.virusChannelPopupTxt,'Enable','off');
    else
        set(handles.virusChannelPopupTxt,'Enable','on');
    end
    set(handles.virusChannelPopup,'String',channelList,'Enable','on');
else
    set(handles.virusChannelPopupTxt,'Enable','off');
    set(handles.virusChannelPopup,'String','N/A','Enable','inactive');
    set(handles.virusTestBtn,'Enable','off');
    errordlg('Entered Processing Folder does not contain any images matching images with the current pattern','Parse Error');
    error('NotADir','Entered Processing Folder does not contain any images matching images with the current pattern');
end

% --- Executes on button press in stitchTestBtn.
function stitchTestBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stitchTestBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stitchFlag,'Value',1);

testParameters(handles,'stitch');
% --- Executes on selection change in maskMethodPopup.
function maskMethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to maskMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns maskMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from maskMethodPopup
switch get(hObject,'Value')
    case 1
        %Make Everything disabled when method is not selected
        set(handles.customMaskFileTxt,'Enable','off');
        set(handles.customMaskFileEdit,'Enable','off');
        set(handles.customMaskFileBrowse,'Enable','off');
        
        set(handles.defineMaskBtn,'Enable','off');
        set(handles.maskTestBtn,'Enable','off');
        
    case 2
        %Enable only custom mask loading
        set(handles.customMaskFileTxt,'Enable','on');
        set(handles.customMaskFileEdit,'Enable','on');
        set(handles.customMaskFileBrowse,'Enable','on');
        
        set(handles.defineMaskBtn,'Enable','off');
        set(handles.maskTestBtn,'Enable','on');
    case 3
        %Enable manual mask detection
        set(handles.customMaskFileTxt,'Enable','off');
        set(handles.customMaskFileEdit,'Enable','off');
        set(handles.customMaskFileBrowse,'Enable','off');
        
        set(handles.defineMaskBtn,'Enable','on');
        set(handles.maskTestBtn,'Enable','on');
    case 4
        %Enable automatic mask detection
        set(handles.customMaskFileTxt,'Enable','off');
        set(handles.customMaskFileEdit,'Enable','off');
        set(handles.customMaskFileBrowse,'Enable','off');
        
        set(handles.defineMaskBtn,'Enable','off');
        set(handles.maskTestBtn,'Enable','on');
end
%

% --- Executes on button press in defineMaskBtn.
function defineMaskBtn_Callback(hObject, eventdata, handles)
% hObject    handle to defineMaskBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.maskFlag,'Value',1);
params = (getParametersFromGUI(handles,'ALL'));
manualMaskDetection(params,handles.customMaskFileEdit);

% --- Executes on button press in customMaskFileBrowse.
function customMaskFileBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to customMaskFileBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get file open window and write the loaded file into the custom Mask
% edit
[customMaskFileName,customMaskPathName,~] = uigetfile({'*.*'});
if(customMaskFileName)
    set(handles.customMaskFileEdit,'String',[customMaskPathName customMaskFileName]);
end

% --- Executes on button press in maskTestBtn.
function maskTestBtn_Callback(hObject, eventdata, handles)
% hObject    handle to maskTestBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.maskFlag,'Value',1);
testParameters(handles,'mask');

% --- Executes on button press in nucleiTestBtn.
function nucleiTestBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiTestBtn (see GCBO)
% eventdata  reserved - to be defined in a future verson of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% params =
set(handles.nucleiFlag,'Value',1);
testParameters(handles,'nuclei');


function artifactThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to artifactThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of artifactThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of artifactThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function artifactThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to artifactThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nucleiFileMaskEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiFileMaskEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nucleiFileMaskEdit as text
%        str2double(get(hObject,'String')) returns contents of nucleiFileMaskEdit as a double


% --- Executes during object creation, after setting all properties.
function nucleiFileMaskEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucleiFileMaskEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nucleiInputFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiInputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nucleiInputFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of nucleiInputFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function nucleiInputFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucleiInputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nucleiInputFolderBrowse.
function nucleiInputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiInputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function nucleiOutputFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiOutputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nucleiOutputFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of nucleiOutputFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function nucleiOutputFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucleiOutputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nucleiOutputFolderBrowse.
function nucleiOutputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiOutputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function minCellAreaNucleiEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minCellAreaNucleiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minCellAreaNucleiEdit as text
%        str2double(get(hObject,'String')) returns contents of minCellAreaNucleiEdit as a double


% --- Executes during object creation, after setting all properties.
function minCellAreaNucleiEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minCellAreaNucleiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxCellAreaNucleiEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxCellAreaNucleiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxCellAreaNucleiEdit as text
%        str2double(get(hObject,'String')) returns contents of maxCellAreaNucleiEdit as a double


% --- Executes during object creation, after setting all properties.
function maxCellAreaNucleiEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxCellAreaNucleiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in illuminationCorrectionFlag.
function illuminationCorrectionFlag_Callback(hObject, eventdata, handles)
% hObject    handle to illuminationCorrectionFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of illuminationCorrectionFlag



function correctionBallRadiusEdit_Callback(hObject, eventdata, handles)
% hObject    handle to correctionBallRadiusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of correctionBallRadiusEdit as text
%        str2double(get(hObject,'String')) returns contents of correctionBallRadiusEdit as a double


% --- Executes during object creation, after setting all properties.
function correctionBallRadiusEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correctionBallRadiusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in nucleiThresholdingPopup.
function nucleiThresholdingPopup_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiThresholdingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nucleiThresholdingPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nucleiThresholdingPopup
switch get(hObject,'Value')
    case 1
        %Make Everything disabled when method is not selected
        set(handles.manualThresholdTxt,'Enable','off');
        set(handles.manualThresholdEdit,'Enable','off');
        
        set(handles.minimalThresholdTxt,'Enable','off');
        set(handles.minimalThresholdEdit,'Enable','off');
        
        set(handles.thresholdCorrectionFactorTxt,'Enable','off');
        set(handles.thresholdCorrectionFactorEdit,'Enable','off');
        
        set(handles.nucleiThresholdBtn,'Enable','off');
        
        set(handles.blockSizeTxt,'Enable','off');
        set(handles.blockSizeEdit,'Enable','off');
        
        set(handles.nucleiTestBtn,'Enable','off');
        
    case 2
        %Manual Thresholding
        set(handles.manualThresholdTxt,'Enable','on');
        set(handles.manualThresholdEdit,'Enable','on');
        set(handles.nucleiThresholdBtn,'Enable','on');
        set(handles.minimalThresholdTxt,'Enable','off');
        set(handles.minimalThresholdEdit,'Enable','off');
        
        set(handles.thresholdCorrectionFactorTxt,'Enable','off');
        set(handles.thresholdCorrectionFactorEdit,'Enable','off');
        
        set(handles.blockSizeTxt,'Enable','off');
        set(handles.blockSizeEdit,'Enable','off');
        
        set(handles.nucleiTestBtn,'Enable','on');
    case 3
        %Global Otsu thresholding
        set(handles.manualThresholdTxt,'Enable','off');
        set(handles.manualThresholdEdit,'Enable','off');
        set(handles.nucleiThresholdBtn,'Enable','off');
        set(handles.minimalThresholdTxt,'Enable','on');
        set(handles.minimalThresholdEdit,'Enable','on');
        
        set(handles.thresholdCorrectionFactorTxt,'Enable','on');
        set(handles.thresholdCorrectionFactorEdit,'Enable','on');
        
        set(handles.blockSizeTxt,'Enable','off');
        set(handles.blockSizeEdit,'Enable','off');
        
        set(handles.nucleiTestBtn,'Enable','on');
    case 4
        %Local Otsu thresholding with specific block size
        set(handles.manualThresholdTxt,'Enable','off');
        set(handles.manualThresholdEdit,'Enable','off');
        set(handles.nucleiThresholdBtn,'Enable','off');
        set(handles.minimalThresholdTxt,'Enable','off');
        set(handles.minimalThresholdEdit,'Enable','off');
        
        set(handles.thresholdCorrectionFactorTxt,'Enable','on');
        set(handles.thresholdCorrectionFactorEdit,'Enable','on');
        
        set(handles.blockSizeTxt,'Enable','on');
        set(handles.blockSizeEdit,'Enable','on');
        
        set(handles.nucleiTestBtn,'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function nucleiThresholdingPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucleiThresholdingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function manualThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to manualThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of manualThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of manualThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function manualThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to manualThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function blockSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to blockSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blockSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of blockSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function blockSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blockSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minimalThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minimalThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minimalThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of minimalThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function minimalThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minimalThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thresholdCorrectionFactorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdCorrectionFactorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdCorrectionFactorEdit as text
%        str2double(get(hObject,'String')) returns contents of thresholdCorrectionFactorEdit as a double


% --- Executes during object creation, after setting all properties.
function thresholdCorrectionFactorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdCorrectionFactorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function virusInputFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to virusInputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of virusInputFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of virusInputFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function virusInputFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusInputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in virusInputFolderBrowse.
function virusInputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to virusInputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function virusFileMaskEdit_Callback(hObject, eventdata, handles)
% hObject    handle to virusFileMaskEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of virusFileMaskEdit as text
%        str2double(get(hObject,'String')) returns contents of virusFileMaskEdit as a double


% --- Executes during object creation, after setting all properties.
function virusFileMaskEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusFileMaskEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function virusThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to virusThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of virusThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of virusThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function virusThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minPlaqueAreaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minPlaqueAreaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minPlaqueAreaEdit as text
%        str2double(get(hObject,'String')) returns contents of minPlaqueAreaEdit as a double


% --- Executes during object creation, after setting all properties.
function minPlaqueAreaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minPlaqueAreaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plaqueConnectivityEdit_Callback(hObject, eventdata, handles)
% hObject    handle to plaqueConnectivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plaqueConnectivityEdit as text
%        str2double(get(hObject,'String')) returns contents of plaqueConnectivityEdit as a double


% --- Executes during object creation, after setting all properties.
function plaqueConnectivityEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plaqueConnectivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in virusTestBtn.
function virusTestBtn_Callback(hObject, eventdata, handles)
% hObject    handle to virusTestBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.virusFlag,'Value',1);
testParameters(handles,'virus');


function virusOutputFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to virusOutputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of virusOutputFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of virusOutputFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function virusOutputFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusOutputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in virusOutputFolderBrowse.
function virusOutputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to virusOutputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plaqueFineDetectionFlag.
function plaqueFineDetectionFlag_Callback(hObject, eventdata, handles)
% hObject    handle to plaqueFineDetectionFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plaqueFineDetectionFlag



function plaqueGaussianFilterSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to plaqueGaussianFilterSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plaqueGaussianFilterSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of plaqueGaussianFilterSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function plaqueGaussianFilterSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plaqueGaussianFilterSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plaqueGaussianFilterSigmaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to plaqueGaussianFilterSigmaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plaqueGaussianFilterSigmaEdit as text
%        str2double(get(hObject,'String')) returns contents of plaqueGaussianFilterSigmaEdit as a double


% --- Executes during object creation, after setting all properties.
function plaqueGaussianFilterSigmaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plaqueGaussianFilterSigmaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function peakRegionSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to peakRegionSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peakRegionSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of peakRegionSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function peakRegionSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakRegionSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function maskPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function processingFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to processingFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of processingFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of processingFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function processingFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processingFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'String',getappdata(0,'currentDir'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inputFolderBrowse.
function inputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to inputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% currentDir = get(handles.processingFolderEdit,'String');
if(isdir(handles.processingFolderEdit.String))
inputFolderEdit = uigetdir(handles.processingFolderEdit.String);
else
inputFolderEdit = uigetdir('');
end
if(inputFolderEdit)
set(handles.processingFolderEdit,'String',inputFolderEdit);
end




function resultOutputFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resultOutputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resultOutputFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of resultOutputFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function resultOutputFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultOutputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'String',getappdata(0,'currentDir'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resultOutputFolderBrowse.
function resultOutputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to resultOutputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isdir(handles.resultOutputFolderEdit.String))
    resultOutputFolder = uigetdir(handles.resultOutputFolderEdit.String);
else
    resultOutputFolder = uigetdir('');
end
if(resultOutputFolder)
set(handles.resultOutputFolderEdit,'String',resultOutputFolder);
end
% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(handles.logEdit,'String','Run');


%get current parameter structure

%  set(hObject,'Enable','Off');
drawnow;
if (~getappdata(0,'isAnalysisRunning'))
    try
        set(hObject,'String','Cancel');
        setappdata(0,'isAnalysisRunning',1);
        %Get params from the GUI
        params = (getParametersFromGUI(handles,'ALL'));
        writeinlog(handles.logEdit,'Running the analysis with following params:');
        
        
        writeinlog(handles.logEdit,'General params :');
        generalParams =  struct2cellwithfields(params.general);
        writeinlog(handles.logEdit,generalParams);
        
        if isfield(params,'stitch')
            writeinlog(handles.logEdit,'Stitch params :');
            generalParams =  struct2cellwithfields(params.stitch);
            writeinlog(handles.logEdit,generalParams);
        end
        if isfield(params,'mask')
            writeinlog(handles.logEdit,'Mask params :');
            generalParams =  struct2cellwithfields(params.mask);
            writeinlog(handles.logEdit,generalParams);
            
        end
        if isfield(params,'nuclei')
            writeinlog(handles.logEdit,'Nuclei params :');
            generalParams =  struct2cellwithfields(params.nuclei);
            writeinlog(handles.logEdit,generalParams);
            
        end
        if isfield(params,'virus')
            writeinlog(handles.logEdit,'Virus params :');
            generalParams =  struct2cellwithfields(params.virus);
            writeinlog(handles.logEdit,generalParams);
            
        end
        writeinlog(handles.logEdit,'Running the analysis, please standby...');
        
        
        plaque2(params,handles);
        set(hObject,'String','Run');
        
   catch errorMsg
        setappdata(0,'isAnalysisRunning',0);
        set(hObject,'String','Run');
        set(hObject,'Enable','On');
        disp(errorMsg)
        writeinlog(handles.logEdit,strcat({'ERROR: '},errorMsg.message));
    end
    set(hObject,'Enable','On');

elseif (getappdata(0,'isAnalysisRunning') == 1)
    disp('CANCELLED');
    
    set(hObject,'Enable','On');
    drawnow;
    setappdata(0,'isAnalysisRunning',0); 
    set(hObject,'String','Run');
    
end




%struct to cell array field+values function
function cellOut = struct2cellwithfields(inputStruct)
% convert the input structure to a single collumn cell array where each row
% is a string of  "field - value"
values = cellfun(@check_numeric, struct2cell(inputStruct), 'UniformOutput', false);
fields = fieldnames(inputStruct);

cellOut = strcat({'    '},fields,{' - '},values);

function output = check_numeric(input)
disp(input)
if isnumeric(input)
    
    input = num2str(input)
elseif iscell(input)
    input = cell2mat(input)
end
  
output = input;


% values = cellfun(@num2str, struct2cell(params), 'UniformOutput', false);
%  fields = fieldnames(params);
% params = strcat(fields,{' - '},values);

% --- Executes during object creation, after setting all properties.
function logoAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logoAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate logoAxes


% --- Executes during object creation, after setting all properties.
function backgroundFig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function inputOutputPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputOutputPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function plateNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to plateNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plateNameEdit as text
%        str2double(get(hObject,'String')) returns contents of plateNameEdit as a double


% --- Executes during object creation, after setting all properties.
function plateNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plateNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function logEdit_Callback(hObject, eventdata, handles)
% hObject    handle to logEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of logEdit as text
%        str2double(get(hObject,'String')) returns contents of logEdit as a double


% --- Executes during object creation, after setting all properties.
function logEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in logClearBtn.
function logClearBtn_Callback(hObject, eventdata, handles)
% hObject    handle to logClearBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.logEdit,'String','');


% --- Executes on button press in logSaveBtn.
function logSaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to logSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName,FilterIndex] = uiputfile('*','Save Log File',[datestr(now,'yymmdd') 'log.txt']);
disp(FileName);
if(exist('FileName'))
    fid = fopen( fullfile(PathName,FileName),'w+');
    cell =get(handles.logEdit,'String');
    
    fprintf(fid, '%s\n', cell{:});
    
    fclose(fid);
end



function minCellAreaVirusEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minCellAreaVirusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minCellAreaVirusEdit as text
%        str2double(get(hObject,'String')) returns contents of minCellAreaVirusEdit as a double


% --- Executes during object creation, after setting all properties.
function minCellAreaVirusEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minCellAreaVirusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxCellAreaVirusEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxCellAreaVirusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxCellAreaVirusEdit as text
%        str2double(get(hObject,'String')) returns contents of maxCellAreaVirusEdit as a double


% --- Executes during object creation, after setting all properties.
function maxCellAreaVirusEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxCellAreaVirusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function plateLayoutBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plateLayoutBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in virusThresholdBtn.
function virusThresholdBtn_Callback(hObject, eventdata, handles)
% hObject    handle to virusThresholdBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getParametersFromGUI(handles,'VIRUS');
thresholdImagesUI(params,'virus',handles.virusThresholdEdit);

% --- Executes on button press in nucleiThresholdBtn.
function nucleiThresholdBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiThresholdBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getParametersFromGUI(handles,'NUCLEI');
thresholdImagesUI(params,'nuclei',handles.manualThresholdEdit);

% --- Executes during object creation, after setting all properties.
function virusThresholdBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusThresholdBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
thresholdPic = (imread('thresholdFace.tif'));
set(hObject,'CData',thresholdPic);


% --- Executes during object creation, after setting all properties.
function nucleiThresholdBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucleiThresholdBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
thresholdPic = (imread('thresholdFace.tif'));
set(hObject,'CData',thresholdPic);



function stitchInputFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stitchInputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stitchInputFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of stitchInputFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function stitchInputFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stitchInputFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

set(hObject,'String',getappdata(0,'currentDir'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stitchInputFolderBrowse.
function stitchInputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to stitchInputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isdir(handles.stitchInputFolderEdit.String))
stitchInputFolderEdit = uigetdir(handles.stitchInputFolderEdit.String);
else
stitchInputFolderEdit = uigetdir('');
end
if(stitchInputFolderEdit)
set(handles.stitchInputFolderEdit,'String',stitchInputFolderEdit);
end
function stitchFileNamePatternEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stitchFileNamePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stitchFileNamePatternEdit as text
%        str2double(get(hObject,'String')) returns contents of stitchFileNamePatternEdit as a double


% --- Executes during object creation, after setting all properties.
function stitchFileNamePatternEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stitchFileNamePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileNamePatternEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileNamePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNamePatternEdit as text
%        str2double(get(hObject,'String')) returns contents of fileNamePatternEdit as a double


% --- Executes during object creation, after setting all properties.
function fileNamePatternEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNamePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in nucleiChannelPopup.
function nucleiChannelPopup_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nucleiChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nucleiChannelPopup


% --- Executes during object creation, after setting all properties.
function nucleiChannelPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucleiChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in maskChannelPopup.
function maskChannelPopup_Callback(hObject, eventdata, handles)
% hObject    handle to maskChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns maskChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from maskChannelPopup


% --- Executes during object creation, after setting all properties.
function maskChannelPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in virusChannelPopup.
function virusChannelPopup_Callback(hObject, eventdata, handles)
% hObject    handle to virusChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns virusChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from virusChannelPopup


% --- Executes during object creation, after setting all properties.
function virusChannelPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stitchFlag.
function stitchFlag_Callback(hObject, eventdata, handles)
% hObject    handle to stitchFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stitchFlag


% --- Executes on button press in maskFlag.
function maskFlag_Callback(hObject, eventdata, handles)
% hObject    handle to maskFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of maskFlag


% --- Executes on button press in nucleiFlag.
function nucleiFlag_Callback(hObject, eventdata, handles)
% hObject    handle to nucleiFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nucleiFlag


% --- Executes on button press in virusFlag.
function virusFlag_Callback(hObject, eventdata, handles)
% hObject    handle to virusFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of virusFlag



function xImageNumberEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xImageNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xImageNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of xImageNumberEdit as a double


% --- Executes during object creation, after setting all properties.
function xImageNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xImageNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yImageNumberEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yImageNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yImageNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of yImageNumberEdit as a double


% --- Executes during object creation, after setting all properties.
function yImageNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yImageNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function maskMethodPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function customMaskFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to customMaskFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of customMaskFileEdit as text
%        str2double(get(hObject,'String')) returns contents of customMaskFileEdit as a double


% --- Executes during object creation, after setting all properties.
function customMaskFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to customMaskFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [matchedFileList channelList] = getChannelList(handles)

inputFolder = get(handles.processingFolderEdit,'String');
pattern = get(handles.fileNamePatternEdit,'String');
parseOutput = parseImageFilenames(inputFolder,pattern);
if(~isempty(parseOutput))
    matchedFileList = parseOutput.matchedFileNames;
    if(isfield(parseOutput,'channelNames'))
        
        channelList = parseOutput.channelNames;
        
    else
        channelList = '';
    end
    
else
    matchedFileList = [];
    channelList =[];
end



% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters= getParametersFromGUI(handles,'ALL');
saveFileName = [datestr(now,'yy_mm_dd') '_parameters'];
uisave('parameters',saveFileName);
% --------------------------------------------------------------------
function menuLoad_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat','Load Parameters');

dummy = load(fullfile(PathName,FileName),'parameters');
parameters = dummy.parameters;
setParametersToGUI(parameters,handles);

% --------------------------------------------------------------------
function menuQuit_Callback(hObject, eventdata, handles)
% hObject    handle to menuQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all force


% --------------------------------------------------------------------
function menuGuide_Callback(hObject, eventdata, handles)
% hObject    handle to menuGuide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isunix)
    web('http://plaque2.github.io/help.html', '-browser')
    
else
    system('start http://plaque2.github.io/help.html')
end

% --------------------------------------------------------------------
function menuManual_Callback(hObject, eventdata, handles)
% hObject    handle to menuManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isunix)
    web('http://plaque2.github.io/help.html', '-browser')
    
else
    system('start http://plaque2.github.io/help.html')
end
% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isunix)
    web('http://plaque2.github.io', '-browser')
else
    system('start http://plaque2.github.io')
end
%  web('http://www.mathworks.com', '-browser')
