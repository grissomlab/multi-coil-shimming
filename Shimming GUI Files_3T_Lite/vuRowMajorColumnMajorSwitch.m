function output = vuRowMajorColumnMajorSwitch(input)
% vuRowMajorColumnMajorSwitch exchanges the rows and columns in the input, in order to
% adhere to row major or column major storage.
% Currently, handles input matrices, meta_image structure, and
% transformation structures.
%
%   SYNTAX:
%       output = vuRowMajorColumnMajorSwitch(input);
%
%   OUTPUTS:
%       output : The new matrix/structure with rows switched with columns;
%
%   EXAMPLE:
%       X = [ 1 2; 3 4];
%       X
%       Y = vuRowMajorColumnMajorSwitch(X);
%       Y
%
% Copyright (c) 2007 - Vanderbilt University Institute of Imaging Science



% Check for structure
if (isstruct(input))
    % Check for meta image data
    if(isfield(input,'Data'))
        if (ndims(input.Data) >= 2)
            input.Data = permute(input.Data,[2 1 3 4 5 6]);
        else
            error('MATLAB:vuRowColumnSwitch:NumberOfDimensions','The number of dimensions of the input matrix data is not supported.  See permute in Matlab help.');
        end
        if(isfield(input,'Orientation'))
            if (ndims(input.Orientation) == 2)
                input.Orientation = permute(input.Orientation,[2 1]);
            else
                error('MATLAB:vuRowColumnSwitch:NumberOfDimensions','The number of dimensions of the input matrix data is not supported.  See permute in Matlab help.');
            end
        end
    % Transform structure
    elseif(isfield(input,'Matrix'))
        if (ndims(input.Matrix) == 2)
            input.Matrix = permute(input.Matrix,[2 1]);
        else
            error('MATLAB:vuRowColumnSwitch:NumberOfDimensions','The number of dimensions of the input matrix data is not supported.  See permute in Matlab help.');
        end
    else
       error('MATLAB:vuRowColumnSwitch:UnknownStructure','The type of input structure is not supported.  See permute in Matlab help.');
    end 
else                 
    dims = ndims(input);
    if (dims>=2)
        input = permute(input,[2 1 3 4 5 6]);
    else
        error('MATLAB:vuRowColumnSwitch:NumberOfDimensions','The number of dimensions of the input image is not supported.  See permute in Matlab help.');
    end
end

output = input;