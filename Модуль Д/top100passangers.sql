SELECT *
FROM (
	SELECT *, dense_rank() OVER(order by total_pay DESC) as rank
	FROM (
		select 
			passenger_id,
			passenger_name,
			SUM(price) as total_pay
		from tickets 
		join segments using(ticket_no)
		GROUP BY 1, 2
	)
)
WHERE rank <= 100