function  visualize_shimming(unshimmed,shimmed_SH,shimmed_MC, shimmed_combined, mask,slice,dim)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% The colorbar configuration is done first for the whole volume so all
% slices have same colorbar
% Configuring same colorbar betweeen plots
bottom = min(min(unshimmed(logical(mask)),[],'all'), min(shimmed_SH(logical(mask)),[],'all'));
bottom = min(bottom,min(shimmed_MC(logical(mask)),[],'all'));
bottom = min(bottom, min(shimmed_combined(logical(mask)),[],'all'));

top = max(max(unshimmed(logical(mask)),[],'all'), max(shimmed_SH(logical(mask)),[],'all'));
top = max(top, max(shimmed_MC(logical(mask)),[],'all'));
top = max(top, max(shimmed_combined(logical(mask)),[],'all'));

switch dim
    case 1
        unshimmed = squeeze(unshimmed(slice,:,:));
        shimmed_SH = squeeze(shimmed_SH(slice,:,:));
        shimmed_MC = squeeze(shimmed_MC(slice,:,:));
        shimmed_combined = squeeze(shimmed_combined(slice,:,:));
        mask = squeeze(mask(slice,:,:));
    case 2
        unshimmed = squeeze(unshimmed(:,slice,:));
        shimmed_SH = squeeze(shimmed_SH(:,slice,:));
        shimmed_MC = squeeze(shimmed_MC(:,slice,:));
        shimmed_combined = squeeze(shimmed_combined(:,slice,:));
        mask = squeeze(mask(:,slice,:));
    case 3
        unshimmed = unshimmed(:,:,slice);
        shimmed_SH = shimmed_SH(:,:,slice);
        shimmed_MC = squeeze(shimmed_MC(:,:,slice));
        shimmed_combined = squeeze(shimmed_combined(:,:,slice));
        mask = mask(:,:,slice);
end
        

% Compute B0 offset statistics for the slice of interest
[unshimmed_mean, shimmed_mean, unshimmed_std, shimmed_std] = compute_shim_stats(unshimmed,shimmed_SH,mask);
[~, shimmed_mean_MC, ~, shimmed_std_MC] = compute_shim_stats(unshimmed,shimmed_MC,mask);
[~, combined_mean, ~, combined_std] = compute_shim_stats(unshimmed, shimmed_combined, mask);



% Values to plot
unshimmed_masked = unshimmed .* mask;
shimmed_masked = shimmed_SH .* mask;
shimmed_MC_masked = shimmed_MC .* mask;
shimmed_combined_masked = shimmed_combined .* mask;

% Set 0s to NaN
unshimmed_masked(unshimmed_masked == 0) = NaN;
shimmed_masked(shimmed_masked == 0) = NaN;
shimmed_MC_masked(shimmed_MC_masked == 0) = NaN;
shimmed_combined_masked(shimmed_combined_masked == 0) = NaN;

figure
colormap parula
subplot(2,2,1)
imagesc(unshimmed_masked)
shading interp;
caxis manual 
caxis([bottom top]);
colorbar
title(['Unshimmed: Mean = ', num2str(unshimmed_mean), ' Hz, STD = ', num2str(unshimmed_std)])
subplot(2,2,2)
imagesc(shimmed_masked)
shading interp;
caxis manual 
caxis([bottom top]);
title(['SH Shimmed: Mean = ', num2str(shimmed_mean), ' Hz , STD = ',  num2str(shimmed_std)])
colorbar
subplot(2,2,3)
imagesc(shimmed_MC_masked)
shading interp;
caxis manual 
caxis([bottom top]);
title(['MC Shimmed : Mean = ', num2str(shimmed_mean_MC), ' Hz , STD = ',  num2str(shimmed_std_MC)])
colorbar
subplot(2,2,4)
imagesc(shimmed_combined_masked)
shading interp;
caxis manual 
caxis([bottom top]);
title(['Combined Shimmed : Mean = ', num2str(combined_mean), ' Hz , STD = ',  num2str(combined_std)])
colorbar

end

