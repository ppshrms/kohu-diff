--------------------------------------------------------
--  DDL for Package HCM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_UTIL" is
-- last update: 17/10/2017 11:11

  param_msg_error         varchar2(4000 char);

  global_v_coduser        varchar2(100 char);
  global_v_codpswd        varchar2(100 char);
  global_v_lang           varchar2(100 char) := '102';

  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  function get_current_user(json_str_input in clob) return clob;
  function get_year return varchar2;
  function get_tinitial(json_str in clob) return clob;
  function get_tfolder(json_str in clob) return clob;
  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d;
  function get_label(json_str in clob) return clob;
  function get_coddesc(json_str in clob) return clob;
  function file_exists(p_filepath in varchar2) return boolean;
  procedure get_cod_income(p_codcompy   in  varchar2 ,
                           p_codempmt   in  varchar2 ,
                           p_codincom1  out varchar2,
                           p_codincom2  out varchar2,
                           p_codincom3  out varchar2,
                           p_codincom4  out varchar2,
                           p_codincom5  out varchar2,
                           p_codincom6  out varchar2,
                           p_codincom7  out varchar2,
                           p_codincom8  out varchar2,
                           p_codincom9  out varchar2,
                           p_codincom10 out varchar2,
                           p_unitcal1   out varchar2,
                           p_unitcal2   out varchar2,
                           p_unitcal3   out varchar2,
                           p_unitcal4   out varchar2,
                           p_unitcal5   out varchar2,
                           p_unitcal6   out varchar2,
                           p_unitcal7   out varchar2,
                           p_unitcal8   out varchar2,
                           p_unitcal9   out varchar2,
                           p_unitcal10  out varchar2);
  procedure get_income(p_lang in varchar2, p_codincom in out varchar2,p_detail  out varchar2);

  function get_list_values (json_str_input clob) return clob;
  procedure get_listfields(json_str_input in clob, json_str_output out clob);
  function gen_listfields(json_str_input in clob) return clob;

  function get_string(obj json, json_key varchar2) return varchar2;
  function get_json(obj json, json_key varchar2) return json;

  function get_string_t(obj json_object_t, json_key varchar2) return varchar2;
  function get_number_t(obj json_object_t, json_key varchar2) return number;
  function get_clob_t(obj json_object_t, json_key varchar2) return clob;
  function get_json_t(obj json_object_t, json_key varchar2) return json_object_t;
  function get_array_t(obj json_object_t, json_key varchar2) return json_array_t;
  function get_boolean_t(obj json_object_t, json_key varchar2) return boolean;

  function translate_statement (v_statement json_object_t,v_codapp varchar2,v_lang varchar2) return json_object_t;
  procedure get_logical_description (json_str_input in clob, json_str_output out clob);
  procedure get_logical_list_values (json_str_input in clob, json_str_output out clob);
  procedure get_codapp_list (json_str_input in clob, json_str_output out clob);

  procedure get_imageurl (json_str_input in clob,json_str_output out clob);

  function get_codcomp_level (p_codcomp varchar2,p_level number,p_concat varchar2 default '',p_fulldisp varchar2 default '') return varchar2;

  function get_level_from_codcomp (p_codcomp varchar2, flg_ignore_zero varchar2 default 'N') return number;

--  function get_codcomp_level2 (p_codcomp varchar2,p_level number) return varchar2;

  function get_qtyavgwk(p_codcomp varchar2,p_codempid varchar2) return number;

  function get_temploy_field(p_codempid varchar2, p_field varchar2) return varchar2;

  function get_temphead_codempid(p_codempidh varchar2, p_prefix_emp varchar2 default null) return clob;
  function count_temphead_codempid(p_codempidh varchar2) return number;

  procedure	cal_dhm_hm (p_day       in  number,
                        p_hr        in  number,
                        p_min       in  number,
                        p_qtyavhwk  in  number,
                        p_type      in  varchar2, -- 1- 'dd:hr:mi' , 2- 'hr:mi'
                        o_day       out number,
                        o_hr        out number,
                        o_min       out number,
                        o_dhm       out varchar);

  function  cal_dhm_concat (p_qtyday in number, p_qtyavgwk in number) return varchar2;

  function  convert_hour_to_minute (p_hour in varchar2) return number;

  function  convert_minute_to_hour(p_minute in number,p_base_100 in varchar2 default 'N') return varchar2;

  function  convert_time_to_minute (p_time in varchar2) return number;

  function  convert_minute_to_time(p_minute in number) return varchar2;

  function convert_dtetime_to_date(p_dtetime varchar2) return date;

  function convert_dtetime_to_time(p_dtetime varchar2) return varchar2;

  function convert_date_time_to_dtetime(p_date date,p_time varchar2) return varchar2;

  function datediff_to_time(p_datestrt date,p_dateend date) return varchar2;

  function query_cursor(json_str_input in clob) return sys_refcursor;

  procedure set_lang(p_lang varchar2);

  function get_lang return varchar2;

  procedure get_terrorm(json_str_input in clob, json_str_output out clob);

  function get_pathphp(p_codapp varchar2) return varchar2;

  function get_date_buddhist_era(p_date date) return varchar2;
  function get_year_buddhist_era(p_year varchar2) return varchar2;
  
  function get_date_config(p_date date) return varchar2;
  function get_year_config(p_year varchar2) return varchar2;
  
  function get_split_decimal(p_number varchar2,p_flg varchar2,p_leng_dec number default 2) return varchar2;
  function get_tempimge(json_str in clob) return clob;
  function get_tempimge_emp(json_str in clob) return clob;
  function get_date_excel(p_date date) return date;
  function convert_numbank(p_numbank varchar2) return varchar2;
  function convert_codempid_to_temp(p_codempid varchar2) return varchar2;
  function get_codcompy (p_codcomp varchar2) return varchar2;
  function get_codcomp_by_level (p_codcomp varchar2, p_level number default 1) return varchar2;
end;

/
