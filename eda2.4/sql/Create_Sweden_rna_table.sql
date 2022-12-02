


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


