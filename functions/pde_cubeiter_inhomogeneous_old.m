function [results, model] = pde_cubeiter_inhomogeneous_old(results,cube,reduce,iter,interp_fineness,mesh_fineness,varargin)
%  PDE_CUBEITER Iteratively refine 3d pde solutions

if isempty(varargin)
    isprint = 0;
else
    isprint = 1;
end

for j = 1:iter
    if isprint
        fprintf(1,'Start iteration %d\n',j)
    end
    model = createpde();
    gm = multicuboid(cube(1),cube(2),cube(3),'Zoffset',-cube(3)/2);
    model.Geometry = gm;
    if isprint
        fprintf(1,'Mesh generation time:')
        tic
    end
    model = MeshCompress2(model,mesh_fineness);
    
%     model = MeshCompress3(cube,mesh_fineness);
%     generateMesh(model,'Hmax',0.005,'Hmin',0.00005,'Hgrad',1.2);
    
    %     pdegplot(model,'FaceLabels','on','FaceAlpha',0.5)

%     tic
%     generateMesh(model,'Hmax',hmax,'Hmin',hmin,'Hgrad',hgrad);%Hgrad = 1.4
    % pdemesh(model);
%     t = toc;
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
        for j = [-1,1]
            [aa,bb] = meshgrid(lin{mod(i,3)+1},lin{mod(i+1,3)+1});
            cc = ones(size(aa))*j*cube(mod(i+2,3)+1)/2;
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
    
    names = findfacename_boundary(model);
    applyBoundaryCondition(model,'dirichlet','face',names(1),'u',fbnd1);
    applyBoundaryCondition(model,'dirichlet','face',names(2),'u',fbnd2);
    applyBoundaryCondition(model,'dirichlet','face',names(3),'u',fbnd3);
    applyBoundaryCondition(model,'dirichlet','face',names(4),'u',fbnd4);
    applyBoundaryCondition(model,'dirichlet','face',names(5),'u',fbnd5);
    applyBoundaryCondition(model,'dirichlet','face',names(6),'u',fbnd6);
    specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);
    
    if isprint
        t= toc;
        fprintf(1,'Boudary conditon interpolation time: %.3f s\n',t)
        fprintf(1,'Pde solving time:')
        tic
    end
    
    results2 = solvepde(model);
    if isprint
        t= toc;
        fprintf(1,' %.3f s\n',t)
    end
    % pdeplot3D(model,"ColorMapData",results2.NodalSolution)
    
    results = results2;
    cube = cube./reduce;
end
end