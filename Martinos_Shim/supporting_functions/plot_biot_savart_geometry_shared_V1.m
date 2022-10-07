function plot_biot_savart_geometry_shared_V1(filename,coils_used)
%%%%%%%%%%%set up current %%%%%%%%%%%%%%



% code for generating the mask normals
% vec = 
% [69  -105 -201
% 35  -107 -149
% 38  -104 -90
% 81  -78  -156
% -69 -107 -199
% -36 -108 -149
% -38 -104 -90
% -80 -77  -157]
% vec2 = [vec] + [vec(:,1)*1.5 vec(:,2)*1.5 vec(:,3)]
% for vv=1:8, v(2*vv-1,:) = vec(vv,:); v(2*vv,:) = vec2(vv,:); end


[cx,cy,cz]=textread([filename,'.txt'],'%f %f %f');

ind = 0;  ind2 = 0; red_ind = zeros(sum(coils_used),1);
for ii = 1:numel(coils_used)
   ind2=ind2+1;
    if coils_used(ii) == 1
            ind = ind + 1;

        cxt(2*ind-1:2*ind) = cx(2*ii-1:2*ii);
        cyt(2*ind-1:2*ind) = cy(2*ii-1:2*ii);
        czt(2*ind-1:2*ind) = cz(2*ii-1:2*ii);
      
    end
      if ii>32
         red_ind(ind) = 1
      end

end

cx = cxt.';
cy = cyt.';
cz = czt.';

% cx = 1.05*cx;   cy = 1.05*cy;  cz = 1.05*cz;

%cy=cy.*-1; % uncomment to reverse y direction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ports=numel(cx)/2; % number of channels (for some reason, 36 channels are in the data file)
faceloop_radius = 32.5;   % mm
faceloop_number_of_turns = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

div=64 % approx. circular coil by div line segments; make larger for more accuracy
circle_radius=45; % radius hard-coded
% circle_radius=45-19; % radius hard-coded second version (8/21/2014) to match array in Keil et al, MRM, 2012

V=[cx(1:2:end),cy(1:2:end),cz(1:2:end)];
N=V-[cx(2:2:end),cy(2:2:end),cz(2:2:end)];
circle_radius=repmat(circle_radius,[ports, 1]);

ind = 0;
for qq=1:numel(coils_used)
    if coils_used(qq) == 1; ind = ind + 1; if qq > 31, circle_radius(ind) = faceloop_radius; end, end
    
end



T=zeros(4,4);
for p=1:ports
    phi=atan(sqrt(N(p,1)^2+N(p,2)^2)/N(p,3));
    the=atan2(N(p,1),N(p,2));
    
    t_x=[1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
    t_z=[cos(the) sin(the) 0;-sin(the) cos(the) 0;0 0 1];
    
    T(4,:)=[0 0 0 1];
    T(1:3,4)=V(p,:)';
    T(1:3,1:3)=t_z*t_x;
    
    for d=1:div
        circle{d}.start=[cos(2*pi/div*d), sin(2*pi/div*d), 0].*circle_radius(p);
        circle{d}.stop=[cos(2*pi/div*(d+1)), sin(2*pi/div*(d+1)), 0].*circle_radius(p);
    end;

    for d=1:div
        cc1=T*[circle{d}.start 1]';
        current{p,d}.start=cc1(1:3)';
        cc2=T*[circle{d}.stop 1]';        
        current{p,d}.stop=cc2(1:3)';
    end;
end;


coil_x=max(V(:,1))-min(V(:,1));
coil_y=max(V(:,2))-min(V(:,2));
coil_z=max(V(:,3))-min(V(:,3));




[vertex_os,face_os]=inverse_read_tri('outer_skull642.tri');
vertex_os(:,2)=vertex_os(:,2).*-1;

phi=0./180*pi;
the=3./180*pi;
t_x=[1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
t_z=[cos(the) sin(the) 0;-sin(the) cos(the) 0;0 0 1];

vertex_os=vertex_os*t_x'*t_z';

tri=delaunay(vertex_os(:,1),vertex_os(:,2),vertex_os(:,3));

brain_x=max(vertex_os(:,1))-min(vertex_os(:,1));
brain_y=max(vertex_os(:,2))-min(vertex_os(:,2));
brain_z=max(vertex_os(:,3))-min(vertex_os(:,3));

% uncomment to recenter brain
% vertex_os(:,1)=vertex_os(:,1)+5;
% vertex_os(:,2)=vertex_os(:,2)-10;
% vertex_os(:,3)=vertex_os(:,3)+(max(V(:,3))-max(vertex_os(:,3)))+70;

% rescale brain to fit inside coils
vertex_os=vertex_os.*0.95;

% figure;
hold on
p=patch('Faces',face_os,...
	'Vertices',vertex_os,...
	'EdgeColor',[0.6 0.6 0.6],...
	'FaceColor',[0.8 0.8 0.8],...
	'FaceLighting', 'flat',...
	'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
	'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);
hold on;

for p=1:ports
    for d=1:div
        h=line([current{p,d}.start(1);current{p,d}.stop(1)],[current{p,d}.start(2);current{p,d}.stop(2)],[current{p,d}.start(3);current{p,d}.stop(3)]);
        set(h,'LineWidth',2)
        
        if red_ind(p) == 1
                set(h,'Color','b')
        else 
            set(h,'Color','b')
        end
           
    end;
    title(['element ', num2str(p)])
        

end;
set(h,'color',[0 0 1]);
set(h,'linewidth',3);
grid on;
axis tight equal;

pause(.1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    setup FOV for B1 calclation                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('CREATING FOV...\n');
% 
% % hard code FOV and resolution; change to match real acquisition parameters
% dim_y_start=-120+1.2;
% dim_y_stop=120-1.2;
% dim_y_mat=100;
% dim_y_skip=(dim_y_stop-dim_y_start)./(dim_y_mat-1);
% dim_y=[dim_y_start:dim_y_skip:dim_y_stop];
% 
% dim_x_start=-120+1.2; 
% dim_x_stop=120-1.2;
% dim_x_mat=100;
% dim_x_skip=(dim_x_stop-dim_x_start)./(dim_x_mat-1);
% dim_x=[dim_x_start:dim_x_skip:dim_x_stop];
% 
% 
% dim_z_start=-61+20;
% dim_z_stop=61+20;
% dim_z_mat=62;
% dim_z_skip=(dim_z_stop-dim_z_start)./(dim_z_mat-1);
% dim_z=[dim_z_start:dim_z_skip:dim_z_stop];
% 
% [fov_y,fov_x,fov_z]=ndgrid(dim_y,dim_x,dim_z);
% 
% fov_grid=[fov_x(1:prod(size(fov_x)))', fov_y(1:prod(size(fov_y)))', fov_z(1:prod(size(fov_z)))'];
% 
% 
% 
% 
% 
% 
% 
% % intersect FOV with brain mesh
% [k,d]=dsearchn(vertex_os,tri,fov_grid);
% v=zeros(size(k));
% v(find(d<10))=1;
% vv=reshape(v,[length(dim_y),length(dim_x),length(dim_z)]);
% for s=1:size(vv,3)
% 	mask(:,:,s)=imfill(im2bw(vv(:,:,s)),'holes');
% end;
% mask=double(mask);
% save mask84.mat mask;
% 
% %slice(fov_x,fov_y,fov_z,vv,[],[],30); %z=0 plane
% %axis tight equal;
% 
% 
% % ASSUMES that pixels in "img" are isotropic!
% 
% 
% %%%%%%%%%%% Biot-Savart's law %%%%%%%%%%%%%%
% fprintf('CALCULATING B1...\n');
% clear cc;
% for p=1:size(current,1)
%     fprintf('port [%d]...\n',p);
%     for x=1:size(current,2)
%         cc{x}=current{p,x};
%     end;
%     b1=b1sim_dc_core(cc,fov_grid);
% 
% %     b1_abs(:,:,:,p)=squeeze(sqrt(sum(b1.^2,2)));
% %     b1_x(:,:,:,p)=reshape(b1(:,1),[length(dim_y),length(dim_x),length(dim_z)]).*mask;
% %     b1_y(:,:,:,p)=reshape(b1(:,2),[length(dim_y),length(dim_x),length(dim_z)]).*mask;
% %     b1_z(:,:,:,p)=reshape(b1(:,3),[length(dim_y),length(dim_x),length(dim_z)]).*mask;
% 
%     b1_x(:,:,:,p)=reshape(b1(:,1),[length(dim_y),length(dim_x),length(dim_z)]);
%     b1_y(:,:,:,p)=reshape(b1(:,2),[length(dim_y),length(dim_x),length(dim_z)]);
%     b1_z(:,:,:,p)=reshape(b1(:,3),[length(dim_y),length(dim_x),length(dim_z)]);
%     b1_effect(:,:,:,p)=b1_x(:,:,:,p)+sqrt(-1.0).*b1_y(:,:,:,p);
% end;
% 
% b1_effect_total=squeeze(sqrt(sum(abs(b1_effect).^2,4)));
% 
% %%%%%%%%%%% formating b1 %%%%%%%%%%%%%%
% figure;
% slice(fov_x,fov_y,fov_z,b1_effect_total,[],[],30); %z=0 plane; can change arguments to plot different slices
% caxis([0,1e-8]);
% %colormap(gray);
% 
% % draw loops
% hold on;
% for p=1:ports
%     for d=1:div
%         h=line([current{p,d}.start(1);current{p,d}.stop(1)],[current{p,d}.start(2);current{p,d}.stop(2)],[current{p,d}.start(3);current{p,d}.stop(3)]);
%         set(h,'color',[0 0 1]);
%         set(h,'linewidth',3);
%     end;
% end;
% hold off;
% axis equal;
% 
% if faceloop_number_of_turns > 1
%    
%     b1_z(:,:,:,33:end) = faceloop_number_of_turns*b1_z(:,:,:,33:end);
%     
% end
% %%%%%%%%%%% save data %%%%%%%%%%%%%%
% %save b1sim_dc_array_circle32.mat b1_effect
% save([output_stem,'.mat'], 'b1_z', 'fov_x', 'fov_y', 'fov_z')

