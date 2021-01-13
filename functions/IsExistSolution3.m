function dt = IsExistSolution3(stlname,mypdeoptions)


dt = '';

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
        dt = string(row_names(cmp));
    end
end

end

