-- ABC
WITH m AS (
  SELECT
    date_trunc('month', f.scheduled_departure)::date AS month,
    s.fare_conditions,
	count(*) cnt_segments,
    sum(s.price) AS revenue
  FROM bookings.segments s
  JOIN timetable f ON f.flight_id = s.flight_id
  GROUP BY 1,2
),
ranked AS (
  SELECT
    *,
    sum(revenue) OVER (PARTITION BY month) AS revenue_total,
    sum(revenue) OVER (
      PARTITION BY month
      ORDER BY revenue DESC, fare_conditions
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS revenue_cum
  FROM m
)
SELECT
  month, fare_conditions, revenue, cnt_segments,
  revenue::numeric / revenue_total AS share,
  revenue_cum::numeric / revenue_total AS cum_share,
  CASE
    WHEN revenue_cum::numeric / revenue_total <= 0.80 THEN 'A'
    WHEN revenue_cum::numeric / revenue_total <= 0.95 THEN 'B'
    ELSE 'C'
  END AS abc_class
FROM ranked
ORDER BY month, revenue DESC;

SELECT 
	month, fare_conditions, revenue,
	revenue / sum AS share,
	revenue_cum / sum as cum_share,
	CASE
	  WHEN revenue_cum / sum <= 0.80 then 'A'
	  when revenue_cum / sum <= 0.95 THEN 'B'
	  ELSE 'C'
	END AS abc_class
FROM (
	SELECT *,
		sum(revenue) over(partition by month),
		sum(revenue) over(partition by month order by revenue DESC, fare_conditions
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as revenue_cum
	FROM (
		SELECT
			date_trunc('month', scheduled_departure)::date as month,
			fare_conditions,
			sum(price) as revenue
		FROM segments
		JOIN timetable USING(flight_id)
		GROUP BY 1, 2
	)
)
order by month, revenue DESC