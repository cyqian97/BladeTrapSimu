function [results, model] = pde_cubeiter_compress(results,cuboid,mesh_finess,reduce,iter,interp_finess,hgrad,varargin)
%  PDE_CUBEITER Iteratively refine 3d pde solutions

if isempty(varargin)
    isprint = 0;
else
    isprint = 1;
end

if reduce<=0
    error('reduce should > 0 but now is %f',reduce)
end

for j = 1:iter
    if isprint
        fprintf(1,'Start iteration %d\n',j)
    end
    temp_model = createpde();
    temp_gm = multicuboid(mesh_finess(1),mesh_finess(2),mesh_finess(3),'Zoffset',-mesh_finess(3)/2);
    temp_model.Geometry = temp_gm;
    if isprint
        fprintf(1,'Mesh generation time:')
    end
    tic
    mesh_raw = generateMesh(temp_model,'Hmax',1,'Hmin',0.01,'Hgrad',hgrad);
    t = toc;
    if isprint
        fprintf(1,' %.3f s\n',t)
    end
    nodes = [mesh_raw.Nodes(1,:)/mesh_finess(1)*cuboid(1);mesh_raw.Nodes(2,:)/mesh_finess(2)*cuboid(2);mesh_raw.Nodes(3,:)/mesh_finess(3)*cuboid(3)];
    elements = mesh_raw.Elements;
    
    model = createpde();
    geometryFromMesh(model,nodes,elements);

    %% Create boundary condition (z- z+ x- x+ y- y+)
    if isprint
        fprintf(1,'Boudary conditon interpolation start.\n')
    end
    tic
    lin = [linspace(-cuboid(1)/2,cuboid(1)/2,interp_finess);linspace(-cuboid(2)/2,cuboid(2)/2,interp_finess);linspace(-cuboid(3)/2,cuboid(3)/2,interp_finess)];
    k=1;
    if isprint
        fprintf(1,'Interpolating boundary condition %d.\n',k)
    end
    cart = ["x","y","z"];
    for i = 0:2
        for j = [-1,1]
            [aa,bb] = meshgrid(lin(mod(i,3)+1,:),lin(mod(i+1,3)+1,:));
            cc = ones(size(aa))*j*cuboid(mod(i+2,3)+1)/2;
            temp = {aa,bb,cc};
            xx = temp{mod(-i,3)+1};
            yy = temp{mod(-i+1,3)+1};
            zz = temp{mod(-i+2,3)+1};
            ss = griddata(results.Mesh.Nodes(1,:),results.Mesh.Nodes(2,:),results.Mesh.Nodes(3,:),results.NodalSolution, ...
                xx,yy,zz,"natural");
            eval("fint"+num2str(k)+" = scatteredInterpolant(aa(:),bb(:),ss(:),'natural');");
            eval("fbnd"+num2str(k)+"=@(location,state)fint"+num2str(k)+"(location."+cart(mod(i,3)+1)+",location."+cart(mod(i+1,3)+1)+");")
            k=k+1;
            if k<7
                if isprint
                    fprintf(1,'Interpolating boundary condition %d.\n',k)
                end
            end
        end
    end
    t= toc;
    if isprint
        fprintf(1,'Boudary conditon interpolation time: %.3f s\n',t)
    end
    names = findfacename_boundary(model);
    applyBoundaryCondition(model,'dirichlet','face',names(1),'u',fbnd1);
    applyBoundaryCondition(model,'dirichlet','face',names(2),'u',fbnd2);
    applyBoundaryCondition(model,'dirichlet','face',names(3),'u',fbnd3);
    applyBoundaryCondition(model,'dirichlet','face',names(4),'u',fbnd4);
    applyBoundaryCondition(model,'dirichlet','face',names(5),'u',fbnd5);
    applyBoundaryCondition(model,'dirichlet','face',names(6),'u',fbnd6);
    specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);

    if isprint
        fprintf(1,'Pde solving time:')
    end
    tic
    results2 = solvepde(model);
    t= toc;
    if isprint
        fprintf(1,' %.3f s\n',t)
    end
    % pdeplot3D(model,"ColorMapData",results2.NodalSolution)
    
    results = results2;
    cuboid = cuboid./reduce;
end
end