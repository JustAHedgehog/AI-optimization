% --- 基本設定 ---
R1 = 740.0       % 滑塊終點位置 (mm)
R4 = 100.0       % 固定桿長 (mm)
R5 = 640.0       % 固定桿長 (mm)
angle_samples = np.radians(np.arange(0, 360, 5))  % 每 5 度一筆，共 72 點


R2 = 0
R3 = 0
R7 = 0
R8 = 0

b2 = 0
b3 = 0
b4 = 0
b5 = 0
b6 = 0

phi2 = 0; phi3 = 0; phi4 = 0; phi5 = 0; phi6 = 0

theta_2 = linspace(0, 2*pi, 72);
theta_3 = zeros(size(theta_2));
for i = 1:length(theta_2)
    t2 = theta_2(i);
    x0 = [1.0];  % 初始猜測
    theta_3(i) = fsolve(@(x) loop_eq(x, t2), x0);
end

% 六連桿機構運動學：矩陣形式表示

%% 1. 位置方程式 (4條 loop closure)
% f1 = R7 + R4a*cos(theta4 + theta4a) - R2*cos(theta2) + R3*cos(theta3) = 0
% f2 = R4a*sin(theta4 + theta4a) - R8 - R2*sin(theta2) + R3*sin(theta3) = 0
% f3 = R1 - R4*cos(theta4) + R5*cos(theta5) = 0
% f4 = R5*sin(theta5) - R4*sin(theta4) = 0

syms theta3 theta4 theta4a theta5

F_pos = [
    R7 + R4a*cos(theta4 + theta4a) - R2*cos(theta2) + R3*cos(theta3);
    R4a*sin(theta4 + theta4a) - R8 - R2*sin(theta2) + R3*sin(theta3);
    R1 - R4*cos(theta4) + R5*cos(theta5);
    R5*sin(theta5) - R4*sin(theta4)
];

%% 2. 速度方程式：J * dtheta = rhs
% J_v * [dtheta3; dtheta4; dtheta5; dR1] = rhs
J_v = [
    -R3*sin(theta3), -R4a*sin(theta4 + theta4a),  0,             0;
     R3*cos(theta3),  R4a*cos(theta4 + theta4a),  0,             0;
     0,               R4*sin(theta4),            -R5*sin(theta5), 1;
     0,              -R4*cos(theta4),             R5*cos(theta5), 0
];

rhs_v = [
    R2*dot_theta2*sin(theta2);
    R2*dot_theta2*cos(theta2);
   -R4*dot_theta4*sin(theta4) + R5*dot_theta5*sin(theta5) - dot_R1;
    R4*dot_theta4*cos(theta4) - R5*dot_theta5*cos(theta5)
];

%% 3. 加速度方程式：J * ddtheta + dJ * dtheta^2 = rhs
% 包含科氏項與平方速度項
rhs_a = [
    R2*(dot_theta2^2*cos(theta2) + ddot_theta2*sin(theta2))
      - R4a*(ddot_theta4*sin(theta4 + theta4a) + dot_theta4^2*cos(theta4 + theta4a))
      - R3*(dot_theta3^2*cos(theta3) + ddot_theta3*sin(theta3));

    R4a*(ddot_theta4*cos(theta4 + theta4a) - dot_theta4^2*sin(theta4 + theta4a))
      + R2*(dot_theta2^2*sin(theta2) - ddot_theta2*cos(theta2))
      - R3*(dot_theta3^2*sin(theta3) - ddot_theta3*cos(theta3));

    ddot_R1 + R4*(dot_theta4^2*cos(theta4) + ddot_theta4*sin(theta4))
      - R5*(dot_theta5^2*cos(theta5) + ddot_theta5*sin(theta5));

    R4*(dot_theta4^2*sin(theta4) - ddot_theta4*cos(theta4))
      - R5*(dot_theta5^2*sin(theta5) - ddot_theta5*cos(theta5))
];

%% 4. 質心位置向量 (可用於慣性力)
rG_2 = [-R7 + b2*cos(phi2 + theta2);
         R8 + b2*sin(phi2 + theta2)];

rG_3 = [-R7 + R2*cos(theta2) - R3*cos(theta3) + b3*cos(phi3 + theta3);
         R8 + R2*sin(theta2) - R3*sin(theta3) + b3*sin(phi3 + theta3)];

rG_4 = [b4*cos(phi4 + theta4);
         b4*sin(phi4 + theta4)];

rG_5 = [R4*cos(theta4) - R5*cos(theta5) + b5*cos(phi5 + theta5);
         R4*sin(theta4) - R5*sin(theta5) + b5*sin(phi5 + theta5)];

rG_6 = [R4*cos(theta4) - R5*cos(theta5) + b6*cos(phi6 + theta6);
         R4*sin(theta4) - R5*sin(theta5) + b6*sin(phi6 + theta6)];

%% 5. 質心加速度 (a = alpha x r - omega^2 * r)
aG_2 = [
    -b2*(ddot_theta2*sin(phi2 + theta2) + dot_theta2^2*cos(phi2 + theta2));
     b2*(ddot_theta2*cos(phi2 + theta2) - dot_theta2^2*sin(phi2 + theta2))
];

aG_3 = [
    R3*(dot_theta3^2*cos(theta3) + ddot_theta3*sin(theta3)) - R2*(dot_theta2^2*cos(theta2) + ddot_theta2*sin(theta2))
      - b3*(ddot_theta3*sin(phi3 + theta3) + dot_theta3^2*cos(phi3 + theta3));

    b3*(ddot_theta3*cos(phi3 + theta3) - dot_theta3^2*sin(phi3 + theta3))
      - R2*(dot_theta2^2*sin(theta2) - ddot_theta2*cos(theta2)) + R3*(dot_theta3^2*sin(theta3) - ddot_theta3*cos(theta3))
];

% 其餘 aG_4, aG_5, aG_6 依相同方式展開
