-------------------------
-- SCRIPT LOCALHOST
-- SCRIPT DE RECREATION DES COMPOSANTS DE LA BASE DE DONNEES
-- IL FAUT TOUT FAIRE TABLE PAR TABLE SINON MARCHE PAS
-------------------------
CREATE SCHEMA ccm21;
ALTER SCHEMA ccm21 OWNER TO postgres;
SET search_path = ccm21, public, pg_catalog;
-------------------------
-- table catchments
-------------------------
CREATE TABLE ccm21.catchments (
    gid integer NOT NULL,
    wso1_id integer,
    wso2_id integer,
    wso3_id integer,
    wso4_id integer,
    wso5_id integer,
    wso6_id integer,
    wso7_id integer,
    wso8_id integer,
    wso9_id integer,
    wso10_id integer,
    wso11_id integer,
    wso_id integer,
    strahler smallint,
    feature_co smallint,
    nextdownid integer,
    y_centroid integer,
    x_centroid integer,
    x_inside_l integer,
    y_inside_l integer,
    xmin_laea integer,
    ymin_laea integer,
    xmax_laea integer,
    ymax_laea integer,
    area numeric,
    area_km2 numeric,
    perimeter integer,
    elev_min integer,
    elev_max integer,
    elev_mean numeric,
    elev_std numeric,
    slope_min numeric,
    slope_max numeric,
    slope_mean numeric,
    slope_std numeric,
    rain_min integer,
    rain_max integer,
    rain_mean numeric,
    rain_std numeric,
    temp_min numeric,
    temp_max numeric,
    temp_mean numeric,
    temp_std numeric,
    "window" integer,
    shape_leng numeric,
    shape_area numeric,
    the_geom geometry(MultiPolygon,3035),
    id integer NOT NULL
);


ALTER TABLE catchments OWNER TO postgres;

--
-- Name: catchments_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE catchments_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE catchments_gid_seq OWNER TO postgres;

--
-- Name: catchments_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE catchments_gid_seq OWNED BY catchments.gid;


--
-- Name: catchments_id_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE catchments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE catchments_id_seq OWNER TO postgres;

--
-- Name: catchments_id_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE catchments_id_seq OWNED BY catchments.id;



-------------------------
---OTHER
---------------------------

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.2
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;


--
-- Name: mycatchment(numeric); Type: FUNCTION; Schema: ccm21; Owner: postgres
--

CREATE FUNCTION mycatchment(gid_ numeric) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	result RECORD;
	pri wso1_id%rowtype;
	resultcount RECORD;
	BEGIN
	    SELECT INTO result strahler FROM ccm21.riversegments where gid=gid_;
	    RAISE NOTICE 'result is %' ,result;
	    IF result.strahler=2 THEN 	
		RAISE NOTICE 'WSO_2 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso2_id =
			(select wso2_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso2_id =
			(select wso2_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=3 THEN 
		RAISE NOTICE 'WSO_3 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso3_id =
			(select wso3_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso3_id =
			(select wso3_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=4 THEN
		RAISE NOTICE 'WSO_4 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso4_id =
			(select wso4_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso4_id =
			(select wso4_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;			
	    ELSIF result.strahler=5 THEN
		RAISE NOTICE 'WSO_5 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso5_id =
			(select wso5_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso5_id =
			(select wso5_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=6 THEN
		RAISE NOTICE 'WSO_6 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso6_id =
			(select wso6_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso6_id =
			(select wso6_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		
	    ELSIF result.strahler=7 THEN
	    	RAISE NOTICE 'WSO_7 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso7_id =
			(select wso7_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso7_id =
			(select wso7_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;	
	    ELSIF result.strahler=8 THEN
	    	RAISE NOTICE 'WSO_8 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso8_id =
			(select wso8_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso8_id =
			(select wso8_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		    	
	    ELSIF result.strahler=9 THEN
	    	RAISE NOTICE 'WSO_9 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso9_id =
			(select wso9_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso9_id =
			(select wso9_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		    	
	    ELSIF result.strahler=10 THEN
	    	RAISE NOTICE 'WSO_10 used';
		SELECT INTO resultcount count(*) from  ccm21.catchments c  where wso10_id =
			(select wso10_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_);
		RAISE NOTICE 'number of primary catchments in the catchment =%',resultcount; 
		for pri in select wso1_id from ccm21.catchments c  where wso10_id =
			(select wso10_id from ccm21.riversegments r 
			join ccm21.catchments c on r.wso1_id=c.wso1_id 
			where r.gid=gid_) loop
		pri.wso1_id=CAST(pri.wso1_id AS int8);
		return next pri.wso1_id;
		end loop;
		return;		    		    		    		    	
	    ELSE RAISE NOTICE 'Strahler is larger than this function can handle !';
	    END IF;
	    RETURN;
	END;
	$$;


ALTER FUNCTION ccm21.mycatchment(gid_ numeric) OWNER TO postgres;

--
-- Name: FUNCTION mycatchment(gid_ numeric); Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON FUNCTION mycatchment(gid_ numeric) IS 'Uses the gid from ccm21.riversegments, checks strahler, and select the catchment accordingly, then returns all primary catchments from this larger catchment';


--
-- Name: mycatchment2(numeric); Type: FUNCTION; Schema: ccm21; Owner: postgres
--

CREATE FUNCTION mycatchment2(wso1_id_ numeric) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
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
	$$;


ALTER FUNCTION ccm21.mycatchment2(wso1_id_ numeric) OWNER TO postgres;

--
-- Name: FUNCTION mycatchment2(wso1_id_ numeric); Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON FUNCTION mycatchment2(wso1_id_ numeric) IS 'Uses the wso1_id from ccm21.riversegments, checks strahler, and select the catchment accordingly, then returns all primary catchments from this larger catchment';


--
-- Name: upstream_segments(numeric); Type: FUNCTION; Schema: ccm21; Owner: postgres
--

CREATE FUNCTION upstream_segments(gid_ numeric) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	gid_riversegments gid%ROWTYPE;
	rec_pfafstette_length RECORD;
	rec_riversegments ccm21.riversegments%ROWTYPE;
	-- pfafstette_chain_length int;
	pfafstette_max_chain_length int;
	pfafstette_value int8;
	BEGIN
	-- filling a new table with the results from a catchment
	
	DROP TABLE IF EXISTS ccm21.upstream_riversegments;
	CREATE TABLE ccm21.upstream_riversegments AS SELECT * FROM ccm21.riversegments
	where wso1_id in (SELECT  ccm21.mycatchment(gid_));
        ALTER TABLE ccm21.upstream_riversegments ADD CONSTRAINT pk_upstream_riversegments PRIMARY KEY (gid);

	-- pfafstette chain length
	--select into pfafstette_chain_length character_length(CAST(round(pfafstette) AS TEXT) 
	--	FROM ccm21.upstream_riversegments WHERE gid=gid_;
	-- RAISE NOTICE 'pfafstette chain length is %', pfafstette_chain_length;
	-- pfafstette max chain length in the selected  basin 
        select into pfafstette_max_chain_length max(character_length(CAST(round(pfafstette) AS TEXT)))
		FROM ccm21.upstream_riversegments; 
	-- pfafstette value
	-- the chain is lengthened to the pfafstette max chain length
	Update ccm21.upstream_riversegments set pfafstette = 
	floor(pfafstette)*power(10,(pfafstette_max_chain_length-character_length(CAST(floor(pfafstette) AS TEXT) )));  
	select into pfafstette_value CAST(round(pfafstette) AS int8) FROM ccm21.upstream_riversegments where gid=gid_;
	RAISE NOTICE 'pfafstette  is %', pfafstette_value;

        DELETE FROM ccm21.upstream_riversegments WHERE pfafstette < pfafstette_value; 
        -- extracting the riversegments corresponding to the basin
       
        for gid_riversegments in select gid from ccm21.upstream_riversegments order by gid loop
	        gid_riversegments.gid=CAST(gid_riversegments.gid AS int8);
		return next gid_riversegments.gid;
		end loop;
		return;	
	END;
$$;


ALTER FUNCTION ccm21.upstream_segments(gid_ numeric) OWNER TO postgres;

--
-- Name: FUNCTION upstream_segments(gid_ numeric); Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON FUNCTION upstream_segments(gid_ numeric) IS 'This function uses ccm21.mycatchment to get all the segments from a catchment and searches all segments with a pfafstetter higher than the segment in the bassin. The pfafstette are trucated to the level of the segment used as input in the function';


--
-- Name: upstream_segments2(numeric); Type: FUNCTION; Schema: ccm21; Owner: postgres
--

CREATE FUNCTION upstream_segments2(wso1_id_ numeric) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION ccm21.upstream_segments2(wso1_id_ numeric) OWNER TO postgres;

--
-- Name: FUNCTION upstream_segments2(wso1_id_ numeric); Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON FUNCTION upstream_segments2(wso1_id_ numeric) IS 'This function uses ccm21.mycatchment2 to get all the segments from a catchment and searches all segments with a pfafstetter higher than the segment in the bassin. The pfafstette are trucated to the level of the segment used as input in the function';


SET default_tablespace = '';

SET default_with_oids = false;


--
-- Name: catchments_temp; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE catchments_temp (
    gid integer DEFAULT nextval('catchments_gid_seq'::regclass) NOT NULL,
    wso1_id integer,
    wso2_id integer,
    wso3_id integer,
    wso4_id integer,
    wso5_id integer,
    wso6_id integer,
    wso7_id integer,
    wso8_id integer,
    wso9_id integer,
    wso10_id integer,
    wso11_id integer,
    wso_id integer,
    strahler smallint,
    feature_co smallint,
    nextdownid integer,
    y_centroid integer,
    x_centroid integer,
    x_inside_l integer,
    y_inside_l integer,
    xmin_laea integer,
    ymin_laea integer,
    xmax_laea integer,
    ymax_laea integer,
    area numeric,
    area_km2 numeric,
    perimeter integer,
    elev_min integer,
    elev_max integer,
    elev_mean numeric,
    elev_std numeric,
    slope_min numeric,
    slope_max numeric,
    slope_mean numeric,
    slope_std numeric,
    rain_min integer,
    rain_max integer,
    rain_mean numeric,
    rain_std numeric,
    temp_min numeric,
    temp_max numeric,
    temp_mean numeric,
    temp_std numeric,
    "window" integer,
    shape_leng numeric,
    shape_area numeric,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE catchments_temp OWNER TO postgres;

--
-- Name: coast; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE coast (
    gid integer NOT NULL,
    id numeric,
    wso_id numeric,
    system_cd character varying(1),
    sea_cd integer,
    sorting integer,
    ild_id integer,
    length numeric,
    fromnode integer,
    tonode integer,
    "window" integer,
    shape_leng numeric,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTILINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE coast OWNER TO postgres;

--
-- Name: coast_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE coast_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE coast_gid_seq OWNER TO postgres;

--
-- Name: coast_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE coast_gid_seq OWNED BY coast.gid;


--
-- Name: islands; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE islands (
    gid integer NOT NULL,
    id double precision,
    name character varying(100),
    lge_id character varying(2),
    int_name character varying(100),
    xmin_laea integer,
    ymin_laea integer,
    xmax_laea integer,
    ymax_laea integer,
    area_m double precision,
    perimeter_ double precision,
    hdm_id character varying(1),
    sea_id integer,
    coast_sort integer,
    coast_dist double precision,
    island_sor integer,
    shape_leng numeric,
    shape_area numeric,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE islands OWNER TO postgres;

--
-- Name: islands_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE islands_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE islands_gid_seq OWNER TO postgres;

--
-- Name: islands_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE islands_gid_seq OWNED BY islands.gid;


--
-- Name: lakes; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE lakes (
    gid integer NOT NULL,
    id numeric,
    name character varying(100),
    lge_id character varying(2),
    wso_id numeric,
    "window" integer,
    area numeric,
    perimeter integer,
    upstream_a numeric,
    system_cd character varying(1),
    sea_cd integer,
    comm_cd integer,
    pfafstette numeric,
    updated_by character varying(15),
    updated_wh date,
    lke_type character varying(1),
    altitude integer,
    shape_leng numeric,
    shape_area numeric,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE lakes OWNER TO postgres;

--
-- Name: lakes_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE lakes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lakes_gid_seq OWNER TO postgres;

--
-- Name: lakes_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE lakes_gid_seq OWNED BY lakes.gid;


--
-- Name: mainrivers; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE mainrivers (
    gid integer NOT NULL,
    id integer,
    wso_id integer,
    pfafstette double precision,
    maindrain_ smallint,
    int_name character varying(200),
    "window" integer,
    main_per_w character varying(1),
    shape_leng numeric,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTILINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE mainrivers OWNER TO postgres;

--
-- Name: mainrivers_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE mainrivers_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mainrivers_gid_seq OWNER TO postgres;

--
-- Name: mainrivers_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE mainrivers_gid_seq OWNED BY mainrivers.gid;


--
-- Name: model_mod; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE model_mod (
    mod_id integer NOT NULL,
    mod_name character varying(30) NOT NULL,
    mod_date date,
    mod_description text NOT NULL,
    mod_location character varying(25),
    mod_formula text
);


ALTER TABLE model_mod OWNER TO postgres;

--
-- Name: COLUMN model_mod.mod_location; Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON COLUMN model_mod.mod_location IS 'Geographical area to which the model is applied, should be consistent with europe.wso';


--
-- Name: model_mod_mod_id_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE model_mod_mod_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE model_mod_mod_id_seq OWNER TO postgres;

--
-- Name: model_mod_mod_id_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE model_mod_mod_id_seq OWNED BY model_mod.mod_id;


--
-- Name: namedrivers; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE namedrivers (
    gid integer NOT NULL,
    id integer,
    name character varying(100),
    lge_id character varying(2),
    int_name character varying(100),
    pfafstette integer,
    wso_id integer,
    "window" smallint,
    shape_leng numeric,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTILINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE namedrivers OWNER TO postgres;

--
-- Name: namedrivers_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE namedrivers_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE namedrivers_gid_seq OWNER TO postgres;

--
-- Name: namedrivers_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE namedrivers_gid_seq OWNED BY namedrivers.gid;


--
-- Name: resultmodel; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE resultmodel (
    res_id integer NOT NULL,
    res_wso1_id integer,
    res_riversegmentgid integer,
    res_value double precision,
    res_mod_id integer
);


ALTER TABLE resultmodel OWNER TO postgres;

--
-- Name: resultmodel_res_id_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE resultmodel_res_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE resultmodel_res_id_seq OWNER TO postgres;

--
-- Name: resultmodel_res_id_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE resultmodel_res_id_seq OWNED BY resultmodel.res_id;


--
-- Name: rivernodes; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE rivernodes (
    gid integer NOT NULL,
    id integer,
    wso_id integer,
    source character varying(1),
    len_tom integer,
    num_seg integer,
    elev integer,
    x_laea integer,
    y_laea integer,
    "window" smallint,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE rivernodes OWNER TO postgres;

--
-- Name: rivernodes_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE rivernodes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rivernodes_gid_seq OWNER TO postgres;

--
-- Name: rivernodes_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE rivernodes_gid_seq OWNED BY rivernodes.gid;


--
-- Name: riversegments; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE riversegments (
    gid integer NOT NULL,
    wso1_id integer,
    wso_id integer,
    rvr_id integer,
    fromnode integer,
    tonode integer,
    strahler smallint,
    pfafstette numeric,
    nextdownid integer,
    longpath character varying(1),
    maindrain_ smallint,
    maindrain1 smallint,
    length integer,
    cum_len integer,
    pixels_100 integer,
    catchment_ numeric,
    cont_pixel integer,
    drain_km2 integer,
    alt_gradie numeric,
    burned integer,
    confidence integer,
    "window" smallint,
    shape_leng numeric,
    the_geom geometry,
    cum_len_sea numeric,
    c_height numeric,
    c_score numeric,
    nbdams numeric,
    cs_height numeric,
    cs_nbdams numeric,
    cs_score numeric,
    summer numeric,
    winter numeric,
    catchment_area numeric,
    artificial_surfaces_11_13 numeric,
    artificial_vegetated_14 numeric,
    arable_land_21 numeric,
    permanent_crops_22 numeric,
    pastures_23 numeric,
    heterogeneous_agricultural_24 numeric,
    forest_31 numeric,
    natural_32_33 numeric,
    wetlands_4 numeric,
    inland_waterbodies_51 numeric,
    marine_water_52 numeric,
    up_catchment_area numeric,
    up_art_11_13 numeric,
    up_art_14 numeric,
    up_arable_21 numeric,
    up_permcrop_22 numeric,
    up_pasture_23 numeric,
    up_hetagr_24 numeric,
    up_forest_31 numeric,
    up_natural_32_33 numeric,
    up_wetlands_4 numeric,
    up_inwat_51 numeric,
    up_marwat_52 numeric,
    distance_source numeric,
    shree numeric,
    scheid numeric,
    distance_relative numeric,
    up_c_area numeric,
    uga numeric,
    c_area numeric,
    up_area numeric,
    slope_mean numeric,
    rain_mean numeric,
    temp_mean numeric,
    elev_mean numeric,
    st_codecsp character varying(8),
    non_calc_surf numeric,
    very_calc_surf numeric,
    mod_calc_surf numeric,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTILINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE riversegments OWNER TO postgres;

--
-- Name: COLUMN riversegments.catchment_area; Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON COLUMN riversegments.catchment_area IS 'area of the unit basin where upstream node are not calculated';


--
-- Name: COLUMN riversegments.up_catchment_area; Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON COLUMN riversegments.up_catchment_area IS 'area calculated from downtream node see R script which is runned on all up_blabla columns as it not calculated on strahler rank 1 (most upstream basins)';


--
-- Name: COLUMN riversegments.up_c_area; Type: COMMENT; Schema: ccm21; Owner: postgres
--

COMMENT ON COLUMN riversegments.up_c_area IS 'sum area of the unit basins from upstream node including this segment catchment surface';


--
-- Name: seaoutlets; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE seaoutlets (
    gid integer NOT NULL,
    wso_id integer,
    strahler integer,
    name character varying(100),
    sorting integer,
    area_km2 numeric,
    system_cd character varying(1),
    sea_cd smallint,
    comm_cd integer,
    xmin_laea integer,
    ymin_laea integer,
    xmax_laea integer,
    ymax_laea integer,
    ild_id integer,
    "window" smallint,
    shape_leng numeric,
    shape_area numeric,
    the_geom geometry,
    area_cd character varying(3),
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE seaoutlets OWNER TO postgres;

--
-- Name: seaoutlets_gid_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE seaoutlets_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seaoutlets_gid_seq OWNER TO postgres;

--
-- Name: seaoutlets_gid_seq; Type: SEQUENCE OWNED BY; Schema: ccm21; Owner: postgres
--

ALTER SEQUENCE seaoutlets_gid_seq OWNED BY seaoutlets.gid;


--
-- Name: taux_etagement_id_seq; Type: SEQUENCE; Schema: ccm21; Owner: postgres
--

CREATE SEQUENCE taux_etagement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE taux_etagement_id_seq OWNER TO postgres;

--
-- Name: temp_rhone; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE temp_rhone (
    id integer NOT NULL,
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE temp_rhone OWNER TO postgres;

--
-- Name: temp_western; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE temp_western (
    gid integer,
    wso1_id integer,
    wso_id integer,
    rvr_id integer,
    fromnode integer,
    tonode integer,
    strahler smallint,
    pfafstette numeric,
    nextdownid integer,
    longpath character varying(1),
    maindrain_ smallint,
    maindrain1 smallint,
    length integer,
    cum_len integer,
    pixels_100 integer,
    catchment_ numeric,
    cont_pixel integer,
    drain_km2 integer,
    alt_gradie numeric,
    burned integer,
    confidence integer,
    "window" smallint,
    shape_leng numeric,
    the_geom geometry,
    cum_len_sea numeric,
    c_height numeric,
    c_score numeric,
    nbdams numeric,
    cs_height numeric,
    cs_nbdams numeric,
    cs_score numeric,
    summer numeric,
    winter numeric,
    catchment_area numeric,
    artificial_surfaces_11_13 numeric,
    artificial_vegetated_14 numeric,
    arable_land_21 numeric,
    permanent_crops_22 numeric,
    pastures_23 numeric,
    heterogeneous_agricultural_24 numeric,
    forest_31 numeric,
    natural_32_33 numeric,
    wetlands_4 numeric,
    inland_waterbodies_51 numeric,
    marine_water_52 numeric,
    up_catchment_area numeric,
    up_art_11_13 numeric,
    up_art_14 numeric,
    up_arable_21 numeric,
    up_permcrop_22 numeric,
    up_pasture_23 numeric,
    up_hetagr_24 numeric,
    up_forest_31 numeric,
    up_natural_32_33 numeric,
    up_wetlands_4 numeric,
    up_inwat_51 numeric,
    up_marwat_52 numeric,
    distance_source numeric,
    shree numeric,
    scheid numeric,
    distance_relative numeric,
    up_c_area numeric,
    uga numeric,
    c_area numeric,
    up_area numeric,
    slope_mean numeric,
    rain_mean numeric,
    temp_mean numeric,
    elev_mean numeric,
    st_codecsp character varying(8),
    res_id integer,
    res_wso1_id integer,
    res_riversegmentgid integer,
    res_value double precision,
    res_mod_id integer,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTILINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3035))
);


ALTER TABLE temp_western OWNER TO postgres;

--
-- Name: upstream_riversegments; Type: TABLE; Schema: ccm21; Owner: postgres
--

CREATE TABLE upstream_riversegments (
    gid integer NOT NULL,
    wso1_id integer,
    wso_id integer,
    rvr_id integer,
    fromnode integer,
    tonode integer,
    strahler smallint,
    pfafstette numeric,
    nextdownid integer,
    longpath character varying(1),
    maindrain_ smallint,
    maindrain1 smallint,
    length integer,
    cum_len integer,
    pixels_100 integer,
    catchment_ numeric,
    cont_pixel integer,
    drain_km2 integer,
    alt_gradie numeric,
    burned integer,
    confidence integer,
    "window" smallint,
    shape_leng numeric,
    the_geom geometry,
    cum_len_sea numeric,
    c_height numeric,
    c_score numeric,
    nbdams numeric,
    cs_height numeric,
    cs_nbdams numeric,
    cs_score numeric,
    summer numeric,
    winter numeric,
    catchment_area numeric,
    artificial_surfaces_11_13 numeric,
    artificial_vegetated_14 numeric,
    arable_land_21 numeric,
    permanent_crops_22 numeric,
    pastures_23 numeric,
    heterogeneous_agricultural_24 numeric,
    forest_31 numeric,
    natural_32_33 numeric,
    wetlands_4 numeric,
    inland_waterbodies_51 numeric,
    marine_water_52 numeric,
    up_catchment_area numeric,
    up_art_11_13 numeric,
    up_art_14 numeric,
    up_arable_21 numeric,
    up_permcrop_22 numeric,
    up_pasture_23 numeric,
    up_hetagr_24 numeric,
    up_forest_31 numeric,
    up_natural_32_33 numeric,
    up_wetlands_4 numeric,
    up_inwat_51 numeric,
    up_marwat_52 numeric,
    distance_source numeric,
    shree numeric,
    scheid numeric,
    distance_relative numeric,
    up_c_area numeric,
    uga numeric,
    c_area numeric,
    up_area numeric,
    slope_mean numeric,
    rain_mean numeric,
    temp_mean numeric,
    elev_mean numeric,
    st_codecsp character varying(8),
    non_calc_surf numeric,
    very_calc_surf numeric,
    mod_calc_surf numeric
);


ALTER TABLE upstream_riversegments OWNER TO postgres;

--
-- Name: catchments gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY catchments ALTER COLUMN gid SET DEFAULT nextval('catchments_gid_seq'::regclass);


--
-- Name: catchments id; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY catchments ALTER COLUMN id SET DEFAULT nextval('catchments_id_seq'::regclass);


--
-- Name: coast gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY coast ALTER COLUMN gid SET DEFAULT nextval('coast_gid_seq'::regclass);


--
-- Name: islands gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY islands ALTER COLUMN gid SET DEFAULT nextval('islands_gid_seq'::regclass);


--
-- Name: lakes gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY lakes ALTER COLUMN gid SET DEFAULT nextval('lakes_gid_seq'::regclass);


--
-- Name: mainrivers gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY mainrivers ALTER COLUMN gid SET DEFAULT nextval('mainrivers_gid_seq'::regclass);


--
-- Name: model_mod mod_id; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY model_mod ALTER COLUMN mod_id SET DEFAULT nextval('model_mod_mod_id_seq'::regclass);


--
-- Name: namedrivers gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY namedrivers ALTER COLUMN gid SET DEFAULT nextval('namedrivers_gid_seq'::regclass);


--
-- Name: resultmodel res_id; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY resultmodel ALTER COLUMN res_id SET DEFAULT nextval('resultmodel_res_id_seq'::regclass);


--
-- Name: rivernodes gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY rivernodes ALTER COLUMN gid SET DEFAULT nextval('rivernodes_gid_seq'::regclass);


--
-- Name: seaoutlets gid; Type: DEFAULT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY seaoutlets ALTER COLUMN gid SET DEFAULT nextval('seaoutlets_gid_seq'::regclass);


--
-- Name: riversegments c_pk_gid_riversegments; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY riversegments
    ADD CONSTRAINT c_pk_gid_riversegments PRIMARY KEY (gid);


--
-- Name: temp_rhone c_pk_id; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY temp_rhone
    ADD CONSTRAINT c_pk_id PRIMARY KEY (id);


--
-- Name: coast coast_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY coast
    ADD CONSTRAINT coast_pkey PRIMARY KEY (gid);


--
-- Name: islands islands_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY islands
    ADD CONSTRAINT islands_pkey PRIMARY KEY (gid);


--
-- Name: lakes lakes_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY lakes
    ADD CONSTRAINT lakes_pkey PRIMARY KEY (gid);


--
-- Name: mainrivers mainrivers_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY mainrivers
    ADD CONSTRAINT mainrivers_pkey PRIMARY KEY (gid);


--
-- Name: model_mod model_mod_mod_name_key; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY model_mod
    ADD CONSTRAINT model_mod_mod_name_key UNIQUE (mod_name);


--
-- Name: model_mod model_mod_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY model_mod
    ADD CONSTRAINT model_mod_pkey PRIMARY KEY (mod_id);


--
-- Name: namedrivers namedrivers_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY namedrivers
    ADD CONSTRAINT namedrivers_pkey PRIMARY KEY (gid);


--
-- Name: upstream_riversegments pk_upstream_riversegments; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY upstream_riversegments
    ADD CONSTRAINT pk_upstream_riversegments PRIMARY KEY (gid);


--
-- Name: resultmodel resultmodel_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY resultmodel
    ADD CONSTRAINT resultmodel_pkey PRIMARY KEY (res_id);


--
-- Name: rivernodes rivernodes_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY rivernodes
    ADD CONSTRAINT rivernodes_pkey PRIMARY KEY (gid);


--
-- Name: seaoutlets seaoutlets_pkey; Type: CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY seaoutlets
    ADD CONSTRAINT seaoutlets_pkey PRIMARY KEY (gid);


--
-- Name: indexcatchments_wso10_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso10_id ON catchments USING btree (wso10_id);


--
-- Name: indexcatchments_wso1_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso1_id ON catchments USING btree (wso1_id);


--
-- Name: indexcatchments_wso2_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso2_id ON catchments USING btree (wso2_id);


--
-- Name: indexcatchments_wso3_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso3_id ON catchments USING btree (wso3_id);


--
-- Name: indexcatchments_wso4_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso4_id ON catchments USING btree (wso4_id);


--
-- Name: indexcatchments_wso5_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso5_id ON catchments USING btree (wso5_id);


--
-- Name: indexcatchments_wso6_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso6_id ON catchments USING btree (wso6_id);


--
-- Name: indexcatchments_wso7_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso7_id ON catchments USING btree (wso7_id);


--
-- Name: indexcatchments_wso8_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso8_id ON catchments USING btree (wso8_id);


--
-- Name: indexcatchments_wso9_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso9_id ON catchments USING btree (wso9_id);


--
-- Name: indexcatchments_wso_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexcatchments_wso_id ON catchments USING btree (wso_id);


--
-- Name: indexriversegments_sp; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexriversegments_sp ON riversegments USING gist (the_geom);


--
-- Name: indexriversegments_wso1_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexriversegments_wso1_id ON riversegments USING btree (wso1_id);


--
-- Name: indexriversegments_wso_id; Type: INDEX; Schema: ccm21; Owner: postgres
--

CREATE INDEX indexriversegments_wso_id ON riversegments USING btree (wso_id);


--
-- Name: resultmodel c_fk_res_mod_id; Type: FK CONSTRAINT; Schema: ccm21; Owner: postgres
--

ALTER TABLE ONLY resultmodel
    ADD CONSTRAINT c_fk_res_mod_id FOREIGN KEY (res_mod_id) REFERENCES model_mod(mod_id);


--
-- PostgreSQL database dump complete
--

