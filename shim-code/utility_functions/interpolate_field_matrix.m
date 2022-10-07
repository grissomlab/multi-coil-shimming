function interpolated_matrix = interpolate_field_matrix(raw_field_matrix, FOV, slice_thickness)
%INTERPOLATE_FIELD_MATRIX Interpolates raw_field_matrix to improve
%resolution
%   Detailed explanation goes here

% MRI Scan Parameters
% FOV_X = 160;  % Field of view in x axis (Left Right) in mm
% FOV_Y = 160; % Field of view in y axis (Anterior Posteior) in mm
% FOV_Z = 160; % Field of view in z axis (Foot Head) in mm

matrix_size = size(raw_field_matrix);
resolution = floor(FOV / slice_thickness); % pixel size in mm


% Slice thickness = F0V / number of slices -> FOV / FOV = 1 mm/slice
[X_MESH_INTERP,Y_MESH_INTERP,Z_MESH_INTERP] = meshgrid(linspace(1,matrix_size(2),resolution(2)),linspace(1,matrix_size(1),resolution(1)),linspace(1,matrix_size(3),resolution(3)));

interpolated_matrix = zeros([resolution , size(raw_field_matrix,4)]);

for i=1:size(raw_field_matrix,4) % for each coil matrix in raw_field_matrix
    interpolated_matrix(:,:,:,i) = interp3(raw_field_matrix(:,:,:,i),X_MESH_INTERP,Y_MESH_INTERP,Z_MESH_INTERP);
end



end

