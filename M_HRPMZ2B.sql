--------------------------------------------------------
--  DDL for Package M_HRPMZ2B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRPMZ2B" as 

    param_msg_error         varchar2(4000 char);
    v_chken                 varchar2(4 char) := hcm_secur.get_v_chken; 
    global_v_coduser        varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zyear          number := 0;
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);
    v_zyear                 number := pdk.check_year(global_v_lang);
    p_coduser_auto          temploy1.coduser%type  := nvl('AUTO',global_v_coduser);
    p_path_file             varchar2(100)  := '';
    p_codapp                varchar2(50)  := 'HRPMZ2B';

    p_data                  clob;
    b_var_codempid          temploy1.codempid%type;
    b_var_codcompy          tcompny.codcompy%type;

    p_filename              varchar2(1000 char);
    p_typedata              varchar2(15 char);
    p_dteimptwdc            varchar2(1000 char);
    p_dteimpt               date;
    p_dteimptst             date;
    p_dteimpten             date;
    json_input_str          json_object_t;

    p_tablename             varchar2(100); 
    p_lovtype               varchar2(100);
    v_flg                   varchar2(1000);

    p_delimeterat           varchar2(3 char)  := ','; 

    type text is table of varchar2(4000 char) index by binary_integer;
        v_text  text;
        v_head  text;

    procedure initial_value (json_str in clob);

    procedure get_process (json_str_input in clob, json_str_output out clob) ;

    procedure get_set_defaults (json_str_input in clob, json_str_output out clob) ;

    procedure gen_set_defaults(json_str_output out clob) ;

    procedure save_default(json_str_input in clob, json_str_output out clob);

    procedure delete_log_import(json_str_input in clob, json_str_output out clob);

    function get_numappl(p_codempid varchar2) return varchar2 ;

    procedure check_header (p_typdate     in varchar2,
                            p_namefile    in varchar2,
                            p_data        in varchar2,
                            p_count       in number ,
                            p_delimiter   in varchar2,
                            p_dteimpt     in varchar2,
                            p_record      in number,
                            p_lang        in varchar2,
                            p_error       in out varchar2) ;

    procedure check_detail (p_typdate     in varchar2,
                            p_namefile    in varchar2,
                            p_data        in varchar2,
                            p_count       in number ,
                            p_delimiter   in varchar2,
                            p_dteimpt     in varchar2,
                            p_record      in number,
                            p_lang        in varchar2,
                            p_error       in out varchar2) ;

    procedure process_import_manual(json_str_input in clob, json_str_output out clob);

    procedure process_import_auto (p_datatype in varchar2);

    procedure import_data_auto (p_typedata  in varchar,p_namfile in varchar2,p_error out varchar2);

    procedure get_mapping_code (p_typcode in varchar2,
                                p_sapcode in varchar2,
                                p_data    in out varchar2,
                                p_error   in out boolean) ;

    procedure insert_tmapcode (p_namfild in varchar2,
                               p_sapcode in varchar2) ;

    procedure get_default_data (p_typdata in varchar2,
                                p_namtbl  in varchar2,
                                p_namfild in varchar2,
                                p_data    in out varchar2) ;

    procedure import_employee_data ( p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) ;

    procedure import_children_data ( p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) ;

    procedure import_education_data (p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) ;

    procedure import_workexp_data (p_namefile   in varchar2,
                                   p_data       in varchar2,
                                   p_typyear    in varchar2,
                                   p_dteimpt    in varchar2,
                                   p_lang       in varchar2,
                                   p_error      in out varchar2,
                                   p_record     in number,
                                   p_coduser    in varchar2) ;

    procedure import_movement_data ( p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) ;

    procedure import_termination_data ( p_namefile   in varchar2,
                                        p_data       in varchar2,
                                        p_typyear    in varchar2,
                                        p_dteimpt    in varchar2,
                                        p_lang       in varchar2,
                                        p_error      in out varchar2,
                                        p_record     in number,
                                        p_coduser    in varchar2) ;

    procedure import_rehire_data (  p_namefile   in varchar2,
                                    p_data       in varchar2,
                                    p_typyear    in varchar2,
                                    p_dteimpt    in varchar2,
                                    p_lang       in varchar2,
                                    p_error      in out varchar2,
                                    p_record     in number,
                                    p_coduser    in varchar2) ;

    procedure import_othincome_data (  p_namefile   in varchar2,
                                       p_data       in varchar2,
                                       p_typyear    in varchar2,
                                       p_dteimpt    in varchar2,
                                       p_lang       in varchar2,
                                       p_error      in out varchar2,
                                       p_record     in number,
                                       p_coduser    in varchar2) ;

    procedure insert_timpfiles (p_typedata  in varchar2,
                                p_dteimpt   in varchar2,
                                p_numseq    in number,
                                p_namefile  in varchar2,
                                p_datafile  in varchar2,                             
                                p_codempid  in varchar2,
                                p_codcomp   in varchar2,
                                p_dteeffec  in varchar2,
                                p_codtrn    in varchar2,
                                p_codexemp  in varchar2,
                                p_dteyrepay in number,
                                p_dtemthpay in number,
                                p_numperiod in number,
                                p_codpay    in varchar2,
                                p_status    in varchar2,
                                p_remarks   in varchar2) ;                                      


    function check_date (p_date in varchar2, p_zyear in number)   return boolean ;

    procedure get_dir_list( p_directory in varchar2,p_coduser in varchar2,p_codapp in varchar2) as language java name 'DirList.getList( java.lang.String, java.lang.String, java.lang.String )';

    function check_dteyre (p_date in varchar2,p_zyear in varchar2) return varchar2 ;

    function check_number (p_number in varchar2) return boolean ;

    function get_comments_column (p_tablename in varchar2,p_namefield in varchar2) return varchar2 ;

    procedure upd_log1(p_codempid   in varchar2,
                       p_codtable   in varchar2,
                       p_numpage    in varchar2,
                       p_fldedit    in varchar2,
                       p_typdata    in varchar2,
                       p_desold     in varchar2,
                       p_desnew     in varchar2,
                       p_flgenc     in varchar2,
                       p_codcomp    in varchar2,
                       p_coduser    in varchar2) ;

    procedure upd_log2(p_codempid   in varchar2,
                       p_codtable   in varchar2,
                       p_numpage    in varchar2,
                       p_numseq     in number,
                       p_fldedit    in varchar2,
                       p_typkey     in varchar2,
                       p_fldkey     in varchar2,
                       p_codseq     in varchar2,
                       p_dteseq     in varchar2,
                       p_typdata    in varchar2,
                       p_desold     in varchar2,
                       p_desnew     in varchar2,
                       p_flgenc     in varchar2,
                       p_codcomp    in varchar2,
                       p_coduser    in varchar2 ) ;

    procedure upd_log3(p_codempid   in varchar2,
                           p_codtable	in varchar2,
                           p_numpage 	in varchar2,
                           p_typdeduct 	in varchar2,
                           p_coddeduct 	in varchar2,
                           p_desold 	in varchar2,
                           p_desnew 	in varchar2,
                           p_codcomp    in varchar2,
                           p_upd	    in out boolean) ;

    procedure upd_tempded (p_temploy1     temploy1%rowtype,p_coduser in varchar2);
end m_hrpmz2b;

/
