function coefficients = shim09(firstSlice,lastSlice,dataSpace,fieldmap)
% COEFFICIENTS = SHIM09(FIRSTSLICE,LASTSLICE,DATASPACE)
% returns coefficients of field expansion by multiple linear 
% regression ( 09 terms )
% input:
%   firstSlice: number of first slice whose data used in regression
%   lastSlice: lastslice number
%   dataSpace: data spacing in image plane
%   output:coefficients of field expansion

% Created by Yansong Zhao, Yale University June 01. 2001
% This is a function of Shimming Toolbox

%%%%% Modified By Saikat Sengupta, Vanderbilt University, Dec 2005

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global roi R Theta Phi;
                              
[Np,Nr,Nsl]=size(fieldmap);

%%%%%%%%% number of data used in shimming
nSlice = size([firstSlice:lastSlice],2);
nPhase = size([1:dataSpace:Np],2);
nRead = size([1:dataSpace:Nr],2);

%%%%%%%%%%%%%%%%%%% Data used in shimming
       
  shimField = reshape(fieldmap(1:dataSpace:Np,1:dataSpace:Nr,...
        firstSlice:lastSlice),nRead*nPhase*nSlice,1);

    shimRoi = reshape(roi(1:dataSpace:Np,1:dataSpace:Nr,...
        firstSlice:lastSlice),nRead*nPhase*nSlice,1);
    
    shimR = reshape(R(1:dataSpace:Np,1:dataSpace:Nr,...
        firstSlice:lastSlice),nRead*nPhase*nSlice,1);

    shimTheta = reshape(Theta(1:dataSpace:Np,1:dataSpace:Nr,...
        firstSlice:lastSlice),nRead*nPhase*nSlice,1);

    shimPhi = reshape(Phi(1:dataSpace:Np,1:dataSpace:Nr,...
        firstSlice:lastSlice),nRead*nPhase*nSlice,1);

index = find(shimRoi == 1);

for k = 1 : size(index,1)
    X(k,:) = onepoint09(shimR(index(k)),shimTheta(index(k))...
        ,shimPhi(index(k)));
    Y(k) = shimField(index(k));
end



if isempty(index)
   coefficients = zeros(9,1);
    return
end


%%%%%%%%%%%% Constrained Fit taking 3TA shim limits ( see 3T HOS
%%%%%%%%%%%% Calibration Excel Sheet)

lb = [ -2000;
        -338;
        -3.94;  
        -363;
        -7.95;
        -3.77;
        -347;
        -7.95;
        -3.82;
        ]; %% Z0,Z1,Z2D,X,ZX,C2,Y,ZY,XY, 4.8 Amp values (Max is 5 Amps)
    
 ub = abs(lb);


 coefficients= lsqlin(X,Y',[],[],[],[],lb,ub); % this performs the actual shimming regression and fitting
 
 % X = spherical harmonics
 % Y = B0 field map that we want to shim
 % lb = lower bounds
 % ub = upper bounds

% coefficients=regress(Y',X);

% END of shim09.m
% This is a function of Shimming Toolbox
