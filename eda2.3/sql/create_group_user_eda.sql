-- Ticket #70 : rôles de groupe eda_admin / eda_read sur la base eda2.3 
-- ---------------------------------------------------------------------------

-- 1. Rôles de groupe (à exécuter une seule fois par base)
-- ---------------------------------------------------------------------------

CREATE ROLE eda_admin NOLOGIN;
CREATE ROLE eda_read NOLOGIN;
GRANT CONNECT ON DATABASE "eda2.3" TO eda_admin;
GRANT CONNECT ON DATABASE "eda2.3" TO eda_read;

ALTER DATABASE "eda2.3" OWNER TO eda_admin;

-- 2. Compte nominatif "marion" (nouveau compte restreint)
-- ---------------------------------------------------------------------------

CREATE ROLE marion WITH
NOSUPERUSER
CREATEDB
CREATEROLE
INHERIT
LOGIN
CONNECTION LIMIT -1;
ALTER ROLE marion WITH password '*****************';

GRANT eda_admin TO marion;

-- 3. Droits sur les schémas EDA pour
--    eda_read (lecture seule) et eda_admin (lecture/écriture complète)
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    eda_schemas text[] := ARRAY[
        'anglian', 'bd_map', 'bdoe', 'bdoe22', 'bdtopo_hydrographie', 'belge', 'ccm21',
        'dbeel', 'dbeel_nomenclature', 'dbeel_rivers', 'devalpomi',
        'ecoregion2003', 'eda_gerem', 'europe', 'european_wise2008', 'france',
        'geo', 'geobs', 'geobs22', 'geol', 'hauteur', 'ice', 'ice22', 'ireland', 'loire', 'montepomi',
        'oria', 'portugal', 'postgis', 'public', 'qgis', 'raster_width',
        'rht', 'roe', 'roe22', 'rsa', 'rsa_loire', 'spain', 'sudoang', 'sweden', 'temp_mulet',
        'tiger', 'tiger_data', 'topology'
    ];
    s text;
    rec record;
BEGIN
    FOREACH s IN ARRAY eda_schemas LOOP
        -- eda_read : lecture seule
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO eda_read', s);
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO eda_read', s);
        -- les futures tables peuvent être créées soit par "postgres" (scripts
        -- existants), soit par "eda_admin" (nouvel usage attendu) : on couvre
        -- les deux cas pour qu'elles restent lisibles par eda_read
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT SELECT ON TABLES TO eda_read', s
        );
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES FOR ROLE eda_admin IN SCHEMA %I GRANT SELECT ON TABLES TO eda_read', s
        );

        -- eda_admin : lecture/écriture complète
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO eda_admin', s);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO eda_admin', s);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO eda_admin', s);
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL PRIVILEGES ON TABLES TO eda_admin', s
        );
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I GRANT ALL PRIVILEGES ON SEQUENCES TO eda_admin', s
        );

    END LOOP;
END
$$;


