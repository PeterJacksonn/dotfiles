drop DATABASE archiver5;
;-- -. . -..- - / . -. - .-. -.--
drop DATABASE archiver5 with (FORCE);
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN
    -- BEGIN
-- Check if e_value_5 is 6 and raise an error if it is
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;

-- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN
     BEGIN
-- Check if e_value_5 is 6 and raise an error if it is
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;

-- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN
    -- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

-- Check if e_value_5 is 6 and raise an error if it is
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN

    -- Check if e_value_5 is 6 and raise an error if it is
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;

    -- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN


    -- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

    -- Check if e_value_5 is 6 and raise an error if it is
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;
-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN
-- Check if e_value_5 is 6 and raise an error if it is
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;

-- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN
    IF e_value_5 = 6 THEN
        RAISE EXCEPTION 'error'
            USING HINT = 'e_value_5 cannot be 6';
    END IF;

-- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION public.insert_data_db_analogue
    (
        server_id_1 INTEGER,
        db_addr_2 INTEGER,
        db_name_3 CHARACTER VARYING,
        time_4 TIMESTAMP WITHOUT TIME ZONE,
        e_value_5 DOUBLE PRECISION,
        out_of_date_6 NUMERIC,
        out_of_range_7 NUMERIC,
        suspect_8 NUMERIC,
        modify_flag_9 NUMERIC,
        insert_flag_10 NUMERIC,
        test_11 NUMERIC,
        db_source_12 NUMERIC,
        alarm_status_13 NUMERIC,
        alarm_level_14 NUMERIC,
        area_number_15 NUMERIC,
        area_name_16 CHARACTER VARYING,
        alarm_category_17 CHARACTER VARYING,
        works_name_18 CHARACTER VARYING,
        process_name_19 CHARACTER VARYING,
        function_name_20 CHARACTER VARYING,
        asset_name_21 CHARACTER VARYING,
        user_flag_1_22 NUMERIC,
        user_flag_2_23 NUMERIC,
        user_flag_3_24 NUMERIC,
        user_flag_4_25 NUMERIC,
        user_flag_5_26 NUMERIC,
        missing_27 NUMERIC
    )
    RETURNS VOID
    LANGUAGE 'plpgsql'

AS
$BODY$

DECLARE
    works_name_current_var TEXT;
    process_name_current_var TEXT;
    function_name_current_var TEXT;
    asset_name_current_var TEXT;
    area_name_current_var TEXT;
    db_name_current_var TEXT;
    area_number_current_var SMALLINT;

    v_cnt NUMERIC;

BEGIN

-- Insert value row
    INSERT
        INTO
            data_db_analogue
            (
                server_id,
                db_addr,
                time,
                e_value,
                out_of_date,
                out_of_range,
                suspect,
                modify_flag,
                insert_flag,
                test,
                db_source,
                alarm_status,
                alarm_level,
                alarm_category,
                user_flag_1,
                user_flag_2,
                user_flag_3,
                user_flag_4,
                user_flag_5,
                missing
            )
        VALUES
            (
                server_id_1,
                db_addr_2,
                time_4,
                e_value_5,
                out_of_date_6::INT::BOOLEAN,
                out_of_range_7::INT::BOOLEAN,
                suspect_8::INT::BOOLEAN,
                modify_flag_9::INT::BOOLEAN,
                insert_flag_10::INT::BOOLEAN,
                test_11::INT::BOOLEAN,
                db_source_12,
                alarm_status_13,
                alarm_level_14,
                alarm_category_17,
                user_flag_1_22::INT::BOOLEAN,
                user_flag_2_23::INT::BOOLEAN,
                user_flag_3_24::INT::BOOLEAN,
                user_flag_4_25::INT::BOOLEAN,
                user_flag_5_26::INT::BOOLEAN,
                missing_27::INT::BOOLEAN
            )
    ON CONFLICT DO NOTHING;

-- Find out if we inserted anything
    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF (v_cnt = 0) THEN
        -- Must have been a duplicate row, so no need to continue
        RETURN;
    END IF;

-- Now check our lookup record is up-to-date
    SELECT
        works_name,
        process_name,
        function_name,
        asset_name,
        area_name,
        db_name,
        area_number
        INTO works_name_current_var,
            process_name_current_var,
            function_name_current_var,
            asset_name_current_var,
            area_name_current_var,
            db_name_current_var,
            area_number_current_var
        FROM data_db_analogue_lookup_t
        WHERE server_id = server_id_1 AND db_addr = db_addr_2;

    IF (db_name_current_var IS NULL) THEN
        -- Didn't find the lookup at all so must be first time we've archived this addr

        INSERT
            INTO
                data_db_analogue_lookup_t
                (
                    server_id,
                    db_addr,
                    works_name,
                    process_name,
                    function_name,
                    asset_name,
                    area_name,
                    db_name,
                    area_number
                )
            VALUES
                (
                    server_id_1,
                    db_addr_2,
                    works_name_18,
                    process_name_19,
                    function_name_20,
                    asset_name_21,
                    area_name_16,
                    db_name_3,
                    area_number_15
                );

    ELSE
        -- Found lookup record, just update names if necessary
        IF (works_name_current_var <> works_name_18) OR
            (process_name_current_var <> process_name_19) OR
            (function_name_current_var <> function_name_20) OR
            (asset_name_current_var <> asset_name_21) OR
            (area_name_current_var <> area_name_16) OR
            (db_name_current_var <> db_name_3) OR
            (area_number_current_var <> area_number_15) THEN

            UPDATE data_db_analogue_lookup_t
            SET
                works_name = works_name_18,
                process_name = process_name_19,
                function_name = function_name_20,
                asset_name = asset_name_21,
                area_name = area_name_16,
                db_name = db_name_3,
                area_number = area_number_15
                WHERE
                    server_id = server_id_1
                    AND db_addr = db_addr_2;
        END IF;
    END IF;

END;

$BODY$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_process
    (
        mimic_name TEXT, os_name TEXT, object_name TEXT, point_name TEXT
    )
    RETURNS TABLE
                (
                    process TEXT,
                    fail_flag BOOLEAN
                )
    LANGUAGE plpgsql
AS
$$
BEGIN
    mimic_name := LOWER(mimic_name);
    os_name := LOWER(os_name);
    object_name := LOWER(object_name);
    point_name := LOWER(point_name);
    fail_flag := FALSE;

    IF point_name LIKE '%dosing%' OR
        point_name LIKE '%cl2%'
    then
        process := 'Dosing';
    END IF;

    if point_name like '%sodium hypo%' then
        process := 'Dosing';
    END IF;

    if point_name like '%chlorine%' then
        process := 'Dosing';
    END IF;


    IF mimic_name ~* 'ortho|sodium|phosphoric' OR os_name ~* 'ortho|sodium|phosphoric' THEN
        process := 'Dosing';
    END IF;

    IF mimic_name LIKE '%chemical%' OR mimic_name LIKE '%dosing%'
            OR os_name LIKE '%chemical%' OR os_name LIKE '%dosing%' THEN
        IF process IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        process := 'Dosing';
    END IF;

    IF mimic_name LIKE '%treatment%' OR os_name LIKE '%treatment%' THEN
        IF process IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        process := 'Treatment';
    END IF;

    IF mimic_name LIKE '%inlet%' OR os_name LIKE '%inlet%' THEN
        IF process IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        process := 'Abstraction';
    END IF;

    IF mimic_name LIKE '%booster%' OR os_name LIKE '%booster%' THEN
        IF process IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        process := 'Distribution';
    END IF;

    IF mimic_name LIKE '%boreholes%' OR os_name LIKE '%boreholes%' THEN
        IF process IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        process := 'Abstraction';
    END IF;


    -- Filters                              only examples I found were 'covered_res'
    IF object_name = 'tank' OR object_name LIKE '%res%' OR object_name LIKE '%sump%' OR point_name LIKE '%sump%'
    THEN
        IF process IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        process := 'Storage';
    END IF;

    -- SITE SITE SITE SITE SITE
    -- SITE takes priority over sps stw etc
    IF point_name LIKE '%site mains supply' OR
        point_name LIKE '%site power status flag%' OR
        point_name LIKE '%ostn mains supply%' OR
        point_name LIKE '%mains supply%' OR
        point_name LIKE '%ostn battery%' OR
        point_name LIKE '%ostn battery charge%' OR

        -- todo guessing this is correct cos Brandon wanted one by the name of OSTN WATCHDOG to be site
        point_name LIKE '%ostn watchdog%' OR
        point_name LIKE '%backup battery%' OR
        point_name LIKE '%firmware%' OR
        point_name LIKE '%signal strength%' OR
        point_name LIKE '%spare%' OR
        point_name LIKE '%busbar%' OR
        object_name LIKE '%generator%' OR
        point_name LIKE '%generator%' OR
        point_name LIKE '%telemetry%' OR
        point_name LIKE '%comms%' OR
        point_name LIKE '%watchdog process%'
    THEN
        process := 'Site';
    END IF;

    IF object_name = 'filter' OR
        point_name LIKE '%filter%' OR
        point_name LIKE '%filtration%'
    THEN
        process := 'Filtration';
    END IF;


    -- only set process as sps wtw stw if process isn't already set to Site, SITE takes priority
    -- THINK THIS
    IF process IS NULL OR (process <> 'Site' AND process <> 'Storage')
    THEN
        BEGIN
            IF mimic_name LIKE '%sps%' OR os_name LIKE '%sps%' THEN
                IF process IS NOT NULL THEN
                    fail_flag := TRUE;
                END IF;
                process := 'Sewage Pumping Station';
            END IF;

            IF mimic_name LIKE '%wtw%' OR os_name LIKE '%wtw%' THEN
                IF process IS NOT NULL THEN
                    fail_flag := TRUE;
                END IF;
                process := 'Water Treatment Works';
            END IF;

            IF mimic_name LIKE '%stw%' OR os_name LIKE '%stw%' THEN
                IF process IS NOT NULL THEN
                    fail_flag := TRUE;
                END IF;
                process := 'Sewage Treatment Works';
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
CREATE OR REPLACE FUNCTION pnp_create_function
    (
        mimic_name TEXT, process TEXT, object_name TEXT, point_name TEXT
    )
    RETURNS TABLE
                (
                    function TEXT,
                    fail_flag BOOLEAN
                )
    LANGUAGE plpgsql
AS
$$
BEGIN
    mimic_name := LOWER(mimic_name);
    process := LOWER(process);
    object_name := LOWER(object_name);
    point_name := LOWER(point_name);
    fail_flag := FALSE;


    IF process = 'dosing' THEN
        -- TODO more checks on this stuff (layout_object (?)) if its coagulent, dont know what im supposed to be checking though
        function := 'Coagulent';
    END IF;

    IF point_name LIKE '%cl2%' OR
        point_name LIKE '%chlorine%'
    THEN
        function := 'Chlorine';
    END IF;

    IF point_name LIKE '%ortho%' THEN
        function := 'Orthophosphoric';
    END IF;

    IF point_name LIKE '%sodium hypo dosing%' THEN
        function := 'Hypochlorite';
    END IF;

    IF point_name LIKE '%hypo%' AND point_name LIKE '%tank%' THEN
        function := 'Hypochlorite';
    END IF;

    -- Pumps
    IF point_name LIKE '%pump%'
    THEN
        CASE
            WHEN point_name LIKE '%borehole pump%'
                THEN function := 'Borehole';
            WHEN point_name LIKE '%booster pump%'
                THEN function := 'Booster';
            WHEN point_name LIKE '%backwash pump%'
                THEN function := 'Backwash';


            -- todo - need to fix for when point_name is like: 120120PUMP HALL SUMP
            -- should this be sump or PUMP???
            -- fixme - for now done sump%pump and pump%sump
            -- this might work idk though

            WHEN point_name LIKE '%sump%pump%'
                THEN function := 'Sump Pump';

            -- PUMP SUMP IN HERE - works better this way I think
            WHEN point_name LIKE '%pump%sump%'
                THEN function := 'Sumpp';

            ELSE function := 'Pump Set';
        END CASE;
    END IF;

    -- Sump
    --                          check Sump isn't already set from above
    IF object_name = 'sump' OR point_name LIKE '%sump%'
    THEN
        IF function IS NULL OR function <> 'Pump Set' AND function <> 'Sump'
        THEN
            IF function IS NOT NULL THEN
                fail_flag := TRUE;
            END IF;
            function := 'Sump';
        END IF;
    END IF;

    -- Reservoirs
    -- todo - UNLESS PREFIXED WITH A CHEMICAL, THEN THIS IS OVERWRITTEN.....
    IF object_name = 'reservoir' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Reservoir';
    END IF;

    -- Generator
    IF object_name = 'generator' OR point_name LIKE '%generator%' OR point_name LIKE '%gen%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Power';
    END IF;

    -- Site
--     if point_name LIKE '%site power status flag%' OR point_name LIKE '%site mains supply%' OR
    -- above changed to:
    IF point_name LIKE '%power status flag%' OR point_name LIKE '%mains supply%' OR
        point_name LIKE '%ostn mains supply' OR -- this isnt needed
        point_name LIKE '%ostn battery' OR point_name LIKE '%ostn battery charge%' OR -- second one isnt needed
        point_name LIKE '%backup battery%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Power';
    END IF;

    -- more site
    IF point_name LIKE '%ostn watchdog%' OR point_name LIKE '%plc watchdog%' OR point_name LIKE '%rtu watchdog%' OR
        point_name LIKE '%site security%' OR
        point_name LIKE '%firmware%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Security';
    END IF;

    -- site x3
    --                                                  says 'telemetry function' but I disagree
    IF point_name LIKE '%site communications%' OR point_name LIKE '%telemetry%'
            OR point_name LIKE '%signal strength%' OR point_name LIKE '%comms%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'System';
    END IF;

    IF point_name LIKE '%busbar%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Power';
    END IF;


    -- Vents
    --              'But no chemical identifier such as cl2 / ortho
    IF point_name LIKE '%ventilation fan%'
    THEN
        function := 'heating Ventilation Air Conditioning';
    END IF;

    IF point_name LIKE '%vent fan%' AND point_name LIKE '%chlorine%'
    THEN
        function := 'Chlorine';
    END IF;

    IF point_name LIKE '%vent fan%' AND point_name LIKE '%ortho%'
    THEN
        function := 'Orthophosphoric';
    END IF;


    -- Filter
    IF object_name LIKE '%filter%' AND point_name LIKE '%gac%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'GAC';
    END IF;

    IF point_name LIKE '%filter%' AND
        (point_name LIKE '%press%' OR
            point_name LIKE '%pres%' OR
            point_name LIKE '%pressure%' OR
            point_name LIKE '%prss%' OR
            point_name LIKE '%pr%')
    THEN
        function := 'Water Quality';
    END IF;


    --Spare
    IF point_name LIKE '%spare%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        -- in the document it says spare but Brandon said spare on teams... ¯\_(ツ)_/¯
        function := 'Spare';
    END IF;


    -- Contact Tank
    IF point_name LIKE '%contact tank%'
    THEN
        function := 'Contact Tank';
    END IF;

    -- Aeration
    IF point_name LIKE '%aeration%' AND process = 'Sewage Treatment Works'
    THEN
        function := 'Aeration';
    END IF;


    -- Waste
    IF point_name LIKE '%waste tank%' OR
        point_name LIKE '%waste water tank%' OR
        point_name LIKE '%waste wtr tank%' OR
        point_name LIKE '%sludge tank%'
    THEN
        function := ' Waste';
    END IF;

    -- Water Quality todo Brandon not sure
    IF point_name LIKE '%neutralisation%'
    THEN
        function := 'Water Quality';
    END IF;

    -- No Clear Indication
    IF function IS NULL THEN
        function := 'Unknown';
    END IF;

    RETURN NEXT;
END
$$;
;-- -. . -..- - / . -. - .-. -.--
CREATE OR REPLACE FUNCTION pnp_create_function
    (
        mimic_name TEXT, process TEXT, object_name TEXT, point_name TEXT
    )
    RETURNS TABLE
                (
                    function TEXT,
                    fail_flag BOOLEAN
                )
    LANGUAGE plpgsql
AS
$$
BEGIN
    mimic_name := LOWER(mimic_name);
    process := LOWER(process);
    object_name := LOWER(object_name);
    point_name := LOWER(point_name);
    fail_flag := FALSE;


    IF process = 'dosing' THEN
        -- TODO more checks on this stuff (layout_object (?)) if its coagulent, dont know what im supposed to be checking though
        function := 'Coagulent';
    END IF;

    IF point_name LIKE '%cl2%' OR
        point_name LIKE '%chlorine%'
    THEN
        function := 'Chlorine';
    END IF;

    IF point_name LIKE '%ortho%' THEN
        function := 'Orthophosphoric';
    END IF;

    IF point_name LIKE '%sodium hypo dosing%' THEN
        function := 'Hypochlorite';
    END IF;

    IF point_name LIKE '%hypo%' AND point_name LIKE '%tank%' THEN
        function := 'Hypochlorite';
    END IF;

    -- Pumps
    IF point_name LIKE '%pump%'
    THEN
        CASE
            WHEN point_name LIKE '%borehole pump%'
                THEN function := 'Borehole';
            WHEN point_name LIKE '%booster pump%'
                THEN function := 'Booster';
            WHEN point_name LIKE '%backwash pump%'
                THEN function := 'Backwash';


            -- todo - need to fix for when point_name is like: 120120PUMP HALL SUMP
            -- should this be sump or PUMP???
            -- fixme - for now done sump%pump and pump%sump
            -- this might work idk though

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
    IF object_name = 'sump' OR point_name LIKE '%sump%'
    THEN
        IF function IS NULL OR function <> 'Pump Set' and function <> 'Sump Pump' AND function <> 'Sump'
        THEN
            IF function IS NOT NULL THEN
                fail_flag := TRUE;
            END IF;
            function := 'Sump';
        END IF;
    END IF;

    -- Reservoirs
    -- todo - UNLESS PREFIXED WITH A CHEMICAL, THEN THIS IS OVERWRITTEN.....
    IF object_name = 'reservoir' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Reservoir';
    END IF;

    -- Generator
    IF object_name = 'generator' OR point_name LIKE '%generator%' OR point_name LIKE '%gen%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Power';
    END IF;

    -- Site
--     if point_name LIKE '%site power status flag%' OR point_name LIKE '%site mains supply%' OR
    -- above changed to:
    IF point_name LIKE '%power status flag%' OR point_name LIKE '%mains supply%' OR
        point_name LIKE '%ostn mains supply' OR -- this isnt needed
        point_name LIKE '%ostn battery' OR point_name LIKE '%ostn battery charge%' OR -- second one isnt needed
        point_name LIKE '%backup battery%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Power';
    END IF;

    -- more site
    IF point_name LIKE '%ostn watchdog%' OR point_name LIKE '%plc watchdog%' OR point_name LIKE '%rtu watchdog%' OR
        point_name LIKE '%site security%' OR
        point_name LIKE '%firmware%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Security';
    END IF;

    -- site x3
    --                                                  says 'telemetry function' but I disagree
    IF point_name LIKE '%site communications%' OR point_name LIKE '%telemetry%'
            OR point_name LIKE '%signal strength%' OR point_name LIKE '%comms%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'System';
    END IF;

    IF point_name LIKE '%busbar%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'Power';
    END IF;


    -- Vents
    --              'But no chemical identifier such as cl2 / ortho
    IF point_name LIKE '%ventilation fan%'
    THEN
        function := 'heating Ventilation Air Conditioning';
    END IF;

    IF point_name LIKE '%vent fan%' AND point_name LIKE '%chlorine%'
    THEN
        function := 'Chlorine';
    END IF;

    IF point_name LIKE '%vent fan%' AND point_name LIKE '%ortho%'
    THEN
        function := 'Orthophosphoric';
    END IF;


    -- Filter
    IF object_name LIKE '%filter%' AND point_name LIKE '%gac%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        function := 'GAC';
    END IF;

    IF point_name LIKE '%filter%' AND
        (point_name LIKE '%press%' OR
            point_name LIKE '%pres%' OR
            point_name LIKE '%pressure%' OR
            point_name LIKE '%prss%' OR
            point_name LIKE '%pr%')
    THEN
        function := 'Water Quality';
    END IF;


    --Spare
    IF point_name LIKE '%spare%' THEN
        IF function IS NOT NULL THEN
            fail_flag := TRUE;
        END IF;
        -- in the document it says spare but Brandon said spare on teams... ¯\_(ツ)_/¯
        function := 'Spare';
    END IF;


    -- Contact Tank
    IF point_name LIKE '%contact tank%'
    THEN
        function := 'Contact Tank';
    END IF;

    -- Aeration
    IF point_name LIKE '%aeration%' AND process = 'Sewage Treatment Works'
    THEN
        function := 'Aeration';
    END IF;


    -- Waste
    IF point_name LIKE '%waste tank%' OR
        point_name LIKE '%waste water tank%' OR
        point_name LIKE '%waste wtr tank%' OR
        point_name LIKE '%sludge tank%'
    THEN
        function := ' Waste';
    END IF;

    -- Water Quality todo Brandon not sure
    IF point_name LIKE '%neutralisation%'
    THEN
        function := 'Water Quality';
    END IF;

    -- No Clear Indication
    IF function IS NULL THEN
        function := 'Unknown';
    END IF;

    RETURN NEXT;
END
$$;
;-- -. . -..- - / . -. - .-. -.--
DROP MATERIALIZED VIEW IF EXISTS pnp_point_hierarchy_view;
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
    -- todo - need comment and server from dbpoint
    IF full_works = 'Unknown' AND LOWER(comment) LIKE '%rtl%' THEN
        SELECT os_name
            INTO full_works
            FROM pnp_outstations
            WHERE
                os_name LIKE '%' || SUBSTRING(point_name, 1, 6)
                AND server_name = nexus_name;
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
            -- same for St
                IF LOWER(part) IN ('stw', 'sbr', 'sps', 'plc', 'rsps', 'gbt', 'ps', 'wtw', 'edm', 'res', 'abp', 'rtu',
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
select * from data_db_string;
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