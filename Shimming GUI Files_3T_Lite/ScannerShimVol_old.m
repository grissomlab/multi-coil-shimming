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


if size(main_Handle.parms.tags,1) == 2*Ns    
    ap_Offset(1:Ns) = main_Handle.parms.tags(1:Ns,20);     
    rl_Offset(1:Ns) = main_Handle.parms.tags(1:Ns,22);     
    fh_Offset(1:Ns) = main_Handle.parms.tags(1:Ns,21);     
end

%%%% Orientation of Blocks, 1: Axial, 2 : Sagital, 3 : Coronal
block_ori = main_Handle.parms.tags(1,26);

 FOV_ap = main_Handle.parms.fov(1);
 FOV_rl = main_Handle.parms.fov(3);
 FOV_fh = main_Handle.parms.fov(2);

fid = fopen('E:\Export\DynShim_ShimVol.txt','r');
%fid = fopen('DynShim_ShimVol.txt','r');
SV = fscanf(fid,'%f');

SV_orient = SV(1);

SV_ap_offcenter = SV(2);
SV_rl_offcenter = SV(3);
SV_fh_offcenter = SV(4);

SV_ap_length = SV(8);
SV_rl_length = SV(9);
SV_fh_length = SV(10);

fclose(fid)

mask = zeros(Np,Nf);

switch SV_orient
    case 0                  %% Sagittal
        SV_pix_length_fh = (Np * SV_fh_length)/FOV_fh ;
        SV_pix_length_ap = (Np * SV_ap_length)/FOV_ap ;
        
        SV_pix_offcen_fh = (Np*(SV_fh_offcenter - fh_Offset))/FOV_fh;
        SV_pix_offcen_ap = (Np*(SV_ap_offcenter - ap_Offset))/FOV_ap;
        
        y_top = Np/2 - round(SV_pix_offcen_fh(1) + SV_pix_length_fh/2);
        y_bot = Np/2 - round(SV_pix_offcen_fh(1) - SV_pix_length_fh/2);
        x_left = Np/2 + round(SV_pix_offcen_ap(1) - SV_pix_length_ap/2);
        x_right = Np/2 + round(SV_pix_offcen_ap(1) + SV_pix_length_ap/2);
                
 
        
         
    case 1                  %% Coronal
        
        SV_pix_length_fh = (Np * SV_fh_length)/FOV_fh ;
        SV_pix_length_rl = (Np * SV_rl_length)/FOV_rl ;
        
        SV_pix_offcen_fh = (Np*(SV_fh_offcenter - fh_Offset))/FOV_fh;
        SV_pix_offcen_rl = (Np*(SV_rl_offcenter - rl_Offset))/FOV_rl;
        
        y_top = Np/2 - round(SV_pix_offcen_fh(1) + SV_pix_length_fh/2);
        y_bot = Np/2 - round(SV_pix_offcen_fh(1) - SV_pix_length_fh/2);       
        x_left = Np/2 - round(SV_pix_offcen_rl + SV_pix_length_rl/2);
        x_right = Np/2 - round(SV_pix_offcen_rl - SV_pix_length_rl/2);
        
                
    case 2                  %% Transverse
        
        SV_pix_length_ap = (Np * SV_ap_length)/FOV_ap ;
        SV_pix_length_rl = (Np * SV_rl_length)/FOV_rl ;
        
        SV_pix_offcen_ap = (Np *(SV_ap_offcenter - ap_Offset))/FOV_ap;  
        SV_pix_offcen_rl = (Np *(SV_rl_offcenter - rl_Offset))/FOV_rl; 
        
        y_top = Np/2 + round(SV_pix_offcen_ap - SV_pix_length_ap/2);
        y_bot = Np/2+ round(SV_pix_offcen_ap + SV_pix_length_ap/2);
        x_left = Np/2 +round(SV_pix_offcen_rl - SV_pix_length_rl/2);
        x_right = Np/2 +round(SV_pix_offcen_rl + SV_pix_length_rl/2);
               
        
    otherwise
end

if y_top < 1  
            y_top = 1;
        
        elseif y_bot > Np  
            y_bot = Np;
        
        elseif x_left < 1  
            x_left = 1;
        
        elseif x_right > Np  
            x_right = Np;
        
end
        
for row =  y_top :  y_bot
    for col =  x_left: x_right
        mask(row,col) = 1;
    end
end

    
 figure; imagesc(mask); colormap gray; title(' Shim ROI imported from scanner') 