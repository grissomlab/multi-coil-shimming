addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\ % Main directory 
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\utility_functions % My utility functions 
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\Martinos_Shim\supporting_functions\helper_functions % Martinos shim functions
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\Martinos_Shim\supporting_functions % Martinos shim functions
addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\load_par_rec % For loading the nifti b0 files with proper scaling


%% Load coil field maps
ellipse = load_coil_field_maps([40, 40 , 40], 4, [3, 2, 1]); % Units of Hz;

%%
% Interpolate coil fields
coil_FOV = [280 220 200];                                      % Probe FOV that encompasses all of the coils; 
interpolated = interpolate_field_matrix(ellipse,coil_FOV, 1); % Interpolated coil field maps


%%
vuThreePaneViewer(sum(interpolated,4))   