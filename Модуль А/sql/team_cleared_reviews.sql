CREATE OR REPLACE VIEW team_rksi.team_rksi_cleared_reviews AS
SELECT DISTINCT ON (order_id)
	review_id,
	order_id,
	CASE 
	  WHEN review_score <= 0 THEN 1
	  WHEN review_score > 5 THEN 5
	  ELSE review_score
	END,
	review_comment_title,
	review_comment_message,
	review_creation_date::date,
	review_answer_timestamp
FROM stg.reviews
ORDER BY order_id, review_creation_date DESC
