--------------------------------------------------------
--  DDL for Package HCM_PM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_PM" is

--ST11 06/03/2018 14:10

global_v_lang         varchar2(10 char) := '102';
function get_codincom (json_str          in clob ) return clob;

function check_over_income (json_str          in clob)   return clob;

function get_tincpos ( json_str          in clob )   return clob ;


function chk_dec(p_amt varchar2, p_codfrm varchar2,p_chken2 varchar2) return number ;

procedure msg_err (p_error in varchar2) ;

end;

/
