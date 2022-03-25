-- http://trac.eptb-vilaine.fr:8066/trac/wiki/CCM2%20download%20and%20load

CREATE OR REPLACE FUNCTION ccm21.mycatchment2(wso1_id_ numeric)
  RETURNS SETOF integer AS
$BODY$
	DECLARE
	result RECORD;
	pri wso1_id%rowtype;
	resultcount RECORD;
	BEGIN
	    SELECT INTO result strahler FROM ccm21.riversegments where wso1_id=wso1_id_;
	    RAISE NOTICE 'result is %' ,result;
	    IF result.strahler=2 THEN 	
		RAISE NOTICE 'WSO_2 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso2_id =
			(select wso2_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso2_id =
			(select wso2_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=3 THEN 
		RAISE NOTICE 'WSO_3 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso3_id =
			(select wso3_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso3_id =
			(select wso3_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=4 THEN
		RAISE NOTICE 'WSO_4 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso4_id =
			(select wso4_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso4_id =
			(select wso4_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;			
	    ELSIF result.strahler=5 THEN
		RAISE NOTICE 'WSO_5 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso5_id =
			(select wso5_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso5_id =
			(select wso5_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=6 THEN
		RAISE NOTICE 'WSO_6 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso6_id =
			(select wso6_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso6_id =
			(select wso6_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		
	    ELSIF result.strahler=7 THEN
	    	RAISE NOTICE 'WSO_7 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso7_id =
			(select wso7_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso7_id =
			(select wso7_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=8 THEN
	    	RAISE NOTICE 'WSO_8 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso8_id =
			(select wso8_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso8_id =
			(select wso8_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		    	
	    ELSIF result.strahler=9 THEN
	    	RAISE NOTICE 'WSO_9 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso9_id =
			(select wso9_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso9_id =
			(select wso9_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		    	
	    ELSIF result.strahler=10 THEN
	    	RAISE NOTICE 'WSO_10 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso10_id =
			(select wso10_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso10_id =
			(select wso10_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.wso1_id=wso1_id_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		    		    		    		    	
	    ELSE RAISE NOTICE 'Strahler is larger than this function can handle !';
	    END IF;
	    RETURN;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION ccm21.mycatchment2(numeric)
  OWNER TO postgres;
COMMENT ON FUNCTION ccm21.mycatchment2(numeric) IS 'Uses the wso1_id from ccm21.riversegments, checks strahler, and select the catchment accordingly, then returns all primary catchments from this larger catchment';



-- Function: ccm21.upstream_segments2(numeric)

-- DROP FUNCTION ccm21.upstream_segments2(numeric);

CREATE OR REPLACE FUNCTION ccm21.upstream_segments2(wso1_id_ numeric)
  RETURNS SETOF integer AS
$BODY$
	DECLARE
	wso1_id_riversegments wso1_id%ROWTYPE;
	rec_pfafstette_length RECORD;
	rec_riversegments ccm21.riversegments%ROWTYPE;
	-- pfafstette_chain_length int;
	pfafstette_max_chain_length int;
	pfafstette_value int8;
	BEGIN
	-- filling a new table with the results from a catchment
	
	DROP TABLE IF EXISTS ccm21.upstream_riversegments;
	CREATE TABLE ccm21.upstream_riversegments AS SELECT * FROM ccm21.riversegments
	where wso1_id in (SELECT  ccm21.mycatchment2(wso1_id_));
        ALTER TABLE ccm21.upstream_riversegments ADD CONSTRAINT pk_upstream_riversegments PRIMARY KEY (wso1_id);

	-- pfafstette chain length
	--select into pfafstette_chain_length character_length(CAST(round(pfafstette) AS TEXT) 
	--	FROM ccm21.upstream_riversegments WHERE wso1_id=wso1_id_;
	-- RAISE NOTICE 'pfafstette chain length is %', pfafstette_chain_length;
	-- pfafstette max chain length in the selected  basin 
        select into pfafstette_max_chain_length max(character_length(CAST(round(pfafstette) AS TEXT)))
		FROM ccm21.upstream_riversegments; 
	-- pfafstette value
	-- the chain is lengthened to the pfafstette max chain length
	Update ccm21.upstream_riversegments set pfafstette = 
	floor(pfafstette)*power(10,(pfafstette_max_chain_length-character_length(CAST(floor(pfafstette) AS TEXT) )));  
	select into pfafstette_value CAST(round(pfafstette) AS int8) FROM ccm21.upstream_riversegments where wso1_id=wso1_id_;
	RAISE NOTICE 'pfafstette  is %', pfafstette_value;

        DELETE FROM ccm21.upstream_riversegments WHERE pfafstette < pfafstette_value; 
        -- extracting the riversegments corresponding to the basin
       
        for wso1_id_riversegments in select wso1_id from ccm21.upstream_riversegments order by wso1_id loop
	        wso1_id_riversegments.wso1_id=CAST(wso1_id_riversegments.wso1_id AS int8);
		return next wso1_id_riversegments.wso1_id;
		end loop;
		return;	
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION ccm21.upstream_segments2(numeric)
  OWNER TO postgres;
COMMENT ON FUNCTION ccm21.upstream_segments2(numeric) IS 'This function uses ccm21.mycatchment2 to get all the segments from a catchment and searches all segments with a pfafstetter higher than the segment in the bassin. The pfafstette are trucated to the level of the segment used as input in the function';
