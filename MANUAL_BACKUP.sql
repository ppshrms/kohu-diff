--------------------------------------------------------
--  DDL for Package MANUAL_BACKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "MANUAL_BACKUP" as
  /* Description usage
   * use for backup pacakge
   * manual call
   * required directory
   * -- CREATE or replace DIRECTORY ST11_USER_50 AS '\\192.168.2.18\phpdata$\ST11';
   * -- CREATE or replace DIRECTORY ST11_USER_50_FUNCTION AS '\\192.168.2.18\phpdata$\ST11\FUNCTION';
   * -- CREATE or replace DIRECTORY ST11_USER_50_JAVA_SOURCE AS '\\192.168.2.18\phpdata$\ST11\JAVA_SOURCE';
   * -- CREATE or replace DIRECTORY ST11_USER_50_LIBRARY AS '\\192.168.2.18\phpdata$\ST11\LIBRARY';
   * -- CREATE or replace DIRECTORY ST11_USER_50_PACKAGE AS '\\192.168.2.18\phpdata$\ST11\PACKAGE';
   * -- CREATE or replace DIRECTORY ST11_USER_50_PROCEDURE AS '\\192.168.2.18\phpdata$\ST11\PROCEDURE';
   * -- CREATE or replace DIRECTORY ST11_USER_50_TRIGGER AS '\\192.168.2.18\phpdata$\ST11\TRIGGER';
   * -- CREATE or replace DIRECTORY ST11_USER_50_TYPE AS '\\192.168.2.18\phpdata$\ST11\TYPE';
   *
   * -- Daily use to call
   * set serveroutput on;
   * set escape off;
   * set define off;
   *
   * declare
   *   p_input    clob;
   *   p_value    clob;
   * begin
   * -- [PACKAGE include PACKAGE BODY]
   * -- [TYPE include TYPE BODY]
   * -- p_module :: object_name like p_module [default '%']
   * -- {"p_module": "MANUAL_BACKUP"}
   * -- p_type :: object_type in (p_type) [default 'FUNCTION,PACKAGE,PACKAGE BODY,PROCEDURE,TRIGGER,TYPE,TYPE BODY']
   * -- {"p_type": "FUNCTION,LIBRARY,PACKAGE"}
   * -- p_day :: last_ddl_time >= (sysdate - p_day) [default 7 days before]
   * -- p_user :: owner like p_user [default user connect database]
   * -- {"p_user": "ST11"}
   * --  p_input := '{"p_module": "MANUAL_BACKUP"}';
   * --  p_input := '{"p_user": ""}';
   * --  p_input := '{"p_type": ""}';
   *   p_input := '{"p_day": "3"}';
   * --  p_input := '{"p_type": "FUNCTION"}';
   * --  p_input := '{"p_type": "JAVA SOURCE"}';
   * --  p_input := '{"p_type": "LIBRARY"}';
   * --  p_input := '{"p_type": "PACKAGE"}';
   * --  p_input := '{"p_type": "PROCEDURE"}';
   * --  p_input := '{"p_type": "TRIGGER"}';
   * --  p_input := '{"p_type": "TYPE"}';
   *   MANUAL_BACKUP.get_backup_main (p_input, p_value);
   *   DBMS_OUTPUT.PUT_LINE(p_value);
   * end;
   */
  param_msg_error           varchar2(4000 char);
  global_v_lang             varchar2(10 char) := '102';
  global_json_str           clob;

--  global_default_type       varchar2(500 char) := 'FUNCTION,JAVA SOURCE,LIBRARY,PACKAGE,PACKAGE BODY,PROCEDURE,TRIGGER,TYPE,TYPE BODY';
  global_default_type       varchar2(500 char) := 'FUNCTION,PACKAGE,PACKAGE BODY,PROCEDURE,TYPE,TYPE BODY';
  global_default_user       varchar2(100 char) := user;
  global_default_directory  varchar2(100 char) := 'UTL_DIR_BACKUP';
  global_default_day        number := 7;

  v_module                  varchar2(100 char);
  v_type                    varchar2(500 char);
  v_user                    varchar2(100 char);
  v_last_update             number := 7;
  v_custname                tcustmodify.custname%type;

  v_directory               varchar2(100 char);
  v_max_text                number := 3000;
  v_fd_key                  varchar2(100 char) := 'MANUAL_BACKUP';
  v_new_line                varchar2(100 char) := chr(10);
  v_end_of_module           varchar2(100 char) := '/'||v_new_line;

  json_input               json_object_t;  

  procedure initial_value (json_str in clob);

  procedure self_remove_file (p_filename in varchar2);
  procedure self_write_file (p_filename in varchar2, p_text in varchar2);

  procedure get_backup_main (json_str_input in clob, json_str_output out clob);
  procedure gen_backup_main (json_str_output out clob);

  procedure get_patch_standard (json_str_input in clob, json_str_output out clob);
  procedure gen_patch_standard (json_str_output out clob);

  procedure get_patch_package (json_str_input in clob, json_str_output out clob);
  procedure gen_patch_package (json_str_output out clob);

end MANUAL_BACKUP;

/
