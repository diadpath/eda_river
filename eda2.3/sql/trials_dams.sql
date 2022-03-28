 with d as (
      SELECT  
* FROM sudoang.dbeel_obstruction_place o JOIN
sudoang.dbeel_physical_obstruction p on  o.op_id=p.ob_op_id WHERE country= 'SP'),
      /*
       * dams ... I collect rna to get emu variable...
       */
      r AS (SELECT rn.idsegment, 
		rn.country, 
		rna.basin, 
		rna.emu, 
		geom FROM "spain".rn JOIN "spain".rna ON rn.idsegment=rna.idsegment AND emu in ('ES_Basq') AND basin in ('CUENCAS INTERNAS PAIS VASCO')),
      dr as (SELECT *  FROM "spain"."join_obstruction_rn"),           
      /*
      joined dams
      */
      jd as (  
      SELECT          
      d.op_id, 
      /*
      op_gis_systemname, 
      op_gis_layername, 
      op_gislocation, 
      op_placename, 
      op_no_observationplacetype, */ 
      d.country AS dam_country,  
      /*
      op_op_id, 
      id_original,
      ob_id, 
      ob_no_origin,
      ob_no_type, 
      ob_no_period, 
      ob_starting_date, 
      ob_ending_date, 
      ob_op_id, 
      ob_dp_id, 
      ot_no_obstruction_type, 
      ot_obstruction_number, 
      ot_no_mortality_type, 
      ot_no_mortality, 
      po_no_obstruction_passability, */
      po_obstruction_height, 
      po_downs_pb, /*
      po_downs_water_depth, 
      po_presence_eel_pass, 
      po_method_perm_ev, 
      po_date_presence_eel_pass, 
      po_turbine_number, 
      fishway_type, */
      r.idsegment,
      r.country,
      r.basin,
      r.emu,
      st_distance(r.geom,d.the_geom) as distance 
      from d
      JOIN dr ON d.op_id=dr.op_id
      JOIN r ON r.idsegment=dr.idsegment
      order by idsegment, distance desc),
      /*
      joined dams unique
      */
      jdu AS (
      select distinct on (op_id) * from jd ),
      /*
      sum dams
      */
      sumd AS (
      select 
        distinct on (idsegment) idsegment,
        sum(nbdams) as nbdams,
        sum(height) as c_height,
        country,
        emu
        /*
        sum(heightp) as c_heightp,
        sum(heightp08) as c_heightp08,
        sum(heightp12) as c_heightp12,
        sum(heightp15) as c_heightp15,
        sum(heightp2) as c_heightp2,
        sum(score) as c_score 
        */
        from (
        select jdu.idsegment, 
        1 as nbdams, 
        coalesce(po_obstruction_height,0) as height,
        jdu.country,
        jdu.emu,
  jdu.basin
        /*
        coalesce(heightp,0)as heightp, 	
        case when coalesce(heightp,0)>1 then coalesce(heightp,0) else power(coalesce(heightp,0),0.8) end as heightp08,
        case when coalesce(heightp,0)<1 then coalesce(heightp,0) else power(coalesce(heightp,0),1.2) end as heightp12,
        case when coalesce(heightp,0)<1 then coalesce(heightp,0) else power(coalesce(heightp,0),1.5) end as heightp15,
        case when coalesce(heightp,0)<1 then coalesce(heightp,0) else power(coalesce(heightp,0),2) end as heightp2,
        coalesce(obs_impact,0) as score
        */
        from jdu) sub
       group by idsegment,country, emu, basin)
      SELECT * FROM sumd