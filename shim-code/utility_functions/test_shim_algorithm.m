%% Test Shim algorithm

test_coils(:,:,:,1) = right_coil_Bz_interp;
test_coils(:,:,:,2) = left_coil_Bz_interp;
test_coils(:,:,:,3) = top_coil_Bz_interp;

test_total_Bz = load('.\coil_simulated_fields\test_MC_B0.mat', '-ascii');     
test_total_Bz = interpolate_field_matrix(reorient_coil_matrix(test_total_Bz));

[test_shimmed, test_amps, test_std_unshimmed, test_std_shimmed] = perform_shim_V1(test_total_Bz, ones(160,70,160) ,test_coils, [15 15 15], 100);



%% Unconstrained shimming using pseudoinverse

% SH only
[SH_shimmed_pinv, SH_amps_pinv, SH_std_unshimm_pinv, SH_std_shim_pinv] = perform_shim_pinv(b0_interp_unshimmed,NHP_brain_mask,SH_shims,0);

% MC only
[MC_shimmed_pinv, MC_amps_pinv, MC_std_unshimm_pinv, MC_std_shim_pinv] = perform_shim_pinv(b0_interp_unshimmed,NHP_brain_mask,MC_shims,0);

% MC + SH
SH_and_MC_shims = cat(4,SH_shims, MC_shims);
[SH_MC_shimmed_pinv, SH_MC_amps_pinv, SH_MC_std_unshimm_pinv, SH_MC_std_shim_pinv] = perform_shim_pinv(b0_interp_unshimmed,NHP_brain_mask,SH_and_MC_shims,0);
