function field_map = parse_biot_txt_file(path_folder, file_names,probe_grid_size)
  arguments
        path_folder % file path for field maps folder
        file_names  % cell containing file names within path_folder
        probe_grid_size %
    end


%{

parse_biot_txt_file.m reads each biot savart .txt files in file_names_struct and returns 
the concatenated Bz coil fields as matrix

This function takes in a path argument to a directory containing the 
coil simulated Bz fields (stored as txt files) and concatenates them 
and exports them in coil_field_output as a matrix in units of Hz. Each
line of the EXPORT file consists of seven tab-delimited floating point
numbers: x     y     z     Bx     By     Bz     B
The coordinates are in meters, the components and magnitude of the vector potential are in
Tesla.

%}

% Read each text file in path and extract the coil field map
coil_fields = [];
coil_num = 1;
column = 5; % this is the column we read from in the BiotSavart exported results. See comment below
%{
The value for the column variable above depends on the orientation of the coils
in the BiotSavart software. We only care about the component of a coil's
magnetic that is in the same direction as z in a real scanner. That
direction needs to correspond to the column you read from in the Biot
Savart .txt files. So, depending on how the coils are oriented in
BiotSavart you will need to adjust this value.
%}
disp(['The column read from is ',num2str(column), '. Be sure to verify proper coil orientation'])
for i=1:length(file_names)
    [~, ~, ext] = fileparts(file_names{i});
    if(ext == ".txt") % Bz for each coil is stored in a txt file
        txt_file_path = fullfile(path_folder,file_names{i});
        coil_B0_field = load(txt_file_path,'-ascii');
        %field = reorient_coil_matrix(field,probe_grid_size,orientation, column);
        coil_fields(:,:,:,coil_num) = reshape(coil_B0_field(:,column),probe_grid_size); % 4th dimension represents each coil
        coil_num = coil_num + 1;
    end
end

field_map = coil_fields;

end