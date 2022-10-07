function T = threshold(I)
%T = THRESHOLD(I) finds the optimal threshold corresponding to the intensity image I.
%The function is intended to be a enhancement of the images toolbox for thresholding
%purposes. It can be a quick way to automate the process of manually selecting a 
%threshold after seeing the histogram of an image. Also, the function helps user
%finding a reasonable good threshold value when the selection is not evident.
%
%If the histogram of image I is purely bimodal, the threshold will take a value 
%in the middle of the valley between the 2 modes (the logical election). 
%In other difficult cases, when the modes are overlapped, the threshold will minimize 
%the error of interpreting background pixels as objects pixels, and vice versa. 

%Created by Felix Toran Marti <ftoran@aimme.es>, 8/5/2000
%This is a function of Image Toolbox

%Image size
[rows,cols]=size(I);

%Initial consideration: each corner of the image has background pixels.
%This provides an initial threshold (T), calculated as the mean of the gray levels contained
%in the corners. The width and height of each corner is a tenth of the image's width 
%and height, respectively.

col_c=floor(cols/10);
rows_c=floor(rows/10);

corners=[I(1:rows_c,1:col_c); I(1:rows_c,(end-col_c+1):end);...
         I((end-rows_c+1):end,1:col_c);I((end-rows_c+1):end,(end-col_c+1):end)];
   
T=mean(mean(corners));

%***************************************************************
% ITERATIVE PROCESS
%***************************************************************

while 1

  %1. The mean of gray levels corresponding to objects in the image is calculated.
  %The actual threshold (T) is used to determine the boundary between objects and
  %background.
  mean_obj=sum(sum( (I>T).*I ))/length(find(I>T));
  
  %2. The same is done for the background pixels.
  mean_backgnd=sum(sum( (I<=T).*I ))/length(find(I<=T));
 
  %3. A new threshold is calculated as the mean of the last results:
  new_T=(mean_obj+mean_backgnd)/2;

  %4. A new iteration starts only if the threshold has changed.
  if(new_T==T)
     break;   
  else
     T=new_T;   
  end
   
end 
;

%At this stage, the optimal threshold value is contained in T. 

% END of threshold.m
% This is a function of Image Toolbox