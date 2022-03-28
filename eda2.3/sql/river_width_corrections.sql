select * from public.riverwidth_spain_portugal where pred_river_width::numeric <0
select * from public.riverwidth_spain_portugal where idsegment='SP1099' -- no line

SELECT * FROM public.riverwidth_spain_portugal where idsegment in (select idsegment  
from spain.rna where rna.riverwidthm  <0 )

SELECT * from spain.rn_rna where riverwidthm  <0

SELECT count(*), riverwidthmsource from spain.rna group by riverwidthmsource
select * from public.riverwidth_spain_portugal limit 1
SELECT * from spain.rna where riverwidthm <0 --83
SELECT * from portugal.rna where riverwidthm <0 -- nothing


select avg(riverwidthm) from portugal.rna --13

--spain

reindex table spain.rna; -- necessary for not like statements (bug)
VACUUM ANALYSE spain.rna;



BEGIN;
with notmerit AS(
select riverwidth_spain_portugal.* from spain.rna 
JOIN public.riverwidth_spain_portugal
on riverwidth_spain_portugal.idsegment=rna.idsegment
where rna.riverwidthmsource NOT LIKE '%MERIT%')
UPDATE spain.rna set riverwidthm=pred_river_width::numeric 
 from notmerit
 WHERE rna.idsegment=notmerit.idsegment
 COMMIT; --308975 rows affected, 27.8 secs execution time.

-- Portugal 

reindex table portugal.rna; -- necessary for not like statements (bug)
VACUUM ANALYSE portugal.rna;
 
BEGIN;
with notmerit AS(
select riverwidth_spain_portugal.* from portugal.rna 
JOIN public.riverwidth_spain_portugal
on riverwidth_spain_portugal.idsegment=rna.idsegment
where rna.riverwidthmsource NOT LIKE '%MERIT%')
UPDATE portugal.rna set riverwidthm=pred_river_width::numeric 
 from notmerit
 WHERE rna.idsegment=notmerit.idsegment
 COMMIT; --68738 rows affected, 5.7 secs execution time.



SELECT * FROM riverwidth_merit_not_updated limit 200

SELECT * FROM riverwidth_merit_not_updated where idsegment like '%PT%'

BEGIN;
with notmerit AS(
select riverwidth_merit_not_updated.* from spain.rna 
JOIN public.riverwidth_merit_not_updated
on riverwidth_merit_not_updated.idsegment=rna.idsegment
where rna.riverwidthmsource NOT LIKE '%MERIT%')
UPDATE spain.rna set riverwidthm=pred_river_width::numeric 
 from notmerit
 WHERE rna.idsegment=notmerit.idsegment
 COMMIT; --7908 rows affected, 27.8 secs execution time.



-- Portugal 

reindex table portugal.rna; -- necessary for not like statements (bug)
VACUUM ANALYSE portugal.rna;



with notmerit AS(
select riverwidth_merit_not_updated.* from portugal.rna 
JOIN public.riverwidth_merit_not_updated
on riverwidth_merit_not_updated.idsegment=rna.idsegment
where rna.riverwidthmsource NOT LIKE '%MERIT%')
UPDATE portugal.rna set riverwidthm=pred_river_width::numeric 
 from notmerit
 WHERE rna.idsegment=notmerit.idsegment; --2179
 COMMIT;
 


