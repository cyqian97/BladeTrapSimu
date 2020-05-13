function SavePdeResults(model,result,stlname,mypdeoptions,iscenter)
%SavePdeResults(model,result,stlname,mypdeoptions,iscenter)
%   Save the solution of a pde.

dt = string(datestr(now,'yyyymmdd_HHMMSS'));

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
            delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+row_names(cmp)+".mat"));
            delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+row_names(cmp)+".mat"));
            row_names{cmp} = char(dt);
            pde_result_table_center.Properties.RowNames = row_names;
            save(table_name,"pde_result_table_center");
        else
            T = table(r0,cntrcap,midcap,gap,x,y,bladeversion, ...
                Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf,cube,iter,reduce,interp_fineness,mesh_fineness,'RowNames',dt);
            pde_result_table_center = [pde_result_table_center;T];
            save(table_name,"pde_result_table_center");
        end
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dt+".mat"),"result");
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dt+".mat"),"model");
    else
        pde_result_table_center = table(r0,cntrcap,midcap,gap,x,y,bladeversion, ...
            Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf,cube,iter,reduce,interp_fineness,mesh_fineness,'RowNames',dt);
        save(table_name,"pde_result_table_center");
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dt+".mat"),"result");
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dt+".mat"),"model");
    end
else
    table_name = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_whole.mat');
    if isfile(table_name)
        load(table_name,"pde_result_table_whole");
        row_names = pde_result_table_whole.Properties.RowNames;
        cmp = ismember(pde_result_table_whole.Variables,[r0,cntrcap,midcap,gap,x,y,bladeversion,Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf],'rows');
        if any(cmp)
            delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+row_names(cmp)+".mat"));
            delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+row_names(cmp)+".mat"));
            row_names{cmp} = char(dt);
            pde_result_table_whole.Properties.RowNames = row_names;
            save(table_name,"pde_result_table_whole");
        else
            T = table(r0,cntrcap,midcap,gap,x,y,bladeversion,Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf,'RowNames',dt);
            pde_result_table_whole = [pde_result_table_whole;T];
            save(table_name,"pde_result_table_whole");
        end
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dt+".mat"),"result");
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dt+".mat"),"model");
    else
        pde_result_table_whole = table(r0,cntrcap,midcap,gap,x,y,bladeversion,Hmax,Hmin,Hgrad,Vend,Vmid,Vcntr,Vrf,'RowNames',dt);
        save(table_name,"pde_result_table_whole");
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dt+".mat"),"result");
        save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dt+".mat"),"model");
    end
end
end