function [rst,mdl] =  PdeCubeIterCompressSchedule(schedule_name,rst)

schedule = [];
schedule = COMSOLdataread(schedule_name);
schedule = schedule';
if isempty(schedule)
    error('Nothing is read from %s',schedule_name);
end
if size(schedule,2)~=10
    error('Incorrect size! schedule should has 9 columns but now it has %d',size(schedule,2));
end
for i = 1:size(schedule,1)
    s = schedule(i,:);
    cuboid=[s(1),s(2),s(3)];
    mesh_finess = [s(4),s(5),s(6)];
    [rst,mdl] = pde_cubeiter_compress(rst,cuboid,mesh_finess,s(7),s(8),s(9),s(10));
end


end