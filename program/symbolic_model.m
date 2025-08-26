function model = symbolic_model(params)
    % SYMBOLIC_MODEL - 定義機構的運動學與動力學符號方程式
    % 輸入: params - 包含桿長、質量等參數的結構體
    % 輸出: model - 包含所有符號方程式與變數的結構體

    %% 宣告符號變數 (運動學)
    syms R1 th2 th3 th4 th5
    syms v1 omega3 omega4 omega5
    syms a1 alpha3 alpha4 alpha5
    syms a_G2x a_G3x a_G4x a_G5x a_G6x
    syms a_G2y a_G3y a_G4y a_G5y a_G6y
    % 將符號變數存入 model 結構體中
    model.sym_pos = [R1; th3; th4; th5];
    model.sym_vel = [v1; omega3; omega4; omega5];
    model.sym_acc = [a1; alpha3; alpha4; alpha5];
    model.sym_aG = [a_G2x a_G2y a_G3x a_G3y a_G4x a_G4y a_G5x a_G5y a_G6x a_G6y];
    
    assume(R1,'real');
    assume([th3 th4 th5],'real');
    
    %% 宣告符號變數 (動力學)
    syms F12x F12y F14x F14y F16x F16y F23x F23y F34x F34y F35x F35y F36x F36y F45x F45y F56x F56y
    syms M12 M14 M16
    syms FSKx FSKy MSK FPress
    model.FMVal = [F12x F12y F14x F14y F16x F16y F23x F23y F34x F34y F35x F35y F36x F36y F45x F45y F56x F56y FPress M12 M14 M16];
    model.SKVal = [FSKx FSKy MSK];

    %% 運動學向量迴路方程式
    % 使用 params 結構體中的參數
    R2 = params.R2; R3 = params.R3; R4 = params.R4; R5 = params.R5; R7 = params.R7; R8 = params.R8;
    omega2 = params.omega2; alpha2 = params.alpha2;
    
    model.FP = [R1 - R4*cos(th4) + R5*cos(th5);
                R5*sin(th5) - R4*sin(th4);
                R7 - R2*cos(th2) + R3*cos(th3) + R4*cos(th4);
                R3*sin(th3) - R2*sin(th2) - R8 + R4*sin(th4)];
    model.FV = [v1 + R4*omega4*sin(th4) - R5*omega5*sin(th5);
                R5*omega5*cos(th5) - R4*omega4*cos(th4);
                R2*omega2*sin(th2) - R3*omega3*sin(th3) - R4*omega4*sin(th4);
                R3*omega3*cos(th3) - R2*omega2*cos(th2) + R4*omega4*cos(th4);];
    model.FA = [a1 + R4*(omega4^2*cos(th4) + alpha4*sin(th4)) - R5*(omega5^2*cos(th5) + alpha5*sin(th5));
                R4*(omega4^2*sin(th4) - alpha4*cos(th4)) - R5*(omega5^2*sin(th5) - alpha5*cos(th5));
                R2*(omega2^2*cos(th2) + alpha2*sin(th2)) - R3*(omega3^2*cos(th3) + alpha3*sin(th3)) - R4*(omega4^2*cos(th4) + alpha4*sin(th4));
                R2*(omega2^2*sin(th2) - alpha2*cos(th2)) - R3*(omega3^2*sin(th3) - alpha3*cos(th3)) - R4*(omega4^2*sin(th4) - alpha4*cos(th4));];

    % 質心位置
    r_G2x = -R7 + params.b2*cos(params.phi2 + th2);
    r_G2y = R8 + params.b2*sin(params.phi2 + th2);
    r_G3x = -R7 + R2*cos(th2) - R3*cos(th3) + params.b3*cos(params.phi3 + th3);
    r_G3y = R8 + R2*sin(th2) - R3*sin(th3) + params.b3*sin(params.phi3 + th3);
    r_G4x = params.b4*cos(params.phi4 + th4);
    r_G4y = params.b4*sin(params.phi4 + th4);
    r_G5x = R4*cos(th4) - R5*cos(th5) + params.b5*cos(params.phi5 + th5);
    r_G5y = R4*sin(th4) - R5*sin(th5) + params.b5*sin(params.phi5 + th5);
    r_G6x = R4*cos(th4) - R5*cos(th5) + params.b6*cos(params.phi6 + th5);
    r_G6y = R4*sin(th4) - R5*sin(th5) + params.b6*sin(params.phi6 + th5);
    
    % 質心速度
    v_G2x = -params.b2*sin(params.phi2 + th2)*omega2;
    v_G2y = params.b2*cos(params.phi2 + th2)*omega2;
    v_G3x = -R2*sin(th2)*omega2 + R3*sin(th3)*omega3 - params.b3*sin(params.phi3 + th3)*omega3;
    v_G3y = R2*cos(th2)*omega2 - R3*cos(th3)*omega3 + params.b3*cos(params.phi3 + th3)*omega3;
    v_G4x = -params.b4*sin(params.phi4 + th4)*omega4;
    v_G4y = params.b4*cos(params.phi4 + th4)*omega4;
    v_G5x = -R4*sin(th4)*omega4 + R5*sin(th5)*omega5 - params.b5*sin(params.phi5 + th5)*omega5;
    v_G5y = R4*cos(th4)*omega4 - R5*cos(th5)*omega5 + params.b5*cos(params.phi5 + th5)*omega5;
    v_G6x = -R4*sin(th4)*omega4 + R5*sin(th5)*omega5 - params.b6*sin(params.phi6 + th5)*omega5;
    v_G6y = R4*cos(th4)*omega4 - R5*cos(th5)*omega5 + params.b6*cos(params.phi6 + th5)*omega5;
    
    % 質心加速度
    a_G2x = -params.b2*sin(params.phi2 + th2)*alpha2 - params.b2*cos(params.phi2 + th2)*omega2^2;
    a_G2y = params.b2*cos(params.phi2 + th2)*alpha2 - params.b2*sin(params.phi2 + th2)*omega2^2;
    a_G3x = -R2*sin(th2)*alpha2 - R2*cos(th2)*omega2^2 + ...
            R3*sin(th3)*alpha3 + R3*cos(th3)*omega3^2 - ...
            params.b3*sin(params.phi3 + th3)*alpha3 - params.b3*cos(params.phi3 + th3)*omega3^2;
    a_G3y = R2*cos(th2)*alpha2 - R2*sin(th2)*omega2^2 - ...
            R3*cos(th3)*alpha3 + R3*sin(th3)*omega3^2 + ...
            params.b3*cos(params.phi3 + th3)*alpha3 - params.b3*sin(params.phi3 + th3)*omega3^2;
    a_G4x = -params.b4*sin(params.phi4 + th4)*alpha4 - params.b4*cos(params.phi4 + th4)*omega4^2;
    a_G4y = params.b4*cos(params.phi4 + th4)*alpha4 - params.b4*sin(params.phi4 + th4)*omega4^2;
    a_G5x = -R4*sin(th4)*alpha4 - R4*cos(th4)*omega4^2 + ...
            R5*sin(th5)*alpha5 + R5*cos(th5)*omega5^2 - ...
            params.b5*sin(params.phi5 + th5)*alpha5 - params.b5*cos(params.phi5 + th5)*omega5^2;
    a_G5y = R4*cos(th4)*alpha4 - R4*sin(th4)*omega4^2 - ...
            R5*cos(th5)*alpha5 + R5*sin(th5)*omega5^2 + ...
            params.b5*cos(params.phi5 + th5)*alpha5 - params.b5*sin(params.phi5 + th5)*omega5^2;
    a_G6x = -R4*sin(th4)*alpha4 - R4*cos(th4)*omega4^2 + ...
            R5*sin(th5)*alpha5 + R5*cos(th5)*omega5^2 - ...
            params.b6*sin(params.phi6 + th5)*alpha5 - params.b6*cos(params.phi6 + th5)*omega5^2;
    a_G6y = R4*cos(th4)*alpha4 - R4*sin(th4)*omega4^2 - ...
            R5*cos(th5)*alpha5 + R5*sin(th5)*omega5^2 + ...
            params.b6*cos(params.phi6 + th5)*alpha5 - params.b6*sin(params.phi6 + th5)*omega5^2;

    % 將所有方程式存入 model 結構體    
    %% 質心的位置、速度、加速度組織成向量形式，便於後續批量計算
    model.r_G = [r_G2x;r_G2y;r_G3x;r_G3y;r_G4x;r_G4y;r_G5x;r_G5y;r_G6x;r_G6y;];
    model.v_G = [v_G2x;v_G2y;v_G3x;v_G3y;v_G4x;v_G4y;v_G5x;v_G5y;v_G6x;v_G6y;];
    model.a_G = [a_G2x;a_G2y;a_G3x;a_G3y;a_G4x;a_G4y;a_G5x;a_G5y;a_G6x;a_G6y;];
   
    %% 力平衡方程式
    model.FM = [F23x - F12x == a_G2x*params.m2;
                F23y - F12y - params.g*params.m2 == a_G2y*params.m2;
                CrossXY(0, - params.m2*params.g,params.b2*cos(params.phi2 + th2),params.b2*sin(params.phi2 + th2)) + CrossXY(F23x,F23y,R2*cos(th2),R2*sin(th2)) + M12 == alpha2*(params.I2 + params.b2^2*params.m2);
                F34x - F23x + F35x == a_G3x*params.m3;
                F34y - F23y + F35y - params.g*params.m3 == a_G3y*params.m3;
                CrossXY(F34x + F35x,F34y + F35y, - params.b3*cos(params.phi3 + th3), - params.b3*sin(params.phi3 + th3)) + CrossXY(-F23x,-F23y,R3*cos(th3) - params.b3*cos(params.phi3 + th3),R3*sin(th3) - params.b3*sin(params.phi3 + th3)) == alpha3*(params.I3);
                F45x - F34x - F14x == a_G4x*params.m4;
                F45y - F34y - F14y - params.g*params.m4 == a_G4y*params.m4;
                CrossXY(0, - params.m4*params.g,params.b4*cos(params.phi4 + th4),params.b4*sin(params.phi4 + th4)) + CrossXY(F45x - F34x,F45y - F34y,R4*cos(th4),R4*sin(th4)) == alpha4*(params.I4 + params.b4^2*params.m4);
                F56x - F45x - F35x == a_G5x*params.m5;
                F56y - F45y - F35y - params.g*params.m5 == a_G5y*params.m5;
                CrossXY(F56x,F56y, - params.b5*cos(params.phi5 + th5),-params.b5*sin(params.phi5 + th5)) + CrossXY(-F35x - F45x,-F35y - F45y,R5*cos(th5) - params.b5*cos(params.phi5 + th5),R5*sin(th5) - params.b5*sin(params.phi5 + th5)) == alpha5*(params.I5);
                -F16x - F56x - FPress == a_G6x*params.m6;
                -F16y - F56y - params.g*params.m6 == a_G6y*params.m6;
                -F34x - F35x - F45x == 0;
                -F34y - F35y - F45y == 0;
                FPress == 20;
                F16x == 0;
                M14 == 0;
                M16 == 0;
                F36x == 0;
                F36y == 0;];
    model.SK = [F12x + F14x + F16x + FPress == FSKx;
                F12y + F14y + F16y == FSKy;
                -M12 + M14 + M16 + CrossXY(F14x,F14y,R7,-R8) + CrossXY(F16x + FPress,F16y,R1 + R7,-R8) == MSK;];
end