function [SH_shims] = define_SH_shims(FOV_X, FOV_Y, FOV_Z, grid_size)
%DEFINE_SH_SHIMS Defines Spherical Harmonic (SH) shims using Sengupta code
%   Detailed explanation goes here


%% MRI Scanner Parameters
% FOV_X = 70;  % Field of view in x axis (Left Right) in mm
% FOV_Y = 160; % Field of view in y axis (Anterior Posteior) in mm
% FOV_Z = 160; % Field of view in z axis (Foot Head) in mm

% Define 1 Amp Spherical Harmonic Shims
y_axis = linspace(-FOV_X/2,FOV_X/2 -1, grid_size(1));
x_axis = linspace(-FOV_Y/2,FOV_Y/2 -1, grid_size(2));
z_axis = linspace(-FOV_Z/2,FOV_Z/2 -1, grid_size(3));


[X_COORDINATES,Y_COORDINATES,Z_COORDINATES] = meshgrid(x_axis, y_axis, z_axis); % These coordinate matrices represent actual position in mm's
% Spherical Harmonic Shim Strengths (mT/m^n/A)
Z0_Str = 1;       
X_Str = 0.056818182; %20/10;    
Y_Str = 0.054347826; %20/10; 
Z_Str = 0.052910053; %20/10;  
Z2_Str = 0.193050193; %2.5/100; 
ZX_Str = -0.389105058; %2.5/100; 
ZY_Str = -0.389105058; %2.5/100; 
C2_Str = -0.184501845; %2.5/100;
S2_Str = -0.184501845; %2.5/100;

% Spherical Harmonic (SH) Shim Flags [Z0 X,Y,Z,Z2,ZX,ZY,C2,S2]
SH_SHIM_FLAGS = [0,1,1,1,0,0,0,0,0];

SH_shims = zeros(grid_size(1), grid_size(2),grid_size(3),9); % Pages of 3D volumes covering imaging volume, one page for each SH shim.

% First order linear shims. Units are Hz/A
SH_shims(:,:,:,1) = Z0_Str*ones(grid_size(1), grid_size(2),grid_size(3));
SH_shims(:,:,:,2) = X_Str*X_COORDINATES;
SH_shims(:,:,:,3) = Y_Str*Y_COORDINATES;
SH_shims(:,:,:,4) = Z_Str*Z_COORDINATES;

% Second order shims. Units are Hz/A
Z2f = Z2_Str*(Z_COORDINATES.^2 -(X_COORDINATES.^2+Y_COORDINATES.^2)/2); 
SH_shims(:,:,:,5) = Z2f;

ZXf = ZX_Str*(Z_COORDINATES.*X_COORDINATES); 
SH_shims(:,:,:,6) = ZXf;

ZYf = ZY_Str*(Z_COORDINATES.*Y_COORDINATES); 
SH_shims(:,:,:,7) = ZYf;

X2Y2f = C2_Str*(X_COORDINATES.^2-Y_COORDINATES.^2); 
SH_shims(:,:,:,8) = X2Y2f;

XYf = S2_Str*(X_COORDINATES.*Y_COORDINATES); 
SH_shims(:,:,:,9) = XYf;

end

