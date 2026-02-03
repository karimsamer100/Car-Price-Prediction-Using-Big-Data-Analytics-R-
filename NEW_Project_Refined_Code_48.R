# CAR PRICE PREDICTION - BIG DATA ANALYTICS PROJECT

# Load required libraries
library(tidyverse) #data manipulation and visualisation
library(rpart) #decision tree models
library(rpart.plot) #visualizing decision trees
library(randomForest) #machine learning model

# 1. LOAD AND EXPLORE DATASET
cars <- read_csv("C://Users//mayar//OneDrive//Desktop//araf//Semester 5//Big Data Analytics//Cars_Prices.csv",
                 na = "-") # replace "-" with NA -> null

# Basic dataset exploration
glimpse(cars) #shows column names, types, and sample values
summary(cars) #gives statistics (min, max, median, missing values)

# 2. DATA QUALITY CHECKS

# Check for missing values
cat("\nMissing values per column:\n")
print(colSums(is.na(cars))) #Counts missing values per column.

# Check for duplicates (excluding ID column)
cars_no_id <- cars %>% select(-ID)  # Ignores ID column
# %>% means take the result from the left and pass it as the first input to the function on the right.
total_duplicates <- sum(duplicated(cars_no_id))
cat("\nDuplicated rows found:", total_duplicates, "\n") #Duplicated rows found: 3512 

# Remove duplicates
cars <- cars %>% 
  distinct(across(-ID), .keep_all = TRUE)
# distinct removes duplicate rows -> across all columns except id
# .keep_all -> After finding duplicate rows, keep all columns in the output without it ->
#R would return only the columns used for uniqueness
cat("After removing duplicates:", nrow(cars), "rows\n")


# 3. DATA TYPE CONVERSION

cars <- cars %>%
# overwrites the old version with a cleaned one
  mutate( # Anything inside mutate() becomes a column in the dataset
    # Convert Levy to numeric
    Levy = as.numeric(Levy), # the symbol - that we replaced with na when it was present made the column of type character
    
    # Extract Turbo flag and engine volume
    Turbo = str_detect(`Engine volume`, "Turbo"),
    # Backticks ` ` -> allow column names with spaces
    # Looks for the word "Turbo" inside "Engine volume" and replaces it with true and makes rest false 
    # i only care if it is turbo or not not any other numeric value beside the word turbo
    # i create a new column called turbo
    Engine_volume = as.numeric(str_extract(`Engine volume`, "\\d+\\.?\\d*")),
    # extracts the numeric part beside the word turbo or the numeric part if there is no turbo written beside it 
    # and create a new column with the numeric part and cast it as type numeric
    
    # Convert mileage to numeric (remove " km")
    Mileage_km = as.numeric(str_remove_all(Mileage, "[^0-9]")), # eg "120 000 km" → "120000" → 120000
    # remove anything that is not a digit and convert it to numeric
    
    # Fix door encoding issues
    Doors = case_when(
      Doors == "02-Mar" ~ 2,
      Doors == "04-May" ~ 4,
      Doors == ">5" ~ 5,
      TRUE ~ NA_real_ # like the default -> dont put na because it will cause ambiguity bs ma3a 3alena msh fhma
    )
  )

# 4. OUTLIER DETECTION AND REMOVAL (IQR METHOD)

# Function to detect outliers using IQR
detect_outliers_IQR <- function(x, multiplier = 3.5) { # create a function 
  Q1 <- quantile(x, 0.25, na.rm = TRUE) # na.rm means ignore missing values when doing calculations
  # any calculation involving NA returns NA by default so best to do this
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  
  lower_fence <- Q1 - multiplier * IQR_val
  upper_fence <- Q3 + multiplier * IQR_val
  
  outliers <- (x < lower_fence | x > upper_fence) & !is.na(x)
  
  return(list(
    outliers = outliers,
    lower_fence = lower_fence,
    upper_fence = upper_fence,
    n_outliers = sum(outliers, na.rm = TRUE)
  ))
}

original_rows <- nrow(cars)

# Detect outliers in key numeric variables
price_outliers <- detect_outliers_IQR(cars$Price)
mileage_outliers <- detect_outliers_IQR(cars$Mileage_km)
engine_outliers <- detect_outliers_IQR(cars$Engine_volume)

cat("\nPrice outliers:", price_outliers$n_outliers, "\n")
cat("Mileage outliers:", mileage_outliers$n_outliers, "\n")
cat("Engine outliers:", engine_outliers$n_outliers, "\n")

# Visualize before removal
par(mfrow = c(1, 2))
#boxplot(cars$Price, main = "Price (Before)", col = "lightblue")
boxplot(log10(cars$Price), main = "Price (log10)", col = "lightblue",
        ylab = "log10(Price)")
# log compresses extreme values
# box plot shaklo msh mazbot 3ashan fy values keybera awy 3ashan dol prices 
# fy affordable prices w fy very expensive prices so it is very skewed
#hist(cars$Price, breaks = 50, main = "Price Distribution", col = "lightgreen")
hist(log10(cars$Price), breaks = 50,
     main = "Histogram of Car Prices (log10)", col = "lightgreen",
     xlab = "log10(Price)")

par(mfrow = c(1, 1))

# Remove outliers
cars <- cars %>%
  filter( # Keeps only the rows where the condition is TRUE
    !price_outliers$outliers,
    !mileage_outliers$outliers,
    !engine_outliers$outliers
  )

cat("Rows removed:", original_rows - nrow(cars), "\n")

# Visualize after removal
par(mfrow = c(1, 2))
boxplot(cars$Price, main = "Price (After)", col = "lightcoral")
hist(cars$Price, breaks = 50, main = "Price Distribution", col = "lightgreen")
par(mfrow = c(1, 1))
# now we can see the plots better without using log

# 5. CONVERT CATEGORICAL VARIABLES TO FACTORS

cars <- cars %>%
  mutate( # Factors = categorical variables in R
    Manufacturer = as.factor(Manufacturer),
    Model = as.factor(Model),
    Category = as.factor(Category),
    `Leather interior` = as.factor(`Leather interior`),
    `Fuel type` = as.factor(`Fuel type`),
    `Gear box type` = as.factor(`Gear box type`),
    `Drive wheels` = as.factor(`Drive wheels`),
    Wheel = as.factor(Wheel),
    Color = as.factor(Color)
  )

# 6. CREATE MODELING DATASET

model_data <- cars %>%
  select(
    Price,
    Prod.year = `Prod. year`,
    Levy,
    Engine_volume,
    Turbo,
    Mileage_km,
    Cylinders,
    Doors,
    Airbags,
    Manufacturer,
    Category,
    `Fuel type`,
    `Gear box type`,
    `Drive wheels`,
    Wheel
  )

# 7. LEVY IMPUTATION STRATEGY

# Analyze missing pattern by manufacturer
miss_by_manu <- model_data %>%
  mutate(Levy_missing = is.na(Levy)) %>% # (1) TRUE if Levy is NA, FALSE otherwise
  group_by(Manufacturer) %>% # (2) because certain manufacturers dont put levy mn asaso
  summarise(
    n = n(),
    missing_rate = mean(Levy_missing),
    .groups = "drop" # so the result of summarise is not grouped by manufacturer anymore 
  ) %>% # (3)
  arrange(desc(missing_rate))

# Set threshold for structural missingness
threshold <- 0.30
structural_manufacturers <- miss_by_manu %>%
  filter(missing_rate >= threshold) %>% # apply filter
  # if they have more then 30% missing then that manufacturer doesnt put levy asln
  pull(Manufacturer) # have all the names of the manufacturers that ^

# For manufacturers with high missing rates, set Levy to 0
model_data <- model_data %>%
  mutate( # if_else(condition, value_if_true, value_if_false)
    Levy = if_else(is.na(Levy) & (Manufacturer %in% structural_manufacturers), 0, Levy)
    # condition if levy is missing and manufacturer doesnt put levy asln then impute with 0
  )

# For remaining missing values, impute with median (data is skewed)
levy_for_impute <- model_data$Levy[!is.na(model_data$Levy) & model_data$Levy > 0] 
# prepare the column to calculate median by removing -ve values and na
fill_value <- median(levy_for_impute)

model_data <- model_data %>%
  mutate(Levy = if_else(is.na(Levy), fill_value, Levy)) 
# if na then replace it with the median else keep the original value

cat("Levy NA remaining:", sum(is.na(model_data$Levy)), "\n")





#######################################################################
#######################################################################
#######################################################################
#######################################################################
# EDA 


# 8. EXPLORATORY DATA ANALYSIS (EDA)

# Price vs Mileage
ggplot(model_data, aes(x = Mileage_km, y = Price)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_smooth(method = "loess", color = "red", se = FALSE) +
  scale_y_log10(labels = scales::comma) +
  labs(title = "Car Price vs Mileage", x = "Mileage (km)", y = "Price (log scale)") +
  theme_minimal()

# Price vs Production Year
ggplot(model_data, aes(x = Prod.year, y = Price)) +
  geom_point(alpha = 0.3, color = "darkgreen") +
  geom_smooth(method = "loess", color = "red", se = FALSE) +
  scale_y_log10(labels = scales::comma) +
  labs(title = "Car Price vs Production Year", x = "Year", y = "Price (log scale)") +
  theme_minimal()

# Price by Fuel Type
ggplot(model_data, aes(x = `Fuel type`, y = Price)) +
  geom_boxplot(fill = "skyblue", alpha = 0.7, outlier.alpha = 0.2) +
  scale_y_log10(labels = scales::comma) +
  labs(title = "Car Price by Fuel Type", x = "Fuel Type", y = "Price (log scale)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Price by Category
ggplot(model_data, aes(x = Category, y = Price)) +
  geom_boxplot(fill = "lightgreen", alpha = 0.7, outlier.alpha = 0.2) +
  scale_y_log10(labels = scales::comma) +
  labs(title = "Car Price by Vehicle Category", x = "Category", y = "Price (log scale)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Price Distribution
ggplot(model_data, aes(x = Price)) +
  geom_histogram(bins = 50, fill = "gray", color = "white") +
  scale_x_log10(labels = scales::comma) +
  labs(title = "Distribution of Car Prices", x = "Price (log scale)", y = "Count") +
  theme_minimal()



#######################################################################
#######################################################################
#######################################################################
#######################################################################
#MODEL
# ==============================================================================
# 9. TRAIN-TEST SPLIT (80-20)
# ==============================================================================

set.seed(123)
n <- nrow(model_data)
train_index <- sample(seq_len(n), size = 0.8 * n)
train_data <- model_data[train_index, ]
test_data <- model_data[-train_index, ]

cat("Training set:", nrow(train_data), "rows\n")
cat("Test set:", nrow(test_data), "rows\n")

# Handle unseen factor levels in test set
# Combine low-frequency manufacturers into "Other" category
train_data <- train_data %>%
  mutate(Manufacturer = fct_lump_n(Manufacturer, n = 45, other_level = "Other"))

test_data <- test_data %>%
  mutate(
    Manufacturer = fct_other(Manufacturer, keep = levels(train_data$Manufacturer), other_level = "Other"),
    Manufacturer = factor(Manufacturer, levels = levels(train_data$Manufacturer))
  )

# ==============================================================================
# 10. MODEL TRAINING
# ==============================================================================

# Create log-transformed target variable (improves model performance)
train_data$log_Price <- log(train_data$Price)
test_data$log_Price <- log(test_data$Price)

# Model 1: Linear Regression
lm_log <- lm(log_Price ~ . - Price, data = train_data)
summary(lm_log)

# Model 2: Decision Tree
tree_model <- rpart(
  log_Price ~ . - Price,
  data = train_data,
  method = "anova",
  control = rpart.control(cp = 0.01)
)

rpart.plot(tree_model, type = 3, extra = 101, 
           main = "Decision Tree for Car Price Prediction")

# Model 3: Random Forest - prepare data (rename columns with spaces)
train_rf <- train_data %>%
  rename(
    Fuel_type = `Fuel type`,
    Gear_box_type = `Gear box type`,
    Drive_wheels = `Drive wheels`
  )

test_rf <- test_data %>%
  rename(
    Fuel_type = `Fuel type`,
    Gear_box_type = `Gear box type`,
    Drive_wheels = `Drive wheels`
  )

# Train Random Forest
set.seed(123)
rf_model <- randomForest(
  log_Price ~ . - Price,
  data = train_rf,
  ntree = 300,
  mtry = 4,
  importance = TRUE
)

print(rf_model)

# ==============================================================================
# 11. MODEL EVALUATION
# ==============================================================================

# Generate predictions
pred_lm <- predict(lm_log, newdata = test_data)
pred_tree <- predict(tree_model, newdata = test_data)
pred_rf <- predict(rf_model, newdata = test_rf)
# Evaluation metrics
y_test_log <- test_data$log_Price
rmse <- function(y, yhat) sqrt(mean((y - yhat)^2, na.rm = TRUE))
rsq <- function(y, yhat) {
  1 - sum((y - yhat)^2, na.rm = TRUE) / sum((y - mean(y, na.rm = TRUE))^2, na.rm = TRUE)
}

# Compare models
results <- tibble(
  Model = c("Linear Regression", "Decision Tree", "Random Forest"),
  RMSE = c(rmse(y_test_log, pred_lm), rmse(y_test_log, pred_tree), rmse(y_test_log, pred_rf)),
  R_squared = c(rsq(y_test_log, pred_lm), rsq(y_test_log, pred_tree), rsq(y_test_log, pred_rf))
)

print(results)

# Feature importance (Random Forest)
imp <- importance(rf_model)
imp_table <- as.data.frame(imp) %>%
  rownames_to_column("Feature") %>%
  arrange(desc(`%IncMSE`))

cat("\nTop 10 Important Features:\n")
print(head(imp_table, 10))


# 13. MODEL VISUALIZATIONS

# Feature importance plot
ggplot(head(imp_table, 10), aes(x = reorder(Feature, `%IncMSE`), y = `%IncMSE`)) +
  geom_col(fill = "darkred") +
  coord_flip() +
  labs(title = "Top 10 Feature Importances", x = "Feature", y = "% Increase in MSE") +
  theme_minimal()

# Actual vs Predicted
pred_df <- tibble(Actual = y_test_log, Predicted = pred_rf)

ggplot(pred_df, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.3, color = "purple") +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Actual vs Predicted Prices (Random Forest)", 
       x = "Actual log(Price)", y = "Predicted log(Price)") +
  theme_minimal()

# Residuals plot
res_df <- tibble(Predicted = pred_rf, Residuals = y_test_log - pred_rf)

ggplot(res_df, aes(x = Predicted, y = Residuals)) +
  geom_point(alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Residuals vs Predicted", x = "Predicted log(Price)", y = "Residuals") +
  theme_minimal()

#######################################################################
#######################################################################
#######################################################################
#######################################################################


# 13. HYPOTHESIS TESTING

# H1: Do automatic cars cost more than manual?
cat("\n--- H1: Automatic vs Manual Transmission ---\n")
h1_df <- model_data %>%
  filter(`Gear box type` %in% c("Automatic", "Manual"))

t.test(Price ~ `Gear box type`, data = h1_df)

# H2: Does fuel type affect price?
cat("\n--- H2: Fuel Type vs Price ---\n")
anova_fuel <- aov(Price ~ `Fuel type`, data = model_data)
summary(anova_fuel)
#TukeyHSD(anova_fuel)

# H3: Does leather interior affect price?
cat("\n--- H3: Leather Interior vs Price ---\n")
h3_df <- cars %>% select(Price, `Leather interior`) %>% drop_na()
t.test(Price ~ `Leather interior`, data = h3_df)

# H4: Is mileage correlated with price?
cat("\n--- H4: Mileage vs Price Correlation ---\n")
cor.test(model_data$Mileage_km, model_data$Price, method = "spearman", exact = FALSE)


# 14. K-MEANS CLUSTERING

# Prepare data for clustering
cluster_data <- model_data %>%
  select(Price, Mileage_km, Engine_volume, Prod.year, Airbags) %>%
  drop_na()

# Scale and cluster
cluster_scaled <- scale(cluster_data)
set.seed(123)
kmeans_model <- kmeans(cluster_scaled, centers = 3, nstart = 25)

cluster_data$Cluster <- factor(kmeans_model$cluster)

# Summarize clusters
cluster_summary <- cluster_data %>%
  group_by(Cluster) %>%
  summarise(
    Count = n(),
    Avg_Price = round(mean(Price), 2),
    Avg_Mileage = round(mean(Mileage_km), 0),
    Avg_Engine = round(mean(Engine_volume), 2)
  )

print(cluster_summary)

# Visualize clusters
ggplot(cluster_data, aes(x = Mileage_km, y = Price, color = Cluster)) +
  geom_point(alpha = 0.5) +
  scale_y_log10(labels = scales::comma) +
  labs(title = "Car Clusters", x = "Mileage (km)", y = "Price (log scale)") +
  theme_minimal()
