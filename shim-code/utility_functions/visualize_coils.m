%function coil_points = visualize_coils(coil_struct)
%visualize_coils Creates 3D coil objects for visualization in matlab
%   Visualizing coils from Biot Savart software in matlab
%   Input Args:
%        coil_struct - struct array
%           for each struct in coil_struct the fields are
%           fields:
%               coil_radius - radius of coil in mm
%               coil_turns - number of turns in coil
%               coil_center - array for coil center coordinates (x,y,z) in mm
%               angle - eulerPhi, eulerTheta, eulerPSi angles to describe coil orientation
    SHIFT_X = 80;
    SHIFT_Y = 80;
    SHIFT_Z = 80;
    
    SHIFT_COILS = [40 35 90];
    [~, NUMBER_COILS] = size(coil_struct);
    coil_turns = 10;
    
    % MRI Scanner Parameters
    FOV_X = 70; % Field of view in x axis (Left Right) in mm
    FOV_Y = 160; % Field of view in y axis (Anterior Posteior) in mm
    FOV_Z = 160; % Field of view in z axis (Foot Head) in mm
    
    % FOV and Probe 3D volume
    PROBE_X_RECT = [-FOV_X/2 -FOV_X/2;-FOV_X/2 -FOV_X/2; FOV_X/2 FOV_X/2; FOV_X/2  FOV_X/2; -FOV_X/2 -FOV_X/2] + SHIFT_X/2;
    PROBE_Y_RECT = [-FOV_Y/2  FOV_Y/2;-FOV_Y/2 FOV_Y/2 ;-FOV_Y/2 FOV_Y/2;-FOV_Y/2  FOV_Y/2; -FOV_Y/2 FOV_Y/2] + SHIFT_Y;
    PROBE_Z_RECT = [-FOV_Z/2 -FOV_Z/2; FOV_Z/2 FOV_Z/2 ; FOV_Z/2 FOV_Z/2;-FOV_Z/2 -FOV_Z/2; -FOV_Z/2 -FOV_Z/2] + SHIFT_Z;
    PROBE_X_LINE = [-FOV_X/2  FOV_X/2 -FOV_X/2  FOV_X/2; -FOV_X/2 FOV_X/2 -FOV_X/2  FOV_X/2] + SHIFT_X/2;
    PROBE_Y_LINE = [-FOV_Y/2 -FOV_Y/2 -FOV_Y/2 -FOV_Y/2;  FOV_Y/2 FOV_Y/2  FOV_Y/2  FOV_Y/2] + SHIFT_Y;
    PROBE_Z_LINE = [ FOV_Z/2  FOV_Z/2 -FOV_Z/2 -FOV_Z/2;  FOV_Z/2 FOV_Z/2 -FOV_Z/2 -FOV_Z/2;] + SHIFT_Z;
    
    % Full Circle
    numberOfPoints = (abs(coil_turns)*30)+1;            % Total number of points in loop
    phi_w = linspace(0,coil_turns*2*pi,numberOfPoints); % Equally spaced angles between 0 and 2pi to define a circle
    
    % Discretize each coil as segments; coilSegmentPoints defines
    % coordinates (vectors) for each point (x,y,z) in the coil
    coilSegmentPoints = zeros(numberOfPoints,3,NUMBER_COILS);   % coilSegmentPoints matrix describes vector for each coil point; the vectors here
    % coilSegmentPoints matrix describes vector for each coil point; the vectors here
    % describe a circle with a center of x = 0, y = 0, z = 1 and radius = COIL_RADIUS 
    for coil_num = 1 : NUMBER_COILS                              % Create the vectors defining each coil point             
        rad = coil_struct(1).coil_radius;
        coilSegmentPoints(:,:,coil_num) = [rad.*cos(phi_w') rad.*sin(phi_w') ones(numberOfPoints,1)]; % x,y, and z component of each coil segment vector
    end    
    
    % TRANSFORM COIL GEOMETRY TO SCANNER GEOMETRY  
    % Transform Coil Geometry to Scanner Geometry so that Coil Field in 
    % the 'Z' direction (W) may be selected directly after BiotSavarts.
    coilSegmentPointsRotated = [];
    for coil_num = 1 : NUMBER_COILS    
        ANG_X = coil_struct(coil_num).angle(1); % rotation angle in degrees about x axis 
        ANG_Y = coil_struct(coil_num).angle(2); % rotation angle in degrees about y axis
        ANG_Z = coil_struct(coil_num).angle(3); % rotation angle in degrees about z axis

        xAxisRotationMatrix = [1 0 0; 0 cosd(ANG_X) -sind(ANG_X); 0 sind(ANG_X) cosd(ANG_X)]; % Matrix operation for rotation about x axis
        yAxisRotationMatrix = [cosd(ANG_Y) 0 sind(ANG_Y); 0 1 0; -sind(ANG_Y) 0 cosd(ANG_Y)]; % Matrix operation for rotation about y axis
        zAxisRotationMatrix = [cosd(ANG_Z) -sind(ANG_Z) 0; sind(ANG_Z) cosd(ANG_Z) 0; 0 0 1]; % Matrix operation for rotation about z axis

        % fullRotationMatrix defines a 3D rotation operation to rotate( clockwise i.e. right hand )coil geometry by the rotation angles defined for each axis
        fullRotationMatrix =  zAxisRotationMatrix * yAxisRotationMatrix * xAxisRotationMatrix;% Full 3D rotation operation 
        
        %coilSegmentPointsRotated(:,:,coil_num) =  fullRotationMatrix * coilSegmentPoints(:,:,coil_num)'; % Apply the rotation matrix operation to all points that define the coil segments
        rotated = (fullRotationMatrix * coilSegmentPoints(:,:,coil_num)')';
%         coilSegmentPointsRotated(:,:,coil_num) = coilSegmentPointsRotated(:,:,coil_num);
%         coilSegmentPointsRotated(:,:,coil_num) = coilSegmentPointsRotated(:,:,coil_num) + repmat(coil_struct(coil_num).coil_center,[numberOfPoints,1]); % Shift each point in coilSegmentPointsRotated matrix by
        coilSegmentPointsRotated(:,:,coil_num) = rotated + repmat((coil_struct(coil_num).coil_center)+SHIFT_COILS,[numberOfPoints,1]);                                                                                  % the values defined by the coil center
    end
   
%% Plotting

    AXES_LIMITS = 190;
    figure; 
    grid on;
    for i=1:NUMBER_COILS
        plot3(PROBE_Z_RECT,PROBE_X_RECT,PROBE_Y_RECT,'g')
        plot3(PROBE_Z_LINE,PROBE_X_LINE,PROBE_Y_LINE,'g')
        plot3(coilSegmentPointsRotated(:,3,i),coilSegmentPointsRotated(:,2,i),coilSegmentPointsRotated(:,1,i),'r','linewidth',4);
        hold on
    end
    grid on;
    t = permute(flipud(anatomical_interpolated),[2,3,1]);
    slice(t,[],40,72)
    xlim([-50 AXES_LIMITS]);
    ylim([-50 AXES_LIMITS]);
    zlim([-50 AXES_LIMITS]);
    xlabel('Magnet Z mm');
    ylabel('Magnet X mm ');
    zlabel('Magnet Y mm '); 
%     set(gca, 'YDir','reverse')
%     set(gca, 'XDir','reverse')
    title(' Coils in the Magnet Coordinate System'); 



%end

