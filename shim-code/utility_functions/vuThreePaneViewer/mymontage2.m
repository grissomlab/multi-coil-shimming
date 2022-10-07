function [result,h]=mymontage2(image,decision,mask1,colors1,mask2,colors2,mask3,colors3,mask4,colors4,mask5,colors5,mask6,colors6,mask7,colors7)
% _________________________________________________________________________
% function [result,h]=mymontage2(image,decision,mask1,colors1,mask2,colors2,mask3,colors3,mask4,colors4,mask5,colors5,mask6,colors6,mask7,colors7)
% _________________________________________________________________________
% This function is most useful for displaying multislice images.  In
% addition, it can be used to visualize regions of interest within 2D or 3D
% images.  This will take a 3D matrix, where the third dimension is slices,
% and lay out the images with each slice side-by-side.  This 2D resulting image will be returned.
% If logical masks are passed, then they will be outlined, and may be shaded as well.
%
% Example usage: result=mymontage2(image,'d');
%
% arguments:image-    must be a 2D or 3D matrix
%           decision- a string containing letters and optionally containing
%                     numbers at the end.  This will determine the output options.
%                     Available options:
%                     'd' for display image in a new figure window
%                     'i' for display image inside current axes
%                     'o' for overlay shaded roi for each region defined by
%                         each mask.
%                     '#' where # is the desired line thickness for roi
%                         borders.  This number must be placed at the end
%                         of the decision string.
%                     Example: decision='do3.5'
%           mask1-    a logical matrix defining the region of interest to be viewed.
%                     This must be the same size as 'image'.
%           colors1-  This defines the color/style for the roi border for mask1.
%                     If overlay is selected, then this will also define the color of
%                     the region shading.  This argument must be either a
%                     character string or a three element numerical array
%                     of rgb values.  Standard formatting as used in the
%                     plot command is also acceptable.
%                     Example entries for colors1:
%                     'g'       for a green outline around roi
%                     'green'   for a green outline around roi
%                     [0 1 0]   for a green outline around roi (useful if
%                               non-standard colors are desired, though you loose the
%                               ability to change your line style.)
%                     'g--'     for a green dashed line around roi
%           mask 2:7- see mask1
%           colors2:7- see colors1
% note: When overlaying a shaded roi, it may be desirable to increase the
%       brightness of the colors.  To do this, pass color information as rgb
%       values in the format [r g b], and increase values beyond 1.  The higher
%       the number used, the more intense that color is.  If the numbers are high
%       enough, the region will simply be saturated with that color, and there
%       will be no apparent transparency to the color.
%
% Other Examples:
%
%   result=mymontage2(brainIM,'do',firstroi,'r',secondroi,'m',thirdroi,'y')
%       This will display 'brianIM' with three rois outlined and shaded.
%       The colors red, magenta, and yellow will mark the first, second,
%       and third roi respectively.  Each will be outlined with a solid
%       line.
%
%
%   result=mymontage2(brainIM,'d',firstroi,'r..',secondroi,[0.4 0.4 0.8],thirdroi,[0.2 0.7 0.6])
%       This will display 'brianIM' with three rois only outlined.
%       The first roi will have a dotted line, while the other two will
%       have custome colors with solid lines.
%
%
% written by: Allen T. Newton
% last revised: 07/28/2006
%__________________________________________________________________________
%__________________________________________________________________________


index=find(isnan(image)==1);
image(index)=0;




%this parces out the line weight informatoin from decision
if nargin>1
    counter=1;
    while isempty(str2num(decision(counter:end)))==1 && counter<length(decision)
        counter=counter+1;
    end;

    if length(decision)~=counter
        weight=str2num(decision(counter:length(decision)));
    else
        weight=1.5;
    end
    %this reads decision to figure out where images should be displayed
    if ~isempty(find(decision=='d')) & nargin~=0
        figure;
        h=axes;
    elseif ~isempty(find(decision=='i')) & nargin~=0
        h=gca;
    end
    %this checks if the overlay option has been selected
    if ~isempty(find(decision=='o'))
        overlay=1;
    else
        overlay=0;
    end
end



sizes=size(image);
%this changes sizes compensating for when a 2D image is sent
if length(sizes)==2
    sizes=[sizes 1];
end

%this interprets the roicolor information so it can be used by both the
%plot command as well as Luci's roi overlay function
if exist('colors7')
    acolor{1}=colors1;
    acolor{2}=colors2;
    acolor{3}=colors3;
    acolor{4}=colors4;
    acolor{5}=colors5;
    acolor{6}=colors6;
    acolor{7}=colors7;
elseif exist('colors6')
    acolor{1}=colors1;
    acolor{2}=colors2;
    acolor{3}=colors3;
    acolor{4}=colors4;
    acolor{5}=colors5;
    acolor{6}=colors6;
elseif exist('colors5')
    acolor{1}=colors1;
    acolor{2}=colors2;
    acolor{3}=colors3;
    acolor{4}=colors4;
    acolor{5}=colors5;
elseif  exist('colors4')
    acolor{1}=colors1;
    acolor{2}=colors2;
    acolor{3}=colors3;
    acolor{4}=colors4;
elseif exist('colors3')
    acolor{1}=colors1;
    acolor{2}=colors2;
    acolor{3}=colors3;
elseif exist('colors2')
    acolor{1}=colors1;
    acolor{2}=colors2;
elseif exist('colors1')
    acolor{1}=colors1;
end

if exist('acolor')
    [acolor,linecolor,roicolor]=colorconverter(acolor);
end



%only the laid out image is returned with no display
if nargin==1
    result=layoutfcn(image);
    return

    %image is displayed, though zero masks
elseif nargin==2
    result=layoutfcn(image);

    axes(h)
    imagesc(result);colormap gray;
    axis image
    caxis([min(result(:)) max(result(:))]);
    axis off
    %image is displayed with 1 mask
elseif nargin==4
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)

    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    hold off
    %image is displayed with 2 masks
elseif nargin==6
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);
    mask2p=layoutfcn(mask2);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)
    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    [B,L] = bwboundaries(mask2p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{2}, 'LineWidth', weight, 'color', linecolor(:,2))
    end
    hold off
    %image is displayed with 3 masks
elseif nargin==8
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);
    mask2p=layoutfcn(mask2);
    mask3p=layoutfcn(mask3);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)
    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    [B,L] = bwboundaries(mask2p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{2}, 'LineWidth', weight, 'color', linecolor(:,2))
    end
    [B,L] = bwboundaries(mask3p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{3}, 'LineWidth', weight, 'color', linecolor(:,3))
    end
    hold off
    %image is displayed with 4 masks
elseif nargin==10
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);
    mask2p=layoutfcn(mask2);
    mask3p=layoutfcn(mask3);
    mask4p=layoutfcn(mask4);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)
    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    [B,L] = bwboundaries(mask2p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{2}, 'LineWidth', weight, 'color', linecolor(:,2))
    end
    [B,L] = bwboundaries(mask3p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{3}, 'LineWidth', weight, 'color', linecolor(:,3))
    end
    [B,L] = bwboundaries(mask4p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{4}, 'LineWidth', weight, 'color', linecolor(:,4))
    end
    hold off
    %image is displayed with 5 masks
elseif nargin==12
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);
    mask2p=layoutfcn(mask2);
    mask3p=layoutfcn(mask3);
    mask4p=layoutfcn(mask4);
    mask5p=layoutfcn(mask5);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)
    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    [B,L] = bwboundaries(mask2p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{2}, 'LineWidth', weight, 'color', linecolor(:,2))
    end
    [B,L] = bwboundaries(mask3p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{3}, 'LineWidth', weight, 'color', linecolor(:,3))
    end
    [B,L] = bwboundaries(mask4p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{4}, 'LineWidth', weight, 'color', linecolor(:,4))
    end
    [B,L] = bwboundaries(mask5p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{5}, 'LineWidth', weight, 'color', linecolor(:,5))
    end
    hold off
    %image is displayed with 6 masks
elseif nargin==14
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);
    mask2p=layoutfcn(mask2);
    mask3p=layoutfcn(mask3);
    mask4p=layoutfcn(mask4);
    mask5p=layoutfcn(mask5);
    mask6p=layoutfcn(mask6);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)
    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    [B,L] = bwboundaries(mask2p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{2}, 'LineWidth', weight, 'color', linecolor(:,2))
    end
    [B,L] = bwboundaries(mask3p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{3}, 'LineWidth', weight, 'color', linecolor(:,3))
    end
    [B,L] = bwboundaries(mask4p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{4}, 'LineWidth', weight, 'color', linecolor(:,4))
    end
    [B,L] = bwboundaries(mask5p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{5}, 'LineWidth', weight, 'color', linecolor(:,5))
    end
    [B,L] = bwboundaries(mask6p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{6}, 'LineWidth', weight, 'color', linecolor(:,6))
    end
    hold off
    %image displayed with 7 masks
elseif nargin==16
    result=layoutfcn(image);
    mask1p=layoutfcn(mask1);
    mask2p=layoutfcn(mask2);
    mask3p=layoutfcn(mask3);
    mask4p=layoutfcn(mask4);
    mask5p=layoutfcn(mask5);
    mask6p=layoutfcn(mask6);
    mask7p=layoutfcn(mask7);

    %this puts all laid out masks into one array
    if exist('mask7p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p,mask7p);
    elseif exist('mask6p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p,mask6p);
    elseif exist('mask5p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p,mask5p);
    elseif exist('mask4p')
        masks=cat(4,mask1p,mask2p,mask3p,mask4p);
    elseif exist('mask3p')
        masks=cat(4,mask1p,mask2p,mask3p);
    elseif exist('mask2p')
        masks=cat(4,mask1p,mask2p);
    elseif exist('mask1p')
        masks=cat(4,mask1p);
    end


    axes(h)
    if overlay==0
        imagesc(result);colormap gray;
        axis image
        caxis([min(min(result)) max(max(result))]);
        axis off
    elseif overlay==1

        result=overlayroifcn(result,masks,roicolor);
        imshow(result);
    end;

    [B,L] = bwboundaries(mask1p,'holes');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{1}, 'LineWidth', weight, 'color', linecolor(:,1))
    end
    [B,L] = bwboundaries(mask2p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{2}, 'LineWidth', weight, 'color', linecolor(:,2))
    end
    [B,L] = bwboundaries(mask3p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{3}, 'LineWidth', weight, 'color', linecolor(:,3))
    end
    [B,L] = bwboundaries(mask4p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{4}, 'LineWidth', weight, 'color', linecolor(:,4))
    end
    [B,L] = bwboundaries(mask5p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{5}, 'LineWidth', weight, 'color', linecolor(:,5))
    end
    [B,L] = bwboundaries(mask6p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{6}, 'LineWidth', weight, 'color', linecolor(:,6))
    end
    [B,L] = bwboundaries(mask7p,'holes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), acolor{7}, 'LineWidth', weight, 'color', linecolor(:,7))
    end
    hold off




end

sizes=size(image);
sizes2=size(result);
set(gca,'xtick',[sizes(2)+0.5:sizes(2):sizes2(2)+0.5],'ytick',[sizes(1)+0.5:sizes(1):sizes2(1)+0.5],'xcolor',[1 1 1],'ycolor',[1 1 1],'yticklabel',[],'xticklabel',[],'gridlinestyle','-');
grid on;



%__________________________________________________________________________
%_________________convert color info to something useful___________________
%__________________________________________________________________________
function [acolor,linecolor,roicolor]=colorconverter(acolor);


for jj=1:length(acolor)
    tmpcolor=acolor{jj};

    counter=0;
    while ~isempty(find((isletter(tmpcolor(1:end-counter)))==0)) && counter<length(tmpcolor)
        counter=counter+1;
    end;

    %switchvar=tmpcolor(1:length(tmpcolor)-counter);
    switchvar=tmpcolor(1);
    if isnumeric(switchvar)
        switchvar=1;
    end
    switch switchvar
        case 'k'
            roicolor=[0 0 0];
            linecolor=[0 0 0];
            alphacolor='k';
        case 'w'
            roicolor=[1 1 1];
            linecolor=[1 1 1];
            alphacolor='w';
        case 'r'
            roicolor=[1 0 0];
            linecolor=[1 0 0];
            alphacolor='r';
        case 'g'
            roicolor=[0 1 0];
            linecolor=[0 1 0];
            alphacolor='g';
        case 'b'
            roicolor=[0 0 1];
            linecolor=[0 0 1];
            alphacolor='b';
        case 'y'
            roicolor=[1 1 0];
            linecolor=[1 1 0];
            alphacolor='y';
        case 'm'
            roicolor=[1 0 1];
            linecolor=[1 0 1];
            alphacolor='m';
        case 'c'
            roicolor=[0 1 1];
            linecolor=[0 1 1];
            alphacolor='c';
        case 'black'
            roicolor=[0 0 0];
            linecolor=[0 0 0];
            alphacolor='k';
        case 'white'
            roicolor=[1 1 1];
            linecolor=[1 1 1];
            alphacolor='w';
        case 'red'
            roicolor=[1 0 0];
            linecolor=[1 0 0];
            alphacolor='r';
        case 'green'
            roicolor=[0 1 0];
            linecolor=[0 1 0];
            alphacolor='g';
        case 'blue'
            roicolor=[0 0 1];
            linecolor=[0 0 1];
            alphacolor='b';
        case 'yellow'
            roicolor=[1 1 0];
            linecolor=[1 1 0];
            alphacolor='y';
        case 'magenta'
            roicolor=[1 0 1];
            linecolor=[1 0 1];
            alphacolor='m';
        case 'cyan'
            roicolor=[0 1 1];
            linecolor=[0 1 1];
            alphacolor='c';
        otherwise
            if ~isnumeric(tmpcolor) || (isnumeric(tmpcolor) & length(tmpcolor)~=3)
                disp(['switchvar = ',switchvar]);
                disp(['tmpcolor = ',tmpcolor]);
                disp('Error: can''t understand color information');
            else

                roicolor=tmpcolor;
                alphacolor='k';
                if max(tmpcolor)>1
                    linecolor=tmpcolor./max(tmpcolor);
                else
                    linecolor=tmpcolor;
                end
            end
    end
    if isnumeric(tmpcolor)
        tmpacolor{jj}=[alphacolor];
    else
        tmpacolor{jj}=[alphacolor tmpcolor(length(tmpcolor)-counter+1:end)];
    end
    tmproicolor(:,jj)=roicolor';
    tmplinecolor(:,jj)=linecolor';
end

clear acolor;
acolor=tmpacolor;
roicolor=tmproicolor;
linecolor=tmplinecolor;




%__________________________________________________________________________
%_____________________return color image for shading_______________________
%__________________________________________________________________________

function [IM_rgb]=overlayroifcn(IM, masks, roicolor)
%this is a modified version of overlayroi by J. Luci

%this brightens the shaded regions
roicolor=1.0.*roicolor;


% Calculate the RGB offset for the color specified and deliver
%  an error if nonsense is provided.
space1=size(IM,1)*size(IM,2);
space2=2*(size(IM,1)*size(IM,2));


% Scale the image from 0 to 1.
% An unfortunate consequence of this choice is that an ROI will
%  be invisible over areas of very low image intensity.
IM=IM-min(min(IM));
IM=IM./max(max(IM));

% Create a pseudo-RGB image in grayscale
IM_rgb=cat(3, IM, IM, IM);

% Increase the red of the roi.
% Index notation used here because red is the first page of
%  the RGB image anyway.
sizes=size(roicolor);
for ii=1:sizes(2)
    roi=squeeze(masks(:,:,:,ii));
    IM_rgb(find(roi)) = IM_rgb(find(roi)).*roicolor(1,ii);
    IM_rgb(find(roi)+space1) = IM_rgb(find(roi)+space1).*roicolor(2,ii);
    IM_rgb(find(roi)+space2) = IM_rgb(find(roi)+space2).*roicolor(3,ii);

end


%__________________________________________________________________________
%__________________________layout 2D images________________________________
%__________________________________________________________________________

function [laidout]=layoutfcn(threed)
sizes=size(threed);
if length(sizes)==2
    sizes=[sizes 1];
end
side=ceil(sqrt(sizes(3)));
laidout=zeros(sizes(1)*ceil(sizes(3)/side),sizes(2)*side);
for m=1:sizes(3)
    q=m/side;
    if q==floor(q)
        i=side;
    else
        i=round((q-floor(q))*side);
    end
    j=ceil(q);
    laidout([1+(sizes(1)*(j-1)):sizes(1)+(sizes(1)*(j-1))],[1+(sizes(2)*(i-1)):sizes(2)+(sizes(2)*(i-1))])=squeeze(threed(:,:,m));
end;







