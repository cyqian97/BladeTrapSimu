function dt = IsExistSolution(stlname,mypdeoptions,iscenter)
dt = '';

expression = 'r(?<r0>[\d.]+)c(?<cntrcap>[\d.]+)m(?<midcap>[\d.]+)g(?<gap>[\d.]+)x(?<x>[\d.]+)y(?<y>[\d.]+)b(?<bladeversion>[\d.]+)';
tokenNames = regexp(stlname,expression,'names');
r0 = str2double(tokenNames.r0)/1000;
cntrcap = str2double(tokenNames.cntrcap)/1000;
midcap = str2double(tokenNames.midcap)/1000;
gap = str2double(tokenNames.gap)/1000;
x = str2double(tokenNames.x);
y = str2double(tokenNames.y);
bladeversion = string(tokenNames.bladeversion);
var_names = properties(mypdeoptions);

for i = 1:length(var_names)
    eval(var_names{i}+"=mypdeoptions."+var_names{i}+";");
end

if iscenter
    table_name = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_center.mat');
    if isfile(table_name)
        load(table_name,"pde_result_table_center");
        row_names = pde_result_table_center.Properties.RowNames;
        cmp = ismember(pde_result_table_center.Variables,[r0,cntrcap,midcap,gap,x,y,bladeversion, ...
            Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf,cube,iter,reduce,interp_fineness,mesh_fineness],'rows');
        if any(cmp)
            dt = row_names(cmp);
        end
    end
else
    table_name = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_whole.mat');
    if isfile(table_name)
        load(table_name,"pde_result_table_whole");
        row_names = pde_result_table_whole.Properties.RowNames;
        cmp = ismember(pde_result_table_whole.Variables,[r0,cntrcap,midcap,gap,x,y,bladeversion, ...
            Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf],'rows');
        if any(cmp)
            dt = row_names(cmp);
        end
    end
end


end

