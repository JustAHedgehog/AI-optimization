%% 清理工作環境
% clc;
clear; % 清空工作環境的變數
close;
cd;
addpath('C:\Users\Ou918\Downloads\AI-optimization\reference\model')
import CrossXY.*
%% 設定初始參數
syms R1 th2 th3 th4 th5
syms v1 omega3 omega4 omega5 % v1(滑塊速度), omega2~omega5(各桿角速度)
n2 = 70;
omega2 = -n2*2*pi/60;
syms a1 alpha2 alpha3 alpha4 alpha5 % a1(滑塊加速度), alpha2~alpha5(各桿角加速度)
assume(R1,'real');
assume(th3,'real');
assume(th4,'real');
assume(th5,'real');


%% 設定力量變數
syms F12x F12y F14x F14y F16x F16y F23x F23y F34x F34y F35x F35y F36x F36y F45x F45y F56x F56y % Fijx, Fijy 表示桿件i對桿件j的作用力(x,y方向)
syms M12 M14 M16
syms FSKx FSKy MSK FPress % 外力：FPress(沖壓力), FSKx, FSKy(機架反力), MSK(機架力矩)
%% 設定桿件質心加速度，用於後續的力平衡方程式
syms a_G2x a_G3x a_G4x a_G5x a_G6x
syms a_G2y a_G3y a_G4y a_G5y a_G6y

%% 讀取資料 
TypeName = "Type 1A";
BOMFileName = TypeName + " 總組合 組合1 BOM表.xlsx";
DimFileName = TypeName + " 尺寸表.xlsx";
IniFileName = TypeName + " 初始位置表.xlsx";
ResultFileName = TypeName + " 計算結果表.xlsx";
rad = pi/180;
g = 9.81;

BOMs = readmatrix(BOMFileName,'Range','A3'); % 材料清單(質量、慣性矩)
Dims = readmatrix(DimFileName,'Range','B1:B15'); % 桿長參數
Inis = readmatrix(IniFileName,'Range','A1'); % R1 th2 th3 th4 th5初始值
Inis = [Inis(:,1)*1e-3,Inis(:,2:4)*rad];

% 桿件設計參數設定
R2 = Dims(2)*1e-3;
R3 = Dims(3)*1e-3;
R4 = Dims(4)*1e-3;
R5 = Dims(5)*1e-3;
R7 = Dims(6)*1e-3;
R8 = Dims(7)*1e-3;

theta2_range = 1:1:360; % 設定輸入角度範圍(1-360)及數量
FPVA_matrix = zeros(360,12); % 位置、速度、加速度
R1_list = zeros(size(theta2_range));
%% 運動學分析 
% 桿件向量迴路方程式，FP, FV, FA = funcion of position / velocity / acceleration
FP = [R1 - R4*cos(th4) + R5*cos(th5);
    R5*sin(th5) - R4*sin(th4);
    R7 - R2*cos(th2) + R3*cos(th3) + R4*cos(th4);
    R3*sin(th3) - R2*sin(th2) - R8 + R4*sin(th4);];
FV = [v1 + R4*omega4*sin(th4) - R5*omega5*sin(th5);
    R5*omega5*cos(th5) - R4*omega4*cos(th4);
    R2*omega2*sin(th2) - R3*omega3*sin(th3) - R4*omega4*sin(th4);
    R3*omega3*cos(th3) - R2*omega2*cos(th2) + R4*omega4*cos(th4);];
FA = [a1 + R4*(omega4^2*cos(th4) + alpha4*sin(th4)) - R5*(omega5^2*cos(th5) + alpha5*sin(th5));
    R4*(omega4^2*sin(th4) - alpha4*cos(th4)) - R5*(omega5^2*sin(th5) - alpha5*cos(th5));
    R2*(omega2^2*cos(th2) + alpha2*sin(th2)) - R3*(omega3^2*cos(th3) + alpha3*sin(th3)) - R4*(omega4^2*cos(th4) + alpha4*sin(th4));
    R2*(omega2^2*sin(th2) - alpha2*cos(th2)) - R3*(omega3^2*sin(th3) - alpha3*cos(th3)) - R4*(omega4^2*sin(th4) - alpha4*cos(th4));];

%%
for i = 1:length(theta2_range) % 模擬 thi_2 繞一圈
    A = R2*cos(i*rad)-R7;
    B = R2*sin(i*rad)+R8;
    a = A^2 + B^2 + R4^2 - R3^2 + 2*R4*A;
    b = -4*R4*B;
    c = A^2 + B^2 + R4^2 - R3^2 - 2*R4*A;
    discriminant = b^2 - 4*a*c;
    if discriminant < 0
        error('無實數解！機構無法達到此構型，請檢查輸入參數。');
    end
    t1 = (-b + sqrt(discriminant)) / (2*a);
    t2 = (-b - sqrt(discriminant)) / (2*a);
    
    % --- 4. 計算 th4 (因t有兩個候選解，所以th4也有兩個候選解) ---
    th4_1 = 2*atan(t1);
    th4_2 = 2*atan(t2);

    % 因機構緣故，th4 僅能在第1 (0 ~ pi/2) 或 第4 (3pi/2 ~ 2pi 或 -pi/2 ~ 0) 象限，而 atan 函數的返回值範圍是 (-pi/2, pi/2)
    if (th4_2 >= 0 && th4_2 <= pi/2) | (th4_2 >= -pi/2 && th4_2 < 0) % 第一象限或第四象限
        th4 = th4_2;
    else % 檢查另一個候選解
        if (th4_1 >= 0 && th4_1 <= pi/2) | (th4_1 >= -pi/2 && th4_1 < 0)
            th4 = th4_1;
        else
            error('無法找到符合 th4 象限限制的解。');
        end
    end
    % --- 5. 計算 th5 ---
    % 首先計算分子 sin(th5) 部分
    % 因機構緣故，th5 僅能在第2 (pi/2 ~ pi) 或第3 (pi ~ 3pi/2) 象限活動，表示 cos(th5) 必須是負值。
    % 如果 th4 在第一象限，則 th5 在第二象限；如果 th4 在第四象限，則 th5 在第三象限。
    % num_th5 = R4*sin(th4);
    % den_th5_sq = R5^2 - (R4*sin(th4))^2;
    % if den_th5_sq < 0
    %     error('R5^2 - (R4*sin(th4))^2 小於零！機構無法達到此構型，請檢查輸入參數。');
    % end
    % den_th5 = -sqrt(den_th5_sq); % 因為 th5 在第2、3象限，cos(th5) 必須為負
    % 
    % th5 = atan2(num_th5, den_th5);
    th5 = pi - asin(R4*sin(th4)/R5);
    
    % --- 6. 計算 th3 ---
    numerator_th3_y = B - R4*sin(th4);
    numerator_th3_x = A - R4*cos(th4);
    th3 = atan2(numerator_th3_y, numerator_th3_x);
    
    % --- 7. 計算 R1 ---
    % 因為 cos(th5) 必須為負 (第2、3象限)，所以 R1 的公式中取減號
    R1 = R4*cos(th4) + sqrt(R5^2 - (R4*sin(th4))^2);
    R1_list(i) = R1;
    FPSol = [R1;th3;th4;th5];
    clear R1 th3 th4 th5;
    syms R1 th3 th4 th5;

    Unk = FV; 
    Unk = subs(Unk,th2,i*rad); % subs(表達式, 舊變數, 新值) - i代入函數
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.'); % 代入[R1; th3; th4; th5]數值進函數中
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[v1,omega3,omega4,omega5]);
    FVSol = UnkL\UnkR; % 解線性方程組

    Unk = FA;
    Unk = subs(Unk,th2,i*rad);
    Unk = subs(Unk,alpha2,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[v1,omega3,omega4,omega5],FVSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[a1,alpha3,alpha4,alpha5]);
    FASol = UnkL\UnkR; % 解線性方程組

    FPVA_matrix(i,:) = [FPSol;FVSol;FASol;].';
end

% fprintf('th3:%f\n', theta_3(1))
% fprintf('th4:%f\n', theta_4(1))
% fprintf('th5:%f\n', theta_5(1))
%% 結果分析
[R1Max,th2Max] = max(FPVA_matrix(:,1));
[R1Min,th2Min] = min(FPVA_matrix(:,1));
th2Min = th2Min - 360;
R1TotalStroke = R1Max - R1Min; % 計算總行程
th2TotalStroke = th2Max - th2Min;
fprintf("Maximum R1 = %.6g mm at th2 = %.6g deg\n",R1Max,th2Max);
fprintf("Minimum R1 = %.6g mm at th2 = %.6g deg\n",R1Min,th2Min);
fprintf("Total Stroke R1 = %.6g mm\n",R1TotalStroke);
fprintf("Total Stroke th2 = %.6g deg\n",th2TotalStroke);

FPVA_Name = ["R1","th3","th4","th5","v1","omega3","omega4","omega5","a1","alpha3","alpha4","alpha5"];
FPVA_Unit = ["m","rad","rad","rad","m/s","rad/s","rad/s","rad/s","m/s^2","rad/s^2","rad/s^2","rad/s^2"];

%% 結果輸出：將所有計算結果寫入Excel檔案
% 運動學
writematrix(FPVA_Name,ResultFileName,'Range','A1','Sheet','桿件位置速度加速度');
writematrix(FPVA_Unit,ResultFileName,'Range','A2','Sheet','桿件位置速度加速度');
writematrix(FPVA_matrix,ResultFileName,'Range','A3','Sheet','桿件位置速度加速度');

%%
disp(TypeName + " Calculate Finished");
beep on;
beep;