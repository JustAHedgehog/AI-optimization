%% 清理工作環境
clc;
clear; % 清空工作環境的變數
close;
cd;
addpath('C:\Users\Ou918\Downloads\AI-optimization\reference\model')
import CrossXY.*
%% 設定初始參數
syms R1 th2 th3 th4 th5
syms v1 omega3 omega4 omega5 % v1(滑塊速度), omega3~omega5(各桿角速度)
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
assume([a_G2x a_G2y a_G3x a_G3y a_G4x a_G4y a_G5x a_G5y a_G6x a_G6y], 'real');

%% 讀取資料 
TypeName = "Type 1A";
BOMFileName = TypeName + " 總組合 組合1 BOM表.xlsx";
DimFileName = TypeName + " 尺寸表.xlsx";
IniFileName = TypeName + " 初始位置表.xlsx";
ResultFileName = TypeName + " 計算結果表.xlsx";
rad = pi/180;
g = 9.81;
n2 = 70; % 馬達轉速
omega2 = n2*2*pi/60;

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

% 桿件材料參數
m_mat = num2cell(BOMs(:,2));
b_mat = num2cell(BOMs(:,8)*1e-3);
phi_mat = num2cell(BOMs(:,9)*rad);
I_mat = num2cell(BOMs(:,12)*1e-6);
[m1,m2,m3,m4,m5,m6] = m_mat{:};
[b1,b2,b3,b4,b5,~] = b_mat{:};
b6 = 0; % 設定第六連桿長度為 0，不使用 BOM 值
[phi1,phi2,phi3,phi4,phi5,phi6] = phi_mat{:};
[I1,I2,I3,I4,I5,I6] = I_mat{:};

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

% 質心位置
r_G2x = -R7 + b2*cos(phi2 + th2);
r_G2y = R8 + b2*sin(phi2 + th2);
r_G3x = -R7 + R2*cos(th2) - R3*cos(th3) + b3*cos(phi3 + th3);
r_G3y = R8 + R2*sin(th2) - R3*sin(th3) + b3*sin(phi3 + th3);
r_G4x = b4*cos(phi4 + th4);
r_G4y = b4*sin(phi4 + th4);
r_G5x = R4*cos(th4) - R5*cos(th5) + b5*cos(phi5 + th5);
r_G5y = R4*sin(th4) - R5*sin(th5) + b5*sin(phi5 + th5);
r_G6x = R4*cos(th4) - R5*cos(th5) + b6*cos(phi6 + th5);
r_G6y = R4*sin(th4) - R5*sin(th5) + b6*sin(phi6 + th5);

% 質心速度
v_G2x = -b2*sin(phi2 + th2)*omega2;
v_G2y = b2*cos(phi2 + th2)*omega2;
v_G3x = -R2*sin(th2)*omega2 + R3*sin(th3)*omega3 - b3*sin(phi3 + th3)*omega3;
v_G3y = R2*cos(th2)*omega2 - R3*cos(th3)*omega3 + b3*cos(phi3 + th3)*omega3;
v_G4x = -b4*sin(phi4 + th4)*omega4;
v_G4y = b4*cos(phi4 + th4)*omega4;
v_G5x = -R4*sin(th4)*omega4 + R5*sin(th5)*omega5 - b5*sin(phi5 + th5)*omega5;
v_G5y = R4*cos(th4)*omega4 - R5*cos(th5)*omega5 + b5*cos(phi5 + th5)*omega5;
v_G6x = -R4*sin(th4)*omega4 + R5*sin(th5)*omega5 - b6*sin(phi6 + th5)*omega5;
v_G6y = R4*cos(th4)*omega4 - R5*cos(th5)*omega5 + b6*cos(phi6 + th5)*omega5;

% 質心加速度
a_G2x = -b2*sin(phi2 + th2)*alpha2 - b2*cos(phi2 + th2)*omega2^2;
a_G2y = b2*cos(phi2 + th2)*alpha2 - b2*sin(phi2 + th2)*omega2^2;
a_G3x = -R2*sin(th2)*alpha2 - R2*cos(th2)*omega2^2 + ...
        R3*sin(th3)*alpha3 + R3*cos(th3)*omega3^2 - ...
        b3*sin(phi3 + th3)*alpha3 - b3*cos(phi3 + th3)*omega3^2;
a_G3y = R2*cos(th2)*alpha2 - R2*sin(th2)*omega2^2 - ...
        R3*cos(th3)*alpha3 + R3*sin(th3)*omega3^2 + ...
        b3*cos(phi3 + th3)*alpha3 - b3*sin(phi3 + th3)*omega3^2;
a_G4x = -b4*sin(phi4 + th4)*alpha4 - b4*cos(phi4 + th4)*omega4^2;
a_G4y = b4*cos(phi4 + th4)*alpha4 - b4*sin(phi4 + th4)*omega4^2;
a_G5x = -R4*sin(th4)*alpha4 - R4*cos(th4)*omega4^2 + ...
        R5*sin(th5)*alpha5 + R5*cos(th5)*omega5^2 - ...
        b5*sin(phi5 + th5)*alpha5 - b5*cos(phi5 + th5)*omega5^2;
a_G5y = R4*cos(th4)*alpha4 - R4*sin(th4)*omega4^2 - ...
        R5*cos(th5)*alpha5 + R5*sin(th5)*omega5^2 + ...
        b5*cos(phi5 + th5)*alpha5 - b5*sin(phi5 + th5)*omega5^2;
a_G6x = -R4*sin(th4)*alpha4 - R4*cos(th4)*omega4^2 + ...
        R5*sin(th5)*alpha5 + R5*cos(th5)*omega5^2 - ...
        b6*sin(phi6 + th5)*alpha5 - b6*cos(phi6 + th5)*omega5^2;
a_G6y = R4*cos(th4)*alpha4 - R4*sin(th4)*omega4^2 - ...
        R5*cos(th5)*alpha5 + R5*sin(th5)*omega5^2 + ...
        b6*cos(phi6 + th5)*alpha5 - b6*sin(phi6 + th5)*omega5^2;

%% 質心的位置、速度、加速度組織成向量形式，便於後續批量計算
r_G = [r_G2x;r_G2y;r_G3x;r_G3y;r_G4x;r_G4y;r_G5x;r_G5y;r_G6x;r_G6y;];
v_G = [v_G2x;v_G2y;v_G3x;v_G3y;v_G4x;v_G4y;v_G5x;v_G5y;v_G6x;v_G6y;];
a_G = [a_G2x;a_G2y;a_G3x;a_G3y;a_G4x;a_G4y;a_G5x;a_G5y;a_G6x;a_G6y;];

%% 力平衡方程式
FM = [F23x - F12x == a_G2x*m2;
    F23y - F12y - g*m2 == a_G2y*m2;
    CrossXY(0, - m2*g,b2*cos(phi2 + th2),b2*sin(phi2 + th2)) + CrossXY(F23x,F23y,R2*cos(th2),R2*sin(th2)) + M12 == alpha2*(I2 + b2^2*m2);
    F34x - F23x + F35x == a_G3x*m3;
    F34y - F23y + F35y - g*m3 == a_G3y*m3;
    CrossXY(F34x + F35x,F34y + F35y, - b3*cos(phi3 + th3), - b3*sin(phi3 + th3)) + CrossXY(-F23x,-F23y,R3*cos(th3) - b3*cos(phi3 + th3),R3*sin(th3) - b3*sin(phi3 + th3)) == alpha3*(I3);
    F45x - F34x - F14x == a_G4x*m4;
    F45y - F34y - F14y - g*m4 == a_G4y*m4;
    CrossXY(0, - m4*g,b4*cos(phi4 + th4),b4*sin(phi4 + th4)) + CrossXY(F45x - F34x,F45y - F34y,R4*cos(th4),R4*sin(th4)) == alpha4*(I4 + b4^2*m4);
    F56x - F45x - F35x == a_G5x*m5;
    F56y - F45y - F35y - g*m5 == a_G5y*m5;
    CrossXY(F56x,F56y, - b5*cos(phi5 + th5),-b5*sin(phi5 + th5)) + CrossXY(-F35x - F45x,-F35y - F45y,R5*cos(th5) - b5*cos(phi5 + th5),R5*sin(th5) - b5*sin(phi5 + th5)) == alpha5*(I5);
    -F16x - F56x - FPress == a_G6x*m6;
    -F16y - F56y - g*m6 == a_G6y*m6;
    -F34x - F35x - F45x == 0;
    -F34y - F35y - F45y == 0;
    FPress == 20;
    F16x == 0;
    M14 == 0;
    M16 == 0;
    F36x == 0;
    F36y == 0;];
SK = [F12x + F14x + F16x + FPress == FSKx;
    F12y + F14y + F16y == FSKy;
    -M12 + M14 + M16 + CrossXY(F14x,F14y,R7,-R8) + CrossXY(F16x + FPress,F16y,R1 + R7,-R8) == MSK;];

%% 結果儲存矩陣初始化
FPVA_matrix = zeros(360,12); % 位置、速度、加速度
GPVA_matrix = zeros(360,30); % 質心運動學
FM_matrix = zeros(360,22);
SK_matrix = zeros(360,3);
MA_matrix = zeros(360,1);

%%
FMVal = [F12x F12y F14x F14y F16x F16y F23x F23y F34x F34y F35x F35y F36x F36y F45x F45y F56x F56y FPress M12 M14 M16];

%% 主程式
for i = 1:360
    FPSol = Inis(i,:).'; % 從Excel讀取R1, th3, th4, th5從初始到結束的每一數值，並使用.'將行向量轉換為列向量 => FPSol 結構：[R1; th3; th4; th5] - 4×1向量)

    Unk = FV; 
    Unk = subs(Unk,th2,i*rad); % subs(表達式, 舊變數, 新值) - i代入函數
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.'); % 代入[R1; th3; th4; th5]數值進函數中
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[v1,omega3,omega4,omega5]);
    FVSol = UnkL\UnkR; % 解線性方程組 UnkL * FVSol = UnkR

    Unk = FA;
    Unk = subs(Unk,th2,i*rad);
    Unk = subs(Unk,alpha2,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[v1,omega3,omega4,omega5],FVSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[a1,alpha3,alpha4,alpha5]);
    FASol = UnkL\UnkR; % 解線性方程組

    Unk = r_G;
    Unk = subs(Unk,th2,i*rad);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = vpa(Unk);
    r_GSol = Unk;

    Unk = v_G;
    Unk = subs(Unk,th2,i*rad);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[v1,omega3,omega4,omega5],FVSol.');
    Unk = vpa(Unk);
    v_GSol = Unk;

    Unk = a_G;
    Unk = subs(Unk,th2,i*rad);
    Unk = subs(Unk,alpha2,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[v1,omega3,omega4,omega5],FVSol.');
    Unk = subs(Unk,[a1,alpha3,alpha4,alpha5],FASol.');
    Unk = vpa(Unk);
    a_GSol = Unk;

    Unk = FM;
    Unk = subs(Unk,th2,i*rad);
    Unk = subs(Unk,alpha2,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[v1,omega3,omega4,omega5],FVSol.');
    Unk = subs(Unk,[a1,alpha3,alpha4,alpha5],FASol.');
    Unk = subs(Unk,[a_G2x a_G2y a_G3x a_G3y a_G4x a_G4y a_G5x a_G5y a_G6x a_G6y],a_GSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,FMVal);
    FMSol = UnkL\UnkR;

    Unk = SK;
    Unk = subs(Unk,FMVal,FMSol.');
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[FSKx FSKy MSK]);
    SKSol = UnkL\UnkR;

    FPVA_matrix(i,:) = [FPSol;FVSol;FASol;].';
    GPVA_matrix(i,:) = [r_GSol;v_GSol;a_GSol;].';
    FM_matrix(i,:) = FMSol.';
    SK_matrix(i,:) = SKSol.';
    if mod(i, 30) == 0
            fprintf('進度: %d / %d\n', i, num_steps);
    end
end
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
%%
[~,th2Start] = min(abs(FPVA_matrix(:,1) - 0.706792));
R1Start = FPVA_matrix(th2Start,1);
fprintf("Press Start R1 = %.6g mm at th2 = %.6g deg\n",R1Start,th2Start);

%%
%{
timestep = 0.005;
th2last = 0;
th2dlast = 0;
th2ddlast = 0;
for t = 1:10/timestep
    del_th2d = th2ddlast*timestep;
    del_th2 = th2ddlast*timestep + 0.5*th2ddlast*timestep^2;
    omega2 = th2dlast + del_th2d;
    th2 = th2last + del_th2;

    th2ddlast = alpha2;
    th2dlast = omega2;
    th2last = th2;
end
%}

%%
FPVA_Name = ["R1","th3","th4","th5","v1","omega3","omega4","omega5","a1","alpha3","alpha4","alpha5"];
GPVA_Name = ["r_G2x","r_G2y","r_G3x","r_G3y","r_G4x","r_G4y","r_G5x","r_G5y","r_G6x","r_G6y",...
    "v_G2x","v_G2y","v_G3x","v_G3y","v_G4x","v_G4y","v_G5x","v_G5y","v_G6x","v_G6y",...
    "a_G2x","a_G2y","a_G3x","a_G3y","a_G4x","a_G4y","a_G5x","a_G5y","a_G6x","a_G6y"];
FM_Name = ["F12x","F12y","F14x","F14y","F16x","F16y","F23x","F23y","F34x","F34y","F35x","F35y","F36x","F36y","F45x","F45y","F56x","F56y","FPress","M12","M14","M16"];
SK_Name = ["FSKx","FSKy","MSK"];
MA_Name = ["MA"];

%%
FPVA_Unit = ["m","rad","rad","rad","m/s","rad/s","rad/s","rad/s","m/s^2","rad/s^2","rad/s^2","rad/s^2"];
GPVA_Unit = [repmat("m",1,10),repmat("m/s",1,10),repmat("m/s^2",1,10)];
KCFVA_Unit = ["m","ul","ul","ul","m","ul","ul","ul"];
KCGVA_Unit = [repmat("m",1,20)];
FM_Unit = [repmat("N",1,19),"Nm","Nm","Nm"];
SK_Unit = ["N","N","Nm"];
MA_Unit = ["ul"];
PEq_Unit = [repmat("kg*m^2",1,14)];
%% 結果輸出：將所有計算結果寫入Excel檔案
% 運動學
writematrix(FPVA_Name,ResultFileName,'Range','A1','Sheet','桿件位置速度加速度');
writematrix(FPVA_Unit,ResultFileName,'Range','A2','Sheet','桿件位置速度加速度');
writematrix(FPVA_matrix,ResultFileName,'Range','A3','Sheet','桿件位置速度加速度');

writematrix(GPVA_Name,ResultFileName,'Range','A1','Sheet','質心位置速度加速度');
writematrix(GPVA_Unit,ResultFileName,'Range','A2','Sheet','質心位置速度加速度');
writematrix(GPVA_matrix,ResultFileName,'Range','A3','Sheet','質心位置速度加速度');

% 動力學
writematrix(FM_Name,ResultFileName,'Range','A1','Sheet','靜力分析');
writematrix(FM_Unit,ResultFileName,'Range','A2','Sheet','靜力分析');
writematrix(FM_matrix,ResultFileName,'Range','A3','Sheet','靜力分析');

% 搖撼力
writematrix(SK_Name,ResultFileName,'Range','A1','Sheet','搖撼力');
writematrix(SK_Unit,ResultFileName,'Range','A2','Sheet','搖撼力');
writematrix(SK_matrix,ResultFileName,'Range','A3','Sheet','搖撼力');

%%
disp(TypeName + " Calculate Finished");
beep on;
beep;