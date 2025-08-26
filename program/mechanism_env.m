function [params, fileInfo] = mechanism_env(TypeName)
    % mechanism_env - 讀取資料並設定所有機構參數
    % 輸入: TypeName - 機構類型名稱 (string)
    % 輸出: params - 包含所有物理參數的結構體
    %       fileInfo - 包含檔案名稱的結構體

    %% 檔案名稱
    fileInfo.BOMFileName = TypeName + " 總組合 組合1 BOM表.xlsx";
    fileInfo.DimFileName = TypeName + " 尺寸表.xlsx";
    fileInfo.ResultFileName = TypeName + " 計算結果表.xlsx";

    %% 常數
    params.rad = pi/180;
    params.g = 9.81;
    params.n2 = 70; % 馬達轉速
    params.omega2 = params.n2 * 2*pi/60;
    params.alpha2 = 0; % 假設馬達等速運轉

    %% 讀取資料
    BOMs = readmatrix(fileInfo.BOMFileName,'Range','A3');
    Dims = readmatrix(fileInfo.DimFileName,'Range','B1:B15');

    %% 桿件設計參數 (單位: m)
    params.R2 = Dims(2)*1e-3;
    params.R3 = Dims(3)*1e-3;
    params.R4 = Dims(4)*1e-3;
    params.R5 = Dims(5)*1e-3;
    params.R7 = Dims(6)*1e-3;
    params.R8 = Dims(7)*1e-3;

    %% 桿件材料參數
    m_mat = num2cell(BOMs(:,2));
    b_mat = num2cell(BOMs(:,8)*1e-3);
    phi_mat = num2cell(BOMs(:,9)*params.rad);
    I_mat = num2cell(BOMs(:,12)*1e-6);
    [params.m1, params.m2, params.m3, params.m4, params.m5, params.m6] = m_mat{:};
    [params.b1, params.b2, params.b3, params.b4, params.b5, ~] = b_mat{:};
    params.b6 = 0;
    [params.phi1, params.phi2, params.phi3, params.phi4, params.phi5, params.phi6] = phi_mat{:};
    [params.I1, params.I2, params.I3, params.I4, params.I5, params.I6] = I_mat{:};
end