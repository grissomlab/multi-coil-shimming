function varargout = Dynamic_Shimming(varargin)
% DYNAMIC_SHIMMIG M-file for Dynamic_Shimmig.fig
%      DYNAMIC_SHIMMIG, by itself, creates a new DYNAMIC_SHIMMIG or raises the existing
%      singleton*.
%
%      H = DYNAMIC_SHIMMIG returns the handle to a new DYNAMIC_SHIMMIG or the handle to
%      the existing singleton*.
%
%      DYNAMIC_SHIMMIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAMIC_SHIMMIG.M with the given input arguments.
%
%      DYNAMIC_SHIMMIG('Property','Value',...) creates a new DYNAMIC_SHIMMIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Dynamic_Shimmig_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Dynamic_Shimmig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Dynamic_Shimmig

% Last Modified by GUIDE v2.5 09-Feb-2021 15:46:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Dynamic_Shimming_OpeningFcn, ...
                   'gui_OutputFcn',  @Dynamic_Shimming_OutputFcn, ...
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


% --- Executes just before Dynamic_Shimming is made visible.
function Dynamic_Shimming_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Dynamic_Shimming (see VARARGIN)

% Choose default command line output for Dynamic_Shimming
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Dynamic_Shimming wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Dynamic_Shimming_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton1_Callback(hObject, eventdata, handles)

if isfield( handles, 'fieldmap')
handles = rmfield(handles,'fieldmap');
end

if isfield( handles, 'Data')
handles = rmfield(handles,'Data');
end

[handles.Output handles.parms] = readParRec;

[np_recon,nf_recon,sl,echo,phase,imtype,dyn] = size(handles.Output);

Np = handles.parms.scan_resolution(1);      % phase encoding steps
Nf = handles.parms.scan_resolution(2);      % frequency encoding steps

if Nf > Np            % Sometimes Nf < Np cos of less than 100% encoding.
    Np = Nf;
elseif Np > Nf
    Nf = Np;
end

if np_recon ~= Np || nf_recon ~= Nf

    for d = 1 : dyn
        for type = 1 : imtype
            for k = 1 : sl
                A = imresize(squeeze(handles.Output(:,:,k,1,1,type)), [ Np Nf]);
                handles.Data(:,:,k,1,1,type,d) = A;
            end
        end
    end

else
    handles.Data = handles.Output;
end


clear handles.Output;

handles.type = imtype;
axes(handles.axes1);
imagesc(handles.Data(:,:,1,handles.type),[-300 300]); 
% axis('off');
% colorbar('location','southoutside')


set(handles.InputSliceNo,'String','1');
set(handles.slider1,'Max',size(handles.Data,3));
set(handles.slider1,'SliderStep',[1/size(handles.Data,[3]), 1]) ;
set(handles.text41,'String', handles.parms.patient) ;

guidata(hObject, handles);   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton2_Callback(hObject, eventdata, handles)

A =  get(handles.popupmenu1,'Value');
B = get(handles.popupmenu1,'String');
handles.order = str2num(B{A}); %#ok<ST2NM>

A =  get(handles.popupmenu2,'Value');
B = get(handles.popupmenu2,'String');
handles.resol = str2num(B{A}); %#ok<ST2NM>

A =  get(handles.popupmenu3,'Value');
B = get(handles.popupmenu3,'String');
handles.fieldmap_Choice = B{A};

A =  get(handles.popupmenu4,'Value');
B = get(handles.popupmenu4,'String');
handles.type_acq = B{A};

A =  get(handles.popupmenu8,'Value');
B = get(handles.popupmenu8,'String');
handles.shim_type = B{A};

A =  get(handles.popupmenu9,'Value');
B = get(handles.popupmenu9,'String');
handles.slice_order = B{A};

A =  get(handles.popupmenu10,'Value');
B = get(handles.popupmenu10,'String');
handles.table_move = B{A};

handles.dummies = str2double(get(handles.edit5,'String'));
handles.dynamics = str2num(get(handles.edit1,'String')); %#ok<ST2NM>
handles.dataspace = str2double(get(handles.edit7,'String'));



    if isfield(handles,'coeffs') 
        handles = rmfield (handles,'coeffs');end
    if isfield(handles,'coeffs_1st') 
        handles = rmfield (handles,'coeffs_1st');end
    if isfield(handles,'coeffs_2nd') 
        handles = rmfield (handles,'coeffs_2nd');end
    if isfield(handles,'coeffs_3rd') 
    handles = rmfield (handles,'coeffs_3rd');end
    if isfield(handles,'coeffs_DAC') 
    handles = rmfield (handles,'coeffs_DAC');end
    
    set(handles.text20,'String',num2str(0));  %%% X
    set(handles.text21,'String',num2str(0));  %%% Y
    set(handles.text22,'String',num2str(0));  %%% Z

    set(handles.text23,'String',num2str(0));  %%% Z2
    set(handles.text24,'String',num2str(0));  %%% ZX
    set(handles.text25,'String',num2str(0));  %%% ZY
    set(handles.text26,'String',num2str(0));  %%% C2
    set(handles.text27,'String',num2str(0));  %%% S2

    set(handles.text28,'String',num2str(0));%Z3
    set(handles.text29,'String',num2str(0));%Z2X
    set(handles.text30,'String',num2str(0));%Z2Y
    set(handles.text31,'String',num2str(0));%ZC2
    set(handles.text32,'String',num2str(0));%2XYZ
    set(handles.text33,'String',num2str(0)); % F0
   

guidata(hObject, handles);


if (strcmp(handles.shim_type,'Dynamic') || strcmp(handles.shim_type,'Dynamic_3Sl')) && handles.order == 2 
    msgbox( 'Higher Dynamic Shim not available on this system');
    return
end

if strcmp(handles.shim_type,'Dynamic') || strcmp(handles.shim_type,'Dynamic_3Sl')
Philips_Dynamic_Shim_GUI;
elseif strcmp(handles.shim_type,'Global')
Philips_Global_Shim_GUI;
elseif strcmp(handles.shim_type,'Combined')
Philips_Combined_Shim_GUI;
end

handles.MapAfterShim = A;


axes(handles.axes2);
imagesc(handles.MapAfterShim(:,:,1),[-300 300]);
%colorbar('location','southoutside')

set(handles.OutPutSlice,'String','1');
set(handles.slider2,'Max',size(handles.fieldmap,[3]));  %#ok<NBRAK>
set(handles.slider2,'SliderStep',[1/size(handles.fieldmap,[3]), 1])  %#ok<NBRAK>

msgbox('Shim Calculation Completed');

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton3_Callback(hObject, eventdata, handles)

if isfield( handles, 'coeffs_DAC')
 rri_lng_GUI(handles);
 msgbox('Real Time Shim System Reloaded');
else    
  msgbox('No 2nd Order Values in Memory , RTS NOT LOADED');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu1_Callback(hObject, eventdata, handles)

A =  get(handles.popupmenu1,'Value');
B = get(handles.popupmenu1,'String');
handles.order = B{A};

guidata(hObject, handles);


function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slider1_Callback(hObject, eventdata, handles)

value = round(get(hObject,'Value'));

if value ~= 0
    
    axes(handles.axes1);
    imagesc(handles.Data(:,:,value,handles.type),[-300 300]);
    %colorbar('location','southoutside')    

    if isfield( handles, 'fieldmap')
        axes(handles.axes3);
        imagesc(handles.fieldmap(:,:,value),[-300 300]);
        %colorbar('location','southoutside')
    end

    set(handles.InputSliceNo,'String',value);

end

guidata(hObject, handles);


function slider1_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slider2_Callback(hObject, eventdata, handles)

value = round(get(hObject,'Value'));

if value ~= 0

    axes(handles.axes2);
    imagesc(handles.MapAfterShim(:,:,value),[-300 300]);
   % colorbar('location','southoutside')


    set(handles.OutPutSlice,'String',value);


    if handles.order == 1

    set(handles.text20,'String',num2str(handles.coeffs_1st(2,value)));  %%% X
    set(handles.text21,'String',num2str(handles.coeffs_1st(3,value)));  %%% Y
    set(handles.text22,'String',num2str(handles.coeffs_1st(1,value)));  %%% Z

    elseif handles.order == 2

    set(handles.text20,'String',num2str(handles.coeffs_1st(2,value)));  %%% X
    set(handles.text21,'String',num2str(handles.coeffs_1st(3,value)));  %%% Y
    set(handles.text22,'String',num2str(handles.coeffs_1st(1,value)));  %%% Z

    set(handles.text23,'String',num2str(handles.coeffs_2nd(1,value)));  %%% Z2
    set(handles.text24,'String',num2str(handles.coeffs_2nd(2,value)));  %%% ZX
    set(handles.text25,'String',num2str(handles.coeffs_2nd(4,value)));  %%% ZY
    set(handles.text26,'String',num2str(handles.coeffs_2nd(3,value)));  %%% C2
    set(handles.text27,'String',num2str(handles.coeffs_2nd(5,value)));  %%% S2

    elseif handles.order == 3

    set(handles.text20,'String',num2str(handles.coeffs_1st(2,value)));  %%% X
    set(handles.text21,'String',num2str(handles.coeffs_1st(3,value)));  %%% Y
    set(handles.text22,'String',num2str(handles.coeffs_1st(1,value)));  %%% Z

    set(handles.text23,'String',num2str(handles.coeffs_2nd(1,value)));  %%% Z2
    set(handles.text24,'String',num2str(handles.coeffs_2nd(2,value)));  %%% ZX
    set(handles.text25,'String',num2str(handles.coeffs_2nd(4,value)));  %%% ZY
    set(handles.text26,'String',num2str(handles.coeffs_2nd(3,value)));  %%% C2
    set(handles.text27,'String',num2str(handles.coeffs_2nd(5,value)));  %%% S2

    set(handles.text28,'String',num2str(handles.coeffs_3rd(1,value)));%Z3
    set(handles.text29,'String',num2str(handles.coeffs_3rd(2,value)));%Z2X
    set(handles.text30,'String',num2str(handles.coeffs_3rd(4,value)));%Z2Y
    set(handles.text31,'String',num2str(handles.coeffs_3rd(3,value)));%ZC2
    set(handles.text32,'String',num2str(handles.coeffs_3rd(5,value)));%2XYZ
   
    end
    
    set(handles.text33,'String',num2str(handles.Freq_Offset(value))); % F0

end

guidata(hObject, handles);


function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu2_Callback(hObject, eventdata, handles)

A =  get(handles.popupmenu2,'Value');
B = get(handles.popupmenu2,'String');
handles.resol = str2num(B{A});                  %#ok<ST2NM>

guidata(hObject, handles);


function popupmenu2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit1_Callback(hObject, eventdata, handles)

handles.dynamics = str2double(get(hObject,'String'));
guidata(hObject, handles);


function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu3_Callback(hObject, eventdata, handles)

A =  get(handles.popupmenu3,'Value');
B = get(handles.popupmenu3,'String');
handles.fieldmap_Choice = B{A};


guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InputSliceNo_Callback(hObject, eventdata, handles)


Slice_Select_Val = str2double(get(handles.InputSliceNo,'String'));

if Slice_Select_Val == 0 || Slice_Select_Val > size(handles.Data,3)
    h = errordlg(' Slice value out of range');
    
else
    set(handles.slider1,'Value',Slice_Select_Val);
    
    axes(handles.axes1);
    imagesc(handles.Data(:,:,Slice_Select_Val,handles.imtype),[-300 300]);
   % colorbar('location','southoutside')
 
   if isfield( handles, 'fieldmap')
    axes(handles.axes3);
    imagesc(handles.fieldmap(:,:,Slice_Select_Val),[-300 300]);
   % colorbar('location','southoutside')
   end
   
end


function InputSliceNo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OutPutSlice_Callback(hObject, eventdata, handles)

Slice_Select_Val = str2double(get(handles.OutPutSlice,'String'));

if Slice_Select_Val == 0 || Slice_Select_Val > size(handles.fieldmap,3) 
    h = errordlg(' Slice value out of range');
    
else
    set(handles.slider2,'Value',Slice_Select_Val);
    axes(handles.axes2);
    imagesc(handles.MapAfterShim(:,:,Slice_Select_Val),[-300 300]);
    %colorbar('location','southoutside')
end



function OutPutSlice_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu4_Callback(hObject, eventdata, handles)

A =  get(handles.popupmenu4,'Value');
B = get(handles.popupmenu4,'String');
handles.type_acq = B{A};

guidata(hObject, handles);


function popupmenu4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function edit5_Callback(hObject, eventdata, handles)

handles.dummies = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)

A =  get(handles.popupmenu7,'Value');
B = get(handles.popupmenu7,'String');
handles.roi_type = B{A};

handles.bs_thresh =  str2double(get(handles.edit6,'String'));
handles.auto_thresh =  str2double(get(handles.edit8,'String'));
handles.Fat_Min = str2double(get(handles.edit9,'String'));
handles.Fat_Max = str2double(get(handles.edit10,'String'));

[handles.fieldmap handles.roi]= Philips_Thresholding(handles);

axes(handles.axes3);
imagesc(handles.fieldmap(:,:,1),[-300 300]);
axis('off');
% colorbar('location','southoutside')

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

A =  get(handles.popupmenu8,'Value');
B = get(handles.popupmenu8,'String');
handles.shim_type = B{A};

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)

handles.bs_thresh = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.dataspace = str2double(get(hObject,'String'));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)

handles.auto_thresh = str2double(get(hObject,'String'));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

A =  get(handles.popupmenu9,'Value');
B = get(handles.popupmenu9,'String');
handles.slice_order = B{A};

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.Fat_Min = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Fat_Max = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10

%contents = cellstr(get(hObject,'String'));

A = get(handles.popupmenu10,'Value');
B = get(handles.popupmenu10,'String');
handles.table_move = B{A};

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
