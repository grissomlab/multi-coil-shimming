function b0_hist = b0_shim_histogram(b0_field,mask,options)
    arguments
        b0_field
        mask
        options.visualize
        options.save
    end

%B0_SHIM_HISTOGRAM Calculates the histogram of volume shim from
%   Returns a histogram object of the b0 offset over a shim volume defined
%   by mask from the b0_field image

name = inputname(1);
masked_volume = b0_field(mask);
b0_hist = histogram(masked_volume);

if strcmp(options.visualize,'yes')
    %name = ['First calling variable is ''' inputname(1) '''.']; % get variable name of first argument
    figure
    histogram(b0_hist.Data)
    title(name)
    
end

if strcmp(options.save,'yes')
    save(name,'b0_hist')
end


end

