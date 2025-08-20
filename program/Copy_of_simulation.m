function results = Copy_of_simulation(model, params)
    % SIMULATION - 執行主迴圈，計算每個角度的運動學與動力學
    % 輸入: model - 包含符號方程式的結構體
    %       params - 包含物理參數的結構體
    % 輸出: results - 包含所有計算結果矩陣的結構體

    %% 初始化結果儲存矩陣
    num_steps = 420;
    
    %% =================================================================
    %  步驟 1: 預掃描以決定正確的運動學分支 (Assembly Mode)
    %  =================================================================
    disp('正在進行預掃描以決定機構組態...');
    % 從 model 和 params 中提取常用變數，增加可讀性
    sym_pos = model.sym_pos;
    sym_vel = model.sym_vel;
    sym_acc = model.sym_acc;
    rad = params.rad;
    toggle_range_rad = [175, 195] * rad; % 肘節效應的目標區間

    %% 主迴圈
    for i = 1:num_steps
        th2_val = i*rad;
        [FPSol_1, FPSol_2] = solve_kinematic_branches(th2_val, params);
        if ~any(isnan(FPSol_1))
            th5_branch1(i) = FPSol_1(4); % 提取 th5
        else
            th5_branch1(i) = NaN;
        end
        if ~any(isnan(FPSol_2))
            th5_branch2(i) = FPSol_2(4); % 提取 th5
        else
            th5_branch2(i) = NaN;
        end
    end
    branch1_reaches_toggle = any(th5_branch1 >= toggle_range_rad(1) & th5_branch1 <= toggle_range_rad(2));
    branch2_reaches_toggle = any(th5_branch2 >= toggle_range_rad(1) & th5_branch2 <= toggle_range_rad(2));
    
     % 根據檢查結果設定使用的分支
    if branch1_reaches_toggle && ~branch2_reaches_toggle
        chosen_branch = 1;
        disp('決策：採用分支 1。');
    elseif ~branch1_reaches_toggle && branch2_reaches_toggle
        chosen_branch = 2;
        disp('決策：採用分支 2。');
    elseif ~branch1_reaches_toggle && ~branch2_reaches_toggle
        error('機構設計錯誤：兩個運動學分支都無法達到指定的肘節區間。');
    else
        error('機構組態不明確：兩個運動學分支都能達到肘節區間，請檢查機構設計。');
    end
    %% =================================================================
    %  步驟 2: 執行完整動力學模擬的主迴圈
    %  =================================================================
    
    % 初始化結果儲存矩陣 (這部分不變)
    results.FPVA_matrix = zeros(num_steps, 12);
    results.GPVA_matrix = zeros(num_steps, 30);
    results.FM_matrix = zeros(num_steps, 22);
    results.SK_matrix = zeros(num_steps, 3);
    % 主迴圈
    for i = 1:num_steps
        th2_val = i * rad;
        % --- 根據預掃描的結果，選擇正確的 FPSol ---
        [FPSol_1, FPSol_2] = solve_kinematic_branches(th2_val, params);
        if chosen_branch == 1
            FPSol = FPSol_1;
        else
            FPSol = FPSol_2;
        end
        % 速度分析
        Unk_V = subs(model.FV, 'th2', th2_val); % subs(表達式, 舊變數, 新值) - i代入函數
        Unk_V = subs(Unk_V, sym_pos.', FPSol.'); % 代入[R1; th3; th4; th5]數值進函數中
        [UnkL_V, UnkR_V] = equationsToMatrix(vpa(Unk_V), sym_vel); % 將Unk轉換成矩陣形式，並按照指定的未知數 [R1d,th3d,th4d,th5d]，重組成標準的矩陣形式UnkL * [R1d,th3d,th4d,th5d] = UnkR
        FVSol = UnkL_V \ UnkR_V; % 解線性方程組 UnkL * FVSol = UnkR

        % 加速度分析
        Unk_A = subs(model.FA, 'th2', th2_val); % subs(表達式, 舊變數, 新值) - i代入函數
        Unk_A = subs(Unk_A, sym_pos.', FPSol.');
        Unk_A = subs(Unk_A, sym_vel.', FVSol.'); % 代入[R1; th3; th4; th5]數值進函數中
        [UnkL_A, UnkR_A] = equationsToMatrix(vpa(Unk_A), sym_acc); % 將Unk轉換成矩陣形式，並按照指定的未知數 [R1d,th3d,th4d,th5d]，重組成標準的矩陣形式UnkL * [R1d,th3d,th4d,th5d] = UnkR
        FASol = UnkL_A \ UnkR_A; % 解線性方程組 UnkL * FVSol = UnkR

        % ... 完整複製你迴圈內的程式碼，並修改變數 ...
        Unk_rG = subs(model.r_G, 'th2', th2_val);
        Unk_rG = subs(Unk_rG, sym_pos.', FPSol.');
        r_GSol = vpa(Unk_rG);
        Unk_vG = subs(model.v_G, 'th2', th2_val);
        Unk_vG = subs(Unk_vG, sym_pos.', FPSol.');
        Unk_vG = subs(Unk_vG, sym_vel.', FVSol.');
        v_GSol = vpa(Unk_vG);

        Unk_aG = subs(model.a_G, 'th2', th2_val);
        Unk_aG = subs(Unk_aG, sym_pos.', FPSol.');
        Unk_aG = subs(Unk_aG, sym_vel.', FVSol.');
        Unk_aG = subs(Unk_aG, sym_acc.', FASol.');
        a_GSol = vpa(Unk_aG);
        % 儲存當前步驟的結果
        results.FPVA_matrix(i,:) = [FPSol; FVSol; FASol].';
        results.GPVA_matrix(i,:) = [r_GSol; v_GSol; a_GSol].';
        % results.FM_matrix(i,:) = FMSol.';
        % results.SK_matrix(i,:) = SKSol.';
        
        if mod(i, 30) == 0
            fprintf('進度: %d / %d\n', i, num_steps);
        end
    end
end

% --- 檔案: solve_kinematic_branches.m ---
function [FPSol_1, FPSol_2] = solve_kinematic_branches(th2_val, params)
    % SOLVE_KINEMATIC_BRANCHES - 計算給定 th2 下的兩個可能的機構組態解

    % 從 params 結構體中提取需要的桿長
    R2 = params.R2; R3 = params.R3; R4 = params.R4;
    R5 = params.R5; R7 = params.R7; R8 = params.R8;

    % --- 解出 th4 的兩個候選解 ---
    A = R2*cos(th2_val) - R7;
    B = R2*sin(th2_val) + R8;
    
    a = A^2 + B^2 + R4^2 - R3^2 + 2*A*R4;
    b = -4*B*R4;
    c = A^2 + B^2 + R4^2 - R3^2 - 2*A*R4;
    
    discriminant = b^2 - 4*a*c;
    if discriminant < 0
        % 如果無解，回傳 NaN 向量
        FPSol_1 = NaN(4,1);
        FPSol_2 = NaN(4,1);
        return;
    end
    
    t1 = (-b + sqrt(discriminant)) / (2*a);
    t2 = (-b - sqrt(discriminant)) / (2*a);
    
    th4_1 = 2*atan(t1);
    th4_2 = 2*atan(t2);

    % --- 分別計算兩個分支的完整解 ---
    % 分支 1
    th5_1 = pi - asin(R4*sin(th4_1)/R5);
    numerator_th3_y = B - R4*sin(th4_1);
    numerator_th3_x = A - R4*cos(th4_1);
    th3_1 = atan2(numerator_th3_y, numerator_th3_x);
    R1_1 = R4*cos(th4_1) - R5*cos(th5_1);
    FPSol_1 = [R1_1; th3_1; th4_1; th5_1];

    % 分支 2
    th5_2 = pi - asin(R4*sin(th4_2)/R5);
    numerator_th3_y = B - R4*sin(th4_2);
    numerator_th3_x = A - R4*cos(th4_2);
    th3_2 = atan2(numerator_th3_y, numerator_th3_x);
    R1_2 = R4*cos(th4_2) - R5*cos(th5_2);
    FPSol_2 = [R1_2; th3_2; th4_2; th5_2];
end