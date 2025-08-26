function SetFontDimensionTable(excelFileName,parasNumber)
    excelApp = actxserver('Excel.Application'); % 啟動一個 Microsoft Excel 的執行個體，並在 MATLAB 中建立一個名為 excelApp 的物件來控制它。
    excelApp.Visible = true; % 讓被遙控的 Excel 視窗顯示在螢幕上
    excelFilePath = fullfile(pwd,excelFileName); % 建立檔案的絕對路徑。pwd 代表 "print working directory"，也就是 MATLAB 當前的工作路徑。fullfile 會安全地將路徑和檔名組合起來，確保不會出錯。
    % 取得指定的Excel檔(workbook)
    oWorkbook = excelApp.Workbooks.Open(excelFilePath);
    oSheet = oWorkbook.Sheets.Item(1);
    oSheet.Activate;
    oSheet.Name = "工作表1";
    % 指定A1:D1到底
    rangeString = ReturnRange(1,1) + ":" + ReturnRange(parasNumber,4);
    oSheet.Range(rangeString).Interior.ColorIndex = -4142; % -4142表示無填充
    oSheet.Range(rangeString).HorizontalAlignment = -4131;
    oSheet.Range(rangeString).VerticalAlignment = -4108;
    oSheet.Range(rangeString).Font.Name = 'Microsoft JhengHei';
    oSheet.Range(rangeString).Font.Size = 10;
    oSheet.Range(rangeString).Font.Color = 0; % 黑色的 RGB 值是 0
    % 指定A:D
    rangeString = ReturnRange(0,1) + ":" + ReturnRange(0,4);
    oSheet.Columns.Item(rangeString).AutoFit();
    % 指定1:12
    rangeString = ReturnRange(1,0) + ":" + ReturnRange(parasNumber,0);
    oSheet.Rows.Item(rangeString).AutoFit();
    oWorkbook.Save();
    oWorkbook.Close();
    excelApp.Quit();
    delete(excelApp);
end