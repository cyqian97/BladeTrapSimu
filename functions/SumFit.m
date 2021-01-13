function f = SumFit(fits)

func = fittype(formula(fits{1}));
names = coeffnames(fits{1});
coefs = zeros(1,length(names));

for i = 1:length(names)
   for j = 1:length(fits)
      coefs(i) = coefs(i)+fits{j}.(names{i}); 
   end
end
strcoefs = "";
for i = 1:length(names)
    strcoefs = strcoefs + num2str(i,",coefs(%d)");
end
eval("f = cfit(func"+strcoefs+");")

end