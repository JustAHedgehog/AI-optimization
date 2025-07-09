function OutRange=ReturnRange(X,Y)
numbers=(1:52);
letters1=arrayfun(@char,'A':'Z','UniformOutput',false);
letters2=strcat('A',arrayfun(@char,'A':'Z','UniformOutput',false));
letters=[letters1,letters2];
map=dictionary(numbers,letters);
if X==0 && Y==0
    OutRange="";
end
if X~=0 && Y==0
    OutRange=string(X);
end
if X==0 && Y~=0
    OutRange=string(map(Y));
end
if X~=0 && Y~=0
    OutRange=string(map(Y))+string(X);
end
end