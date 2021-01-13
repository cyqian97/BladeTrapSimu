function [model, result_struct] = SolvePdeBlades2(stlname,pdeoptionsblades,varargin)
%[model, result] = SolvePdeBlades(stlname,varargin)
%   Solve pde for blade trap model
%   == Input ==
%   sltname : the name for the slt file which contains the model
%   infromation.
%   mypdeoptions : the options for my pde solving functions
%   p_result(optional) : the solution of the previous pde.
%   == Name-Value Pairs ==
%   isprint : Print the progress of this function if it is true. Defualt =
%   true
%   overwrite : Overwrite the existing data if is true, otherwise load the
%   existing data without solving the pde. Defualt = false.
%   savedata : Sava solution to .mat file if is true. Defualt = true.
%   neumann : Use neamann boundary condition a x = x_min and x = x_max
%   faces if is true. Use dirichlet otherwise. Default = true.
%   loadname : Load dataname only if is true, otherwise load also result
%   and model. Default = false.
%   interp_rate : Fineness of the boundary condition interpolation. Default
%   = 3.
%   symmetrize : Symmetrize the boundary condition if is true. Default =
%   false;

p = inputParser;
addOptional(p,'p_result',[],@(x) validateattributes(x,{'pde.StationaryResults'},{'scalar'},mfilename,'p_result'));
addParameter(p,'isprint',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'isprint'));
addParameter(p,'overwrite',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'overwrite'));
addParameter(p,'savedata',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'savedata'));
addParameter(p,'neumann',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'neumann'));
addParameter(p,'loadname',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'loadname'));
addParameter(p,'interp_rate',3,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'interp_rate'));
addParameter(p,'symmetrize',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'symmetrize'));
parse(p,varargin{:});

isprint = p.Results.isprint;
p_result = p.Results.p_result;
overwrite = p.Results.overwrite;
savedata = p.Results.savedata;
interp_rate = p.Results.interp_rate;

if isempty(p_result) && ~isempty(char(pdeoptionsblades.parent))
    error('No p_result input. The parent property of pdeoptionsblades should be empty');
end

dataname = IsExistSolution2(stlname,pdeoptionsblades);

if ~isempty(dataname)&& ~overwrite
    if p.Results.loadname
        model = [];
        result_struct.dataname = dataname;
        result_struct.result = pde.StationaryResults;
        return
    else
        load(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"result_"+dataname+".mat"),"result");
        load(fullfile(getenv('TRAPSIMU'),'results','pdesolutions',"model_"+dataname+".mat"),"model");
        result_struct.result = result;
        result_struct.dataname = dataname;
        return
    end
end


model = createpde();
if isfile(stlname)
    importGeometry(model, stlname);
else
    importGeometry(model, fullfile(getenv('TRAPSIMU'),'stl',stlname));
end

[cuboid,bladesx,cuboidf] =  findfacenameOnlineAll(model);
cube = cuboid(1,:)-cuboid(2,:);

if isprint
    fprintf(1,'Mesh generation time:')
    tic
end
generateMesh(model,'Hmax',pdeoptionsblades.Hmax,'Hmin',pdeoptionsblades.Hmin,'Hgrad',pdeoptionsblades.Hgrad);
if isprint
    t = toc;
    fprintf(1,' %.3f s\n',t)
end
specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);
applyBoundaryCondition(model,'dirichlet','face',1:model.Geometry.NumFaces,'u',0);
for j=[1,5]
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,1}{j},'u',pdeoptionsblades.Vend);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,2}{j},'u',pdeoptionsblades.Vend);
end
for j=[2,4]
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,1}{j},'u',pdeoptionsblades.Vmid);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,2}{j},'u',pdeoptionsblades.Vmid);
end
for j=3
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,1}{j},'u',pdeoptionsblades.Vcntr);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,2}{j},'u',pdeoptionsblades.Vcntr);
end
for j=1:5
    applyBoundaryCondition(model,'dirichlet','face',bladesx{1,1}{j},'u',pdeoptionsblades.Vrf);
    applyBoundaryCondition(model,'dirichlet','face',bladesx{2,2}{j},'u',pdeoptionsblades.Vrf);
end
if isempty(p_result)
    if p.Results.neumann
        applyBoundaryCondition(model,'neumann','Face',[cuboidf{1};cuboidf{2}],'q',0,'g',0);
    end
else
    lin = {linspace(cuboid(2,1),cuboid(1,1),interp_rate*(cuboid(1,1)-cuboid(2,1))/pdeoptionsblades.Hmax); ...
        linspace(cuboid(2,2),cuboid(1,2),interp_rate*(cuboid(1,2)-cuboid(2,2))/pdeoptionsblades.Hmax); ...
        linspace(cuboid(2,3),cuboid(1,3),interp_rate*(cuboid(1,3)-cuboid(2,3))/pdeoptionsblades.Hmax)};
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
        for j = [-1,1]
            [aa,bb] = ndgrid(lin{mod(i,3)+1},lin{mod(i+1,3)+1});
            cc = ones(size(aa))*j*cube(mod(i+2,3)+1)/2;
            temp = {aa,bb,cc};
            xx = temp{mod(-i,3)+1};
            yy = temp{mod(-i+1,3)+1};
            zz = temp{mod(-i+2,3)+1};
            if p.Results.symmetrize
                ss = reshape((interpolateSolution(p_result,xx,yy,zz)+interpolateSolution(p_result,-xx,yy,zz))/2,size(xx));
            else
                ss = reshape(interpolateSolution(p_result,xx,yy,zz),size(xx));
            end
            nonan = ~isnan(ss);
            eval("fint"+num2str(k)+" = scatteredInterpolant(aa(nonan),bb(nonan),ss(nonan),'natural','linear');");
            eval("fbnd"+num2str(k)+"=@(location,state)fint"+num2str(k)+"(location."+cart(mod(i,3)+1)+",location."+cart(mod(i+1,3)+1)+");")
            k=k+1;
            if k<7
                if isprint
                    fprintf(1,'Interpolating boundary condition %d.\n',k)
                end
            end
        end
    end
    applyBoundaryCondition(model,'dirichlet','face',cuboidf{5},'u',fbnd1,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',cuboidf{6},'u',fbnd2,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',cuboidf{1},'u',fbnd3,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',cuboidf{2},'u',fbnd4,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',cuboidf{3},'u',fbnd5,'Vectorized','on');
    applyBoundaryCondition(model,'dirichlet','face',cuboidf{4},'u',fbnd6,'Vectorized','on');
    if isprint
        t= toc;
        fprintf(1,'Boudary conditon interpolation time: %.3f s\n',t)
    end
end
if isprint
    fprintf(1,'Pde solving time:')
    tic
end
result = solvepde(model);
if isprint
    toc
end
if savedata
    dataname = SavePdeResults2(model,result,stlname,pdeoptionsblades);
end

result_struct.result = result;
result_struct.dataname = dataname;

end

