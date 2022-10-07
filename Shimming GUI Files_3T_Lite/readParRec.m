% Function read_parrec(filename,output_format,verbose_flag);
%  to read PARREC files on Philips
%

% Syntax: [flt_data,parms,dims] = parrec(filename,output_format,verbose_flag);
%
% Inputs:
%           If no inputs, via UI, select name of PAR file
%           assumes the REC file in the same folder as PAR file
%           output is then FP
%           With inputs:
%                       filename = filename (with path) of PAR file
%                       output_format = data output type - FP, DV, SV
%                       verbose_flag = if exists, prints info to command window
%
% Output: flt_data: matrix of the images (as FP values, by default)
%         parms: structure containing PRA file info
%         dims: [stride nline nslice necho nphase ntype ndyn]
% Can process both V3 and V4 types of PAR files automatically
%

% Date: 16-nov-2004
% Author: Benoit Desjardins, MD, PhD
%         Department of Radiology
%         University of Michigan
%
% JCG 1/27/05
% Modified for 1, input of parfile name directly
%              2, Data format output selection
%              3, Platform independent file conversion
%
%
% Edited 2/14/05 to correctly parse multiple echoes
%


function [flt_data , parms] = parrec(parfile,out_fmt,verboseflag);



if nargin < 2
    out_fmt = 'FP';  % format of outputed images: can be 'FP', 'DV' or 'SV'
end
% Check for valid formats
    if ~(strcmp(out_fmt,'FP') | strcmp(out_fmt,'DV') | strcmp(out_fmt,'SV') )
        error('Format needs to be one of: FP (default), DV, SV');
    end
if nargin < 1
[fname,pname] = uigetfile('*.PAR','Select *.PAR file');
parfile=[pname fname];
end

tic;

%%%% Actual functions for reading PAR and REC files.

[parms,ver] = read_parfile(parfile);
[flt_data,dims] = read_recfile([parfile(1:(end-4)) '.REC'],parms,ver,out_fmt);

if nargin > 2
    disp(sprintf('This is a %s PAR file',ver));
    disp(sprintf('Output of images is in %s format',out_fmt));
    disp(sprintf('Read %d images of size [%d x %d]',prod(dims(3:end)),dims(1:2)));
    disp(sprintf('# slices: %d, # echoes: %d, # phases: %d, # types: %d, # dynamics: %d',dims(3:end)));
    disp(['Total execution time = ' num2str(toc)]);
end

% Output = Philips_Thresholding(flt_data);   %%%%% For FFE
% fieldmap = flt_data;                         %%%%% For EPI

return;



%%==========================================================================

function [parms,ver] = read_parfile(file_name) ;

% read all the lines of the PAR file
nlines  = 0;
fid = fopen(file_name,'r');
if (fid < 1), error(['.PAR file ', file_name, ' not found.']); end;
while ~feof(fid)
    curline = fgetl(fid);
    if ~isempty(curline)
        nlines = nlines + 1;
        lines(nlines) = cellstr(curline); % allows variable line size
    end
end
fclose(fid);

% identify the header lines
NG = 0;
for L = 1:size(lines,2)
    curline = char(lines(L));
    if (size(curline,2) > 0 & curline(1) == '.')
       NG = NG + 1;
       geninfo(NG) = lines(L); 
    end
end
if (NG < 1), error('.PAR file has invalid format'); end;

% figure out if V3 or V4 PAR files
test_key = '.    Image pixel size [8 or 16 bits]    :';
if strmatch(test_key,geninfo); % only V3 has that key in the headers
    ver = 'V3';
    template=get_template_v3;
else
    ver = 'V4';
    template=get_template_v4;
end;

% parse the header information
for S=1:size(template,1)
    line_key = char(template(S,1));
    value_type = char(template(S,2));
    field_name = char(template(S,3));
    L = strmatch(line_key,geninfo);

    if ~isempty(L)
        curline = char(geninfo(L));
        value_start = 1 + strfind(curline,':');
        value_end = size(curline,2);
    else
        value_type = ':-( VALUE NOT FOUND )-:';
    end 

    switch (value_type)
    case { 'float scalar' 'int   scalar' 'float vector' 'int   vector'}
         parms.(field_name) = str2num(curline(value_start:value_end));
    case { 'char  scalar' 'char  vector' }
         parms.(field_name) = deblank(strjust(curline(value_start:value_end),'left'));
    otherwise
         parms.(field_name) = '';
    end

end

% parse the tags for each line of data
nimg  = 0;
for L = 1:size(lines,2)
    curline = char(lines(L));
    firstc=curline(1);
    if (size(curline,2) > 0 & firstc ~= '.' & firstc ~= '#' & firstc ~= '*')
       nimg = nimg + 1;
       parms.tags(nimg,:) = str2num(curline);
    end
end
if (nimg < 1), error('Missing scan information in .PAR file'); end;

return;

%==========================================================================

function [image_data,dims] = read_recfile(recfile_name,parms,ver,out_fmt);

types_list = unique(parms.tags(:,5)'); % to handle multiple types
scan_tag_size = size(parms.tags);
nimg = scan_tag_size(1);
nslice = parms.max_slices; 
nphase = parms.max_card_phases;
necho = parms.max_echoes;
ndyn = parms.max_dynamics;
ntype = size(types_list,2);
% no mix# indicated in the tags themselves

if ( isfield(parms,'recon_resolution') )
    nline = parms.recon_resolution(1);
    stride = parms.recon_resolution(2);
else
    nline = parms.tags(1,10);
    stride = parms.tags(1,11);
end

switch(ver)
case {'V3'}, pixel_bits = parms.pixel_bits;
case {'V4'}, pixel_bits = parms.tags(1,8);  % assume same for all imgs
end

switch (pixel_bits)
    case { 8 }, read_type = 'int8';
    case { 16 }, read_type = 'short';
    otherwise, read_type = 'uchar';
end

% read the REC file
fid = fopen(recfile_name,'r','l');
[binary_1D,read_size] = fread(fid,inf,read_type);  %%%%% Running out of Memory Here.
                                                   %%%%% .rec file too big.
fclose(fid);

if (read_size ~= nimg*nline*stride)
    disp(sprintf('Expected %d int.  Found %d int',nimg*nline*stride,read_size));
    if (read_size > nimg*nline*stride)
        error('.REC file has more data than expected from .PAR file')
    else
        error('.REC file has less data than expected from .PAR file')
    end
else
    disp(sprintf('.REC file read sucessfully'));
end

% generate the final matrix of images
dims = [stride nline nslice necho nphase ntype ndyn];
image_data=zeros(dims);
for I  = 1:nimg
    slice = parms.tags(I,1);
    phase = parms.tags(I,4);
    type = parms.tags(I,5);
    type_idx = find(types_list == type);
    echo = parms.tags(I,2);
    dyn = parms.tags(I,3);
    seq = parms.tags(I,6);
    rec = parms.tags(I,7);
    start_image = 1+rec*nline*stride;
    end_image = start_image + stride*nline - 1;
    img = reshape(binary_1D(start_image:end_image),stride,nline);
    % rescale data to produce FP information (not SV, not DV)
    img = permute(rescale_rec(img,parms.tags(I,:),ver,out_fmt), [2 1]);
    image_data(:,:,slice,echo,phase,type_idx,dyn) = img;
end
return;

%==========================================================================

function img = rescale_rec(img,tag,ver,out_fmt)

% transforms SV data in REC files to SV, DV or FP data for output
switch( ver )
case { 'V3' }, ri_i = 8; rs_i = 9; ss_i = 10;
case { 'V4' }, ri_i = 12; rs_i = 13; ss_i = 14;
end;
RI = tag(ri_i);  % 'inter' --> 'RI'
RS = tag(rs_i);  % 'slope' --> 'RS'
SS = tag(ss_i);  % new var 'SS'
switch (out_fmt)
    case { 'FP' }, img = (RS*img + RI)./(RS*SS);
    case { 'DV' }, img = (RS*img + RI);
    case { 'SV' }, img = img;
end

return;

%==========================================================================
function [template] = get_template_v3;  % header information for V3 PAR files

template = { ...                                  
'.    Patient name                       :'    'char  scalar'    'patient';    ...   
'.    Examination name                   :'    'char  scalar'    'exam_name';   ... 
'.    Protocol name                      :'    'char  vector'    'protocol';   ... 
'.    Examination date/time              :'    'char  vector'    'exam_date';  ...
'.    Acquisition nr                     :'    'int   scalar'    'acq_nr';    ...
'.    Reconstruction nr                  :'    'int   scalar'    'recon_nr';  ...
'.    Scan Duration [sec]                :'    'float scalar'    'scan_dur';        ...
'.    Max. number of cardiac phases      :'    'int   scalar'    'max_card_phases'; ...
'.    Max. number of echoes              :'    'int   scalar'    'max_echoes'; ...
'.    Max. number of slices/locations    :'    'int   scalar'    'max_slices'; ... 
'.    Max. number of dynamics            :'    'int   scalar'    'max_dynamics'; ... 
'.    Max. number of mixes               :'    'int   scalar'    'max_mixes'; ... 
'.    Image pixel size [8 or 16 bits]    :'    'int   scalar'    'pixel_bits'; ... 
'.    Technique                          :'    'char  scalar'    'technique'; ...  
'.    Scan mode                          :'    'char  scalar'    'scan_mode'; ... 
'.    Scan resolution  (x, y)            :'    'int   vector'    'scan_resolution'; ... 
'.    Scan percentage                    :'    'int   scalar'    'scan_percentage'; ... 
'.    Recon resolution (x, y)            :'    'int   vector'    'recon_resolution'; ... 
'.    Number of averages                 :'    'int   scalar'    'num_averages'; ... 
'.    Repetition time [msec]             :'    'float scalar'    'repetition_time'; ...   
'.    FOV (ap,fh,rl) [mm]                :'    'float vector'    'fov'; ... 
'.    Slice thickness [mm]               :'    'float scalar'    'slice_thickness'; ...
'.    Slice gap [mm]                     :'    'float scalar'    'slice_gap'; ... 
'.    Water Fat shift [pixels]           :'    'float scalar'    'water_fat_shift'; ... 
'.    Angulation midslice(ap,fh,rl)[degr]:'    'float vector'    'angulation'; ...
'.    Off Centre midslice(ap,fh,rl) [mm] :'    'float vector'    'offcenter'; ... 
'.    Flow compensation <0=no 1=yes> ?   :'    'int   scalar'    'flowcomp'; ...
'.    Presaturation     <0=no 1=yes> ?   :'    'int   scalar'    'presaturation';... 
'.    Cardiac frequency                  :'    'int   scalar'    'card_frequency'; ...
'.    Min. RR interval                   :'    'int   scalar'    'min_rr_interval'; ...
'.    Max. RR interval                   :'    'int   scalar'    'max_rr_interval'; ...
'.    Phase encoding velocity [cm/sec]   :'    'float vector'    'venc'; ... 
'.    MTC               <0=no 1=yes> ?   :'    'int   scalar'    'mtc'; ...
'.    SPIR              <0=no 1=yes> ?   :'    'int   scalar'    'spir'; ...
'.    EPI factor        <0,1=no EPI>     :'    'int   scalar'    'epi_factor'; ...
'.    TURBO factor      <0=no turbo>     :'    'int   scalar'    'turbo_factor'; ...
'.    Dynamic scan      <0=no 1=yes> ?   :'    'int   scalar'    'dynamic_scan'; ...
'.    Diffusion         <0=no 1=yes> ?   :'    'int   scalar'    'diffusion'; ...
'.    Diffusion echo time [msec]         :'    'float scalar'    'diffusion_echo_time'; ...
'.    Inversion delay [msec]             :'    'float scalar'    'inversion_delay'; ...
};

return;

%==========================================================================
function [template] = get_template_v4;    % header information for V4 PAR files

template = { ...                                  
'.    Patient name                       :' 'char  scalar' 'patient';    ...   
'.    Examination name                   :' 'char  vector' 'exam_name';   ... 
'.    Protocol name                      :' 'char  vector' 'protocol';   ... 
'.    Examination date/time              :' 'char  vector' 'exam_date';  ...
'.    Series Type                        :' 'char  vector' 'series_type';  ...
'.    Acquisition nr                     :' 'int   scalar' 'acq_nr';    ...
'.    Reconstruction nr                  :' 'int   scalar' 'recon_nr';  ...
'.    Scan Duration [sec]                :' 'float scalar' 'scan_dur';        ...
'.    Max. number of cardiac phases      :' 'int   scalar' 'max_card_phases'; ...
'.    Max. number of echoes              :' 'int   scalar' 'max_echoes'; ...
'.    Max. number of slices/locations    :' 'int   scalar' 'max_slices'; ... 
'.    Max. number of dynamics            :' 'int   scalar' 'max_dynamics'; ... 
'.    Max. number of mixes               :' 'int   scalar' 'max_mixes'; ... 
'.    Patient position                   :' 'char  vector' 'patient_position'; ... 
'.    Preparation direction              :' 'char  vector' 'preparation_dir'; ... 
'.    Technique                          :' 'char  scalar' 'technique'; ...  
'.    Scan resolution  (x, y)            :' 'int   vector' 'scan_resolution'; ... 
'.    Scan mode                          :' 'char  scalar' 'scan_mode'; ... 
'.    Repetition time [ms]               :' 'float scalar' 'repetition_time'; ...   
'.    FOV (ap,fh,rl) [mm]                :' 'float vector' 'fov'; ... 
'.    Water Fat shift [pixels]           :' 'float scalar' 'water_fat_shift'; ... 
'.    Angulation midslice(ap,fh,rl)[degr]:' 'float vector' 'angulation'; ...
'.    Off Centre midslice(ap,fh,rl) [mm] :' 'float vector' 'offcenter'; ... 
'.    Flow compensation <0=no 1=yes> ?   :' 'int   scalar' 'flowcomp'; ...
'.    Presaturation     <0=no 1=yes> ?   :' 'int   scalar' 'presaturation';... 
'.    Phase encoding velocity [cm/sec]   :' 'float vector' 'venc'; ... 
'.    MTC               <0=no 1=yes> ?   :' 'int   scalar' 'mtc'; ...
'.    SPIR              <0=no 1=yes> ?   :' 'int   scalar' 'spir'; ...
'.    EPI factor        <0,1=no EPI>     :' 'int   scalar' 'epi_factor'; ...
'.    Dynamic scan      <0=no 1=yes> ?   :' 'int   scalar' 'dynamic_scan'; ...
'.    Diffusion         <0=no 1=yes> ?   :' 'int   scalar' 'diffusion'; ...
'.    Diffusion echo time [msec]         :' 'float scalar' 'diffusion_echo_time'; ...
};

return;

%==========================================================================

