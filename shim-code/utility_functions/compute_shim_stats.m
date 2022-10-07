function [unshimmed_mean, shimmed_mean, unshimmed_std, shimmed_std] = compute_shim_stats(unshimmed,shimmed,mask)
%UNTITLED4 Computes Bo offset mean and standard deviation for shimmed and
%unshimmed whole VOLUME defined by mask

%   Detailed explanation goes here

% Extract only the values defined within the mask
unshimmed_masked = unshimmed(logical(mask));
shimmed_masked = shimmed(logical(mask));

unshimmed_mean = mean(unshimmed_masked);
shimmed_mean = mean(shimmed_masked);

unshimmed_std = std(unshimmed_masked);
shimmed_std = std(shimmed_masked);

format short g
% this is the mean and std across the whole brain volume
fprintf("Mean B0 offset unshimmed: %f Hz\n",unshimmed_mean)
fprintf("Mean B0 offset SH shimmed: %f Hz\n", shimmed_mean)
fprintf("STD B0 offset unshimmed: %f Hz\n",unshimmed_std)
fprintf("STD B0 offset SH shimmed: %f Hz\n", shimmed_std)


end

