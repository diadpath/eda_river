

-- Load excel-file with hydropower information
drop table if exists rawdata.hydropower;
create table rawdata.hydropower(
Namn VARCHAR,	
Ägare VARCHAR,	
Normalprod DOUBLE PRECISION,	
Effekt DOUBLE PRECISION,	
Byggt VARCHAR,
Nedlagt INT,
Aggregat INT,
Turbinlev VARCHAR,
Genlev VARCHAR,
Turbintyp VARCHAR,
Station VARCHAR,
Ombyggt VARCHAR,
Fallh DOUBLE PRECISION,
Regler VARCHAR,
Vattenf DOUBLE PRECISION,
Medelv DOUBLE PRECISION,
Magasin DOUBLE PRECISION,
Vattendrag VARCHAR,
Ort VARCHAR,
Kommun VARCHAR,
Län VARCHAR,
"Lat" NUMERIC,
"Long" NUMERIC
);

copy rawdata.hydropower from 'C:\hydrografi_i_natverk\Vattenkraft\vattenkraft 2021-02-10.csv' (FORMAT 'csv', HEADER, delimiter ";", ENCODING 'WIN1252');

-- Add geometry to table (these points are locations of hydropower buildings)
ALTER TABLE rawdata.hydropower 
  ADD geom geography(POINT,4326);

update rawdata.hydropower 
set 
geom = ST_SetSRID(ST_MakePoint("Long","Lat"),4326);



-- sweden.rn definition

-- Drop table

-- DROP TABLE sweden.rn;

/*
 Creation of the sweden.rn table 
 */

drop table if exists sweden.rna;
CREATE TABLE sweden.rna (fictitious boolean,
innetwork int4,
	CONSTRAINT c_pk_rnaidsegment PRIMARY KEY (idsegment)
)
INHERITS (dbeel_rivers.rna);
CREATE INDEX indexidsegmentrna ON sweden.rna USING btree (idsegment);
ALTER TABLE sweden.rna ADD CONSTRAINT c_fk_idsegment FOREIGN KEY (idsegment)
REFERENCES sweden.rn(idsegment) ON UPDATE CASCADE ON DELETE CASCADE;
/* TODO CREATE INDEXES ON TABLE rna
CREATE INDEX indexcountry ON sweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON sweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON sweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON sweden.rn USING btree (source);
CREATE INDEX indextargetrn ON sweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON sweden.rn USING gist (geom);
*/
-- Insert values of idsegments from table rn to table rna


INSERT INTO sweden.rna(idsegment) SELECT idsegment FROM sweden.rn;
-- Updated Rows 1458830


SELECT count(*) FROM  sweden.rn; 
UPDATE sweden.rn SET seaidsegment = NULL;
UPDATE sweden.rn SET seaidsegment = idsegment WHERE issea ; --4957
UPDATE sweden.rn SET path= text2ltree(idsegment) WHERE issea ; --4957
SELECT path FROM  sweden.rn WHERE path  IS NOT NULL;
SELECT path FROM  sweden.rn WHERE issea



-- update from the table created in R for path and distancesea
CREATE INDEX ON sweden.temp_rna_distance USING btree(idsegment);
UPDATE sweden.rn set path=temp_rna_distance.path::ltree FROM
sweden.temp_rna_distance WHERE temp_rna_distance.idsegment=rn.idsegment; --Updated Rows 1353009

UPDATE sweden.rna set distanceseam=temp_rna_distance.distanceseam::numeric FROM 
sweden.temp_rna_distance WHERE temp_rna_distance.idsegment=rna.idsegment; --Updated Rows  1353009




CREATE OR REPLACE VIEW sweden.rn_rna
AS SELECT rn.idsegment,
    rn.source,
    rn.target,
    rn.lengthm,
    rn.nextdownidsegment,
    rn.path,
    rn.isfrontier,
    rn.issource,
    rn.seaidsegment,
    rn.issea,
    rn.geom,
    rn.isendoreic,
    rn.isinternational,
    rn.country,
    rna.altitudem,
    rna.distanceseam,
    rna.distancesourcem,
    rna.cumnbdam,
    rna.medianflowm3ps,
    rna.surfaceunitbvm2,
    rna.surfacebvm2,
    rna.strahler,
    rna.shreeve,
    rna.codesea,
    rna.name,
    rna.pfafriver,
    rna.pfafsegment,
    rna.basin,
    rna.riverwidthm,
    rna.riverwidthmsource,
    rna.temperature,
    rna.temperaturejan,
    rna.temperaturejul,
    rna.wettedsurfacem2,
    rna.wettedsurfaceotherm2,
    rna.lengthriverm,
    rna.emu,
    rna.cumheightdam,
    rna.slope,
    rna.dis_m3_pyr_riveratlas,
    rna.dis_m3_pmn_riveratlas,
    rna.dis_m3_pmx_riveratlas,
    rna.drought,
    rna.drought_type_calc
   FROM sweden.rn
     JOIN sweden.rna ON rna.idsegment = rn.idsegment;




