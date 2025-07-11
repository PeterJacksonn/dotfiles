SELECT * FROM ae_targets;
;-- -. . -..- - / . -. - .-. -.--
SET client_min_messages TO WARNING;
;-- -. . -..- - / . -. - .-. -.--
CREATE EXTENSION IF NOT EXISTS pg_trgm;
;-- -. . -..- - / . -. - .-. -.--
CREATE INDEX pnp_mimic_usage_server_index ON mimic_usage_data (SPLIT_PART(mimic_name, '_', 1));
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
 
 
 
;
;-- -. . -..- - / . -. - .-. -.--
 
;
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