function analyze(results, fileInfo)
    % ANALYZE - 分析結果並將其儲存到Excel檔案
    % 輸入: results - 包含計算結果的結構體
    %       fileInfo - 包含檔案路徑的結構體

    FPVA_matrix = results.FPVA_matrix;
    ResultFileName = fileInfo.ResultFileName;

    %% 結果分析
    [R1Max, th2Max] = max(FPVA_matrix(:,1));
    [R1Min, th2Min] = min(FPVA_matrix(:,1));
    if th2Min > 360
        th2Min = th2Min - 360;
    end
    R1TotalStroke = R1Max - R1Min; % 計算總行程
    th2TotalStroke = th2Max - th2Min;
    
    fprintf("Maximum R1 = %.6g mm at th2 = %.6g deg\n", R1Max, th2Max);
    fprintf("Minimum R1 = %.6g mm at th2 = %.6g deg\n", R1Min, th2Min);
    fprintf("Total Stroke R1 = %.6g mm\n", R1TotalStroke);
    fprintf("Total Stroke th2 = %.6g deg\n", th2TotalStroke);
    
    [~, th2Start] = min(abs(FPVA_matrix(:,1) - 0.706792));
    R1Start = FPVA_matrix(th2Start,1);
    fprintf("Press Start R1 = %.6g mm at th2 = %.6g deg\n", R1Start, th2Start);

    %% 定義Excel表頭與單位
    FPVA_Name = ["R1","th3","th4","th5","v1","omega3","omega4","omega5","a1","alpha3","alpha4","alpha5"];
    GPVA_Name = ["r_G2x","r_G2y","r_G3x","r_G3y","r_G4x","r_G4y","r_G5x","r_G5y","r_G6x","r_G6y",...
        "v_G2x","v_G2y","v_G3x","v_G3y","v_G4x","v_G4y","v_G5x","v_G5y","v_G6x","v_G6y",...
        "a_G2x","a_G2y","a_G3x","a_G3y","a_G4x","a_G4y","a_G5x","a_G5y","a_G6x","a_G6y"];
    FM_Name = ["F12x","F12y","F14x","F14y","F16x","F16y","F23x","F23y","F34x","F34y","F35x","F35y","F36x","F36y","F45x","F45y","F56x","F56y","FPress","M12","M14","M16"];
    SK_Name = ["FSKx","FSKy","MSK"];
    % MA_Name = ["MA"];
    FPVA_Unit = ["m","rad","rad","rad","m/s","rad/s","rad/s","rad/s","m/s^2","rad/s^2","rad/s^2","rad/s^2"];
    GPVA_Unit = [repmat("m",1,10),repmat("m/s",1,10),repmat("m/s^2",1,10)];
    % KCFVA_Unit = ["m","ul","ul","ul","m","ul","ul","ul"];
    % KCGVA_Unit = [repmat("m",1,20)];
    FM_Unit = [repmat("N",1,19),"Nm","Nm","Nm"];
    SK_Unit = ["N","N","Nm"];
    % MA_Unit = ["ul"];
    % PEq_Unit = [repmat("kg*m^2",1,14)];

    %% 結果輸出：將所有計算結果寫入Excel檔案
    disp('正在將結果寫入Excel...');
    % 運動學
    writematrix(FPVA_Name, ResultFileName, 'Range','A1', 'Sheet','桿件位置速度加速度');
    writematrix(FPVA_Unit, ResultFileName, 'Range','A2', 'Sheet','桿件位置速度加速度');
    writematrix(results.FPVA_matrix, ResultFileName, 'Range','A3', 'Sheet','桿件位置速度加速度');

    writematrix(GPVA_Name,ResultFileName,'Range','A1','Sheet','質心位置速度加速度');
    writematrix(GPVA_Unit,ResultFileName,'Range','A2','Sheet','質心位置速度加速度');
    writematrix(results.GPVA_matrix,ResultFileName,'Range','A3','Sheet','質心位置速度加速度');
    
    % 動力學
    writematrix(FM_Name,ResultFileName,'Range','A1','Sheet','靜力分析');
    writematrix(FM_Unit,ResultFileName,'Range','A2','Sheet','靜力分析');
    writematrix(results.FM_matrix,ResultFileName,'Range','A3','Sheet','靜力分析');
    
    % 搖撼力
    writematrix(SK_Name,ResultFileName,'Range','A1','Sheet','搖撼力');
    writematrix(SK_Unit,ResultFileName,'Range','A2','Sheet','搖撼力');
    writematrix(results.SK_matrix,ResultFileName,'Range','A3','Sheet','搖撼力');
        
    disp('Excel檔案寫入完成。');
end