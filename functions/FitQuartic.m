function [fitresult, gof] =  FitQuartic(result,xq)

if isa(result,'pde.StationaryResults')
uq = interpolateSolution(result,xq,zeros(size(xq)),zeros(size(xq)));
else
    uq = zeros(size(xq'));
    for i = 1:length(result)
       uq = uq+interpolateSolution(result{i},xq,zeros(size(xq)),zeros(size(xq)));
    end
end
[xData, yData] = prepareCurveData( xq, uq );

% Set up fittype and options.
ft = fittype( 'a + b*x^2 + c*x^4', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end