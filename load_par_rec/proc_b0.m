%filename = '../XMLPARREC/Caskey_740818_23_01_13.40.29_(WIP_B0map_SENSE)';

[file, path] = uigetfile('C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\NHP_B0_maps\','Select B0 file');
filename = [file path];
[data,info] = loadParRec(filename);
data = squeeze(data);
mag = data(:,:,:,1,1);
b0 = data(:,:,:,2,2);
%save('b0.mat','b0','mag');