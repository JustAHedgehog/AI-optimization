clc;
clear;
close;
import SetFontDimensionTable.*
ReadExcelFileName = "全部Type 尺寸表 整理前.xlsx";
WriteExcelFileName = "全部Type 尺寸表 整理後.xlsx";
%% 定義預設參數以避免資料缺失
D = readcell(ReadExcelFileName,'Range','A1'); % 讀取ReadExcelFileName的所有內容，並存入 D 這個 cell 陣列中
R1 = 740;
R2 = 100;
R3 = 100;
R4 = 100;
R5 = 100;
R7 = 100;
R8 = 100;
%%
A1 = {'T1A_'};
% 14個桿件設計參數，其中Joint_Width代表滑塊連接棒的長度
A2 = {'R1';'R2';'R3';'R4';'R5';'R7';'R8';'R1_Width';'R2_Width';'R3_Width';'R4_Width';'R5_Width';'R6_Width';'Joint_Width';}; 
B = [R1;R2;R3;R4;R5;R7;R8;756;756;344;756;550;550;756;];
C = repmat({'mm'},size(A2,1),1); % repmat = repeat matrix; 建立一個和 A2 一樣多列的直行陣列，且每一格的內容都是 'mm'，代表單位
%% 
A1append = repmat(A1,1,size(A2,1)); % 將 'T1A_' 這個前綴複製 14 次
A1append = reshape(A1append.',size(A1,1)*size(A2,1),1); % 轉換成直行
% 根據 A1 數量複製多少個 A2, B, C 內容
A2append = repmat(A2,size(A1,1),1);
Bappend = repmat(B,size(A1,1),1);
Cappend = repmat(C,size(A1,1),1);
InvPara = [string(A1append)+string(A2append),Bappend,Cappend]; % 前綴與名稱相加 string(A1append)+string(A2append)，變成 'T1A_R1', 'T1A_R2', ... 
% InvPara 會變成一個 14x3 的表格：
% | "T1A_R1" | 740 | "mm" |
% | :--- | :-- | :--- |
% | "T1A_R2" | 100 | "mm" |
% | "T1A_R3" | 100 | "mm" |
% | ... | ... | ... |
% | "T1A_Joint_Width" | 756 | "mm" |

%% 過濾掉 整理前.xlsx 檔案裡的無效資訊
E = extractBefore(string(D(:,1)),2); % 擷取參數第一個字元
F = ~strcmp(E(:),'T'); % 當參數的開頭不是 'T' 時，對應的位置就是 1 (true)
D(F,:) = []; % 刪除那些開頭不是 'T' 的儲存格
%%
for i = 1:size(D,1)
    repindex = find(strcmp(InvPara(:,1),D{i,1})); % 找出 D 以及 InvPara 相同參數名稱下對應的索引值
    InvPara(repindex,2) = D{i,2}; % 更換 InvPara 參數為實際參數
end
parasNumber = size(InvPara,1); % 紀錄總共有多少個參數
%%
writematrix(InvPara,WriteExcelFileName,'Range','A1');
%%
SetFontDimensionTable(WriteExcelFileName,parasNumber);
%%
disp(InvPara);
disp("------------------------------------------------------------------");
