%% 
% This script performs the B0 shimming of the NHP B0 field maps using SIMULATED BIOT SAVART MC fields!

% The workflow for performing shimming on a scanner is as follows

% 1. Either obtain coil field maps from simulation (BiotSavart or other) OR
% perform and record B0 mapping scan for each in vivo coil individually with 1 Amp current in scanner (this option will take a long time but can be reused). 
% 2. Take B0 mapping scan of our object being imaged.
% 3 (optional). If using simulated coil field maps, you need to align, reorient, and
%   interpolate the matrices such that the field maps have the same grid size and
%   FOV as the image being scanned.
% 4. Generate a masked volume to shim over
% 5. Perform shim


%% Important file paths
base_directory_path = '/Users/antonioglenn/Desktop/multi-coil-shimming/'; % replace this with the directory where the multi-coil-shimming folder is located

addpath(strcat(base_directory_path,'shim-code'))                    % Main directory 
addpath(strcat(base_directory_path,'shim-code/utility_functions')) % My utility functions 
addpath(strcat(base_directory_path,'Martinos_Shim/supporting_functions/helper_functions')) % Martinos shim functions
addpath(strcat(base_directory_path,'Martinos_Shim/supporting_functions')) % Martinos shim functions
addpath(strcat(base_directory_path,'load_par_rec')) % For loading the nifti b0 files with proper scaling
addpath(strcat(base_directory_path,'shim-code/utility_functions/vuThreePaneViewer')) % vuThreePaneViewer utilities



%% 1. Load coil B0 field maps; (3.) interpolate or reorient if needed
simulated_coil_maps_path = "/Users/antonioglenn/Desktop/multi-coil-shimming/simulated-coil-B0-fields"; % replace with directory where simulated Biot Savart field maps are
[MC_field, MC_FOV] = load_coil_field_maps(simulated_coil_maps_path, 'interp','yes', 'reorient','no'); % Units of Hz;
MC_field_net = sum(MC_field,4); % superposition (net) B0 field from all coils in MC_field
vuThreePaneViewer(MC_field_net)

%% 2. Load unshimmed B0 field maps and anatomical images; interpolate or reorient if needed
in_vivo_field_maps_path = '/Users/antonioglenn/Desktop/multi-coil-shimming/NHP-B0-field-maps/'; % replace with directory where unshimmed field maps are located
[b0, anatomical, FOV, file_name, info] = read_in_Par(in_vivo_field_maps_path,'interp','no', 'reorient','no');  % read in b0 field map (Hz) and FOV in mm(x y z from scanners axes)
%anatomical = read_in_nifti;   % loads brain mask and anatomical image from nifti files
vuThreePaneViewer(anatomical)

%% 4. Create brain mask using anatomical image
[masked_anatomical, mask] = generate_mask(anatomical, file_name,'anatomical'); % loads binary mask and the mask overlaid on the anatomical image


%% (3) Align coil field maps to anatomical image
pad = (size(MC_field,1,2,3) - size(anatomical)) /2; % padding for b0 and anatomical images

anatomical_alignment = padarray(anatomical, pad,0,'both'); % Anatomical image padded for visualizing the required shift
vuThreePaneViewer(30*sum(MC_field,4) + anatomical_alignment)      % Use this to measure required shift values

% Pad the mask and unshimmed b0 such that they have same size as coil field
mask_padded = padarray(mask,pad,0,'both');


%% Shift unshimmed b0 and mask 

shift_values = [- 0 0]; % Values to shift b0 & mask array in y, x, and z. Modify these based on coil alignment above. 
b0_unshimmed_shifted = circshift(b0_unshimmed .* mask_padded, shift_values); % This variable is what gets fed into the b0 unshimmed shim algorithm
mask_shifted = circshift(mask_padded, shift_values);                 % This is the mask for the shim algorithm

vuThreePaneViewer(b0_unshimmed_shifted + sum(MC_field,4))     % Visualize shifted b0 and coils

%% 5. Perform Shim Shim Calculations Using Martinos Shim functions
% Only SH shimming
SH_field = define_SH_shims(coil_FOV(1), coil_FOV(2), coil_FOV(3), size(b0));

% Max Current Bounds
max_current = 5;
SH_lb = [1000 max_current max_current max_current max_current max_current max_current max_current max_current];
SH_total_current = 2000;
[SH_shimmed, SH_amps, SH_std_unshimmed, SH_std_shimmed] = perform_shim_V1(b0_unshimmed_shifted, mask_shifted , SH_field, SH_lb, SH_total_current);


%% Multi coil shimming (generic)

MC_max_current = 5 * ones(1,size(MC_field,4));
MC_total_current = sum(MC_max_current) + 50;

% [MC_shimmed, MC_amps, MC_std_unshimmed, MC_std_shimmed] = perform_shim_V1(b0_interp_unshimmed, NHP_brain_mask, coil_field_maps, MC_max_current, MC_total_current);

[MC_shimmed, MC_amps, MC_std_unshimmed, MC_std_shimmed] = perform_shim_V1(b0_unshimmed_shifted, mask_shifted, MC_field, MC_max_current, MC_total_current);

%compute_shim_stats(b0_interp_unshimmed, MC_shimmed, NHP_brain_mask)
%visualize_shimming(b0_interp_unshimmed, MC_shimmed, NHP_brain_mask,41,2)


%% SH shimming and MC Shimming
% Concatenate SH shims and MC shims into single matrix so shim algorithm
% can optimize both sets of currents simultaneously

SH_and_MC_fields = cat(4,SH_field, MC_field);
SH_and_MC_max_current = [SH_lb MC_max_current];
SH_and_MC_total_current = sum(SH_and_MC_max_current) + 100;

[Combined_shimmed, Combined_amps, Combined_std_unshimmed, Combined_std_shimmed] = perform_shim_V1(b0_unshimmed_shifted, mask_shifted, SH_and_MC_fields, SH_and_MC_max_current, SH_and_MC_total_current);

%% Visualization of shim performance

visualize_shimming(b0_unshimmed,SH_shimmed, MC_shimmed, Combined_shimmed, mask_shifted,85,2)

                                                                         
%% Unconstrained shim

[MC_shimmed, MC_amps, MC_std_unshimmed, MC_std_shimmed] = perform_shim_pinv(b0_reoriented, NHP_brain_mask, coil_field_FOV, MC_max_current);

visualize_shimming(b0_reoriented,SH_shimmed, MC_shimmed, Combined_shimmed, NHP_brain_mask,35,2)

