import pandas as pd

# Load the Real Estate dataset.
df = pd.read_csv("Realestate.csv")

# 2-3. Normalize/standardize houseAge using z-score standardization.
# The original houseAge column is preserved, and standardized values are
# stored in the new houseAgeStandardized column.
df["houseAgeStandardized"] = (
    (df["houseAge"] - df["houseAge"].mean()) / df["houseAge"].std()
)

# 4. Drop numberOfConvenienceStores.
df = df.drop(columns=["numberOfConvenienceStores"])

# 5. Rename transaction to transactionDate.
df = df.rename(columns={"transaction": "transactionDate"})

# 6. Use .loc[] to display rows 0 through 10 (inclusive).
print("Rows 0 through 10 using .loc[]:")
print(df.loc[0:10])

# 7. Use .iloc[] to display the first 10 rows.
print("\nFirst 10 rows using .iloc[]:")
print(df.iloc[:10])

# 8. Find and remove duplicate rows.
print("\nDuplicate rows before removal:", df.duplicated().sum())
df = df.drop_duplicates()
print("Duplicate rows after removal:", df.duplicated().sum())

# 9. Find missing values and fill numeric missing values with the mean.
print("\nMissing values before filling:")
print(df.isna().sum())

numeric_columns = df.select_dtypes(include="number").columns
df[numeric_columns] = df[numeric_columns].fillna(df[numeric_columns].mean())

print("\nMissing values after filling:")
print(df.isna().sum())

# Save the cleaned dataset so all modifications persist.
df.to_csv("Realestate_cleaned.csv", index=False)
