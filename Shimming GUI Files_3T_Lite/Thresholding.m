function varargout = Thresholding(varargin)
% THRESHOLDING M-file for Thresholding.fig
%      THRESHOLDING, by itself, creates a new THRESHOLDING or raises the existing
%      singleton*.
%
%      H = THRESHOLDING returns the handle to a new THRESHOLDING or the handle to
%      the existing singleton*.
%
%      THRESHOLDING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THRESHOLDING.M with the given input arguments.
%
%      THRESHOLDING('Property','Value',...) creates a new THRESHOLDING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Thresholding_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Thresholding_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Thresholding

% Last Modified by GUIDE v2.5 05-Dec-2007 15:58:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Thresholding_OpeningFcn, ...
                   'gui_OutputFcn',  @Thresholding_OutputFcn, ...
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


% --- Executes just before Thresholding is made visible.
function Thresholding_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Thresholding (see VARARGIN)

handles.data = varargin{1,1};
axes(handles.axes1); 
imagesc(handles.data(:,:,1,2));
set(handles.edit1,'String',0);   
set(handles.edit2,'String',1);   

set(handles.slider1,'Max',size(handles.data,[3])); %#ok<NBRAK>
set(handles.slider1,'SliderStep',[1/size(handles.data,[3]), 1]) %#ok<NBRAK>


% Choose default command line output for Thresholding
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Thresholding wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Thresholding_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

value = round(get(hObject,'Value'));

if value ~= 0
    
axes(handles.axes1);
imagesc(handles.data(:,:,value,2));
%colorbar('location','southoutside')    
 
if isfield( handles, 'mask')
    axes(handles.axes2);
    imagesc(handles.mask(:,:,value));
    %colorbar('location','southoutside')
end
  
if isfield( handles, 'data_out')
    axes(handles.axes3);
    imagesc(handles.data_out(:,:,value));
    %colorbar('location','southoutside')
end


set(handles.edit2,'String',value);

end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

global gui_mask

Threshold = str2double(get(hObject,'String'));
Slice = str2double(get(handles.edit2,'String'));  

[handles.seg_im,handles.mask] = vuBrainExtraction(handles.data(:,:,:,1),'frac_thresh',Threshold);
clear seg_im;
handles.data_out = handles.data(:,:,:,2) .* handles.mask;

axes(handles.axes1); 
imagesc(handles.data(:,:,Slice,2));

if isfield( handles, 'mask')
axes(handles.axes2); 
imagesc(handles.mask(:,:,Slice));
end


if isfield( handles, 'data_out')
axes(handles.axes3); 
imagesc(handles.data_out(:,:,Slice));
end

gui_mask = handles.mask;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


Slice = str2double(get(hObject,'String'));

axes(handles.axes1); 
imagesc(handles.data(:,:,Slice,2));

if isfield( handles, 'mask')
axes(handles.axes2); 
imagesc(handles.mask(:,:,Slice));
end


if isfield( handles, 'data_out')
axes(handles.axes3); 
imagesc(handles.data_out(:,:,Slice));
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close;
