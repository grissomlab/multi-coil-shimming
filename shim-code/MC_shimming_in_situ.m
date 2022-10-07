%% Multi Coil Shimming in Situ
% This script performs the B0 shimming in the MRI scanner using
% experimentally obtained B0 fields from an in situ MC shim array

% The workflow for performing shimming on in situ within a scanner is as follows

% 1. Obtain B0 field map for each individual coil within array 
% 2. Take B0 mapping scan of our object being imaged
% 3. Generate a masked volume to shim over
% 4. Perform shim


%% Important file paths for utility functions
base_directory_path = '/Users/antonioglenn/Desktop/multi-coil-shimming/'; % replace this with the directory where the multi-coil-shimming folder is located

addpath(strcat(base_directory_path,'shim-code'))                    % Main directory 
addpath(strcat(base_directory_path,'shim-code/utility_functions')) % My utility functions 
addpath(strcat(base_directory_path,'Martinos_Shim/supporting_functions/helper_functions')) % Martinos shim functions
addpath(strcat(base_directory_path,'Martinos_Shim/supporting_functions')) % Martinos shim functions
addpath(strcat(base_directory_path,'load_par_rec')) % For loading the nifti b0 files with proper scaling
addpath(strcat(base_directory_path,'shim-code/utility_functions/vuThreePaneViewer')) % vuThreePaneViewer utilities


%% 1. Obtain in situ B0 map for each coil in shim arry
reference_current = 1; % 1 Amps. Reference current used to generate B0 field maps.
MC_file_path = '../in-situ-experiments/26-Aug-2022/CoilFields/'; % path to b0 par files on MRI scanner host machine
[MC_field, MC_FOV] = load_in_situ_coil_field_maps(MC_file_path, 'interp','no', 'reorient','no'); % Units of Hz;
                      % MC_field is the array to hold each b0 field from each coil
                      % MC_b0_field dimensions: [a,b,c,n] where (a,b,c)
                      % represents imaging volume and n represents number
                      % of coils in shim array
% ~~~ pseudocode ~~~
% for each file in MC_b0_file_path:
%   load the file using load_par_rec
%   extract the b0 field
%   add the b0 field to MC_b0_field
%   

%% 2. Obtain in situ B0 map for object to be shimmed
in_situ_field_maps_path = '/Users/antonioglenn/Desktop/multi-coil-shimming/in-situ-experiments/26-Aug-2022/ObjectField'; % replace with directory where unshimmed field maps are located
[b0, anatomical, FOV, file_name, info]= load_in_situ_object_field_map(in_situ_field_maps_path,'interp','no', 'reorient','no'); % path to b0 field of the object



%% 3. Masking of Volume of interest
mask_path = "/Users/antonioglenn/Desktop/multi-coil-shimming/in-situ-experiments/26-Aug-2022/";
[mask, mask_overlay] = generate_mask(anatomical, mask_path, 'anatomical'); % generate binary mask and the mask overlaid on the anatomical image
unshimmed_b0_field_masked = b0 .* mask;
% figure out how to call fsl from matlab AND how to install fsl brain
% extraction on the MRI machine

%% 4. Perform shim
MC_current_bounds = 5 * ones(1,size(MC_field,4)); % current limits for MC shim array.
MC_total_current = sum(MC_current_bounds) + 50;

[shimmed_b0_field, MC_amps, std_unshimmed, std_shimmed] = perform_shim_V1(unshimmed_b0_field_masked, mask , MC_field, MC_current_bounds, MC_total_current);


