
/* 
 * CREATE_EEL_ELECTROFISHING_TABLE
 * 
 * This script is used to create a table with electrofishing data from SERS to be used in EDA 2.4
 * 
 * @ Torbjörn Säterberg (torbjorn.saterberg@slu.se) 2023-01-24
 */

-------------------------------------------------------
-- use this code to check individual tables and keys --
-------------------------------------------------------

/*
-- check key in density table (xkoorlok, ykoorlok, fiskedat) #79574
select count(*)
from 
(select distinct lokalid, fiskedat 
from
rawdata.elfiskefangst_isa ei) dens;  

-- check key in length table (xkoorlok, ykoorlok, fiskedat) #74187
select count(*)
from 
(select distinct lokalid, fiskedat 
from
rawdata.elfiskelangder_isa ei) dens;  

-- check key in utf table #79177
select count(*)
from 
(select distinct lokalid, fiskedat 
from
rawdata.elfiskeutftotal_isa ei) dens;  

-- check key in environmental table #79574
select count(*)
from 
(select distinct lokalid, fiskedat 
from
rawdata.elprovfiske_isa ei) dens;  


-- check key difference #5387 ( there is thus 5387 electrofishing operations without lengths)
select count(*)
from
(select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskefangst_isa ei
except
select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskelangder_isa ei) A

-- zero occations with keys in elfiskeländger that do not exist in density table
select count(*)
from
(select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskelangder_isa ei
except
select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskefangst_isa ei) A

-- no difference in keys between density and environmental tables
select count(*)
from
(select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elprovfiske_isa ei
except
select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskefangst_isa ei) A


-- check key difference #397 ( there is thus 397 electrofishing operations where we do not have utfisken)
select count(*)
from
(select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskefangst_isa ei
except
select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskeutftotal_isa ei) A

-- check key difference #0 (No occations where we have utfisken and not density data)
select count(*)
from
(select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskeutftotal_isa ei
except
select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskefangst_isa ei) A

-- find data where there is no utfiske but density estimates
with el_key as
(select *
from
(select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskefangst_isa ei
except
select distinct xkoorlok, ykoorlok, fiskedat 
from
rawdata.elfiskeutftotal_isa ei) A)
select ei2.*
from 
rawdata.elfiskefangst_isa ei2, el_key
where 
ei2.xkoorlok in (el_key.xkoorlok) and
ei2.ykoorlok in (el_key.ykoorlok) and 
ei2.fiskedat in (el_key.fiskedat);

-- Check if there are no nulls in lokalid in any electro fishing table
select count(*)
from rawdata.elprovfiske_isa ei  
where lokalid is null
*/

-------------------------------------
-- Create eel electrofishing table --
-------------------------------------
--
-- 1. create a unique list of ids(lokalid and fiskedat) with electrofishing operations
drop view if exists rawdata.eel_dens_electrofishing;
create view rawdata.eel_dens_electrofishing as
with el_key as( -- keys for each electrofishing
select distinct xkoorlok, ykoorlok, lokalid, fiskedat
from rawdata.elfiskefangst_isa),
eel_dens as ( -- eel densities where eel have been caught
select 
*
from 
rawdata.elfiskefangst_isa ei2 
where 
fiskart='Ål'),
eel_utf as ( -- electrofishing operations where eels have been caught
select 
*
from 
rawdata.elfiskeutftotal_isa ei3
where 
fiskart = 'Ål'),
eel_env as ( -- environmental variables for electrofishing
select 
*
from
rawdata.elprovfiske_isa
),
site as ( --information on electrofishing site
select 
*
from
rawdata.elfiskelokal_isa ei 
)
select distinct -- change here to include other variables
ek.xkoorlok, ek.ykoorlok, s.vdragnam, ST_POINT(ek.ykoorlok,ek.xkoorlok,3021) geom, ek.lokalid, ek.fiskedat, 
ed.storfisk eel_dens, ee.antutfis, eu.utf1, eu.utf2, eu.utf3, eu.utf4, eu.aldersta,
ee.bredd, ee.langd, ee.lokalbre, ee."area", ee.avfiskbr, ee.grumligh, 
ee.vtnfarg, ee.maxdjup, ee.medeldju, ee.bottento, ee.substr1, ee.substr2, 
ee.substr3, ee.vattenha, ee.vattente, ee.lufttemp, ee.syfte 
from
el_key ek
left join site s on ek.lokalid=s.lokalid
left join eel_dens ed on ek.lokalid = ed.lokalid and ek.fiskedat=ed.fiskedat
left join eel_env ee on ek.lokalid = ee.lokalid and ek.fiskedat=ee.fiskedat
left join eel_utf eu on ek.lokalid = eu.lokalid and ek.fiskedat=eu.fiskedat;

/*
-- It is a double id in the utf table
select *
from 
rawdata.elfiskeutftotal_isa ei  
where lokalid='654280-129370' and fiskedat='1991-09-19 00:00:00.000';

-- There is a double id for one electrofishing
select lokalid, fiskedat, count(*)
from
rawdata.elfiskeutftotal_isa ei
where fiskart ='Ål'
group by lokalid, fiskedat
order by count(*) desc
*/
