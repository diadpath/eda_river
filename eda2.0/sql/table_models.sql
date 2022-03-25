create table europe.location as (select distinct on (area) area from europe.wso);
alter table europe.location ADD constraint c_pk_area PRIMARY KEY (area);
create table ccm21.model_mod(
	mod_id serial PRIMARY KEY,
	mod_name VARCHAR(30) NOT NULL UNIQUE,
	mod_date date,
	mod_description text NOT NULL,
	mod_location varchar(25),
	CONSTRAINT c_fk_mod_location FOREIGN KEY (mod_location) REFERENCES europe.location(area));
comment on column ccm21.model_mod.mod_location is 'Geographical area to which the model is applied, should be consistent with europe.wso';
drop table if exists ccm21.resultmodel;
create table ccm21.resultmodel(
	res_id serial PRIMARY KEY,
	res_wso1_id integer,
	res_riversegmentgid integer,
	res_value float,
	res_mod_id integer,
	CONSTRAINT c_fk_res_mod_id FOREIGN KEY (res_mod_id) REFERENCES ccm21.model_mod(mod_id));