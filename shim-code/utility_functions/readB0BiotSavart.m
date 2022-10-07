function coil_struct = readB0BiotSavart(file_name,coil_name)

%READB0BIOTSAVART: Reads in an export file from Biot Savart software 
% Pre: txt file from Biot Savart sofwtare containing the x,y,z coordinates
% and the resulting magnetic field components and magnitude

export = load(file_name,'-ascii');

x = export(:,1);
y = export(:,2);
z = export(:,2);

Bx = export(:,3);
By = export(:,4);
Bz = export(:,5);
B_magnitude = export(:,end);

coil_struct = struct('name',{coil_name},'coordinates', [x y z], 'B0_components',[Bx By Bz], 'B0_magnitude',[B_magnitude]);

end

