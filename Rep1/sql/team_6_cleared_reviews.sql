-- Очищенное представление таблицы отзывов
CREATE OR REPLACE VIEW team_6.team_6_cleared_reveiws AS
SELECT DISTINCT ON(order_id) -- убираем дубликаты отзывов к одному заказу, выбираем самый свежий
	review_id,
	order_id,
	CASE
	  WHEN review_score <= 0 THEN 1 -- Отзывы имеющие оценку 0 и ниже приводим к 1
	  WHEN review_score >= 6 THEN 5 -- Отзывы имеющие оценку 6 и выше приводим к 5
	  ELSE review_score
	END,
	review_comment_title,
	review_comment_message,
	review_creation_date::date -- приводим к типу date, т.к. данные в таблице не имеют времени
FROM stg.reviews
ORDER BY order_id, review_creation_date DESC -- сортируем по убыванию дат, чтобы выбирались более новые отзывы

