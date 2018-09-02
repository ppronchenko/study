CREATE TABLE films (title VARCHAR(355), id int PRIMARY KEY, country VARCHAR (355) NOT NULL, box_office int, realese_year TIMESTAMP);

INSERT INTO films VALUES ('A Beautiful Mind', 1, 'USA', 313542341, '2001-12-13'::timestamp),
('Fight Club', 2, 'USA', 100853753, '1999-09-10'::timestamp), ('Back to the Future', 3, 'USA', 381109762, '1985-07-03'::timestamp), ('Matrix', 4, 'USA', 463517383, '1999-03-23'::timestamp), ('Forrest Gump', 5, 'USA', 667386686, '1994-06-23'::timestamp);

CREATE TABLE persons (id int PRIMARY KEY,  title VARCHAR(355));

INSERT INTO persons VALUES  (1, 'Ron Howard'), (2, 'David Fincher'), (3, 'Robert Zemeckis'), (4, 'Lana Wachowski'), (5, 'Lili Wachowski'), (6, 'Robert Zemeckis'),;

CREATE TABLE persons2content (person_id int, film_id VARCHAR(355),   person_type VARCHAR(355));

INSERT INTO persons2content  VALUES (1, 1, 'Director'), (2, 2, 'Director'), (3, 3, 'Director'), (4, 4, 'Director'), (5, 4, 'Director'), (6, 5, 'Director');
