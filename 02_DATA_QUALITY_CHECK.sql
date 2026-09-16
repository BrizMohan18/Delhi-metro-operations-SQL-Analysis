SELECT COUNT(*) AS invalid_fares
FROM trips
WHERE fare <= 0;

SELECT COUNT(*) AS same_station_trips
FROM trips
WHERE entry_station_id = exit_station_id;