--------------------------------------------------------
--  DDL for Package HRES6OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES6OE" is
-- last update: 04/12/2017 16:22
  v_file              utl_file.file_type;
  v_file_name         varchar2 (4000 char);

--  obj_row             json;
  json_long           long;

  --param error warning
  param_msg_error       varchar2(4000 char);
  p_latitude            number;
  p_longitude           number;
  p_radius              number  := 6387.7;
  p_deg_to_rad          number  := 57.29577951;
  p_km                  number  := 1000;
  v_key_undefinded_codcust  varchar2(100 char) := '9999999999';
--  param_item_error      varchar2(4000 char);
--  param_sqlerrm         varchar2(4000 char);
--  param_code_error      varchar2(4000 char);
--  param_flgwarn         varchar2(4000 char);

  --global
  global_v_coduser      varchar2(100);
  global_v_codpswd      varchar2(100);
  global_v_lang         varchar2(100);
  global_v_chken        varchar2(10);

  --value
  v_start               number;
  v_end                 number;
  v_codempid            varchar2(10 char);
  v_codprovr            varchar2(4000 char);
  v_namcust             varchar2(4000 char);
  v_codcust             varchar2(4000 char);
  v_typplace            varchar2(4000 char);
  v_dtereq              date;
  v_dtework             date;
  v_numseq              number;
  v_tchkinreq           long;
  v_seqno               number;
  v_codcustsurv         varchar2(10 char);

  v_flgchkin            varchar2(1 char);
  v_dte                 date;
  v_tim                 varchar2(4 char);
  v_codreason           varchar2(4 char);
  v_activity            varchar2(500 char);
  v_latitude            varchar2(50 char);
  v_longitude           varchar2(50 char);
  v_accuracy            varchar2(50 char);
  v_ipaddr              varchar2(50 char);
  v_devicenam           varchar2(50 char);
  v_new_namcust         varchar2(4000 char);
  v_namcontact          varchar2(4000 char);
  v_phone               varchar2(50 char);
  v_filenamei           varchar2(4000 char);
  v_filenameo           varchar2(4000 char);
  v_zipcode             varchar2(4000 char);
  v_adrcust             varchar2(4000 char);
  v_default_radius      tcust.radius%type;
  v_default_radiuso     tcust.radiuso%type;

  last_codcust        tcust.codcust%type;
  last_flg_inout      varchar2(20);

  function get_datework(p_codempid varchar2,p_date varchar2, p_time varchar2, p_flgchkin varchar2 default 'I') return varchar2;
  procedure initial_value(json_str_input in clob);
  procedure get_cust(json_str_input in clob,json_str_output out clob);
  procedure get_cust_no_location(json_str_input in clob,json_str_output out clob);
  procedure save_tchkin_master(p_table in varchar2);
  procedure check_in_out(json_str_input in clob,json_str_output out clob);
  procedure get_last_checkin(json_str_input in clob,json_str_output out clob);
  procedure get_history(json_str_input in clob,json_str_output out clob);
  procedure modify_chkin(json_str_input in clob,json_str_output out clob);
  procedure get_tcodreason(json_str_input in clob, json_str_output out clob);

  procedure get_tattence (p_codempid in temploy1.codempid%type,
                          p_dtework  in tattence.dtework%type,
                          r_tattence in out tattence%rowtype);

  procedure time_stamp (p_codshift   in tattence.codshift%type,
                        p_dtework  	 in tattence.dtework%type,
                        p_stampinst  out tatmfile.dtetime%type,
                        p_stampinen  out tatmfile.dtetime%type,
                        p_stampoutst out tatmfile.dtetime%type,
                        p_stampouten out tatmfile.dtetime%type);

  procedure upd_tchkin(p_codempid temploy1.codempid%type,
                       p_coduser  in varchar2,
                       p_dtestrt  in date,
                       p_dteend   in date);                   
end; -- Package spec

/
