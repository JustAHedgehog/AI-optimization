clc;
clear;
close;
cd;
%%
TitleName=[{"零件號碼"},{"質量"},{"材料"},{"密度"},{"CG[X]"},{"CG[Y]"},{"CG[Z]"},{"CG[b]"},{"CG[phi]"},{"Ixx"},{"Iyy"},{"Izz"},{"Ixy"},{"Iyz"},{"Ixz"}];
UnitName=[{""},{"kg"},{""},{"kg/mm^3"},{"mm"},{"mm"},{"mm"},{"mm"},{"deg"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"},{"kg*mm^2"}];
TypeName=["Type 1A"];
%%
invApp=actxserver('Inventor.Application');
invApp.Visible=true;
%%
excelApp=actxserver('Excel.Application');
excelApp.Visible=true;
%%
for j=1:size(TypeName,2)
    % iptFileName=A1(j)+" R1前充座.ipt";
    iamFileName=TypeName(j)+" 總組合 組合1.iam";
    excelFileName=TypeName(j)+" 總組合 組合1 BOM表.xlsx";
    iamFilePath=fullfile(pwd,iamFileName);
    % 取得指定的組合
    oAsmDoc=invApp.Documents.Open(iamFilePath);
    excelFilePath=fullfile(pwd,excelFileName);
    % 取得指定的Excel檔(workbook)
    oWorkbook=excelApp.Workbooks.Open(excelFilePath);
    % 取得組合中的零件們
    oOccurrences=oAsmDoc.ComponentDefinition.Occurrences;
    for i=1:oOccurrences.Count
        % 取得目前零件
        oOccurrence=oOccurrences.Item(i);
        InvParas=ReadSingleOccurrence(oOccurrence);
        WriteSingleRowExcelFile(oWorkbook,TitleName,i,InvParas);
    end
    SetFontExcelFile(oWorkbook,TitleName,UnitName,oOccurrences.Count);
    oAsmDoc.Save2(true);
    oAsmDoc.Close();
    oWorkbook.Save();
    oWorkbook.Close();
end
%%
invApp.Quit();
delete(invApp); 
%%
excelApp.Quit();
delete(excelApp);
%%
disp("Read Inventor iam File Finished");
beep on;
beep;
