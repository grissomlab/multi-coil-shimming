%%%%% Reading Scanner Shim Volume                                    %%%%%%

%%%% File for reading shim volume planned on the scanner and exported %%%%%
%%%% for ROI based shimming.

%%%% Written by Saikat Sengupta, VUIIS, Feb 2008                    %%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mask] = ScannerShimVol(main_Handle)

%global parms;

Np = main_Handle.parms.scan_resolution(1);      % phase encoding steps
Nf = main_Handle.parms.scan_resolution(2);      % frequency encoding steps
Ns = main_Handle.parms.max_slices;              % no of slices

if Nf > Np            % Sometimes Nf < Np cos of less than 100% encoding.
    Np = Nf;
elseif Np > Nf
    Nf = Np;
end

% if size(main_Handle.parms.tags,1) == 2*Ns    
    ap_Offset(1:Ns) = main_Handle.parms.tags(1:Ns,20);     
    rl_Offset(1:Ns) = main_Handle.parms.tags(1:Ns,22);     
    fh_Offset(1:Ns) = main_Handle.parms.tags(1:Ns,21);     
% end

 FOV_ap = main_Handle.parms.fov(1);
 FOV_rl = main_Handle.parms.fov(3);
 FOV_fh = main_Handle.parms.fov(2);

 fid = fopen('E:\Export\DynShim_ShimVol.txt','r');
  if (fid < 1)
       fid = fopen('DynShim_ShimVol.txt','r');
      if (fid < 1)
      error('Valid Directory not found, Cant write shim file'); 
      end
  end
  
SV = fscanf(fid,'%f');

SV_orient = SV(1);

SV_ap_offcenter = SV(2);
SV_rl_offcenter = SV(3);
SV_fh_offcenter = SV(4);

SV_ap_ang = SV(5) * pi/180;
SV_rl_ang = SV(6) * pi/180;
SV_fh_ang = SV(7) * pi/180;

SV_ap_length = SV(8);
SV_rl_length = SV(9);
SV_fh_length = SV(10);

fclose(fid)

mask = zeros(Np,Nf);
  
if mod(Ns,2)== 0
    ind = Ns/2;
else
    ind = (Ns+1)/2;
end


%%%%% Converting from LPH - RCD system %%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch SV_orient
    case 0                  %% Sagittal
        
        block_ori = 2 ; 
        
        [Geo_T] = Rotation_ShimVolume(block_ori,SV_ap_ang,SV_rl_ang,SV_fh_ang);
        
        SV_pix_length_fh = (Np * SV_fh_length)/FOV_fh ;
        SV_pix_length_ap = (Nf * SV_ap_length)/FOV_ap ;
        
        SV_pix_offcen_fh = (Np*(SV_fh_offcenter - fh_Offset))/FOV_fh;
        SV_pix_offcen_ap = (Nf*(SV_ap_offcenter - ap_Offset))/FOV_ap;
        
        FH_foot =  round(SV_pix_offcen_fh - SV_pix_length_fh/2);
        FH_head =  round(SV_pix_offcen_fh + SV_pix_length_fh/2);
        AP_ant =  round(SV_pix_offcen_ap - SV_pix_length_ap/2);
        AP_pos =  round(SV_pix_offcen_ap + SV_pix_length_ap/2);       
        
         [A_RCD] = Geo_T * [ 0      0         0          0 ; ...
                     AP_ant(ind)  AP_pos(ind)  AP_pos(ind)  AP_ant(ind) ;...                   
                     FH_head(ind)  FH_head(ind)  FH_foot(ind)  FH_foot(ind)   ];
        
        
         
    case 1                  %% Coronal
        
        block_ori = 3 ; 
        
        [Geo_T] = Rotation_ShimVolume(block_ori,SV_ap_ang,SV_rl_ang,SV_fh_ang);
        
        SV_pix_length_fh = (Np * SV_fh_length)/FOV_fh ;
        SV_pix_length_rl = (Np * SV_rl_length)/FOV_rl ;
        
        SV_pix_offcen_fh = (Np*(SV_fh_offcenter - fh_Offset))/FOV_fh;
        SV_pix_offcen_rl = (Np*(SV_rl_offcenter - rl_Offset))/FOV_rl;
        
        FH_foot =  round(SV_pix_offcen_fh - SV_pix_length_fh/2);
        FH_head = round(SV_pix_offcen_fh + SV_pix_length_fh/2);       
        RL_right = round(SV_pix_offcen_rl - SV_pix_length_rl/2);
        RL_left = round(SV_pix_offcen_rl + SV_pix_length_rl/2);
            
         [A_RCD] = Geo_T * [ RL_right(ind)  RL_left(ind)  RL_left(ind)  RL_right(ind); ...
                                0           0          0            0 ;...                   
                             FH_head(ind)  FH_head(ind)  FH_foot(ind)  FH_foot(ind)   ];
              
              
        
    case 2                  %% Transverse
        
        block_ori = 1 ; 
        
        [Geo_T] = Rotation_ShimVolume(block_ori,SV_ap_ang,SV_rl_ang,SV_fh_ang);
        
        SV_pix_length_ap = (Np * SV_ap_length)/FOV_ap ;
        SV_pix_length_rl = (Nf * SV_rl_length)/FOV_rl ;
            
        SV_pix_offcen_ap = (Np *(SV_ap_offcenter - ap_Offset))/FOV_ap;  
        SV_pix_offcen_rl = (Nf *(SV_rl_offcenter - rl_Offset))/FOV_rl;
             
        AP_ant =  SV_pix_offcen_ap - SV_pix_length_ap/2;
        AP_pos =  SV_pix_offcen_ap + SV_pix_length_ap/2;
        RL_right =  SV_pix_offcen_rl - SV_pix_length_rl/2;
        RL_left =  SV_pix_offcen_rl + SV_pix_length_rl/2;       
       
        
         [A_RCD] = Geo_T * [ RL_right(ind)  RL_left(ind)  RL_left(ind)  RL_right(ind); ...
                             AP_ant(ind)  AP_ant(ind)  AP_pos(ind)  AP_pos(ind) ;...                   
                                 0           0         0           0   ]; 
                  
    otherwise
end


%%%%%%%%%%%%%% Creating Mask with Row and Column Coordinates
%%%%%%%%%%%%%% %%%%%%%%%%%%%%%

  R = [ A_RCD(1,1) A_RCD(1,2) A_RCD(1,3) A_RCD(1,4)];
  C = [ A_RCD(2,1) A_RCD(2,2) A_RCD(2,3) A_RCD(2,4)];

 mask = roipoly( mask,round(C+Nf/2),round(R+Np/2));
    
 figure; imagesc(mask);axis image;colormap gray; title(' Shim ROI imported from scanner') 