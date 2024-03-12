### Important Notes: 
In the descriptions below of the metrics, there are references to ‘positive’ and ‘negative’ labels. These are general terms to describe a binary classification outcome that we want to examine in relation to ‘sex’ in this case. An example of such a binary classification would be if we were looking at a dataset to train a cancer detection diagnostic model. The model either outputs ‘yes’ if cancer is detected, or ‘no’ if it is not, and these would be the ‘positive’ and ‘negative’ labels respectively. These metrics help us to understand the breakdown of our dataset in terms of the ‘sex’ variable and the ‘has cancer’ variable.

In addition, we are not always striving for the values that signify exact equality between male and female counts and percentages. For example, consider an AI tool used to diagnose autoimmune diseases. 80% of autoimmune diseases are suffered by females, therefore even if our dataset was 50% male samples and 50% female samples, we would and should expect that the value for Positive Label Imbalance is closer to -1 than 0, meaning that a higher percentage of the female samples are ‘positive’ compared to male samples. This examples highlights the fact that the ‘optimal’ or ‘unbiased’ values for these metrics that we are striving for can be highly contextual, depending on the problem that the AI tools is addressing.

These metrics were taken from: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-detect-data-bias.html

# Training Dataset Challenge

## Submission Requirements
Below are the requirements that your submitted dataset must follow in order to work properly with the benchmarking workflow:

1. A column with the label ‘ID’ that is of the type ‘string’
2. A colum with the label ‘Sexo’ that is of the type ‘string’
3. All values in the ‘Sexo’ column must be either the string ‘male’ or ‘female’
4. A colum with the label ‘AF’ that is of type ‘string’
5. All values in the ‘AF’ column must be either the string ‘Yes’ or ‘No’
6. The file must be a .csv

## Metrics

### Class Imbalance

**Definition:** What proportion of the data set is one class vs the other 

**Equation:** (male_count - female_count) / (male_count + female_count)

**How to interpret:** If the value is 0.5, the dataset is perfectly balanced, having the same number of male samples as female samples. As the value trends toward 1, the data set has more male samples, and toward 0, the data set has more female samples.

### Female Positive Label Percentage

**Definition:** What percentage of all 'positive' labels are from females 

**Equation:** f_positive / overall_positive

**How to interpret:** If the value is 0.5, this means that of all the samples with a ‘positive’ label, there are the same number of male samples as there are female. As the value trends toward 1, more female samples have a ‘positive’ label than male, and toward 0, more male samples have a ‘positive’ label than female.

### Female Negative Label Percentage

**Definition:** What percentage of all 'negative' labels are from males

**Equation:** f_negative / overall_negative

**How to interpret:** If the value is 0.5, this means that of all the samples with a ‘negative’ label, there are the same number of male samples as there are female. As the value trends toward 1, more female samples have a ‘negative’ label than male, and toward 0, more male samples have a ‘negative’ label than female.

### Positive Label Imbalance

**Definition:** What percentage of 'positive' labels are male/female

**Equation:** (m_positive / male_count) - (f_positive / female_count)

**How to interpret:** If the value is 0, this means that the same percentage of female samples are ‘positive’ as male samples are ‘positive’. As the value trends toward 1, this means that the percentage of male samples that are ‘positive’ is greater than the percentage of female samples that are ‘positive’, and vice versea as the value trends toward -1.

### Negative Label Imbalance

**Definition:** What percentage of 'negative' labels are male/female

**Equation:** (m_negative / male_count) - (f_negative / female_count)

**How to interpret:** If the value is 0, this means that the same percentage of female samples are ‘negative’ as male samples are ‘negative’. As the value trends toward 1, this means that the percentage of male samples that are ‘negative’ is greater than the percentage of female samples that are ‘negative’, and vice versea as the value trends toward -1.

### Female Conditional Demographic Disparity

**Definition:** Determines whether females have a larger proportion of negative predictions in the data set than of the positive predictions

**Equation:** (f_negative / (m_negative + f_negative)) - (f_positive / (m_positive + f_positive))

**How to interpret:** A value of 0 indicates females represent equal proportions of ‘negative’ and ‘positive’ outcomes. As the value trends toward 1, this means that females have a greater proportion of ‘negative’ outcomes than ‘positive’ outcomes in the dataset. As the value trends toward -1, this means that females have a greater proportion of ‘positive’ outcomes than ‘negative’ outcomes in the dataset. 
 
### Male Conditional Demographic Disparity

**Definition:** Determines whether males have a larger proportion of negative predictions in the data set than of the positive predictions 

**Equation:** (m_negative / (m_negative + f_negative)) - (m_positive / (m_positive + f_positive))

**How to interpret:** A value of 0 indicates males represent equal proportions of ‘negative’ and ‘positive’ outcomes. As the value trends toward 1, this means that males have a greater proportion of ‘negative’ outcomes than ‘positive’ outcomes in the dataset. As the value trends toward -1, this means that males have a greater proportion of ‘positive’ outcomes than ‘negative’ outcomes in the dataset. 

# Model Output Challenge

## Submission Requirements

Below are the requirements that your submitted dataset must follow in order to work properly with the benchmarking workflow:

1. A column with the label ‘ID’ that is of the type ‘string’
2. A colum with the label ‘output’ that is of the type ‘string’
3. All values in the ‘output’ column must be either the string ‘Yes’ or ‘No’
4. The file must be a .csv

## Metrics

#### For definition purposes:
TP - True positives, model predicted positive and true value is positive (count)
TN - True negatives, model predicted negative and true value is negative (count)
FP - False positives, model predicted positive but true value is negative (count)
FN - False negatives, model predicted negative but true value is positive (count)


### Overall Accuracy 

**Definition:**  Percentage of model predictions that are correct

**Equation:** (TP + TN) / (total count)

**How to interpret:**  The higher the percentage (closer to 1) the better the model is at predicting the correct true value.

### Statistical Parity

**Definition:**  Percentage of the outputs that the model predicted as positive

**Equation:** (TP + FP) / (total count)

**How to interpret:**  A higher percentage (closer to 1) means that the model often predicts positive values, and a low percentage (closer to 0) means that the model often predicts negative values.

### Equal Opportunity

**Definition:**  Percentage of positive outcomes that the model predicted correctly

**Equation:** TP / (TP + FN)

**How to interpret:**  A high percentage (closer to 1) means that the model is very good at accurately predictive positive values.

### Predictive Equality

**Definition:**  Percentage of the negative outcomes that the model predicted incorrectly

**Equation:** FP / (FP + TN)

**How to interpret:**  A high percentage (closer to 1), means that the model often misses negative predictions.

### False Negative Rate

**Definition:**  Percentage of positive outcomes that the model did not predict correctly

**Equation:** FN / (FN + TP)

**How to interpret:**  A high percentage (closer to 1), means that the model often misses positive predictions.

### Disparate Impact 

**Definition:**  The ratio of positive proportions in the predicted labels metric for males versus females

**Equation:** (males given a positive prediction / number of males) / (females given a positive prediction / number of females)

**How to interpret:** A value of 1 means there is demographic partiy, that is the model predicts positive outcomes for males and females at the same rate. A value less than 1 means that males have a higher proportion of positive predictions than women, and vice versa for a value greater than 1.

### Accuracy Difference 

**Definition:**  The model accuracy for males minus the model acuracy for females

**Equation:** ((male true positives + male true negatives) / (total males)) - ((female true positives + female true negatives) / (total females))

**How to interpret:** A value of 0 means that the accuracy of the model for males and females is the same. A positive value means the model is more accurate for males than for females. A negative value means the model is more accurate for females than for males.

### Difference in Conditional Acceptance 

**Definition:**  This compares the true values to the model's predicted values and whether this is the same for males and females for predicted positive values

**Equation:** (male true positives / male predicted positives) - (female true positives / female predicted positives)

**How to interpret:** A value of 0 means the ratio of true positives to predicted positives is the same for both males and females. A positive value means this ratio is greater for males than females, which indicates a potential bias against males who should have a positive prediction. A negative value means this ratio is greater for females than males, which indicates a potential bias against females who should have a positive prediction.

### Difference in Conditional Rejection

**Definition:**  This compares the true values to the model's predicted values and whether this is the same for males and females for predicted negative values

**Equation:** (male true negatives / male predicted negatives) - (female true negatives / female predicted negatives)

**How to interpret:** A value of 0 means the ratio of true negatives to predicted negatives is the same for both males and females. A positive value means this ratio is greater for males than females, which indicates a potential bias against males who should have a negative prediction. A negative value means this ratio is greater for females than males, which indicates a potential bias against females who should have a negative prediction.

### Treatment Equality

**Definition:**  The difference in the ratio of false negatives to false positives between males and females

**Equation:** (false negatives for females / false positives for females) - (false negatives for males / false positives for males)

**How to interpret:** A value of 0 means the ratios of false negatives to false positives is the same for both males and females. A positive value means that the model predicts more false negatives than false positives for females compared to males, and vice versa for a negative value. 

