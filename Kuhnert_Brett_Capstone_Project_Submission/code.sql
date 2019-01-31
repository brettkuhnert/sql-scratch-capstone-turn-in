/*
1. Slide 1.1: Campaign and Sources
*/

        
/*Here is the query used to return the total unique campaign count:*/
SELECT COUNT (DISTINCT utm_campaign) AS 'distinct_campaigns'
FROM page_visits;


/*Here is the query used to return the total unique source count:*/
SELECT COUNT (DISTINCT utm_source) AS 'distinct_sources'
FROM page_visits;


/*The following query returns both the distinct campaign and its associated source:*/
SELECT DISTINCT utm_campaign AS 'campaign', utm_source AS 'source'
FROM page_visits;

	
/*
2. Slide 1.2: Where are users going?
*/

/*Here is the query used to return the list of CTS pages:*/
SELECT DISTINCT page_name AS 'pages'
FROM page_visits;
	
/*
3. Slides 2.1-2.2: First Touch Attribution: 
*/

/*Here is the query used to return a summary of first touches by source & campaign:*/
WITH first_touch AS (
   SELECT user_id, MIN(timestamp) as first_touch_at
   FROM page_visits
   GROUP BY user_id),
ft_attr AS (
   SELECT ft.user_id,
      ft.first_touch_at,
      pv.utm_source,
      pv.utm_campaign
   FROM first_touch ft
   JOIN page_visits pv
   ON ft.user_id = pv.user_id
   AND ft.first_touch_at = pv.timestamp
 )
SELECT ft_attr.utm_source AS 'source', ft_attr.utm_campaign AS 'campaign', COUNT(*) AS 'total_first_touches'
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
		
/*
4. Slides 2.3-2.4: Last Touch Attribution: 
*/

/*Here is the query used to return a summary of last touches by source & campaign:*/
WITH last_touch AS (
   SELECT user_id,
       MAX(timestamp) as last_touch_at
   FROM page_visits
   GROUP BY user_id),
lt_attr AS (
   SELECT lt.user_id,
      lt.last_touch_at,
      pv.utm_source,
      pv.utm_campaign
   FROM last_touch lt
   JOIN page_visits pv
   ON lt.user_id = pv.user_id
   AND lt.last_touch_at = pv.timestamp
 )
SELECT lt_attr.utm_source AS 'source', lt_attr.utm_campaign AS 'campaign', COUNT(*) AS 'total_last_touches'
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
	
/*
5. Slide 2.5: How many visitors are buying?
*/

/* Here is the query to return the total count of unique visitors (users) who make a purchase:*/
SELECT COUNT (DISTINCT user_id) AS 'visitor_purchases'
FROM page_visits
WHERE page_name = '4 - purchase';

/*
6. Slide 2.6: How many visitors are buying? Cont’d
*/

/*Here is the query used to return a summary of last touches on the '4 - purchase' page, by source & campaign:*/
WITH last_touch AS (
   SELECT user_id,
       MAX(timestamp) as last_touch_at
   FROM page_visits
     WHERE page_name = '4 - purchase'
   GROUP BY user_id),
lt_attr AS (
   SELECT lt.user_id,
      lt.last_touch_at,
      pv.utm_source,
      pv.utm_campaign
   FROM last_touch lt
   JOIN page_visits pv
   ON lt.user_id = pv.user_id
   AND lt.last_touch_at = pv.timestamp
 )
SELECT lt_attr.utm_source AS 'source', lt_attr.utm_campaign AS 'campaign', COUNT(*) AS 'total_last_touches'
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
7. Slide 2.8: How can more users complete the trip?
*/

/*This simple query yields 'purchase page' visits by user, listed in descending order to attempt to identify repeat customers:*/

SELECT user_id, COUNT(user_id) AS 'purchase_page_visits'
FROM page_visits
WHERE page_name = '4 - purchase'
GROUP BY user_id
ORDER BY 2 DESC
LIMIT 20;

/*The following query returns the 'last touch' visitor count grouped by page:*/

WITH last_page AS (
   SELECT user_id, MAX(timestamp), page_name
   FROM page_visits
   GROUP BY user_id)
SELECT page_name AS last_page, COUNT(*) AS visitor_count
FROM last_page
GROUP BY page_name;