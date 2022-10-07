function [reoriented_matrix] = reorient_coil_matrix(coil_field, alignment)
%REORIENT_COIL_MATRIX Reorients coil matrices from Biot Savart software

% INPUT: 
%   coil_file: EXPORT file from BiotSavart software. 
%   Each line of the EXPORT file consists of seven tab-delimited floating point numbers: 
%   x     y     z     Bx     By     Bz     B
%   The coordinates are in meters, the components and magnitude of the vector potential are in Tesla. 
% OUTPUT:
%   reoriented_matrix: 3D matrix containing the z components of the coils
%   magnetic field in Tesla.
%   
% This function is similar to reorient_scanner_matrix.m but operates on the
% coil matrices from the BiotSavart sofwtare. This function reorients the
% the coil magnetic field matrices such that the first dimension (rows)
% corresponds to the scanners y axis, the second dimension (columns)
% corresponds to the scanners x axis, and the thrid dimension (pages)
% correpsonds to the scanners z axis.


% MRI Scanner Parameters
FOV_X = 170;  % Field of view in x axis (Left Right) in mm
FOV_Y = 170; % Field of view in y axis (Anterior Posteior) in mm
FOV_Z = 170; % Field of view in z axis (Foot Head) in mm

% Volumetric of Interest & Probe Parameters
% POS_PROB = [0 0 0];                                        % coordinates of probe in x,y,z in mm
% PROBE_DIMENSIONS = [FOV_X FOV_Y FOV_Z];                    % probe dimensions, same as scanner FOV
% x_axis = linspace(-FOV_X/2,FOV_X/2,PROBE_GRID_SIZE(1));    % Generate the probe x axis in mm.
% y_axis = linspace(-FOV_Y/2,FOV_Y/2,PROBE_GRID_SIZE(2));    % Generate the probe y axis in mm.
% z_axis = linspace(-FOV_Z/2,FOV_Z/2,PROBE_GRID_SIZE(3));    % Generate the probe z axis in mm.
% [X_MESH, Y_MESH, Z_MESH] = meshgrid(x_axis,y_axis,z_axis); % Volume of interest

% Reorient the coil magnetic field matrices such that they are aligned with the scanners axes
reoriented_matrix = [];
for i=1:size(coil_field,4)
    reoriented_matrix(:,:,:,i) = flipud(permute(coil_field(:,:,:,i),alignment)); % Units of Tesla
end

% Explanation of code immediately above: flipud(permute(reshape ...)
% Due to the way the Bz data is stored in the BiotSavart export file and
% the way that reshape works, we need to rearange the Bz matrix data such
% that its dimensions are the same as that of the scanner, i.e. we want the
% *_coil_Bz matrix to have its dimensions be [Y X Z] which is what the
% scanners dimensions are i.e. for the scanner the rows are top-bottom
% which is the y axis, the columns are left to right which is the x axis
% and the pages of the matrix are foot to head which is the z axis.
end

