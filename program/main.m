%% 六連桿沖壓機構分析 - 主程式
% -------------------------------------------------
% 這份主腳本負責協調整個分析流程，包含：
% 1. 初始化參數與讀取資料
% 2. 定義機構的符號模型
% 3. 執行模擬迴圈
% 4. 分析並儲存結果
% -------------------------------------------------

%% 清理工作環境
clc;
clear;
close;
cd; % 建議指定到專案目錄
addpath('C:\Users\Ou918\Downloads\AI-optimization\reference\model'); % 確保路徑正確
import CrossXY.*
import mechanism_env.*
import simulation.*
import symbolic_model.*
import analyze.*

%% 1. 設定與讀取參數
disp('Step 1: 正在設定參數...');
% 使用一個結構體(struct)來管理所有參數，方便傳遞
TypeName = "Type 1A";
[params, fileInfo] = mechanism_env(TypeName);
disp('參數設定完成。');

%% 2. 定義符號模型
disp('Step 2: 正在定義符號模型...');
% 符號模型也用一個結構體管理
model = symbolic_model(params);
disp('符號模型定義完成。');

%% 3. 執行模擬迴圈
disp('Step 3: 正在執行模擬迴圈...');
% 傳入模型和參數，返回計算結果
results = simulation(model, params);
disp('模擬計算完成。');

%% 4. 分析與儲存結果
disp('Step 4: 正在分析與儲存結果...');
analyze(results, fileInfo);

%% 完成
disp(TypeName + " 全部計算已完成！");