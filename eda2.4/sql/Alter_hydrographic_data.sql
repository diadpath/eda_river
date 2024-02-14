-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- This script is used to alter raw hydrographic data to be used in EDA modeling --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- @ torbjorn.saterberg@slu.se 240126


/*****************************************************
 *  COPY data from raw inspire data to a schema with *
 *  				altered data.					 *
 *****************************************************/
CREATE TABLE alt_insp.hydronode 
AS TABLE insp.hydronode;
CREATE TABLE alt_insp.watercourselink 
AS TABLE insp.watercourselink;
CREATE TABLE alt_insp.watercourselinksequence 
AS TABLE insp.watercourselinksequence;
CREATE TABLE alt_insp.watercourse 
AS TABLE insp.watercourse;
CREATE TABLE alt_insp.standingwater 
AS TABLE insp.standingwater;


/*******************************************************
 *  			Change ids in altered data             *
 *******************************************************/

-----------------------------------------------------------------------------------------
-- add gml_id for each watercourselinksequence(ids to include in watercourselink table) -
-----------------------------------------------------------------------------------------
UPDATE 
alt_insp.watercourselinksequence w
SET 
gml_id=w2.namespace||'.'||w2.localid
FROM 
alt_insp.watercourselinksequence w2
WHERE
w.ogc_fid=w2.ogc_fid; 

----------------------------------------
-- add gml_id for each watercourselink -
----------------------------------------
UPDATE 
alt_insp.watercourselink w
SET 
gml_id=w2.namespace||'.'||w2.localid
FROM 
alt_insp.watercourselink w2
WHERE
w.ogc_fid=w2.ogc_fid; 

---------------------------------
-- add gml_id to each hydronode -
---------------------------------
UPDATE 
alt_insp.hydronode h
SET 
gml_id=h.namespace||'.'||h.localid
FROM 
alt_insp.hydronode h2
WHERE
h.ogc_fid=h2.ogc_fid; 

--------------------------------------------------
-- Add maincatchmentarea info to watercourselink -
--------------------------------------------------
ALTER TABLE alt_insp.watercourselink 
ADD COLUMN
maincatchment int4;

-------------------------------------------------------
-- Insert maincatchment area in watercourse link data -
-------------------------------------------------------

--append data from Svensk vattenstandard network
UPDATE 
alt_insp.watercourselink w
SET 
maincatchment = r.maincatchmentareanumber 
FROM 
"SVS".ws_riverreach r
WHERE 
r.localid = w.localid;

-- Segments with null in maincatchmentarea 
CREATE TABLE alt_insp.non_catchmentarea AS
SELECT A.*, ca.haro
FROM
(SELECT * FROM 
alt_insp.watercourselink w 
WHERE maincatchment IS NULL) A
JOIN
rawdata.catchment_area ca 
ON ST_Intersects(A.wkb_geometry,ca.geom);

-- add data from spatial catchment area layer(these have the wrong numbers(fixing it using SQL-code; non_cathcmentarea_join_key_haro contains keys for updating data)
WITH key_haro AS
(SELECT ca.haro, MODE() WITHIN GROUP (ORDER BY w.maincatchment) haro_key
FROM 
rawdata.catchment_area ca 
LEFT JOIN
alt_insp.watercourselink w 
ON ST_Intersects(w.wkb_geometry,ca.geom)
GROUP BY ca.haro),
non_cathcmentarea_join_key_haro AS(
SELECT nc.*, k.haro_key
FROM alt_insp.non_catchmentarea nc 
LEFT JOIN
key_haro k
ON nc.haro=k.haro)
UPDATE alt_insp.watercourselink A 
SET maincatchment=ncjkh.haro_key
FROM non_cathcmentarea_join_key_haro ncjkh
where A.gml_id=ncjkh.gml_id;

-- Manually update a few cathmentareas with nulls
/* UPDATE alt_insp.watercourselink 
SET maincatchment=1025
where gml_id='SE.LM.HY.ba3bfd5c-d3f9-498e-aef5-d3df74e25c74';

UPDATE alt_insp.watercourselink 
SET maincatchment=1025
where gml_id='SE.LM.HY.0e97df16-bbe4-4568-bd5a-9ddf8a49d6d7';

UPDATE alt_insp.watercourselink 
SET maincatchment=25042
where gml_id='SE.LM.HY.edccbef5-c5db-47d8-96c3-45c40a15b800';

UPDATE alt_insp.watercourselink 
SET maincatchment=25042
where gml_id='SE.LM.HY.9d1ba9ba-e1ee-43b7-a609-4940c27a33bb';

UPDATE alt_insp.watercourselink 
SET maincatchment=25042
where gml_id='SE.LM.HY.64eac6ec-904b-4907-9fcf-1a0a1f3313ef';

UPDATE alt_insp.watercourselink 
SET maincatchment=25042
where gml_id='SE.LM.HY.4355325a-41d4-46dc-8dbc-f7d6fb240cf8';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.0c0551c1-1c45-4ba9-9542-f683d38e09a8';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.2702e9ee-413f-4b2d-893b-01b98ecc2fe6';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.59fc83a5-9247-4b01-b6de-0bc480c24998';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.8fb51a1c-b4a9-489e-8729-c9d6e6026ff9';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.3a7742d8-a03b-4868-b900-e44e05bb0521';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.5ce51fa6-2b1a-41f0-b815-9a8aeacd6a43';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.0a55a321-b301-47df-9b65-7f8de614945b';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.53ceb867-ab1c-4c22-9451-f63ab2d182a9';

UPDATE alt_insp.watercourselink 
SET maincatchment=42059
where gml_id='SE.LM.HY.998e77a5-b27b-4dce-b55f-bfac953badbe';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.4fae2809-d248-4c4f-a9f7-7fd783a31726';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.2186f9f1-5bc6-4ad6-b73e-83b9a109c30a';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.95c994c6-13d9-4885-b7c9-d002ef5e9dd9';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.3fe78e88-f967-4e2b-8c20-92c6b11f0986';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.940ace98-df2d-4213-ab74-93cef17951b7';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.c70a837c-7545-4ff3-9017-d7ed1f672bee';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.8504859e-cfe9-4948-8aff-12196105b474';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.3fe78e88-f967-4e2b-8c20-92c6b11f0986';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.18a19939-98bb-4c1e-8d3b-9d35e5ad59f6';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.12f683df-362e-4cef-8e85-65a27fc3684c';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.1bf32bff-2c9a-417b-9215-0cda3ca9af6c';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.cc2c9e08-9481-413d-aa80-aa56c8780836';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.639905d1-ebb5-41b1-8a2c-7e9f9a059d36';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.99667037-d450-44c6-8261-08334d2dde8d';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.2e7f93bc-1c05-4c06-8d8f-ca3bbe01f460';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.a849c835-4d99-4d3f-8bed-41c452af32b8';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.26f348ae-07c6-4815-9853-8adc6811d642';

UPDATE alt_insp.watercourselink 
SET maincatchment=59063
where gml_id='SE.LM.HY.debc0aea-cc9d-49f4-94b6-5cc4a63fc169';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.d33a4ac5-bfdc-4198-b834-f07540b79801';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.42146917-3877-4920-9f17-8da0371e5093';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.adc87dc7-dab4-4119-8aaf-b3671e19352f';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.04488a87-4a40-421a-ba32-f3cb6c615511';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.c99f9d21-daf7-474f-9219-8bed2770d42c';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.abd51958-3dd5-45d4-9590-856beb4414fb';

UPDATE alt_insp.watercourselink 
SET maincatchment=63071
where gml_id='SE.LM.HY.f67350ae-037c-4ffd-b10c-5250c5e7bc03';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.233cc614-5f86-48a5-8d44-963e8d35fa94';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.ebc96b72-4a01-4019-b98d-9f48760ef3cd';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.d013b4f4-98e8-422c-b60b-52ffa21249ab';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.cf06d88a-2816-4e06-837a-3f95d766ff9a';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.6dd56212-688f-4d0b-866d-246e5edd08d1';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.242d5f02-3c71-4f85-94fa-e1184766a8df';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.d56f60bd-502b-4cb7-9138-9c61585046c9';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.a52354c9-2861-4a08-9f0b-b78a8e0de59d';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.6e48735f-4919-4282-ae39-1f3f810b594d';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.cc3274b3-fcec-46c1-a37a-f7056c5da95b';

UPDATE alt_insp.watercourselink 
SET maincatchment=71080
where gml_id='SE.LM.HY.12d336eb-df3e-4773-81a2-fdfde8c3b729';

UPDATE alt_insp.watercourselink 
SET maincatchment=80094
where gml_id='SE.LM.HY.5357c673-99f1-49b5-997c-6a682bdeb197';

UPDATE alt_insp.watercourselink 
SET maincatchment=80094
where gml_id='SE.LM.HY.e1528afc-c747-4b85-bb73-e6b3a3c5a962';

UPDATE alt_insp.watercourselink 
SET maincatchment=80094
where gml_id='SE.LM.HY.10e3aa1d-b1be-40b7-83fa-25cf97b34938';

UPDATE alt_insp.watercourselink 
SET maincatchment=80094
where gml_id='SE.LM.HY.a5787324-dfdf-4604-a642-79758dc55748';

UPDATE alt_insp.watercourselink 
SET maincatchment=80094
where gml_id='SE.LM.HY.3c0884f6-6df5-49c3-8842-abf68eb2f498';

UPDATE alt_insp.watercourselink 
SET maincatchment=80094
where gml_id='SE.LM.HY.fffc5e7b-917f-4f19-b4ff-b51e8c0aeee4';

UPDATE alt_insp.watercourselink 
SET maincatchment=94108
where gml_id='SE.LM.HY.fd69bde5-63cd-40ea-92fe-3e1b311f5e71';

UPDATE alt_insp.watercourselink 
SET maincatchment=94108
where gml_id='SE.LM.HY.0f93a9e7-4922-4bf5-9445-d1218aac490e';

UPDATE alt_insp.watercourselink 
SET maincatchment=94108
where gml_id='SE.LM.HY.9ae54da1-106e-4aea-9c5e-3716dc284051';

UPDATE alt_insp.watercourselink 
SET maincatchment=108112
where gml_id='SE.LM.HY.d55dddd5-7de8-4d7e-b49f-b23f9b065b3c';

UPDATE alt_insp.watercourselink 
SET maincatchment=108112
where gml_id='SE.LM.HY.e6ea8f72-3e3e-4671-8feb-6e86215b620d';

UPDATE alt_insp.watercourselink 
SET maincatchment=301000
where gml_id='SE.LM.HY.5afae64b-d62b-4ac3-9065-c606d396d491';

UPDATE alt_insp.watercourselink 
SET maincatchment=301000
where gml_id='SE.LM.HY.1d0929da-ccaa-4dd4-b64e-0ab0cac56e35';
*/


/******************************************************
-- 				Add end- and startnodes 			  *
*******************************************************/
--endnodes
WITH A AS
(SELECT ogc_fid, 
CASE 
WHEN 
starts_with(endnode_href,'#SE') THEN LTRIM(endnode_href,'#')
ELSE 
namespace || LTRIM(endnode_href,'#') 
END endnode
FROM
alt_insp.watercourselink w)
UPDATE 
alt_insp.watercourselink w2
SET 
endnode = A.endnode
FROM 
A
WHERE 
A.ogc_fid=w2.ogc_fid;

--startnodes
WITH A AS
(SELECT ogc_fid, 
CASE 
WHEN 
starts_with(startnode_href,'#SE') THEN LTRIM(startnode_href,'#')
ELSE 
namespace || LTRIM(startnode_href,'#') 
END startnode
FROM
alt_insp.watercourselink w)
UPDATE 
alt_insp.watercourselink w2
SET 
startnode = A.startnode
FROM 
A
WHERE 
A.ogc_fid=w2.ogc_fid;

-- check stupid links with non-existing nodes
CREATE TABLE alt_insp.unlinked_nodes_in_wcl AS
SELECT *
FROM 
alt_insp.watercourselink
WHERE localid IN
((SELECT localid
FROM
alt_insp.watercourselink w 
ORDER BY LENGTH(startnode_href)
limit 5)
UNION
(SELECT localid
FROM
alt_insp.watercourselink w 
ORDER BY LENGTH(endnode_href)
limit 4))

-- links to remove
/* 
DELETE FROM alt_insp.watercourselink
WHERE ogc_fid=417587;

DELETE FROM alt_insp.watercourselink
WHERE
localid IN ('2588b758-88ba-414a-923a-599b2e3fa4f7',
'03062489-6a25-4173-91b9-a604037dfcd9',
'd3470271-cf00-4f26-b9e6-5d5595143807',
'1624c66e-c2d7-4aab-add1-362c5ee66c73',
'164ec776-9b47-4ea9-a7de-fede99272f3d',
'9fe4bb49-3f1f-48d4-bd30-7480d39785a5',
'f57b94ab-2d14-4595-bce3-d7c1a74943c9')

DELETE FROM alt_insp.watercourselink 
WHERE gml_id='SE.LM.HY.340fed6d-d91f-4872-9bb4-3f8619b26bd3'

-- hydronodes to remove
DELETE FROM alt_insp.hydronode 
WHERE ogc_fid IN (391721,515549)

*/

/*
 * remove duplicate nodes
 * 
 
CREATE TABLE alt_insp.test_dupl_node AS
SELECT *
FROM alt_insp.hydronode
WHERE gml_id IN
(SELECT gml_id 
FROM alt_insp.hydronode
GROUP BY gml_id 
HAVING count(*)>1)

  
WITH A AS
(SELECT ogc_fid, ROW_NUMBER() OVER (PARTITION BY gml_id ORDER BY ogc_fid) rn
 FROM alt_insp.test_dupl_node tdn)
DELETE FROM alt_insp.hydronode h 
WHERE ogc_fid IN (SELECT ogc_fid FROM A WHERE rn>1)


-- Check for duplicate ids in watercourselinksequence (792 rows where gml_id is no unique) 
-- We leave these as is and do not refence this table.
  
SELECT gml_id, COUNT(*)
FROM
alt_insp.watercourselink
GROUP BY gml_id having count(*) >1

CREATE TABLE alt_insp.dupl_wcls AS
SELECT *
FROM 
alt_insp.watercourselinksequence w 
WHERE gml_id IN
(SELECT gml_id
FROM
alt_insp.watercourselinksequence
GROUP BY gml_id having count(*) > 1)
*/


--------------------------------------------------------------------
-- Add a reference to watercourselinksequence in watercourse link  -
--------------------------------------------------------------------
-- note that this reference is not associated through a foreign key as wcls are not unique
WITH A AS
(SELECT ogc_fid, array_agg(link_upd) upd_wcl_ids
FROM
(SELECT
ogc_fid,
ltrim(unnest(link_href),'#') link_upd --remove hashtag from ids
FROM
alt_insp.watercourselinksequence) subquery
group by
ogc_fid)
UPDATE 
alt_insp.watercourselinksequence w
SET 
link_href = A.upd_wcl_ids
FROM 
A
WHERE 
A.ogc_fid = w.ogc_fid;

-- add a column referencing wcls in tabke wcl
ALTER TABLE alt_insp.watercourselink 
ADD COLUMN
fk_gml_id_wcls varchar;

-- CREATE temporary table with link from watercourselink and watercourselinksequence
CREATE TEMPORARY TABLE wcls_key AS
SELECT
gml_id, unnest(link_href) link_upd 
FROM
alt_insp.watercourselinksequence;

-- Insert watercourselinksequence reference in watercourse link data
UPDATE 
alt_insp.watercourselink w
SET 
fk_gml_id_wcls = wcl.gml_id
FROM 
wcls_key wcl
WHERE 
wcl.link_upd = w.gml_id;

-- some links do not have associated watercourselinkids(h_ref are null in watercourselink)
WITH idstoupdate AS( 
SELECT i.ogc_fid, w2.gml_id -- ids in watercourselink and corresponding sequence id
FROM 
(SELECT w.ogc_fid, wkb_geometry -- where watercourselink reference to sequences are null
FROM alt_insp.watercourselink w 
WHERE fk_gml_id_wcls IS NULL) i
JOIN alt_insp.watercourselinksequence w2 ON ST_Within(i.wkb_geometry,w2.wkb_geometry)) -- 
UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = idstoupdate.gml_id 
FROM 
idstoupdate
WHERE 
w3.ogc_fid = idstoupdate.ogc_fid;


-- Manually alter a few references to watercourselinksequence
/*

CREATE TABLE alt_insp.null_wcls_key AS
SELECT * -- where watercourselink reference to sequences are null
FROM alt_insp.watercourselink w 
WHERE fk_gml_id_wcls IS NULL

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.94b44914-b6f4-4410-9b5e-c27abfd1c452'
WHERE 
w3.gml_id = 'SE.LM.HY.8a89e0be-417a-411a-a702-3847d57c0b3e';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.426a64b9-a1cc-406f-b3c0-64d7e2d877e1'
WHERE 
w3.gml_id = 'SE.LM.HY.bcd51a9c-3db3-4bfc-9a52-11099cb2b067';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.828064bc-cc1d-485f-a6e7-6046f807339a'
WHERE 
w3.gml_id = 'SE.LM.HY.3178d665-17d2-4c66-922b-0d1b9c907477';

-- As there is no obvious gml_id in wcls that can be used here we use the same ids for both 
UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.7daecbab-a807-4e0d-a1d2-dd195acdd14b'
WHERE 
w3.gml_id = 'SE.LM.HY.7daecbab-a807-4e0d-a1d2-dd195acdd14b';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.6c275853-baf3-42b6-acd4-42cbef359b10'
WHERE 
w3.gml_id = 'SE.LM.HY.NVE.f3847219-2872-4407-98a5-14e34d4f5f4b';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.7159cb65-b364-4179-bd87-5840cfaa23c3'
WHERE 
w3.gml_id = 'SE.LM.HY.NVE.71a8cd62-48bd-4c2a-bf67-638816a5f0c3';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.199be5a1-26bb-46b6-be33-1dddf8d2b892'
WHERE 
w3.gml_id = 'SE.LM.HY.NVE.865bd47e-c19c-4b96-ab9a-c8ab5099ddc3';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.7ef35c07-03f5-415a-8fc5-f8c225a3032e'
WHERE 
w3.gml_id = 'SE.LM.HY.5b46fb7a-8432-4edf-bc50-45f7d70968e7';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.cd90235d-0a78-4902-90d5-2e29d4faa63a'
WHERE 
w3.gml_id = 'SE.LM.HY.01a3d722-affa-40f0-8db2-83362c52d5b2';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.ab322e8b-a073-4ed5-b5dd-b376b6f94497'
WHERE 
w3.gml_id = 'SE.LM.HY.NVE.57d72581-634d-4cac-b301-b85b6727957f';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.77fd24e4-960d-4473-a2d4-a3a5090d6a68'
WHERE 
w3.gml_id = 'SE.LM.HY.11f16b50-cf80-4cc2-a143-74642d5c44e1';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.72fee41c-6a6d-4fb2-a1e2-330767340bb9'
WHERE 
w3.gml_id = 'SE.LM.HY.05b1d478-ebdd-4aa8-899a-c1d7b1937018';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.1baff9cb-4829-4007-9d88-03aff881c0f9'
WHERE 
w3.gml_id = 'SE.LM.HY.d74dbc12-b7bf-4d33-8113-1d3a1a1e71a5';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.ba1766a9-ba11-444b-a860-aa08049166bd'
WHERE 
w3.gml_id = 'SE.LM.HY.4fe22130-042a-4214-a71c-5a62db63beaf';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.ba1766a9-ba11-444b-a860-aa08049166bd'
WHERE 
w3.gml_id = 'SE.LM.HY.6f52d256-c5d2-4ada-b355-c4eda05fcc87';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.8e62885e-cda1-4dbd-b7b2-4295de4db768'
WHERE 
w3.gml_id = 'SE.LM.HY.3bc28ad3-6eda-493d-a59f-55475b156340';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.ad52b73f-32f7-4d2c-ba61-3bbfd2431e18'
WHERE 
w3.gml_id = 'SE.LM.HY.11a4ac4a-28bc-431c-9d4d-82bfa3be5501';

UPDATE 
alt_insp.watercourselink w3
SET 
fk_gml_id_wcls = 'SE.LM.HY.d5d06afe-a5da-418a-a26d-858abed51ea8'
WHERE 
w3.gml_id = 'SE.LM.HY.d80920d6-3888-4e8b-b055-b53c4f754105';
*/


---------------------------------------------------------------------------
-- Work on cases where ids in watercourselink and hydronode do not match --
--------------------------------------------------------------------------- 
SELECT COUNT(*) --1
FROM
((SELECT startnode 
FROM alt_insp.watercourselink w 
UNION
SELECT endnode 
FROM alt_insp.watercourselink w2 )
EXCEPT
SELECT gml_id
FROM
alt_insp.hydronode h )A 

UPDATE 
alt_insp.watercourselink w3
SET 
endnode = 'SE.LM.HY.2a86a735-bb85-91cd-0cc0-601e27aefae4'
WHERE 
w3.gml_id = 'SE.LM.HY.19eb07da-7660-42c4-9306-ec2c68e21530';

SELECT COUNT(*) --0
FROM
(SELECT gml_id
FROM
alt_insp.hydronode h
EXCEPT
(SELECT startnode 
FROM alt_insp.watercourselink w 
UNION
SELECT endnode 
FROM alt_insp.watercourselink w2 )
)A 


-------------------------------------
-- Add reference to physical waters -
-------------------------------------

-- references in watercourselink
CREATE TEMPORARY TABLE ref_phy AS
SELECT gml_id,
SUBSTRING(relatedhydroobject_href FROM 'gml.zip.inspire-hyp_(..)_') AS ref_phy,
SUBSTRING(relatedhydroobject_href FROM POSITION('#' IN relatedhydroobject_href) + 1) AS fk_gml_id_phy
FROM alt_insp.watercourselink w; 

-- add columns to watercourse links
ALTER TABLE alt_insp.watercourselink ADD fk_gml_id_sw VARCHAR;
ALTER TABLE alt_insp.watercourselink ADD fk_gml_id_wc VARCHAR;

-- update table
UPDATE alt_insp.watercourselink w 
SET fk_gml_id_sw=ref_phy.fk_gml_id_phy
FROM ref_phy
WHERE w.gml_id =ref_phy.gml_id
AND ref_phy.ref_phy='sw' ;

UPDATE alt_insp.watercourselink w --150593
SET fk_gml_id_wc=ref_phy.fk_gml_id_phy
FROM ref_phy
WHERE w.gml_id =ref_phy.gml_id
AND ref_phy.ref_phy='wc' ;

--**********************--
-- Standing water table --
--**********************--

-- Find segments where references are not available in standingwater table
CREATE TABLE alt_insp.non_ref_sw AS
WITH 
IDS AS( -- ids of segments that are not available in standing water
SELECT gml_id 
FROM
ref_phy
WHERE 
fk_gml_id_phy IN
(SELECT fk_gml_id_phy
FROM ref_phy
where ref_phy='sw'
EXCEPT
SELECT distinct gml_id
FROM alt_insp.standingwater
)), 
non_ref_seg AS(
SELECT w.*
FROM 
alt_insp.watercourselink w 
JOIN IDS
on w.gml_id=IDS.gml_id)
SELECT *
FROM
non_ref_seg n;

-- add index to temporary table
CREATE INDEX geometryidx on alt_insp.non_ref_sw USING GIST(wkb_geometry);
SELECT *
FROM alt_insp.non_ref_sw


CREATE TEMPORARY TABLE spat_int AS --55464 rows
SELECT DISTINCT ON(gml_id) gml_id, fk_gml_id_phy, lengthm 
FROM
(SELECT nrs.gml_id, s.gml_id as fk_gml_id_phy ,ST_LENGTH(ST_intersection(nrs.wkb_geometry, s.geometry)) as lengthm
FROM
alt_insp.non_ref_sw nrs 
JOIN 
alt_insp.standingwater s
ON 
ST_intersects(nrs.wkb_geometry, s.geometry)) A 
ORDER BY gml_id, lengthm DESC;

-- Update watercourselink
UPDATE alt_insp.watercourselink w
SET fk_gml_id_sw=s.fk_gml_id_phy
FROM spat_int s
WHERE w.gml_id=s.gml_id;

-- Update watercourselink (links with no standing water associated(this has been checked on a map!!!)) 52 segments
UPDATE alt_insp.watercourselink 
SET fk_gml_id_sw = NULL
WHERE gml_id IN
(SELECT gml_id
from alt_insp.non_ref_sw nrs 
EXCEPT
SELECT gml_id 
FROM spat_int s)

--*******************--
-- Watercourse table --
--*******************--

-- Find segments where references are not available in standingwater table
CREATE TABLE alt_insp.non_ref_wc AS --18099
WITH 
IDS AS( -- ids of segments that are not available in standing water
SELECT gml_id 
FROM
ref_phy
WHERE 
fk_gml_id_phy IN
(SELECT fk_gml_id_phy
FROM ref_phy
where ref_phy='wc'
EXCEPT
SELECT distinct gml_id
FROM alt_insp.watercourse
)), 
non_ref_seg AS(
SELECT w.*
FROM 
alt_insp.watercourselink w 
JOIN IDS
on w.gml_id=IDS.gml_id)
SELECT *
FROM
non_ref_seg n;

-- add index to temporary table
CREATE INDEX geometryidx_wc on alt_insp.non_ref_wc USING GIST(wkb_geometry);

CREATE TEMPORARY TABLE spat_int2 AS --18099 
SELECT DISTINCT ON(gml_id) gml_id, fk_gml_id_phy, lengthm 
FROM
(SELECT nrc.gml_id, w.gml_id as fk_gml_id_phy ,ST_LENGTH(ST_intersection(nrc.wkb_geometry, w.geometry)) as lengthm
FROM
alt_insp.non_ref_wc nrc 
JOIN 
alt_insp.watercourse w 
ON 
ST_intersects(nrc.wkb_geometry, w.geometry)) A 
ORDER BY gml_id, lengthm DESC;

-- Update watercourselink
UPDATE alt_insp.watercourselink w
SET fk_gml_id_wc=s.fk_gml_id_phy
FROM spat_int2 s
WHERE w.gml_id=s.gml_id;

SELECT COUNT(*)
FROM alt_insp.watercourselink w 
WHERE fk_gml_id_wc IS NULL;

------------------------------------------------------------------------
-- Create index on watercourselinksequence id in table watercourselink -
------------------------------------------------------------------------
CREATE INDEX fk_gml_id_wcls_idx ON alt_insp.watercourselink USING btree (fk_gml_id_wcls);
CREATE INDEX startnode_gml_idx ON alt_insp.watercourselink USING btree (startnode);
CREATE INDEX endnode_gml_idx ON alt_insp.watercourselink USING btree (endnode);

-- Add primary keys using GML_ids
ALTER TABLE alt_insp.hydronode 
ADD PRIMARY KEY (gml_id);
ALTER TABLE alt_insp.watercourselink  
ADD PRIMARY KEY (gml_id);
ALTER TABLE alt_insp.standingwater 
ADD PRIMARY KEY (gml_id);
ALTER TABLE alt_insp.watercourse  
ADD PRIMARY KEY (gml_id);

-- CREATE spatial indices
CREATE INDEX hn_geom_idx
  ON alt_insp.hydronode 
  USING GIST (wkb_geometry);
CREATE INDEX wcl_geom_idx
  ON alt_insp.watercourselink  
  USING GIST (wkb_geometry);
CREATE INDEX wcls_geom_idx
  ON alt_insp.watercourselinksequence  
  USING GIST (wkb_geometry);
CREATE INDEX sw_geom_idx
  ON alt_insp.standingwater  
  USING GIST (geometry);
CREATE INDEX wc_geom_idx
  ON alt_insp.watercourse  
  USING GIST (geometry); 


------------------------------------------------------------------------
--           Add foreign keys to watercourse link table               --
------------------------------------------------------------------------
ALTER TABLE alt_insp.watercourselink  
ADD CONSTRAINT fk_gml_id_endnode 
FOREIGN KEY (endnode) 
REFERENCES alt_insp.hydronode (gml_id);

ALTER TABLE alt_insp.watercourselink  
ADD CONSTRAINT fk_gml_id_startnode 
FOREIGN KEY (startnode) 
REFERENCES alt_insp.hydronode (gml_id);

ALTER TABLE alt_insp.watercourselink  
ADD CONSTRAINT fk_gml_id_sw 
FOREIGN KEY (fk_gml_id_sw) 
REFERENCES alt_insp.standingwater (gml_id);

ALTER TABLE alt_insp.watercourselink  
ADD CONSTRAINT fk_gml_id_wc 
FOREIGN KEY (fk_gml_id_wc) 
REFERENCES alt_insp.watercourse (gml_id);

-----------------------------------------------------------------
-- Find bifurcations (the segment upstream from a bifurcation) --
-----------------------------------------------------------------
CREATE MATERIALIZED VIEW alt_insp.bifurcations AS
SELECT *
FROM alt_insp.watercourselink w3 
WHERE w3.endnode IN
(SELECT w.startnode
FROM 
alt_insp.watercourselink w 
GROUP BY w.startnode HAVING COUNT(*)>1 ORDER BY COUNT(*) DESC)

/***********************************************************************
-- Utility function used to find startnode of watercourselinksequences * 
************************************************************************/
CREATE OR REPLACE FUNCTION test.fncstartsegment_within_seq(id varchar)
RETURNS TABLE 
(
gml_id varchar
)
AS
$$ 
BEGIN 
	RETURN QUERY
	SELECT wcl.gml_id FROM test.watercourselink wcl
	WHERE fk_gml_id_wcls=id
	AND startnode IN 
	(SELECT 
	w1.startnode
	FROM test.watercourselink w1
	WHERE w1.fk_gml_id_wcls = id
	EXCEPT
	SELECT
	w2.endnode
	FROM test.watercourselink w2
	WHERE w2.fk_gml_id_wcls = id);
END;
$$
LANGUAGE plpgsql;

-- Utility function used to find endsegments of watercourselinksequences  
CREATE OR REPLACE FUNCTION test.fncendsegment_within_seq(id varchar)
RETURNS TABLE 
(
gml_id varchar
)
AS
$$ 
BEGIN 
	RETURN QUERY
	SELECT wcl.gml_id FROM test.watercourselink wcl
	WHERE fk_gml_id_wcls=id
	AND endnode IN 
	(SELECT 
	w1.endnode
	FROM test.watercourselink w1
	WHERE w1.fk_gml_id_wcls = id
	EXCEPT
	SELECT
	w2.startnode
	FROM test.watercourselink w2
	WHERE w2.fk_gml_id_wcls = id);
END;
$$
LANGUAGE plpgsql;

-- Utility function used to find startnode of watercourselinksequences  
CREATE OR REPLACE FUNCTION test.fncstartnode_within_seq(id varchar)
RETURNS TABLE 
(
node varchar
)
AS
$$ 
BEGIN 
	RETURN QUERY
	SELECT 
	w1.startnode
	FROM test.watercourselink w1
	WHERE w1.fk_gml_id_wcls = id
	EXCEPT
	SELECT
	w2.endnode
	FROM test.watercourselink w2
	WHERE w2.fk_gml_id_wcls = id;
END;
$$
LANGUAGE plpgsql;

-- Utility function used to find endnode of each watercourselinksequences  
CREATE OR REPLACE FUNCTION test.fncendnode_within_seq(id varchar)
RETURNS TABLE 
(
node varchar
)
AS
$$ 
BEGIN 
	RETURN QUERY
	SELECT 
	w1.endnode
	FROM test.watercourselink w1
	WHERE w1.fk_gml_id_wcls = id
	EXCEPT
	SELECT
	w2.startnode
	FROM test.watercourselink w2
	WHERE w2.fk_gml_id_wcls = id;
END;
$$
LANGUAGE plpgsql;


-- Utility function used to find intermediate nodes in watercourselinksequences  
CREATE OR REPLACE FUNCTION test.fncintermnodes_within_seq(id varchar)
RETURNS TABLE 
(
nodes varchar
)
AS
$$ 
BEGIN 
	RETURN QUERY
	SELECT 
	w1.endnode
	FROM test.watercourselink w1
	WHERE w1.fk_gml_id_wcls = id
	INTERSECT 
	SELECT
	w2.startnode
	FROM test.watercourselink w2
	WHERE w2.fk_gml_id_wcls = id;
END;
$$
LANGUAGE plpgsql;

-- Intermediate nodes within each sequence
SELECT alt_insp.fncintermnodes_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A

-- startnodes within each sequence
SELECT alt_insp.fncstartnode_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A

-- endnodes within each sequence
SELECT alt_insp.fncendnode_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A

-- endsegment within each sequence
SELECT alt_insp.fncendsegment_within_seq(fk_gml_id_wcls) gml_id, fk_gml_id_wcls FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A

WITH endnodes AS (
SELECT alt_insp.fncendnode_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A)
SELECT COUNT(*) -- #361213
FROM endnodes;

-- Find bifurcations from sequence endnodes
CREATE MATERIALIZED VIEW alt_insp.dupl_startnodes_end_seq AS
WITH endnodes AS (
SELECT alt_insp.fncendnode_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A)
SELECT *
FROM alt_insp.watercourselink w 
where w.startnode IN
(SELECT w.startnode
FROM alt_insp.watercourselink w 
WHERE w.startnode IN (SELECT sn_ids FROM endnodes)
GROUP BY w.startnode  
HAVING COUNT(*) >1)

-- Find substreams
CREATE MATERIALIZED VIEW alt_insp.substream AS
WITH intermnodes AS (
SELECT alt_insp.fncintermnodes_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls 
FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A)
, startnodes AS (
SELECT alt_insp.fncstartnode_within_seq(fk_gml_id_wcls) sn_ids, fk_gml_id_wcls 
FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A)
SELECT w.*
FROM alt_insp.watercourselink w 
WHERE fk_gml_id_wcls IN(
SELECT s.fk_gml_id_wcls
FROM
startnodes s
JOIN
intermnodes i
ON s.sn_ids=i.sn_ids);

CREATE MATERIALIZED VIEW alt_insp.sourcenodes AS
SELECT *
FROM 
alt_insp.hydronode h 
where 
h.gml_id IN (SELECT startnode FROM alt_insp.watercourselink EXCEPT
			 SELECT endnode FROM alt_insp.watercourselink)

-----------------------------------------------------------------------------
-- Create views used to visualise start and end segments withing sequences --
-----------------------------------------------------------------------------

CREATE MATERIALIZED VIEW alt_insp.endsegment AS 
WITH sn_ids AS
(SELECT alt_insp.fncendsegment_within_seq(fk_gml_id_wcls) sn_ids FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A) 
SELECT * FROM alt_insp.watercourselink w 
WHERE gml_id IN (SELECT sn_ids FROM sn_ids)

CREATE MATERIALIZED VIEW alt_insp.startsegment AS 
WITH sn_ids AS
(SELECT alt_insp.fncstartsegment_within_seq(fk_gml_id_wcls) sn_ids FROM 
(SELECT DISTINCT fk_gml_id_wcls FROM alt_insp.watercourselink w) A) 
SELECT * FROM alt_insp.watercourselink w 
WHERE gml_id IN (SELECT sn_ids FROM sn_ids)



--------------------------
-- vacuum analyse table --
--------------------------
VACUUM FULL alt_insp.watercourselink;
VACUUM FULL alt_insp.watercourselinksequence;
VACUUM FULL alt_insp.hydronode;
VACUUM FULL alt_insp.non_ref_sw;