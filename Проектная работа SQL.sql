-- Запрос 1. Выгрузить продажи смартфонов по ценовым сегментам и брендам, кодам торговых точек.

SELECT 
  shops."MARKET_CODE",
  shops."CODE_POINTS_SALE" AS OFFICE,
  eq."ITEM_MARK",
  CASE WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) < 5000 THEN '1. 0 < 5000 RUB'  
  WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 5000 AND 10000 THEN '2. 5000 < 10000 RUB'
  WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 10000 AND 15000 THEN '3. 10000 < 15000 RUB'
  WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 15000 AND 20000 THEN '4. 15000 < 20000 RUB'
  WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 20000 AND 25000 THEN '5. 20000 < 25000 RUB'
  WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 25000 AND 30000 THEN '6. 25000 < 30000 RUB'
  WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) > 30000 THEN '7. 30000 RUB и более'
  ELSE '0' END 
  AS Price_Category,
  SUM(sales."QTY") AS QTY,
  SUM(sales."AMOUNT_RUR") AS AMOUNT_RUR
FROM sales
LEFT JOIN
	items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN
	shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
WHERE
	eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo')
	and sales."TP" = 'I'
GROUP BY
	shops."MARKET_CODE",
	shops."CODE_POINTS_SALE",
	eq."ITEM_MARK",
CASE
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) < 5000 THEN '1. 0 < 5000 RUB'
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 5000 AND 10000 THEN '2. 5000 < 10000 RUB'
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 10000 AND 15000 THEN '3. 10000 < 15000 RUB'
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 15000 AND 20000 THEN '4. 15000 < 20000 RUB'
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 20000 AND 25000 THEN '5. 20000 < 25000 RUB'
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) BETWEEN 25000 AND 30000 THEN '6. 25000 < 30000 RUB'
	WHEN cast(cast(sales."AMOUNT_RUR" as numeric) as float) > 30000	THEN '7. 30000 RUB и более' ELSE '0' 
END;

-- Запрос 2. Выгрузить выручку, объем продаж и среднюю цену смартфона в каждом регионе, отсортировать по средней цене.

SELECT ro."REGION"
      , SUM(sales."AMOUNT_RUR") as Revenue
      , SUM(sales."QTY") as Volume
      , SUM(sales."AMOUNT_RUR")/SUM(sales."QTY") as Avg_Price 
FROM sales 
LEFT JOIN
	items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN
	shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
INNER JOIN retail_offices ro on shops."CODE_POINTS_SALE" = ro."OFFICE_ID"
WHERE
	eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo')
	and sales."TP" = 'I'
GROUP BY ro."REGION"
ORDER BY SUM(sales."AMOUNT_RUR")/SUM(sales."QTY") desc;


-- Запрос 3. Выгрузить регионы с количеством точкек более 200.
SELECT ro."REGION", count(ro."OFFICE_ID") from (select * from shops where "CODE_POINTS_SALE" is not null) a 
LEFT JOIN retail_offices ro on a."CODE_POINTS_SALE" = ro."OFFICE_ID"
WHERE  a."CODE_POINTS_SALE" is not null  
GROUP BY ro."REGION"
HAVING count(ro."OFFICE_ID")> 200;


--- Запрос 4. Выгрузить номера чеков по акции "3 аксессуара за 99 руб.", сумму акционного чека и количество позиций в чеке.
with action as 
(
select 
		distinct "DOC_NUMBER", 
		cast("OPER_DATE" as date) as "OPER_DATE", 
		"KEY_DISCOUNT",
		"DISCOUNT_NAME" 
from 
	    discount as disc
									
where 
		disc."DISCOUNT_NAME" = '3 аксессуара за 99 руб.'
		and cast("OPER_DATE" as date) >= '20170701'
		)
select sales."DOC_NUMBER", SUM("AMOUNT_RUR") as summ_chek, count(sales."ITEM_ARTICLE") as count_chek, action."DISCOUNT_NAME"  
from sales 
inner join action on sales."DOC_NUMBER" = action."DOC_NUMBER" and cast(sales."OPER_DATE" as date) = cast(action."OPER_DATE" as date)
group by sales."DOC_NUMBER", action."DISCOUNT_NAME";


--- Запрос 5. Выгрузить top 100 чеков с наибольшим отклонением от средней цены смартфона в филиале, проданного с аксессуаром.
with smart as 
(
select
	sales."DOC_NUMBER",
	sales."OPER_DATE",
	sum(sales."QTY") as QTY,
	sum(sales."AMOUNT_RUR") as "SUM_RUR",
	sum(cast(sales."AMOUNT_RUR" as numeric))/sum(sales."QTY") as "PRICE",
	shops."MARKET_CODE",
	shops."CODE_POINTS_SALE"
from sales
left join items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN
shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
where
sales."TP" = 'I' 
and shops."CODE_POINTS_SALE" is not NULL
and eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo')
group by shops."MARKET_CODE", shops."CODE_POINTS_SALE", sales."DOC_NUMBER", sales."OPER_DATE"
),
Acs AS
(
SELECT
  sales."OPER_DATE",
  sales."DOC_NUMBER"
FROM sales
LEFT JOIN
  items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
WHERE
  eq."ITEM_CATEGORY" in ('Accessories')
)
select smart."DOC_NUMBER", smart."MARKET_CODE", smart."PRICE", AVG(cast(smart."PRICE" as numeric)) over (PARTITION BY smart."MARKET_CODE") as avg_sum_market_code, cast(smart."PRICE" as numeric) - AVG(cast(smart."PRICE" as numeric)) over (PARTITION BY smart."MARKET_CODE") as difference
from smart
inner join Acs
on smart."DOC_NUMBER" = Acs."DOC_NUMBER" and cast(smart."OPER_DATE" as date) = cast(Acs."OPER_DATE" as date)
order by (cast(smart."PRICE" as numeric) - AVG(cast(smart."PRICE" as numeric)) over (PARTITION BY smart."MARKET_CODE")) desc
LIMIT 100;


--- Запрос 6. Вывести чеки с более чем 2-мя позициями аксессуаров в чеке 
select "OPER_DATE", "DOC_NUMBER", "Кол_во_аксессуаров" from
(
SELECT
  sales."OPER_DATE",
  sales."DOC_NUMBER",
  count(sales."ITEM_ARTICLE") over (PARTITION BY sales."DOC_NUMBER") as "Кол_во_аксессуаров"
FROM sales
LEFT JOIN
  items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
WHERE
  eq."ITEM_CATEGORY" in ('Accessories')
) a 
where "Кол_во_аксессуаров" >= 2
group by "OPER_DATE", "DOC_NUMBER", "Кол_во_аксессуаров"
limit 100;

-- Запрос 7. Вывести долю каждой позиции в сумме чека
SELECT
  sales."OPER_DATE",
  sales."DOC_NUMBER",
  eq."ITEM_ARTICLE",
  sales."AMOUNT_RUR"/sum(sales."AMOUNT_RUR") over (PARTITION BY sales."DOC_NUMBER") as "Доля_позиции_в_чеке"
FROM sales
LEFT JOIN
  items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
where sales."AMOUNT_RUR" is not null and eq."ITEM_ARTICLE" is not null
;

-- Запрос 8. Вывести долю каждого бренда в общих продажах смартфонов

select a."ITEM_MARK", sum(a."Summ_Mark") over (PARTITION BY a."ITEM_MARK")/(sum(a."Summ_Mark") over ())  as "Доля_бренда", a."Summ_Mark" from
(
select
	eq."ITEM_MARK",
	sum(sales."AMOUNT_RUR") as "Summ_Mark"	 
from sales
left join items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
where
sales."TP" = 'I' 
and eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo')
group by eq."ITEM_MARK"
) as a
group by a."ITEM_MARK", a."Summ_Mark"
order by a."Summ_Mark" desc;

-- Запрос 9. Выгрузить самые дорогие проданные смартфоны в каждом регионе
select a."REGION", a."AMOUNT_RUR" from
(
select row_number() over (partition by ro."REGION" order by sales."AMOUNT_RUR" desc) as num, ro."REGION", sales."AMOUNT_RUR"
from sales 
left join items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
INNER JOIN retail_offices ro on shops."CODE_POINTS_SALE" = ro."OFFICE_ID"
where
sales."TP" = 'I' 
and eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo')
) a
where a.num = 1
order by a."AMOUNT_RUR" desc;

-- Запрос 10. Выгрузить кол-во проданных позиций в каждом филиале
select ro."BRANCHNAME", count(sales."DOC_NUMBER") as "Кол_во_позиций"
from sales 
left join items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
INNER JOIN retail_offices ro on shops."CODE_POINTS_SALE" = ro."OFFICE_ID"
where
sales."TP" = 'I'
group by ro."BRANCHNAME"
order by count(sales."DOC_NUMBER") desc;

--- Создание представлений 
--- Представление 1. Чеки с продажами смартфонов
CREATE OR REPLACE VIEW Smartphones AS
select ro."REGION" as "Регион", ro."BRANCHNAME" as "Филиал", shops."CODE_POINTS_SALE" as "Код_ТТ", sales."DOC_NUMBER" as "Номер_чека", sales."OPER_DATE" as Дата, sales."ITEM_ARTICLE" as "Артикул", eq."ITEM_NAME" as "Наименование", eq."ITEM_MARK" as "Бренд", sales."QTY" as "Кол_во", sales."AMOUNT_RUR" as "Сумм_руб"
from sales 
left join items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
INNER JOIN retail_offices ro on shops."CODE_POINTS_SALE" = ro."OFFICE_ID"
where
sales."TP" = 'I' 
and eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo'); 

--- Представление 2. Количество аксессуаров в чеках со смартфонами
CREATE OR REPLACE VIEW Smartphones_with_Acs AS
with Acs as (
select "OPER_DATE", "DOC_NUMBER", "Кол_во_аксессуаров" from
(
SELECT
  sales."OPER_DATE",
  sales."DOC_NUMBER",
  count(sales."ITEM_ARTICLE") over (PARTITION BY sales."DOC_NUMBER") as "Кол_во_аксессуаров"
FROM sales
LEFT JOIN
  items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
WHERE
  eq."ITEM_CATEGORY" in ('Accessories')
) a 
group by "OPER_DATE", "DOC_NUMBER", "Кол_во_аксессуаров"
),
smart as 
(
select ro."REGION" as "Регион", ro."BRANCHNAME" as "Филиал", shops."CODE_POINTS_SALE" as "Код_ТТ", sales."DOC_NUMBER" as "Номер_чека",  sales."OPER_DATE" as Дата, sales."ITEM_ARTICLE" as "Артикул", eq."ITEM_NAME" as "Наименование", eq."ITEM_MARK" as "Бренд", sales."QTY" as "Кол_во", sales."AMOUNT_RUR" as "Сумм_руб"
from sales 
left join items eq ON sales."ITEM_ARTICLE" = eq."ITEM_ARTICLE"
LEFT JOIN shops on shops."CODE_OFFICE" = sales."CODE_OFFICE"
INNER JOIN retail_offices ro on shops."CODE_POINTS_SALE" = ro."OFFICE_ID"
where
sales."TP" = 'I' 
and eq."ITEM_SUBCATEGORY" in ('SMARTPHONES', 'SMARTPHONES Demo')
)
select smart.*, Acs."Кол_во_аксессуаров" from smart 
inner join Acs on smart."Номер_чека" = Acs."DOC_NUMBER" and cast(smart."Дата" as date) = cast(Acs."OPER_DATE" as date);



