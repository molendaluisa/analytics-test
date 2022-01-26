/*  2. How common is it for users to switch payment method after inserting their first ad?
   Compare payment methods between the first and second ad insertion. */
   
WITH user_payment_nr AS (
--selecting user, payment method and ranking 1st and 2nd ad insertion

   SELECT
       DISTINCT ad.ACCOUNT_ID                                                          AS user,
       ad.FINAL_PAY_TYPE_FCT                                                           AS payment_method,
       RANK() OVER (PARTITION BY ad.ACCOUNT_ID ORDER BY ad.PUBLISH_DTT ASC)            AS payment_nr
   FROM `luisa-space.sandbox.f_ads` ad
   ORDER BY 1, 3
),
 
pivot_payments AS (
--transposing 1st and 2nd payment method from rows into columns

   SELECT
       *
   FROM user_payment_nr
   PIVOT (ANY_VALUE(payment_method) FOR payment_nr IN (1, 2))
   ORDER BY user
),
 
payment_change_mapping AS (
--mapping same payment method or the switch (from swish to paycard or from paycard to swish)

   SELECT
       *,
 
       CASE
           WHEN _1 = _2 THEN 'same payment method'
           ELSE CONCAT(_1, ' to ', _2)
       END                                                                             AS payment_change
   FROM pivot_payments
),
 
agg AS (
--aggregating on payment change

   SELECT
       payment_change,
       COUNT(*)                                                                        AS volume
   FROM payment_change_mapping
   WHERE payment_change IS NOT NULL
   GROUP BY 1
)
 
--calculating percentage of total
SELECT
   *,
   ROUND(100 * volume/SUM(volume) OVER())                                              AS percentage_of_total
FROM agg
ORDER BY 2 DESC
