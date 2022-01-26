/*  4. How do add-on products perform? Does that differ between various categories?
   Compare selling time by add-on and category sections. */
   
WITH calc_selling_time AS (
--calculating selling time in days

   SELECT
       c.CATEGORY_SECTION                              AS category_section,
       ad.ADDITIONAL_PRODUCT_TYPE                      AS add_on,
       DATE_DIFF(DELETE_DTT, PUBLISH_DTT, DAY)         AS selling_time_day
   FROM `luisa-space.sandbox.f_ads` ad
   LEFT JOIN `luisa-space.sandbox.d_categories` c
       ON ad.CATEGORY_GROUP_ID = c.CATEGORY_GROUP_ID
   WHERE REMOVE_REASON_FCT = 'sold_on_blocket' --include only items sold on blocket
),
 
agg_and_avg AS (
--aggregating selling time average on section and add on

   SELECT
       category_section,
       add_on,
       ROUND(AVG(selling_time_day))                        AS avg_selling_time_day
   FROM calc_selling_time
   GROUP BY 1, 2
   ORDER BY 1, 2
)

--transposing add on from rows into columns
SELECT
   *
FROM agg_and_avg
PIVOT (AVG(avg_selling_time_day) FOR add_on IN (NULL, 'GALLERY', 'AUTOBUMP'))
ORDER BY category_group
