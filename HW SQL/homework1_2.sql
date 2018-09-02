CREATE TABLE films_2 (title VARCHAR(355), dirctor VARCHAR(355), Oskar VARCHAR(355));

INSERT INTO films_2 VALUES ('Энни Холл', 'Вудди Ален', '"+"'),
('Быть Джоном Малковичем', 'Спайк Джонс', '"+"'),
('Любовь и смерть', 'Вуди Аллен', '"-"');

CREATE TABLE rating (dirctor VARCHAR(355) PRIMARY KEY, Rating int);

INSERT INTO rating VALUES ('Вудди Ален', 8),
('Спайк Джонс', 7);

CREATE TABLE films_3 (title VARCHAR(355), country VARCHAR(355));

INSERT INTO films_3 VALUES ('Энни Холл', 'США'),
('Быть Джоном Малковичем', 'США'),
('Любовь и смерть', 'Россия');


CREATE TABLE oskar (country VARCHAR(355) PRIMARY KEY, Oskar VARCHAR(355));

INSERT INTO oskar VALUES ('США', '"+"'),
('Россия', '"+"');





