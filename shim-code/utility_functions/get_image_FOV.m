function FOV = get_image_FOV(file)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

image_struct = niftiinfo(file);

image_size = image_struct.ImageSize;
pixel_dimensions = image_struct.PixelDimensions;

spacing_between_slices = 2; % in units of mm
FOV = round(image_size .* pixel_dimensions);  % units are in mm but check the nifti files


end

