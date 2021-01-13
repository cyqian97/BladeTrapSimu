function [fs,xs] = RFHomogeneityAll_bias(result_rf,result_dc,V,xs,varargin)
%[fs,xs] = RFHomogeneityAll_bias(result_rf,result_dc,V,xs,varargin)
%   Get the mean radial frequency at each x along the trap.
p = inputParser;
addRequired(p,'V',@(x) validateattributes(x,{'numeric'},{'vector'},mfilename,'V'));
addRequired(p,'xs',@(x) validateattributes(x,{'numeric'},{'vector'},mfilename,'xs'));
addParameter(p,'yz_range',0.01,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'yz_range'));
addParameter(p,'ismean',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'ismean'));
parse(p,V,xs,varargin{:});

fs = [xs;xs];
[yy,zz] = meshgrid(linspace(-p.Results.yz_range,p.Results.yz_range,50));


for j = 1:length(xs)
    pp = yy(:)*0;
    xx = ones(size(yy))*xs(j);
    if ~isempty(result_rf)
        [gx,gy,gz] = evaluateGradient(result_rf,xx,yy,zz);
        pp = pp + PseudoPotential(gx,gy,gz);
    end
    for i = 1:length(result_dc)
        pp = pp + interpolateSolution(result_dc(i),xx,yy,zz)*V(i);
        pp = pp + interpolateSolution(result_dc(i),xx,-yy,zz)*V(i);
    end
    [f1,f2,~] = PseudoFreq2D(yy(:),zz(:),pp);
    fs(:,j) = [f1;f2];
end

if p.Results.ismean
    fs = (fs(1,:)+fs(2,:))/2;
end

end