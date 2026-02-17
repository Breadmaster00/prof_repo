-- Очищенное представление таблицы оплат
CREATE OR REPLACE VIEW team_6.team_6_cleared_payments AS
SELECT DISTINCT ON(order_id, payment_value) -- убираем дубликаты по айди заказа и последовательности оплаты
	order_id,
	payment_sequential,
	payment_type, 
	payment_installments,
	payment_value
FROM stg.payments
ORDER BY order_id, payment_value DESC; -- Сортируем по убыванию чтобы distinct on выбрал строку с наибольшей оплатой
