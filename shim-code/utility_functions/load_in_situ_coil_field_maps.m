function [MC_field, MC_FOV] = load_in_situ_coil_field_maps(MC_file_path,options)

    arguments 
        MC_file_path
        options.interp = 'no'  % yes for interpolating the field matrix by grid_Size. Default is no
        options.reorient = 'no'% yes for reorienting the field matrix by reorient. Default is no
   end

%{
load_in_situ_coil_field_maps reads in B0 field map from shim coil par file that the user selects and performs optional
interpolation and reorientation on field data for dimension agreement with B0 fields
from object field map for shimming.
%}

% Get the folder path where MC B0 field maps are located
%path = uigetdir(MC_file_path,'Select directory where MC B0 maps are located');

% for each file in folder, extract field and append to MC_field
[file, path] = uigetfile("*.REC");
path = strcat(path,file);
[data, info] = loadParRec(path);

MC_field = squeeze(data);
MC_field = MC_field(:,:,:,:,2,2);

MC_FOV = [];

% MC_field = [];
% for i=1:length(MC_par_files)
%     file_name = MC_par_files(i).name;
%     file_dir = MC_par_files(i).folder;
%     full_filename = strcat(file_dir,filesep,file_name);
%     [data,info] = loadParRec(full_filename);
%     data = squeeze(data);
%     MC_field(i,:,:,:) = data(:,:,:,1,1);
% end
% 
% MC_FOV = str2num(info.pardef.FOV_ap_fh_rl_mm); % FOV in AP(y), FH(z), RL(x)
% 
% disp('Input image FOV: ')
% disp(MC_FOV)
% disp('Input image grid size: ')
% disp(size(MC_field))

% Optional interpolation of the unshimmed in-situ field for array dimension
% agreement with multi-coil b0 fields
if strcmp(options.interp,'yes')
    grid_size = input('Enter a vector for a desired grid size to interpolate to: ');
    MC_field = interpolate_field_matrix(MC_field, grid_size,1);
end

% Optional reorientation of the unshimmed in-situ field for alignment with multi-coil b0 fields
if strcmp(options.reorient,'yes')
    orientation = input('Enter vector for re-orientation: ');
    MC_field = reorient_scanner_matrix(MC_field, orientation);
end


end

