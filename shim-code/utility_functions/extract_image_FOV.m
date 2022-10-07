function output_matrix = extract_image_FOV(coil_field, FOV)
%UNTITLED8 Slices the coil_field matrix to extract the desired FOV.

%   FOV is a row vector with the desired FOV in this order: y, x, z
%   coil_field is a 3D or 4D matrix representing either a single coil field
%   map (3D) or multiple coil field maps (4D) with the last dimension being
%   the number of coils present
%   coil_field is the biot Savart coil field map matrix that encompasses all of
%   the coils, i.e. all the coils can be reaidly visualized. But we will
%   only want a slice of this matrix base don the FOV of the scanner so we
%   want to take a slice from this matrix. This function performs that by
%   taking a symmetric slice from the center of each dimension in coil_field.


[dim_y, dim_x,dim_z, num_coils] = size(coil_field); % get dimension for each coil field map in coil_field


FOV_x = FOV(2);
FOV_y = FOV(1);
FOV_z = FOV(3);


% center_x = matrix_dimension(2);
% center_y = matrix_dimension(1);
% center_z = matrix_dimension(3); 

if mod(dim_y,2) == 1 % if odd
    center_y = ceil(dim_y / 2);
    if mod(FOV_y,2) == 1 % if odd
        slice_y = [center_y - ceil(((FOV(1) / 2) - 1)) : center_y + floor(((FOV(1) / 2)))];   
    else
        slice_y = [center_y - ((FOV(1) / 2) - 1) : center_y + ((FOV(1) / 2))];   
    end
else
    center_y = dim_y / 2;
    if mod(FOV_y,2) == 1 % if odd
        slice_y = [center_y - ceil(((FOV(1) / 2) - 1)) : center_y + floor(((FOV(1) / 2)))];   
    else
        slice_y = [center_y - ((FOV(1) / 2) - 1) : center_y + ((FOV(1) / 2))];   
    end   
end

if mod(dim_x,2) == 1 % if odd
    center_x = ceil(dim_x / 2);
    if mod(FOV_x,2) == 1 % if odd
        slice_x = [center_x - ceil(((FOV(2) / 2) - 1)) : center_x + floor(((FOV(2) / 2)))];   
    else
        slice_x = [center_x - ((FOV(2) / 2) - 1) : center_x + ((FOV(2) / 2))];   
    end
else
    center_x = dim_x / 2;
    if mod(FOV_x,2) == 1 % if odd
        slice_x = [center_x - ceil(((FOV(2) / 2) - 1)) : center_x + floor(((FOV(2) / 2)))];   
    else
        slice_x = [center_x - ((FOV(2) / 2) - 1) : center_x + ((FOV(2) / 2))];   
    end   
end

if mod(dim_z,2) == 1 % if odd
    center_z = ceil(dim_z / 2);
    if mod(FOV_z,2) == 1 % if odd
        slice_z = [center_z - ceil(((FOV(3) / 2) - 1)) : center_z + floor(((FOV(3) / 2)))];   
    else
        slice_z = [center_z - ((FOV(3) / 2) - 1) : center_z + ((FOV(3) / 2))];   
    end
else
    center_z = dim_z / 2;
    if mod(FOV_z,2) == 1 % if odd
        slice_z = [center_z - ceil(((FOV(3) / 2) - 1)) : center_z + floor(((FOV(3) / 2)))];   
    else
        slice_z = [center_z - ((FOV(3) / 2) - 1) : center_z + ((FOV(3) / 2))];   
    end   
end


output_matrix = [];

for i = 1:num_coils
    output_matrix(:,:,:,i) = coil_field(slice_y, slice_x, slice_z,i);
end


end

