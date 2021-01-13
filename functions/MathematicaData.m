function MathematicaData(results,ele,dir)

if isempty(dir)
    dir = cd();
end

if strcmp(ele,'DC1') || strcmp(ele,'DC2') || strcmp(ele,'DC3')
    xs = linspace(-0.15,0.15,13);
    [yy,zz] = ndgrid(linspace(-0.01,0.01,200));
    for i = 1:length(xs)
        xx = ones(size(yy))*xs(i);
        uu = interpolateSolution(results,xx,yy,zz);
        writematrix([xx(:),yy(:),zz(:),uu],fullfile(dir, ele+"_YZ"+num2str(i-7)+".txt"), ...
            "Delimiter","tab");
    end
    
    [xx,yy] = ndgrid(linspace(-0.15,0.15,200),linspace(-0.01,0.01,200));
    zz = zeros(size(yy));
    uu = interpolateSolution(results,xx,yy,zz);
    writematrix([xx(:),yy(:),zz(:),uu],fullfile(dir, ele+"_XY.txt"), ...
        "Delimiter","tab");
    [xx,zz] = ndgrid(linspace(-0.15,0.15,200),linspace(-0.01,0.01,200));
    yy = zeros(size(yy));
    uu = interpolateSolution(results,xx,yy,zz);
    writematrix([xx(:),yy(:),zz(:),uu],fullfile(dir, ele+"_XZ.txt"), ...
        "Delimiter","tab");
    
elseif strcmp(ele,'RF1')
    xs = linspace(-0.15,0.15,13);
    [yy,zz] = ndgrid(linspace(-0.01,0.01,200));
    for i = 1:length(xs)
        xx = ones(size(yy))*xs(i);
        uu = interpolateSolution(results,xx,yy,zz);
        writematrix([xx(:),yy(:),zz(:),uu],fullfile(dir, ele+"_YZ"+num2str(i-7)+".txt"), ...
            "Delimiter","tab");
    end
    [xx,yy] = ndgrid(linspace(-0.15,0.15,200),linspace(-0.01,0.01,200));
    zz = zeros(size(yy));
    uu = interpolateSolution(results,xx,yy,zz);
    writematrix([xx(:),yy(:),zz(:),uu],fullfile(dir, ele+"_XY.txt"), ...
        "Delimiter","tab");
    [xx,zz] = ndgrid(linspace(-0.15,0.15,200),linspace(-0.01,0.01,200));
    yy = zeros(size(yy));
    uu = interpolateSolution(results,xx,yy,zz);
    writematrix([xx(:),yy(:),zz(:),uu],fullfile(dir, ele+"_XZ.txt"), ...
        "Delimiter","tab");
    
elseif strcmp(ele,'ERF1')
    xs = linspace(-0.15,0.15,13);
    [yy,zz] = ndgrid(linspace(-0.01,0.01,200));
    for i = 1:length(xs)
        xx = ones(size(yy))*xs(i);
        [gradx,grady,gradz] = evaluateGradient(results,xx,yy,zz);
        writematrix([xx(:),yy(:),zz(:),sqrt(gradx.^2+grady.^2+gradz.^2)*1000],fullfile(dir, ele+"_YZ"+num2str(i-7)+".txt"), ...
            "Delimiter","tab");
    end
    [xx,yy] = ndgrid(linspace(-0.15,0.15,200),linspace(-0.01,0.01,200));
    zz = zeros(size(yy));
    [gradx,grady,gradz] = evaluateGradient(results,xx,yy,zz);
    writematrix([xx(:),yy(:),zz(:),sqrt(gradx.^2+grady.^2+gradz.^2)*1000],fullfile(dir, ele+"_XY.txt"), ...
        "Delimiter","tab");
    [xx,zz] = ndgrid(linspace(-0.15,0.15,200),linspace(-0.01,0.01,200));
    yy = zeros(size(yy));
    [gradx,grady,gradz] = evaluateGradient(results,xx,yy,zz);
    writematrix([xx(:),yy(:),zz(:),sqrt(gradx.^2+grady.^2+gradz.^2)*1000],fullfile(dir, ele+"_XZ.txt"), ...
        "Delimiter","tab");
    
end


end