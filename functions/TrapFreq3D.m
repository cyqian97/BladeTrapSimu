function [mdl,f,direction] = TrapFreq3D(coord_1,coord_2,coord_3,U,varargin)
%[mdl,f,direction] = TrapFreq3D(coord_1,coord_2,coord_3,U,varargin)
%   Calculate the trap frequencies of an ion trap using 3D quardratic
%   fitting. Using the static electric potential of pseudo-potential data.
%   == Input ==
%   coord_1 : coordinate 1
%   coord_2 : coordinate 2
%   coord_3 : coordinate 3
%   U : electric potential
%   == Name-Value Pairs ==
%   scale : scale of the coordinates, e.g if the coordinates' unit is in mm, scale = 1000
%   atomic_mass: atomic mass of the ion in amu
%   loose : Set to 1 to output the result when the fitting is bad. Default
%   = 0

p = inputParser;
addRequired(p,'coord_1', @(x) validateattributes(x,{'numeric'},{'2d','nonempty'},mfilename,'coord_1',1));
addRequired(p,'coord_2', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'coord_2',2));
addRequired(p,'coord_3', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'coord_3',3));
addRequired(p,'U', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'U',4));
addParameter(p,'scale',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'scale'));
addParameter(p,'atomic_mass',171,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'atomic_mass'));
addParameter(p,'loose',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'loose'));
parse(p,coord_1,coord_2,coord_3,U,varargin{:});



phys = matfile("phys.mat","Writable",false);

scale =  p.Results.scale;
m =  p.Results.atomic_mass * phys.amu;


% 2D harmonic fitting
X = [reshape(p.Results.coord_1,[],1),reshape(p.Results.coord_2,[],1),reshape(p.Results.coord_3,[],1)];
y = reshape(p.Results.U,[],1);
modelfun = @(b,x)b(1) + b(2).*x(:,1).*x(:,2) + b(3).*x(:,1).*x(:,3) + b(4).*x(:,2).*x(:,3) + b(5).*x(:,1).^2 + b(6).*x(:,2).^2 + b(7).*x(:,3).^2;
beta0 = [0 0 0 0 0 0 0];
mdl = fitnlm(X,y,modelfun,beta0);
if mdl.Rsquared.Adjusted<0.99 && ~p.Results.loose
    error('Low gof! rsquare = %.4f',gof.rsquare);
end
variables = mdl.Coefficients.Variables;
b = variables(:,1);
% Find principle axes and frequencies
[V,D] = eig([b(5),b(2)/2,b(3)/2; ...
    b(2)/2, b(6), b(4)/2; ...
   b(3)/2, b(4)/2, b(7)]);
f = (D*scale^2*phys.e*2/m).^(1/2)/2/pi;
f = [f(1,1) f(2,2), f(3,3)];
direction = V;

end