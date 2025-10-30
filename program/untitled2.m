%% 測試 3: run_simulation_loop.m (快速測試版)
clc;
clear;
close all;

% --- 準備測試 (需要 params 和 model) ---
TypeName = "Type 1A";
addpath('C:\Users\Ou918\Downloads\AI-optimization\reference\model');
import CrossXY.*

disp('正在準備測試環境...');
[params, ~] = mechanism_env(TypeName);
model = symbolic_model(params);
disp('準備完成。');

% --- 執行被測試的函數 ---
% *** 請確認已將 run_simulation_loop.m 中的迴圈改成 1:5 ***
disp('正在測試 simulation.m ...');
results = simulation(model, params);

% --- 驗證結果 ---
if exist('results', 'var')
    disp('測試成功！迴圈執行完畢且無錯誤。');
    
    % 檢查輸出矩陣的大小是否正確
    [rows, cols] = size(results.FPVA_matrix);
    fprintf('FPVA_matrix 的大小為 %d x %d (應為 420 x 12)\n', rows, cols);
    
    % 檢查是否有 NaN (Not-a-Number)，這通常表示計算出錯
    if any(isnan(results.FPVA_matrix(:)))
        disp('警告：結果中包含 NaN，可能有計算錯誤！');
    else
        disp('結果中未發現 NaN。');
    end
else
    disp('測試失敗！');
end

disp('*** 測試完畢***');