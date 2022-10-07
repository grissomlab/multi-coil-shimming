function img = vuGenerateMetaImage(data, spc, origin)
% vuGENERATEMETAIMAGE Generate a meta image structure
%   SYNTAX:
%       META_IMG = vuGenerateMetaImage(DATA, SPC, ORIGIN) generates the
%       meta image structure, META_IMG.  DATA is an MxN or MxNxP matrix of
%       the image data for 2D or 3D images.  SPC is a 1xRANK(DATA) vector
%       describing the voxel spacing of the image data.  ORIGIN is a
%       1xRANK(DATA) vector describing the the location of the first
%       element in DATA in physical space coordinates of the imaging
%       device.
%   
%   DEFAULTS:
%       SPC = [1 1] or [1 1 1]
%       ORIGIN = [0 0] or [0 0 0]
%
%   OUTPUTS:
%       META_IMG is the meta image structure generated from the inputs, and
%       has the following format:
%           META_IMG
%              |->DATA
%              |->DIMS
%              |->SPC
%              |->ORIGIN
%
%   EXAMPLE:
%       im = imread('cameraman.tif');
%       %Generate a 2D meta image with 1 isotropic voxel spacing
%       %and an origin at [0 0]
%       meta_im = vuGenerateMetaImage(im,[1 1],[0 0]);
%
% Copyright (c) 2007 - Vanderbilt University Institute of Imaging Science

dims = size(data);
dims(1:2) = fliplr(dims(1:2));
if(length(dims)<2)
    error('The input image must be at least 2D')
end
if nargin < 1
  error('MATLAB:vuGenerateMetaImage:NotEnoughInputs', 'Not enough input arguments.');
end
if nargin < 2
  spc = ones(1,min([length(dims) 3]));
end
if nargin < 3
    origin = zeros(1,min([length(dims)  3]));
end
if nargin > 3
    warning('MATLAB:vuGenerateMetaImage:TooManyInputs', 'Too many arguments.');
end
if(length(dims)==2 || length(dims) == 3)
    if(length(dims) ~= length(spc))
      error('The size of the spacing vector does not match the number of dimensions of the data matrix');
    end
    if(length(dims) ~= length(origin))
      error('The size of the origin vector does not match the number of dimensions of the data matrix');
    end
end


img = struct('Data',single(data),'Dims',double(dims),'Spc',double(spc),'Origin',double(origin));

