-- Создаём витрину с накопительными итогами и MoM изменениями по бронированиям
CREATE MATERIALIZED VIEW team_6.mom_bookings_mart AS
SELECT 
	book_date,
	total_day,
	lag(total_day) OVER(ORDER BY book_date) as prev_month_revenue,
	(total_day / lag(total_day) OVER(ORDER BY book_date) - 1) * 100 as prev_month_diff,
	SUM(total_day) over(partition by date_part('month', book_date) ORDER BY book_date) as revenue_cum_all	
FROM (
	SELECT
		date_trunc('day', timezone('UTC', book_date))::date as book_date,
		sum(total_amount) as total_day
	from bookings.bookings
	group by 1
);
