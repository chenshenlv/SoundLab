function varargout = horizontal(varargin)
% HORIZONTAL MATLAB code for horizontal.fig
%      HORIZONTAL, by itself, creates a new HORIZONTAL or raises the existing
%      singleton*.
%
%      H = HORIZONTAL returns the handle to a new HORIZONTAL or the handle to
%      the existing singleton*.
%
%      HORIZONTAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HORIZONTAL.M with the given input arguments.
%
%      HORIZONTAL('Property','Value',...) creates a new HORIZONTAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before horizontal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to horizontal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help horizontal

% Last Modified by GUIDE v2.5 29-Jan-2019 02:33:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @horizontal_OpeningFcn, ...
                   'gui_OutputFcn',  @horizontal_OutputFcn, ...
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


% --- Executes just before horizontal is made visible.
function horizontal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to horizontal (see VARARGIN)
% HRTF load in
num = 0; % number of hrtfs loaded
path = uigetdir(pwd,'Please select the folder');
filelist = dir(sprintf('%s/*.mat',path));
for i = 1 : length(filelist)
    clear data specs
    num = num + 1;
    fprintf('Now loading: %s\n',filelist(i).name);
    hrtf_struct(i)=load(sprintf('%s/%s',path,filelist(i).name));
%     hrtf_struct(i).az = az;
%     hrtf_struct(i).hrir_l = hrir_l;
%     hrtf_struct(i).num = num;
%     hrtf_struct(i) = filelist(i).name
end

handles.hrtf_struct=hrtf_struct;

% Initialization the hrtf
% handles.R_hrtf_num=floor(1+length(handles.hrtf_struct).*rand(1,1));
% handles.hrtf_struct=hrtf_struct(handles.R_hrtf_num);
% ind = []; % indices for horizontal plane
% data=handles.hrtf_struct;
% for j = 1 : length(handles.hrtf_struct)    
%     if data(j).el == 0 && mod(data(j).az,30)==0
%          ind = [ind, j];% index for elevation equal to zero
%          handles.ind=ind;
%     end
% end 


%% NEED TO BE MODIFY
%--generate 12 test points or 24
azs_index=[];
azs_ground_truth=[];
for i=1:24
    azs_index=[azs_index,i];
    %handles.hrir=handles.hrtf_struct.data(handles.R_azs_num).IR;   
end
handles.azs_index=azs_index;
R_azs_num=azs_index(randperm(length(handles.azs_index)));
handles.R_azs_num=R_azs_num;

%--generate HRTF order
HRTF_index=[];
HRTF_ground_truth=[];
for i=1:length(handles.hrtf_struct)
    HRTF_index=[HRTF_index,i];
    %handles.hrir=handles.hrtf_struct.data(handles.R_azs_num).IR;   
end
handles.HRTF_index=HRTF_index;
R_HRTF_index=HRTF_index(randperm(length(handles.HRTF_index)));
handles.R_HRTF_index=R_HRTF_index;

%--store azithum ground truth 
for i=1:24
    azs=handles.hrtf_struct(1).HRTF(handles.R_azs_num(i)).az;
    azs_ground_truth=[azs_ground_truth,azs];
end
handles.azs_ground_truth=azs_ground_truth;
save('azs_ground_truth_1.mat', 'azs_ground_truth') 

%--initiate an array to store test result 
choice_result=zeros(1,72);
handles.choice_result=choice_result;
handles.choice_result_r=handles.choice_result;
% initialize a counter for count click save number
click_num=1;
handles.click_num=click_num;
% initialize a counter for count test times
test_num=1;
handles.test_num=test_num;
% to initialize the sampling frequency
for i=1:length(handles.hrtf_struct)
    handles.fs(i) = handles.hrtf_struct(i).HRTF(1).srate;
end
set(handles.text_fs,'String',handles.hrtf_struct(R_HRTF_index(1)).HRTF(1).srate)

% to specify parameters for making input
handles.sigRep = 10;
handles.sigRepPrep = 10;
% to make input signal
handles = mk_signal(handles); % to be saved in handles.mono
% Set the timer
handles.timer = timer('StartDelay',0.5, ...
    'ExecutionMode', 'fixedSpacing', ...       % Run timer repeatedly
    'Period', 2, ...                        % Initial period is 1 sec.
    'TimerFcn', {@Playsound,hObject}); % Specify callback function

%initiate save button
handles.Save1.Enable='off';

% Choose default command line output for horizontal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes horizontal wait for user response (see UIRESUME)
% uiwait(handles.figure1);



%% Make Stimuli

function pinkn = mk_pink(npts)

Den = poly([0.99572754 0.94790649 0.53567505]);    %set up the denominator and numerator polynomials for a digital IIR pink-noise filter
Num = poly([0.98443604 0.83392334 0.07568359]);

seg = rand(size(1:npts));
seg = seg - mean(seg);
pinkn = filter(Num,Den,seg);      %create the pink noise signal
% --- make infrapitch
function y = mk_infrapitch(handles)
handles.durBase = 1/handles.sigRep; % 0.2 per base
for i=1:length(handles.fs)
    infraBase(i).base = mk_pink(ceil(handles.fs(i)*handles.durBase)); 
end

for i=1:length(infraBase)
    handles.fullSig(i).fullsig = [];
    for iRep = 1:handles.sigRepPrep
        handles.fullSig(i).fullsig = [handles.fullSig(i).fullsig, infraBase(i).base];
    end
    mono(i).mono = handles.fullSig(i).fullsig;
    mono_for_save=mono(i).mono;
    filenm=['infrapitch' num2str(i) '.mat'];
    save(filenm, 'mono_for_save')
    
end
handles.mono = mono; 

%handles.mono = handles.fullSig(1:ceil(min(handles.fs*handles.sigLength, length(handles.fullSig))));
y = handles;

function y = mk_signal(handles)
clear mono
clear handles.mono
handles = mk_infrapitch(handles);
display('making infrapitch');
y = handles;

% --- Outputs from this function are returned to the command line.
function varargout = horizontal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PlaySound_4.
function PlaySound_4_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(4)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(4))).azimuth


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11


% --- Executes on button press in radiobutton12.
function radiobutton12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton12


% --- Executes on button press in radiobutton13.
function radiobutton13_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton13


% --- Executes on button press in radiobutton14.
function radiobutton14_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton14


% --- Executes on button press in radiobutton15.
function radiobutton15_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton15


% --- Executes on button press in radiobutton16.
function radiobutton16_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton16


% --- Executes on button press in radiobutton17.
function radiobutton17_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton17


% --- Executes on button press in radiobutton18.
function radiobutton18_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton18


% --- Executes on button press in radiobutton19.
function radiobutton19_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton19


% --- Executes on button press in radiobutton20.
function radiobutton20_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton20


% --- Executes on button press in radiobutton21.
function radiobutton21_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton21


% --- Executes on button press in radiobutton22.
function radiobutton22_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton22


% --- Executes on button press in radiobutton23.
function radiobutton23_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton23


% --- Executes on button press in radiobutton24.
function radiobutton24_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton24


% --- Executes on button press in radiobutton25.
function radiobutton25_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton25


% --- Executes on button press in radiobutton26.
function radiobutton26_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton26


% --- Executes on button press in radiobutton27.
function radiobutton27_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton27


% --- Executes on button press in radiobutton28.
function radiobutton28_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton28


% --- Executes on button press in radiobutton29.
function radiobutton29_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton29


% --- Executes on button press in radiobutton30.
function radiobutton30_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton30


% --- Executes on button press in radiobutton31.
function radiobutton31_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton31


% --- Executes on button press in radiobutton33.
function radiobutton33_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton33


% --- Executes on button press in radiobutton34.
function radiobutton34_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton34


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.



% --- Executes on button press in PlaySound_3.
function PlaySound_3_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(3)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(3))).azimuth


% --- Executes on button press in PlaySound_2.
function PlaySound_2_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(2)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(2))).azimuth


% --- Executes on button press in Next.
function Next_Callback(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SubjectNum,'Enable','inactive')
handles.HRTF_Pick=handles.R_HRTF_index(mod(handles.click_num,length(handles.hrtf_struct))+1);
handles.hrir_r=handles.hrtf_struct(handles.HRTF_Pick).HRTF(handles.R_azs_num(handles.click_num)).hrir_r;
handles.hrir_l=handles.hrtf_struct(handles.HRTF_Pick).HRTF(handles.R_azs_num(handles.click_num)).hrir_l;
IR_r=handles.hrir_r;
IR_l=handles.hrir_l;
left = conv(IR_l,handles.mono(handles.HRTF_Pick).mono);
right = conv(IR_r,handles.mono(handles.HRTF_Pick).mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
set(handles.text_fs,'String',handles.fs(handles.HRTF_Pick))
sound(v,handles.fs(handles.HRTF_Pick));
set(handles.Next,'Enable','off')
set(handles.Save1,'Enable','on')
%start a timer
time=cputime;
handles.time=time;

azs=(handles.R_azs_num(handles.click_num)-1)*15
guidata(hObject, handles);

% --- Executes on button press in PlaySound_7.
function PlaySound_7_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(7)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(7))).azimuth


% --- Executes on button press in PlaySound_8.
function PlaySound_8_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(8)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(8))).azimuth


% --- Executes on button press in PlaySound_9.
function PlaySound_9_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(9)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(9))).azimuth


% --- Executes on button press in PlaySound_10.
function PlaySound_10_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(10)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(10))).azimuth


% --- Executes on button press in PlaySound_11.
function PlaySound_11_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(11)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(11))).azimuth


% --- Executes on button press in PlaySound_12.
function PlaySound_12_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(12)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(12))).azimuth


% --- Executes on button press in PlaySound_6.
function PlaySound_6_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(6)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(6))).azimuth


% --- Executes on button press in PlaySound_5.
function PlaySound_5_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySound_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hrir=handles.hrtf_struct.data(handles.R_azs_num(5)).IR;
IR=handles.hrir;
left = conv(IR(:,1),handles.mono);
right = conv(IR(:,2),handles.mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs);
azs=handles.hrtf_struct.data(handles.ind(handles.R_azs_num(5))).azimuth


% --- Executes on key press with focus on Next and none of its controls.
function Next_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    

% --- Executes on button press in Save1.
function Save1_Callback(hObject, eventdata, handles)
% hObject    handle to Save1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--compute decision time
handles.e=cputime-handles.time;
%--the choice of subject
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+5)/5;
handles.choice_result(iLoc)=handles.choice_result(iLoc)+1;
choice_result=handles.choice_result;
%--establish a struct to store user result
handles.test_result(handles.test_num).subject=get(handles.SubjectNum,'Value');
handles.test_result(handles.test_num).HRTF_BASE=handles.R_HRTF_index(handles.HRTF_Pick);
handles.test_result(handles.test_num).Ground_Truth=handles.azs_ground_truth(handles.click_num);
handles.test_result(handles.test_num).Subject_Choice=deg_picked;
handles.test_result(handles.test_num).Choice_sumup=choice_result;
handles.test_result(handles.test_num).time=handles.e;
test_result=handles.test_result;
filenm=['test_result_sub' num2str(test_result(1).subject) '.mat'];
save(filenm,'test_result');
save('choice_result.mat','choice_result');
set(handles.Save1,'Enable','off');
set(handles.Next,'Enable','on');
handles.click_num=handles.click_num+1;
if mod(handles.click_num,3)==0
    handles.R_HRTF_index=handles.HRTF_index(randperm(length(handles.HRTF_index)));
end
if handles.click_num==12
    handles.R_azs_num=handles.azs_index(randperm(length(handles.azs_index)));
    handles.click_num=1;
end
handles.test_num=handles.test_num+1;
set(handles.edit_rep,'String',handles.test_num)
if handles.test_num==120
    msgbox('Complete')
    set(handles.Save1,'Enable','off');
    set(handles.Next,'Enable','off');
end
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Next.
function Next_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Next.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_2.
function PlaySound_2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_2.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_3.
function PlaySound_3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_3.BackgroundColor=[0,0.94,0];


% --- Executes on button press in Save2.
function Save2_Callback(hObject, eventdata, handles)
% hObject    handle to Save2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result
save('test_result.mat','test_result');
set(handles.Save2,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save3.
function Save3_Callback(hObject, eventdata, handles)
% hObject    handle to Save3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result
save('test_result.mat','test_result');
set(handles.Save3,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save4.
function Save4_Callback(hObject, eventdata, handles)
% hObject    handle to Save4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save4,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save5.
function Save5_Callback(hObject, eventdata, handles)
% hObject    handle to Save5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save5,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save6.
function Save6_Callback(hObject, eventdata, handles)
% hObject    handle to Save6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save6,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save12.
function Save12_Callback(hObject, eventdata, handles)
% hObject    handle to Save12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save12,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save11.
function Save11_Callback(hObject, eventdata, handles)
% hObject    handle to Save11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save11,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save10.
function Save10_Callback(hObject, eventdata, handles)
% hObject    handle to Save10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save10,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save9.
function Save9_Callback(hObject, eventdata, handles)
% hObject    handle to Save9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save9,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save8.
function Save8_Callback(hObject, eventdata, handles)
% hObject    handle to Save8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save8,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in Save7.
function Save7_Callback(hObject, eventdata, handles)
% hObject    handle to Save7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deg_picked = str2num(get(get(handles.uibuttongroup2,'SelectedObject'), 'String'));
iLoc=(deg_picked+15)/15;
handles.test_result(iLoc)=handles.test_result(iLoc)+1;
test_result=handles.test_result;
save('test_result.mat','test_result');
set(handles.Save7,'Enable','off')
guidata(hObject, handles);

% --- Executes on button press in deg0.
function deg0_Callback(hObject, eventdata, handles)
% hObject    handle to deg0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of deg0


% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% switch(get(eventdata.NewValue,'Tag'));
%     case 'deg0'
%         temp_array=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%     case 'deg15'
        


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_4.
function PlaySound_4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_4.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_5.
function PlaySound_5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_5.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_6.
function PlaySound_6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_6.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_7.
function PlaySound_7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_7.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_8.
function PlaySound_8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_8.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_9.
function PlaySound_9_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_9.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_10.
function PlaySound_10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_10.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_11.
function PlaySound_11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_11.BackgroundColor=[0,0.94,0];


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlaySound_12.
function PlaySound_12_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlaySound_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlaySound_12.BackgroundColor=[0,0.94,0];


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SubjectNum.
function SubjectNum_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SubjectNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubjectNum


% --- Executes during object creation, after setting all properties.
function SubjectNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjectNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in text_fs.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to text_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns text_fs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from text_fs


% --- Executes during object creation, after setting all properties.
function text_fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Replay.
function Replay_Callback(hObject, eventdata, handles)
% hObject    handle to Replay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IR_r=handles.hrir_r;
IR_l=handles.hrir_l;
left = conv(IR_l,handles.mono(handles.HRTF_Pick).mono);
right = conv(IR_r,handles.mono(handles.HRTF_Pick).mono);
if isrow(left)
    left = left';
    right = right';
    v = [left,right];
end
sound(v,handles.fs(handles.HRTF_Pick));



function edit_rep_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rep as text
%        str2double(get(hObject,'String')) returns contents of edit_rep as a double


% --- Executes during object creation, after setting all properties.
function edit_rep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
