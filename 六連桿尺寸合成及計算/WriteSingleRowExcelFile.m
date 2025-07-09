function WriteSingleRowExcelFile(oWorkbook,TitleName,i,InvParas)
parasNumber=size(TitleName,2);
% 取得指定的工作表(sheet)
oSheet=oWorkbook.Sheets.Item(1);
oSheet.Activate;
oSheet.Name="工作表1";
% 指定A3:O3到底
rangeString=ReturnRange(2+i,1)+":"+ReturnRange(2+i,parasNumber);
oSheet.Range(rangeString).Value=InvParas;
end