clc;
clear;
close;
cd;
%%
syms R1 th2 th3 th4 th5
syms R1d th2d th3d th4d th5d
syms R1dd th2dd th3dd th4dd th5dd
%%
syms ff12 hh22 hh32 hh42 hh52
syms ff12d hh22d hh32d hh42d hh52d
%%
syms F12x F12y F14x F14y F16x F16y F23x F23y F34x F34y F35x F35y F36x F36y F45x F45y F56x F56y
syms M12 M14 M16
syms FSKx FSKy MSK FPress
%%
syms aG2x aG3x aG4x aG5x aG6x
syms aG2y aG3y aG4y aG5y aG6y
%%
TypeName = "Type 1A";
BOMFileName = TypeName + " 總組合 組合1 BOM表.xlsx";
DimFileName = TypeName + " 尺寸表.xlsx";
IniFileName = TypeName + " 初始位置表.xlsx";
ResultFileName = TypeName + " 計算結果表.xlsx";
dtr = pi/180;
g = 9.81;
%%
BOMs = readmatrix(BOMFileName,'Range','A3');
Dims = readmatrix(DimFileName,'Range','B1:B15');
Inis = readmatrix(IniFileName,'Range','A1');
Inis = [Inis(:,1)*1e-3,Inis(:,2:4)*dtr];
%%
R2 = Dims(2)*1e-3;
R3 = Dims(3)*1e-3;
R4 = Dims(4)*1e-3;
R5 = Dims(5)*1e-3;
R7 = Dims(6)*1e-3;
R8 = Dims(7)*1e-3;
th6 = 0;
%%
m_mat = num2cell(BOMs(:,2));
b_mat = num2cell(BOMs(:,8)*1e-3);
phi_mat = num2cell(BOMs(:,9)*dtr);
I_mat = num2cell(BOMs(:,12)*1e-6);
[m1,m2,m3,m4,m5,m6] = m_mat{:};
[b1,b2,b3,b4,b5,b6] = b_mat{:};
[phi1,phi2,phi3,phi4,phi5,phi6] = phi_mat{:};
[I1,I2,I3,I4,I5,I6] = I_mat{:};
b6 = 0;
%%
FP = [R1 - R4*cos(th4) + R5*cos(th5);
    R5*sin(th5) - R4*sin(th4);
    R7 - R2*cos(th2) + R3*cos(th3) + R4*cos(th4);
    R3*sin(th3) - R2*sin(th2) - R8 + R4*sin(th4);];
FV = [R1d + R4*th4d*sin(th4) - R5*th5d*sin(th5);
    R5*th5d*cos(th5) - R4*th4d*cos(th4);
    R2*th2d*sin(th2) - R3*th3d*sin(th3) - R4*th4d*sin(th4);
    R3*th3d*cos(th3) - R2*th2d*cos(th2) + R4*th4d*cos(th4);];
FA = [R1dd + R4*(th4d^2*cos(th4) + th4dd*sin(th4)) - R5*(th5d^2*cos(th5) + th5dd*sin(th5));
    R4*(th4d^2*sin(th4) - th4dd*cos(th4)) - R5*(th5d^2*sin(th5) - th5dd*cos(th5));
    R2*(th2d^2*cos(th2) + th2dd*sin(th2)) - R3*(th3d^2*cos(th3) + th3dd*sin(th3)) - R4*(th4d^2*cos(th4) + th4dd*sin(th4));
    R2*(th2d^2*sin(th2) - th2dd*cos(th2)) - R3*(th3d^2*sin(th3) - th3dd*cos(th3)) - R4*(th4d^2*sin(th4) - th4dd*cos(th4));];
KCFV = [ff12 + R4*hh42*sin(th4) - R5*hh52*sin(th5);
    R5*hh52*cos(th5) - R4*hh42*cos(th4);
    R2*sin(th2) - R3*hh32*sin(th3) - R4*hh42*sin(th4);
    R3*hh32*cos(th3) - R2*cos(th2) + R4*hh42*cos(th4);];
KCFA = [ff12d + R4*(hh42d*sin(th4) + hh42^2*cos(th4)) - R5*(hh52d*sin(th5) + hh52^2*cos(th5));
    R4*(hh42^2*sin(th4) - hh42d*cos(th4)) - R5*(hh52^2*sin(th5) - hh52d*cos(th5));
    R2*cos(th2) - R3*(hh32d*sin(th3) + hh32^2*cos(th3)) - R4*(hh42d*sin(th4) + hh42^2*cos(th4));
    R2*sin(th2) - R3*(hh32^2*sin(th3) - hh32d*cos(th3)) - R4*(hh42^2*sin(th4) - hh42d*cos(th4));];
rG2x = b2*cos(phi2 + th2) - R7;
rG2y = R8 + b2*sin(phi2 + th2);
rG3x = b3*cos(phi3 + th3) + R4*cos(th4);
rG3y = b3*sin(phi3 + th3) + R4*sin(th4);
rG4x = b4*cos(phi4 + th4);
rG4y = b4*sin(phi4 + th4);
rG5x = b5*cos(phi5 + th5) + R4*cos(th4) - R5*cos(th5);
rG5y = b5*sin(phi5 + th5) + R4*sin(th4) - R5*sin(th5);
rG6x = b6*cos(phi6 + th6) + R4*cos(th4) - R5*cos(th5);
rG6y = b6*sin(phi6 + th6) + R4*sin(th4) - R5*sin(th5);
vG2x = -b2*th2d*sin(phi2 + th2);
vG2y = b2*th2d*cos(phi2 + th2);
vG3x = -R4*th4d*sin(th4) - b3*th3d*sin(phi3 + th3);
vG3y = b3*th3d*cos(phi3 + th3) + R4*th4d*cos(th4);
vG4x = -b4*th4d*sin(phi4 + th4);
vG4y = b4*th4d*cos(phi4 + th4);
vG5x = R5*th5d*sin(th5) - R4*th4d*sin(th4) - b5*th5d*sin(phi5 + th5);
vG5y = b5*th5d*cos(phi5 + th5) + R4*th4d*cos(th4) - R5*th5d*cos(th5);
vG6x = R5*th5d*sin(th5) - R4*th4d*sin(th4);
vG6y = R4*th4d*cos(th4) - R5*th5d*cos(th5);
aG2x = -b2*(th2dd*sin(phi2 + th2) + th2d^2*cos(phi2 + th2));
aG2y = b2*(th2dd*cos(phi2 + th2) - th2d^2*sin(phi2 + th2));
aG3x = -b3*(th3dd*sin(phi3 + th3) + th3d^2*cos(phi3 + th3)) - R4*(th4d^2*cos(th4) + th4dd*sin(th4));
aG3y = b3*(th3dd*cos(phi3 + th3) - th3d^2*sin(phi3 + th3)) - R4*(th4d^2*sin(th4) - th4dd*cos(th4));
aG4x = -b4*(th4dd*sin(phi4 + th4) + th4d^2*cos(phi4 + th4));
aG4y = b4*(th4dd*cos(phi4 + th4) - th4d^2*sin(phi4 + th4));
aG5x = R5*(th5d^2*cos(th5) + th5dd*sin(th5)) - R4*(th4d^2*cos(th4) + th4dd*sin(th4)) - b5*(th5dd*sin(phi5 + th5) + th5d^2*cos(phi5 + th5));
aG5y = b5*(th5dd*cos(phi5 + th5) - th5d^2*sin(phi5 + th5)) - R4*(th4d^2*sin(th4) - th4dd*cos(th4)) + R5*(th5d^2*sin(th5) - th5dd*cos(th5));
aG6x = R5*(th5d^2*cos(th5) + th5dd*sin(th5)) - R4*(th4d^2*cos(th4) + th4dd*sin(th4));
aG6y = R5*(th5d^2*sin(th5) - th5dd*cos(th5)) - R4*(th4d^2*sin(th4) - th4dd*cos(th4));
ffG22x = -b2*sin(phi2 + th2);
ffG22y = b2*cos(phi2 + th2);
ffG32x = -R4*hh42*sin(th4) - b3*hh32*sin(phi3 + th3);
ffG32y = b3*hh32*cos(phi3 + th3) + R4*hh42*cos(th4);
ffG42x = -b4*hh42*sin(phi4 + th4);
ffG42y = b4*hh42*cos(phi4 + th4);
ffG52x = R5*hh52*sin(th5) - R4*hh42*sin(th4) - b5*hh52*sin(phi5 + th5);
ffG52y = b5*hh52*cos(phi5 + th5) + R4*hh42*cos(th4) - R5*hh52*cos(th5);
ffG62x = R5*hh52*sin(th5) - R4*hh42*sin(th4);
ffG62y = R4*hh42*cos(th4) - R5*hh52*cos(th5);
ffG22xd = -b2*cos(phi2 + th2);
ffG22yd = -b2*sin(phi2 + th2);
ffG32xd = -b3*(hh32d*sin(phi3 + th3) + hh32^2*cos(phi3 + th3)) - R4*(hh42d*sin(th4) + hh42^2*cos(th4));
ffG32yd = b3*(hh32d*cos(phi3 + th3) - hh32^2*sin(phi3 + th3)) - R4*(hh42^2*sin(th4) - hh42d*cos(th4));
ffG42xd = -b4*(hh42d*sin(phi4 + th4) + hh42^2*cos(phi4 + th4));
ffG42yd = b4*(hh42d*cos(phi4 + th4) - hh42^2*sin(phi4 + th4));
ffG52xd = R5*(hh52d*sin(th5) + hh52^2*cos(th5)) - R4*(hh42d*sin(th4) + hh42^2*cos(th4)) - b5*(hh52d*sin(phi5 + th5) + hh52^2*cos(phi5 + th5));
ffG52yd = b5*(hh52d*cos(phi5 + th5) - hh52^2*sin(phi5 + th5)) - R4*(hh42^2*sin(th4) - hh42d*cos(th4)) + R5*(hh52^2*sin(th5) - hh52d*cos(th5));
ffG62xd = R5*(hh52d*sin(th5) + hh52^2*cos(th5)) - R4*(hh42d*sin(th4) + hh42^2*cos(th4));
ffG62yd = R5*(hh52^2*sin(th5) - hh52d*cos(th5)) - R4*(hh42^2*sin(th4) - hh42d*cos(th4));

%%
FM = [F23x - F12x == aG2x*m2;
    F23y - F12y - g*m2 == aG2y*m2;
    CrossXY(0,-m2*g,b2*cos(th2 + phi2),b2*sin(th2 + phi2)) + CrossXY(F23x,F23y,R2*cos(th2),R2*sin(th2)) + M12 == th2dd*(I2 + b2^2*m2);
    F34x - F23x + F35x == aG3x*m3;
    F34y - F23y + F35y - g*m3 == aG3y*m3;
    CrossXY(F34x + F35x,F34y + F35y,-b3*cos(th3 + phi3),-b3*sin(th3 + phi3)) + CrossXY(-F23x,-F23y,R3*cos(th3) - b3*cos(th3 + phi3),R3*sin(th3) - b3*sin(th3 + phi3)) == th3dd*(I3);
    F45x - F34x - F14x == aG4x*m4;
    F45y - F34y - F14y - g*m4 == aG4y*m4;
    CrossXY(0,-m4*g,b4*cos(th4 + phi4),b4*sin(th4 + phi4)) + CrossXY(F45x - F34x,F45y - F34y,R4*cos(th4),R4*sin(th4)) == th4dd*(I4 + b4^2*m4);
    F56x - F45x - F35x == aG5x*m5;
    F56y - F45y - F35y - g*m5 == aG5y*m5;
    CrossXY(F56x,F56y,-b5*cos(th5 + phi5),-b5*sin(th5 + phi5)) + CrossXY(-F35x - F45x,-F35y - F45y,R5*cos(th5) - b5*cos(th5 + phi5),R5*sin(th5) - b5*sin(th5 + phi5)) == th5dd*(I5);
    -F16x - F56x - FPress == aG6x*m6;
    -F16y - F56y - g*m6 == aG6y*m6;
    -F34x - F35x - F45x == 0;
    -F34y - F35y - F45y == 0;
    FPress == 20;
    F16x == 0;
    M14 == 0;
    M16 == 0;
    F36x == 0;
    F36y == 0;];
SK=[F12x + F14x + F16x + FPress == FSKx;
    F12y + F14y + F16y == FSKy;
    -M12 + M14 + M16 + CrossXY(F14x,F14y,R7,-R8) + CrossXY(F16x + FPress,F16y,R1 + R7,-R8) == MSK;];
%%
hh22 = 1;
hh22d = 0;
hh62 = 0;
hh62d = 0;
AR2 = I2*hh22^2 + m2*(ffG22x^2 + ffG22y^2);
AR3 = I3*hh32^2 + m3*(ffG32x^2 + ffG32y^2);
AR4 = I4*hh42^2 + m4*(ffG42x^2 + ffG42y^2);
AR5 = I5*hh52^2 + m5*(ffG52x^2 + ffG52y^2);
AR6 = I6*hh62^2 + m6*(ffG62x^2 + ffG62y^2);
BR2 = m2*(ffG22x*ffG22xd + ffG22y*ffG22yd) + I2*hh22*hh22d;
BR3 = m3*(ffG32x*ffG32xd + ffG32y*ffG32yd) + I3*hh32*hh32d;
BR4 = m4*(ffG42x*ffG42xd + ffG42y*ffG42yd) + I4*hh42*hh42d;
BR5 = m5*(ffG52x*ffG52xd + ffG52y*ffG52yd) + I5*hh52*hh52d;
BR6 = m6*(ffG62x*ffG62xd + ffG62y*ffG62yd) + I6*hh62*hh62d;
%%
Imo = 1.979; % 馬達轉動慣量 kg*m^2
hhmo2 = 1; % 馬達運動係數 kg*m^2
Amo = Imo*hhmo2^2;
Bmo = 0;
SigmaA = AR2 + AR3 + AR4 + AR5 + AR6 + Amo;
SigmaB = BR2 + BR3 + BR4 + BR5 + BR6 + Bmo;
%%
rG = [rG2x;rG2y;rG3x;rG3y;rG4x;rG4y;rG5x;rG5y;rG6x;rG6y;];
vG = [vG2x;vG2y;vG3x;vG3y;vG4x;vG4y;vG5x;vG5y;vG6x;vG6y;];
aG = [aG2x;aG2y;aG3x;aG3y;aG4x;aG4y;aG5x;aG5y;aG6x;aG6y;];
KCGV = [ffG22x;ffG22y;ffG32x;ffG32y;ffG42x;ffG42y;ffG52x;ffG52y;ffG62x;ffG62y;];
KCGA = [ffG22xd;ffG22yd;ffG32xd;ffG32yd;ffG42xd;ffG42yd;ffG52xd;ffG52yd;ffG62xd;ffG62yd;];
PEq = [AR2;AR3;AR4;AR5;AR6;Amo;BR2;BR3;BR4;BR5;BR6;Bmo;SigmaA;SigmaB];
%%
FPVA_matrix = zeros(420,12);
GPVA_matrix = zeros(420,30);
KCFVA_matrix = zeros(420,8);
KCGVA_matrix = zeros(420,20);
FM_matrix = zeros(420,22);
SK_matrix = zeros(420,3);
MA_matrix = zeros(420,1);
PEq_matrix = zeros(420,14);
%%
FMVal = [F12x F12y F14x F14y F16x F16y F23x F23y F34x F34y F35x F35y F36x F36y F45x F45y F56x F56y FPress M12 M14 M16];
%%
for i=1:420
    if mod(i,10)==0
        fprintf("th2= %g deg\n",i);
    end
%     Unk = FP;
%     Unk = subs(Unk,th2,i*dtr);
%     Unk = vpa(Unk);
%     guessFP = Inis(ceil(i/90),:);
%     [R1Sol,th3Sol,th4Sol,th5Sol] = vpasolve(Unk,[R1,th3,th4,th5],guessFP);
%     FPSol = [R1Sol;th3Sol;th4Sol;th5Sol];
    FPSol = Inis(i,:).';

    Unk = FV;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[R1d,th3d,th4d,th5d]); % 將Unk轉換成矩陣形式，並按照指定的未知數 [R1d,th3d,th4d,th5d]，重組成標準的矩陣形式UnkL * [R1d,th3d,th4d,th5d] = UnkR
    FVSol = UnkL\UnkR; % 解線性方程組 UnkL * FVSol = UnkR

    Unk = FA;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,th2dd,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[R1dd,th3dd,th4dd,th5dd]);
    FASol = UnkL\UnkR;

    Unk = rG;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = vpa(Unk);
    rGSol = Unk;

    Unk = vG;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = vpa(Unk);
    vGSol = Unk;

    Unk = aG;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,th2dd,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = subs(Unk,[R1dd,th3dd,th4dd,th5dd],FASol.');
    Unk = vpa(Unk);
    aGSol = Unk;

    Unk = KCFV;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[ff12,hh32,hh42,hh52]);
    KCFVSol = UnkL\UnkR;

    Unk = KCFA;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,th2dd,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = subs(Unk,[ff12,hh32,hh42,hh52],KCFVSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[ff12d,hh32d,hh42d,hh52d]);
    KCFASol = UnkL\UnkR;

    Unk = KCGV;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = subs(Unk,[ff12,hh32,hh42,hh52],KCFVSol.');
    Unk = vpa(Unk);
    KCGVSol = Unk;

    Unk = KCGA;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,th2dd,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = subs(Unk,[R1dd,th3dd,th4dd,th5dd],FASol.');
    Unk = subs(Unk,[ff12,hh32,hh42,hh52],KCFVSol.');
    Unk = subs(Unk,[ff12d,hh32d,hh42d,hh52d],KCFASol.');
    Unk = vpa(Unk);
    KCGASol = Unk;

    Unk = FM;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,th2d,420*dtr);
    Unk = subs(Unk,th2dd,0);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[R1d,th3d,th4d,th5d],FVSol.');
    Unk = subs(Unk,[R1dd,th3dd,th4dd,th5dd],FASol.');
    Unk = subs(Unk,[aG2x aG2y aG3x aG3y aG4x aG4y aG5x aG5y aG6x aG6y],aGSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,FMVal);
    FMSol = UnkL\UnkR;

    Unk = SK;
    Unk = subs(Unk,FMVal,FMSol.');
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = vpa(Unk);
    [UnkL,UnkR] = equationsToMatrix(Unk,[FSKx FSKy MSK]);
    SKSol = UnkL\UnkR;
    
    Unk = PEq;
    Unk = subs(Unk,th2,i*dtr);
    Unk = subs(Unk,[R1,th3,th4,th5],FPSol.');
    Unk = subs(Unk,[ff12,hh32,hh42,hh52],KCFVSol.');
    Unk = subs(Unk,[ff12d,hh32d,hh42d,hh52d],KCFASol.');
    Unk = vpa(Unk);
    PEqSol = Unk;

    FPVA_matrix(i,:) = [FPSol;FVSol;FASol;].';
    GPVA_matrix(i,:) = [rGSol;vGSol;aGSol;].';
    KCFVA_matrix(i,:) = [KCFVSol;KCFASol;].';
    KCGVA_matrix(i,:) = [KCGVSol;KCGASol;].';
    FM_matrix(i,:) = FMSol.';
    SK_matrix(i,:) = SKSol.';
    PEq_matrix(i,:) = PEqSol.';
end
%%
[R1Max,th2Max] = max(FPVA_matrix(:,1));
[R1Min,th2Min] = min(FPVA_matrix(:,1)); % 回傳數值及索引值(對應角度)
if th2Min > 360
    th2Min = th2Min - 360;
end
R1TotalStroke = R1Max - R1Min;
th2TotalStroke = th2Max - th2Min;
fprintf("Maximum R1= %.6g mm at th2= %.6g deg\n",R1Max,th2Max);
fprintf("Minimum R1= %.6g mm at th2= %.6g deg\n",R1Min,th2Min);
fprintf("Total Stroke R1=%.6g mm\n",R1TotalStroke);
fprintf("Total Stroke th2=%.6g deg\n",th2TotalStroke);
%%
[~,th2Start] = min(abs(FPVA_matrix(:,1)-0.706792));
R1Start = FPVA_matrix(th2Start,1);
fprintf("Press Start R1= %.6g mm at th2= %.6g deg\n",R1Start,th2Start);
%%
ff12Sol = KCFVA_matrix(:,1);
R1TotalStroke = 1;
MA_matrix = R1TotalStroke./ff12Sol;
%%
%{
timestep = 0.005;
th2last = 0;
th2dlast = 0;
th2ddlast = 0;
for t=1:10/timestep
    del_th2d = th2ddlast*timestep;
    del_th2 = th2ddlast*timestep + 0.5*th2ddlast*timestep^2;
    th2d = th2dlast + del_th2d;
    th2 = th2last + del_th2;

    th2ddlast = th2dd;
    th2dlast = th2d;
    th2last = th2;
end
%}
%%
FPVA_Name = ["R1","th3","th4","th5","R1d","th3d","th4d","th5d","R1dd","th3dd","th4dd","th5dd"];
GPVA_Name = ["rG2x","rG2y","rG3x","rG3y","rG4x","rG4y","rG5x","rG5y","rG6x","rG6y",...
    "vG2x","vG2y","vG3x","vG3y","vG4x","vG4y","vG5x","vG5y","vG6x","vG6y",...
    "aG2x","aG2y","aG3x","aG3y","aG4x","aG4y","aG5x","aG5y","aG6x","aG6y"];
KCFVA_Name = ["ff12","hh32","hh42","hh52","ff12d","hh32d","hh42d","hh52d"];
KCGVA_Name = ["ffG22x","ffG22y","ffG32x","ffG32y","ffG42x","ffG42y","ffG52x","ffG52y","ffG62x","ffG62y",...
    "ffG22xd","ffG22yd","ffG32xd","ffG32yd","ffG42xd","ffG42yd","ffG52xd","ffG52yd","ffG62xd","ffG62yd"];
FM_Name = ["F12x","F12y","F14x","F14y","F16x","F16y","F23x","F23y","F34x","F34y","F35x","F35y","F36x","F36y","F45x","F45y","F56x","F56y","FPress","M12","M14","M16"];
SK_Name = ["FSKx","FSKy","MSK"];
MA_Name = ["MA"];
PEq_Name = ["AR2","AR3","AR4","AR5","AR6","Amo","BR2","BR3","BR4","BR5","BR6","Bmo","SigmaA","SigmaB"];
%%
FPVA_Unit = ["m","rad","rad","rad","m/s","rad/s","rad/s","rad/s","m/s^2","rad/s^2","rad/s^2","rad/s^2"];
GPVA_Unit = [repmat("m",1,10),repmat("m/s",1,10),repmat("m/s^2",1,10)];
KCFVA_Unit = ["m","ul","ul","ul","m","ul","ul","ul"];
KCGVA_Unit = [repmat("m",1,20)];
FM_Unit = [repmat("N",1,19),"Nm","Nm","Nm"];
SK_Unit = ["N","N","Nm"];
MA_Unit = ["ul"];
PEq_Unit=[repmat("kg*m^2",1,14)];
%%
writematrix(FPVA_Name,ResultFileName,'Range','A1','Sheet','桿件位置速度加速度');
writematrix(FPVA_Unit,ResultFileName,'Range','A2','Sheet','桿件位置速度加速度');
writematrix(FPVA_matrix,ResultFileName,'Range','A3','Sheet','桿件位置速度加速度');
%%
writematrix(GPVA_Name,ResultFileName,'Range','A1','Sheet','質心位置速度加速度');
writematrix(GPVA_Unit,ResultFileName,'Range','A2','Sheet','質心位置速度加速度');
writematrix(GPVA_matrix,ResultFileName,'Range','A3','Sheet','質心位置速度加速度');
%%
writematrix(KCFVA_Name,ResultFileName,'Range','A1','Sheet','桿件運動係數');
writematrix(KCFVA_Unit,ResultFileName,'Range','A2','Sheet','桿件運動係數');
writematrix(KCFVA_matrix,ResultFileName,'Range','A3','Sheet','桿件運動係數');
%%
writematrix(KCGVA_Name,ResultFileName,'Range','A1','Sheet','質心運動係數');
writematrix(KCGVA_Unit,ResultFileName,'Range','A2','Sheet','質心運動係數');
writematrix(KCGVA_matrix,ResultFileName,'Range','A3','Sheet','質心運動係數');
%%
writematrix(FM_Name,ResultFileName,'Range','A1','Sheet','靜力分析');
writematrix(FM_Unit,ResultFileName,'Range','A2','Sheet','靜力分析');
writematrix(FM_matrix,ResultFileName,'Range','A3','Sheet','靜力分析');
%%
writematrix(SK_Name,ResultFileName,'Range','A1','Sheet','搖撼力');
writematrix(SK_Unit,ResultFileName,'Range','A2','Sheet','搖撼力');
writematrix(SK_matrix,ResultFileName,'Range','A3','Sheet','搖撼力');
%%
writematrix(MA_Name,ResultFileName,'Range','A1','Sheet','機械利益');
writematrix(MA_Unit,ResultFileName,'Range','A2','Sheet','機械利益');
writematrix(MA_matrix,ResultFileName,'Range','A3','Sheet','機械利益');
%%
writematrix(PEq_Name,ResultFileName,'Range','A1','Sheet','動力式係數');
writematrix(PEq_Unit,ResultFileName,'Range','A2','Sheet','動力式係數');
writematrix(PEq_matrix,ResultFileName,'Range','A3','Sheet','動力式係數');
%%
disp(TypeName + " Calculate Finished");
beep on;
beep;