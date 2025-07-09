# Six-Bar Linkage Inverse Design with Machine Learning

This project aims to implement an inverse design framework for six-bar linkage mechanisms using machine learning. The goal is to predict feasible linkage dimensions based on performance curves such as shaking moment, slider acceleration, mechanical advantage, and more.

## 📚 Project Overview

This study focuses on the Type 1A six-bar linkage configuration. By simulating various valid linkage combinations and extracting their corresponding performance metrics, we train a regression model that learns to infer optimal linkage parameters from target dynamic response curves.

## 🏗️ Structure

The project is divided into the following modules:

- `generate_dataset.py`  
   Generate training data by simulating forward kinematics & dynamics of six-bar linkages.

- `model_train.py`  
   Train a regression model to map performance curves to linkage parameters.

- `predict_design.py`  
   Given target curves, predict the most suitable linkage dimensions.

- `utils/`  
   Helper functions for physics-based simulation, loss functions, data pre-processing.

## 🧾 Parameters

Each linkage is described by:

- `L`: length (mm)  
- `b`: centroid distance (mm)  
- `m`: mass (kg)  
- `I`: moment of inertia (kg·mm²)  
- `θ`: initial angle (degrees)  

### Fixed Conditions:
- Type 1A configuration
- Double-toggle condition at slider stroke end
- Transmission angle = 75° at stroke end

## 🎯 Model Input (Given)

The input to the model consists of **n performance curves** with 72 points each, including:

- Slider Position
- Slider Velocity
- Slider Acceleration
- Mechanical Advantage (MA)
- Driving Force
- Driving Torque
- Shaking Force
- Shaking Moment

_Total input dimension = 72 × n_

## 🎯 Model Output (Obtain)

The predicted design parameters:

- R2: Crank length  
- R3: Coupler length  
- R7, R8: Secondary links  

Other parameters (mass, inertia) are computed from R automatically.

## 🧪 Performance Metrics

To evaluate predictions:

- Mean Squared Error (MSE) of shaking moment curve
- Max absolute error
- Dynamic curve similarity (e.g., DTW)
- Physical feasibility check (toggle effect, transmission angle)

## 🧠 Future Work

- Incorporate multi-type linkage generation (Watt, Stephenson)
- Add constraint filtering post-inference
- Explore generative models (VAE, GAN) for design suggestion

## 📝 Author

Willy Chen 
Department of Mechanical Engineering  
National Cheng Kung University
2025

---

## 使用方式

```bash
# 建立資料集
python generate_dataset.py

# 訓練模型
python model_train.py

# 輸入目標性能曲線，推估設計
python predict_design.py --input curves/sample.csv
