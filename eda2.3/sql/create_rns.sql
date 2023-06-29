DROP TABLE IF EXISTS dbeel_rivers.rns CASCADE;
CREATE TABLE dbeel_rivers.rns (
idsegment TEXT,
surfaceunitbvm2 NUMERIC,
surfacebvm2 NUMERIC,
delta NUMERIC,
gamma NUMERIC,
density NUMERIC,
nyellow NUMERIC,
byellow NUMERIC, -- rne_annual
pyellow150 NUMERIC,
pyellow150300 NUMERIC,
pyellow300450 NUMERIC,
pyellow450600 NUMERIC,
pyellow600750 NUMERIC,
pyellow750 NUMERIC,
nsilver NUMERIC,
bsilver NUMERIC, -- rne_annual
psilver150300 NUMERIC,
psilver300450 NUMERIC,
psilver450600 NUMERIC,
psilver600750 NUMERIC,
psilver750 NUMERIC,
psilver NUMERIC,
pmale150300 NUMERIC,
pmale300450 NUMERIC,
pmale450600 NUMERIC,
pfemale300450 NUMERIC,
pfemale450600 NUMERIC,
pfemale600750 NUMERIC,
pfemale750 NUMERIC,
pmale NUMERIC,
sex_ratio NUMERIC,  -- rne_annual
cnfemale300450 NUMERIC, -- dbeel_rivers.rn_rna_cumul_silver
cnfemale450600 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnfemale600750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnfemale750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnmale150300 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnmale300450 NUMERIC,-- dbeel_rivers.rn_rna_cumul_si
cnmale450600 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver150300 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver300450 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver450600 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver600750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
delta_tr NUMERIC, --dbeel_rivers.rn_rna_model_transport_fit(deltatransport)
gamma_tr NUMERIC, --dbeel_rivers.rn_rna_model_transport_fit(gammatransport)
type_fit_delta_tr TEXT, --dbeel_rivers.rn_rna_model_transport_fit(type_fit_delta)
type_fit_gamma_tr TEXT, --dbeel_rivers.rn_rna_model_transport_fit(type_fit_gamma)
density_tr NUMERIC, --dbeel_rivers.rn_rna_model_transport_fit(densitytransport)
density_pmax_tr NUMERIC, -- dbeel_rivers.rn_rna_model_transport_fit(density2)
nyellow_pmax_tr NUMERIC, -- dbeel_rivers.rn_rna_model_transport(nyellow)
nsilver_pmax_tr NUMERIC, -- dbeel_rivers.rn_rna_model_transport(nsilver)
density_wd NUMERIC,  --TODO
nyellow_wd NUMERIC,  --TODO
byellow_wd NUMERIC,  --TODO
nsilver_wd NUMERIC,  --TODO
bsilver_wd NUMERIC,  --TODO
CONSTRAINT c_pk_rns_idsegment PRIMARY KEY (idsegment)
);


DROP TABLE IF EXISTS france.rns;    
CREATE TABLE france.rns (
      CONSTRAINT c_pk_rns_idsegment PRIMARY KEY (idsegment),
      CONSTRAINT c_fk_rns_idsegment FOREIGN KEY (idsegment) REFERENCES france.rn(idsegment))
      INHERITS (dbeel_rivers.rns); 
DROP TABLE IF EXISTS portugal.rns;
CREATE TABLE portugal.rns (
      CONSTRAINT c_pk_rns_idsegment PRIMARY KEY (idsegment),
      CONSTRAINT c_fk_rns_idsegment FOREIGN KEY (idsegment) REFERENCES portugal.rn(idsegment))
      INHERITS (dbeel_rivers.rns); 
      
-- Updates from rna

INSERT INTO france.rns (
  idsegment
, 
FROM temp_table_rns
; -- 325399