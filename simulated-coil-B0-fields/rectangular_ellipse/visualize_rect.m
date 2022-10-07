addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\ % Main directory 
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\utility_functions % My utility functions 
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\Martinos_Shim\supporting_functions\helper_functions % Martinos shim functions
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\Martinos_Shim\supporting_functions % Martinos shim functions
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\load_par_rec % For loading the nifti b0 files with proper scaling


%% Convert exported field files in Fields_Rect.mat to .txt 
load('Fields_Rect.mat')
field = [];
for i=1:length(data)
    name = num2str(i);
    type = '.txt';
    writematrix(cell2mat(data(i)), strcat(name, type), 'Delimiter','tab')
end

%% Load coil field maps
column = 6;
reorientation = [2,1,3];
probe_grid_size = [64, 64, 64];
rect = load_coil_field_maps(probe_grid_size, column, reorientation); % Units of Hz;

%% Interpolate coil fields
coil_FOV = [300 300 300]; % Probe FOV that encompasses all of the coils, units in mm; 
interpolated = interpolate_field_matrix(rect,coil_FOV, 1); % Interpolated coil field maps


%%
vuThreePaneViewer(sum(interpolated,4))   