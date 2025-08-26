clc;
clear;
close;
cd; % 切換到預設的使用者資料夾
import SetFontExcelFile.*
import ReadSingleOccurrence.*
import WriteSingleRowExcelFile.*
%%
TitleName = [{"零件號碼"},{"質量"},{"材料"},{"密度"},{"CG[X]"},{"CG[Y]"},{"CG[Z]"},{"CG[b]"},{"CG[phi]"},{"Ixx"},{"Iyy"},{"Izz"},{"Ixy"},{"Iyz"},{"Ixz"}];
UnitName = [{""},{"kg"},{""},{"kg/mm^3"},{"mm"},{"mm"},{"mm"},{"mm"},{"deg"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"}];
TypeName = ["Type 1A"];
%%
invApp = actxserver('Inventor.Application'); % 啟動 Inventor，並在 MATLAB 中建立一個名為 invApp 的物件來控制它。
invApp.Visible = true; % 讓被遙控的 Inventor 視窗顯示在螢幕上
%%
excelApp = actxserver('Excel.Application'); % 啟動一個 Microsoft Excel 的執行個體，並在 MATLAB 中建立一個名為 excelApp 的物件來控制它。
excelApp.Visible = true; % 讓被遙控的 Excel 視窗顯示在螢幕上
%%
for j = 1:size(TypeName,2)
    % ... 檔案名稱設定 ...
    iamFileName = TypeName(j) + " 總組合 組合1.iam";
    iamFilePath = fullfile(pwd,iamFileName); % 建立檔案的絕對路徑
    excelFileName = TypeName(j) + " 總組合 組合1 BOM表.xlsx";
    excelFilePath = fullfile(pwd,excelFileName);

    % ... 開啟檔案 ...
    oAsmDoc = invApp.Documents.Open(iamFilePath);
    oWorkbook = excelApp.Workbooks.Open(excelFilePath); % Excel 是需要"預先"存在的

    % ... 遍歷零件並寫入資料 ...
    oOccurrences = oAsmDoc.ComponentDefinition.Occurrences; % 取得組合檔中所有的零件/子組合的集合。
    for i = 1:oOccurrences.Count
        oOccurrence = oOccurrences.Item(i); % 取得目前零件
        InvParas = ReadSingleOccurrence(oOccurrence); % 從零件中提取出所有物理性質
        WriteSingleRowExcelFile(oWorkbook,TitleName,i,InvParas);
    end
    % ... 格式化與存檔 ...
    SetFontExcelFile(oWorkbook,TitleName,UnitName,oOccurrences.Count);
    oAsmDoc.Save2(true);
    oAsmDoc.Close();
    oWorkbook.Save();
    oWorkbook.Close();
end
%% 程式結束與清理
invApp.Quit();
delete(invApp); 
%% 程式結束與清理
excelApp.Quit();
delete(excelApp);
%%
disp("Read Inventor iam File Finished");