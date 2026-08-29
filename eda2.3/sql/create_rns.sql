DROP TABLE IF EXISTS dbeel_rivers.rns CASCADE;
CREATE TABLE dbeel_rivers.rns (
	idsegment text NULL,
	ratio float8 NULL,
	region text NULL,
	presencesaumon int4 NULL,
	surfaceerr float8 NULL,
	geol text NULL,
	intensite_etiage float8 NULL,
	idbvia text NULL,
	pred float8 NULL,
	s_err_mod float8 NULL,
	s_err_obs float8 NULL,
	assessment_year text NULL,
	preddensactu float8 NULL,
	preddenspristine float8 NULL,
	preddens float8 NULL,
	eff_sat float8 NULL,
	"IC-5\%" float8 NULL,
	"Moy" float8 NULL,
	"IC-95\%" float8 NULL,
	prod_mod_hist float8 NULL,
	prod_mod_actu float8 NULL,
	prod_obs float8 NULL,
	prod_obs_5 float8 NULL,
	prod_obs_95 float8 null,
CONSTRAINT c_pk_rns_idsegment PRIMARY KEY (idsegment)
);
ALTER TABLE dbeel_rivers.rns DROP COLUMN geol CASCADE;


--09/04/2026 we include "new" predictions in the table
ALTER TABLE dbeel_rivers.rns DROP CONSTRAINT c_pk_rns_idsegmentassessmentyear;
ALTER TABLE dbeel_rivers.rns ADD CONSTRAINT c_pk_rns_idsegmentassessmentyear  PRIMARY KEY (idsegment,assessment_year);


DROP TABLE IF EXISTS france.rns;    
CREATE TABLE france.rns (
      CONSTRAINT c_pk_rns_idsegment PRIMARY KEY (idsegment),
      CONSTRAINT c_fk_rns_idsegment FOREIGN KEY (idsegment) REFERENCES france.rn(idsegment))
      INHERITS (dbeel_rivers.rns); 


ALTER TABLE france.rns DROP CONSTRAINT c_pk_rns_idsegmentassessmentyear ;
ALTER TABLE france.rns ADD CONSTRAINT c_pk_rns_idsegmentassessmentyear  PRIMARY KEY (idsegment, assessment_year);      
-- Updates from rna

INSERT INTO france.rns
select *
FROM france.temp_rns
; -- 34198

DROP TABLE IF EXISTS france.temp_rns;

--create france.rn_rna_rne_rns
DROP VIEW IF exists france.rn_rna_rne_rns;
CREATE OR REPLACE VIEW france.rn_rna_rne_rns AS(
	SELECT row_number() OVER () AS _uid_,
	    rne.idsegment,
	    rne.delta,
	    rne.gamma,
	    rne.density,
	    rne.neel,
	    rne.beel,
	    rne.p150,
	    rne.p150300,
	    rne.p300450,
	    rne.p450600,
	    rne.p600750,
	    rne.p750,
	    rne.nsilver,
	    rne.bsilver,
	    rne.psilver150300,
	    rne.psilver300450,
	    rne.psilver450600,
	    rne.psilver600750,
	    rne.psilver750,
	    rne.psilver,
	    rne.pmale150300,
	    rne.pmale300450,
	    rne.pmale450600,
	    rne.pfemale300450,
	    rne.pfemale450600,
	    rne.pfemale600750,
	    rne.pfemale750,
	    rne.pmale,
	    rne.sex_ratio,
	    rne.cnfemale300450,
	    rne.cnfemale450600,
	    rne.cnfemale600750,
	    rne.cnfemale750,
	    rne.cnmale150300,
	    rne.cnmale300450,
	    rne.cnmale450600,
	    rne.cnsilver150300,
	    rne.cnsilver300450,
	    rne.cnsilver450600,
	    rne.cnsilver600750,
	    rne.cnsilver750,
	    rne.cnsilver,
	    rne.delta_tr,
	    rne.gamma_tr,
	    rne.type_fit_delta_tr,
	    rne.type_fit_gamma_tr,
	    rne.density_tr,
	    rne.density_pmax_tr,
	    rne.neel_pmax_tr,
	    rne.nsilver_pmax_tr,
	    rne.density_wd,
	    rne.neel_wd,
	    rne.beel_wd,
	    rne.nsilver_wd,
	    rne.bsilver_wd,
	    rne.sector_tr,
	    rne.year_tr,
	    rne.is_current_distribution_area,
	    rne.is_pristine_distribution_area_1985,
	    rne.cnsilver_wd,
	    rna.codesea,
	    rna.name,
	    rna.basin,
	    rna.emu,
	    rn.geom,
	    rn.country,
	    rns.ratio, 
	    rns.region, 
	    rns.presencesaumon, 
	    rns.surfaceerr, 
	    rns.intensite_etiage, 
	    rns.idbvia, 
	    rns.pred, 
	    rns.s_err_mod, 
	    rns.s_err_obs, 
	    rns.preddensactu, 
	    rns.preddenspristine, 
	    rns.preddens, 
	    rns.eff_sat, 
	    rns."IC-5\%", 
	    rns."Moy", 
	    rns."IC-95\%", 
	    rns.prod_mod_hist, 
	    rns.prod_mod_actu, 
	    rns.prod_obs, 
	    rns.prod_obs_5, 
	    rns.prod_obs_95,
	    geol.geol_type
	   FROM france.rn
	     JOIN france.rne ON rn.idsegment = rne.idsegment
	     JOIN france.rna ON rn.idsegment = rna.idsegment	    
	     LEFT JOIN france.rn_rna_geol geol ON geol.idsegment= rn.idsegment
	     LEFT JOIN (SELECT * FROM france.rns WHERE assessment_year = '2026') rns ON rn.idsegment = rns.idsegment
	       -- Updated value in france.rns 
);

--create dbeel_rivers.rn_rna_rne_rns
DROP VIEW IF exists dbeel_rivers.rn_rna_rne_rns;
CREATE OR REPLACE VIEW dbeel_rivers.rn_rna_rne_rns AS(
	SELECT row_number() OVER () AS _uid_,
	    rn.idsegment,
	    rne.delta,
	    rne.gamma,
	    rne.density,
	    rne.neel,
	    rne.beel,
	    rne.p150,
	    rne.p150300,
	    rne.p300450,
	    rne.p450600,
	    rne.p600750,
	    rne.p750,
	    rne.nsilver,
	    rne.bsilver,
	    rne.psilver150300,
	    rne.psilver300450,
	    rne.psilver450600,
	    rne.psilver600750,
	    rne.psilver750,
	    rne.psilver,
	    rne.pmale150300,
	    rne.pmale300450,
	    rne.pmale450600,
	    rne.pfemale300450,
	    rne.pfemale450600,
	    rne.pfemale600750,
	    rne.pfemale750,
	    rne.pmale,
	    rne.sex_ratio,
	    rne.cnfemale300450,
	    rne.cnfemale450600,
	    rne.cnfemale600750,
	    rne.cnfemale750,
	    rne.cnmale150300,
	    rne.cnmale300450,
	    rne.cnmale450600,
	    rne.cnsilver150300,
	    rne.cnsilver300450,
	    rne.cnsilver450600,
	    rne.cnsilver600750,
	    rne.cnsilver750,
	    rne.cnsilver,
	    rne.delta_tr,
	    rne.gamma_tr,
	    rne.type_fit_delta_tr,
	    rne.type_fit_gamma_tr,
	    rne.density_tr,
	    rne.density_pmax_tr,
	    rne.neel_pmax_tr,
	    rne.nsilver_pmax_tr,
	    rne.density_wd,
	    rne.neel_wd,
	    rne.beel_wd,
	    rne.nsilver_wd,
	    rne.bsilver_wd,
	    rne.sector_tr,
	    rne.year_tr,
	    rne.is_current_distribution_area,
	    rne.is_pristine_distribution_area_1985,
	    rne.cnsilver_wd,
	    rna.codesea,
	    rna.name,
	    rna.basin,
	    rna.emu,
	    rn.geom,
	    rn.country,
	    rns.ratio, 
	    rns.region, 
	    rns.presencesaumon, 
	    rns.surfaceerr, 
	    rns.intensite_etiage, 
	    rns.idbvia, 
	    rns.pred, 
	    rns.s_err_mod, 
	    rns.s_err_obs, 
	    rns.preddensactu, 
	    rns.preddenspristine, 
	    rns.preddens, 
	    rns.eff_sat, 
	    rns."IC-5\%", 
	    rns."Moy", 
	    rns."IC-95\%", 
	    rns.prod_mod_hist, 
	    rns.prod_mod_actu, 
	    rns.prod_obs, 
	    rns.prod_obs_5, 
	    rns.prod_obs_95,
	    geol.geol_type
	   FROM dbeel_rivers.rn
	     JOIN dbeel_rivers.rne ON rn.idsegment = rne.idsegment
	     JOIN dbeel_rivers.rna ON rn.idsegment = rna.idsegment
	     LEFT JOIN france.rn_rna_geol geol ON geol.idsegment= rn.idsegment
	     LEFT JOIN (SELECT * FROM france.rns WHERE assessment_year = '2026') rns ON rn.idsegment = rns.idsegment
);




DROP VIEW IF exists dbeel_rivers.rn_rna_rns;
CREATE OR REPLACE VIEW dbeel_rivers.rn_rna_rns AS(
  SELECT row_number() OVER () AS _uid_,
      rn.idsegment, 
      rna.codesea,
      rn.issea,
      rn.seaidsegment,
      rna.lengthriverm,
      rna.medianflowm3ps,
      rna.distanceseam,
      rna.distancesourcem,
      rna.altitudem,
      rna.slope,
      rna.strahler,
      rna.name,
      rna.basin,
      rna.emu,
      rna.wettedsurfacem2,
      rna.wettedsurfaceotherm2,
	    rna.wettedasurface_riverm2,
      rna.wettedasurface_estuarym2,
      rna.wettedasurface_lagoonm2,
      rna.wettedasurface_reservoirm2,
      rna.wettedasurface_lakem2,
      rna.wettedasurface_temp_lakem2,
      rna.coeffwettedsurfaceother,
      rna.riverwidthm,
      rna.temperature,
      rna.temperaturejan,
      rna.temperaturejul,
      rn.geom,
      rn.country,
      rns.ratio, 
      rns.region, 
      rns.presencesaumon, 
      rns.surfaceerr, 
      rns.intensite_etiage, 
      rns.idbvia, 
      rns.pred, 
      rns.s_err_mod, 
      rns.s_err_obs, 
      rns.preddensactu, 
      rns.preddenspristine, 
      rns.preddens, 
      rns.eff_sat, 
      rns."IC-5\%", 
      rns."Moy", 
      rns."IC-95\%", 
      rns.prod_mod_hist, 
      rns.prod_mod_actu, 
      rns.prod_obs, 
      rns.prod_obs_5, 
      rns.prod_obs_95,
      geol.geol_type
     FROM dbeel_rivers.rn
       JOIN dbeel_rivers.rna ON rn.idsegment = rna.idsegment
       LEFT JOIN france.rn_rna_geol geol ON geol.idsegment= rn.idsegment
       LEFT JOIN (SELECT * FROM dbeel_rivers.rns WHERE assessment_year = '2026') rns ON rn.idsegment = rns.idsegment
);



DROP VIEW IF exists france.rn_rna_rns;
CREATE OR REPLACE VIEW france.rn_rna_rns AS(
WITH rns AS (SELECT * FROM france.rns WHERE assessment_year  = '2026') 
  SELECT row_number() OVER () AS _uid_,
      rn.idsegment, 
      rna.codesea,
      rn.issea,
      rn.seaidsegment,
      rna.lengthriverm,
      rna.medianflowm3ps,
      rna.distanceseam,
      rna.distancesourcem,
      rna.altitudem,
      rna.slope,
      rna.strahler,
      rna.name,
      rna.basin,
      rna.emu,
      rna.wettedsurfacem2,
      rna.wettedsurfaceotherm2,
      rna.wettedasurface_riverm2,
      rna.wettedasurface_estuarym2,
      rna.wettedasurface_lagoonm2,
      rna.wettedasurface_reservoirm2,
      rna.wettedasurface_lakem2,
      rna.wettedasurface_temp_lakem2,
      rna.coeffwettedsurfaceother,
      rna.riverwidthm,
      rna.temperature,
      rna.temperaturejan,
      rna.temperaturejul,
      rn.geom,
      rn.country,
      rns.ratio, 
      rns.region, 
      rns.presencesaumon, 
      rns.surfaceerr, 
      rns.intensite_etiage, 
      rns.idbvia, 
      rns.pred, 
      rns.s_err_mod, 
      rns.s_err_obs, 
      rns.preddensactu, 
      rns.preddenspristine, 
      rns.preddens, 
      rns.eff_sat, 
      rns."IC-5\%", 
      rns."Moy", 
      rns."IC-95\%", 
      rns.prod_mod_hist, 
      rns.prod_mod_actu, 
      rns.prod_obs, 
      rns.prod_obs_5, 
      rns.prod_obs_95,
      geol.geol_type
     FROM france.rn
       JOIN france.rna ON rn.idsegment = rna.idsegment
       LEFT JOIN france.rn_rna_geol geol ON geol.idsegment= rn.idsegment
       LEFT JOIN rns ON rn.idsegment = rns.idsegment
       -- see sub query at the top for assessment year
);




