-- Charente : Barrages de Lavaud et Mas chaban (1984 2007 2013)
-- distance sea 367
-- transport_charente.png
-- cs_height10_p 166 m

CREATE TABLE dbeel_rivers.transport AS(

SELECT _idsegment AS idsegment, sector, "year" FROM  dbeel_rivers.upstream_segments_rn('FR100728') 
CROSS JOIN (SELECT 'Charente' AS sector,1984 AS "year") sub 

UNION

-- Vienne : barrage de Vassivière (2006)
--transport_vassiviere.png
her
SELECT _idsegment AS idsegment, sector, "year" FROM  dbeel_rivers.upstream_segments_rn('FR230915') 
CROSS JOIN (SELECT 'Vassivière' AS sector, 2006 AS "year") sub1


UNION

SELECT 'FR231328' AS idsegment, 'Vienne' AS sector, 2006 AS "year"


UNION

-- le lot 66 m (cs_height) 123 m cs_height_p 315 km mer
--1995 => 2014
-- transport_lot.png

SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR110889') 
CROSS JOIN (SELECT 'Lot' AS sector, 1995 AS "year") sub3


-- La lède 1988 (affluent du lot) 
UNION 


SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR110130')
CROSS JOIN (SELECT 'Lède' AS sector,  1988 AS "year") sub4

UNION 
-- Le dropt  1988 (affluent du lot) 

SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR109171')
CROSS JOIN (SELECT 'Dropt' AS sector,  1988 AS "year") sub5

-- L'aude près PSICICULTURE FEDERALES CHERCHEZ PAS PLUS LOIN ... 
-- transport_aude.png
UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR24294')
CROSS JOIN (SELECT 'Aude' AS sector,  1994 AS "year") sub6


-- Aveyron (2 stations)
UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR112201')
CROSS JOIN (SELECT 'Aveyron' AS sector,  2004 AS "year") sub7

-- yonne (43 m -- 151 m pred 634 km mer)
--1998
-- transport_yonne.png


UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR317084')
CROSS JOIN (SELECT 'Yonne' AS sector,  1998 AS "year") sub8

--Marne

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR313384')
CROSS JOIN (SELECT 'Marne' AS sector,  1990 AS "year") sub9

--Seine Amont

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR316121')
CROSS JOIN (SELECT 'Seine' AS sector,  1990 AS "year") sub10




--Meuse

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR500284')
CROSS JOIN (SELECT 'Meuse' AS sector,  1985 AS "year") sub11


-- Rhone

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('FR9301')
CROSS JOIN (SELECT 'Rhone' AS sector,  1995 AS "year") sub12

-- Vale 

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP61960')
CROSS JOIN (SELECT 'Rio Guadalest' AS sector,  1992 AS "year") sub13



UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP63917')
CROSS JOIN (SELECT 'Rio Amadorio' AS sector,  2007 AS "year") sub14


UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP58528')
CROSS JOIN (SELECT 'Rio Serpis' AS sector,  2007 AS "year") sub15


UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP43630')
CROSS JOIN (SELECT 'Rio Jucar' AS sector,  2001 AS "year") sub16

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP50192')
CROSS JOIN (SELECT 'Rio Cazunta' AS sector,  2015 AS "year") sub17

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP44871')
CROSS JOIN (SELECT 'Rio Turia o Guadalaviar' AS sector,  1995 AS "year") sub18

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP44871')
CROSS JOIN (SELECT 'Rio Turia o Guadalaviar' AS sector,  1995 AS "year") sub19


UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP44871')
CROSS JOIN (SELECT 'Riu Palancia' AS sector,  2015 AS "year") sub20


UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP33591')
CROSS JOIN (SELECT 'Riu Mijares' AS sector,  2008 AS "year") sub21

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP30468')
CROSS JOIN (SELECT 'Riu Lucena' AS sector,  2009 AS "year") sub22

-- there are NOT reported

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP286559')
CROSS JOIN (SELECT 'Riu Segre' AS sector,  2002 AS "year") sub23

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP120302')
CROSS JOIN (SELECT 'Riu Muga' AS sector,  2002 AS "year") sub24

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP264971')
CROSS JOIN (SELECT 'Rio Aragon' AS sector,  2002 AS "year") sub25

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP238906')
CROSS JOIN (SELECT 'Rio Ubagua' AS sector,  2009 AS "year") sub26

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP241801')
CROSS JOIN (SELECT 'Rio Ega' AS sector,  2003 AS "year") sub27

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP240328')
CROSS JOIN (SELECT 'Rio Ebro' AS sector,  2008 AS "year") sub28

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP232597')
CROSS JOIN (SELECT 'Araxes Ibaia' AS sector,  2018 AS "year") sub29

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP231807')
CROSS JOIN (SELECT 'Leitzaran Ibaia' AS sector,  2018 AS "year") sub30



-- 2015 and 2018
UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP231292')
CROSS JOIN (SELECT 'Oria Ibaia' AS sector,  2015 AS "year") sub33

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP233795')
CROSS JOIN (SELECT 'Rio Agauntza' AS sector,  2007 AS "year") sub34

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP233817')
CROSS JOIN (SELECT 'Txiki Erreka' AS sector, 2018  AS "year") sub35


UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP230385')
CROSS JOIN (SELECT 'Urola Ibaia' AS sector,  2018 AS "year") sub36

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP232288')
CROSS JOIN (SELECT 'Antzinako Erreka' AS sector,  2018 AS "year") sub37

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP233592')
CROSS JOIN (SELECT 'Olaran Erreka' AS sector,  2018 AS "year") sub38

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP255753')
CROSS JOIN (SELECT 'Rio Navia' AS sector,  1990 AS "year") sub39

UNION
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP163646')
CROSS JOIN (SELECT 'Rio Minno' AS sector,  1999 AS "year") sub40

UNION



-- A single point but possible error so far upstream on the Tejo
UNION
SELECT 'SP206198' AS idsegment, 'RIO DE RAMACASTAÑAS O PRADO LATORRE' AS sector, 2009 AS "year"
) --51143 2h22






DELETE FROM dbeel_rivers.transport WHERE sector='Rio Tera'; --2020


INSERT INTO dbeel_rivers.transport
SELECT _idsegment AS idsegment, sector, "year"  FROM  dbeel_rivers.upstream_segments_rn('SP294614')
CROSS JOIN (SELECT 'Rio Tera' AS sector,  2011 AS "year") sub

-- no double ok:
DELETE FROM dbeel_rivers.transport WHERE idsegment IN (
SELECT idsegment
FROM
  (SELECT idsegment,
          rank() OVER (PARTITION BY idsegment) AS pos
     FROM dbeel_rivers.transport
  ) AS ss
WHERE pos >1;




ALTER TABLE  dbeel_rivers.transport  DROP COLUMN geom;
SELECT AddGeometryColumn ('dbeel_rivers','transport','geom',3035,'MULTILINESTRING',2, false);
UPDATE dbeel_rivers.transport set geom=rn.geom FROM
				dbeel_rivers.rn  WHERE rn.idsegment=transport.idsegment;--50662
            
INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Tamega' AS sector,  1999 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP296436'));


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio da riberina de San Lourenzo' AS sector,  1999 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP290384')); --472



INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rios Lor' AS sector,  1989 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP167721')); --472


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio mao' AS sector,  1989 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP169708')); --31


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio arnoia' AS sector,  1995 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP170986')); --445


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Avia' AS sector,  2006 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP168413'));--393


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Cabe' AS sector,  1999 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP166299'));--327

INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Amsa' AS sector,  2003 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP1208'));--27


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Iso' AS sector,  2003 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP186399'));--27

INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Ulla' AS sector,  2000 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP183112'));--303


INSERT INTO dbeel_rivers.transport(idsegment,sector,"year",geom)
SELECT idsegment, sector, "year", geom  
FROM  
spain.rn 
CROSS JOIN (SELECT 'Rio Sil' AS sector,  1997 AS "year") sub
WHERE idsegment IN (SELECT
dbeel_rivers.upstream_segments_rn('SP167099'));--1978