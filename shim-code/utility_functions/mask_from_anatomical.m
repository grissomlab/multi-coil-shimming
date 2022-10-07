function mask = mask_from_anatomical(anatomical_image, threshold)
%MASK_FROM_ANATOMICAL Generates a volume mask from an anatomical image 
%   Uses thresholding of the anatomical image to generate a mask for the
%   anatomical region of interest

mask = anatomical_image;
mask(logical(anatomical_image <= threshold*max(anatomical_image,[],'all'))) = 0;
mask = logical(mask);

end

