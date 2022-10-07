function [shimmed,amps,db0,mask] = perform_shim_ncc(unshimmed,mask,coil,max_current,total_current,opts)
tic;
unshimmed(isnan(unshimmed)) = 0;

freeb0 = false;
if length(opts)>=3
    freeb0 = opts{3};
end

nx = numel(coil(:,1,1,1));
ny = numel(coil(1,:,1,1));
nz = numel(coil(1,1,:,1));
nq = numel(coil(1,1,1,:));

unshimmed_vec = mask2vec(unshimmed,mask==1);
% coil(:,:,:,60:end) = 0;
A = mask2vec(coil,mask==1);
A_all = reshape(coil,[nx*ny*nz nq]);
% A( :, ~any(A,1) ) = [];
% A_all( :, ~any(A_all,1) ) = [];
nq = size(A,2);

% perform shim

%  amps = fmincon( @(amps)shim_fun(amps,A,unshimmed_vec),zeros(nq,1),[],[],[],[],-max_current*ones(nq,1),...
%      max_current*ones(nq,1),@(amps)first_order_norm(amps,total_current),options);
% amps = quadprog(A'*A,-A'*unshimmed_vec,[],[],[],[],-max_current*ones(nq,1),max_current*ones(nq,1))
v = [ones(nq,1);-ones(nq,1)];
B = diag(v,0)+diag(v(nq+1:end),nq)+diag(v(nq+1:end),-nq);
Ap = [A,zeros(size(A,1),nq)];
options = optimoptions('quadprog','Display','off');
alpha = 1000;
if (~freeb0)
amps = quadprog(Ap'*Ap+alpha*blkdiag(zeros(size(A,2)),eye(size(A,2))),-(Ap)'*unshimmed_vec,...
    [[zeros(1,nq),ones(1,nq)];100*B],[total_current;zeros(nq*2,1)],...
    [],[],-max_current*ones(2*nq,1), max_current*ones(2*nq,1),[]);
else
% amps = [A;30*eye(32)]\[unshimmed_vec;zeros(32,1)];
% free B0
    Ap = [A,zeros(size(A,1),nq),ones(size(A,1),1)];
    amps = quadprog(Ap'*Ap+alpha*blkdiag(zeros(size(A,2)),eye(size(A,2)),0),-(Ap)'*unshimmed_vec,[[[zeros(1,nq),ones(1,nq)];100*B], zeros(nq*2+1,1)],[total_current;zeros(nq*2,1)],[],[],[-max_current*ones(2*nq,1);-1e5], [max_current*ones(2*nq,1);1e5]);
end
db0 = 0;

amps = amps(1:nq);
shimmed = A_all*amps;

shimmed = reshape(shimmed,[nx ny nz]);

shimmed = (unshimmed - shimmed);

if(freeb0)
    shimmed = shimmed-mean(mask2vec(shimmed,mask==1));
end

% flip polarity of c14urrent setting for shim_fun (double check on shim_fun_std!!!)
amps = double(-amps);

toc;






