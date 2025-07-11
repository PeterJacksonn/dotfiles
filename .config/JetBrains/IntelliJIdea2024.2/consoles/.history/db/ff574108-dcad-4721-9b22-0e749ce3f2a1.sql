 

 
 
 
 
 
 
 
 
;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_above_works()
RETURNS TEXT
    LANGUAGE plpgsql AS $$
    BEGIN
        -- NO ABOVE WORKS NEEDED FOR NOW
        RETURN 'Above Works';
    END
    $$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_asset
    (
        object_name TEXT, point_name TEXT, db_addr TEXT, process TEXT
    )
    RETURNS TABLE
                (
                    asset TEXT,
                    overwritten TEXT
                )
    LANGUAGE plpgsql
AS
$$
DECLARE
    pump_pos INT;
    pump_num TEXT;
    pump_num_part TEXT;
    address_type TEXT;
    pump_acro TEXT;
BEGIN
    process := LOWER(process);
    object_name := LOWER(object_name);
    point_name := LOWER(point_name);
    overwritten := '';

    -- todo - this needs better filtering, think '%pump%sump%' should be tank (below)
    IF point_name LIKE '%pump%' OR (point_name LIKE '%pmp%' AND object_name LIKE '%pump%')
    THEN
        IF point_name LIKE '%pump%' THEN
            pump_acro = 'pump';
        ELSIF point_name LIKE '%pmp%' THEN
            pump_acro = 'pmp';
        END IF;
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION(pump_acro IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + LENGTH(pump_acro)));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+$' THEN
            asset := ('Pump ' || pump_num);
        ELSE
            asset := 'Pump';
        END IF;
    END IF;

    IF object_name LIKE '%pump%' AND process = 'water treatment works' AND asset NOT LIKE 'Pump%'
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Pump';
    END IF;

    -- Reservoirs
    IF object_name = 'conical_res' OR
        object_name = 'covered_res' OR
        object_name = 'res_diagnostic_grid' OR
        object_name = 'reservoir_grid' OR
        object_name = 'reservoirs_grid' OR
        object_name = 'reservoir_symbols_grid' OR
        object_name = 'res_level' OR
        object_name = 'res_security_grid"' OR
        object_name = 'res_security_table' OR
        object_name = 'res_sites_grid'
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Tank';
    END IF;


    -- Tank
    IF object_name LIKE '%tank%' OR point_name LIKE '%tank%'
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION('tank' IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + 4));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+[A-Za-z]?$' THEN
            asset := ('Tank ' || UPPER(pump_num));
        ELSE
            asset := 'Tank';
        END IF;
    END IF;

    -- Sump
    IF object_name LIKE '%sump%' OR point_name LIKE '%sump%'
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION('sump' IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + 4));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+[A-Za-z]?$' THEN
            asset := ('Sump ' || UPPER(pump_num));
        ELSE
            asset := 'Sump';
        END IF;
    END IF;

    -- Flow
    -- todo - if dbname contains word flow or acronyms & object_name IS NOT analog_value, asset = Flow -- so the same thing then.. ?
    IF (point_name LIKE '%flow%' OR
        point_name LIKE '%flw%')
            AND
        (object_name = 'analog_value' OR
            object_name = 'digital_text')
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Flow Meter';
    END IF;

    -- Pressure
    IF (point_name LIKE '%pressure%' OR
        point_name LIKE '%pr%' OR
        point_name LIKE '%pres%' OR
        point_name LIKE '%prss%')
            AND
        (object_name = 'analog_value' OR
            object_name = 'digital_text')
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Pressure Meter';
    END IF;

    -- Turbidity
    IF (point_name LIKE '%turbidity%' OR
        point_name LIKE '%turb%')
            AND
        (object_name = 'analog_value' OR
            object_name = 'digital_text')
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Turbidity Meter';
    END IF;

    -- Generator
    IF point_name LIKE '%generator%' OR
        object_name LIKE '%generator%'
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Generator';
    END IF;

    -- Spare
    IF point_name LIKE '%spare%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        address_type = SUBSTRING(db_addr, 1, 1);
        IF address_type = 'C' THEN
            asset := 'Character';
        ELSEIF address_type = 'B' THEN
            asset := 'Boolean';
        ELSEIF address_type = 'E' THEN
            asset := 'Analogue';
        ELSE
            -- todo - not sure what else should be asset := ed here, there's P and S to deal with
            asset := 'Spare';
        END IF;
    END IF;

    -- Busbar
    IF point_name LIKE '%busbar%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Busbar';
    END IF;

    -- Site
    IF point_name LIKE '%rtu%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'RTU';
    END IF;
    IF point_name LIKE '%plc%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'PLC';
    END IF;
    IF point_name LIKE '%ups%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'UPS';
    END IF;
    IF point_name LIKE '%telemetry%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Telemetry';
    END IF;
    IF point_name LIKE '%mains supply%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Mains Supply';
    END IF;
    IF point_name LIKE '%site power status flag%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Site Power Status Flag';
    END IF;
    IF point_name LIKE '%battery%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Battery';
    END IF;
    IF point_name LIKE '%battery charge%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Battery Charge';
    END IF;
    IF point_name LIKE '%firmware version%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Firmware Version';
    END IF;
    IF point_name LIKE '%signal strength%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Signal Strength';
    END IF;

    IF point_name LIKE '%intruder%' AND process = 'site' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Intruder';
    END IF;

    -- Vents
    IF point_name LIKE '%vent fan%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Vent Fan';
    END IF;
    IF point_name LIKE '%vent system%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Vent System';
    END IF;
    IF point_name LIKE '%ventilation panel%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Ventilation Panel';
    END IF;
    IF point_name LIKE '%vent stack%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Vent Stack';
    END IF;
    IF point_name LIKE '%intake vent fan%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Intake Vent Fan';
    END IF;
    IF point_name LIKE '%extract vent fan%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Extract Vent Fan';
    END IF;

    -- Ventilation Fans Numbered
    IF point_name LIKE '%ventilation fan%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION('ventilation fan' IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + 15));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+$' THEN
            asset := ('Ventilation Fan ' || pump_num);
        ELSE
            pump_num = (SPLIT_PART(pump_num_part, ' ', 2));
            IF pump_num ~ '^[0-9]+$' THEN
                asset := ('Ventilation Fan ' || pump_num);
            ELSE
                asset := 'Ventilation Fan';
            END IF;
        END IF;
    END IF;

    IF point_name LIKE '%gas store vent%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Gas Store Vent';
    END IF;

    -- Valves
    IF point_name LIKE '%tank vlv%' OR
        point_name LIKE '%valve%'
        --         point_name LIKE '%vlv%' OR  -> part of valves numbered
--         object_name LIKE '%valve%' -> part of valves numbered
    THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        asset := 'Valve';
    END IF;

    -- Valves Numbered
    IF point_name LIKE '%vlv%' OR point_name LIKE '%valve%' THEN
        IF point_name LIKE '%vlv%' THEN
            pump_acro = 'vlv';
        ELSIF point_name LIKE '%valve%' THEN
            pump_acro = 'valve';
        END IF;
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION(pump_acro IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + LENGTH(pump_acro)));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+$' THEN
            asset := ('Valve ' || pump_num);
        ELSE
            asset := 'Valve';
        END IF;
    END IF;

    -- Compressor (Numbered)
    IF point_name LIKE '%compressor%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION('compressor' IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + 10));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+$' THEN
            asset := ('Compressor ' || pump_num);
        ELSE
            asset := 'Compressor';
        END IF;
    END IF;

    -- Monitor / MON (Numbered)
    IF point_name LIKE '%monitor%' OR point_name ~* '\ymon\y' -- 'mon' as its own word
    THEN
        IF point_name LIKE '%monitor%' THEN
            pump_acro = 'monitor';
        ELSIF point_name ~* '\ymon\y' THEN
            pump_acro = 'mon';
        END IF;
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION(pump_acro IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + LENGTH(pump_acro)));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[0-9]+$' THEN
            asset := ('Monitor ' || pump_num);
        ELSE
            asset := 'Monitor';
        END IF;
    END IF;


    -- UV Reactor (Numbered)
    IF point_name LIKE '%uv reactor%' THEN
        IF asset IS NOT NULL THEN
            overwritten := overwritten || asset || ' ';
        END IF;
        pump_pos = POSITION('uv reactor' IN point_name);
        pump_num_part = TRIM(SUBSTRING(point_name, pump_pos + 10));
        pump_num = (SPLIT_PART(pump_num_part, ' ', 1));
        IF pump_num ~ '^[a-zA-Z]$' OR pump_num ~ '^\d+$' THEN
            asset := ('UV Reactor  ' || UPPER(pump_num));
        ELSE
            asset := 'UV Reactor';
        END IF;
    END IF;

    -- Unknown
    IF asset IS NULL THEN
        asset := 'Unknown';
    END IF;

    RETURN NEXT;
END
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_process
    (
        mimic_name TEXT, os_name TEXT, object_name TEXT, point_name TEXT
    )
    RETURNS TABLE
                (
                    process TEXT,
                    fail_flag TEXT
                )
    LANGUAGE plpgsql
AS
$$
BEGIN
    mimic_name := LOWER(mimic_name);
    os_name := LOWER(os_name);
    object_name := LOWER(object_name);
    point_name := LOWER(point_name);
    fail_flag := '';

    -- Dosing
    IF
        mimic_name LIKE '%chemical%' OR
            mimic_name LIKE '%dosing%' OR
            os_name LIKE '%chemical%' OR
            os_name LIKE '%dosing%' OR
            -- #
            mimic_name ~* 'ortho|sodium|phosphoric' OR
            os_name ~* 'ortho|sodium|phosphoric' OR
            -- #
            point_name LIKE '%dosing%' OR
            point_name LIKE '%cl2%' OR
            point_name LIKE '%sodium hypo%' OR
            point_name LIKE '%chlorine%'
    THEN
        process := 'Dosing';
    END IF;

    -- Treatment
    IF mimic_name LIKE '%treatment%' OR os_name LIKE '%treatment%' THEN
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Treatment';
    END IF;

    -- Abstraction
    IF mimic_name LIKE '%inlet%' OR
        os_name LIKE '%inlet%' OR
        mimic_name LIKE '%boreholes%' OR
        os_name LIKE '%boreholes%' OR
        point_name LIKE '%borehole%'
    THEN
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Abstraction';
    END IF;

    -- Distribution
    IF mimic_name LIKE '%booster%' OR
        os_name LIKE '%booster%' OR
        point_name LIKE '%booster%'
    THEN
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Distribution';
    END IF;

    -- SITE
    IF point_name LIKE '%site mains supply' OR
        point_name LIKE '%site power status flag%' OR
        point_name LIKE '%ostn mains supply%' OR
        point_name LIKE '%ostn battery%' OR
        point_name LIKE '%ostn battery charge%' OR
        point_name LIKE '%backup battery%' OR
        point_name LIKE '%firmware%' OR
        point_name LIKE '%signal strength%' OR
        point_name LIKE '%telemetry%' OR
        point_name LIKE '%incoming mains%' OR
        point_name LIKE '%spare%' OR
        point_name LIKE '%busbar%' OR
        point_name LIKE '%comms%' OR
        point_name LIKE '%watchdog%' OR
        point_name LIKE '%security%' OR
        point_name LIKE '%intruder%' OR
        point_name LIKE '%mains supply%' OR
        -- Generator
        object_name LIKE '%generator%' OR
        point_name LIKE '%generator%'
    THEN
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Site';
    END IF;

    -- Reservoirs
    -- todo think this should be if point_name like '%tank%' as well
    IF object_name LIKE '%tank%' OR
        object_name LIKE '%res_%' OR
        object_name LIKE '%_res%' -- I think this works
    THEN
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Storage';
    END IF;

    -- Sump
    IF object_name LIKE '%sump%' OR
        point_name LIKE '%sump%'
    THEN
        IF process IS NOT NULL THEN -- cant remember why this is here - think it was overwriting with the same process?: AND process <> 'Storage'
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Storage';
    END IF;

    -- Filtration
    IF object_name = 'filter' OR
        object_name = 'bio_filter' OR
        object_name = 'sand_filter' OR
        point_name LIKE '%filter%' OR -- this will get overwritten by 'pre sandfilter'
        point_name LIKE '%filtration%'
    THEN
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Filtration';
    END IF;


    if point_name like '%pre sandfilter%' and point_name like '%phosphate%'
    then
        IF process IS NOT NULL THEN -- TODO - probs put a check for if process is 'Filtration' - it will be set already from filtration section
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Dosing';
    END IF;

    if point_name like '%post sandfilter%' and point_name like '%phosphate%'
    then
        IF process IS NOT NULL THEN
            fail_flag := fail_flag || process || ' ';
        END IF;
        process := 'Dosing';
    END IF;


    -- LOWEST PRIORITY - so only set if process is still null, shouldn't overwrite any process ever
    IF process IS NULL
    THEN
        BEGIN
            IF mimic_name LIKE '%sps%' OR
                os_name LIKE '%sps%'
            THEN
                IF process IS NOT NULL THEN
                    fail_flag := fail_flag || process || ' ';
                END IF;
                process := 'Sewage Pumping Station';
            END IF;

            IF mimic_name LIKE '%stw%' OR
                os_name LIKE '%stw%'
            THEN
                IF process IS NOT NULL THEN
                    fail_flag := fail_flag || process || ' ';
                END IF;
                process := 'Sewage Treatment Works';
            END IF;

            IF mimic_name LIKE '%wtw%' OR
                os_name LIKE '%wtw%'
            THEN
                IF process IS NOT NULL THEN
                    fail_flag := fail_flag || process || ' ';
                END IF;
                process := 'Water Treatment Works';
            END IF;

            IF os_name LIKE '%ps%' and process <> 'Sewage Pumping Station' -- guessing check - stop overwrite
            THEN
                IF process IS NOT NULL THEN
                    fail_flag := fail_flag || process || ' ';
                END IF;
                process := 'Pumping Station';
            END IF;
        END;
    END IF;

    IF process IS NULL THEN
        process := 'Unknown';
    END IF;

    RETURN NEXT;
END
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_truncate_table(table_name TEXT)
    RETURNS void
    LANGUAGE plpgsql AS $$
BEGIN
EXECUTE 'TRUNCATE TABLE ' || quote_ident(table_name) || ' CASCADE';
END $$;
;-- -. . -..- - / . -. - .-. -.--
GRANT ALL
ON FUNCTION pnp_truncate_table(text) TO apisrv;
;-- -. . -..- - / . -. - .-. -.--
DROP TABLE pnp_mappings;
;-- -. . -..- - / . -. - .-. -.--
CREATE TABLE pnp_mappings
(
    db_point_addr    text NOT NULL,
    outstation_num   text NOT NULL,
    nexus_name      text NOT NULL,
    primary key (nexus_name, db_point_addr, outstation_num)
);
;-- -. . -..- - / . -. - .-. -.--
grant
    all
    on table pnp_mappings to apisrv;
;-- -. . -..- - / . -. - .-. -.--
CREATE TABLE pnp_outstations
(
    os_address                    text,
    os_name                       text,
    os_number                     text,
    nexus_name                    text,
    failure_db_bool               text,
    connection_status_db_mbit     text,
    command_status_db_mbit        text,
    auto_fallback_db_bool         text,
    config_status_db_mbit         text,
    maintenance_db_bool           text,
    connected_db_bool             text,
    site_activity_timeout_db_bool text,
    request_stage_status_db_mbit  text,
    out_of_contact_db_bool        text,
    primary key (nexus_name, os_number)
);
;-- -. . -..- - / . -. - .-. -.--
CREATE TABLE pnp_point_names
    (
        point_name TEXT NULL,
        db_addr TEXT NULL,
        server_name TEXT NULL,
        comment TEXT NULL,
        PRIMARY KEY (server_name, db_addr)
    );
;-- -. . -..- - / . -. - .-. -.--
GRANT
    ALL
    ON TABLE pnp_point_names TO apisrv;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_function
    (
        mimic_name TEXT, process TEXT, object_name TEXT, point_name TEXT, other_value TEXT, os_name TEXT
    )
    RETURNS TABLE
                (
                    function TEXT,
                    fail_flag TEXT
                )
    LANGUAGE plpgsql
AS
$$
BEGIN
    mimic_name := LOWER(mimic_name);
    other_value := LOWER(other_value);
    process := LOWER(process);
    object_name := LOWER(object_name);
    point_name := LOWER(point_name);
    os_name := LOWER(os_name);
    fail_flag := '';

    IF (mimic_name LIKE '%chemical%' OR mimic_name LIKE '%dosing%') AND process = 'dosing' THEN
        IF other_value LIKE '%coagulant' OR
            other_value LIKE '%coag%'
        THEN
            function := 'Coagulant';
        END IF;
    END IF;

    IF point_name LIKE '%cl2%' OR
        point_name LIKE '%chlorine%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Chlorine';
    END IF;

    IF point_name LIKE '%ortho%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Orthophosphoric';
    END IF;

    IF point_name LIKE '%sodium hypo dosing%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Hypochlorite';
    END IF;

    IF point_name LIKE '%hypo%' AND point_name LIKE '%tank%'
    THEN
        IF function IS NOT NULL AND function <> 'Hypochlorite' THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Hypochlorite';
    END IF;

    IF (point_name LIKE '%acid%' OR
        point_name LIKE '%alum%' OR
        point_name LIKE '%caustic%' OR
        point_name LIKE '%soda%')
            AND
        process = 'dosing'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Chemical';
    END IF;

    -- Pumps
    IF point_name LIKE '%pump%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        CASE
            WHEN point_name LIKE '%borehole pump%'
                THEN function := 'Borehole';
            WHEN point_name LIKE '%booster pump%'
                THEN function := 'Booster';
            WHEN point_name LIKE '%backwash pump%'
                THEN function := 'Backwash';

            -- todo - need to fix for when point_name is like: 120120PUMP HALL SUMP -- should this be sump or PUMP?
            -- fixme - for now done sump%pump and pump%sump -- this might work
            WHEN point_name LIKE '%sump%pump%'
                THEN function := 'Sump Pump';

            -- PUMP SUMP IN HERE - works better this way I think
            WHEN point_name LIKE '%pump%sump%'
                THEN function := 'Sump';

            ELSE function := 'Pump Set';
        END CASE;
    END IF;

    -- Sump
    --                          check Sump isn't already set from above
    IF object_name LIKE '%sump%' OR point_name LIKE '%sump%'
    THEN
        -- This *might* be right
        IF function IS NULL OR function <> 'Pump Set' AND function <> 'Sump Pump' AND function <> 'Sump'
        THEN
            IF function IS NOT NULL THEN
                fail_flag := fail_flag || function || ' ';
            END IF;
            function := 'Sump';
        END IF;
    END IF;

    -- Reservoirs
    -- todo - unless prefixed with a chemical, then this is overwritten..
    IF object_name LIKE '%reservoir%' THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Reservoir';
    END IF;

    -- Reservoir (again)
    IF (point_name LIKE '%reservoir' OR point_name LIKE '%res%') AND process = 'storage'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Reservoir';
    END IF;


    -- Generator
    IF object_name = 'generator' OR
        point_name LIKE '%generator%' OR
        point_name LIKE '%gen%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Power';
    END IF;

    -- Site -> Power
    IF point_name LIKE '%site mains supply%' OR
        point_name LIKE '%site power status flag%' OR
        point_name LIKE '%mains supply%' OR
        point_name LIKE '%ostn mains supply' OR -- this isnt needed
        point_name LIKE '%ostn battery' OR
        point_name LIKE '%ostn battery charge%' OR -- not needed
        point_name LIKE '%backup battery%' OR
        point_name LIKE '%incoming mains function%' OR
        point_name LIKE '%busbar%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Power';
    END IF;

    -- More Site -> Security
    IF point_name LIKE '%ostn watchdog%' OR
        point_name LIKE '%plc watchdog%' OR
        point_name LIKE '%rtu watchdog%' OR
        point_name LIKE '%site security%' OR
        point_name LIKE '%firmware%' OR
        point_name LIKE '%intruder%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Security';
    END IF;

    -- site x3 -> System
    IF point_name LIKE '%site communications%' OR
        point_name LIKE '%telemetry%' OR
        point_name LIKE '%signal strength%' OR
        point_name LIKE '%comms%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'System';
    END IF;

    -- Vents
    -- 'But no chemical identifier such as cl2/ortho', so just this?
    IF point_name LIKE '%ventilation fan%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Heating Ventilation Air Conditioning';
    END IF;

    IF point_name LIKE '%vent fan%' AND point_name LIKE '%chlorine%' -- already set above
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Chlorine';
    END IF;

    IF point_name LIKE '%vent fan%' AND point_name LIKE '%ortho%' -- already set above
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Orthophosphoric';
    END IF;

    -- Filter
    IF object_name LIKE '%filter%' AND point_name LIKE '%gac%' THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'GAC';
    END IF;

    -- Water Quality
    IF point_name LIKE '%filter%'
            AND
        (point_name LIKE '%press%' OR
            point_name LIKE '%pres%' OR
            point_name LIKE '%pressure%' OR
            point_name LIKE '%prss%' OR
            point_name LIKE '%pr%')
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Water Quality';
    END IF;

    -- Water Quality #2
    IF (point_name LIKE '%sldg trans pmp%' OR
        point_name LIKE '%sample pmp%' OR
        point_name LIKE '%saturator%' OR
        point_name LIKE '%saturated%')
--             point_name LIKE '%floculator%' -- TODO - this conflicts another rule, double check this (but think this will be the one to use)
            AND
        (process = 'water treatment works')
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Water Quality';
    END IF;

    -- Waste
    IF point_name LIKE '%ww rec tnk%' AND process = 'water treatment works'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Waste';
    END IF;

    -- Water Quality #3
    IF (point_name LIKE '%raw wtr ph%' OR
        point_name LIKE '%raw ph%' OR
        point_name LIKE '%ph%' OR
        point_name LIKE '%raw wtr turbidity%' OR
        point_name LIKE '%raw wtr turb%' OR
        point_name LIKE '%turbidity%' OR
        point_name LIKE '%raw wtr samp%' OR
        point_name LIKE '%raw water quality monitors%')
            AND
        (process = 'abstraction')
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Water Quality';
    END IF;

    -- Water Quality #3 todo - Brandon not sure
    IF point_name LIKE '%neutralisation%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Water Quality';
    END IF;

    --Spare
    IF point_name LIKE '%spare%' THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Spare';
    END IF;


    -- Scraper - No answer given yet
    IF point_name LIKE '%scraper'
            AND
        (process = 'sewage treatment works' OR process = 'sewage pumping station')
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Scraper(?)';
    END IF;

    -- Sedimentation
    IF (point_name LIKE '%sedimentation tank' AND process = 'sewage treatment works')
            OR
        (point_name LIKE '%sediment tank%')
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Sedimentation';
    END IF;

    -- TODO - priorities
    -- TANKS:
    -- (1st Priority) Security
    IF point_name LIKE '%contact tank%' AND process = 'water treatment works' AND os_name LIKE '%security%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Security';
    END IF;

    IF point_name LIKE '%tank security%' AND process = 'water treatment works'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Security';
    END IF;


    --(2nd Priority) Contact Tank
    IF point_name LIKE '%contact tank%'
    THEN
        -- can do and function <> 'Security' but there's other security like ostn watchdog
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Contact Tank';
    END IF;

    -- Aeration
    IF point_name LIKE '%aeration%' AND process = 'sewage treatment works'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Aeration';
    END IF;

    -- Waste
    IF point_name LIKE '%waste tank%' OR
        point_name LIKE '%waste water tank%' OR
        point_name LIKE '%waste wtr tank%' OR
        point_name LIKE '%sludge tank%' OR
        point_name LIKE '%washwtr tank%' OR
        point_name LIKE '%washwtr break tank%' OR
        point_name LIKE '%storm tank%' OR
        point_name LIKE '%storm storage tank%' OR
        point_name LIKE '%sldg trans pmp%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := ' Waste';
    END IF;

    -- Backwash
    IF point_name LIKE '%backwash tank%' OR
        point_name LIKE '%backwash return tank%' OR
        point_name LIKE '%backwash balance tank%' OR
        point_name LIKE '%backwash water tank%' OR
        point_name LIKE '%backwash trigger tank%'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Backwash';
    END IF;

    -- Contact
    IF point_name LIKE '%balance tank' OR
        point_name LIKE '%balancing tank%'
                AND point_name NOT LIKE '%backwash balance tank%' -- Brandon says backwash is priority so don't overwrite it
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Contact';
    END IF;

    -- Floculator
    IF point_name LIKE '%floculator%' AND process = 'water treatment works'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Floculator';
    END IF;

    -- Disinfection
    IF point_name LIKE '%sulphuric%' AND process = 'water treatment works'
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Disinfection';
    END IF;

    -- Digestion
    IF (point_name LIKE '%digester%')
            AND
        (process = 'water treatment works' OR process = 'treatment')
    THEN
        IF function IS NOT NULL THEN
            fail_flag := fail_flag || function || ' ';
        END IF;
        function := 'Digester';
    END IF;

    -- No Clear Indication
    IF function IS NULL THEN
        function := 'Unknown';
    END IF;

    RETURN NEXT;
END
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value,
                   (mimic_cte).os_name
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value,
                   (process_cte.process_result).os_name
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,
                    mimic_cte.os_name,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value,
                   (process_cte.process_result).os_name
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
grant
    all
    on table pnp_outstations to apisrv;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_works
    (
        mapped_name TEXT,
        failure_dbbool_name TEXT,
        connectionstat TEXT,
        commandstat TEXT,
        autofallback TEXT,
        configstat TEXT,
        maintenancedbbool TEXT,
        connecteddbbool TEXT,
        siteactivity TEXT,
        requeststage TEXT,
        outofcontact TEXT,
        point_name TEXT,
        server_name TEXT,
        comment TEXT
    )
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    full_works TEXT;
    site_id1 TEXT;
    site_id2 TEXT;
    site_name TEXT;
    part TEXT;
    final_works TEXT = '';
BEGIN
    full_works := COALESCE(
            mapped_name, failure_dbbool_name, connectionstat,
            commandstat, autofallback, configstat, maintenancedbbool,
            connecteddbbool, siteactivity, requeststage, outofcontact,
            'Unknown'
                  );

    -- If no works found, check 'comment' for RTL,
    -- if 'rtl' is in it, then take the first 6 numbers from the dbpoint and match to os_name, along with server = nexus_name
    IF full_works = 'Unknown' AND LOWER(comment) LIKE '%rtl%' THEN
        SELECT os_name
            INTO full_works
            FROM pnp_outstations
            WHERE
                os_name LIKE SUBSTRING(point_name, 1, 6) || '%'
                AND server_name = nexus_name;
        IF full_works IS NULL THEN
            full_works = 'Unknown';
        END IF;
    END IF;


    IF full_works != 'Unknown' THEN
        -- space after first siteID
        site_id1 := SUBSTRING(full_works, 1, 6) || ' ';

        -- Check if any of the next 6 characters (7th to 12th) are numeric
        IF SUBSTRING(full_works, 7, 6) ~ '[0-9]' THEN
            -- If any numeric characters found, insert a space after the 12th character
            site_name := INITCAP(SUBSTRING(full_works FROM 13));
            site_id2 := SUBSTRING(full_works, 7, 6) || ' ';
            full_works := site_id1 || site_id2 || site_name;
        ELSE
            -- no second id
            site_name := INITCAP(SUBSTRING(full_works FROM 7));
            full_works := site_id1 || site_name;
        END IF;


        -- uppercase matches of stw etc.
        FOREACH part IN ARRAY STRING_TO_ARRAY(full_works, ' ')
            LOOP
            -- these will need to be confirmed, there are some i've added and some i haven't that not fully sure on:
            --- Vw -> Barrington West End Vw -> Think this is View so not gonna do VW
            -- same for St -> Street?
                IF LOWER(part) IN ('sq', 'tsf', 'ostn', 'stw', 'sbr', 'sps', 'plc', 'rsps', 'gbt', 'ps', 'wtw', 'edm', 'res', 'abp', 'rtu',
                                   'cp', 'azp', 'cso', 'os', 'it', 'drv', 'est', 'pl', 'in', 'uhf', 'wrc', 'prv', 'dbn',
                                   'opp', 'fm') OR LOWER(part) LIKE ('plc%') THEN
                    part := UPPER(part);
                    final_works := final_works || part || ' ';
                ELSE
                    final_works := final_works || part || ' ';
                END IF;
            END LOOP;
        final_works := RTRIM(final_works);
        RETURN final_works;

    END IF;
    RETURN full_works;

END
$$;
;-- -. . -..- - / . -. - .-. -.--
select * from pnp_outstations;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_works
    (
        mapped_name TEXT,
        failure_dbbool_name TEXT,
        connectionstat TEXT,
        commandstat TEXT,
        autofallback TEXT,
        configstat TEXT,
        maintenancedbbool TEXT,
        connecteddbbool TEXT,
        siteactivity TEXT,
        requeststage TEXT,
        outofcontact TEXT,
        point_name TEXT,
        server_name TEXT,
        comment TEXT
    )
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    full_works TEXT;
    site_id1 TEXT;
    site_id2 TEXT;
    site_name TEXT;
    part TEXT;
    final_works TEXT = '';
BEGIN
    full_works := COALESCE(
            mapped_name, failure_dbbool_name, connectionstat,
            commandstat, autofallback, configstat, maintenancedbbool,
            connecteddbbool, siteactivity, requeststage, outofcontact,
            'Unknown'
                  );

    -- If no works found, check 'comment' for RTL,
    -- if 'rtl' is in it, then take the first 6 numbers from the dbpoint and match to os_name, along with server = nexus_name
    IF full_works = 'Unknown' AND LOWER(comment) LIKE '%rtl%' THEN
        SELECT os_name
            INTO full_works
            FROM public.pnp_outstations
            WHERE
                os_name LIKE SUBSTRING(point_name, 1, 6) || '%'
                AND server_name = nexus_name;
        IF full_works IS NULL THEN
            full_works = 'Unknown';
        END IF;
    END IF;


    IF full_works != 'Unknown' THEN
        -- space after first siteID
        site_id1 := SUBSTRING(full_works, 1, 6) || ' ';

        -- Check if any of the next 6 characters (7th to 12th) are numeric
        IF SUBSTRING(full_works, 7, 6) ~ '[0-9]' THEN
            -- If any numeric characters found, insert a space after the 12th character
            site_name := INITCAP(SUBSTRING(full_works FROM 13));
            site_id2 := SUBSTRING(full_works, 7, 6) || ' ';
            full_works := site_id1 || site_id2 || site_name;
        ELSE
            -- no second id
            site_name := INITCAP(SUBSTRING(full_works FROM 7));
            full_works := site_id1 || site_name;
        END IF;


        -- uppercase matches of stw etc.
        FOREACH part IN ARRAY STRING_TO_ARRAY(full_works, ' ')
            LOOP
            -- these will need to be confirmed, there are some i've added and some i haven't that not fully sure on:
            --- Vw -> Barrington West End Vw -> Think this is View so not gonna do VW
            -- same for St -> Street?
                IF LOWER(part) IN ('sq', 'tsf', 'ostn', 'stw', 'sbr', 'sps', 'plc', 'rsps', 'gbt', 'ps', 'wtw', 'edm', 'res', 'abp', 'rtu',
                                   'cp', 'azp', 'cso', 'os', 'it', 'drv', 'est', 'pl', 'in', 'uhf', 'wrc', 'prv', 'dbn',
                                   'opp', 'fm') OR LOWER(part) LIKE ('plc%') THEN
                    part := UPPER(part);
                    final_works := final_works || part || ' ';
                ELSE
                    final_works := final_works || part || ' ';
                END IF;
            END LOOP;
        final_works := RTRIM(final_works);
        RETURN final_works;

    END IF;
    RETURN full_works;

END
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_other_value ON mimic_usage_data (other_value);
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_composite_db_other ON mimic_usage_data (other_value, db_addr);
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_server_other_combined ON mimic_usage_data (other_value, SPLIT_PART(mimic_name, '_', 1));
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_object_name_lower ON mimic_usage_data (LOWER(object_name));
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_db_other_layout ON mimic_usage_data (other_value, db_addr, LOWER(object_name));
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_score ON mimic_usage_data (other_value, db_addr, SPLIT_PART(mimic_name, '_', 1));
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_mimic_name ON mimic_usage_data (mimic_name);
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_name_gin ON mimic_usage_data USING GIN (mimic_name gin_trgm_ops);
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);
    -- TODO - each thing needs to go down in the amount of score it adds
    -- so say layout + 1000
    -- similarity is between 0-1, so this should *10 so its 10-100
    -- then the rest can lower by 10 for each one
    -- this should prioritise things well if more rules are needed/added

    IF object_name LIKE '%layout%' THEN
        score := score + 100;
    END IF;

--  Add the similarity
--     score := score + ((word_similarity(mimic_name, works)));
    score := score + ((similarity(mimic_name, works)));

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
select version();
;-- -. . -..- - / . -. - .-. -.--
select * from pg_extension where extname = 'pg_trgm';
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);
    -- TODO - each thing needs to go down in the amount of score it adds
    -- so say layout + 1000
    -- similarity is between 0-1, so this should *10 so its 10-100
    -- then the rest can lower by 10 for each one
    -- this should prioritise things well if more rules are needed/added

    IF object_name LIKE '%layout%' THEN
        score := score + 100;
    END IF;

--  Add the similarity
    score := score + ((word_similarity(mimic_name, works, 0.3)));

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);
    -- TODO - each thing needs to go down in the amount of score it adds
    -- so say layout + 1000
    -- similarity is between 0-1, so this should *10 so its 10-100
    -- then the rest can lower by 10 for each one
    -- this should prioritise things well if more rules are needed/added

    IF object_name LIKE '%layout%' THEN
        score := score + 100;
    END IF;

--  Add the similarity
    score := score + ((word_similarity(mimic_name, works)));

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
SELECT proname FROM pg_proc WHERE proname LIKE '%similarity%';
;-- -. . -..- - / . -. - .-. -.--
SELECT similarity('hello', 'hola');
;-- -. . -..- - / . -. - .-. -.--
SELECT similarity('asdfhello', 'hola');
;-- -. . -..- - / . -. - .-. -.--
SHOW search_path;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);
    -- TODO - each thing needs to go down in the amount of score it adds
    -- so say layout + 1000
    -- similarity is between 0-1, so this should *10 so its 10-100
    -- then the rest can lower by 10 for each one
    -- this should prioritise things well if more rules are needed/added

    IF object_name LIKE '%layout%' THEN
        score := score + 100;
    END IF;

--  Add the similarity
    score := score + ((similarity(mimic_name::text, works::text)));

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);
    -- TODO - each thing needs to go down in the amount of score it adds
    -- so say layout + 1000
    -- similarity is between 0-1, so this should *10 so its 10-100
    -- then the rest can lower by 10 for each one
    -- this should prioritise things well if more rules are needed/added

    IF object_name LIKE '%layout%' THEN
        score := score + 100;
    END IF;

--  Add the similarity
    score := score + ((similarity(mimic_name, works)));

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,
                    mimic_cte.os_name,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value,
                   os_name
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
CREATE EXTENSION pg_trgm;
;-- -. . -..- - / . -. - .-. -.--
similarity('hello', 'testing');
;-- -. . -..- - / . -. - .-. -.--
select similarity('hello', 'testing');
;-- -. . -..- - / . -. - .-. -.--
select similarity('hello', 'hi');
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);
    -- TODO - each thing needs to go down in the amount of score it adds
    -- so say layout + 1000
    -- similarity is between 0-1, so this should *10 so its 10-100
    -- then the rest can lower by 10 for each one
    -- this should prioritise things well if more rules are needed/added

    IF object_name LIKE '%layout%' THEN
        score := score + 100;
    END IF;

--  Add the similarity
--     score := score + ((similarity(mimic_name, works)));
    score := score + similarity(COALESCE(mimic_name, '')::text, COALESCE(works, '')::text);

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
select similarity('hello', 'hello');
;-- -. . -..- - / . -. - .-. -.--
score = score + similarity(mimic_name, works);
;-- -. . -..- - / . -. - .-. -.--
score := score + similarity(mimic_name, works);
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
    sim_score REAL;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);

    IF object_name LIKE '%layout%' THEN
        score := score + 1000;
    END IF;

--  Add the similarity
    sim_score := similarity(mimic_name, works) * 100;

    score := score + sim_score;

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
DROP MATERIALIZED VIEW IF EXISTS pnp_point_hierarchy_view;
;-- -. . -..- - / . -. - .-. -.--
sim_score := similarity(mimic_name, works) * 100;
;-- -. . -..- - / . -. - .-. -.--
SELECT similarity('apple', 'apples');
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
    sim_score REAL;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);

    IF object_name LIKE '%layout%' THEN
        score := score + 1000;
    END IF;

--  Add the similarity
    sim_score := similarity(mimic_name, works) * 100;

    score := score + FLOOR(sim_score);

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
    sim_score REAL;
BEGIN
    score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);

    IF object_name LIKE '%layout%' THEN
        score := score + 1000;
    END IF;

--  Add the similarity
    SELECT similarity(mimic_name, works) * 100 INTO sim_score;

    score := score + FLOOR(sim_score);

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
    sim_score REAL;
BEGIN
    score := 0;
    sim_score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);

    IF object_name LIKE '%layout%' THEN
        score := score + 1000;
    END IF;

--  Add the similarity
    SELECT similarity(mimic_name, works) * 100 INTO sim_score;

    score := score + FLOOR(sim_score);

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM pg_available_extensions WHERE name = 'pg_trgm';
;-- -. . -..- - / . -. - .-. -.--
SELECT schema_name
    FROM information_schema.schemata;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_mimic_prioritiser
    (
        mimic_name TEXT, object_name TEXT, works TEXT
    )
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    score INTEGER;
    sim_score REAL;
BEGIN
    score := 0;
    sim_score := 0;
    mimic_name := LOWER(mimic_name);
    object_name := LOWER(object_name);
    works := LOWER(works);

    IF object_name LIKE '%layout%' THEN
        score := score + 1000;
    END IF;

--  Add the similarity
    SELECT public.similarity(mimic_name, works) * 100 INTO sim_score;

    score := score + FLOOR(sim_score);

    IF object_name = 'status_page' THEN
        score := score + 5;
    END IF;

    RETURN score;
END;
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE MATERIALIZED VIEW pnp_point_hierarchy_view AS
    WITH
        first_cte AS (
                         SELECT
                             pn.server_name,
                             pn.db_addr,
                             pn.point_name,
                             pn.comment,
                             os_map.os_name,
                             pnp_create_above_works() AS above_works,
                             pnp_create_works(
                                     os_map.os_name,
                                     os_fdbbool.os_name,
                                     os_constat.os_name,
                                     os_fallback.os_name,
                                     os_configstat.os_name,
                                     os_maintenance.os_name,
                                     os_connecteddb.os_name,
                                     os_siteact.os_name,
                                     os_requeststg.os_name,
                                     os_outofcont.os_name,
                                     os_outofcont.os_name,
                                     pn.point_name,
                                     pn.server_name,
                                     pn.comment
                             ) AS works
                             FROM
                                 pnp_point_names pn
                                     LEFT JOIN pnp_mappings AS ma
                                         ON (pn.server_name = ma.nexus_name AND pn.db_addr = ma.db_point_addr)
                                     LEFT JOIN pnp_outstations AS os_map
                                         ON (ma.outstation_num = os_map.os_number
                                             AND pn.server_name = os_map.nexus_name)
                                     LEFT JOIN pnp_outstations AS os_fdbbool
                                         ON (pn.server_name = os_fdbbool.nexus_name
                                             AND pn.db_addr = os_fdbbool.failure_db_bool)
                                     LEFT JOIN pnp_outstations AS os_constat
                                         ON (pn.server_name = os_constat.nexus_name
                                             AND pn.db_addr = os_constat.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_fallback
                                         ON (pn.server_name = os_fallback.nexus_name
                                             AND pn.db_addr = os_fallback.auto_fallback_db_bool)
                                     LEFT JOIN pnp_outstations AS os_configstat
                                         ON (pn.server_name = os_configstat.nexus_name
                                             AND pn.db_addr = os_configstat.config_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_maintenance
                                         ON (pn.server_name = os_maintenance.nexus_name
                                             AND pn.db_addr = os_maintenance.maintenance_db_bool)
                                     LEFT JOIN pnp_outstations AS os_connecteddb
                                         ON (pn.server_name = os_connecteddb.nexus_name
                                             AND pn.db_addr = os_connecteddb.connected_db_bool)
                                     LEFT JOIN pnp_outstations AS os_siteact
                                         ON (pn.server_name = os_siteact.nexus_name
                                             AND pn.db_addr = os_siteact.site_activity_timeout_db_bool)
                                     LEFT JOIN pnp_outstations AS os_requeststg
                                         ON (pn.server_name = os_requeststg.nexus_name
                                             AND pn.db_addr = os_requeststg.request_stage_status_db_mbit)
                                     LEFT JOIN pnp_outstations AS os_outofcont
                                         ON (pn.server_name = os_outofcont.nexus_name
                                             AND pn.db_addr = os_outofcont.out_of_contact_db_bool)
                     ),

        mimic_cte AS
            (
                SELECT
                    first_cte.server_name,
                    first_cte.db_addr,
                    first_cte.point_name,
                    first_cte.comment,
                    first_cte.above_works,
                    first_cte.works,
                    first_cte.os_name,

                    (FIRST_VALUE(mu.mimic_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS mimic_name,
                    (FIRST_VALUE(mu.object_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_name,
                    (FIRST_VALUE(mu.object_instance_name)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS object_instance,
                    (FIRST_VALUE(mu.other_value)
                     OVER (PARTITION BY first_cte.db_addr, first_cte.server_name ORDER BY pnp_mimic_prioritiser(mimic_name, object_name, works) DESC)) AS other_value

                    FROM
                        first_cte
                            LEFT JOIN mimic_usage_data AS mu
                                ON (
                                (first_cte.db_addr = mu.other_value)
                                        AND mu.mimic_name LIKE first_cte.server_name || '_%')
            ),

        process_cte AS
            (
                SELECT
                    mimic_cte.server_name,
                    mimic_cte.db_addr,
                    mimic_cte.point_name,
                    mimic_cte.comment,
                    mimic_cte.above_works,
                    mimic_cte.works,

                    mimic_cte.mimic_name,
                    mimic_cte.object_name,
                    mimic_cte.object_instance,
                    mimic_cte.other_value,
                    mimic_cte.os_name,

                    pnp_create_process(
                            mimic_cte.mimic_name,
                            mimic_cte.os_name,
                            mimic_cte.object_name,
                            mimic_cte.point_name
                    ) AS process_result
                    FROM mimic_cte
            )
    SELECT DISTINCT ON (db_addr, server_name)

        mimic_name,
        object_name,
        object_instance,

        server_name,
        db_addr,
        point_name,
        above_works,
        works,
        (process_result).process,
        function_result.function,
        asset_result.asset,
        (process_result).fail_flag AS process_overwritten,
        function_result.fail_flag AS function_overwritten,
        asset_result.overwritten AS asset_overwritten
        FROM
            process_cte
                CROSS JOIN LATERAL pnp_create_asset(
                    object_name,
                    point_name,
                    db_addr,
                    (process_cte.process_result).process
                                   ) AS asset_result
                CROSS JOIN LATERAL pnp_create_function(
                    mimic_name,
                    (process_cte.process_result).process,
                    object_name,
                    point_name,
                    other_value,
                   os_name
                                   ) AS function_result
        ORDER BY
            process_cte.server_name,
            process_cte.db_addr;
;-- -. . -..- - / . -. - .-. -.--
SET client_min_messages TO WARNING;
;-- -. . -..- - / . -. - .-. -.--
CREATE EXTENSION IF NOT EXISTS pg_trgm;
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_server_index ON mimic_usage_data (SPLIT_PART(mimic_name, '_', 1));