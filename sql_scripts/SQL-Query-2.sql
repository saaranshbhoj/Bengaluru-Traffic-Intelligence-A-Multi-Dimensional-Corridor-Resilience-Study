----------- -----------------------------------Perform Exploratory Data Analysis [EDA]---------------------------------------------------------------

-- ---------------------------------- 1. Data Quality & Coverage: Null / missing values per column --------------------------------------------------

-- SELECT 
--     'timestamp' AS column_name, SUM(timestamp IS NULL) AS null_count FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'area', SUM(area IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'road', SUM(road IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'traffic_volume', SUM(traffic_volume IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'avg_speed', SUM(avg_speed IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'travel_time_index', SUM(travel_time_index IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'road_capacity_utilization', SUM(road_capacity_utilization IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'incident_reports', SUM(incident_reports IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'environmental_impact', SUM(environmental_impact IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'public_transport_usage', SUM(public_transport_usage IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'traffic_signal_compliance', SUM(traffic_signal_compliance IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'parking_usage', SUM(parking_usage IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'ped_cycle_count', SUM(ped_cycle_count IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'weather', SUM(weather IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'roadwork', SUM(roadwork IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'congestion_score', SUM(congestion_score IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'latitude', SUM(latitude IS NULL) FROM traffic_cleaned_geo
-- UNION ALL
-- SELECT 'longitude', SUM(longitude IS NULL) FROM traffic_cleaned_geo;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------Date range & days covered------------------------------------------------------------------------
-- SELECT 
--     MIN(DATE(timestamp)) AS start_date,
--     MAX(DATE(timestamp)) AS end_date,
--     COUNT(DISTINCT DATE(timestamp)) AS days_covered
-- FROM traffic_cleaned_geo;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------Unique spatial entities--------------------------------------------------------------------------
-- SELECT
-- 	COUNT(DISTINCT road) as "Distinct_Roads/Corridors",
--     COUNT(DISTINCT area) as Distinct_Areas,
--     COUNT(DISTINCT CONCAT(area,'|',road)) as unique_spatial_entities
-- FROM traffic_cleaned_geo;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------Binning congestion_score to see distribution-----------------------------------------------------------
--  SELECT
--      CASE 
--          WHEN congestion_score < 0.2 THEN 'Very Low'
--          WHEN congestion_score < 0.4 THEN 'Low'
--          WHEN congestion_score < 0.6 THEN 'Medium'
--          WHEN congestion_score < 0.8 THEN 'High'
--          ELSE 'Very High'
--      END AS congestion_band,
--      COUNT(*) AS records,
--      ROUND(100.0 * COUNT(*)/(SELECT COUNT(*) FROM traffic_cleaned_geo),2) as pct_contribution
--  FROM traffic_cleaned_geo
--  GROUP BY congestion_band
--  ORDER BY pct_contribution desc;

-- NOTE: This output also indicated that the data points of congestion scores are not normally distributed and are heavily skewed.
-- This is an important indicator for our future statistical analysis and methods.
------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------Area-Level & Road-Level EDA (Spatial but Aggregated)-------------------------------------------------
-- Area-wise congestion summary

-- SELECT
--     area,
--     COUNT(*) AS records,
--     MIN(congestion_score) as min_cong_score,
--     MAX(congestion_score) as max_cong_score,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(AVG(avg_speed), 2) AS avg_speed,
--     ROUND(AVG(traffic_volume), 0) AS avg_volume
-- FROM traffic_cleaned_geo
-- GROUP BY area
-- ORDER BY avg_congestion DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Road-level/Corridor-level hotspot detection
-- SELECT
--     road,
--     area,
--     COUNT(*) AS records,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(AVG(avg_speed), 2) AS avg_speed,
--     ROUND(AVG(traffic_volume), 0) AS avg_volume,
--     ROUND(AVG(environmental_impact), 2) AS avg_env_impact
-- FROM traffic_cleaned_geo
-- GROUP BY road, area
-- HAVING COUNT(*) >= 100  -- optional: ensure enough data points
-- ORDER BY avg_congestion DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------Temporal Trends (Daily Granularity)---------------------------------------------------------------
-- Daily congestion trend (overall)
-- SELECT
--     DATE(timestamp) AS dt,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(AVG(avg_speed), 2) AS avg_speed,
--     SUM(traffic_volume) AS total_volume
-- FROM traffic_cleaned_geo
-- GROUP BY dt
-- ORDER BY dt;
-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------“Best” and “Worst” days of the entire day why to find? :  Establishing the Absolute Range (Best/Worst Case Scenarios)
-- By calculating the extreme boundary values we can create a theoretical best case congestion_score and theoretical worst. We can build our model
-- such that if congestion_score for that day reaches theoretical worst raise an emergency alarm. Help in defining absolute boundary of the system/model

-- SELECT DATE(timestamp) as day, 
-- 	ROUND(AVG(congestion_score),3) as avg_congestion,
-- 	ROUND(SUM(traffic_volume),2) as total_volume,
-- 	ROUND(AVG(avg_speed),2) as avg_speed
-- FROM traffic_cleaned_geo
-- GROUP BY DATE(timestamp)
-- ORDER BY avg_congestion DESC
-- LIMIT 10;

-- Top-10 Best:
-- SELECT DATE(timestamp) as day, 
-- 	ROUND(AVG(congestion_score),3) as avg_congestion,
-- 	ROUND(SUM(traffic_volume),2) as total_volume,
-- 	ROUND(AVG(avg_speed),2) as avg_speed
-- FROM traffic_cleaned_geo
-- GROUP BY DATE(timestamp)
-- ORDER BY avg_congestion 
-- LIMIT 10;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Weather & Roadwork Impact
-- SELECT
--     weather,
--     COUNT(*) AS records,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(STDDEV_SAMP(congestion_score),2) as volatility_congestion,
--     ROUND(1.0 * STDDEV_SAMP(congestion_score) / NULLIF(AVG(congestion_score),0),2) as coeff_of_variation,
--     ROUND(AVG(avg_speed), 2) AS avg_speed,
--     ROUND(AVG(traffic_volume), 0) AS avg_volume
-- FROM traffic_cleaned_geo
-- GROUP BY weather
-- ORDER BY avg_congestion DESC;

-- NOTE: We also ran correlation analysis between weather type and other key metrics and were not able to find any significant correlations.

-- -----ROADWORK VS NO ROADWORK
-- SELECT
--     roadwork,
--     COUNT(*) AS records,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(STDDEV_SAMP(congestion_score),2) as volatility_congestion,
--     ROUND(1.0 * STDDEV_SAMP(congestion_score)/ NULLIF(AVG(congestion_score),0),2) as coeff_of_variation
-- FROM traffic_cleaned_geo
-- GROUP BY roadwork
-- ORDER BY avg_congestion DESC;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Safety & Incident Risk EDA: Where are incidents concentrated?
-- SELECT
--     road,
--     area,
--     COUNT(*) as total_records,
--     SUM(incident_reports) as total_incidents,
--     ROUND(1.0 * SUM(incident_reports)/ COUNT(*),2) AS incident_per_records,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(AVG(traffic_volume),2) as avg_volume,
--     ROUND(AVG(road_capacity_utilization),2) as road_capacity,
--     ROUND(STDDEV_SAMP(road_capacity_utilization),2) as volatility_capacity
-- FROM traffic_cleaned_geo
-- GROUP BY road, area
-- ORDER BY incident_per_records DESC;

-- Reasoning : Why total_incidents alone was not a good factor as we had unequal no of records. Also check for avg_speed volatility when analyzing
-- corridors that have high incidents but low congestion ; speed maybe a factor there!

-- NOTE: avg_speed as a factor did not show any significant correlations, for the city's overall analysis the incident_reports shows moderate positive
-- correlation with traffic metrics [traffic_volume,road_capacity_utilization,congestion_score] with significant deviations found in koramangala,
-- MG road and Electronic city areas.

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- Parking, Pedestrians & Public Transport:
-- SELECT
--     CASE 
--         WHEN parking_usage < 65 THEN 'Low Parking Usage'
--         WHEN parking_usage < 85 THEN 'Medium Parking Usage'
--         ELSE 'High Parking Usage'
--     END AS parking_band,
--     COUNT(*) AS records,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(AVG(avg_speed), 2) AS avg_speed,
--     ROUND(AVG(traffic_volume), 0) AS avg_volume
-- FROM traffic_cleaned_geo
-- GROUP BY parking_band
-- ORDER BY parking_band;

-- NOTE: Does not exhibit any measurable predictive influence and correlation with other metrics. Representation of Measure of Density
-- not a driver of flow.
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Pedestrian/Cyclist presence vs congestion : Why it matters: Helps understand if active mobility corridors are more or less congested.

-- SELECT
--     CASE 
--         WHEN ped_cycle_count = 0 THEN 'No Ped/Cycle'
--         WHEN ped_cycle_count < 100 THEN 'Low Ped/Cycle'
--         WHEN ped_cycle_count < 160 THEN 'Medium Ped/Cycle'
--         ELSE 'High Ped/Cycle'
--     END AS ped_cycle_band,
--     COUNT(*) AS records,
--     ROUND(AVG(congestion_score), 3) AS avg_congestion,
--     ROUND(AVG(avg_speed), 2) AS avg_speed
-- FROM traffic_cleaned_geo
-- GROUP BY ped_cycle_band
-- ORDER BY ped_cycle_band;

-- NOTE: Extracted the true nature of relation using pearson vs spearman comparision in correlation analysis.
-- In the corridor vs overall comparisions found significant deviations in case of 2 corridors 
-- where the strength of correlation increased by (80-100%).
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------ENVIRONMENTAL IMPACT AND ITS RELATION WITH CONGESTION--------------------------------------------
-- CORRIDOR LEVEL ANALYSIS:
-- SELECT area,road,
-- 	ROUND(AVG(traffic_volume),2) as avg_traffic_volume,
-- 	ROUND(AVG(congestion_score),2) as avg_congestion,
--     ROUND(AVG(ped_cycle_count),2) as avg_mobility,
--     ROUND(AVG(road_capacity_utilization),2) as avg_capacity,
--     ROUND(AVG(environmental_impact),2) as avg_env_impact,
--     ROUND(STDDEV_SAMP(environmental_impact),2) as volatility_env
-- FROM traffic_cleaned_geo
-- GROUP BY area,road
-- ORDER BY avg_env_impact DESC;

-- NOTE: traffic_volume was primary driver with perfect correlation score of 1. Strong Positive Correlations with congestion and road_capacity
-- indicates strong correlations with traffic metrics and moderate negative correlation with mobility and avg_speed with some deviations
-- observed corridor-wise.  
------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------PUBLIC TRANSPORT USAGE AND CORRELATION WITH TRAFFIC VOLUME AND CONGESTION----------------------------------
-- SELECT area,road, 	ROUND(AVG(congestion_score),2) as avg_congestion,
--       ROUND(AVG(traffic_volume),2) as avg_volume,
--       ROUND(AVG(avg_speed),2) as avg_speed,
--       ROUND(AVG(public_transport_usage),2) as avg_usage,
-- 	  ROUND(STDDEV_SAMP(public_transport_usage),2) as usage_volatility
--   FROM traffic_cleaned_geo
--   GROUP BY area,road
 --  ORDER BY avg_usage DESC;

-- NOTE: Our query output and correlation analysis for the city and for individual corridors doesn't reflected any significant correlations.
-------------------------------------------------------------------------------------------------------------------------------------------------------











    






