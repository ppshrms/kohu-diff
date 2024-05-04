--------------------------------------------------------
--  DDL for Package ALERTMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "ALERTMAIL" is
  procedure run_alert ;
  function  gen_header(p_codempid varchar2) return varchar2;
  procedure inst_data(v_memono   in varchar2,
                      v_dteeffec in date,
                      v_criteria in varchar2,
                      v_coduser  in varchar2,
                      v_table    in varchar2,
                      p_filename out varchar2);
  PROCEDURE Check_mail (p_empidf   in varchar2,
                       p_memono   in varchar2,
                       p_dteeffec in date ,
                       p_subject  in varchar2,
                       p_msg      in clob,
                       p_filename in varchar2 );
  FUNCTION Send_Msg (p_fromname in varchar2,
                      p_codempid in varchar2,
                      p_msg      in clob,
                      p_subj     in varchar2,
                      p_filename in varchar2) RETURN VARCHAR2;
  procedure check_proc (p_memono in varchar2,p_dteeffec in date,p_type in varchar);
end alertmail;

/
