# 🚗 Car Price Prediction Using Big Data Analytics

## 📋 Overview

This project applies the complete Big Data Analytics lifecycle to predict car prices using machine learning techniques. By analyzing 19,237 car listings with 18 different features, we built predictive models to help dealerships, buyers, and insurance companies make better pricing decisions.

### 🎯 Project Objectives

- Clean and preprocess a large-scale car dataset
- Detect and handle outliers and missing values
- Explore relationships between car features and pricing
- Test statistical hypotheses about factors affecting car prices
- Build and compare multiple prediction models (Linear Regression, Decision Tree, Random Forest)
- Identify the most important features that determine car prices
- Evaluate model performance using RMSE and R² metrics

---

## 🗂️ Dataset

**Source**: Used Cars Dataset  
**Size**: 19,237 car records  
**Features**: 18 attributes (numeric + categorical)

### Key Features:

**Numeric Features:**
- 💰 **Price**: Car selling price (target variable)
- 📊 **Levy**: Tax/fee associated with the car
- ⚙️ **Engine Volume**: Engine displacement in liters
- 🛣️ **Mileage**: Distance travelled by the car (km)
- 📅 **Production Year**: Year the car was manufactured
- 🔢 **Cylinders**: Number of engine cylinders
- 🚪 **Doors**: Number of doors
- 🛡️ **Airbags**: Number of airbags

**Categorical Features:**
- 🏭 **Manufacturer**: Car manufacturer (e.g., Toyota, BMW, Mercedes)
- 🚙 **Model**: Specific car model
- 📦 **Category**: Vehicle category (SUV, Sedan, Hatchback, etc.)
- ⛽ **Fuel Type**: Type of fuel used (Petrol, Diesel, Hybrid, etc.)
- ⚙️ **Gear Box Type**: Manual, Automatic, or Tiptronic
- 🎨 **Color**: Exterior color
- 🪑 **Leather Interior**: Yes/No
- 🚗 **Drive Wheels**: Front, Rear, or 4x4
- 🔧 **Turbo**: Whether the engine has a turbo

**Dataset File**: `Cars_Prices.csv`

---

## 🛠️ Installation

### Prerequisites
- R 4.0 or higher
- RStudio (recommended)

### Clone the Repository

```bash
git clone https://github.com/karimsamer100/Car-Price-Prediction-Using-Big-Data-Analytics-R-.git
cd Car-Price-Prediction
```

### Install Required R Packages

Open R or RStudio and run:

```r
install.packages(c("tidyverse", "rpart", "rpart.plot", "randomForest"))
```

### Required Libraries
```r
tidyverse      # Data manipulation and visualization
rpart          # Decision tree models
rpart.plot     # Visualizing decision trees
randomForest   # Random Forest machine learning model
```

---

## 🚀 Usage

1. **Open RStudio**

2. **Load the R script**
   ```r
   source("NEW_Project_Refined_Code_48.R")
   ```

3. **Update the data path** in the script to point to your CSV file location:
   ```r
   cars <- read_csv("path/to/Cars_Prices.csv", na = "-")
   ```

4. **Run the script** to execute the complete analytics pipeline

---

## 📊 Project Workflow - Big Data Analytics Lifecycle

### Phase 1: Discovery 🔍
- Dataset exploration and understanding
- Problem definition: Predict car prices accurately
- Hypothesis formulation about factors affecting prices

### Phase 2: Data Preparation 🧹
- **Data Cleaning**:
  - Removed 3,512 duplicate rows
  - Converted data types (numeric and categorical)
  - Extracted Turbo flag from engine volume text
  
- **Missing Value Handling**:
  - Structural missing values (Levy) set to 0 for manufacturers with >30% missing
  - Remaining missing values imputed with median
  
- **Outlier Detection**:
  - Applied IQR method (multiplier = 3.5)
  - Removed outliers from Price, Mileage, and Engine Volume

- **Data Splitting**:
  - 80% Training set
  - 20% Testing set

### Phase 3: Model Planning 📈
- **Exploratory Data Analysis (EDA)**:
  - Analyzed price distributions by fuel type, gear type, category
  - Examined correlations between numeric features and price
  - Created visualizations (boxplots, scatter plots, histograms)

- **Feature Selection**:
  - Selected 15 relevant features for modeling
  - Grouped low-frequency manufacturers into "Other" category

### Phase 4: Model Building 🤖
Three machine learning models were trained and compared:

| Model | RMSE | R² | Description |
|-------|------|-----|-------------|
| 🔵 **Linear Regression** | 1.25 | 0.217 | Baseline model with log-transformed price |
| 🌳 **Decision Tree** | 1.17 | 0.311 | Captures non-linear relationships |
| 🌲 **Random Forest** ⭐ | 1.01 | 0.484 | **Best performing model** |

**Winner**: Random Forest achieved the lowest RMSE and highest R², explaining ~48% of variance in car prices.

### Phase 5: Communicate Results 📢
- Feature importance analysis
- Model performance visualizations
- Hypothesis testing results
- Business insights and recommendations

---

## 🔬 Hypothesis Testing Results

### H1: Automatic vs Manual Transmission ⚙️
**Test**: Welch Two-Sample t-test  
**Result**: ✅ Statistically significant (p < 0.001)
- **Automatic cars**: Average price = $16,926
- **Manual cars**: Average price = $11,385
- **Conclusion**: Automatic transmission cars are significantly more expensive (+$5,541)

### H2: Effect of Fuel Type ⛽
**Test**: ANOVA  
**Result**: ✅ Statistically significant (F = 225.1, p < 0.001)
- **Conclusion**: Fuel type has a significant impact on car prices

### H3: Leather Interior Effect 🪑
**Test**: Welch Two-Sample t-test  
**Result**: ✅ Statistically significant (p < 0.001)
- **Cars with leather**: Average price = $19,176
- **Cars without leather**: Average price = $13,309
- **Conclusion**: Leather interior adds ~$6,000 to car price

### H4: Mileage Correlation 🛣️
**Test**: Spearman's Rank Correlation  
**Result**: ✅ Statistically significant (ρ = -0.170, p < 0.001)
- **Conclusion**: Higher mileage is associated with lower prices (negative correlation)

---

## 🎯 Key Findings

### Top 5 Most Important Features (Random Forest):

1. 🛡️ **Airbags** (81.10% increase in MSE)
2. ⚙️ **Gear Box Type** (72.85%)
3. 📅 **Production Year** (70.18%)
4. 🏭 **Manufacturer** (43.33%)
5. 💰 **Levy** (43.16%)

### Business Insights:

- ✅ **Automatic transmission** significantly increases car value
- ✅ **Newer cars** command higher prices
- ✅ **Luxury features** (leather interior, more airbags) add substantial value
- ✅ **Higher mileage** correlates with lower prices
- ✅ **Fuel type** and **manufacturer** are strong price determinants
- ⚠️ **Prediction accuracy decreases** for high-priced luxury vehicles

---

## 📁 Project Structure

```
car-price-prediction/
│
├── NEW_Project_Refined_Code_48.R          # Main R script with complete analysis
├── Cars_Prices.csv                        # Dataset
├── Car_Price_Prediction_Poster.pdf        # Project poster (A3)
├── Project_Report.pdf                     # Detailed project documentation
├── Project_description.pdf                # Project requirements
├── README.md                              # Project overview
└── requirements.txt                       # R package dependencies
```

---

## 📊 Visualizations

The project includes comprehensive visualizations:
- 📈 Price distribution by fuel type and gear type
- 🔍 Correlation heatmaps
- 📉 Residual plots for model evaluation
- 🎯 Actual vs Predicted price scatter plots
- 📊 Feature importance bar charts
- 🌳 Decision tree visualizations

*(All visualizations are generated in the R script and included in the project report)*

---

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 Course Information

**Course**: CSE486 – Big Data Analytics  
**Institution**: [Your University Name]  
**Academic Year**: 2024-2025

---

## ⚠️ Disclaimer

This project is for **educational and research purposes only**. The predictive models are based on historical data and should not be used as the sole basis for real-world car pricing decisions without additional validation and expert consultation.

---

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👥 Team Members

**Prepared By**:
- **Karim Samer** (23P0439) - [@karimsamer100](https://github.com/karimsamer100)
- **Maya Ramy** (23P0241)
- **Mawada Eissa** (23P0265)
- **Mohamed Eissa** (23P0143)
- **Youssef El Sayed** (23P0215)
- **Youssef Abboud** (23P0062)

---

## 🙏 Acknowledgments

- Course instructor and teaching assistants
- Used Cars Dataset contributors
- R community for excellent data science packages
- All team members for their collaboration and dedication

---

**⭐ Star this repository if you found it helpful!**

Made with 💻 and ☕ by Team 48
