function SetFontExcelFile(oWorkbook,TitleName,UnitName,i)
parasNumber = size(TitleName,2);
% 取得指定的工作表(sheet)
oSheet = oWorkbook.Sheets.Item(1);
oSheet.Activate;
oSheet.Name = "工作表1";
% 指定A1:O1
rangeString = ReturnRange(1,1) + ":" + ReturnRange(1,parasNumber);
oSheet.Range(rangeString).Value = TitleName;
% 指定A2:O2
rangeString = ReturnRange(2,1) + ":" + ReturnRange(2,parasNumber);
oSheet.Range(rangeString).Value = UnitName;
% 指定A1:O12
rangeString = ReturnRange(1,1) + ":" + ReturnRange(12,parasNumber);
oSheet.Range(rangeString).Interior.ColorIndex = -4142; % -4142表示無填充
oSheet.Range(rangeString).HorizontalAlignment = -4131;
oSheet.Range(rangeString).VerticalAlignment = -4108;
oSheet.Range(rangeString).Font.Name = 'Microsoft JhengHei';
oSheet.Range(rangeString).Font.Size = 10;
oSheet.Range(rangeString).Font.Color = 0; % 黑色的 RGB 值是 0
% 指定A1:O2
rangeString = ReturnRange(1,1) + ":" + ReturnRange(2,parasNumber);
oSheet.Range(rangeString).Font.Size = 12;
oSheet.Range(rangeString).Font.Bold = true;
% 將重要參數上色
R = 255;
G = 255;
B = 0;
colorval = R + G*256 + B*256^2;
% 指定B1:B1到底
rangeString = ReturnRange(1,2) + ":" + ReturnRange(2 + i,2);
oSheet.Range(rangeString).Interior.Color = colorval;
% 指定H1:H1到底
rangeString = ReturnRange(1,8) + ":" + ReturnRange(2 + i,8);
oSheet.Range(rangeString).Interior.Color = colorval;
% 指定I1:I1到底
rangeString = ReturnRange(1,9) + ":" + ReturnRange(2 + i,9);
oSheet.Range(rangeString).Interior.Color = colorval;
% 指定L1:L1到底
rangeString = ReturnRange(1,12) + ":" + ReturnRange(2 + i,12);
oSheet.Range(rangeString).Interior.Color = colorval;

% 指定A:O
rangeString = ReturnRange(0,1) + ":" + ReturnRange(0,parasNumber);
oSheet.Columns.Item(rangeString).AutoFit();
% 指定1:12
rangeString = ReturnRange(1,0) + ":" + ReturnRange(2 + i,0);
oSheet.Rows.Item(rangeString).AutoFit();
end