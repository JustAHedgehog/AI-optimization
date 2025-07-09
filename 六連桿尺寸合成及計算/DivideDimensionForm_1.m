clc;
clear;
close;
cd;
%%
sourceFileName="全部Type 尺寸表 整理後.xlsx";
sourceDim=readcell(sourceFileName,'Range','A1');
A1={'Type 1A'};
VarVal=14; % 每個Type有多少參數
%%
for i=1:size(A1,1)
    TypeName=A1(i);
    divideFileName=TypeName+" 尺寸表.xlsx";
    index=1+VarVal*i-VarVal;
    divideDim=sourceDim(index:index+VarVal-1,:);
    writecell(divideDim,divideFileName);
    disp(divideFileName+" is filled");
end