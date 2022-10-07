%%%%%  SHIM SIMULATION CODE   PHILIPS GLOBAL SHIMMING               %%%%%%

%%%% Wrapper file for calculating shim values after getting fieldmap %%%%%
%%%% Uses shimXX , onepointXX , and aftershimXX functions written  %%%%%%%
%%%% by Yansong Zhao                                               %%%%%%%

%%%% Modified by Saikat Sengupta, VUIIS, Dec 2005

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global roi R Theta Phi;

roi= handles.roi;
fieldmap = handles.fieldmap;

mid = find(fieldmap > 350 | fieldmap < -350); fieldmap(mid) = 0;

%%%%%%%%%%%% Reading in Parameters and Creating the Coordinates %%%%%%%%%%%

Np = handles.parms.scan_resolution(1);      % phase encoding steps
Nf = handles.parms.scan_resolution(2);      % frequency encoding steps
Ns = handles.parms.max_slices;              % no of slices

if Nf > Np                          % Sometimes Nf < Np cos of less than 100% encoding.
    Np = Nf;
elseif Np > Nf
    Nf = Np;
end


block_ori = handles.parms.tags(1,26);

 FOV_AP = handles.parms.fov(1)/10;
 FOV_FH = handles.parms.fov(2)/10;
 FOV_RL = handles.parms.fov(3)/10;
 
  Slice_Thk = handles.parms.tags(1,23)/10; 
 
 %%%%%%%%%%%%%%%%%%%% Angulation for Oblique Slices   %%%%%%%%%%%%%%%%%%%% 
 
 ang_ap = handles.parms.angulation(1) * pi/180;
 ang_fh = handles.parms.angulation(2) * pi/180;
 ang_rl = handles.parms.angulation(3) * pi/180;
  
 Patient_Pos = handles.parms.patient_position;
 
 [ Tpom Geo_T] = Rotation_Stack(block_ori,ang_ap,ang_rl,ang_fh,Patient_Pos);

%%%%%%%%%%%%%%%%%%%%%%% Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Coordinate System for Gradients Vanderbilt 7 Tesla  %%%%%%%%%%%%%       
% 
%         | +x
%         |
%         |
%         /--------> +y
%        /
%       /
%      /
%    +z
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if block_ori == 1 %%%%%% axial      
      FOV_ROW = FOV_AP; 
      FOV_COL = FOV_RL; 
      FOV_DEPTH = FOV_FH; 
elseif block_ori == 3 %%%%%% coronal      
      FOV_ROW = FOV_FH; 
      FOV_COL = FOV_RL; 
      FOV_DEPTH = FOV_AP;
elseif block_ori == 2 %%%%%% Sagital     
      FOV_ROW = FOV_FH; 
      FOV_COL = FOV_AP; 
      FOV_DEPTH = FOV_RL;
end

row = linspace(-FOV_ROW/2,FOV_ROW/2,Np);
col = linspace(-FOV_COL/2,FOV_COL/2,Nf);
depth = linspace(- FOV_DEPTH/2 + Slice_Thk/2, FOV_DEPTH/2-Slice_Thk/2,Ns);

[COL,ROW,DEPTH] = meshgrid(col,row,depth);

for row = 1 : Np
    for col = 1 : Nf
        for depth = 1 : Ns
          Mag = Geo_T * [ROW(row,col,depth);COL(row,col,depth);DEPTH(row,col,depth)];
          Mag_X(row,col,depth) = Mag(1);
          Mag_Y(row,col,depth) = Mag(2);
          Mag_Z(row,col,depth) = Mag(3);
        end
    end
end


[Phi,Theta_complement,R] = cart2sph(Mag_X,Mag_Y,Mag_Z);
Theta = pi/2 - Theta_complement;


for n = 1 : Ns
    
    A_Slice = fieldmap(:,:,n);

    Stdev_init(n) = std(nonzeros(A_Slice));
    Mean(n) = mean(nonzeros(A_Slice)); 

    m_id = find(  A_Slice >  (Mean(n) + 3* Stdev_init(n)) |  A_Slice <  (Mean(n) - 3* Stdev_init(n)));
    A_Slice(m_id) = 0;
    
    A_Slice = medfilt2(A_Slice,[3 3]);

    fieldmap(:,:,n) = A_Slice;
       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Shimming  %%%%%%%%%%%%%%%%%%%%%%%%%%%

A = zeros(Np,Nf,Ns);

% Global shim
firstSlice = 1; 
lastSlice = Ns; 
dataspace = handles.dataspace;

%%% Downsample if needed
if numel(fieldmap) >= 8*1e5
    dataspace = 2;
end
      
    switch handles.order
        case 1
    %%%%%% Shimming 1st Order only
    handles.coeffs = shim04(firstSlice,lastSlice,dataspace,fieldmap);
    
    for index=1:Ns
          A(:,:,index) = aftershim04(handles.coeffs,index,fieldmap,block_ori);
    end
            
        case 2
    %%%%% Shimming 1st and 2nd Order
    
    handles.coeffs = shim09(firstSlice,lastSlice,dataspace,fieldmap);
    
    for index=1:Ns
          A(:,:,index) = aftershim09(handles.coeffs,index,fieldmap,block_ori);
    end
   
        case 3
    %%%%%% Shimming 1st ,2nd and 3rd  Order
    handles.coeffs = shim16(firstSlice,lastSlice,dataspace,fieldmap);
         
        otherwise
       error(' Shim order out of range ');
    end
    
    
    
handles.coeffs = -handles.coeffs;   %%%% Corrections
    
%%%%% Corrections for Stack Offsets   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  (For Global Shimming, Fo Offsets will be taken care of by Prep Phase )%%%%%%%%%


%%%% Offset_XYZ has sign adjusted Offsets for calculation of shim and F0 adjustments due
%%%% to multiplication of Tpom. Rows 1 : 3 are X;Y;Z respectively.

Offset_XYZ = Tpom * [ handles.parms.tags(1:2:end,22)/10 handles.parms.tags(1:2:end,20)/10  handles.parms.tags(1:2:end,21)/10 ]';


if mod(Ns,2)== 0
    Off_X = mean([Offset_XYZ(1,Ns/2),Offset_XYZ(1,(Ns/2)+1)]);
    Off_Y = mean([Offset_XYZ(2,Ns/2),Offset_XYZ(2,(Ns/2)+1)]);
    Off_Z = mean([Offset_XYZ(3,Ns/2),Offset_XYZ(3,(Ns/2)+1)]);
else
    Off_X = Offset_XYZ(1,(Ns+1)/2);
    Off_Y = Offset_XYZ(2,(Ns+1)/2);
    Off_Z = Offset_XYZ(3,(Ns+1)/2);
end


%%%%%% If table automatically moves to the isocenter position, then zero
%%%%%% the z offset.
 if strcmp(handles.table_move,'Yes')
     Off_Z = 0;
 end


if handles.order == 2 

        %%% For Z  =  Z - ( 2*Z2*Zoff +  ZX * Xoff + ZY * Yoff )
      handles.coeffs(2) = handles.coeffs(2) -(2*handles.coeffs(3)*Off_Z + handles.coeffs(5)* Off_X + handles.coeffs(8)* Off_Y) ;
      
      %%% For X  = X - ( -Z2*Xoff + ZX*Zoff + 2*X2Y2 * Xoff + 2*XY*Yoff)
      handles.coeffs(4) = handles.coeffs(4) -(- handles.coeffs(3)*Off_X + handles.coeffs(5)* Off_Z + 2*handles.coeffs(6)*Off_X + 2* handles.coeffs(9)* Off_Y);
      
       %%% For Y  = Y - ( -Z2*Yoff + ZY*Zoff - 2*X2Y2 * Yoff + 2*XY*Xoff)
      handles.coeffs(7) = handles.coeffs(7) -( -handles.coeffs(3)* Off_Y + handles.coeffs(8)* Off_Z - 2*handles.coeffs(6)* Off_Y + 2* handles.coeffs(9)* Off_X);

end



%%%%%%%%%%%%%%%%%%%%%%% Conversion to mT/m %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To convert from Hz/cm to mT/m divide by 425.8

% First Order       
%   01 Z0           
%   02 Z            
%   03 X            
%   04 Y            

% ====================================================================

% Second Order      

%  #     shim    LoadnGo Name
%  01     Z0
%  02     Z1
%  03     Z2        Z4
%  04     X
%  05     ZX        ZX
%  06     X2-Y2     C2
%  07     Y
%  08     ZY        ZY
%  09     2XY       S2

% ====================================================================


if handles.order == 1    
    handles.coeffs_1st = handles.coeffs([2,3,4])./425.8 ;  % Hz/cm - mT/m      
    handles.coeffs_1st = repmat(handles.coeffs_1st,[1 Ns]);
elseif handles.order == 2
   
    handles.coeffs_1st = handles.coeffs([2,4,7])./425.8 ;  % Hz/cm - mT/m 
    handles.coeffs_2nd = handles.coeffs([3,5,6,8,9]) ./ 4.258 ; % Hz/cm^2 - mT/m^2 

    handles.coeffs_1st = repmat(handles.coeffs_1st,[ 1 Ns]);
    handles.coeffs_2nd = repmat(handles.coeffs_2nd,[ 1 Ns]);
end

handles.Freq_Offset(1:Ns) = 0;


%%%%%%%%%%% Updating GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%

if handles.order == 1
    
set(handles.text20,'String',num2str(handles.coeffs_1st(2,1)));  %%% X
set(handles.text21,'String',num2str(handles.coeffs_1st(3,1)));  %%% Y
set(handles.text22,'String',num2str(handles.coeffs_1st(1,1)));  %%% Z

elseif handles.order == 2
    
set(handles.text20,'String',num2str(handles.coeffs_1st(2,1)));  %%% X
set(handles.text21,'String',num2str(handles.coeffs_1st(3,1)));  %%% Y
set(handles.text22,'String',num2str(handles.coeffs_1st(1,1)));  %%% Z
    
set(handles.text23,'String',num2str(handles.coeffs_2nd(1,1)));  %%% Z2
set(handles.text24,'String',num2str(handles.coeffs_2nd(2,1)));  %%% ZX
set(handles.text25,'String',num2str(handles.coeffs_2nd(4,1)));  %%% ZY
set(handles.text26,'String',num2str(handles.coeffs_2nd(3,1)));  %%% C2
set(handles.text27,'String',num2str(handles.coeffs_2nd(5,1)));  %%% S2


end

set(handles.text33,'String',num2str(handles.Freq_Offset(1))); % F0

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fid = fopen('E:\Export\Shim_Table_Manual.txt','wt');
fid = fopen('E:\Export\PRIDE\shimtool\linear_shim.txt','wt'); % This is writting the shim currents to a text file for the scanner to read

if (fid < 1)
      fid = fopen('linear_shim.txt','wt');
      if (fid < 1)
      error('Valid Directory not found, Cant write shim file'); 
      end
 end
  
    
 fprintf(fid,'%f \n',(handles.coeffs_1st(2,1))); % x
 fprintf(fid,'%f \n',(handles.coeffs_1st(3,1))); % y 
 fprintf(fid,'%f \n',(handles.coeffs_1st(1,1))); % z
 
 if isfield( handles,'coeffs_2nd')
 fprintf(fid,'%f \n',(handles.coeffs_2nd(1,1))); %z2
 fprintf(fid,'%f \n',(handles.coeffs_2nd(2,1))); %zx
 fprintf(fid,'%f \n',(handles.coeffs_2nd(4,1))); %zy
 fprintf(fid,'%f \n',(handles.coeffs_2nd(3,1))); %c2
 fprintf(fid,'%f \n',(handles.coeffs_2nd(5,1))); %s2
 else
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');    
 end
 
 if isfield( handles,'coeffs_3rd')
 fprintf(fid,'%f \n',(handles.coeffs_3rd(1,1))); %z3
 fprintf(fid,'%f \n',(handles.coeffs_3rd(2,1))); %z2x
 fprintf(fid,'%f \n',(handles.coeffs_3rd(4,1))); %z2y
 fprintf(fid,'%f \n',(handles.coeffs_3rd(3,1))); %ZC2
 fprintf(fid,'%f \n',(handles.coeffs_3rd(5,1))); %Zs2
 else
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');  
 end
     
 fprintf(fid,'0.0 \n');
 fprintf(fid,'0.0 \n');
 
fclose(fid);