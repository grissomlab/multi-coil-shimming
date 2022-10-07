function [BRAIN,MASK,OVERLAY,SKULL,COST] = vuBrainExtraction(X, varargin)
% vuBrainExtraction(...) extracts the brain, and approximate skull
% from the input image X
%
%   SYNTAX:
%       BRAIN = vuBrainExtraction(X)
%       [BRAIN,MASK,OVERLAY,SKULL,COST] = vuBrainExtraction(X, options)     
%
%   OPTIONS:
%       apply_thresholding : use threhold to brain/mask output
%       frac_thresh : smaller values give larger brain output (between 0-1)
%       vertical_grad : apply vertical gradient to frac_thresh (resulting
%       in larger brain outline on bottom (z==0), smaller on top (z>0) for positive
%       gradient (visa-versa for negative) (between -1 to 1)
%       center_coord : Center of head (for starting center of surface)
%       head_radius (in mm): Approximate radius of head (for estimating surface)
%       code_skull : Color code skull if there is skull output
%       verbose : Print the progress of the filter
%
%   OPTIONS & DEFAULTS:
%       apply_thresholding = 0
%       frac_thresh = 0.5
%       vertical_grad = 0
%       center_coord = center of mass
%       head_radius = 0
%       code_skull = 0;
%       verbose = 0
%
%   OUTPUTS:
%       BRAIN is the segmented brain image
%       MASK is the mask for the brain
%       SKULL is an approximate skull image
%       COST is the approximate image cost function
%       OVERLAY is brain surface overlaid onto image
%
%   EXAMPLE:
%       im = load('Brain4.dat');
%       seed = [165 118];
%       seg_im = vuBrainExtraction(im,seed);
%				seg_im(seg_im<100)=256;
%				seg_im(seg_im>=100)=0;
%       figure;
%       subplot(1,2,1);imshow(im,colormap(gray(256)));title('Image Before Segmenting');
%       subplot(1,2,2);imshow(conn_im,colormap(gray(256)));title('Image After Segmenting');
%
% Copyright (c) 2007 - Vanderbilt University Institute of Imaging Science


if nargin < 1
  error('MATLAB:vuBrainExtraction:NotEnoughInputs', 'Not enough input arguments.');
end

if(isstruct(X))
  %Check for meta image structure
  if(isfield(X,'Data') &&  isfield(X,'Dims') && ...
          isfield(X,'Spc') && isfield(X,'Origin'))
    disp('X is a valid MetaImage struct.')
  else
      error('MATLAB:vuBrainExtraction:InvalidStruct', 'The input image structure is not valid.');
  end
  isStruct = true;
else
  %Assume matrix inputs with (0,0) origin and unit spacing
  X = vuGenerateMetaImage(single(X),ones(1,length(size(X))),zeros(1,length(size(X))));
  disp('X is a matrix.')
  isStruct = false;
end

if (length(X.Dims) < 3 || length(X.Dims) > 3)
  error('MATLAB:vuBrainExtraction:UnknownDims', 'vuBrainExtraction can only handle images of 3 dimensions.');
end
 
% Get and parse options
p = inputParser;
p.addParamValue('apply_thresholding',0,@(x) isa(x,'double'));
p.addParamValue('frac_thresh',0.5,@(x) isa(x,'double')&&(x>=0)&&(x<=1));
p.addParamValue('vertical_grad',0,@(x) isa(x,'double')&&(abs(x)<=1));
p.addParamValue('center_coord',[-100000/X.Spc(1) 0 0],@(x) isa(x,'double'));
p.addParamValue('head_radius',-1000000,@(x) isa(x,'double')&&x>0);
p.addParamValue('code_skull',0,@(x) isa(x,'double'));
p.addParamValue('verbose',0,@(x) isa(x,'double'));
p.FunctionName='vuBrainExtraction';
p.parse(varargin{:});

% Cast meta image elements (double-check)
X.Data = single(X.Data);
X.Dims = double(X.Dims);
% In mm
X.Spc = double(X.Spc)*10;
X.Origin = double(X.Origin)*10;

% Row-major for ITK
X = vuRowMajorColumnMajorSwitch(X);

if isStruct
    if nargout == 1
        BRAIN = MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
    elseif nargout == 2
        [BRAIN,MASK]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
    elseif nargout == 3
        [BRAIN,MASK,OVERLAY]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
    elseif nargout == 4
        [BRAIN,MASK,OVERLAY,SKULL]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);        
    elseif nargout == 5
        [BRAIN,MASK,OVERLAY,SKULL,COST]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
    end
else
    if nargout == 1
        brain = MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
        BRAIN = brain.Data;
    elseif nargout == 2
        [brain,mask]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
        BRAIN = brain.Data;
        MASK = mask.Data;
    elseif nargout == 3
        [brain,mask,overlay]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
        BRAIN = brain.Data;
        MASK = mask.Data;
        OVERLAY = overlay.Data;
    elseif nargout == 4
        [brain,mask,overlay,skull]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);        
        BRAIN = brain.Data;
        MASK = mask.Data;
        OVERLAY = overlay.Data;
        SKULL = skull.Data;
    elseif nargout == 5
        [brain,mask,overlay,skull,cost]= MEXBrainExtraction(X, p.Results.apply_thresholding, p.Results.frac_thresh, p.Results.vertical_grad, p.Results.center_coord.*X.Spc, p.Results.head_radius, p.Results.code_skull, p.Results.verbose);
        BRAIN = brain.Data;
        MASK = mask.Data;
        OVERLAY = overlay.Data;
        SKULL = skull.Data;
        COST = cost.Data;
    end
end

% Copy Orientation if it exists
if (isfield(X,'Orientation'))
    BRAIN.Orientation = X.Orientation;
    if nargout > 1
        MASK.Orientation = X.Orientation;
    end
    if nargout > 2
        OVERLAY.Orientation = X.Orientation;
    end
    if nargout > 3
        SKULL.Orientation = X.Orientation;
    end
    if nargout > 4
        COST.Orientation = X.Orientation;
    end
end
% Copy parmeters if they exist
if (isfield(X,'Parms'))
    BRAIN.Parms = X.Parms;
    if nargout > 1
        MASK.Parms = X.Parms;
    end
    if nargout > 2
        OVERLAY.Parms = X.Parms;
    end
    if nargout > 3
        SKULL.Parms = X.Parms;
    end
    if nargout > 4
        COST.Parms = X.Parms;
    end
end

% Column-major for Matlab
BRAIN = vuRowMajorColumnMajorSwitch(BRAIN);

if(isStruct)
    % In cm
    BRAIN.Spc = double(BRAIN.Spc)/10;
    BRAIN.Origin = double(BRAIN.Origin)/10;
    if nargout > 1
        MASK = vuRowMajorColumnMajorSwitch(MASK);
        % In cm
        MASK.Spc = double(MASK.Spc)/10;
        MASK.Origin = double(MASK.Origin)/10;
    end
    if nargout > 2
        OVERLAY = vuRowMajorColumnMajorSwitch(OVERLAY);
        % In cm
        OVERLAY.Spc = double(OVERLAY.Spc)/10;
        OVERLAY.Origin = double(OVERLAY.Origin)/10;
    end
    if nargout > 3
        SKULL = vuRowMajorColumnMajorSwitch(SKULL);
        % In cm
        SKULL.Spc = double(SKULL.Spc)/10;
        SKULL.Origin = double(SKULL.Origin)/10;
    end
    if nargout > 4
        COST = vuRowMajorColumnMajorSwitch(COST);
        % In cm
        COST.Spc = double(COST.Spc)/10;
        COST.Origin = double(COST.Origin)/10;
    end
else
    if nargout > 1
        MASK = vuRowMajorColumnMajorSwitch(MASK);
    end
    if nargout > 2
        OVERLAY = vuRowMajorColumnMajorSwitch(OVERLAY);
    end
    if nargout > 3
        SKULL = vuRowMajorColumnMajorSwitch(SKULL);
    end
    if nargout > 4
        COST = vuRowMajorColumnMajorSwitch(COST);
    end
    
end