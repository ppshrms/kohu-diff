--------------------------------------------------------
--  DDL for Package PDK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "PDK" IS

   TYPE code_arr IS TABLE OF VARCHAR2(4000)
   INDEX BY BINARY_INTEGER;

   PROCEDURE footer;

   FUNCTION check_pathdad RETURN VARCHAR2;

   FUNCTION check_codempid(p_coduser IN VARCHAR2)
                                 RETURN VARCHAR2;

   FUNCTION sendmail(p_codempid IN VARCHAR2,

                       p_codapp IN VARCHAR2,
                     p_typemail IN VARCHAR2,
                     p_item_err IN VARCHAR2,
                    p_approv_no IN NUMBER,
                       p_approv IN VARCHAR2,
                         p_lang IN VARCHAR2)
                            RETURN VARCHAR2  ;

   FUNCTION check_seq(p_chk IN VARCHAR2,
                 p_approvno IN NUMBER,
                  p_chk_seq IN VARCHAR2)
                        RETURN BOOLEAN;


   FUNCTION check_year(p_lang IN VARCHAR2) RETURN NUMBER;

   PROCEDURE login;
   PROCEDURE get_tinexinf(p_item  IN VARCHAR2,
                          p_type  IN VARCHAR2,
                          p_lang  IN VARCHAR2);
   PROCEDURE header(p_desc VARCHAR2,p_coduser VARCHAR2,p_lang VARCHAR2,p_type VARCHAR2);

   PROCEDURE get_tcodmove(p_item  IN VARCHAR2,
                       p_type  IN VARCHAR2,
                       p_lang  IN VARCHAR2);

   PROCEDURE error_approve(p_code  IN VARCHAR2,

                p_table IN VARCHAR2,
                p_item  IN VARCHAR2,
                p_lang  IN VARCHAR2 );

   PROCEDURE get_list_item(p_code  IN VARCHAR2,
                        p_lang  IN VARCHAR2,
                        p_item  IN VARCHAR2,
                        p_value IN VARCHAR2,
                        p_style IN VARCHAR2);
   PROCEDURE error_page(p_code IN VARCHAR2,
                     p_lang IN VARCHAR2);

--   PROCEDURE get_tcodplan(p_item  IN VARCHAR2,
--
--                       p_type  IN VARCHAR2,
--                       p_lang  IN VARCHAR2);
   PROCEDURE error_process(p_code varchar2,
                        p_table varchar,
                        p_item varchar2,
                        p_lang varchar2
                        );
  FUNCTION get_title(p_lang in varchar2) RETURN varchar2;

  PROCEDURE block_click ;


  procedure Main_Data(p_label1 in varchar2,
                    p_link1  in varchar2,
                    p_label2 in varchar2,
                    p_link2  in varchar2,
                    p_label3 in varchar2,
                    p_link3  in varchar2,
                    p_label4 in varchar2,
                    p_link4  in varchar2,
                    p_label5 in varchar2,
                    p_link5  in varchar2,
                    p_label6 in varchar2,
                    p_link6  in varchar2,
                    p_label7 in varchar2,
                    p_link7  in varchar2,
                    p_label8 in varchar2 default null,
                    p_link8  in varchar2 default null);
                    --user36 STA3590329 01/11/2016 add tab 8
                    --user36 STA3600369 31/03/2017 add default null

  procedure dialog_window(p_link1  in varchar2);
  PROCEDURE pass_approve( p_codapp   VARCHAR2,
                        p_coduser  VARCHAR2,
                        p_lang     VARCHAR2,
                        p_codcomp  VARCHAR2,
                        p_dtest    VARCHAR2,
                        p_dteen    VARCHAR2,
                        p_staappr  VARCHAR2,
                        p_codempid VARCHAR2);

  procedure get_tlistval(p_item    in varchar2,
                         p_codapp  in varchar2,
                         p_lang    in varchar2);

  PROCEDURE menu(p_coduser  IN VARCHAR2,
                 p_lang     IN VARCHAR2,
                 p_main     IN VARCHAR2,
                 p_wide     IN NUMBER,
                 p_high     IN NUMBER,
                 p_action   IN VARCHAR2,
                 p_type     IN VARCHAR2,
                 p_chkall   IN VARCHAR2,
                 p_codcomp  IN VARCHAR2,
                 p_dtest    IN VARCHAR2,
                 p_dteen    IN VARCHAR2,
                 p_staappr  IN VARCHAR2,
                 p_codempid IN VARCHAR2);

  PROCEDURE block_refresh;
  PROCEDURE block_backspace;
  FUNCTION error_msg(p_coderr IN VARCHAR2,p_lang IN VARCHAR2)
                             RETURN VARCHAR2;
  PROCEDURE keynextitem;

  PROCEDURE getempname(p_coduser in varchar2,p_lang in varchar2);
  PROCEDURE gettemployname(itemtran  IN VARCHAR2,
                itemwhere IN VARCHAR2,
                itemgo    in varchar2,
                p_coduser  IN VARCHAR2,
                p_lang  IN VARCHAR2 );
  FUNCTION error_table(p_table  IN VARCHAR2 ,

                     p_coderr IN VARCHAR2,
                     p_lang   IN VARCHAR2) RETURN VARCHAR2;
  procedure window_close (p_lang in varchar2);

  procedure include_js;
  procedure include_css;


END; -- Package spec

/
