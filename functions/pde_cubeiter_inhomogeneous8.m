function [model, result_struct] = pde_cubeiter_inhomogeneous8(stlname,mypdeoptions,result,varargin)
%[result, model] = pde_cubeiter_inhomogeneous7(result,stlname,mypdeoptions,varargin)
%  PDE_CUBEITER Iteratively refine 3d pde solutions
%   == Input ==
%   result : the solution of the previous pde.
%   sltname : the name for the slt file which is used in the previous pde.
%   mypdeoptions : the options for my pde solving functions
%   == Name-Value Pairs ==
%   isprint : Print the progress of this function if it is true. Defualt =
%   true
%   overwrite : Overwrite the existing data if is true, otherwise load the
%   existing data without solving the pde. Defualt = false.
%   savedata : Sava solution to .mat file if is true. Defualt = true.
%   symmetrize : Symmetrize the boundary condition if is true. Default =
%   false;
p = inputParser;
addParameter(p,'loaddata',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'loaddata'));
addParameter(p,'savedata',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'savedata'));
addParameter(p,'isprint',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'isprint'));
parse(p,varargin{:});
loaddata = p.Results.loaddata;
savedata = p.Results.savedata;
isprint = p.Results.isprint;

dataname = IsExistSolution3(stlname,mypdeoptions);
if ~isempty(dataname)&& loaddata
    load(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dataname+".mat"),"result");
    load(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dataname+".mat"),"model");
    result_struct.result = result;
    result_struct.dataname = dataname;
    return
end

cube = mypdeoptions.cube;
iter = mypdeoptions.iter;
reduce = mypdeoptions.reduce;
interp_fineness = mypdeoptions.interp_fineness;
mesh_fineness = mypdeoptions.mesh_fineness;

for j = 1:iter
    if isprint
        fprintf(1,'Start iteration %d\n',j)
    end
    if isprint
        fprintf(1,'Mesh generation time:')
        tic
    end
    
    model = MeshCompress3(cube,mesh_fineness);
    if isprint
        t = toc;
        fprintf(1,' %.3f s\n',t)
    end
    %% Create boundary condition (z- z+ x- x+ y- y+)
    lin = {linspace(-cube(1)/2,cube(1)/2,interp_fineness(1));linspace(-cube(2)/2,cube(2)/2,interp_fineness(2));linspace(-cube(3)/2,cube(3)/2,interp_fineness(3))};
    k=1;
    if isprint
        fprintf(1,'Boudary conditon interpolation start.\n')
        tic
    end
    if isprint
        fprintf(1,'Interpolating boundary condition %d.\n',k)
    end
    cart = ["x","y","z"];
    for i = 0:2
        for m = [-1,1]
            [aa,bb] = ndgrid(lin{mod(i,3)+1},lin{mod(i+1,3)+1});
            cc = ones(size(aa))*m*cube(mod(i+2,3)+1)/2;
            temp = {aa,bb,cc};
            xx = temp{mod(-i,3)+1};
            yy = temp{mod(-i+1,3)+1};
            zz = temp{mod(-i+2,3)+1};            
            if mypdeoptions.symmetrize
                ss = reshape((interpolateSolution(result,xx,yy,zz)+interpolateSolution(result,-xx,yy,zz))/2,size(xx));
            else
                ss = reshape(interpolateSolution(result,xx,yy,zz),size(xx));
            end
            eval("fint"+num2str(k)+" = griddedInterpolant(aa,bb,ss,'spline');");
            eval("fbnd"+num2str(k)+"=@(location,state)fint"+num2str(k)+"(location."+cart(mod(i,3)+1)+",location."+cart(mod(i+1,3)+1)+");")
            k=k+1;
            if k<7
                if isprint
                    fprintf(1,'Interpolating boundary condition %d.\n',k)
                end
            end
        end
    end
    
    names = findfacename_boundary(model);
    applyBoundaryCondition(model,'dirichlet','face',names(1),'u',fbnd1,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',names(2),'u',fbnd2,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',names(3),'u',fbnd3,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',names(4),'u',fbnd4,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',names(5),'u',fbnd5,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',names(6),'u',fbnd6,'Vectorized','on');
    specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);
    
    if isprint
        t= toc;
        fprintf(1,'Boudary conditon interpolation time: %.3f s\n',t)
        fprintf(1,'Pde solving time:')
        tic
    end
    
    results = solvepde(model);
    if isprint
        t= toc;
        fprintf(1,' %.3f s\n',t)
    end
    
    result = results;
    cube = cube./reduce;
end

if savedata
    dataname = SavePdeResults3(model,result,stlname,mypdeoptions);
end

result_struct.result = result;
result_struct.dataname = dataname;

end