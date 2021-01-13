function DeleteResultName(dataname)
%DeleteResultName(dataname)
%   Delete .mat data and the record in pde_result_table by data name.

table_file = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_blades_2.mat');
load(table_file,"pde_result_table");
row_names = pde_result_table.Properties.RowNames;
if ismember(row_names,dataname)
    pde_result_table(dataname,:) = [];
    save(table_file,"pde_result_table");
    delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dataname+".mat"));
    delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dataname+".mat"));
    return
end

table_file = fullfile(getenv('TRAPSIMU'),'results','pdesolutions','pde_solution_cube_2.mat');
load(table_file,"pde_result_table");
row_names = pde_result_table.Properties.RowNames;
if ismember(row_names,dataname)
    pde_result_table(dataname,:) = [];
    save(table_file,"pde_result_table");
    delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dataname+".mat"));
    delete(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dataname+".mat"));
    return
end

error("Cannot find "+dataname+"!");

end