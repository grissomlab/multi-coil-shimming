function visualize_coil_B0(path, slice, dim)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here


addpath C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\utility_functions % My utility functions 

coil_field_maps = load_coil_field_maps(coil_directory); % units are in Gauss

switch dim
    case 1
        coil_field_maps = squeeze(coil_field_maps(slice,:,:)); 
    case 2
        coil_field_maps = squeeze(coil_field_maps(:,slice,:));
    case 3
        coil_field_maps = coil_field_maps(:,:,slice);
end


figure
imagesc(coil_field_maps

end


