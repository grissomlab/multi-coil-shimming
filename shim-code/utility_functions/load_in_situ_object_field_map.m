function [b0, anatomical, FOV, full_file_path, info] = load_in_situ_object_field_map(file_directory,options)

    arguments 
        file_directory         % directory location for in situ unshimmed b0 fields
        options.interp = 'no'  % yes for interpolating the field matrix. Default is no
        options.reorient = 'no'% yes for reorienting the field matrix by reorient. Default is no
    end

%{
load_in_situ_object_field_map reads in the in situ object B0 field map in a par file that the user selects and performs optional
interpolation and reorientation on field data for dimension agreement with B0 fields
from multi-coil shim array for shimming.
%}


[file, path] = uigetfile('*.PAR','Select Par file',file_directory);
filename = strcat(path,file);
[data,info] = loadParRec(filename);
data = squeeze(data);
anatomical = data(:,:,:,1,1);
b0 = data(:,:,:,2,2);

FOV = str2num(info.pardef.FOV_ap_fh_rl_mm); % FOV in AP(y), FH(z), RL(x)

disp('Input image FOV: ')
disp(FOV)
disp('Input image grid size: ')
disp(size(anatomical))

% Optional interpolation of the unshimmed in-situ field for array dimension
% agreement with multi-coil b0 fields
if strcmp(options.interp,'yes')
    grid_size = input('Enter a vector for a desired grid size to interpolate to: ');
    b0 = interpolate_field_matrix(b0, grid_size,1);
    anatomical = interpolate_field_matrix(anatomical, grid_size,1);
end

% Optional reorientation of the unshimmed in-situ field for alignment with multi-coil b0 fields
if strcmp(options.reorient,'yes')
    orientation = input('Enter vector for re-orientation: ');
    b0 = reorient_scanner_matrix(b0, orientation);
    anatomical = reorient_scanner_matrix(anatomical, orientation);
end

full_file_path = filename;

end

