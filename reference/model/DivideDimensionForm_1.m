clc;
clear;
close;
cd;
%%
sourceFileName = "全部Type 尺寸表 整理後.xlsx";
sourceDim = readcell(sourceFileName,'Range','A1'); % 從儲存格 A1 開始讀取並複製整個excel工作表的所有資料
A1 = {'Type 1A'}; % 想要處理的目標類型名稱，未來可增加'Type 1B', ...
VarVal = 14; % 每個Type有多少參數
%%
for i=1:size(A1,1) % 計算 A1 這個陣列有多少列（Row），決定迴圈數量
    TypeName = A1(i);
    divideFileName = TypeName + " 尺寸表.xlsx";
    index = 1 + VarVal*i - VarVal; % 定義該Type的資料擷取起始位置
    divideDim = sourceDim(index:index+VarVal-1,:); % 從原始的大表格 sourceDim 中，擷取出我們需要的資料範圍。
    writecell(divideDim,divideFileName);
    disp(divideFileName + " is filled");
end