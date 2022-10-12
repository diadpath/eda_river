/*
* get_path provides the path between two idsegments of the same basin
*/  
CREATE OR REPLACE FUNCTION dbeel_rivers.get_path(_from integer, _to integer, _country character varying)                           
  RETURNS SETOF ltree                                                                                                               
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
 SELECT text2ltree(string_agg(idsegment::text, '.')) AS gid_list                                                                  
 FROM (SELECT idsegment FROM pgr_dijkstra(                                                                                        
    'SELECT gid as id, source, target, st_length(geom) as cost FROM dbeel_rivers.rn where country='||quote_literal(_country),     
    _from,                                                                                                                        
    _to,                                                                                                                          
   FALSE                                                                                                                          
 )  pt                                                                                                                            
 JOIN dbeel_rivers.rn r ON pt.edge = r.gid where r.country = _country order by seq) sub;                                          
                                                                                                                                  
 END                                                                                                                              
 $function$;      
 
 
 -- EXAMPLE OF USE
-- select dbeel_rivers.get_path (113670,114115,'FR')
-- FR113618.FR114065.FR114053.FR114042

/* 
get_path functions for FRANCE, SPAIN and PORTUGAL
*/

-- DROP FUNCTION france.get_path(integer, integer);

CREATE OR REPLACE FUNCTION france.get_path(
    _from integer,
    _to integer)
  RETURNS SETOF ltree AS
$BODY$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(idsegment::text, '.')) AS idsegment_list  
FROM (SELECT idsegment FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM france.rn ',
   _from,
   _to,
  FALSE
)  pt
JOIN france.rn r ON pt.edge = r.gid order by seq) sub;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

 -- DROP FUNCTION portugal.get_path(integer, integer);

CREATE OR REPLACE FUNCTION portugal.get_path(
    _from integer,
    _to integer)
  RETURNS SETOF ltree AS
$BODY$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(idsegment::text, '.')) AS idsegment_list  
FROM (SELECT idsegment FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM portugal.rn ',
   _from,
   _to,
  FALSE
)  pt
JOIN portugal.rn r ON pt.edge = r.gid order by seq) sub;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;




 /*
 dbeel_rivers.dbeel_rivers.upstream_segments_rn(TEXT) takes an upstream segment and returns a vector of idsegments
If you don't have to search an international basin, is best run in the rn.france, rn.spain tables where the index are build for search
 */
 
 CREATE OR REPLACE FUNCTION dbeel_rivers.upstream_segments_rn(text)                                                                 
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
                         dbeel_rivers.rn r0                                                                                       
                 WHERE                                                                                                            
                         r0.idsegment = $1                                                                                        
                                                                                                                                  
                                                                                                                                  
                UNION SELECT                                                                                                      
                    r1.idsegment,                                                                                                 
                    r1.nextdownidsegment                                                                                          
                                                                                                                                  
                 FROM                                                                                                             
                         parcours                                                                                                 
                 JOIN dbeel_rivers.rn r1                                                                                          
                 ON  parcours.idsegment = r1.nextdownidsegment)                                                                   
           SELECT idsegment FROM parcours;                                                                                        
 END                                                                                                                              
 $function$;   
COMMENT ON FUNCTION dbeel_rivers.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment,
attention this function is slower than national counterparts, check in schema spain portugal and france for quicker functions';

-- EXAMPLE
-- SELECT  dbeel_rivers.upstream_segments_rn('FR114042') 

 /*
 dbeel_rivers.upstream_segments_rn_sti(TEXT) takes an upstream segment and a TABLE with idsegment, target, source, this in more convenient for
later use of routing functions (like get path) which require source and target
*/
 
 CREATE OR REPLACE FUNCTION dbeel_rivers.upstream_segments_rn_sti(text)                                                             
  RETURNS TABLE(_idsegment text, source integer, target integer)                                                                    
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
         WITH RECURSIVE parcours AS(                                                                                              
                 SELECT                                                                                                           
                         r0.idsegment,                                                                                            
                         r0.source,                                                                                               
                         r0.target                                                                                                
                 FROM                                                                                                             
                         dbeel_rivers.rn r0                                                                                       
                 WHERE                                                                                                            
                         r0.idsegment = $1                                                                                        
                                                                                                                                  
                                                                                                                                  
                UNION SELECT                                                                                                      
                        r1.idsegment,                                                                                             
                        r1.source,                                                                                                
                        r1.target                                                                                                 
                 FROM                                                                                                             
                         parcours                                                                                                 
                 JOIN dbeel_rivers.rn r1                                                                                          
                 ON  parcours.source = r1.target)                                                                                 
           SELECT * FROM parcours;                                                                                                
 END                                                                                                                              
 $function$;       

/*
 dbeel_rivers.downstream_segments_rn_sti(TEXT) takes an upstream segment and a TABLE with idsegment, target, source, this in more convenient for
later use of routing functions (like get path) which require source and target
*/
 
 CREATE OR REPLACE FUNCTION dbeel_rivers.downstream_segments_rn(text)                                                               
  RETURNS TABLE(_idsegment text)                                                                                                    
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
         WITH  parcoursdown AS(                                                                                                   
                 SELECT                                                                                                           
                         CAST(UNNEST(regexp_split_to_array(ltree2text(path),E'\\.')) AS TEXT) AS idsegment  from dbeel_rivers.rn 
                         WHERE idsegment = $1                                                                                     
                         EXCEPT                                                                                                   
                         SELECT $1 )                                                                                              
           SELECT * FROM parcoursdown;                                                                                            
 END                                                                                                                              
 $function$ ;  
 COMMENT ON FUNCTION dbeel_rivers.downstream_segments_rn(text) IS 'Function to calculate downstream segments idsegment';

-- EXAMPLE 
-- SELECT dbeel_rivers.downstream_segments_rn('SP227795');
 
 /*
 dbeel_rivers.downstream_segments_rn only for the spain schema, quicker to use.
*/
 
  CREATE OR REPLACE FUNCTION spain.downstream_segments_rn(text)                                                               
  RETURNS TABLE(_idsegment text)                                                                                                    
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
         WITH  parcoursdown AS(                                                                                                   
                 SELECT                                                                                                           
                         CAST(UNNEST(regexp_split_to_array(ltree2text(path),E'\\.')) AS TEXT) AS idsegment  from spain.rn 
                         WHERE idsegment = $1                                                                                     
                         EXCEPT                                                                                                   
                         SELECT $1 )                                                                                              
           SELECT * FROM parcoursdown;                                                                                            
 END                                                                                                                              
 $function$ ; 
 




/*
get_distance uses the pgr_dijkstra to calculate distance
between two rivers segments (including the distance of the idsegments themselves)
*/


CREATE OR REPLACE FUNCTION dbeel_rivers.get_distance(
    _from integer,
    _to integer,
    _country character varying)
  RETURNS numeric AS
$BODY$
BEGIN
RETURN(SELECT sum(lengthm) AS distance  
FROM (SELECT idsegment,lengthm FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM dbeel_rivers.rn where country='||quote_literal(_country),
   _from,
   _to,
  FALSE
)  pt
JOIN dbeel_rivers.rn r ON pt.edge = r.gid where r.country = _country order by seq) sub);
END
$BODY$
LANGUAGE plpgsql VOLATILE;

  
-- EXAMPLES
-- select  dbeel_rivers.get_distance (113670,114115,'FR'); --12669
 -- THE SAME WITH VECTORS
-- with source as (select source from france.rn_rna where basin ='la sarthe de sa source au loir (nc) [M0]' limit 10)
-- SELECT dbeel_rivers.get_distance(203073, source.source, 'FR') from source






/*
This function is adapted to return all elements (source,target, and idsegment)
*/


CREATE OR REPLACE FUNCTION dbeel_rivers.upstream_segments_rn_sti(IN text)
  RETURNS TABLE(_idsegment text, source integer, target INTEGER) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.source,
			r0.target
		FROM
			dbeel_rivers.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	               r1.idsegment,
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN dbeel_rivers.rn r1 
		ON  parcours.source = r1.target)
          SELECT * FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION dbeel_rivers.upstream_segments_rn_sti(text)
  OWNER TO postgres;
COMMENT ON FUNCTION dbeel_rivers.upstream_segments_rn_sti(text) IS 'Function to calculate upstream segments source, target idsegment, see spain.upstream_segments_rn to return idsegment only';


/*
Specific function for spain
*/


CREATE OR REPLACE FUNCTION spain.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			spain.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN spain.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION spain.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION spain.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment only for the spain
schema, use same function in dbeel_rivers schema for international search.';


CREATE OR REPLACE FUNCTION spain.upstream_segments_rn_sti(IN text)
  RETURNS TABLE(_idsegment text, source integer, target INTEGER) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.source,
			r0.target
		FROM
			spain.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	               r1.idsegment,
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN spain.rn r1 
		ON  parcours.source = r1.target)
          SELECT * FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION spain.upstream_segments_rn_sti(text)
  OWNER TO postgres;
COMMENT ON FUNCTION spain.upstream_segments_rn_sti(text) IS 'Function to calculate upstream segments source, target idsegment, see spain.upstream_segments_rn to return idsegment only';

-- France

CREATE OR REPLACE FUNCTION france.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			france.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN france.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION france.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION france.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment only for the france
schema, use same function in dbeel_rivers schema for international search.';

-- Portugal

CREATE OR REPLACE FUNCTION portugal.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			portugal.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN portugal.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION portugal.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION portugal.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment only for the portugal
schema, use same function in dbeel_rivers schema for international search.';





/*---------------
*  FRANCE EXTRACT BASINS
*-------------------------*/
-- example how to extract basins

with rr as (
	select 
	idsegment,
	split_part(split_part("name",'[',2),']',1) as cdsoussect,
	 split_part(split_part(basin,'[',2),']',1) AS cdsecteurh,
	 substring( split_part(split_part(basin,'[',2),']',1),1,1) as cdregionh
	 FROM france.rna),
  rrr AS (
	 SELECT *,
	 CASE WHEN cdregionh in ('U','V','W','X','Y') then 'M' else 'A' end as codesea
	 from rr)
 update france.rna set codesea=rrr.codesea from rrr where rrr.idsegment=rna.idsegment;--114564




/*
Function to write missing path (some basins have not been updated probably because of wrong basin assignation)
The function loads all downstream points where path is null into a cursor (curdown) and will move into this cursor
to apply get_path(cur_target,u.source, _country) where cur_target will be target point of the most downstream segment
source is the vector of sources of the whole basin collected by upstream_segments.

Function for spain (no country argument)
change isendoreic or idsea to adapt path calculation
*/


DROP function if exists spain.write_path(INTEGER);
CREATE OR REPLACE FUNCTION spain.write_path(_limit INTEGER)
   RETURNS integer AS 
 $$
DECLARE 
 current_count integer default 0;
 the_downstream_point   RECORD;
 cur_target integer;
 cur_idsegment TEXT; 
 cur_down CURSOR 
	 FOR SELECT idsegment, source, target
	 FROM  spain.rn 	 
	 --WHERE issea
	 WHERE isendoreic 
	 AND path IS NULL 
	 limit _limit;
         
BEGIN
   -- Open the cursor
   OPEN  cur_down;
   
   LOOP
    -- fetch row one by one into the_downstream_point
      FETCH cur_down INTO the_downstream_point;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
      current_count := current_count+1;
     cur_target := the_downstream_point.target;
     cur_idsegment := the_downstream_point.idsegment;
     
    -- raise notice for now
      RAISE NOTICE 'target :%',cur_target; 
      
    -- create the path for this target and all upstream segments, the correction is done in each country
     WITH uu AS (SELECT source from spain.upstream_segments_rn_sti(cur_idsegment))
     UPDATE spain.rn set path=spain.get_path(cur_target,uu.source) 
     from uu
     where rn.source = uu.source; 
  END LOOP;
  
   -- Close the cursor
   CLOSE cur_down;
 
   RETURN current_count;
END; 
$$ 
LANGUAGE plpgsql;


