import numpy as np
import pandas as pd
from scipy.optimize import fsolve
import matplotlib.pyplot as plt

# --- 基本設定 ---
R1 = 740.0       # 滑塊終點位置 (mm)
R4 = 100.0       # 固定桿長 (mm)
R5 = 640.0       # 固定桿長 (mm)
angle_samples = np.radians(np.arange(0, 360, 5))  # 每 5 度一筆，共 72 點

# --- 桿件質量與轉動慣量 ---
def compute_bar_parameter(R):
    w = 100 # mm
    t = 100 # mm
    density = 7850*1e-9 # kg/mm^3
    m = R * w * t * density # m = R * w * t * density
    Iz_cen = 1/12 * m * (R**2 + t**2) # I = 1/12 * m * (L^2 + t^2) TODO 坐標系平移
    b = 0.3 * R  # 假設質量中心在桿件中點 TODO 實際上不可能這樣
    return m, Iz_cen, b

# --- 解機構位置方程式，得到 θ3~θ6 ---
def solve_angles(R2, R3, R7, R8, θ2):
    def loop_eqs(x):
        θ3, θ4, θ5, θ6 = x
        eq1 = R7 - R2* np.cos(θ2) + R3 * np.cos(θ3) + R4 * np.cos(θ4)
        eq2 = R3 * np.sin(θ3) - R2* np.sin(θ2) - R8 + R4 * np.sin(θ4)
        eq3 = R1 - R4 * np.cos(θ5) - R5 * np.cos(θ4)
        eq4 = R5 * np.sin(θ5) - R4 * np.sin(θ4)
        return [eq1, eq2, eq3, eq4]

    x0 = [np.radians(80), np.radians(155), np.radians(110), np.radians(90)] # 設定每一個參數的初始猜測值以便收斂
    
    try:
        result = fsolve(loop_eqs, x0) # 在x0設定的初始值下，使用 fsolve 解方程組
        if np.isclose(loop_eqs(result), [0, 0, 0, 0], atol=1e-6).all(): # atol為設定解容許的絕對閾值；.all()判斷np.isclose回傳的布林陣列是否全部都為True
            return result
    except:
        return None # 若無法收斂，則返回 None

# --- 計算單一姿態的搖撼力矩 ---
def compute_shaking_moment(R2, R3, R6, R7, R8, θ2):
    angles = solve_angles(R2, R3, R7, R8, θ2)
    if angles is None or np.any(np.isnan(angles)):
        return None
    θ3, θ4, θ5, θ6 = angles

    m2, I2, b2 = compute_bar_parameter(R2)
    m3, I3, b3 = compute_bar_parameter(R3)
    m5, I5, b5 = compute_bar_parameter(R5)
    m6, I6, b6 = compute_bar_parameter(R6)

    # 目前簡化為轉動慣量總和（尚未加入 aG）
    M_shaking = I2 + I3 + I5 + I6 # TODO 還沒設定好
    return M_shaking

# --- 模擬 θ2 一整圈，回傳最大搖撼力矩 ---
def compute_max_shaking_moment(R2, R3, R7, R8):
    R6 = 200  # 滑塊等效長度，暫定固定
    max_M = 0
    for theta2 in angle_samples:
        M = compute_shaking_moment(R2, R3, R6, R7, R8, theta2)
        if M is not None:
            max_M = max(max_M, abs(M))
    return max_M

# === 限制條件檢查 ===
def is_valid_type1A(R2, R3, R7, R8):
    R6 = 200
    theta2 = 0  # 沖壓結束時
    try:
        θ3, θ4, θ5, θ6 = solve_angles(R2, R3, R7, R8, theta2)

        # 條件 2: 檢查雙肘節效應（θ4 與 θ5 幾乎共線）
        elbow_effect = np.abs(np.degrees(θ5 - θ4))
        if not (170 <= elbow_effect <= 190):  # 近似180度
            return False

        # 條件 3: 傳力角（R3 vs R4）為 75°
        # 夾角 = θ3 - θ4（或反過來，取絕對值）
        trans_angle = np.abs(np.degrees(θ3 - θ4)) % 180
        if not (70 <= trans_angle <= 80):
            return False

        return True
    except:
        return False

# --- 建立資料集 ---
def generate_dataset(n=500):
    data = []
    count = 0
    while count < n:
        R2 = np.random.uniform(40, 200)
        R3 = np.random.uniform(200, 800)
        R7 = np.random.uniform(50, 250)
        R8 = np.random.uniform(200, 900)

        # 加入 Type 1A 限制條件
        if not is_valid_type1A(R2, R3, R7, R8):
            continue

        max_moment = compute_max_shaking_moment(R2, R3, R7, R8)
        data.append([R2, R3, R7, R8, max_moment])
        count += 1

        if (count + 1) % 50 == 0:
            print(f"已完成 {count+1}/{n} 筆")

    df = pd.DataFrame(data, columns=["R2", "R3", "R7", "R8", "Max_Shaking_Moment"])
    return df


# --- 主程式 ---
if __name__ == "__main__":
    df = generate_dataset(n=500)
    df.to_csv("type1A_shaking_dataset.csv", index=False)
    print("✅ 資料集儲存完成：type1A_shaking_dataset.csv")

    # 額外：簡單視覺化
    df["Max_Shaking_Moment"].hist(bins=30)
    plt.title("Max Shaking Moment Distribution")
    plt.xlabel("Shaking Moment")
    plt.ylabel("Count")
    plt.grid(True)
    plt.show()
    plt.savefig('data_distribution.png')
