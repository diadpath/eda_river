---------------------------------------------------------------------------------------------------------------------------
-- 											drop_electrofishing_data 													 --
--																														 --
-- This script is used as a task for deleting electrofishing tables before transfering those from the data layer (SERS). --
-- See tasks folder DatTransSERS																						 -- 
--																														 --
-- @ Torbjörn Säterberg(torbjorn.saterberg@slu.se) 230125																 --
---------------------------------------------------------------------------------------------------------------------------

drop table if exists rawdata.elfiskefangst_isa cascade;
drop table if exists rawdata.elfiskelangder_isa cascade;
drop table if exists rawdata.elfiskelokal_isa cascade;
drop table if exists rawdata.elfiskeutftotal_isa cascade;
drop table if exists rawdata.elprovfiske_isa cascade;

