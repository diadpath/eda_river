/* 
SCRIPT DE CREATION D'UN TABLEAU UNIQUE DES RESULTATS 
6 avril 2012 Cédric Briand Céline Jouanin
*/

-- pour voir les données du modèle, ci dessous seules certaines colonnes de résultats sont retenues

select * from rht.model_mod

-- le script utilise la fonction crosstab (text,text) pour passer d'un format 'long' a un format 'court' (données en colonnes)
-- comme crosstab est une fonction renvoyant un setof record, il faut nommer et typer les colonnes de sortie as....

DROP TABLE IF EXISTS rht.crosstab_rhtvs2;
CREATE TABLE rht.crosstab_rhtvs2 as (
	SELECT 
  rhtvs2.id_drain,
  crosstab.largeur, 
  crosstab.surface, 
  crosstab.ers_id_drain, 
  crosstab.exutoire, 
  crosstab.gamma, 
  crosstab.delta, 
  crosstab.densite, 
  crosstab.abondance,
  rhtvs2.the_geom,
  rhtvs2.dmer,
  rhtvs2.dsource,
  rhtvs2.cumnbbar from rht.rhtvs2 left join 
	(SELECT * FROM crosstab('select res_id_drain, res_mod_id,res_value from rht.resultmodel
					where res_mod_id in (15,16,17,18,4,5,6,8)
					order by 1,2',
					'select mod_id from rht.model_mod where mod_id in (15,16,17,18,4,5,6,8) order by mod_id')
			AS ct(id_drain integer, 
			largeur numeric,
			surface numeric,
			ers_id_drain numeric,
			exutoire numeric,
			gamma numeric, 
			delta numeric,
			densite numeric,
			abondance numeric) 
	)as crosstab
on rhtvs2.id_drain=crosstab.id_drain);

comment on table rht.crosstab_rhtvs2 is 'table crée le 6 avril 2012 a partir des résultats définitifs d''EDA';
-- creation des clés et des index qui vont bien
alter table rht.crosstab_rhtvs2 add constraint c_pk_crosstab_rhtvs2 PRIMARY KEY (id_drain);	
CREATE INDEX crosstab_rhtvs2_index
  ON rht.crosstab_rhtvs2
  USING btree
  (id_drain);
CREATE INDEX crosstab_rhtvs2_gistindex
  ON rht.rhtvs2
  USING gist
  (the_geom);
  
-- code dump
-- pg_dump -U postgres -f 'v_rht_model_mod.sql' --table rht.crosstab.rhtvs2 eda2.1

