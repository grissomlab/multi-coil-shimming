% function shimmed = perform_shim(unshimmed,mask,max_current)
% Author: Jason Stockmann
%
function[shimmed,amps,std_unshimmed,std_shimmed] = perform_shim_pinv(unshimmed,mask,coil,max_current)

unshimmed(isnan(unshimmed)) = 0;


nx = numel(coil(:,1,1,1));
ny = numel(coil(1,:,1,1));
nz = numel(coil(1,1,:,1));
nq = numel(coil(1,1,1,:));

unshimmed_vec = mask2vec(unshimmed,mask);
A = mask2vec(coil,mask);
A_all = reshape(coil,[nx*ny*nz nq]);
 

options = optimset('DerivativeCheck','off','GradObj','on','Display','iter-detailed');

% perform shim

% amps = fmincon( @(amps)shim_fun_std(amps,A,unshimmed_vec),zeros(nq,1),[],[],[],[],-max_current*ones(nq,1),max_current*ones(nq,1),[],options);

amps = A\unshimmed_vec;

shimmed = A_all*amps;

shimmed = reshape(shimmed,[nx ny nz]);

shimmed = (unshimmed - shimmed).*double(mask);


shimmed(isnan(shimmed)) = 0;


std_unshimmed = calc_std(unshimmed,mask);
std_shimmed = calc_std(shimmed,mask);

% flip polarity of current setting for shim_fun (double check on shim_fun_std!!!)
amps = -amps;

disp(['standard deviation before shim is ',num2str(mean(std_unshimmed)), ' and after shim is ',num2str(mean(std_shimmed))])








