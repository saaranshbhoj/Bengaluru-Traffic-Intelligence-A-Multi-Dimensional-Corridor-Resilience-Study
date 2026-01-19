
-- ------------------------------------Road-Level Stability vs Volatility (using stddev & avg together)---------------------------------------------------------
-- -------Query: overall statistics for congestion_score
--  SELECT
--       ROUND(AVG(congestion_score),3)                       AS mean_congestion,
--       ROUND(STDDEV_POP(congestion_score),3)                AS stddev_congestion,
--       ROUND(VAR_POP(congestion_score),3)                   AS variance_congestion,
--       MIN(congestion_score)                       AS min_congestion,
--       MAX(congestion_score)                       AS max_congestion
--   FROM traffic_cleaned_geo
--   LIMIT 1;
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------Road-Level Stability vs Volatility (using stddev & avg together)----------------------------------------------------
-- Query: per-road mean & stddev of congestion
-- WITH daily AS (
--     SELECT
--         DATE(timestamp) AS dt,
--         area,
--         road,
--         AVG(congestion_score) AS avg_congestion
--     FROM traffic_cleaned_geo
--     GROUP BY DATE(timestamp), area, road
-- )
-- SELECT
--     area,
--     road,
--     COUNT(*)                               AS days_observed,
--     ROUND(AVG(avg_congestion), 3)          AS mean_congestion,
--     ROUND(STDDEV(avg_congestion), 3)       AS stddev_congestion,
--     ROUND(100.0 * STDDEV(avg_congestion) / NULLIF(AVG(avg_congestion),0), 3) AS coeff_of_variation
-- FROM daily
-- GROUP BY area, road
-- HAVING COUNT(*) >= 100     -- at least ~3 month of days
-- ORDER BY mean_congestion DESC, stddev_congestion DESC;
--------------------------------------------------------------------------------------------------------------------------------------------------------
                  -- ----------------- TEMPORAL RESILIENCE FOR CORRIDORS IN THEIR BEHAVIOUR(CHRONIC/VOLATILE)-- --------------------------------
                  
-- WITH ct_1 as (
-- SELECT DATE_FORMAT(DATE(timestamp),'%Y-%m') as month,
-- 	ROUND(AVG(congestion_score),2) as avg_congestion,
--     ROUND(STDDEV_SAMP(congestion_score),2) as volatility_congestion,
--     ROUND( ROUND(STDDEV_SAMP(congestion_score),2)/ROUND(AVG(congestion_score),2)* 100,2) as 'CV' 
-- FROM traffic_cleaned_geo
-- WHERE area='Koramangala'
-- GROUP BY DATE_FORMAT(DATE(timestamp),'%Y-%m')),
-- ct_2 as (
-- SELECT month,avg_congestion,
-- 	LAG(avg_congestion) OVER (ORDER BY month) as prev_congestion,
--     ROUND((avg_congestion-LAG(avg_congestion) OVER (ORDER BY month))/LAG(avg_congestion) OVER (ORDER BY month)* 100,2) as pct_change_congestion,
--     CV,
-- 	LAG(CV) OVER (ORDER BY month) as prev_CV,
--     ROUND((CV-LAG(CV) OVER (ORDER BY month))/LAG(CV) OVER (ORDER BY month)* 100,2) as pct_change_CV
-- FROM ct_1)

-- SELECT month,avg_congestion,pct_change_congestion,CV,pct_change_CV
-- FROM ct_2 
-- WHERE pct_change_CV is not null and pct_change_congestion is not null;

-- NOTE: When we segmented our corridors into chronic/volatile it was important for us to check whether these behaviours are temporal resilient
-- or we see some pattern in the specific months.
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------Rolling 7-Day Moving Average & Trend Detection (window + rolling)----------------------------------------------
-- WITH daily AS (
--     SELECT
--         DATE(timestamp) AS date,
--         area,
--         road,
--         AVG(congestion_score) AS avg_congestion
--     FROM traffic_cleaned_geo
--     GROUP BY DATE(timestamp), area, road
-- )
-- SELECT
--     area,road,date,avg_congestion,
--     ROUND(
--         AVG(avg_congestion) OVER (PARTITION BY area, road ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),3) AS 7_day_congestion,
--     ROUND(
--         avg_congestion- LAG(avg_congestion) OVER (PARTITION BY area, road ORDER BY date),3) AS day_change,
--     -- Week-over-week change using 7-day lag
--     ROUND(
--         avg_congestion - LAG(avg_congestion, 7) OVER (PARTITION BY area, road ORDER BY date),3) AS week_change
-- FROM daily
-- WHERE area='Koramangala' 
-- ORDER BY area, road, date;

-- NOTE: For the above method it will be useful if we want to track say for eg: weekly trends in congestion_score for a particular area/corridor
-- and find out if there has been any improvement/degradation in the concerned metric.
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------Outlier Day Detection (Z-score using window function)--------------------------------------------------------
-- WITH daily AS (
--     SELECT DATE(timestamp) AS date,area,road,
--         AVG(congestion_score) AS avg_congestion
-- FROM traffic_cleaned_geo
-- GROUP BY DATE(timestamp), area, road
-- ),
-- stats AS (
--     SELECT area,road,
--         ROUND(AVG(avg_congestion),2)      AS mean_congestion,
--         ROUND(STDDEV_SAMP(avg_congestion),2) AS stddev_congestion
--     FROM daily
--     GROUP BY area, road
-- )
-- SELECT d.area,d.road,d.date,
--     ROUND(d.avg_congestion, 3) AS avg_congestion,
--     ROUND(
--         (d.avg_congestion - s.mean_congestion) / NULLIF(s.stddev_congestion, 0), -- mathematical formula for z-score calculation
--         3
--     ) AS z_score
-- FROM daily d
-- JOIN stats s
--   ON d.area = s.area
--  AND d.road = s.road
-- WHERE s.stddev_congestion > 0
--   AND (d.avg_congestion - s.mean_congestion) / s.stddev_congestion <= -2.5 -- we know that anomaly for the higher side would be +1 congestion_score
-- ORDER BY z_score DESC;

-- NOTE: Contrary to popular beliefs in this use-case even though the distribution is skewed z-score still stands as a better and more robust
-- method to identify dates having anamoly in terms of congestion scores as IQR method was found to be too senstive for our data distribution.
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------Road vs Area Benchmarking (joins + window percentiles)-------------------------------------------------------
-- Here we compare each road to its area average and see which roads are under/over-performing within the same area.
-- Ques: Are areas uniformly congested or is there any volatility within roads of same areas?
-- Ques: If the areas have non uniform congestion distribution then there is a possibility of finding an alternative route in same area for faster commute!

-- WITH daily as (
-- SELECT DATE(timestamp) as date,area,road,
-- 	ROUND(AVG(congestion_score),2) as avg_congestion,
-- 	ROUND(AVG(traffic_volume),2) as avg_traffic_volume
-- FROM traffic_cleaned_geo
-- GROUP BY DATE(timestamp),area,road),

-- area as (
-- SELECT date,area,
-- 	ROUND(AVG(avg_congestion),2) as avg_congestion_area
-- FROM daily
-- GROUP BY date,area)

-- SELECT d.date,d.area,d.road,d.avg_congestion,a.avg_congestion_area,
-- 	ROUND((d.avg_congestion-a.avg_congestion_area),2) as delta_congestion -- most important metric in this analysis
-- FROM daily d JOIN area a ON d.area=a.area and d.date=a.date
-- ORDER BY delta_congestion DESC
-- LIMIT 50;

-- NOTE: The area vs corridor analysis for same date reveals a positive insight that majority of the dates the two corridors of the same area
-- were not gridlocked creating a possibility of better alternate routing and diversion of traffic by the local traffic police management. 
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------Percentile ranking of roads by area.You can wrap the road-level aggregates in a window function:-----------------------------------
-- WITH road_stats AS (
--     SELECT area,road,
--         AVG(congestion_score) AS mean_congestion
--     FROM traffic_cleaned_geo
--     GROUP BY area, road
-- )
-- SELECT
--     area,road,
--     ROUND(mean_congestion, 3) AS mean_congestion,
--     PERCENT_RANK() OVER (PARTITION BY area ORDER BY mean_congestion) AS pct_rank_in_area
-- FROM road_stats
-- ORDER BY area, pct_rank_in_area DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------BUCKETING THE ROADS BASED ON VOLATILITY-----------------------------------------------------------------------
-- ------------------- RANGE OF VOLATILITY IN DATASET : 0.14-0.25

-- WITH ct_1 as (
-- SELECT area,road,
--         ROUND(AVG(congestion_score),2) AS avg_congestion,
--         ROUND(STDDEV_SAMP(congestion_score),2) as std_deviation
-- FROM traffic_cleaned_geo
-- GROUP BY area, road
-- ORDER BY std_deviation)

-- SELECT area,road,avg_congestion,std_deviation,
-- 	CASE 
-- 		WHEN std_deviation < 0.16 THEN 'Low'
--         WHEN std_deviation <0.20 THEN 'Medium'
-- 		ELSE 'High'
-- 	END as volatility_level
-- FROM ct_1;
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------









