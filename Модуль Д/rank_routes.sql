-- Топ 20 маршрутов по выручке
CREATE MATERIALIZED VIEW top20routes AS
SELECT *
FROM (
	SELECT *,
		DENSE_RANK() OVER(ORDER BY sum_price DESC) as rank
	FROM (
		SELECT
			CONCAT(route_no, ': ', departure_airport, ' -> ', arrival_airport),
			SUM(price) sum_price
		from timetable
		JOIN segments USING(flight_id)
		GROUP BY 1
	)
)
WHERE rank <= 20;