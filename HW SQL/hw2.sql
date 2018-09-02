SELECT 'ФИО: Пронченко Павел';


-- 1.1 SELECT , LIMIT - выбрать 10 записей из таблицы rating

select * from ratings LIMIT 10;

-- 1.2 WHERE, LIKE - выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000
select * from links 
where imdbid like '%42' 
and movieid between 100 and 1000 
limit 10;

-- 2.1 INNER JOIN выбрать из таблицы links все imdb_id, которым ставили рейтинг 5
select imdbid from links l 
inner join ratings r on l.movieid = r.movieid 
where r.rating = 5 
limit 10;

--3.1 COUNT() Посчитать число фильмов без оценок
SELECT count(links.movieid)  
FROM links 
LEFT JOIN ratings 
ON links.movieid=ratings.movieid 
WHERE ratings.movieid IS NULL;

--3.2 GROUP BY, HAVING вывести top-10 пользователей, у который средний рейтинг выше 3.5
select  userid, AVG(rating) as avg_rating 
from ratings r 
inner join links l on r.movieid = l.movieid 
group by userid 
having AVG(rating) > 3.5 
order by avg(r.rating) desc 
limit 10;

--4.1 Подзапросы: достать 10 imbdId из links у которых средний рейтинг больше 3.5
select imdbId from links l 
inner join 
(select movieid, avg(rating) as avg_rating from ratings
group by movieid) r 
on r.movieid = l.movieid
where r.avg_rating > 3.5 
limit 10;

--4.2 Common Table Expressions: посчитать средний рейтинг по пользователям, у которых более 10 оценок

with count_ratings as 
(
select userid, count(rating) as count_rat 
from ratings
group by userid
),
avg_rating as
(
select userid, avg(rating) as avg_rating from ratings
group by userid
)
select ar.userid, ar.avg_rating from count_ratings cr
inner join avg_rating ar on cr.userid = ar.userid
where cr.count_rat > 10
limit 10;



