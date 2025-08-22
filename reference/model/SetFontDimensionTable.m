function SetFontDimensionTable(excelFileName,parasNumber)
    excelApp=actxserver('Excel.Application');
    excelApp.Visible=true;
    excelFilePath=fullfile(pwd,excelFileName);
    % 取得指定的Excel檔(workbook)
    oWorkbook=excelApp.Workbooks.Open(excelFilePath);
    oSheet=oWorkbook.Sheets.Item(1);
    oSheet.Activate;
    oSheet.Name="工作表1";
    % 指定A1:D1到底
    rangeString=ReturnRange(1,1)+":"+ReturnRange(parasNumber,4);
    oSheet.Range(rangeString).Interior.ColorIndex=-4142; % -4142表示無填充
    oSheet.Range(rangeString).HorizontalAlignment=-4131;
    oSheet.Range(rangeString).VerticalAlignment=-4108;
    oSheet.Range(rangeString).Font.Name='Microsoft JhengHei';
    oSheet.Range(rangeString).Font.Size=10;
    oSheet.Range(rangeString).Font.Color=0; % 黑色的 RGB 值是 0
    % 指定A:D
    rangeString=ReturnRange(0,1)+":"+ReturnRange(0,4);
    oSheet.Columns.Item(rangeString).AutoFit();
    % 指定1:12
    rangeString=ReturnRange(1,0)+":"+ReturnRange(parasNumber,0);
    oSheet.Rows.Item(rangeString).AutoFit();
    oWorkbook.Save();
    oWorkbook.Close();
    excelApp.Quit();
    delete(excelApp);
end