function f = QuickRaidalFreq(r0,Vrf)

automatic = automaticSTL();
[~,stlname] = automatic.NewStl('r0',r0);
model = createpde();
importGeometry(model, fullfile(getenv('TRAPSIMU'),'stl',stlname));
[~,ele1,ele2] =  findfacenameOnline(model);
generateMesh(model,'Hmax',0.1,'Hmin',0.0005,'Hgrad',1.2);
applyBoundaryCondition(model,'dirichlet','face',1:model.Geometry.NumFaces,'u',0);
for i=1:length(ele1)
    applyBoundaryCondition(model,'dirichlet','face',ele1{i},'u',1);
    applyBoundaryCondition(model,'dirichlet','face',ele2{i},'u',1);
end
specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);
results = solvepde(model);
cube = [0.1,0.1,0.1];
reduce = 2;
iter = 3;
interp_finess = 50;
mesh_finess = [10,30,30];
[rst, ~] = pde_cubeiter_inhomogeneous(results,cube,reduce,iter,interp_finess,mesh_finess);

[yy,zz] = meshgrid(linspace(-0.01,0.01,100));
xx = zeros(size(yy));
ssu = griddata(rst.Mesh.Nodes(1,:),rst.Mesh.Nodes(2,:),rst.Mesh.Nodes(3,:),rst.NodalSolution, ...
    xx,yy,zz,"natural");
[f1,f2,~] = RadialFreq2D(yy,zz,ssu,'Vrf',Vrf,'loose',true);
f=(f1+f2)/2;
fprintf(1,'Vrf:%.6f\tf:%.6e\n',Vrf,f)
end

