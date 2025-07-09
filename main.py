import pandas as pd
import numpy as np
from lightgbm import LGBMRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error

# ========== 模型訓練 ========== #
def train_inverse_model(csv_path="type1A_shaking_dataset.csv"):
    df = pd.read_csv(csv_path)
    
    # X 是搖撼力矩、y 是桿件長度
    X = df[["Max_Shaking_Moment"]]
    y = df[["R2", "R3", "R7", "R8"]]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = MultiOutputRegressor(LGBMRegressor(n_estimators=200, learning_rate=0.05))
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    print(f"✅ 模型訓練完成，測試集 MSE: {mse:.2f}")

    return model

# ========== 設計參數預測器 ========== #
def predict_designs(model: MultiOutputRegressor, target_moment, top_n=5, perturb_std=1000):
    # 使用高斯微擾產生相近但不同的輸入
    target_array = np.random.normal(loc=target_moment, scale=perturb_std, size=(1000, 1))
    preds = model.predict(target_array)

    pred_df = pd.DataFrame(preds, columns=["R2", "R3", "R7", "R8"])
    pred_df = pred_df.round(2).drop_duplicates()

    print(f"🔍 預測完成，輸入目標搖撼力矩：{target_moment}")
    print(f"📊 預測到 {len(pred_df)} 組設計參數。")
    return pred_df.head(top_n)

# ========== 推論參數範圍條件式（選用） ========== #
def analyze_ranges(df_result: pd.DataFrame):
    print("📏 推薦設計參數範圍：")
    for col in df_result.columns:
        min_val = df_result[col].min()
        max_val = df_result[col].max()
        print(f"{col} ∈ [{min_val:.2f}, {max_val:.2f}]")

if __name__ == "__main__":
    model = train_inverse_model()
    target_m = float(input("請輸入你期望的搖撼力矩 (N·mm): "))
    
    top_designs = predict_designs(model, target_m, top_n=5)
    print(f"\n✨ 推薦前 {len(top_designs)} 組設計參數：")
    print(top_designs.to_string(index=False))

    print('===='*6)
    # 額外分析範圍
    analyze_ranges(top_designs)
