

# C:\workspace\pdata\devalpomi\data\allba_prod_mod_actu.RData

rht <- ba@data

# recupérer les données des variables :


c("id_drain", "idbverr", "ratio", "pente", "module", "largeur", 
    "id_drainmer", "surface", "region", "presencesaumon", "surfaceerr", 
    "dmer", "strahler", "altitude", "geol", "x", "y", "c_ss_sect", 
    "libelle", "lib_sect", "lib_region", "lb", "intensite_etiage", 
    "idbvia", "sqrtpente", "lQ", "bv", "pred", "s_err_mod", "s_err_obs", 
    "date", "preddensactu", "preddenspristine", "preddens", "N", 
    "IC-5\\%", "Moy", "IC-95\\%", "prod_mod_hist", "prod_mod_actu", 
    "prod_obs", "prod_obs_5", "prod_obs_95", "nb_mort", "survie_finale_par_segment"
)
ba$idsegment <- str_c("FR", ba$id_drain)
# je dirais ces variables
c("idsegment", 
    "ratio", # ? c'est quoi ?
    "region", 
    "presencesaumon", 
    "surfaceerr", 
     "geol", 
    "intensite_etiage", 
    "idbvia", 
    "pred", 
    "s_err_mod", 
    "s_err_obs", 
    "date", 
    "preddensactu",
    "preddenspristine", 
    "preddens", 
    "N", 
    "IC-5\\%",
    "Moy", 
    "IC-95\\%",
    "prod_mod_hist",
    "prod_mod_actu", 
    "prod_obs", 
    "prod_obs_5", 
    "prod_obs_95"
)
