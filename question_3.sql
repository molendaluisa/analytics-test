/*  3. How willing are users to insert ads in different categories?
   Consider first and second ad insertion across category groups and category sections */

WITH user_ad_nr AS (
--selecting user, category id and ranking 1st and 2nd ad insertion
   SELECT
       DISTINCT ad.ACCOUNT_ID                                                                          AS user,
       ad.CATEGORY_GROUP_ID                                                                            AS category_group_id,
       RANK() OVER (PARTITION BY ad.ACCOUNT_ID ORDER BY ad.PUBLISH_DTT ASC)                            AS ad_nr
   FROM `luisa-space.sandbox.f_ads` ad
   ORDER BY 1, 3
),
 
pivot_ads AS (
--transposing 1st and 2nd category id from rows into columns

   SELECT
       *
   FROM user_ad_nr
   PIVOT (ANY_VALUE(category_group_id) FOR ad_nr IN (1, 2))
   ORDER BY user
),
 
category_change_mapping AS (
--mapping same id or the switch in a group or section level

   SELECT
       user,

       CASE
           WHEN c1.CATEGORY_GROUP = c2.CATEGORY_GROUP THEN 'same group'
           ELSE CONCAT(c1.CATEGORY_GROUP, ' to ', c2.CATEGORY_GROUP)
       END                                                                                             AS group_change,
 
       CASE
           WHEN c1.CATEGORY_SECTION = c2.CATEGORY_SECTION THEN 'same section'
           ELSE CONCAT(c1.CATEGORY_SECTION, ' to ', c2.CATEGORY_SECTION)
       END                                                                                             AS section_change
 
   FROM pivot_ads pa
   LEFT JOIN `luisa-space.sandbox.d_categories` c1
       ON pa._1 = c1.CATEGORY_GROUP_ID
   LEFT JOIN `luisa-space.sandbox.d_categories` c2
       ON pa._2 = c2.CATEGORY_GROUP_ID
),
 
agg AS (
--aggregating users by section and group change

   SELECT
       section_change,
       group_change,
       COUNT(*)                                                                                        AS volume
   FROM category_change_mapping
   WHERE section_change IS NOT NULL OR group_change IS NOT NULL --excluding one time user ad insertion (users that only inserted one ad)
   GROUP BY 1, 2
)
 
 
SELECT
   *
FROM agg
ORDER BY 3 DESC