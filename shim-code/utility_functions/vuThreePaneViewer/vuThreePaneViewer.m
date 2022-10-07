function varargout = vuThreePaneViewer(varargin)
% VUTHREEPANEVIEWER M-file for vuThreePaneViewer.fig
%      VUTHREEPANEVIEWER, by itself, creates a new VUTHREEPANEVIEWER or raises the existing
%      singleton*.
%
%      H = VUTHREEPANEVIEWER returns the handle to a new VUTHREEPANEVIEWER or the handle to
%      the existing singleton*.
%
%      VUTHREEPANEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VUTHREEPANEVIEWER.M with the given input arguments.
%
%      VUTHREEPANEVIEWER('Property','Value',...) creates a new VUTHREEPANEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vuThreePaneViewer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vuThreePaneViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vuThreePaneViewer

% Last Modified by GUIDE v2.5 05-Mar-2009 14:00:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vuThreePaneViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @vuThreePaneViewer_OutputFcn, ...
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


% --- Executes just before vuThreePaneViewer is made visible.
function vuThreePaneViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vuThreePaneViewer (see VARARGIN)

% Choose default command line output for vuThreePaneViewer
handles.output = hObject;

% Check/Make input a Meta Image
if nargin < 1
	error('MATLAB:vuThreePaneViewer:NotEnoughInputs', 'Not enough input arguments.');
end
image = varargin{1};
if (~isStructure(image))
    image = vuGenerateMetaImage(image);
end
setappdata(gcf,'image',image);
setappdata(gcf,'measure',0);
% Calculate middle slices
midSlice = floor(image.Dims/2);
% Setup the sliders
set(handles.tlSlider,'Min',0.999)
set(handles.tlSlider,'Max',image.Dims(3))
set(handles.tlSlider,'SliderStep',[1./(image.Dims(3)-0.999) 1./(image.Dims(3)-0.999)]);
set(handles.tlSlider,'Value',midSlice(3));
set(handles.trSlider,'Min',0.999)
set(handles.trSlider,'Max',image.Dims(1))
set(handles.trSlider,'SliderStep',[1./(image.Dims(1)-0.999) 1./(image.Dims(1)-0.999)]);
set(handles.trSlider,'Value',midSlice(1));
set(handles.blSlider,'Min',0.999)
set(handles.blSlider,'Max',image.Dims(2))
set(handles.blSlider,'SliderStep',[1./(image.Dims(2)-0.999) 1./(image.Dims(2)-0.999)]);
set(handles.blSlider,'Value',midSlice(2));
set(handles.volSlider,'Value',1);
if (length(image.Dims)>3)
    set(handles.volSlider,'Min',0.999)
    set(handles.volSlider,'Max',image.Dims(4))
    set(handles.volSlider,'SliderStep',[1./(image.Dims(4)-0.999) 1./(image.Dims(4)-0.999)]);
    set(handles.volSlider,'Visible','on');
end

% Lines
xLine = midSlice(1);
yLine = midSlice(2);
zLine = midSlice(3);
setappdata(gcf,'noCallbacksTl',false);
setappdata(gcf,'noCallbacksTr',false);
setappdata(gcf,'noCallbacksBl',false);

% Show the image
axes(handles.tlFig)
imshow(squeeze(image.Data(:,:,midSlice(3),1)),[])
zhx = line([xLine xLine],[1 image.Dims(2)],'Color','r');
zhy = line([1 image.Dims(1)],[yLine yLine],'Color','r');
axes(handles.trFig)
imshow(squeeze(image.Data(:,midSlice(1),:,1)),[])
xhz = line([zLine zLine],[1 image.Dims(2)],'Color','r');
xhy = line([1 image.Dims(3)],[yLine yLine],'Color','r');
axes(handles.blFig)
imshow(squeeze(image.Data(midSlice(2),:,:,1)),[])
yhz = line([zLine zLine],[1 image.Dims(1)],'Color','r');
yhx = line([1 image.Dims(3)],[xLine xLine],'Color','r');

% Windowing Sliders
minValue = min(image.Data(:));
maxValue = max(image.Data(:));
if ((minValue-maxValue)==0)
    minValue = minValue-0.001;
end
setappdata(gcf,'curMin',minValue);
setappdata(gcf,'curMax',maxValue);

meanValue = (maxValue+minValue)/2;

if meanValue < handles.lowerSlide.Value
    set(handles.lowerSlide,'Min', minValue);
    set(handles.lowerSlide,'Value', meanValue);
    set(handles.lowerSlide,'Max', maxValue-0.0001);
    
    set(handles.upperSlide,'Min', minValue+0.0001);
    set(handles.upperSlide,'Value', meanValue);
    set(handles.upperSlide,'Max', maxValue);
else 
    set(handles.lowerSlide,'Max', maxValue-0.0001);
    set(handles.lowerSlide,'Value', meanValue);
    set(handles.lowerSlide,'Min', minValue);
    
     set(handles.upperSlide,'Max', maxValue);
     set(handles.upperSlide,'Value', meanValue);
     set(handles.upperSlide,'Min', minValue+0.0001);
end
    
    

% Set slider to 2%-98%
sortedImage = sort(image.Data(:));
lowerValue = sortedImage(round(0.02*length(nonzeros(sortedImage))));
upperValue = sortedImage(round(0.98*length(nonzeros(sortedImage))));
setappdata(gcf,'curMin',lowerValue);
setappdata(gcf,'curMax',upperValue);
if(lowerValue == upperValue)
    sortedImage(sortedImage==upperValue) = [];
    if (~isempty(sortedImage))
        upperValue = sortedImage(1);
    else
        lowerValue = minValue;
        upperValue = maxValue;
    end
end
set(handles.lowerSlide,'Value', lowerValue);
set(handles.upperSlide,'Value', upperValue);
set(handles.lowerText,'String',num2str(lowerValue));
set(handles.upperText,'String',num2str(upperValue));

axes(handles.tlFig)
caxis([lowerValue upperValue]);
axes(handles.trFig)
caxis([lowerValue upperValue]);
axes(handles.blFig)
caxis([lowerValue upperValue]);

% Labels
set(handles.tlText,'String',['Slice #: ' num2str(midSlice(3)) , ' Dimension 3']);
set(handles.trText,'String',['Slice #: ' num2str(midSlice(1)) , ' Dimension 2']);
set(handles.blText,'String',['Slice #: ' num2str(midSlice(2)) , ' Dimension 1']);
if (length(image.Dims)>3) 
    set(handles.volText,'String','Volume #: 1');
    set(handles.volText,'Visible','on');
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vuThreePaneViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vuThreePaneViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function tlSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tlSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
measure = getappdata(gcf,'measure');
if (~measure)
    curVal = round(get(handles.tlSlider,'Value'));
    curVol = round(get(handles.volSlider,'Value'));
    image = getappdata(gcf,'image');
    set(handles.tlSlider,'Value',curVal)
    axes(handles.tlFig)
    imshow(squeeze(image.Data(:,:,curVal,curVol)))
    curMin = getappdata(gcf,'curMin');
    curMax = getappdata(gcf,'curMax');
    caxis([curMin curMax]);
    xLine = round(get(handles.trSlider,'Value'));
    yLine = round(get(handles.blSlider,'Value'));
    zhx = line([xLine xLine],[1 image.Dims(2)],'Color','r');
    zhy = line([1 image.Dims(1)],[yLine yLine],'Color','r');
    
    mapString = get(handles.mapMenu,'String');
    mapValue = get(handles.mapMenu,'Value');
    eval(['colormap ' cell2mat(mapString(mapValue))]);
    
    % Labels
    set(handles.tlText,'String',['Slice #: ' num2str(curVal), ' Dimension 3']);
    
    
    noCallbacks = getappdata(gcf,'noCallbacksTl');
    if (noCallbacks)
        setappdata(gcf,'noCallbacksTl',false);
    else
        setappdata(gcf,'noCallbacksTr',true);
        setappdata(gcf,'noCallbacksBl',true);
        trSlider_Callback(handles.trSlider, eventdata, handles)
        blSlider_Callback(handles.blSlider, eventdata, handles)
    end
end
% --- Executes during object creation, after setting all properties.
function tlSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tlSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function trSlider_Callback(hObject, eventdata, handles)
% hObject    handle to trSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
measure = getappdata(gcf,'measure');
if (~measure)
    curVal = round(get(handles.trSlider,'Value'));
    curVol = round(get(handles.volSlider,'Value'));
    image = getappdata(gcf,'image');
    set(handles.trSlider,'Value',curVal)
    axes(handles.trFig)
    imshow(squeeze(image.Data(:,curVal,:,curVol)))
    curMin = getappdata(gcf,'curMin');
    curMax = getappdata(gcf,'curMax');
    caxis([curMin curMax]);
    zLine = round(get(handles.tlSlider,'Value'));
    yLine = round(get(handles.blSlider,'Value'));
    zhz = line([zLine zLine],[1 image.Dims(2)],'Color','r');
    zhy = line([1 image.Dims(1)],[yLine yLine],'Color','r');
    
    
    mapString = get(handles.mapMenu,'String');
    mapValue = get(handles.mapMenu,'Value');
    eval(['colormap ' cell2mat(mapString(mapValue))]);
    
    % Labels
    set(handles.trText,'String',['Slice #: ' num2str(curVal), ' Dimension 2']);
    
    noCallbacks = getappdata(gcf,'noCallbacksTr');
    if (noCallbacks)
        setappdata(gcf,'noCallbacksTr',false);
    else
        setappdata(gcf,'noCallbacksTl',true);
        setappdata(gcf,'noCallbacksBl',true);
        tlSlider_Callback(handles.tlSlider, eventdata, handles)
        blSlider_Callback(handles.blSlider, eventdata, handles)
    end
end
% --- Executes during object creation, after setting all properties.
function trSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function blSlider_Callback(hObject, eventdata, handles)
% hObject    handle to blSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
measure = getappdata(gcf,'measure');
if (~measure)
    curVal = round(get(handles.blSlider,'Value'));
    curVol = round(get(handles.volSlider,'Value'));
    image = getappdata(gcf,'image');
    set(handles.blSlider,'Value',curVal)
    axes(handles.blFig)
    imshow(squeeze(image.Data(curVal,:,:,curVol)))
    curMin = getappdata(gcf,'curMin');
    curMax = getappdata(gcf,'curMax');
    caxis([curMin curMax]);
    zLine = round(get(handles.tlSlider,'Value'));
    xLine = round(get(handles.trSlider,'Value'));
    zhz = line([zLine zLine],[1 image.Dims(1)],'Color','r');
    zhx = line([1 image.Dims(3)],[xLine xLine],'Color','r');
    
    mapString = get(handles.mapMenu,'String');
    mapValue = get(handles.mapMenu,'Value');
    eval(['colormap ' cell2mat(mapString(mapValue))]);
    
    % Labels
    set(handles.blText,'String',['Slice #: ' num2str(curVal), ' Dimension 1']);
    
    noCallbacks = getappdata(gcf,'noCallbacksBl');
    if (noCallbacks)
        setappdata(gcf,'noCallbacksBl',false);
    else
        setappdata(gcf,'noCallbacksTl',true);
        setappdata(gcf,'noCallbacksTr',true);
        tlSlider_Callback(handles.tlSlider, eventdata, handles)
        trSlider_Callback(handles.trSlider, eventdata, handles)
    end
end

% --- Executes during object creation, after setting all properties.
function blSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% Function to Check the Structure of the image
function isStruct = isStructure(X)

if(isstruct(X))
  %Check for meta image structure
  if(isfield(X,'Data') &&  isfield(X,'Dims') && ...
          isfield(X,'Spc') && isfield(X,'Origin'))
      isStruct = true;
      if (length(X.Dims) < 3 || length(X.Dims) > 4)
          error('MATLAB:vuThreePaneViewer:UnknownDims', 'vuThreePaneViewer can only handle images of 3 or 4 dimensions.');
      end
  else
      error('MATLAB:vuThreePaneViewer:InvalidStruct', 'The input image structure is not valid.');
  end
else
    if (ndims(X)~=3 && ndims(X)~=4)
          error('MATLAB:vuThreePaneViewer:UnknownDims', 'vuThreePaneViewer can only handle images of 3 or 4 dimensions.');
    end
    isStruct = false;
end

return

% --- Executes on button press in measure.
function measure_Callback(hObject, eventdata, handles)
% hObject    handle to measure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
measure = getappdata(gcf,'measure');
if (~measure)
    axes(handles.tlFig)
    h = imdistline;
    setappdata(gcf,'tlapi',iptgetapi(h))
    axes(handles.trFig)
    h = imdistline;
    setappdata(gcf,'trapi',iptgetapi(h))
    axes(handles.blFig)
    h =imdistline;
    setappdata(gcf,'blapi',iptgetapi(h))
    setappdata(gcf,'measure',1);
end
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
point = get(gca,'CurrentPoint');
image = getappdata(gcf,'image');
measure = getappdata(gcf,'measure');
selectionType = get(gcf,'SelectionType');

if(strcmp(selectionType,'open'))
    if(gca==handles.tlFig)
        if(round(point(1,1))>=1&&round(point(1,1))<=image.Dims(1) ...
                && round(point(1,2))>=1 && round(point(1,2))<=image.Dims(2))
            curVal = round(get(handles.tlSlider,'Value'));
            curVol = round(get(handles.volSlider,'Value'));
            vuOnePaneViewer(image,'pane',3,'slice',curVal,'dynamic',curVol)
        end
    elseif(gca==handles.trFig)
        if(round(point(1,1))>=1&&round(point(1,1))<=image.Dims(3) ...
                && round(point(1,2))>=1 && round(point(1,2))<=image.Dims(2))
            curVal = round(get(handles.trSlider,'Value'));
            curVol = round(get(handles.volSlider,'Value'));
            vuOnePaneViewer(image,'pane',1,'slice',curVal,'dynamic',curVol)
        end
    elseif(gca==handles.blFig) 
        if(round(point(1,1))>=1&&round(point(1,1))<=image.Dims(3) ...
                && round(point(1,2))>=1 && round(point(1,2))<=image.Dims(1))
            curVal = round(get(handles.blSlider,'Value'));
            curVol = round(get(handles.volSlider,'Value'));
            vuOnePaneViewer(image,'pane',2,'slice',curVal,'dynamic',curVol)
        end
    end
else
    if(~measure)
        if(gca==handles.tlFig)
            if(round(point(1,1))>=1&&round(point(1,1))<=image.Dims(1) ...
                    && round(point(1,2))>=1 && round(point(1,2))<=image.Dims(2))
                setappdata(gcf,'noCallbacksTl',true);
                setappdata(gcf,'noCallbacksTr',true);
                setappdata(gcf,'noCallbacksBl',true);
                set(handles.trSlider,'Value',round(point(1,1)))
                set(handles.blSlider,'Value',round(point(1,2)))
                trSlider_Callback(handles.trSlider, eventdata, handles)
                blSlider_Callback(handles.blSlider, eventdata, handles)
                tlSlider_Callback(handles.tlSlider, eventdata, handles)
            end
        elseif(gca==handles.trFig)
            if(round(point(1,1))>=1&&round(point(1,1))<=image.Dims(3) ...
                    && round(point(1,2))>=1 && round(point(1,2))<=image.Dims(2))
                setappdata(gcf,'noCallbacksTl',true);
                setappdata(gcf,'noCallbacksTr',true);
                setappdata(gcf,'noCallbacksBl',true);
                set(handles.tlSlider,'Value',round(point(1,1)))
                set(handles.blSlider,'Value',round(point(1,2)))
                tlSlider_Callback(handles.tlSlider, eventdata, handles)
                blSlider_Callback(handles.blSlider, eventdata, handles)
                trSlider_Callback(handles.trSlider, eventdata, handles)
            end
        elseif(gca==handles.blFig) 
            if(round(point(1,1))>=1&&round(point(1,1))<=image.Dims(3) ...
                    && round(point(1,2))>=1 && round(point(1,2))<=image.Dims(1))
                setappdata(gcf,'noCallbacksTl',true);
                setappdata(gcf,'noCallbacksTr',true);
                setappdata(gcf,'noCallbacksBl',true);
                set(handles.tlSlider,'Value',round(point(1,1)))
                set(handles.trSlider,'Value',round(point(1,2)))
                tlSlider_Callback(handles.tlSlider, eventdata, handles)
                trSlider_Callback(handles.trSlider, eventdata, handles)
                blSlider_Callback(handles.blSlider, eventdata, handles)
            end
        end
    end
end

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image = getappdata(gcf,'image');
setappdata(gcf,'measure',0);
midSlice = floor(image.Dims/2);
set(handles.tlSlider,'Value',midSlice(3));
set(handles.trSlider,'Value',midSlice(1));
set(handles.blSlider,'Value',midSlice(2));
set(handles.volSlider,'Value',1);

% Windowing Sliders
minValue = min(image.Data(:));
maxValue = max(image.Data(:));
if ((minValue-maxValue)==0)
    minValue = minValue-0.001;
end
setappdata(gcf,'curMin',minValue);
setappdata(gcf,'curMax',maxValue);
set(handles.lowerSlide,'Value', minValue);
set(handles.upperSlide,'Value', maxValue);
set(handles.lowerText,'String',num2str(minValue));
set(handles.upperText,'String',num2str(maxValue));

% Lines
xLine = midSlice(1);
yLine = midSlice(2);
zLine = midSlice(3);
setappdata(gcf,'noCallbacksTl',false);
setappdata(gcf,'noCallbacksTr',false);
setappdata(gcf,'noCallbacksBl',false);

% Show the image
axes(handles.tlFig)
imshow(squeeze(image.Data(:,:,midSlice(3),1)))
zhx = line([xLine xLine],[1 image.Dims(2)],'Color','r');
zhy = line([1 image.Dims(1)],[yLine yLine],'Color','r');
caxis([minValue maxValue]);
axes(handles.trFig)
imshow(squeeze(image.Data(:,midSlice(1),:,1)))
xhz = line([zLine zLine],[1 image.Dims(2)],'Color','r');
xhy = line([1 image.Dims(3)],[yLine yLine],'Color','r');
caxis([minValue maxValue]);
axes(handles.blFig)
imshow(squeeze(image.Data(midSlice(2),:,:,1)))
yhz = line([zLine zLine],[1 image.Dims(1)],'Color','r');
yhx = line([1 image.Dims(3)],[xLine xLine],'Color','r');
caxis([minValue maxValue]);

    set(handles.tlNPixels,'String','Pixels : ??');
    set(handles.trNPixels,'String','Pixels : ??');
    set(handles.blNPixels,'String','Pixels : ??');
    
    set(handles.tlDist,'String','Distance : ??');
    set(handles.trDist,'String','Distance : ??');
    set(handles.blDist,'String','Distance : ??');

    set(handles.tlLoc,'String','Location : ??');
    set(handles.trLoc,'String','Location : ??');
    set(handles.blLoc,'String','Location : ??');

% --- Executes on button press in measure2.
function measure2_Callback(hObject, eventdata, handles)
% hObject    handle to measure2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
measure = getappdata(gcf,'measure');
if (~measure)
    axes(handles.tlFig)
    [x,y] = ginput(2);
    h = imdistline(gca,x,y);
    setappdata(gcf,'tlapi',iptgetapi(h))
    axes(handles.trFig)
    [x,y] = ginput(2);
    h = imdistline(gca,x,y);
    setappdata(gcf,'trapi',iptgetapi(h))
    axes(handles.blFig)
    [x,y] = ginput(2);
    h = imdistline(gca,x,y);
    setappdata(gcf,'blapi',iptgetapi(h))
    setappdata(gcf,'measure',1);
end


% --- Executes on slider movement.
function upperSlide_Callback(hObject, eventdata, handles)
% hObject    handle to upperSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
usrMax = get(handles.upperSlide,'Value');
usrMax = round(usrMax*1000)/1000;
if (usrMax <= curMin)
    set(handles.upperSlide,'Value',curMax);
else
    setappdata(gcf,'curMax',usrMax);
    set(handles.upperText,'String',num2str(usrMax));
end
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
axes(handles.tlFig)
caxis([curMin curMax]);
axes(handles.trFig)
caxis([curMin curMax]);
axes(handles.blFig)
caxis([curMin curMax]);

% --- Executes during object creation, after setting all properties.
function upperSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function lowerSlide_Callback(hObject, eventdata, handles)
% hObject    handle to lowerSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
usrMin = get(handles.lowerSlide,'Value');
usrMin = round(usrMin*1000)/1000;
if (usrMin >= curMax)
    set(handles.lowerSlide,'Value',curMin);
else
    setappdata(gcf,'curMin',usrMin);
    set(handles.lowerText,'String',num2str(usrMin));
end
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
axes(handles.tlFig)
caxis([curMin curMax]);
axes(handles.trFig)
caxis([curMin curMax]);
axes(handles.blFig)
caxis([curMin curMax]);


% --- Executes during object creation, after setting all properties.
function lowerSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function upperText_Callback(hObject, eventdata, handles)
% hObject    handle to upperText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperText as text
%        str2double(get(hObject,'String')) returns contents of upperText as a double
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
usrMax = get(handles.upperText,'String');
usrMax = str2num(usrMax);
if (~isempty(usrMax))
    if (usrMax < curMin)
        usrMax = curMin+1;
        set(handles.upperText,'String',num2str(curMin+1));
    end
    setappdata(gcf,'curMax',usrMax);
    set(handles.upperSlide,'Value',usrMax);
else
    set(handles.upperText,'String',num2str(curMax));
end
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
axes(handles.tlFig)
caxis([curMin curMax]);
axes(handles.trFig)
caxis([curMin curMax]);
axes(handles.blFig)
caxis([curMin curMax]);

% --- Executes during object creation, after setting all properties.
function upperText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowerText_Callback(hObject, eventdata, handles)
% hObject    handle to lowerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerText as text
%        str2double(get(hObject,'String')) returns contents of lowerText as a double
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
usrMin = get(handles.lowerText,'String');
usrMin = str2num(usrMin);
if (~isempty(usrMin))
    if (usrMin > curMax)
        usrMin = curMax-1;
        set(handles.lowerText,'String',num2str(curMax-1));
    end
    setappdata(gcf,'curMin',usrMin);
    set(handles.lowerSlide,'Value',usrMin);
else
    set(handles.lowerText,'String',num2str(curMin));
end
curMin = getappdata(gcf,'curMin');
curMax = getappdata(gcf,'curMax');
axes(handles.tlFig)
caxis([curMin curMax]);
axes(handles.trFig)
caxis([curMin curMax]);
axes(handles.blFig)
caxis([curMin curMax]);

% --- Executes during object creation, after setting all properties.
function lowerText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mapMenu.
function mapMenu_Callback(hObject, eventdata, handles)
% hObject    handle to mapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns mapMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mapMenu
mapString = get(handles.mapMenu,'String');
mapValue = get(handles.mapMenu,'Value');
axes(handles.tlFig)
eval(['colormap ' cell2mat(mapString(mapValue))]);

% --- Executes during object creation, after setting all properties.
function mapMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateDist.
function updateDist_Callback(hObject, eventdata, handles)
% hObject    handle to updateDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
measure = getappdata(gcf,'measure');

if (measure)
    
    image = getappdata(gcf,'image');
    
    tlapi = getappdata(gcf,'tlapi');
    trapi = getappdata(gcf,'trapi');
    blapi = getappdata(gcf,'blapi');

    tldist = tlapi.getDistance();
    trdist = trapi.getDistance();
    bldist = blapi.getDistance();
    
    tlLoc = tlapi.getPosition();
    trLoc = trapi.getPosition();
    blLoc = blapi.getPosition();
    
    % Calculate Distance based on spacing
    xSpc = image.Spc(1);
    ySpc = image.Spc(2);
    zSpc = image.Spc(3);
    tlRealDist = sqrt(((tlLoc(2,1)-tlLoc(1,1))*xSpc)^2 + ((tlLoc(2,2)-tlLoc(1,2))*ySpc)^2);
    trRealDist = sqrt(((trLoc(2,1)-trLoc(1,1))*zSpc)^2 + ((trLoc(2,2)-trLoc(1,2))*ySpc)^2);
    blRealDist = sqrt(((blLoc(2,1)-blLoc(1,1))*zSpc)^2 + ((blLoc(2,2)-blLoc(1,2))*xSpc)^2);
    
    set(handles.tlNPixels,'String',sprintf('Pixels : %.2f',tldist));
    set(handles.trNPixels,'String',sprintf('Pixels : %.2f',trdist));
    set(handles.blNPixels,'String',sprintf('Pixels : %.2f',bldist));
    
    set(handles.tlDist,'String',sprintf('Distance : %.2f',tlRealDist));
    set(handles.trDist,'String',sprintf('Distance : %.2f',trRealDist));
    set(handles.blDist,'String',sprintf('Distance : %.2f',blRealDist));

    set(handles.tlLoc,'String',sprintf('Location : (%.2f %.2f) , (%.2f %.2f)',tlLoc(1,1),tlLoc(1,2),tlLoc(2,1),tlLoc(2,2)));
    set(handles.trLoc,'String',sprintf('Location : (%.2f %.2f) , (%.2f %.2f)',trLoc(1,1),trLoc(1,2),trLoc(2,1),trLoc(2,2)));
    set(handles.blLoc,'String',sprintf('Location : (%.2f %.2f) , (%.2f %.2f)',blLoc(1,1),blLoc(1,2),blLoc(2,1),blLoc(2,2)));
end


% --- Executes on slider movement.
function volSlider_Callback(hObject, eventdata, handles)
% hObject    handle to volSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
measure = getappdata(gcf,'measure');
if (~measure)
    curVal = round(get(handles.tlSlider,'Value'));
    curVol = round(get(handles.volSlider,'Value'));
    image = getappdata(gcf,'image');
    set(handles.tlSlider,'Value',curVal)
    axes(handles.tlFig)
    imshow(squeeze(image.Data(:,:,curVal,curVol)))
    curMin = getappdata(gcf,'curMin');
    curMax = getappdata(gcf,'curMax');
    caxis([curMin curMax]);
    xLine = round(get(handles.trSlider,'Value'));
    yLine = round(get(handles.blSlider,'Value'));
    zhx = line([xLine xLine],[1 image.Dims(2)],'Color','r');
    zhy = line([1 image.Dims(1)],[yLine yLine],'Color','r');
    
    mapString = get(handles.mapMenu,'String');
    mapValue = get(handles.mapMenu,'Value');
    eval(['colormap ' cell2mat(mapString(mapValue))]);
    
    % Labels
    set(handles.volText,'String',['Volume #: ' num2str(curVol)]);
    
    noCallbacks = getappdata(gcf,'noCallbacksTl');
    if (noCallbacks)
        setappdata(gcf,'noCallbacksTl',false);
    else
        setappdata(gcf,'noCallbacksTr',true);
        setappdata(gcf,'noCallbacksBl',true);
        trSlider_Callback(handles.trSlider, eventdata, handles)
        blSlider_Callback(handles.blSlider, eventdata, handles)
    end
end

% --- Executes during object creation, after setting all properties.
function volSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in setPoint.
function setPoint_Callback(hObject, eventdata, handles)
% hObject    handle to setPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tr = round(get(handles.trSlider,'Value'));
tl = round(get(handles.tlSlider,'Value'));
bl = round(get(handles.blSlider,'Value'));
vol = round(get(handles.volSlider,'Value'));
if (vol > 1)
    point = [tr bl tl vol];
else
    point = [tr bl tl];
end
if (evalin('base','exist(''threepaneViewerPoint'')'))
    existingPoint = evalin('base','threepaneViewerPoint');
else
    existingPoint = [];
end
assignin('base','threepaneViewerPoint',[existingPoint; point]);
