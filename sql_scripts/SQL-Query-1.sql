-- CREATE DATABASE IF NOT EXISTS bengaluru_traffic;
-- USE bengaluru_traffic;

-- CREATE TABLE traffic_cleaned_geo(
--     id BIGINT AUTO_INCREMENT PRIMARY KEY,
-- 	timestamp DATETIME NOT NULL,
--     area VARCHAR(100) NOT NULL,
--     road VARCHAR(150) NOT NULL,

--     traffic_volume INT,
--     avg_speed DECIMAL(6,2),
--     travel_time_index DECIMAL(6,3),
--     congestion_level VARCHAR(20),

--     road_capacity_utilization DECIMAL(5,2),
--     incident_reports INT,
--     environmental_impact DECIMAL(10,3),

--     public_transport_usage DECIMAL(5,2),
--     traffic_signal_compliance DECIMAL(5,2),
--     parking_usage DECIMAL(5,2),

--     ped_cycle_count INT,
--     weather VARCHAR(50),
--     roadwork VARCHAR(50),
--     congestion_score DECIMAL(6,3),
--     lat DECIMAL(9,6),
--     lon DECIMAL(9,6)
-- );


-- LOAD DATA LOCAL INFILE 'C:/Users/asbho/OneDrive/Desktop/Pandas/Bengluru Traffic Analysis/data/cleaned/traffic_cleaned_geo.csv'
-- INTO TABLE traffic_cleaned_geo
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (timestamp,
--  area,
--  road,
--  traffic_volume,
--  avg_speed,
--  travel_time_index,
--  congestion_level,
--  road_capacity_utilization,
--  incident_reports,
--  environmental_impact,
--  public_transport_usage,
--  traffic_signal_compliance,
--  parking_usage,
--  ped_cycle_count,
--  weather,
--  roadwork,
--  congestion_score,
--  latitude,
--  longitude
-- );
-- SELECT * FROM traffic_cleaned_geo LIMIT 10;