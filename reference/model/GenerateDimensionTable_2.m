clc;
clear;
close;
cd;
import SetFontDimensionTable.*
%%
iptFileName = "All Type Dimension Synthesis.ipt";
WriteExcelFileName = "全部Type 尺寸表 整理前.xlsx";
% TitleName = [{"參數名稱"},{"值"},{"單位"},{"註解"}];
%%
invApp = actxserver('Inventor.Application');
invApp.Visible = true;
iptFilePath = fullfile(pwd,iptFileName);
% 取得指定的零件
oIptDoc = invApp.Documents.Open(iptFilePath);
oIptParas = oIptDoc.ComponentDefinition.Parameters;
%%
paraNames = repmat({''},1,oIptParas.Count);
paraValues = repmat({''},1,oIptParas.Count);
paraUnits = repmat({''},1,oIptParas.Count);
paraComments = repmat({''},1,oIptParas.Count);
%%
% 迭代所有參數
for i = 1:oIptParas.Count
    para = oIptParas.Item(i);
    TrueValue = para.Value;
    if para.Unit == "mm"
        TrueValue = para.Value*10;
    end
    if para.Unit == "deg"
        TrueValue = para.Value*180/pi;
    end
    paraNames{i} = para.Name;  % 參數名稱
    paraValues{i} = TrueValue;  % 參數值
    paraUnits{i} = para.Unit;  % 參數單位
    paraComments{i} = para.Comment;  % 參數單位
end
%%
oIptDoc.Save2(true);
oIptDoc.Close();
invApp.Quit();
delete(invApp);
%%
[paraNamesSorted,sortIdx] = sort(paraNames);  % 排序參數名稱，並獲取排序索引
% 根據排序索引重新排列參數值和類型
paraValuesSorted = paraValues(sortIdx);
paraUnitsSorted = paraUnits(sortIdx);
paraCommentsSorted = paraComments(sortIdx);
%%
% InvParas = [paraNames;paraValues;paraUnits;paraComments].';
InvParas = [paraNamesSorted;paraValuesSorted;paraUnitsSorted;paraCommentsSorted].';
disp(InvParas);
parasNumber = size(InvParas,1);
%%
writecell(InvParas,WriteExcelFileName,'Range','A1');
%%
SetFontDimensionTable(WriteExcelFileName,parasNumber);
%%
disp("Read Inventor ipt File Finished");