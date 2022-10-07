%%  create_coil_structs
% This sript creates a struct array to contain the goil geometry parameters
% for input into the visualize_coil.m function

%% MRI Scanner Parameters
FOV_X = 70;  % Field of view in x axis (Left Right) in mm
FOV_Y = 160; % Field of view in y axis (Anterior Posteior) in mm
FOV_Z = 160; % Field of view in z axis (Foot Head) in mm

%% Volumetric of Interest & Probe Parameters
POS_PROB = [0 0 0];                                        % coordinates of probe in x,y,z in mm
PROBE_GRID_SIZE = [28 80 80];                              % probe grid size in each dimension in x,y,z
PROBE_DIMENSIONS = [FOV_X FOV_Y FOV_Z];                    % probe dimensions, same as scanner FOV
x_axis = linspace(-FOV_X/2,FOV_X/2,PROBE_GRID_SIZE(1));    % Generate the probe x axis in mm.
y_axis = linspace(-FOV_Y/2,FOV_Y/2,PROBE_GRID_SIZE(2));    % Generate the probe y axis in mm.
z_axis = linspace(-FOV_Z/2,FOV_Z/2,PROBE_GRID_SIZE(3));    % Generate the probe z axis in mm.
[X_MESH, Y_MESH, Z_MESH] = meshgrid(x_axis,y_axis,z_axis); % Volume of interest

%% Coil dimension parameters
LEFT_DIAM = 63.5;     % diameter of left coil in mm
RIGHT_DIAM = 63.5;    % diameter of right coil in mm
TOP_DIAM = 76.2;      % diameter of top coil in mm

POS_LEFT = [0 -66.675 0];   % coordinates of left coil in y x z in mm (based on Matt's CAD model)
POS_RIGHT = [0 66.675 0];   % coordinates of right coil in y x z in mm
POS_TOP =  [57.15 0 0];     % coordinates of top coil in y x z in mm 

ANG_LEFT = [90 0 0];       % rotation in degrees about y x z axis respectively
ANG_RIGHT = [90 0 0];      % rotation in degrees about y x z axis respectively
ANG_TOP = [0 90 0] ;      % rotation in degrees about y x z axis respectively

%% Create coil struct data structure
top_coil_struct = struct('coil_radius',TOP_DIAM/2,'coil_turns',1,'coil_center',POS_TOP,'angle',ANG_TOP);
left_coil_struct = struct('coil_radius',LEFT_DIAM/2,'coil_turns',1,'coil_center',POS_LEFT,'angle',ANG_LEFT);
right_coil_struct = struct('coil_radius',RIGHT_DIAM/2,'coil_turns',1,'coil_center',POS_RIGHT,'angle',ANG_RIGHT);

coil_struct = [top_coil_struct left_coil_struct right_coil_struct];



