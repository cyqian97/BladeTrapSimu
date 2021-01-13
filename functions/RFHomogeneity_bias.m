function [fs,xs] = RFHomogeneity_bias(result,xs,varargin)
%[fs,xs] = RFHomogeneity(result,xs,vargarin)
%   Get the mean radial frequency at each x along the trap.
p = inputParser;
addRequired(p,'result',@(x) validateattributes(x,{'pde.StationaryResults'},{'scalar'},mfilename,'result'));
addRequired(p,'xs',@(x) validateattributes(x,{'numeric'},{'vector'},mfilename,'xs'));
addParameter(p,'yz_range',0.01,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'yz_range'));
addParameter(p,'ismean',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'ismean'));
addParameter(p,'pseudo',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'pseudo'));
addParameter(p,'sort',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'sort'));
parse(p,result,xs,varargin{:});

fs = [xs;xs];
[yy,zz] = meshgrid(linspace(-p.Results.yz_range,p.Results.yz_range,50));

for j = 1:length(xs)
    xx = ones(size(yy))*xs(j);
    ss = interpolateSolution(result,xx,yy,zz);
    ss = ss + interpolateSolution(result,xx,-yy,zz);
    if p.Results.pseudo
        [f1,f2,~] = PseudoFreq2D(yy(:),zz(:),ss,'sort',p.Results.sort);
    else
        [f1,f2,~] = RadialFreq2D(yy(:),zz(:),ss);
    end
    fs(:,j) = [f1;f2];
end

if p.Results.ismean
    fs = (fs(1,:)+fs(2,:))/2;
end

end