function dt = SavePdeResults3(model,result,stlname,mypdeoptions)
%SavePdeResults(model,result,stlname,mypdeoptions,iscenter)
%   Save the solution of a pde.

dt = string(datestr(now,'yyyymmdd_HHMMSS'));

%%
expression = 'r(?<r0>[\d.]+)c(?<cntrcap>[\d.]+)m(?<midcap>[\d.]+)g(?<gap>[\d.]+)x(?<x>[\d.]+)y(?<y>[\d.]+)b(?<bladeversion>[\d.]+)';
tokenNames = regexp(stlname,expression,'names');
var_array = "";
var_names = fields(tokenNames);
for i = 1:length(var_names)
    var_array = var_array + var_names{i} +",";
    eval(var_names{i}+"=str2double(tokenNames."+var_names{i}+");");
end

var_names = properties(mypdeoptions);
for i = 1:length(var_names)
    var_array = var_array + var_names{i} +",";
    eval(var_names{i}+"=mypdeoptions."+var_names{i}+";");
end
var_array = char(var_array);
var_array = var_array(1:length(var_array)-1);

%%
if isa(mypdeoptions,'PdeOptionsCube3')
    table_file = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_cube_3.mat');
elseif isa(mypdeoptions,'PdeOptionsBlades3')
    table_file = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_blades_3.mat');
else 
    error('The class of mypdeoptions is wrong!');
end

if isfile(table_file)
    load(table_file,"pde_result_table");
    row_names = pde_result_table.Properties.RowNames;
    eval("cmp = ismember(pde_result_table.Variables,["+var_array+"],'rows');");
    if any(cmp)
        delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+row_names(cmp)+".mat"));
        delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+row_names(cmp)+".mat"));
        row_names{cmp} = char(dt);
        pde_result_table.Properties.RowNames = row_names;
        save(table_file,"pde_result_table");
    else
        eval("T = table("+var_array+",'RowNames',dt);");
        pde_result_table = [pde_result_table; T];
        save(table_file,"pde_result_table");
    end
else
    eval("pde_result_table = table("+var_array+",'RowNames',dt);");
    save(table_file,"pde_result_table");
end

%%
save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dt+".mat"),"result");
save(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dt+".mat"),"model");

end