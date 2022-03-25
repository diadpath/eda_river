
 CREATE OR REPLACE FUNCTION dbeel_rivers.get_distance(_from integer, _to integer, _country character varying)                       
  RETURNS numeric                                                                                                                   
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
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
 $function$                                                                                                                         
 
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
 $function$                                                                                                                         
 
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
 $function$                                                                                                                         
 
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
 $function$                                                                                                                         
 
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
 $function$   
 
 
 
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
 $function$  
 


