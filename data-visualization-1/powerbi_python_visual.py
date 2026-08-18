# Power BI Python Visual Script
# ---------------------------------------------------------
# Re-presents "Total Rooms vs Total Bedrooms" as a hexbin density
# plot with a trend line, instead of a plain scatter plot.
#
# SETUP IN POWER BI DESKTOP:
# 1. Get Data > Text/CSV > select housing.csv > Load
# 2. In the Visualizations pane, click the "Python visual" icon
#    (a small chart with a Python logo) to add it to the canvas
# 3. In the Fields pane, check: total_rooms, total_bedrooms
#    (drag them into the "Values" box of the Python visual if not
#    added automatically)
# 4. In the Python script editor pane at the bottom, paste this
#    entire script, then click the "Run" (play) button
#
# NOTE: Power BI auto-creates a dataframe called `dataset` containing
# only the fields you bind to the visual, deduplicated. Do not rename
# or remove the `dataset` variable.
# ---------------------------------------------------------

import matplotlib.pyplot as plt
import numpy as np

# `dataset` is auto-populated by Power BI with the bound columns
df = dataset.dropna(subset=["total_rooms", "total_bedrooms"])

x = df["total_rooms"].values
y = df["total_bedrooms"].values

fig, ax = plt.subplots(figsize=(8, 6))

# Hexbin instead of a plain scatter - shows point DENSITY, which is
# more informative than a scatter plot once you have thousands of
# overlapping points
hb = ax.hexbin(x, y, gridsize=40, cmap="viridis", mincnt=1)
cb = fig.colorbar(hb, ax=ax)
cb.set_label("Number of homes")

# Add a linear trend line on top
coeffs = np.polyfit(x, y, 1)
trend_x = np.linspace(x.min(), x.max(), 100)
trend_y = coeffs[0] * trend_x + coeffs[1]
ax.plot(trend_x, trend_y, color="red", linewidth=2, linestyle="--",
        label=f"Trend: y = {coeffs[0]:.2f}x + {coeffs[1]:.1f}")

ax.set_xlabel("Total Rooms")
ax.set_ylabel("Total Bedrooms")
ax.set_title("Total Rooms vs Total Bedrooms (Density View)")
ax.legend(loc="upper left")

plt.tight_layout()
plt.show()
