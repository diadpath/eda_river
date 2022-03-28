ALTER TABLE rht.silver2017 add column idsegment text;
UPDATE rht.silver2017 set idsegment='FR'||id_drain; --114472



SELECT rn_rna.idsegment, isfrontier, issource, issea, isendoreic, isinternational,country, altitudem, distanceseam, distancesourcem, medianflowm3ps,
surfacebvm2, strahler, shreeve, codesea, "name", basin, riverwidthm, riverwidthmsource, emu,"300_450", "450_600", "600_750", "750", total, geom 
from dbeel_rivers.rn_rna LEFT join rht.silver2017 on dbeel_rivers.rn_rna.idsegment=silver2017.idsegment where issea ;

alter table rht.dcdf2017 set schema eda_gerem;
CREATE SCHEMA eda_gerem;
CREATE TABLE eda_gerem.seaidsegment_silver AS SELECT rn_rna.idsegment, isfrontier, issource, issea, isendoreic, isinternational,country,
 altitudem, distanceseam, distancesourcem, medianflowm3ps,surfacebvm2, strahler, shreeve, codesea, name, basin, riverwidthm, riverwidthmsource, 
 emu,300_450, 450_600, 600_750, 750, total, geom from dbeel_rivers.rn_rna LEFT join rht.silver2017 on dbeel_rivers.rn_rna.idsegment=silver2017.idsegment 
 where issea ;

pg_dump -U postgres -f "eda_gerem.sql" --schema eda_gerem eda2.3

