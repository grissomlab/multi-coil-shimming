%%%% Load the Shim Coils 


path1 = '.';
path2 = '';
Full_FOV = [40,40,40]; % Full FOV in cm;

%%% Load the Shim Coils
L = {};
clear file_str file_str_0
file_str = {};

%%% On Top of patient (Not a good idea because coil might move around
% file_str{end+1} = '/W_5cm_Ang_0_90_0_Pos_10_0_5'; %4

%%% On Bottom of patient (* Have to avoid posterior torso array *)
% file_str{end+1} = '/W_5cm_Ang_0_90_0_Pos_-15_0_5'; %1
% file_str{end+1} = '/W_5cm_Ang_0_90_0_Pos_-15_0_-5'; %2
% file_str{end+1} = '/W_5cm_Ang_0_90_0_Pos_-15_10_-5'; %3
% file_str{end+1} = '/W_5cm_Ang_0_90_0_Pos_-15_5_0'; %7 
% file_str{end+1} = '/W_5cm_Ang_0_90_0_Pos_-15_-5_0'; %8  
% file_str{end+1} = '/W_5cm_Ang_0_-90_0_Pos_-15_0_10'; %9  
% file_str{end+1} = '/W_5cm_Ang_0_-80_0_Pos_-15_0_10'; %10
% file_str{end+1} = '/W_5cm_Ang_0_-80_0_Pos_-15_0_5'; %11 
% file_str{end+1} = '/W_5cm_Ang_0_-70_0_Pos_-15_0_5'; %12 
% file_str{end+1} = '/W_5cm_Ang_0_-70_0_Pos_-15_0_10'; %13 
% file_str{end+1} = '/W_5cm_Ang_0_0_0_Pos_-15_0_5'; %14 
% file_str{end+1} = '/W_5cm_Ang_0_-80_0_Pos_-15_0_10'; %15 
% file_str{end+1} = '/W_4cm_Ang_0_-80_0_Pos_-15_0_10'; %16 
% file_str{end+1} = '/W_5cm_Ang_0_-70_0_Pos_-15_5_10'; %17   
% file_str{end+1} = '/W_5cm_Ang_0_-70_0_Pos_-15_-5_10'; %18 
% file_str{end+1} = '/W_5cm_Ang_0_-60_0_Pos_-15_0_10'; %19 
%  file_str{end+1} = '/W_5cm_Ang_0_-90_0_Pos_-15_0_15'; %23
  
%%% Side of patient ( Best Configuration )
  %  file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_18_-10'; %5 . %%% Too close to body
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_18_-9'; %6 . %%% Too close to body

   file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_19_-9'; %22
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_19_-2'; %21
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_19_-1'; %22
   file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_19_0'; %20
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_19_1'; %22
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_19_2'; %22
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_6_19_-4'; %22
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_8_19_-4'; %22
    
%   file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_-19_0'; %22
%   file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_-19_1'; %22
%    file_str{end+1} = '/W_5cm_Ang_90_0_0_Pos_0_-19_-9'; %22
%   file_str{end+1} = '/W_3cm_Ang_90_0_0_Pos_0_-19_-9'; %22
 


%%%%% 2 cm coils seem too small to have an impact
%  file_str{end+1} = '/W_2cm_Ang_90_0_0_Pos_0_19_-10'; %22
% file_str{end+1} = '/W_2cm_Ang_90_0_0_Pos_0_19_-5'; %22
%   file_str{end+1} = '/W_2cm_Ang_90_0_0_Pos_0_19_-6'; %22
%   file_str{end+1} = '/W_2cm_Ang_90_0_0_Pos_0_19_-2'; %22

  

WC_Fit = [];
  
for n= 1: length(file_str)
    Temp = load([path1,path2,file_str{n},'.mat']);
    WC_Fit(:,:,:,n) = Temp.W;
    if isfield(Temp,'L_Final'), L{n} = Temp.L_Final; end   
    clear Temp;   
end

ND = size(WC_Fit,1);


%%%% Load the field Data.
Temp = load([path1,path2,'/W_Implant.mat']);
Mask = single(Temp.Mask);
Df_Image = single(Temp.Deltaf); 
clear Temp;

%%%% Load the image volume
Temp = load([path1,path2,'/Vol_Image.mat']);
Vol = single(Temp.Vol_int_final);
clear Temp;


%%% Circshift the Df_Image and Vol a little bit in the left-right directon.
Df_Image = circshift(Df_Image,-15,2);
Vol = circshift(Vol,-15,2);


file_str_legend = {}; 
%%%% Plotting CN90 in the same plot----------------------------------/
figure; 
%%% Plotting
for i = 1:length(L)
LL = L{i};
plot3(LL(:,3),LL(:,2),LL(:,1),'linewidth',2); grid on;
axis image 
xlabel('Magnet Z Axis (mm) ', 'FontSize',14);ylabel('Magnet Y Axis (mm)','FontSize',14);zlabel('Magnet X Axis (mm)','FontSize',14); 
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
file_str_legend{i}  = regexprep(file_str{i}, '_', ' ');
hold on
end
view(-45,25);
set(gcf,'color','w');
xlim([ -Full_FOV(1)/2 Full_FOV(1)/2]); ylim([-Full_FOV(2)/2 Full_FOV(2)/2]);zlim([-Full_FOV(3)/2 Full_FOV(3)/2]);

legend(file_str_legend);


%% Perform Quick Shim fit for volume

clear Mask_Image
clear AS
clear XFit_Vec YFit_Vec index

Mask_Image = zeros(size(Vol));

figure; imagesc(Vol(:,:,226)); axis image; colormap gray
roi = roipoly;

 nslices = 6;
% nslices = 1;

sl_range = 226-nslices/2:226+nslices/2-1;
Mask_Image(:,:,sl_range) = repmat(roi,[1,1,nslices]);
index = find(Mask_Image(:));


%% Define 1 Amp Spherical Harmonic Shims

x = 1*(-ND/2:ND/2-1)/10;
y = 1*(-ND/2:ND/2-1)/10;
z = 1*(-ND/2:ND/2-1)/10;
[X, Y, Z] = meshgrid(x,y,z);

%%%%% Spherical Harmonic Shim strengths
Z0_Str = 1; % Hz
X_Str = 24.19318182 ;%% . Hz/cm/A
Y_Str = 23.14130435 ;%% . Hz/cm/A
Z_Str = 22.52910053 ;%% . Hz/cm/A
Z2_Str = 0.822007722 ;%% . Hz/cm^2/A
ZX_Str = -1.656809339 ;%% . Hz/cm^2/A
ZY_Str = -1.656809339 ;%% . Hz/cm^2/A
C2_Str = -0.785608856;%% . Hz/cm^2/A
S2_Str = -0.79588785 ;%% . Hz/cm^2/A


% Adding ShShims: [Z0 X,Y,Z,Z2,ZX,ZY,C2,S2]
Add_ShShim_Flag = [0,1,1,1,1,1,1,1,1];

SH_shims = zeros(ND-1,ND-1,ND-1,9);

SH_shims(:,:,:,1) = Z0_Str*ones(ND-1,ND-1,ND-1);
SH_shims(:,:,:,2) = X_Str*X(2:ND,2:ND,2:ND);
SH_shims(:,:,:,3) = Y_Str*Y(2:ND,2:ND,2:ND);
SH_shims(:,:,:,4) = Z_Str*Z(2:ND,2:ND,2:ND);

Z2f = Z2_Str*(Z.^2 -(X.^2+Y.^2)/2); 
SH_shims(:,:,:,5) = Z2f(2:ND,2:ND,2:ND);

ZXf = ZX_Str*(Z.*X); 
SH_shims(:,:,:,6) = ZXf(2:ND,2:ND,2:ND);

ZYf = ZY_Str*(Z.*Y); 
SH_shims(:,:,:,7) = ZYf(2:ND,2:ND,2:ND);


C2f = C2_Str*(X.^2-Y.^2); 
SH_shims(:,:,:,8) = C2f(2:ND,2:ND,2:ND);

S2f = S2_Str*(X.*Y); 
SH_shims(:,:,:,9) = S2f(2:ND,2:ND,2:ND);


%%%% Max Current Bounds
max_current = -4.8;
SH_lb = [-1000;max_current;max_current;max_current;max_current;max_current;max_current;max_current;max_current];
% SH_lb = SH_lb *0;


%% Local Coils + Spherical Harmonic Fields

clear XFit_Vec YFit_Vec;
%%%%% Vectors for Shim Fitting
YFit = squeeze(Df_Image);  
YFit_Vec = YFit(:);

%%% Choose Only 2 local coils
Nshims = 2;
N = size(WC_Fit,4);
Comb = nchoosek(1:N,Nshims);
AfterShim_std_ratio = zeros(size(Comb,1),1);


%%%% Adding SH Shims if Needed
coeffs = zeros(size(Comb,1), Nshims+nnz(Add_ShShim_Flag));
Nshims = Nshims+nnz(Add_ShShim_Flag);
SH_Vec = [];
SH_lb_idx = [];
for sh_idx = 1:9
    if Add_ShShim_Flag(sh_idx) == 1
        tmp = SH_shims(:,:,:,sh_idx);
        SH_Vec = cat(2,SH_Vec,tmp(:));
        SH_lb_idx(end+1) = SH_lb(sh_idx);
        clear tmp;
    end
end



for comb_idx = 1 : size(Comb,1)
    
%  for ncomb = 1 
    
clear XFit_Vec;
clear AS;

disp(['combination number = ',num2str(comb_idx)]); 
coil_idx = Comb(comb_idx,:);

XFit_Vec = [];
for n = coil_idx    
     Temp = WC_Fit(2:ND,2:ND,2:ND,n);
     XFit_Vec(:,end+1) = double(Temp(:));
     clear Temp
end

%%%%Set Current Bounds for Local Shims
%lb = -100*ones(size(XFit_Vec,2),1);
lb = 0*ones(size(XFit_Vec,2),1); % zero the currents in the coil loops
 
%%% Adding Spherical Harmonic Shims.
XFit_Vec = [XFit_Vec,SH_Vec];
lb = [lb;SH_lb_idx'];
ub = -lb;
shimcoeffs_0 = 0*ones(size(XFit_Vec,2),1);


%%%%% Shim Fitting %%%%%%%%%%%
options=optimset('Display','off','MaxIter',1000, 'TolFun',1e-6);   
[ coeffs(comb_idx,:), AfterShim_std_ratio(comb_idx)]  = fminsearchbnd(@Optimization_Function_2coils,shimcoeffs_0,lb,ub,...
            options,YFit_Vec(index),XFit_Vec(index,:)); 
        
end

[~,id] = min(AfterShim_std_ratio);
 
Fit_Field_vec = XFit_Vec*coeffs(id,:)';
Fit_Field = reshape(Fit_Field_vec ,size(Df_Image));     
  
AS_Vec = YFit_Vec + Fit_Field_vec;
AS = reshape(AS_Vec,size(Df_Image));

% vuOnePaneViewer(AS.*Mask_Image);

Df_roi = Df_Image(:,:,sl_range);
AS_roi = AS(:,:,sl_range);
Mask_roi = Mask_Image(:,:,sl_range);

figure;imagesc(mymontage2(Df_roi.*Mask_roi), [ -1000 0]); 
axis image; title(' Before Shimming');
figure;imagesc(mymontage2(AS_roi.*Mask_roi), [ -100 100]); 
axis image; title(' After Shimming');

A = Df_Image(:,:,226-nslices/2:226+nslices/2-1).*Mask_Image(:,:,226-nslices/2:226+nslices/2-1);
B = AS(:,:,226-nslices/2:226+nslices/2-1).*Mask_Image(:,:,226-nslices/2:226+nslices/2-1);

figure;plot(AfterShim_std_ratio);
figure; h1 = histogram(nonzeros(Df_roi.*Mask_roi),100);xlim([-1000 500]);
hold on; h2 = histogram(nonzeros(AS_roi.*Mask_roi),100);xlim([-1000 500]);
grid on; 


%%

function [AfterShim_std ] = Optimization_Function_2coils(Z,y,x)

X = x*Z';
arg = y + X;

% AfterShim_std = std(nonzeros(arg)) %#ok<NOPRT>
AfterShim_std = std(arg)/std(nonzeros(y)); %#ok<NOPRT>
% AfterShim_std = max(arg(:))-min(arg(:));

end

