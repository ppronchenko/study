SELECT ('ФИО: Пронченко Павел');

--- Топ-5 таблиц в базе 
SELECT TABLE_NAME,
pg_size_pretty(size) AS total_size
FROM (SELECT TABLE_NAME,
pg_total_relation_size(TABLE_NAME) AS size
FROM (SELECT ('' || table_schema || '.' || TABLE_NAME || '') AS TABLE_NAME FROM information_schema.tables ) AS a
ORDER BY size DESC) AS sizes LIMIT 5;

-- array_agg: собрать в массив все фильмы, просмотренные пользователем (без повторов)
SELECT userID, array_agg(movieId) as user_views FROM (select distinct userID, movieID from ratings) a group by userID;

-- таблица user_movies_agg, в которую сохраните результат предыдущего запроса
DROP TABLE IF EXISTS user_movies_agg;
SELECT userID, user_views INTO public.user_movies_agg FROM (SELECT userID, array_agg(movieId) as user_views FROM (select distinct userID, movieID from ratings) a group by userID) as a;

SELECT * FROM user_movies_agg LIMIT 3;

---***** как работает функция UNNEST
--select userid, unnest(user_views) from (select userid, user_views from user_movies_agg) a;


-- Используя следующий синтаксис, создайте функцию cross_arr оторая принимает на вход два массива arr1 и arr2.
-- Функциия возвращает массив, который представляет собой пересечение контента из обоих списков.
-- Примечание - по именам к аргументам обращаться не получится, придётся делать через $1 и $2.

CREATE OR REPLACE FUNCTION cross_arr (bigint[], bigint[]) RETURNS bigint[] language sql as $FUNCTION$ select array_agg(a) from (select unnest($1) as a INTERSECT select unnest($2) as a) b ; $FUNCTION$;

-- Сформируйте запрос следующего вида: достать из таблицы всевозможные наборы u1, r1, u2, r2.
-- u1 и u2 - это id пользователей, r1 и r2 - соответствующие массивы рейтингов
-- ПОДСКАЗКА: используйте CROSS JOIN


SELECT agg1.userId as u1, agg2.userId as u2, agg1.user_views as ar1, agg2.user_views as ar2 
from user_movies_agg as agg1
CROSS JOIN user_movies_agg as agg2;

-- Оберните запрос в CTE и примените к парам <ar1, ar2> функцию CROSS_ARR, которую вы создали
-- вы получите триплеты u1, u2, crossed_arr
-- созхраните результат в таблицу common_user_views
DROP TABLE IF EXISTS common_user_views;
with cross_table as 
(
SELECT agg1.userId as u1, agg2.userId as u2, agg1.user_views as ar1, agg2.user_views as ar2 
from user_movies_agg as agg1
CROSS JOIN user_movies_agg as agg2
)
select cross_table.u1, cross_table.u2, cross_arr(ar1, ar2) as crossed_arr 
into public.common_user_views
from cross_table
where cross_table.u1 <> cross_table.u2
;

-- вывод топ 10 пользователей с наибольшими пересечениями
select * from (SELECT *, array_length(crossed_arr, 1) as ord FROM common_user_views) a
where a.ord is not null
order by a.ord desc                                 
LIMIT 10;


-- Создайте по аналогии с cross_arr функцию diff_arr, которая вычитает один массив из другого.
-- Подсказка: используйте оператор SQL EXCEPT.
CREATE OR REPLACE FUNCTION diff_arr (bigint[], bigint[]) RETURNS bigint[] language sql as $FUNCTION$ select array_agg(a) from (select unnest($1) as a EXCEPT select unnest($2) as a) b ; $FUNCTION$;

-- Сформируйте рекомендации - для каждой пары посоветуйте для u1 контент, который видел u2, но не видел u1 (в виде массива).
-- Подсказка: нужно заджойнить user_movies_agg и common_user_views и применить вашу функцию diff_arr к соответствующим полям.
-- с векторами фильмов
select u1, u2, diff_arr(user_views, crossed_arr) as recommend
FROM common_user_views 
CROSS JOIN user_movies_agg 
where u2 = userid 
and  array_length(crossed_arr, 1) >= 5
LIMIT 10;

