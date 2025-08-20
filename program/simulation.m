function results = simulation(model, params)
    % SIMULATION - 執行主迴圈，計算每個角度的運動學與動力學
    % 輸入: model - 包含符號方程式的結構體
    %       params - 包含物理參數的結構體
    % 輸出: results - 包含所有計算結果矩陣的結構體

    %% 初始化結果儲存矩陣
    num_steps = 420;
    results.FPVA_matrix = zeros(num_steps, 12);
    results.GPVA_matrix = zeros(num_steps, 30);
    results.FM_matrix = zeros(num_steps, 22);
    results.SK_matrix = zeros(num_steps, 3);
    
    % 從 model 和 params 中提取常用變數，增加可讀性
    sym_pos = model.sym_pos;
    sym_vel = model.sym_vel;
    sym_acc = model.sym_acc;
    rad = params.rad;
    candidate_1 = 0;
    candidate_2 = 0;
    %% 主迴圈
    for i = 1:num_steps
        th2_val = i*rad;
        [FPSol, candidate_1, candidate_2] = solve_position(th2_val, params, candidate_1, candidate_2);

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
    fprintf("th4_2 跌代次數： %f\n", candidate_2);
    fprintf("th4_1 跌代次數： %f\n", candidate_1);
end

function [FPSol, candidate_1, candidate_2] = solve_position(th2_val, params, candidate_1, candidate_2)
    R2 = params.R2; R3 = params.R3; R4 = params.R4;
    R5 = params.R5; R7 = params.R7; R8 = params.R8;
    A = R2*cos(th2_val) - R7;
    B = R2*sin(th2_val) + R8;
    a = A^2 + B^2 + R4^2 - R3^2 + 2*R4*A;
    b = -4*R4*B;
    c = A^2 + B^2 + R4^2 - R3^2 - 2*R4*A;
    discriminant = b^2 - 4*a*c;
    if discriminant < 0
        error('無實數解！機構在 th2 = %f rad 時無法達到此構型。', th2_val);
    end
    t1 = (-b + sqrt(discriminant)) / (2*a);
    t2 = (-b - sqrt(discriminant)) / (2*a);
    
    th4_1 = 2*atan(t1);
    th4_2 = 2*atan(t2);

    % 因機構緣故，th4 僅能在第1 (0 ~ pi/2) 或 第4 (3pi/2 ~ 2pi 或 -pi/2 ~ 0) 象限，而 atan 函數的返回值範圍是 (-pi/2, pi/2)
    if (th4_2 >= -pi/2 && th4_2 <= pi/2) % 第一象限或第四象限
        th4 = th4_2;
        candidate_2 = candidate_2 + 1;
    else % 檢查另一個候選解
        if (th4_1 >= -pi/2 && th4_1 <= pi/2)
            th4 = th4_1;
            candidate_1 = candidate_1 + 1;
        else
            error('在 th2 = %f rad 時，找不到符合 th4 象限限制的解。', th2_val);
        end
    end
    th5 = pi - asin(R4*sin(th4)/R5);
    numerator_th3_y = B - R4*sin(th4);
    numerator_th3_x = A - R4*cos(th4);
    th3 = atan2(numerator_th3_y, numerator_th3_x);
    
    % 因為 cos(th5) 必須為負 (第2、3象限)，所以 R1 的公式中取減號
    R1 = R4*cos(th4) + sqrt(R5^2 - (R4*sin(th4))^2);
    FPSol = [R1; th3; th4; th5];
end