-------------------------------------------------------
-- Utility functions for creating rivernetwork Sweden -
-------------------------------------------------------

CREATE extension IF NOT EXISTS pgrouting
    WITH SCHEMA worksweden;

CREATE OR REPLACE FUNCTION worksweden.get_path(_from integer, _to integer, _country character varying)                           
  RETURNS SETOF ltree                                                                                                               
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
 SELECT text2ltree(string_agg(idsegment::text, '.')) AS gid_list                                                                  
 FROM (SELECT idsegment FROM pgr_dijkstra(                                                                                        
    'SELECT gid as id, source, target, st_length(geom) as cost FROM worksweden.rn where country='||quote_literal(_country),     
    _from,                                                                                                                        
    _to,                                                                                                                          
   FALSE                                                                                                                          
 )  pt                                                                                                                            
 JOIN worksweden.rn r ON pt.edge = r.gid where r.country = _country order by seq) sub;                                          
                                                                                                                                  
 END                                                                                                                              
 $function$;      


CREATE OR REPLACE FUNCTION worksweden.get_path(_from integer, _to integer)                           
  RETURNS SETOF ltree                                                                                                               
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
 SELECT text2ltree(string_agg(idsegment::text, '.')) AS gid_list                                                                  
 FROM (SELECT idsegment FROM pgr_dijkstra(                                                                                        
    'SELECT gid as id, source, target, ST_length(geom) as cost FROM worksweden.rn ',     
    _from,                                                                                                                        
    _to,                                                                                                                          
   TRUE                                                                                                                          
 )  pt                                                                                                                            
 JOIN worksweden.rn r ON pt.edge = r.gid order by seq) sub;                                          
                                                                                                                                  
 END                                                                                                                              
 $function$;      

select worksweden.get_path(785458,1302735)

/*
SELECT * FROM pgr_dijkstra(
  'select gid as id, source, target, lengthm as cost from worksweden.rn',
  471176, 45436, true)
*/

 -- EXAMPLE OF USE
-- select worksweden.get_path (702734, 1143560),'SW')
-- SW1282915.SW1286283.SW1285130.SW1287839

CREATE OR REPLACE FUNCTION worksweden.upstream_segments_rn(text)
 RETURNS TABLE(_idsegment text)
 LANGUAGE plpgsql
AS $function$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			worksweden.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN worksweden.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$function$
;



