function [probe_grid_size, probe_FOV] = parse_biot_file(path_folder, file_names)

    arguments
        path_folder % file path for field maps folder
        file_names  % cell containing file names within path_folder
    end

%PARSE_BIOT_FILE Parses .biot file to extract probe grid size and the probe
%FOV
%   Reads .biot file to find the dimensions of the probe in x y z and probe
%   FOV

% Get the .biot file path in the path_folder
biot_file_name = '';
for j = 1:length(file_names)
    [~, ~, ext] = fileparts(file_names{j});
    if (ext == ".biot")
        biot_file_name = file_names{j};
    end
end

% read .biot file 
biot_file_path = fullfile(path_folder,biot_file_name);
biot_file = fileread(biot_file_path);

% extract probe grid size
probe_grid_size = regexp(biot_file, 'grid \d+ \d+ \d+','match');
probe_grid_size = regexp(probe_grid_size{1}, ' ','split');
x = str2num(probe_grid_size{2});
y = str2num(probe_grid_size{3});
z = str2num(probe_grid_size{4});
probe_grid_size = [x y z];

% extract probe FOV 
sizeX = string(regexp(biot_file, 'sizeX \d*(mm)?', 'match'));
sizeX = str2double(regexp(sizeX,'\d*','match'));
sizeY = string(regexp(biot_file, 'sizeY \d*(mm)?', 'match'));
sizeY = str2double(regexp(sizeY,'\d*','match'));
sizeZ = string(regexp(biot_file, 'sizeZ \d*(mm)?', 'match'));
sizeZ = str2double(regexp(sizeZ,'\d*','match'));
probe_FOV = [sizeX, sizeY, sizeZ]; % Units need to be in mm

end

