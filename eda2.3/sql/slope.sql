/*-----------------------
* SCRIPT TO CALCULATE SLOPE IN SPAIN
* slope will be used for river characteristics models and also to predict the height of dams
*---------------------------*/

ALTER TABLE dbeel_rivers.rna add column slope numeric;



UPDATE  spain.rna set slope = sub.slope FROM (
SELECT rn.idsegment, (cota_max-cota_min)/lengthm as slope from 
spain.unit_basin join spain.rn on 
rn.idsegment=unit_basin.idsegment) sub
where sub.idsegment=rna.idsegment; --  325606 rows affected, 01:18

-- France
UPDATE france.rna set slope = pente/1000 FROM
france.rnasuppl where rnasuppl.idsegment= rna.idsegment; --114561 9.9 


select slope from france.rna limit 100


UPDATE  spain.rna set slope = 10 where slope >10; --10 rows



