-- создаем структуры и заполняем

CREATE TABLE Department
  (
  id integer PRIMARY KEY,
  name varchar(255)
  );
  
CREATE TABLE Employee
 (
   id integer PRIMARY KEY,
   department_id integer REFERENCES Department, 
   chief_doc_id integer, 
   name varchar(255), 
   num_public integer  
 );



insert into Department 
values ('1', 'Therapy'), 
('2', 'Neurology'), 
('3', 'Cerdiology'),
('4', 'Gastroenterology'),
('5', 'Hematology'),
('6', 'Oncology');


insert into Employee values
('1', '1', '1', 'Kate', 4),
('2', '1', '1', 'Lidia', 2),
('3', '1', '1', 'Alexey', 1),
('4', '1', '2', 'Pier', 7),
('5', '1', '2', 'Aurel', 6),
('6', '1', '2', 'Klaudia', 1),
('7', '2', '3', 'Klaus', 12),
('8', '2', '3', 'Maria', 11),
('9', '2', '4', 'Kate', 10),
('10', '3', '5', 'Peter', 8),
('11', '3', '5', 'Sergey', 9),
('12', '3', '6', 'Olga', 12),
('13', '3', '6', 'Maria', 14),
('14', '4', '7', 'Irina', 2),
('15', '4', '7', 'Grit', 10),
('16', '4', '7', 'Vanessa', 16),
('17', '5', '8', 'Sascha', 21),
('18', '5', '8', 'Ben', 22),
('19', '6', '9', 'Jessy', 19),
('20', '6', '9', 'Ann', 18);

-- В том же редакторе http://sqlfiddle.com/ создать следующие SQL-запросы:
-- •Вывести список названий департаментов и количество главных врачей в каждом из этих департаментов

select Department.name, count(distinct chief_doc_id) from Employee
inner join Department on Employee.department_id = Department.id
group by Department.name
;

-- •Вывести список департамент id в которых работают 3 и более сотрудника
select department_id, count(id) from Employee
group by department_id
having count(id) >= 3
;

-- •Вывести список департамент id с максимальным количеством публикаций
select department_id, a.sum_num_public from 
(
select department_id, sum(num_public) as sum_num_public from Employee
group by department_id
) a
order by a.sum_num_public desc
;

-- •Вывести список имен сотрудников и департаментов с минимальным количеством в своем департаментe
with min_public as 
(
select department_id, name, sum(num_public) as sum_num_public from Employee
group by department_id, name
)
select b.name, a.name, a.sum_num_public  from min_public a
inner join Department b on a.department_id = b.id
order by a.sum_num_public asc
;

-- •Вывести список названий департаментов и среднее количество публикаций для тех департаментов, в которых работает более одного главного врача
with count_chief as
(
select department_id, count(distinct chief_doc_id) from Employee
group by department_id
having count(distinct chief_doc_id) > 1
),
avg_public as
(
select b.name, avg(a.num_public) as avg_num_public, a.department_id from Employee a
inner join Department b on a.department_id = b.id
group by b.name, a.department_id
)
select avg_public.name, avg_public.avg_num_public from avg_public
inner join count_chief on avg_public.department_id  = count_chief.department_id 
;








