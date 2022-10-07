function [ T ] = Rotation_ShimVolume(orient,ang_ap,ang_rl,ang_fh)

%%%%%%%%%  Rotation Matrices 

%%% Slice Orientation Matrix (SOM)
%%% Image/Matlab System (SEV , South , East ,View  or Row, Col, Depth) to 
%%% Angulated Patient Axis System (L'P'H', Left, Posterior, Head)

if orient == 1              %%% Axial
    
    Tsom = [ 0 1 0;
             1 0 0; 
             0 0 1];
         
elseif  orient == 3        %%%% Coronal
    
    Tsom = [ 0 1 0;
             0 0 1; 
            -1 0 0];
         
elseif  orient == 2         %%% Sagittal
    
    Tsom = [ 0 0 -1;
             0 1  0; 
            -1 0  0];
end


%%%%% Angulation Matrix (ANG)
%%%%  Angulated Patient Coordinate System ( L'P'H') to
%%%%  Non Angulated Patient Coordinate System (L,P,H)

Trl = [ 1      0            0 ;
        0 cos(ang_rl) -sin(ang_rl);
        0 sin(ang_rl)  cos(ang_rl)];
    
Tap = [ cos(ang_ap)   0   sin(ang_ap) ; 
           0          1        0     ; 
       -sin(ang_ap)   0   cos(ang_ap)];
   
Tfh = [ cos(ang_fh)   -sin(ang_fh)  0 ;
        sin(ang_fh)   cos(ang_fh)   0 ;
            0             0         1];
        
Tang = Trl * Tap * Tfh;
   
                                             
T = inv(Tsom) * Tang  ;   %%%%%% Not Clear why this is coming out to be Tang and not inv(Tang)
    