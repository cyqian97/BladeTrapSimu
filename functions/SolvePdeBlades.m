function [model, result] = SolvePdeBlades(stlname,mypdeoptions,isoverwrite)
%[model, result] = SolvePdeBlades(stlname,varargin)
%   Solve pde for blade trap model
%   == Input ==
%   sltname : the name for the slt file which contains the model
%   infromation.
%   mypdeoptions : the options for my pde solving functions
dataname = IsExistSolution(stlname,mypdeoptions,0);
if ~isempty(dataname)&& ~isoverwrite
    load(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dataname+".mat"),"result");
    load(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dataname+".mat"),"model");
    return
end


model = createpde();
if isfile(stlname)
    importGeometry(model, stlname);
else
    importGeometry(model, fullfile(getenv('TRAPSIMU'),'stl',stlname));
end

[~,bladesx,cuboidf] =  findfacenameOnlineAll(model);
fprintf(1,'Mesh generation:\n')
tic
generateMesh(model,'Hmax',mypdeoptions.Hmax,'Hmin',mypdeoptions.Hmin,'Hgrad',mypdeoptions.Hgrad);
toc

specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);
applyBoundaryCondition(model,'dirichlet','face',1:model.Geometry.NumFaces,'u',0);
applyBoundaryCondition(model,'neumann','Face',[cuboidf{1};cuboidf{2}],'q',0,'g',0);
for j=[1,5]
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,1}{j},'u',mypdeoptions.Vend);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,2}{j},'u',mypdeoptions.Vend);
end
for j=[2,4]
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,1}{j},'u',mypdeoptions.Vmid);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,2}{j},'u',mypdeoptions.Vmid);
end
for j=3
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,1}{j},'u',mypdeoptions.Vcntr);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,2}{j},'u',mypdeoptions.Vcntr);
end
for j=1:5
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,1}{j},'u',mypdeoptions.Vrf);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,2}{j},'u',mypdeoptions.Vrf);
end

fprintf(1,'PDE solving:\n')
tic
result = solvepde(model);
toc

SavePdeResults(model,result,stlname,mypdeoptions,0)

end

