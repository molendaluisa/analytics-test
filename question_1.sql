--1. How big is the share of users who inserted an ad in each category section?

WITH category_acc_agg AS (
-- selecting category section and aggregating unique users

   SELECT
       c.CATEGORY_SECTION                      AS category_section,
       COUNT(DISTINCT ad.ACCOUNT_ID)           AS cnt_account,
   FROM `luisa-space.sandbox.f_ads` ad
   LEFT JOIN `luisa-space.sandbox.d_categories` c
       ON c.CATEGORY_GROUP_ID = ad.CATEGORY_GROUP_ID
   GROUP BY 1
),

running_total AS (
--calculating runing total

   SELECT
       caa.*,
       SUM(cnt_account) OVER()                 AS total_accounts
   FROM category_acc_agg caa
)
 
--calculating share of users per section

SELECT
   category_section,
   ROUND((cnt_account/total_accounts) * 100)   AS share_of_users
FROM running_total rt
ORDER BY 2 DESC
