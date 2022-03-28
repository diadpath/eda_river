SET SEARCH_PATH TO dbeel_rivers, public;
SELECT * FROM transport LIMIT 10
ALTER TABLE transport ADD COLUMN id serial PRIMARY KEY;

-- true duplicates
WITH TRUE_duplicates AS (
SELECT t1.* FROM transport t1 
JOIN transport t2 ON (t1.idsegment,t1.sector)=(t2.idsegment,t2.sector)
WHERE t2.id != t1.id
AND t2.id < t1.id)
SELECT distinct sector FROM TRUE_duplicates
/*
Rios Lor
Rio Iso
Oria Ibaia
*/
WITH TRUE_duplicates AS (
SELECT t1.* FROM transport t1 
JOIN transport t2 ON (t1.idsegment,t1.sector)=(t2.idsegment,t2.sector)
WHERE t2.id != t1.id
AND t2.id < t1.id)
DELETE FROM transport WHERE id IN (SELECT id FROM TRUE_duplicates) --833

SELECT * FROM transport WHERE sector IN ('Rios Lor', 'Rio Iso', 'Oria Ibaia');


WITH OTHER_duplicates AS (
SELECT t1.* FROM transport t1 
JOIN transport t2 ON (t1.idsegment)=(t2.idsegment)
WHERE t2.id != t1.id
AND t2.id < t1.id)
SELECT * FROM other_duplicates
SELECT distinct sector FROM OTHER_duplicates

/*
Riu Palancia
Oria Ibaia
Rio Turia o Guadalaviar
Rio Agauntza
*/

WITH OTHER_duplicates AS (
SELECT t1.* FROM transport t1 
JOIN transport t2 ON (t1.idsegment)=(t2.idsegment)
WHERE t2.id != t1.id
AND t2.id <> t1.id)
DELETE FROM transport WHERE id IN (SELECT id FROM OTHER_duplicates) --833

WITH OTHER_duplicates AS (
SELECT t1.* FROM transport t1 
JOIN transport t2 ON (t1.idsegment)=(t2.idsegment)
WHERE t2.id != t1.id
AND t2.id < t1.id)
DELETE FROM transport WHERE  sector = 'Rio Turia o Guadalaviar'; -- 2035
DELETE FROM transport WHERE  sector = 'Rio Agauntza'; --17

WITH OTHER_duplicates AS (
SELECT t1.* FROM transport t1 
JOIN transport t2 ON (t1.idsegment)=(t2.idsegment)
WHERE t2.id != t1.id
AND t2.id < t1.id)
DELETE FROM transport WHERE id IN (SELECT id FROM OTHER_duplicates);--3

ALTER TABLE transport ADD CONSTRAINT c_uk_idsegment UNIQUE(idsegment);