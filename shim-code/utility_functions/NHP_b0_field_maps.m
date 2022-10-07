%% Utility script to visualize b0 field maps and anatomical images of NHP
% Loads and displays each imaging axis of the NHP b0 field maps and
% anatomical images for troubleshooting.
clear;
close all
load('b0.mat');

% Note: 1 Tesla = 10,000 Gauss
% Units of b0 are Hz
% mag contains anatomical maps
% The b0 and mag tensor dimensions are z,y,x in that order but I want them
% to be oriented in the same way the scanners axes are.

% Axes of the 3T scanner:
% up - down = y axis
% left-right = x axis
% head-foot = z axis

% Field of view found in the info.pardef struct from loadParRec.m
% FOV_ap_fh_rl_mm: '160.000  160.000  70.000'
% AP (anterior/posterior) = 160 mm
% FT (foot/head) = 160 mm
% RL (right/left) = 70 mm

% MRI Scanner Parameters
FOV_X = 70; % Field of view in x axis (Left Right) in mm
FOV_Y = 160; % Field of view in y axis (Anterior Posteior) in mm
FOV_Z = 160; % Field of view in z axis (Foot Head) in mm
%% Reorient the matrixes b0 and mag such that they are aligned with the scanners axes
b0_reoriented = reorient_scanner_matrix(b0);
anatomical_reoriented = reorient_scanner_matrix(mag);

%% Interpolate to improve resoltion
b0_interpolated = interpolate_field_matrix(b0_reoriented);
anatomical_interpolated = interpolate_field_matrix(anatomical_reoriented);

%% View image in three panes
%vuThreePaneViewer(b0_interpolated)
[y,x,z] = size(b0_interpolated);

%% Axial plane B0 field mappings in Hz & anatomical images
for i = 1:z
    ax1 = subplot(1,2,1);
    imagesc(squeeze(b0_interpolated(:,:,i))); % step throguh scanner z axis
    title('B0 field')
    xlabel('x axis of scanner')
    ylabel('y axis of scanner')
    colorbar
    colormap(ax1,jet)
    
    ax2 = subplot(1,2,2);
    imagesc(squeeze(anatomical_interpolated(:,:,i)));
    title('Axial Plane Anatomical')
    xlabel('x axis of scanner')
    ylabel('y axis of scanner')
    colormap(ax2, gray)
    pause(.001);
end
%% Sagittal plane B0 field mappings in Hz & anatomical images
for i = 1:x
    ax1 = subplot(1,2,1);
    imagesc(squeeze(b0_interpolated(:,i,:))); % step throguh scanner x axis
    title('B0 field')
    xlabel('z axis of scanner')
    ylabel('y axis of scanner')
    colorbar
    colormap(ax1,jet)
    
    ax2 = subplot(1,2,2);
    imagesc(squeeze(anatomical_interpolated(:,i,:)));
    title('Sagittal Plane Anatomical')
    xlabel('z axis of scanner')
    ylabel('y axis of scanner')
    colormap(ax2, gray)
    pause(.001);
end
%% Coronal plane B0 field mappings in Hz & anatomical images
for i = 1:y
    ax1 = subplot(1,2,1);
    imagesc(squeeze(b0_interpolated(i,:,:))); % step throguh scanner y axis
    title('B0 field')
    xlabel('z axis of scanner')
    ylabel('x axis of scanner')
    colorbar
    colormap(ax1,jet)
    
    ax2 = subplot(1,2,2);
    imagesc(squeeze(anatomical_interpolated(i,:,:)));
    title('Coronal Plane Anatomical')
    xlabel('z axis of scanner')
    ylabel('x axis of scanner')
    colormap(ax2, gray)
    pause(.001);
end


%% plot multi slices in 3D using slice command
figure
colormap gray
t = permute(anatomical_interpolated,[2,3,1]);
slice(t,[],50,110) 
xlabel('scanner z')
ylabel('scanner x')
zlabel('scanner y')
set(gca, 'ZDir','reverse')

 


    

