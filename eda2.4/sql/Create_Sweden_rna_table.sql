

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

drop table if exists worksweden.rna;
CREATE TABLE worksweden.rna (fictitious boolean,
innetwork int4,
	CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment)
)
INHERITS (dbeel_rivers.rna);
CREATE INDEX indexcountry ON sweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON sweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON sweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON sweden.rn USING btree (source);
CREATE INDEX indextargetrn ON sweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON sweden.rn USING gist (geom);


