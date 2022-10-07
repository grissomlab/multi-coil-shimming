function [coil_field_output, probe_FOV] = load_coil_field_maps(biot_file_path,options)
   arguments 
        biot_file_path
        options.interp = 'no'  % yes for interpolating the field matrix by grid_Size. Default is no
        options.reorient = 'no'% yes for reorienting the field matrix by reorient. Default is no
   end

%{

load_coil_field_maps.m reads the biot savart txt files in path, performs optional
or reorientation, and returns the Bz coil fields as a matrix. It relies on the parse_biot_txt_file.m 
file to parse the .txt files to load the Bz coil components.

This function takes in a path argument to a directory containing the 
coil simulated Bz fields (stored as txt files) and concatenates them 
and exports them in coil_field_output as a matrix in units of Hz. Each
line of the EXPORT file consists of seven tab-delimited floating point
numbers: x     y     z     Bx     By     Bz     B
The coordinates are in meters, the components and magnitude of the vector potential are in
Tesla.

%}

%% Constants
Y = 42.6e6; % Gyromagnetic ratio Hz/Tesla

%% Select path to the Biot Savart Coil text files
coil_fields_path =  uigetdir(biot_file_path);
coil_folder_struct = dir(coil_fields_path);
file_names = {coil_folder_struct(~[coil_folder_struct.isdir]).name}; % cell array of all file names in coil_fields_path


% Get probe grid size and FOV from .biot
[probe_grid_size, probe_FOV] = parse_biot_file(coil_fields_path, file_names); % Extract the Bz component of coil field from Biot Savart .txt file

% Get Bz field maps from each .txt file in coil_fields_path
coil_fields = parse_biot_txt_file(coil_fields_path,file_names,probe_grid_size);

% Optional interpolation of the multi coil field for array dimension
% agreement with unshimmed in-situ field
if strcmp(options.interp,'yes')
    disp("Old Field Size")
    disp(size(coil_fields))
    grid_size = input('Enter a vector for a desired grid size to interpolate to: ');
    coil_fields = interpolate_field_matrix(coil_fields, grid_size,1);
end

% Optional reorientation of multi coil fields for alignment with unshimmed in-situ field
if strcmp(options.reorient,'yes')
    orientation = input('Enter a vector for the orientation: ');
    coil_fields = reorient_coil_matrix(coil_fields,orientation);
end

coil_field_output = coil_fields * Y;

end

