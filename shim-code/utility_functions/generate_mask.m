function [mask mask_overlay] = generate_mask(anatomical_image, path_to_save, flag)
%UNTITLED2 Generates a masks for an image
%   Allows a mask to be generated depending on the input. Uses FSL to
%   generate the brain mask if selected.

[filepath, name, ext] = fileparts(path_to_save);

cd(filepath)

if strcmp(flag,"brain") % brain mask
    anatomical_interp_name = 'anatomical_interp.nii';
    anatomical_interp_filepath = [filepath '\' anatomical_interp_name];
    niftiwrite(anatomical_image,anatomical_interp_filepath) % save interpolated anatomical image as nii

    % At this point we should go to FSL and create the brain mask, naming it
    % mask

    disp('Go to FSL and create the brain mask from the anatomical_interp.nii file')
    input('Hit enter when dones creating brain mask through FSL')

    delete(anatomical_interp_filepath) % Delete the anatomical file we passed to FSL when done

    mask_path = [filepath '\mask_mask.nii.gz'];
    mask_overlay_path = [filepath '\mask_overlay.nii.gz'];

    mask = double(niftiread(mask_path));
    mask_overlay = double(niftiread(mask_overlay_path));
    
elseif strcmp(flag,'other') % arbitrary mask
    
    mask = ones(size(anatomical_image));
    mask_overlay = mask;

elseif strcmp(flag,'anatomical') % generate mask using anatomical magnitude image
    
    threshold = 1e4;
    mask = anatomical_image .* (anatomical_image > threshold);
    mask_overlay = (anatomical_image > threshold);
    
end

    

% trying to run fsl from matlab
%system(['wsl /usr/local/fsl/bin/bet ', path, ' mask ', '-o ', '-f 7'])

%delete([filepath '\*.gz']) % Delete the mask files FSL creates when we dont need them


end

