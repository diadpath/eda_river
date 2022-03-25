create table rht.crosstab_rht_2015 as (
 -- le script utilise la fonction crosstab (text,text) pour passer d'un format 'long' a un format 'court' (données en colonnes)
-- comme crosstab est une fonction renvoyant un setof record, il faut nommer et typer les colonnes de sortie as....

SELECT 
  rhtvs2.id_drain,
  crosstab_rhtvs2.largeur, 
  crosstab_rhtvs2.surface, 
  crosstab_rhtvs2.ers_id_drain, 
  crosstab_rhtvs2.exutoire, 
  crosstab.gamma, 
  crosstab.delta, 
  crosstab.densite, 
  crosstab.densite*crosstab_rhtvs2.surface as abondance,
  crosstab_rhtvs2.cs_heightp,
  rhtvs2.the_geom,
  rhtvs2.dmer,
  rhtvs2.dsource,
  rhtvs2.cumnbbar from rht.rhtvs2 left join 
	(SELECT * FROM crosstab('select res_id_drain, res_mod_id,res_value from rht.resultmodel
					where res_mod_id in (					
					(select max(mod_id)-2 from rht.model_mod),
					(select max(mod_id)-1 from rht.model_mod),
					(select max(mod_id) from rht.model_mod))
					order by 1,2',
					'select mod_id from rht.model_mod where mod_id in (
					(select max(mod_id)-2 from rht.model_mod),
					(select max(mod_id)-1 from rht.model_mod),
					(select max(mod_id) from rht.model_mod)
					) order by mod_id')
			AS ct(id_drain integer, 
			gamma numeric, 
			delta numeric,
			densite numeric
			) 
	)as crosstab
on rhtvs2.id_drain=crosstab.id_drain
left join rht.crosstab_rhtvs2
on crosstab_rhtvs2.id_drain=crosstab.id_drain);

comment on table rht.crosstab_rht_2015 is 'table crée le 10 fevrier 2015';
-- creation des clés et des index qui vont bien
alter table rht.crosstab_rht_2015 add constraint c_pk_crosstab_rht_2015 PRIMARY KEY (id_drain);	
CREATE INDEX crosstab_rht_2015_index
  ON rht.crosstab_rht_2015
  USING btree
  (id_drain);
CREATE INDEX crosstab_rht_2015_gistindex
  ON rht.crosstab_rht_2015
  USING gist
  (the_geom);

-- select Probe_Geometry_Columns();