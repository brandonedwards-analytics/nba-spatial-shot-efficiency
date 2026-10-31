# NBA Spatial Shot Optimization & Clutch Analysis (2018–2023)

An executive-level basketball analytics project examining spatial shot efficiency, league-wide zone benchmarks, and primary scorer performance under high-leverage clutch conditions across 5 NBA seasons.

---

## 🛠️ Technical Stack & Architecture
* **Languages & Platforms:** Python (Pandas, NumPy), Google BigQuery SQL
* **Dataset:** Multi-season NBA Spatial & Play-by-Play Tracking Dataset (Kaggle)

### Repository Structure
* `sql/` – 5 modular BigQuery SQL scripts for zone efficiency, clutch player isolation, pairings, spatial optimization, and baseline benchmarks.
* `nba_data_preprocessing_and_validation.py` – Python script for initial data cleaning, transformation, and validation.

---

## 🔑 Key Insights & Analytics Scope

1. **Spatial Efficiency Benchmarks**
   * Categorized shot selection into four core spatial zones: **Restricted Area (0-4ft)**, **Paint/Short Mid (5-14ft)**, **Long Mid-Range (15ft+)**, and **Above-the-Break 3**.
   * Evaluated league-wide baseline expectations using **Points Per Shot (PPS)** and **Effective Field Goal Percentage (eFG%)**.

2. **Clutch Execution Analysis**
   * Isolated performance metrics in high-leverage situations (≤ 5 minutes remaining, score within 5 points).
   * Identified volume-efficiency tradeoffs for high-usage primary options versus positional benchmark baselines.

3. **Primary Scorer Shot Distribution**
   * Ranked top-volume scorers (1–10) within each spatial zone to determine optimal shot distribution profiles.

---

## ⚙️ Data Pipeline & Methodology
1. **Extraction & Ingestion:** Handled chunked processing of massive play-by-play CSV records in Python, filtering for the modern 2018–2023 era (`season >= 2018`) and compressing datasets (`.csv.gz`).
2. **Data Transformation & Cleaning:**
   * Isolated actual shot events (`eventmsgtype 1 and 2`) and utilized `np.select` to map raw text descriptions into precise spatial zones.
   * Engineered custom derived metrics (`PPS`, `eFG%`, `Clutch Delta`) to power downstream analytics.
3. **Query Architecture:** Structured modular SQL scripts in BigQuery to isolate spatial aggregations and clutch scoring pairings independently.
