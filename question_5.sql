/*  5. How fast are items getting sold in different category sections? 
Is number of received ad views a good predictor of selling time? */

WITH calc_selling_time AS (
    SELECT
        c.CATEGORY_SECTION                              AS category_section,
        DATE_DIFF(DELETE_DTT, PUBLISH_DTT, DAY)         AS selling_time_day,
        v.AD_VIEWS                                      AS ad_views
    FROM `luisa-space.sandbox.f_ads` ad
    LEFT JOIN `luisa-space.sandbox.d_categories` c
        ON ad.CATEGORY_GROUP_ID = c.CATEGORY_GROUP_ID
    LEFT JOIN `luisa-space.sandbox.f_views` v
        ON ad.AD_ID = v.AD_ID
    WHERE REMOVE_REASON_FCT = 'sold_on_blocket'
)

SELECT
    category_section,
    ROUND(AVG(selling_time_day))                        AS avg_selling_time_day,
    SUM(ad_views)                                       AS sum_ad_views
FROM calc_selling_time
GROUP BY 1
ORDER BY 2 
