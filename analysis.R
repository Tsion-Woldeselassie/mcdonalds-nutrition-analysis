# Install packages 
install.packages("ggplot2")
install.packages("reshape2")
install.packages("corrplot")

# Load packages
library(ggplot2)
library(reshape2)
library(corrplot)

# Set working directory to file path
setwd("C:/Users/User/Downloads/archive (16)") 

# Load the data
menu <- read.csv("menu.csv")

# Take a quick look
head(menu)
dim(menu)
str(menu)


# Part 1(a) - Histogram of Calories
ggplot(menu, aes(x = Calories)) +
  geom_histogram(binwidth = 50, fill = "steelblue", color = "white") +
  labs(title = "Histogram of Calories",
       x = "Calories",
       y = "Count") +
  theme_minimal()

# Part 1(b) - Correlation heatmap (21x21)
# Select only numeric columns
numeric_menu <- menu[, sapply(menu, is.numeric)]

# Compute correlation matrix
cor_matrix <- cor(numeric_menu, use = "complete.obs")

# Plot heatmap
corrplot(cor_matrix, 
         method = "color",
         type = "full",
         tl.cex = 0.6,
         tl.col = "black",
         addCoef.col = "black",
         number.cex = 0.35,
         title = "Correlation Heatmap",
         mar = c(0,0,1,0))

# Part 1(c) - Correlations with Calories
cal_cor <- cor_matrix["Calories", ]
cal_cor_sorted <- sort(cal_cor, decreasing = TRUE)
print(cal_cor_sorted)

# Part 1(d) - Negative correlations with Calories
negative_cors <- cal_cor[cal_cor < 0]
print(negative_cors)

# Part 2(a) - Scatter plots

# Total Fat vs Calories
ggplot(menu, aes(x = Total.Fat, y = Calories)) +
  geom_point(color = "steelblue") +
  labs(title = "Calories vs Total Fat", x = "Total Fat (g)", y = "Calories") +
  theme_minimal()

# Saturated Fat % Daily Value vs Calories
ggplot(menu, aes(x = Saturated.Fat....Daily.Value., y = Calories)) +
  geom_point(color = "darkorange") +
  labs(title = "Calories vs Saturated Fat % Daily Value", x = "Saturated Fat % DV", y = "Calories") +
  theme_minimal()

# Vitamin C % Daily Value vs Calories
ggplot(menu, aes(x = Vitamin.C....Daily.Value., y = Calories)) +
  geom_point(color = "darkgreen") +
  labs(title = "Calories vs Vitamin C % Daily Value", x = "Vitamin C % DV", y = "Calories") +
  theme_minimal()

# Part 2(b) - Box plots

# Total Fat
ggplot(menu, aes(y = Total.Fat)) +
  geom_boxplot(fill = "steelblue") +
  labs(title = "Box Plot of Total Fat", y = "Total Fat (g)") +
  theme_minimal()

# Saturated Fat % Daily Value
ggplot(menu, aes(y = Saturated.Fat....Daily.Value.)) +
  geom_boxplot(fill = "darkorange") +
  labs(title = "Box Plot of Saturated Fat % Daily Value", y = "Saturated Fat % DV") +
  theme_minimal()

# Vitamin C % Daily Value
ggplot(menu, aes(y = Vitamin.C....Daily.Value.)) +
  geom_boxplot(fill = "darkgreen") +
  labs(title = "Box Plot of Vitamin C % Daily Value", y = "Vitamin C % DV") +
  theme_minimal()

# Part 3(a) - Median and SD for all numeric features
numeric_menu <- menu[, sapply(menu, is.numeric)]

medians <- sapply(numeric_menu, median, na.rm = TRUE)
sds <- sapply(numeric_menu, sd, na.rm = TRUE)

results_3a <- data.frame(Feature = names(medians), 
                         Median = round(medians, 2), 
                         SD = round(sds, 2))
print(results_3a)

# Part 3(b) - Replace outliers with NaN using 1.5 x IQR rule
numeric_menu_clean <- numeric_menu

nan_counts <- sapply(names(numeric_menu_clean), function(col) {
  x <- numeric_menu_clean[[col]]
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  lower <- Q1 - 1.5 * IQR_val
  upper <- Q3 + 1.5 * IQR_val
  outliers <- x < lower | x > upper
  numeric_menu_clean[[col]][outliers] <<- NaN
  sum(outliers)
})

print(nan_counts)

# Part 3(c) - Replace NaN with column mean
numeric_menu_imputed <- numeric_menu_clean

for(col in names(numeric_menu_imputed)) {
  col_mean <- mean(numeric_menu_imputed[[col]], na.rm = TRUE)
  numeric_menu_imputed[[col]][is.nan(numeric_menu_imputed[[col]])] <- col_mean
}

# Recompute median and SD
medians_new <- sapply(numeric_menu_imputed, median, na.rm = TRUE)
sds_new <- sapply(numeric_menu_imputed, sd, na.rm = TRUE)

results_3c <- data.frame(Feature = names(medians_new),
                         Median_New = round(medians_new, 2),
                         SD_New = round(sds_new, 2))
print(results_3c)