
-- We have here inserted the restocking data into rawdata (Originally in varchar form)

-- set empty values to null
UPDATE rawdata.restockingeda SET antal=NULL where antal='';
update rawdata.restockingeda SET antal=NULL where antal=-9;
UPDATE rawdata.restockingeda SET belopp=NULL where belopp='';
UPDATE rawdata.restockingeda SET belopp=NULL where belopp=' ';
UPDATE rawdata.restockingeda SET belopp=10000 where belopp='10 000';
UPDATE rawdata.restockingeda SET belopp=NULL where belopp=-9;
ALTER TABLE rawdata.restockingeda ALTER COLUMN belopp TYPE float4 USING belopp::float4;
UPDATE rawdata.restockingeda SET vikt=NULL where vikt='';
UPDATE rawdata.restockingeda SET vikt=NULL where vikt=' ';
UPDATE rawdata.restockingeda SET vikt=NULL where vikt='-9.00';
ALTER TABLE rawdata.restockingeda ALTER COLUMN vikt TYPE float4 USING vikt::float4;
UPDATE rawdata.restockingeda SET koordxut=NULL where koordxut='';
UPDATE rawdata.restockingeda SET koordxut=NULL where koordxut=' ';
UPDATE rawdata.restockingeda SET koordxut='6196353' where koordxut='6196353.545';
ALTER TABLE rawdata.restockingeda ALTER COLUMN koordxut TYPE int8 USING koordxut::int8;
UPDATE rawdata.restockingeda SET koordyut=NULL where koordyut='';
UPDATE rawdata.restockingeda SET koordyut=NULL where koordyut=' ';
UPDATE rawdata.restockingeda SET koordyut='1355519' where koordyut='1355519.597';
ALTER TABLE rawdata.restockingeda ALTER COLUMN koordyut TYPE int8 USING koordyut::int8;
UPDATE rawdata.restockingeda SET koordx=NULL where koordx='';
UPDATE rawdata.restockingeda SET koordx=NULL where koordx=' ';
ALTER TABLE rawdata.restockingeda ALTER COLUMN koordx TYPE int8 USING koordx::int8;
UPDATE rawdata.restockingeda SET koordy=NULL where koordy='';
UPDATE rawdata.restockingeda SET koordy=NULL where koordy=' ';
ALTER TABLE rawdata.restockingeda ALTER COLUMN koordy TYPE int8 USING koordy::int8;

-- add geometry to table
ALTER TABLE rawdata.restockingeda ADD COLUMN geom geometry; 
update rawdata.restockingeda set geom = ST_POINT(koordyut, koordxut,3021);
update rawdata.restockingeda set geom = ST_POINT(koordy, koordx,3021) where geom is null;

