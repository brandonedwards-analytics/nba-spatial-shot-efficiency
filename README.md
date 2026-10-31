# NBA Spatial Shot Optimization & Clutch Analysis (2018–2023)

An executive-level basketball analytics project examining spatial shot efficiency, league-wide zone benchmarks, and primary scorer performance under high-leverage clutch conditions across 5 NBA seasons.

---

## Executive Overview
* **Live Interactive Dashboard:** [View on Tableau Public](https://public.tableau.com/views/NBA_Spatial_Shot_Optimization/NBASpatialShotOptimizationClutchAnalysis)
* **Tools Used:** Tableau Public, Python (Pandas, NumPy), SQL, Git/GitHub
* **Dataset:** Multi-season NBA Spatial & Play-by-Play Tracking Dataset (Kaggle)

---

## 🔑 Key Insights & Analytics Scope

1. **Spatial Efficiency Benchmarks**
   * Categorized shot selection into four core spatial zones: **Restricted Area (0-4ft)**, **Paint/Short Mid (5-14ft)**, **Long Mid-Range (15ft+)**, and **Above-the-Break 3**.
   * Evaluated league-wide baseline expectations using **Points Per Shot (PPS)** and **Effective Field Goal Percentage (eFG%)**.

2. **Clutch Execution Analysis**
   * Isolated performance metrics in high-leverage situations ($\le 5$ minutes remaining, score within 5 points).
   * Identified volume-efficiency tradeoffs for high-usage primary options versus positional benchmark baselines.

3. **Primary Scorer Shot Distribution**
   * Ranked top-volume scorers (1–10) within each spatial zone to determine optimal shot distribution profiles.

---

## 📊 Dashboard Structure

The project is structured as a 3-part interactive Tableau Story:
* **Tab 1: Spatial Benchmarks** — Macro league trends and zone-by-zone scoring efficiency.
* **Tab 2: Clutch Execution** — Player performance metrics during critical game situations.
* **Tab 3: Primary Scorer Optimization** — Granular 1–10 efficiency rankings by spatial zone.

---

## 🛠️ Data Pipeline & Methodology
1. **Extraction & Ingestion:** Handled chunked processing of massive play-by-play CSV records in Python, filtering for the modern 2018–2023 era (`season >= 2018`) and compressing datasets (`.csv.gz`).
2. **Data Transformation & Cleaning:**
   * Isolated actual shot events (`eventmsgtype 1 and 2`) and utilized `np.select` to map raw text descriptions into precise spatial zones.
   * Engineered custom derived metrics (`PPS`, `eFG%`, `Clutch Delta`) to power downstream visualizations.
3. **Visualization & Delivery:** Exported pre-aggregated summary tables and built fixed-aspect executive dashboards published to Tableau Public.
