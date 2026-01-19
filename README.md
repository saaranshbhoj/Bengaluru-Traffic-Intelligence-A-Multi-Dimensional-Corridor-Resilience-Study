Bengaluru Traffic Intelligence: A Multi-Dimensional Resilience Study

📌 Why This Project?
In a city like Bengaluru, treating every "Red" road the same leads to inefficient infrastructure spending. This project solves a practical real-life problem: differentiating 
between Structural Failures (Chronic) and Behavioral Surges (Volatile) to ensure targeted urban intervention and better data-driven policies.

🎯 Problem Statement
To analyze the nature of congestion patterns and behaviors by exploring dependencies between traffic, safety, and environmental metrics. The goal is to segment 
corridors accurately and verify these segments through Spatial Analysis, providing a prioritized roadmap for policymakers.

📊 Data Snapshot
Window: 952 Days (Jan 2022 - Aug 2024)
Scale: 8,936 Records | 16 Corridors | 8 High-Traffic Areas
Primary Metric: congestion_score (A composite, normalized KPI weighted by Travel Time Index and Road Capacity Utilization).

🛠 The 6 Analytical Pillars
1. Corridor Volatility Profiling
Utilized the Coefficient of Variation (CV) to separate chronic bottlenecks (consistent failure) corridors from demand-induced volatility (unpredictable surges) corridors.

2. Maverick Index (Sensitivity Analysis)
Identified corridors that defy city-wide macro-patterns. Performed a Comprehensive Correlation Analysis(spearman correlation) of key metrics with each other firstly on 
a city-wide level and then subsequently for each corridor flagging any sizeable deviation from the city-wide behaviour. By measuring the deviation of a corridor’s 
behavior from the city baseline, we isolated localized shocks from general traffic pulses.

3. Statistical Audit: Z-Score vs. Inter Quartile Range (IQR)
A technical deep-dive into anomaly detection. We proved why Z-score acts as a high-precision filter for skewed traffic data, outperforming IQR (Inter-Quartile Range)  
which collapses in chronically congested zones.

4. Temporal Resilience Analysis
Leveraged Advanced SQL Window Functions (LAG, OVER) to track monthly changes in congestion. We analyzed the "Congestion Solidification" point—the exact 
moment a corridor transitions from volatile to a permanent structural bottleneck.

5. Spatial "Gravity" Analysis
Established a causal link between POI Proximity (Tech Parks, Malls) and corridor failure. Using the Geodesic formula, we proved how "Urban Gravity" dictates the 
saturation point of the road network. We also bucketed the POI's based on its distance(km) from the corridor to better assess their impact on traffic metrics.

6. Multi-Collinearity Optimized KPI
Designed a Final Corridor Priority Index with a 40/25/15/20 weighting strategy. We deliberately filtered out redundant signals (Volume and Emissions) to prevent
"signal double-counting" and focus on independent variables like Volatility and Sensitivity.

📈 Key Findings & Policy Impact
Structural vs. Behavioral: Chronic Corridors (e.g., Sony World Junction) require infrastructure reform, while Volatile Demand Induced Corridors (e.g., Silk Board Junction) 
can be optimized via dynamic Traffic management and Peak-Hour Signal Timing changes.

Noise Filtration: Through Comprehensive Correlation Analysis and Statistical Application, Confirmed that factors like Parking Usage and Weather act as systemic noise 
at the macro level thus having low predictive influence, allowing us to focus on high-signal drivers like Capacity Utilization and congestion score.

The Anomaly Paradox: Validated Z-Score as the superior tool for identifying "Miracle Days" (unusually low traffic) in skewed distributions where Inter-Quartile Range fails.

Chronic Corridor's Symmetry Gap: Performed granular analysis of road vs overall area congestion analysis for chronic corridors ,Found days where a road was at 1.0 (Peak Saturation)
while the area mean was 0.6, suggesting immediate relief is possible through Dynamic Route Rerouting even for chronic bottlenecks.

POI's Clustering: Chronic corridors showed extreme POI density within a <1km and <2.5 Km radius, whereas Volatile corridors had dispersed density (>5km). 
Spatially verified that the Corridors segmented into Chronic Category were having more POI's density within the corridor centre whereas Corridors segmented
into Volatile(Demand-Induced) Category showed dispersed POI's density establishing our segmentation.

💻 Tech Stack & Pipeline
Engine: MySQL (Window Functions, Aggregations, Temporal Analysis)
Language: Python (Pandas, NumPy)
Geospatial: Geopy (Geodesic Distance Modeling)
Visuals: Matplotlib, Seaborn (Heatmaps, Quadrant Scatter Plots Analysis, Combined horizontal Bar-Charts)
Bridge: SQLAlchemy (Python-to-SQL Production Workflow)
