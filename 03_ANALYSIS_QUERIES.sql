-- Analysis 1 (Overall KPIs)

SELECT 
    COUNT(*) AS total_trips,
    ROUND(SUM(fare),2) AS gross_revenue,
    ROUND(AVG(fare),2) AS average_fare
FROM trips;

-- Analysis 2 (Passenger Segments)

SELECT 
    p.passenger_type,
    COUNT(*) AS trips,
    ROUND(SUM(t.fare),2) AS revenue,
    ROUND(AVG(t.fare),2) AS avg_fare
FROM passengers p
JOIN trips t
    ON p.passenger_id = t.passenger_id
GROUP BY p.passenger_type
ORDER BY revenue DESC;

-- Analysis 3 (Top Stations)

SELECT 
    s.station_name,
    COUNT(*) AS entries
FROM trips t
JOIN stations s
    ON t.entry_station_id = s.station_id
GROUP BY s.station_id, s.station_name
ORDER BY entries DESC
LIMIT 10;

-- Analysis 4 (Peak Demand)

SELECT 
    peak_period,
    COUNT(*) AS trips,
    ROUND(SUM(fare),2) AS revenue
FROM trips
GROUP BY peak_period
ORDER BY trips DESC;

-- Analysis 5 (Weekday vs Weekend)

SELECT 
    c.day_type,
    COUNT(*) AS trips,
    ROUND(SUM(t.fare),2) AS revenue
FROM trips t
JOIN service_calendar c
    ON t.trip_date = c.service_date
GROUP BY c.day_type;

-- Analysis 6 (Monthly Revenue)

SELECT 
    DATE_FORMAT(trip_date,'%Y-%m') AS month,
    COUNT(*) AS trips,
    ROUND(SUM(fare),2) AS revenue
FROM trips
GROUP BY DATE_FORMAT(trip_date,'%Y-%m')
ORDER BY month;

-- Analysis 7 (payment Performence)

SELECT 
    payment_status,
    COUNT(*) AS transactions,
    ROUND(
        100 * COUNT(*) / 
        (SELECT COUNT(*) FROM payments),2
    ) AS percentage
FROM payments
GROUP BY payment_status;

-- Analysis 8 (Delay Analysis)

SELECT 
    line_name,
    COUNT(*) AS incidents,
    ROUND(AVG(delay_minutes),2) AS avg_delay,
    MAX(delay_minutes) AS max_delay
FROM delays
GROUP BY line_name
ORDER BY avg_delay DESC;

-- Analysis 9 (Ranking)

WITH station_counts AS (
    SELECT
        s.line_name,
        s.station_id,
        s.station_name,
        COUNT(t.trip_id) AS entries
    FROM stations s
    LEFT JOIN trips t
        ON s.station_id = t.entry_station_id
    GROUP BY
        s.line_name,
        s.station_id,
        s.station_name
)

SELECT *,
       DENSE_RANK() OVER(
           PARTITION BY line_name
           ORDER BY entries DESC
       ) AS station_rank
FROM station_counts
ORDER BY line_name, station_rank;

-- Analysis 10 (Repeat Passengers)

 SELECT
    passenger_id,
    COUNT(*) AS trip_count,
    ROUND(SUM(fare),2) AS spend
FROM trips
GROUP BY passenger_id
HAVING COUNT(*) >= 5
ORDER BY trip_count DESC;

-- Analysis 11 (Running Revenue)

WITH daily AS (
    SELECT
        trip_date,
        SUM(fare) AS revenue
    FROM trips
    GROUP BY trip_date
)

SELECT
    trip_date,
    ROUND(revenue,2) AS revenue,
    ROUND(
        SUM(revenue) OVER(
            ORDER BY trip_date
        ),2
    ) AS running_revenue
FROM daily
ORDER BY trip_date;