SELECT 'ФИО: Пронченко Павел';


-- Вывести список пользователей в формате userId, movieId, normed_rating, avg_rating где
--
--   userId, movieId - без изменения
--  для каждого пользователя преобразовать рейтинг r в нормированный - normed_rating=(r - r_min)/(r_max - r_min), где r_min и r_max соответственно минимально и максимальное значение рейтинга у данного 
--  пользователя
--  avg_rating - среднее значение рейтинга у данного пользователя
-- Вывести первые 30 таких записей


SELECT 
	userId
	, movieId
	, (rating - MIN(rating) OVER (PARTITION BY userId))/(MAX(rating) OVER (PARTITION BY userId) - MIN(rating) OVER (PARTITION BY userId)) as normed_rating
	, (avg(rating) OVER (PARTITION BY userId)) as avg_rating 
    from (select distinct userId, movieId, rating from ratings) s
    ORDER BY userId , rating DESC LIMIT 30;


-- 2 ETL

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "DROP TABLE IF EXISTS keywords"

echo "Загружаем keywords.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE IF NOT EXISTS keywords (
    Id bigint,
    tags text   
  );'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy keywords FROM '/data/keywords.csv' DELIMITER ',' CSV HEADER"



-- 3 TRANSFORM
with top_rated as 
(SELECT rt.movieID, avg(rt.rating) as avg_rating from ratings as rt
inner join (select distinct movieid, count(userid) as cnt from ratings group by movieid) as r
on r.movieId = rt.movieId
where r.cnt >= 50 
group by rt.movieId 
order by rt.movieId, avg(rating) desc
LIMIT 150)
select top_rated.movieId, top_rated.avg_rating, keywords.tags
into top_rated_tags 
from top_rated
left join keywords on top_rated.movieId = keywords.Id;

--4 LOAD
echo "Выгружаем top_rated_tags.tsv..."
psql --host $APP_POSTGRES_HOST -U postgres -c "\\copy (select * from top_rated_tags) to 'top_rated_tags.tsv' delimiter as E'\t'"








