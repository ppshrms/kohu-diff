--------------------------------------------------------
--  DDL for Package HRAL3TB_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3TB_BATCH" is
  p_timtran            number := 99;
  p_path_file          varchar2(100)  := '';
  p_coduser_auto       temploy1.coduser%type  := 'AUTO';
  p_coduser_all        temploy1.coduser%type;
  p_stamptime          number;
  p_sysdate            date   := sysdate;
  v_zyear              number := 0;-- v11 not use : pdk.check_year('');
  p_codapp             varchar2(50)  := 'HRAL3TB';
  --------------------------------------------------------

  procedure import_data;-- open file

  procedure import_text(p_filename in varchar2, p_error out varchar2, p_typmatch varchar2);-- text file --> tatmfile

  procedure import_text_file(json_str_input in clob,
                             p_typmatch     varchar2,
                             p_coduser      varchar2,
                             p_error        out varchar2,
                             p_sumtrn       out varchar2,
                             p_sumerr       out varchar2,
                             p_text         out data_error_array,
                             p_numseq       out data_error_array); --user3 : 28/06/2018

  procedure import_text_json(json_str_input in clob, p_error out varchar2, p_sumtrn out varchar2, p_sumerr out varchar2, p_typmatch varchar2); --user3 : 28/06/2018

	procedure cal_tattence(p_typmatch  in varchar2);-- tatmfile --> tattence

  procedure transfer_time(p_codempid  in temploy1.codempid%type,
		                      p_dtestrt   in date,
		                      p_dteend    in date,
		                      p_coduser   in varchar2,
		                      --p_typmatch  in varchar2,
		                      p_mode      in varchar2, --'M = Manual , A = Auto'
		                      p_rectran   in out number,
		                      p_recerr    in out number);

  procedure cal_tlateabs;-- tattence --> tlateabs

  procedure get_tattence (p_codempid in temploy1.codempid%type,
                          p_dtework  in tattence.dtework%type,
                          r_tattence in out tattence%rowtype);

  procedure upd_att_in (p_r_tattence in tattence%rowtype,
                        p_r_tatmfile in tatmfile%rowtype,
                        p_flgupd     in out boolean);

  procedure upd_att_out(p_r_tattence in tattence%rowtype,
                        p_r_tatmfile in tatmfile%rowtype,
                        p_flgupd     in out boolean);

  procedure upd_att_in_today(p_r_tattence in tattence%rowtype,
                             p_r_tatmfile in tatmfile%rowtype,
                             p_flgupd     in out boolean);

  procedure time_stamp(p_codshift  in tattence.codshift%type,
                       p_dtework    in tattence.dtework%type,
                       p_stampinst  out tatmfile.dtetime%type,
                       p_stampinen  out tatmfile.dtetime%type,
                       p_stampoutst out tatmfile.dtetime%type,
                       p_stampouten out tatmfile.dtetime%type);

  procedure upd_att_out_today(p_r_tattence in tattence%rowtype,
                              p_r_tatmfile in tatmfile%rowtype,
                              p_flgupd     in out boolean);

  procedure upd_att_log(p_codempid in temploy1.codempid%type,
                        p_coduser  in varchar2,
                        p_dtestrt  in date,
                        p_dteend   in date,
                        p_mode     in varchar2); --'M = Manual , A = Auto');

  procedure get_dir_list( p_directory in varchar2,p_coduser in varchar2,p_codapp in varchar2) as language java name 'DirList.getList( java.lang.String, java.lang.String, java.lang.String )';
end HRAL3TB_BATCH;

/
