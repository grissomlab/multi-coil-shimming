
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Code for thresholding the fieldmap from Philips based on the 
%%%%%%%%%%%%  FFE data set.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data_out mask] = Philips_Thresholding(main_Handle)

%#function checknargin
global gui_mask;

data = main_Handle.Data;

[m,n,sl,echo,phase,imtype,dyn] = size(data);
mask = zeros(m,n,sl,echo,phase,imtype,dyn);
mask_bs_auto = zeros(m,n,sl,echo,phase,imtype,dyn);

data_in = data(:,:,:,1,1,:,1);

if imtype == 1
    h = errordlg('Dixon Fieldmap ; Load anatomical image for Auto tresholding');
    [handles.Dixon handles.Dixon_parms] = readParRec;
    image_dixon = handles.Dixon(:,:,:,1,1,1);
    
    for k = 1 : sl 
        mask_dixon_temp = ones(m,n);
        image_dixon_temp = image_dixon(:,:,k);
        max_val(k) = max(max(image_dixon_temp));
        id = find(image_dixon_temp < main_Handle.auto_thresh * max_val(k));
        mask_dixon_temp(id) = 0;
        mask_dixon(:,:,k) = mask_dixon_temp;        
    end

    data_out = mask_dixon .* data_in;
    mask = mask_dixon;
    
    return;
end


switch main_Handle.roi_type
%%%%%%%%% Masking for Humans %%%%%%%%%%%%%%%%%%%%%
    
 
    case ' Brain Seg'
        
        if imtype == 1
           h = errordlg(' Insufficient Informaition for Brain Seg Masking ; Use Manual Masking');
           data_out =  data;
           return
       end

        h = Thresholding(squeeze(data_in));
        waitfor(h)
        gui_mask = repmat(gui_mask,[ 1, 1, 1,echo,phase,imtype,dyn]);
        mask = gui_mask;

%%%%%%%%% Manual Masking  (Single Mask for all slices) %%%%%%%%%%%%%%%%%%%%
    case ' Manual'
      

        figure; imagesc(data_in(:,:,1,1,1,1,1));colormap gray;axis image;
        mask = roipoly;
        mask = repmat(mask,[ 1, 1, sl,echo,phase,imtype,dyn]);
        
        if imtype == 1
           data_out =  mask .* data;
           return
        end

 %%%%%%%%% Manual Masking Separate  (Separate Mask for every slice) %%%%%%%%%%%%%%%%%%%%
    case ' Manual_Sl'
      
        for k = 1 : sl
            figure; imagesc(data_in(:,:,k,1,1,1,1));colormap gray;axis image;
            mask(:,:,k) = roipoly;
        end
        
        mask(:,:,:,echo,phase,imtype,dyn) = mask(:,:,:,1,1,1,1);
        
        if imtype == 1
           data_out =  mask .* data;
           return
        end       
        
        

%%%%%%%%%% Mask imported from Scanner %%%%%%%%%%%%%
    case ' Scanner ROI'
        
        if imtype == 1
           h = errordlg(' Insufficient Information for Scanner ROI Masking ; Use Manual Masking');
           data_out =  data;
           return
        end
       
        mask = ScannerShimVol(main_Handle);
        pause(1);
        mask = repmat(mask,[ 1, 1, sl,echo,phase,imtype,dyn]);

%%%%%%%%% Automatic Masking %%%%%%%%%%%%%%%%%%    
    case ' Automatic'
        
       if imtype == 1
           h = errordlg(' Insufficient Informaition for Automatic Masking ; Use Manual Masking');
           data_out =  data;
           return
       end

          for d = 1 : dyn   
            for k = 1 : sl
                max_val(k) = max(max(data(:,:,k,1,1,1,d)));
                              
                
                for i = 1 : m
                    for j = 1 : n       
                        if data(i,j,k,1,1,1,d) >= main_Handle.auto_thresh * max_val(k)  %%%%% Threshold
                               mask(i,j,k,1,1,1:imtype,d) = 1;

                        end
                    end
                end
                 mask(:,:,k,1,1,1:imtype,d) = bwareaopen(mask(:,:,k,1,1,1:imtype,d),500);         
                 mask(:,:,k,1,1,1:imtype,d) = Select_Largest_Block(squeeze(mask(:,:,k,1,1,1,d)));        

                 clear out;       

            end
          end         
    
    
%%%%%%%%% Automatic Masking %%%%%%%%%%%%%%%%%%    
    case 'Scanner & Fat'
        
        if imtype == 1
           h = errordlg(' Insufficient Information for Scanner & Fat Masking ; Use Manual Masking');
           data_out =  data;
           return
        end
        

        for d = 1 : dyn     
        for k = 1 : sl
            max_val(k) = max(max(data(:,:,k,1,1,1,d)));
            for i = 1 : m
                for j = 1 : n       
                    if data(i,j,k,1,1,1,d) >= main_Handle.auto_thresh* max_val(k)  %%%%% Threshold
                           mask(i,j,k,1,1,1:imtype,d) = 1;
                      
                    end
                end
            end
          mask(:,:,k,1,1,1:imtype,d) = bwareaopen(mask(:,:,k,1,1,1:imtype,d),500);         
          mask(:,:,k,1,1,1:imtype,d) = Select_Largest_Block(squeeze(mask(:,:,k,1,1,1,d)));        
          
         clear out;
        end                  
        end
     
     
        mask = squeeze(mask(:,:,:,1,1,1,1));
        
        mask_scanner = ScannerShimVol(main_Handle);
        mask = mask .* repmat(mask_scanner, [ 1 1 sl]);
        pause(1);
                 
              
        for k  = 1 : sl   
           mask_fat_slice = mask(:,:,k);
           p = squeeze(data(:,:,k,1,1,2,1));
           p = p .*mask(:,:,k);
           
           %%%% Adaptive levels of fieldmaps thresholding ?
           
           ind = find(p > main_Handle.Fat_Max | p < main_Handle.Fat_Min | abs(p) < 0.5);
           mask_fat_slice(ind) = 0; 
           mask(:,:,k) = mask_fat_slice;
           mask(:,:,k,1,1,1:imtype,d) = Select_Largest_Block(squeeze(mask(:,:,k)));
           
        end
        
      clear mask_fat_slice;
        
%%%%%%%%% From Saved ROI in Workspace %%%%%%%%%%%%%%%%%% 
     
    otherwise
         
end

%%%%%%%%%%%%% Automatic Residual Masking %%%%%%%%%%%%%%%%%%

if strcmp(main_Handle.roi_type ,' From Scanner & Fat') ~= 1

[seg_im,mask_bs_auto(:,:,:,1,1,1)] = vuBrainExtraction(data(:,:,:,1,1,1),'frac_thresh',main_Handle.bs_thresh);
mask_bs_auto(:,:,:,1,1,2) = mask_bs_auto(:,:,:,1,1,1);
mask = mask & mask_bs_auto; 

end

data_out = mask .* data;
data_out = data_out(:,:,:,1:echo,1:phase,2,1:dyn);
data_out = squeeze(data_out);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ out ] = Select_Largest_Block(in)
       
out = ones(size(in,1),size(in,2));

% SE = strel('square', 2);
% in = imerode(in,SE);

[mo,no] = bwlabel(in); 

if no == 0                     %%% No blocks available.
       
    out = repmat(in, [ 1 1 2]); 
    return
 
else
    
    for block = 1:no
        np(block) = length(find(mo == block)); 
    end
    [Y,I] = max(np);
    m_id = find(mo ~= I);
    out(m_id) = 0; %#ok<FNDSB>

%     out = imdilate(out,SE);

    out = repmat(out, [ 1 1 2]);       

end             