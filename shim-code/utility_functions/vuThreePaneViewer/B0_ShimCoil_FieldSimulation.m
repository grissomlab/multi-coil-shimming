%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to simulate fields produced by a simple coil
%%% configuration by Biot Savarts in the Prostate

%% Parameter Settings
CENTER_FREQ = 127;          % spectrometer frequency in MHz
CHI_WATER = -9.05*10^-6;    % (Vol Susc : Schenk)
FOV = 50;                   % FOV (in cm)

FOV_wraparoundpad = FOV+FOV/2;

RESOLUTION = 0.5;           % Resolution (in cm/voxel)
RESOLUTION_CURELEM = 0.5;   % Resolution (in cm/voxel)
GAMMA = 4*pi*1e-5;          % Induction constant GAMMA = mu0 = 4*pi*1e-7  Tm/A or  4*pi*1e-5 Tcm/A 
CURRENT = 1;                % Amperes

ND = FOV/RESOLUTION;        % This gives the number of voxels within the field of view given a certain resolution

%% Induction curve (In the magnet coordinate system)

WIRE_DIAM = 0.04;           % 26G wire im cm .

% prompt = ' Please enter number of coils :  ';
% NUMBER_COILS = input(prompt);

NUMBER_COILS = 1;           % number of shim coils
COIL_RADIUS = input('Please enter a coil radius in cm :  ');
COIL_TURNS = input('Please enter number of turns per coil : ');  

%COIL_TURNS = 1;


%% Define Coil Centers in cm 
% Coordinate 1 is X : up(+ve)-down(-ve)
% Coordinate 2 is Y : left(-ve)-right(+ve)
% Coordinate 3 is Z : foot(+ve)-head(-ve)

% COIL_CENTER = [-15,0,-4];
% COIL_CENTER = [0,0,0];
COIL_CENTER = [0,0,-5];
% COIL_CENTER = [-15,-5,0];
% COIL_CENTER = [-15,0,15];
% COIL_CENTER = [-15,-18,5];

%COIL_CENTER = [8,-19,-4];


%% Coil Geometry 
switch menu('Choose a coil geometry','XN_NTurnLoop')
    
    case 1  % -------------------- N Turn Circular Loops --------------------
                          
        % Arc or Full Circle
        numberOfPoints = (abs(COIL_TURNS)*10)+1;            % Total number of points in loop
        phi_w = linspace(0,COIL_TURNS*2*pi,numberOfPoints); % Equally spaced angles between 0 and 2p to define a circle
        
        % Discretize each coil as segments; coilSegmentPoints defines
        % coordinates (vectors) for each point (x,y,z) in the coil
        coilSegmentPoints = zeros(numberOfPoints,3,NUMBER_COILS);   % coilSegmentPoints matrix describes vector for each coil point; the vectors here
                                                                     % describe a circle with a center of x = 0, y = 0, z = 1 and radius = COIL_RADIUS 
        
        if COIL_TURNS >= 1              
                 pitch = WIRE_DIAM;                                  % Pitch of the turns in mm (distance between turns)
        else
                  % pitch = 0;                                       % Pitch of the turns in mm ( distance between turns)
        end
       
        % coilSegmentPoints matrix describes vector for each coil point; the vectors here
        % describe a circle with a center of x = 0, y = 0, z = 1 and radius = COIL_RADIUS 
        for coil_num = 1 : NUMBER_COILS                              % Create the vectors defining the coil             
         coilSegmentPoints(:,:,coil_num) = [ COIL_RADIUS.*cos(phi_w')  COIL_RADIUS.*sin(phi_w')  ones(numberOfPoints,1)  ]; % x,y, and z component of each coil segment vector
        end
        
end

%% TRANSFORM COIL GEOMETRY TO SCANNER GEOMETRY  
    % Transform Coil Geometry to Scanner Geometry so that Coil Field in 
    % the 'Z' direction (W) may be selected directly after BiotSavarts.

ANG_X = 0; % rotation angle in degrees about x axis 
ANG_Y = 0;  % rotation angle in degrees about y axis
ANG_Z = 0;  % rotation angle in degrees about z axis

% Transform to Unrotated Magnet coordinate system
% Needle_Mag_Transform = [ -1 0 0; 0 1 0; 0 0 1];
% L_Mag = coilSegmentPoints * Needle_Mag_Transform;

xAxisRotationMatrix = [1 0 0; 0 cosd(ANG_X) -sind(ANG_X); 0 sind(ANG_X) cosd(ANG_X)]; % Matrix operation for rotation about x axis
yAxisRotationMatrix = [cosd(ANG_Y) 0 sind(ANG_Y); 0 1 0; -sind(ANG_Y) 0 cosd(ANG_Y)]; % Matrix operation for rotation about y axis
zAxisRotationMatrix = [cosd(ANG_Z) -sind(ANG_Z) 0; sind(ANG_Z) cosd(ANG_Z) 0; 0 0 1]; % Matrix operation for rotation about z axis

% fullRotationMatrix defines a 3D rotation operation to rotate( clockwise i.e. right hand )coil geometry by the rotation angles defined for each axis
fullRotationMatrix =  zAxisRotationMatrix * yAxisRotationMatrix * xAxisRotationMatrix;% Full 3D rotation operation 
                                                                                      % recall from linear algebra we apply x rotation,
                                                                                      % then y, then z rotation.
                                                                                      % the order matters from right to left


% Mag_MagRot_Transform = [cosd(ANG_Y)*cosd(ANG_Z), -cosd(ANG_X)*sind(ANG_Z)+ sind(ANG_X)*sind(ANG_Y)*cosd(ANG_Z), sind(ANG_X)*sind(ANG_Z)+cosd(ANG_X)*sind(ANG_Y)*cosd(ANG_Z) ;...
%            cosd(ANG_Y)*sind(ANG_Z), cosd(ANG_X)*cosd(ANG_Z)+sind(ANG_X)*sind(ANG_Y)*sind(ANG_Z), -sind(ANG_X)*cosd(ANG_Z)+ cosd(ANG_X)*sind(ANG_Y)*sind(ANG_Z);...    
%                  -sind(ANG_Y)  ,                    sind(ANG_X)*cosd(ANG_Y)  ,                                 cosd(ANG_X)*cosd(ANG_Y)];

coilSegmentPointsRotated =  fullRotationMatrix * coilSegmentPoints'; % Apply the rotation matrix operation to all points that define the coil segments

coilSegmentPointsRotated = coilSegmentPointsRotated';

coilSegmentPointsRotated = coilSegmentPointsRotated + repmat(COIL_CENTER,[numberOfPoints,1]); % Shift each point in coilSegmentPointsRotated matrix by
                                                                                              % the values defined by the coil center

Nl = numel(coilSegmentPoints)/3; % Number of points of the curve


figure ; 
plot3(coilSegmentPointsRotated(:,3),coilSegmentPointsRotated(:,2),coilSegmentPointsRotated(:,1),'r','linewidth',4);
grid on;
xlim([-FOV/2 FOV/2]);ylim([-FOV/2 FOV/2]);zlim([-FOV/2 FOV/2]);
xlabel('Magnet Z cm');ylabel('Magnet Y cm ');zlabel('Magnet X cm '); 
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
title(' Coil in the Magnet Coordinate System'); 

pause

%% Numerical integration of Biot-Savart law
clear W dW
clear x_range y_range z_range Ind_X Ind_Y Ind_Z
tic 

x = linspace(-FOV/2, FOV/2, ND);
y = linspace(-FOV/2, FOV/2, ND);
z = linspace(-FOV/2, FOV/2, ND); 
[Y, X, Z] = meshgrid(y,-x,-z);     % 3D volumetric grid. We are calculating B field at each point in this grid

x_range = -ND/2:ND/2-1;
y_range = -ND/2:ND/2-1;
z_range = -ND/2:ND/2-1;

[ Ind_Y, Ind_X ,Ind_Z] = meshgrid(y_range,-x_range,z_range);  % 3D volumetric grid of indices for indexing

Ind_X = single(Ind_X); 
Ind_Y = single(Ind_Y); 
Ind_Z = single(Ind_Z);

Ind_X_vec = Ind_X(:); 
Ind_Y_vec = Ind_Y(:); 
Ind_Z_vec = Ind_Z(:);

% Induction vector components B = (U, V, W);
% U = single(zeros(ND, ND, ND));
% V = single(zeros(ND, ND, ND));
W = single(zeros(ND, ND, ND));

X = single(X);
Y = single(Y);
Z = single(Z);

% The curve is discretized in Nl points, we iterate on the Nl-1
% segments. Each segment is discretized with a "ds" length step
% to evaluate a "dB" increment of the induction "B".

Lx = [];
Ly = [];
Lz = [];
Npi = zeros(Nl-1,1);

for pCurv = 1:Nl-1
% for pCurv = 1
    % Length of the curve element
    len = norm(coilSegmentPointsRotated(pCurv,:) - coilSegmentPointsRotated(pCurv+1,:));
    % Number of points for the curve-element discretization                
    Npi(pCurv) = ceil(len/RESOLUTION_CURELEM);

    if Npi(pCurv) < 3
%      close(Wait);
%       error('Integration step is too big, Reduce RESOLUTION_CURELEM !!')
        Npi(pCurv) = ceil(len/(RESOLUTION_CURELEM/2));
    end
    
    % Curve-element discretization
    Lx = cat(2,Lx,linspace(coilSegmentPointsRotated(pCurv,1), coilSegmentPointsRotated(pCurv+1,1), Npi(pCurv)));
    Ly = cat(2,Ly,linspace(coilSegmentPointsRotated(pCurv,2), coilSegmentPointsRotated(pCurv+1,2), Npi(pCurv)));
    Lz = cat(2,Lz,linspace(coilSegmentPointsRotated(pCurv,3), coilSegmentPointsRotated(pCurv+1,3), Npi(pCurv)));

end

dLx_v = diff(Lx);
dLy_v = diff(Ly);
dLz_v = diff(Lz);
  
Npi_Total = length(Lx);
cNpi = cumsum(Npi);
Factor = -1*CURRENT*GAMMA/4/pi;
                
toc                            
for ind = 1 : length(Ind_X_vec)
    
     i = Ind_X_vec(ind) + ND/2+1;
     j = Ind_Y_vec(ind) + ND/2+1;
     k = Ind_Z_vec(ind) + ND/2+1;
         
    if i > ND || j > ND ||  k > ND
        continue
    else
%      waitbar(ind/length(Ind_X_vec), Wait)
       % Ptest is the point of the field where we calculate induction             
       %%%%% X Grid should be up-down, Y Grid should be left-right, Z Grid
       %%%%% should be Foot-Head
         pTest = [X(i,j,k) Y(i,j,k) Z(i,j,k)]; 

         % Integration
            for s = 1:Npi_Total-1
                                                     
                % Vector connecting the infinitesimal curve-element 
                % point and field point "pTest"
%                 
                Rx = Lx(s) - pTest(1);
                Ry = Ly(s) - pTest(2);
                Rz = Lz(s) - pTest(3);
                                            
                % Infinitesimal curve-element components
%                 dLx = Lx(s+1) - Lx(s);
%                 dLy = Ly(s+1) - Ly(s);
%                 dLz = Lz(s+1) - Lz(s);

                % Modules
%                dL = sqrt(dLx^2 + dLy^2 + dLz^2);
                dL = sqrt(dLx_v(s)^2 + dLy_v(s)^2 + dLz_v(s)^2);
                R = sqrt(Rx^2 + Ry^2 + Rz^2);
                                               
                % Biot-Savart
%               dU = -1*CURRENT*GAMMA/4/pi*(dLy*Rz - dLz*Ry)/R/R/R;
%               dV = -1*CURRENT*GAMMA/4/pi*(dLz*Rx - dLx*Rz)/R/R/R;
%               dW = -1*CURRENT*GAMMA/4/pi*(dLx*Ry - dLy*Rx)/R/R/R;
%                  
%                dW = Factor*(dLx*Ry - dLy*Rx)/R/R/R;
                 dW = Factor*(dLx_v(s)*Ry - dLy_v(s)*Rx)/R/R/R;
                                 
                      
                % Add increment to the main field
%                U(i,j,k) = U(i,j,k) + dU;
%                V(i,j,k) = V(i,j,k) + dV;
                W(i,j,k) = W(i,j,k) + dW;
                
            end              
    end
           
end

%close(Wait);

%%% Convert to Hz : 1T = 42.57*1e6 Hz for proton
% U = U * 42.57*1e6;  
% V = V * 42.57*1e6;  
W = W * 42.57*1e6;  

toc


   