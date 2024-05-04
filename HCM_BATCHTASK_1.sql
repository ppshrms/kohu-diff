--------------------------------------------------------
--  DDL for Package Body HCM_BATCHTASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_BATCHTASK" is
  -- last update: 31/05/2020 23:24

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    v_flgquery          := upper(nvl(hcm_util.get_string_t(json_obj,'p_flgquery'),'A')); -- N=Noti, A=All
    v_limit             := to_number(nvl(hcm_util.get_string_t(json_obj,'p_limit'),'999999'));
    v_start             := to_number(hcm_util.get_string_t(json_obj,'p_start'));
    v_codapp            := upper(hcm_util.get_string_t(json_obj,'p_codapp'));
    v_codalw            := upper(hcm_util.get_string_t(json_obj,'p_codalw'));
    v_flgproc           := upper(hcm_util.get_string_t(json_obj,'p_flgproc'));
    if v_flgproc = 'A' then
      v_flgproc := null;
    end if;
    v_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    v_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    v_timstrt           := hcm_util.get_string_t(json_obj,'p_timstrt');
    v_dtetimstrt        := to_date(to_char(v_dtestrt,'dd/mm/yyyy')||v_timstrt,'dd/mm/yyyyhh24miss');
    v_procname          := hcm_util.get_string_t(json_obj,'p_procname');
    v_amt_process       := to_number(nvl(hcm_util.get_string_t(json_obj,'p_amt_process'),'0'));
    v_param_input       := hcm_util.get_json_t(json_obj,'p_param_input').to_clob;
    v_dtetim            := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

  end;

  function get_desccodalw(p_codapp varchar2,p_codalw varchar2) return varchar2 is
    v_desc_codalw   varchar2(4000 char);
  begin
    v_desc_codalw := '';
    if p_codapp <> p_codalw then
      if p_codapp = 'HRAL71B' then
        v_desc_codalw := get_tlistval_name('CODALW',p_codalw,global_v_lang);
      elsif p_codapp = 'HRAL24B' then
        if p_codalw = 'HRAL24B1' then
          v_desc_codalw := get_label_name('HRAL24B',global_v_lang,'40');
        elsif p_codalw = 'HRAL24B2' then
          v_desc_codalw := get_label_name('HRAL24B',global_v_lang,'50');
        elsif p_codalw = 'HRAL24B3' then
          v_desc_codalw := get_label_name('HRAL24B',global_v_lang,'60');
        end if;
      elsif p_codapp = 'HRPM91B' then
        if p_codalw = 'HRPM91B1' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'60');
        elsif p_codalw = 'HRPM91B2' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'100');
        elsif p_codalw = 'HRPM91B3' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'70');
        elsif p_codalw = 'HRPM91B4' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'110');
        elsif p_codalw = 'HRPM91B5' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'80');
        elsif p_codalw = 'HRPM91B6' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'120');
        elsif p_codalw = 'HRPM91B7' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'90');
        elsif p_codalw = 'HRPM91B8' then
          v_desc_codalw := get_label_name('HRPM91BC1',global_v_lang,'130');
        end if;
      end if;
    end if;
    return v_desc_codalw;
  end;

  function set_detail_header(p_codapp varchar2,p_json_str clob) return clob is
    obj_header    json_object_t := json_object_t();
  begin
    return '';
		if p_json_str is not null then
			obj_header := json_object_t(p_json_str);

      if p_codapp = 'HRPM91B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dteproc',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dteproc'),'dd/mm/yyyy')));
      elsif p_codapp = 'HRAL24B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dteeffec',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dteeffec'),'dd/mm/yyyy')));
      elsif p_codapp = 'HRAL34B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'p_codempid_query'),global_v_lang));
        obj_header.put('desc_stdate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_stdate'),'dd/mm/yyyy')));
        obj_header.put('desc_endate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_endate'),'dd/mm/yyyy')));
      elsif p_codapp = 'HRAL3TB' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'p_codempid_query'),global_v_lang));
        obj_header.put('desc_stdate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_stdate'),'dd/mm/yyyy')));
        obj_header.put('desc_endate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_endate'),'dd/mm/yyyy')));
      elsif p_codapp = 'HRAL56B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_stdate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_stdate'),'dd/mm/yyyy')));
        obj_header.put('desc_endate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_endate'),'dd/mm/yyyy')));
      elsif p_codapp = 'HRAL71B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
      elsif p_codapp = 'HRAL82B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        obj_header.put('desc_dtecal',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dtecal'),'dd/mm/yyyy')));
      elsif p_codapp = 'HRAL85B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtestrt',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dtestrt'),'dd/mm/yyyy')));
        obj_header.put('desc_dteend',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dteend'),'dd/mm/yyyy')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
        obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'p_codempid_query'),global_v_lang));
      elsif p_codapp = 'HRPY35B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY3AB' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY41B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        if hcm_util.get_string_t(obj_header,'p_newflag') = 'Y' then
          obj_header.put('desc_newflag',get_label_name('HRPY41B',global_v_lang,'100'));
        else
          obj_header.put('desc_newflag',get_label_name('HRPY41B',global_v_lang,'110'));
        end if;
        if hcm_util.get_string_t(obj_header,'p_flgretro') = '1' then
          obj_header.put('desc_flgretro',get_label_name('HRPY41B',global_v_lang,'130'));
        else
          obj_header.put('desc_flgretro',get_label_name('HRPY41B',global_v_lang,'140'));
        end if;
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY44B' then
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY46B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'codcomp'),global_v_lang));
        obj_header.put('desc_month',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'month'),global_v_lang));
        obj_header.put('desc_year',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'year')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'typpayroll'),global_v_lang));
        obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'codempid_query'),global_v_lang));
      elsif p_codapp = 'HRPY6KB' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'codcomp'),global_v_lang));
        obj_header.put('desc_year',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'year')));
        obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'codempid_query'),global_v_lang));
      elsif p_codapp = 'HRPY70B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemonth',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'month'),global_v_lang));
        obj_header.put('desc_dteyear',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'year')));
        obj_header.put('desc_typbank',get_tcodec_name('tcodbank',hcm_util.get_string_t(obj_header,'typbank'),global_v_lang));
        obj_header.put('desc_dtepay',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'datePay'),'dd/mm/yyyy')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY80B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        obj_header.put('desc_sdate',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_sdate'),'dd/mm/yyyy')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY81B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'codcomp'),global_v_lang));
        obj_header.put('desc_dtemonth',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'month'),global_v_lang));
        obj_header.put('desc_dteyear',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'year')));
      elsif p_codapp = 'HRPY90B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
        obj_header.put('desc_dtepay',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dtepay'),'dd/mm/yyyy')));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
      elsif p_codapp = 'HRPY91B' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
        obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'p_codempid_query'),global_v_lang));
        obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
        obj_header.put('desc_dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
      elsif p_codapp = 'HRPYBGB' then
        obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcompy'),global_v_lang));
        obj_header.put('desc_dteeffec',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dteeffec'),'dd/mm/yyyy')));
      end if;
		end if;
    return obj_header.to_clob;
  end;

  function gen_filename(p_filename in varchar2, p_extension in varchar2, p_chk in date default null) return varchar2 is
    v_filename  varchar2(4000 char);
  begin
    if p_chk is not null then
      v_filename := p_filename||'_'||to_char(sysdate,'yyyymmddhh24miss')||'_'||trunc(dbms_random.value(10,99));
    else
      v_filename := p_filename;
    end if;
    return v_filename||'.'||replace(p_extension,'.');
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_data_tmp    json_object_t;
    v_rcnt          number := 0;
    v_min_total    	number;
    v_time          varchar2(1000 char);
    v_flgdelete     varchar2(1000 char);
    v_oracode     	tbackproc.oracode%type;
    v_flgdata       boolean := false;

    cursor c_tbackproc is
      select a.codapp,a.codalw,a.flgproc,a.dtestrt,a.dteend,a.qtyproc,a.qtyerror,a.descproc,a.jobno,
             a.filename1,a.pathfile1,a.filename2,a.pathfile2,a.filename3,a.pathfile3,a.filename4,a.pathfile4,a.filename5,a.pathfile5,a.oracode,b.jsonstr
        from tbackproc a,tbackprocl b
       where a.codapp  = b.codapp(+)
         and a.coduser = b.coduser(+)
         and a.codalw  = b.codalw(+)
         and a.dtestrt = b.dtestrt(+)
         and a.coduser = global_v_coduser
         and a.codapp  = nvl(v_codapp,a.codapp)
         and a.flgproc = nvl(v_flgproc,a.flgproc)
         and (
               (v_dtestrt is null or v_dtestrt between trunc(a.dtestrt) and trunc(nvl(a.dteend,a.dtestrt))) or
               (v_dteend is null or v_dteend between trunc(a.dtestrt) and trunc(nvl(a.dteend,a.dtestrt))) or
               (trunc(a.dtestrt) between v_dtestrt and nvl(v_dteend,v_dtestrt)) or
               (trunc(a.dteend) between v_dtestrt and nvl(v_dteend,v_dtestrt))
             )
      order by a.dtestrt desc,a.codapp,a.codalw;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tbackproc loop
      if i.codalw <> 'HRAL71B' and i.codalw <> 'M_HRAL71B' then
        v_flgdata   := true;
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codapp', i.codapp);
        obj_data.put('desc_codapp',get_tappprof_name(replace(i.codapp,'M_'),1,global_v_lang));
        obj_data.put('codalw',i.codalw);
        obj_data.put('desc_codalw',get_desccodalw(replace(i.codapp,'M_'),replace(i.codalw,'M_')));
        obj_data.put('flgproc',i.flgproc);
        obj_data.put('desc_flgproc',get_tlistval_name('FLGPROC',i.flgproc,global_v_lang));
        obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
        obj_data.put('timstrt',to_char(i.dtestrt,'hh24:mi:ss'));
        obj_data.put('timstrt_display',to_char(i.dtestrt,'hh24:mi'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('timend',to_char(i.dteend,'hh24:mi'));
        obj_data.put('qtyproc',to_char(i.qtyproc,'fm999,999,999,990'));
        obj_data.put('qtyerror',to_char(i.qtyerror,'fm999,999,999,990'));
        obj_data.put('jsonstr',i.jsonstr);  -- set_detail_header(i.codapp,i.jsonstr) | don't display on screen

        v_time := null;
        if i.dteend is not null then
          v_min_total := (i.dteend - i.dtestrt)*1440;
          if v_min_total < 1 then -- set minimum is 1 minute
            v_min_total := 1;
          end if;
          v_time       := trunc(v_min_total/60)||':'||lpad(trunc(mod(v_min_total,60)),2,'0');
        end if;

        obj_data.put('qtytime',v_time);
        obj_data.put('descproc',i.descproc);
        obj_data.put('filename',i.filename1);
        obj_data.put('path_filename',i.pathfile1);

        v_flgdelete := 'N';
        if (i.flgproc in ('Y','N')) then
--        or (i.flgproc = 'P' and (nvl(i.dteend,sysdate) - i.dtestrt)*1440 > nvl(get_tsetup_value('TIMEPROC'),1440)) then
          v_flgdelete := 'Y';
        end if;

        if i.flgproc = 'P' then
          begin
            select 'N' into v_flgdelete
              from user_jobs
             where job = i.jobno;
          exception when no_data_found then
            v_flgdelete := 'Y';
          end;

          if (nvl(i.dteend,sysdate) - i.dtestrt)*1440 > nvl(get_tsetup_value('TIMEPROC'),1440) then
            v_flgdelete := 'Y';
          end if;
        end if;

        obj_data.put('flgdelete',v_flgdelete);

        v_oracode := null;
        if replace(i.codapp,'M_') = 'HRPY46B' then
          v_oracode := replace(i.oracode,get_error_msg_php('HR2715',global_v_lang));
        end if;
        if i.flgproc <> 'Y' then
          v_oracode := i.oracode;
        end if;
        obj_data.put('oracode',v_oracode);

        obj_row.put(to_char(v_rcnt-1),obj_data);

        if v_flgquery = 'A' then
          obj_data_tmp := obj_data;
          if i.filename2 is not null then
            v_rcnt   := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('filename',i.filename2);
            obj_data.put('path_filename',i.pathfile2);
            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;

          if i.filename3 is not null then
            v_rcnt   := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('filename',i.filename3);
            obj_data.put('path_filename',i.pathfile3);
            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;

          if i.filename4 is not null then
            v_rcnt   := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('filename',i.filename4);
            obj_data.put('path_filename',i.pathfile4);
            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;

          if i.filename5 is not null then
            v_rcnt   := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('filename',i.filename5);
            obj_data.put('path_filename',i.pathfile5);
            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;
        end if; --if v_flgquery = 'A' then

        -- update flgread
        begin
          update tbackproc
             set flgread = 'Y'
           where codapp  = i.codapp
             and coduser = global_v_coduser
             and codalw  = i.codalw
             and dtestrt = i.dtestrt
             and flgproc in ('Y','N');
        exception when others then null;
        end;
      end if; -- if i.codalw <> 'HRAL71B' then
    end loop;
    if v_flgdata then
      commit;
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tbackproc');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_total_complete(json_str_input in clob, json_str_output out clob) as
    obj_data              json_object_t;
    v_total_complete      number := 0;
    v_total_processing    number := 0;
    obj_data_noti         json_object_t;
    obj_row_noti          json_object_t;
    v_row_noti            number := 0;
    v_status              varchar2(1000 char);
    v_flgchk              boolean := true;
    v_count_chk           number := 0;

    cursor c_noti is
      select codapp,replace(codapp,'M_') as codapp_m,codalw,replace(codalw,'M_') as codalw_m,flgproc,dtestrt,dteend,oracode
        from tbackproc
       where flgproc in ('Y','N')
         and flgread = 'N'
         and flgnoti = 'N'
         and coduser = global_v_coduser;
  begin
    initial_value(json_str_input);
    begin
      select count(*)
        into v_total_complete
        from tbackproc
       where coduser = global_v_coduser
         and flgproc in ('Y','N')
         and flgread = 'N';
    exception when others then
      v_total_complete := 0;
    end;

    begin
      select count(*)
        into v_total_processing
        from tbackproc
       where coduser = global_v_coduser
         and flgproc = 'P'
         and (sysdate - dtestrt)*1440 < nvl(get_tsetup_value('TIMEPROC'),1440);
    exception when others then
      v_total_processing := 0;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('total_complete',to_char(v_total_complete));
    obj_data.put('total_processing',to_char(v_total_processing));

    obj_row_noti := json_object_t();
    for r_noti in c_noti loop
      v_flgchk := true;
      if r_noti.codapp_m = 'HRAL71B' and r_noti.codalw_m = 'HRAL71B' then
        begin
          select count(*) into v_count_chk
            from tbackproc
           where codapp  =  r_noti.codapp
             and codalw  <> r_noti.codalw
             and coduser =  global_v_coduser
             and dtestrt =  r_noti.dtestrt
             and flgproc = 'Y';
        exception when others then
          v_count_chk := 0;
        end;
        if v_count_chk > 0 then
          v_flgchk := false; -- don't noti alert codapp='HRAL71B' and codalw='HRAL71B'
        end if;
      end if;

      if v_flgchk then
        obj_data_noti := json_object_t();
        obj_data_noti.put('codapp',r_noti.codapp_m);
        if r_noti.flgproc = 'N' then
          v_status := get_label_name('BATCHTASK',global_v_lang,'180');
        else
          v_status := get_label_name('BATCHTASK',global_v_lang,'170');
        end if;
        obj_data_noti.put('flgproc',r_noti.flgproc);
        obj_data_noti.put('status',v_status);
        obj_data_noti.put('desc_codapp',get_tappprof_name(r_noti.codapp_m,1,global_v_lang));
        obj_data_noti.put('codalw',r_noti.codalw_m);
        obj_data_noti.put('desc_codalw',get_desccodalw(r_noti.codapp_m,r_noti.codalw_m));
        obj_data_noti.put('oracode',replace(r_noti.oracode,'@#$%200'));
        obj_row_noti.put(to_char(v_row_noti),obj_data_noti);
        v_row_noti := v_row_noti + 1;
      end if;
    end loop;
    obj_data.put('noti_alert',obj_row_noti);

    begin
      update tbackproc
         set flgnoti = 'Y'
       where flgproc in ('Y','N')
         and flgread = 'N'
         and flgnoti = 'N';
    exception when others then null;
    end;
    commit;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    json_obj        json_object_t;
    json_obj2       json_object_t;
    v_codapp        tbackproc.codapp%type;
    v_codalw        tbackproc.codalw%type;
    v_dtestrt       tbackproc.dtestrt%type;
    v_date          varchar2(100 char);
    v_time          varchar2(100 char);
    v_sid           tbackproc.sid%type;
    v_serial        tbackproc.serial%type;
    v_jobno         tbackproc.jobno%type;
    v_err           boolean;

  begin
    initial_value(json_str_input);
    json_obj     :=  hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..json_obj.get_size-1 loop
        json_obj2   := json_object_t(json_obj.get(to_char(i)));

        v_codapp       := upper(hcm_util.get_string_t(json_obj2,'codapp'));
        v_codalw       := upper(hcm_util.get_string_t(json_obj2,'codalw'));
        v_date         := upper(hcm_util.get_string_t(json_obj2,'dtestrt'));
        v_time         := upper(hcm_util.get_string_t(json_obj2,'timstrt'));
        v_dtestrt      := to_date(v_date||v_time,'ddmmyyyyhh24miss');

        begin
          select sid,serial,jobno
            into v_sid,v_serial,v_jobno
            from tbackproc
           where codapp = v_codapp
             and coduser = global_v_coduser
             and codalw  = v_codalw
             and dtestrt = v_dtestrt;
        exception when no_data_found then
          v_sid    := null;
          v_serial := null;
        end;

        begin
          delete from tbackproc
                where codapp  = v_codapp
                  and coduser = global_v_coduser
                  and codalw  = v_codalw
                  and dtestrt = v_dtestrt;
        end;

        begin
          delete from tbackprocd
                where codapp  = v_codapp
                  and coduser = global_v_coduser
                  and codalw  = v_codalw
                  and dtestrt = v_dtestrt;
        end;

        -- kill session
        if v_sid is not null and v_serial is not null then
          begin
            v_err := execute_stmt('EXEC DBMS_JOB.REMOVE('||v_jobno||');');
            exception when others then null;
          end;
          /*if get_tsetup_value('SYSPLATFORM') = 'aws' then
            begin
              rdsadmin.rdsadmin_util.disconnect(sid => v_sid,serial => v_serial);
            exception when others then null;
            end;
          else
            begin
              execute immediate ' alter system kill session '''||v_sid||','||v_serial||''' immediate';
            exception when others then null;
            end;
          end if;*/
        end if;

      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  function get_detail_header(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_dtestrt date) return clob is
    v_jsonstr   clob;
  begin
    begin
      select jsonstr
        into v_jsonstr
        from tbackprocl
       where codapp  = p_codapp
         and coduser = p_coduser
         and codalw  = p_codalw
         and dtestrt = p_dtestrt;
    exception when no_data_found then
      v_jsonstr := null;
    end;
    return v_jsonstr;
  end;

  procedure get_detail_hrpm91b(json_str_input in clob, json_str_output out clob) is
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_header      json_object_t := json_object_t();
    v_rcnt          number := 0;
    v_codapp        varchar2(10 char) := 'HRPM91B';
    v_header_detail clob;

    cursor c_tbackprocd is
      select *
        from tbackprocd
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and dtestrt = v_dtetimstrt
      order by numseq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tbackprocd loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('codempid',i.item01);
      obj_data.put('desc_codempid',i.item02);
      obj_data.put('desc_codcomp',i.item03);
      obj_data.put('desc_codpos',i.item04);
      obj_data.put('process_topic',i.item05);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    v_header_detail := get_detail_header(v_codapp,global_v_coduser,v_codalw,v_dtetimstrt);
		if v_header_detail is not null then
			obj_header := json_object_t(v_header_detail);
			obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
			obj_header.put('dteproc',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_dteproc'),'dd/mm/yyyy')));
		end if;

    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('obj_rows',obj_row);
		obj_result.put('json_header',obj_header);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_hral3tb(json_str_input in clob, json_str_output out clob) is
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_header      json_object_t := json_object_t();
    v_rcnt          number := 0;
    v_codapp        varchar2(10 char) := 'HRAL3TB';
    v_header_detail clob;

    cursor c_tbackprocd is
      select *
        from tbackprocd
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and dtestrt = v_dtetimstrt
      order by numseq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tbackprocd loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('numseq',i.item01);
      obj_data.put('text',i.item02);
      obj_data.put('error_code',i.item03);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    v_header_detail := get_detail_header(v_codapp,global_v_coduser,v_codalw,v_dtetimstrt);
		if v_header_detail is not null then
			obj_header := json_object_t(v_header_detail);
			obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
			obj_header.put('desc_codempid',get_temploy_name(hcm_util.get_string_t(obj_header,'p_codempid_query'),global_v_lang));
			obj_header.put('dtestrt',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_stdate'),'dd/mm/yyyy')));
			obj_header.put('dteend',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'p_endate'),'dd/mm/yyyy')));
		end if;

    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('obj_rows',obj_row);
		obj_result.put('json_header',obj_header);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_hrpy41b(json_str_input in clob, json_str_output out clob) is
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_header      json_object_t := json_object_t();
    v_rcnt          number := 0;
    v_codapp        varchar2(10 char) := 'HRPY41B';
    v_header_detail clob;

    cursor c_tbackprocd is
      select *
        from tbackprocd
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and dtestrt = v_dtetimstrt
      order by numseq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tbackprocd loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('image',get_emp_img(i.item01));
      obj_data.put('codempid',i.item02);
      obj_data.put('desc_codempid',i.item03);
      obj_data.put('result',i.item04);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    v_header_detail := get_detail_header(v_codapp,global_v_coduser,v_codalw,v_dtetimstrt);
		if v_header_detail is not null then
			obj_header := json_object_t(v_header_detail);
			obj_header.put('dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
			obj_header.put('dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
			if hcm_util.get_string_t(obj_header,'p_newflag') = 'Y' then
				obj_header.put('newflag',get_label_name('HRPY41B',global_v_lang,'100'));
			else
				obj_header.put('newflag',get_label_name('HRPY41B',global_v_lang,'110'));
			end if;
			if hcm_util.get_string_t(obj_header,'p_flgretro') = '1' then
				obj_header.put('flgretro',get_label_name('HRPY41B',global_v_lang,'130'));
			else
				obj_header.put('flgretro',get_label_name('HRPY41B',global_v_lang,'140'));
			end if;
			obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
			obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
		end if;

    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('obj_rows',obj_row);
		obj_result.put('json_header',obj_header);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_hrpy44b(json_str_input in clob, json_str_output out clob) is
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_header      json_object_t := json_object_t();
    v_rcnt          number := 0;
    v_codapp        varchar2(10 char) := 'HRPY44B';
    v_header_detail clob;

    cursor c_tbackprocd is
      select *
        from tbackprocd
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and dtestrt = v_dtetimstrt
      order by numseq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tbackprocd loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('codempid',i.item01);
      obj_data.put('desc_codempid',i.item02);
      obj_data.put('result',i.item03);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    v_header_detail := get_detail_header(v_codapp,global_v_coduser,v_codalw,v_dtetimstrt);
		if v_header_detail is not null then
			obj_header := json_object_t(v_header_detail);
			obj_header.put('dtemthpay',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'p_dtemthpay'),global_v_lang));
			obj_header.put('dteyrepay',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'p_dteyrepay')));
			obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
			obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'p_typpayroll'),global_v_lang));
		end if;

    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('obj_rows',obj_row);
		obj_result.put('json_header',obj_header);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_hrpy70b(json_str_input in clob, json_str_output out clob) is
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_header      json_object_t := json_object_t();
    v_rcnt          number := 0;
    v_codapp        varchar2(10 char) := 'HRPY70B';
    v_header_detail clob;

    cursor c_tbackprocd is
      select *
        from tbackprocd
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and dtestrt = v_dtetimstrt
      order by numseq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tbackprocd loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('image',get_emp_img(i.item01));
      obj_data.put('codempid',i.item02);
      obj_data.put('desc_codempid',i.item03);
      obj_data.put('codpay',i.item04);
      obj_data.put('desc_codpay',i.item05);
      obj_data.put('desc_typpayroll',i.item07);
      obj_data.put('amt',i.item08);
      obj_data.put('max',i.item09);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    v_header_detail := get_detail_header(v_codapp,global_v_coduser,v_codalw,v_dtetimstrt);
		if v_header_detail is not null then
			obj_header := json_object_t(v_header_detail);
			obj_header.put('dtemonth',get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_header,'month'),global_v_lang));
			obj_header.put('dteyear',hcm_util.get_year_buddhist_era(hcm_util.get_string_t(obj_header,'year')));
			obj_header.put('desc_codcomp',get_tcenter_name(hcm_util.get_string_t(obj_header,'p_codcomp'),global_v_lang));
			obj_header.put('desc_typbank',get_tcodec_name('tcodbank',hcm_util.get_string_t(obj_header,'typbank'),global_v_lang));
			obj_header.put('dtepay',hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_header,'datePay'),'dd/mm/yyyy')));
			obj_header.put('desc_typpayroll',get_tcodec_name('tcodtypy',hcm_util.get_string_t(obj_header,'typpayroll'),global_v_lang));
		end if;

    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('obj_rows',obj_row);
		obj_result.put('json_header',obj_header);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure run_job(p_codapp varchar2,p_coduser varchar2,p_runno varchar2) is
    v_stmt    clob := '';
    v_err     boolean;
  begin
    begin
      select paramjson
        into v_stmt
        from tempbatchtask
       where codapp   = p_codapp
         and coduser  = p_coduser
         and runno    = p_runno;
    end;
    execute immediate v_stmt;
  end;
  --
  procedure call_batch(json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    obj_data_tmp        json_object_t;
    obj_data_hral71b    json_object_t;
    dtestrt             tbackproc.dtestrt%type;
    v_dteend            tbackproc.dteend%type;
    v_finish            boolean := true;
    v_min_total         number;
    v_hour              number;
    v_min               number;
    v_qtymintime        number := 0;
    v_message           varchar2(1000 char);
    v_flgavil           varchar2(1 char) := 'Y';
    v_stmt              clob;
    v_jobno             number;
    v_msg_error         varchar2(4000 char);
    v_dtetim_tmp        date;
    v_lang_tmp          varchar2(100 char);
    v_coduser_tmp       varchar2(100 char);
    v_max               number := 0;
    v_random            number;
    v_runno             varchar2(100 char);
    cursor c_tbackproc is
      select codapp
        from tbackproc
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and flgproc = 'P'
         and (sysdate - dtestrt)*1440 < nvl(get_tsetup_value('TIMEPROC'),1440);

    cursor c_tbackproc_lastproc is
      select dtestrt,dteend
        from tbackproc
       where codapp  = v_codapp
         and coduser = global_v_coduser
         and codalw  = v_codalw
         and flgproc = 'Y'
      order by dtestrt desc;
  begin
    initial_value(json_str_input);

    for r_tbackproc in c_tbackproc loop
      v_finish := false;
      exit;
    end loop;

    if v_finish then
      v_flgavil := 'Y';
      v_message := get_label_name('BATCHTASK',global_v_lang,'190');
      for r_tbackproc_lastproc in c_tbackproc_lastproc loop
        v_min_total := (r_tbackproc_lastproc.dteend - r_tbackproc_lastproc.dtestrt)*1440;
        v_hour      := trunc(v_min_total/60);
        v_min       := trunc(mod(v_min_total,60));

        v_qtymintime := v_min_total;
        v_message := get_label_name('BATCHTASK',global_v_lang,'140');
        if v_hour > 0 then
          v_message := v_message||' '||v_hour||' '||get_label_name('BATCHTASK',global_v_lang,'150');
        end if;
        if v_min > 0 then
          v_message := v_message||' '||v_min||' '||get_label_name('BATCHTASK',global_v_lang,'160');
        end if;

        if v_hour <= 0 and v_min <= 0 then
          v_min := '1';
          v_message := v_message||' '||v_min||' '||get_label_name('BATCHTASK',global_v_lang,'160');
        end if;
        exit;
      end loop;
    else
      v_flgavil := 'N';
      v_message := 'HR8855'||' '||get_terrorm_name('HR8855',global_v_lang);
    end if;

    -- call batch process
    if v_flgavil = 'Y' then
      -- start batch process
      v_dtetim := sysdate;
      obj_data_tmp := json_object_t(v_param_input);
      
      v_coduser_tmp := hcm_util.get_string_t(obj_data_tmp,'p_coduser');
      if v_coduser_tmp is null then
        obj_data_tmp.put('p_coduser',global_v_coduser);
      end if;
      
      v_lang_tmp := hcm_util.get_string_t(obj_data_tmp,'p_lang');
      if v_lang_tmp is null then
        obj_data_tmp.put('p_lang',global_v_lang);
      end if;
      
      v_dtetim_tmp := to_date(hcm_util.get_string_t(obj_data_tmp,'p_dtetim'),'ddmmyyyyhh24miss');
      if v_dtetim_tmp is null then
        obj_data_tmp.put('p_dtetim',to_char(v_dtetim,'ddmmyyyyhh24miss'));
      else
        v_dtetim := v_dtetim_tmp;
      end if;
      if v_codapp = 'HRAL71B' or v_codapp = 'M_HRAL71B' then
        obj_data_hral71b := json_object_t.parse(hcm_util.get_string_t(obj_data_tmp,'json_input_str'));
        obj_data_tmp.put('json_input_str',obj_data_hral71b);
      end if;
      v_param_input := obj_data_tmp.to_clob;

      -- check validate index before call main process
      v_msg_error := execute_desc('select '||v_codapp||'.check_index_batchtask('''||v_param_input||''') from dual');
      -- call main process
      if v_msg_error is null then
        -- job for call main process
        v_random  := trunc(dbms_random.value(1000,9999));
        v_runno   := to_char(sysdate,'yyyymmddhh24miss')||v_random;
        v_param_input := replace(v_param_input,'''','''''');
        v_stmt    := ' declare p_param_output clob; '||
                     ' begin '||v_procname||'('''||v_param_input||''',p_param_output); '||
                     '   delete from tempbatchtask '||
                     '    where codapp  = '''||v_codapp ||''''||
                     '      and coduser = '''||global_v_coduser ||''''||
                     '      and runno   = '''||v_runno ||''';'||
                     ' end;';
        begin
          insert into tempbatchtask values (v_codapp,global_v_coduser,v_runno,v_stmt);
        end;
        v_stmt    := 'begin hcm_batchtask.run_job('''||v_codapp||''','''||global_v_coduser||''','''||v_runno||'''); end;';
        begin
          dbms_job.submit(v_jobno,v_stmt);
          commit;
        exception when others then
          v_msg_error := 'Error: '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          v_message := v_msg_error;
          v_flgavil := 'N';
        end;

        if v_msg_error is null then
          if v_amt_process = 0 then -- set default std
            v_amt_process := 1;
            if v_codapp = 'HRAL24B' or v_codapp = 'M_HRAL24B' then
              v_amt_process := 3;
            elsif v_codapp = 'HRPM91B' or v_codapp = 'M_HRPM91B' then
              v_amt_process := 8;
            end if;
          end if;

          if v_amt_process = 1 then
            start_batch_process(
              p_codapp        => v_codapp,
              p_coduser       => global_v_coduser,
              p_codalw        => v_codapp,
              p_param_search  => v_param_input,
              p_jobno         => v_jobno,
              p_dtestrt       => v_dtetim
            );
          else
            for i in 1..v_amt_process loop
              start_batch_process(
                p_codapp        => v_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => v_codapp||to_char(i),
                p_param_search  => v_param_input,
                p_jobno         => v_jobno,
                p_dtestrt       => v_dtetim
              );
            end loop;
          end if;
        end if;
      else
        v_message := v_msg_error;
        v_flgavil := 'W';
        v_qtymintime := 0;
      end if;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('qtymintime',v_qtymintime);
    obj_data.put('message',v_message);
    obj_data.put('flgavail',v_flgavil);
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure start_batch_process(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_param_search clob default null,p_jobno number default null,p_dtestrt in out date) is
    v_sid           varchar2(100 char);
    v_serial        varchar2(100 char);
    v_check_count   number := 0;
    v_flginsert     boolean := true;
    json_obj        json_object_t;
    v_codapp        varchar2(100 char) := upper(p_codapp);
    v_codalw        varchar2(100 char) := upper(p_codalw);
    type a_varchar is table of tbackprocl.item01%type index by binary_integer;
       a_item       a_varchar;

  begin
    v_sid   := SYS_CONTEXT('USERENV','SID');
    begin
      select serial#
        into v_serial
        from sys.v_$session
       where sid = v_sid;
    exception when others then null;
    end;

    -- insert tbackproc
    v_flginsert := true;
    if v_codapp = 'HRAL71B' or v_codapp = 'M_HRAL71B' then
      if v_codalw <> v_codapp then
        begin
          select count(*) into v_check_count
            from tbackproc
           where codapp  = v_codapp
             and coduser = p_coduser
             and (codalw  = 'HRAL71B' or codalw  = 'M_HRAL71B')
             and dtestrt = p_dtestrt;
        exception when others then
          v_check_count := 0;
        end;
        if v_check_count = 0 then
          v_flginsert := false;
        end if;
      end if;
    else
      if p_dtestrt is null then
        p_dtestrt := sysdate;
      end if;
    end if;

    if v_flginsert then
      begin
        insert into tbackproc (codapp,coduser,codalw,dtestrt,flgproc,sid,serial,jobno)
                        values(v_codapp,p_coduser,v_codalw,p_dtestrt,'P',v_sid,v_serial,p_jobno);
      exception when dup_val_on_index then
        update tbackproc
           set flgproc = 'P',
               sid     = v_sid,
               serial  = v_serial,
               jobno   = p_jobno
         where codapp  = v_codapp
           and coduser = p_coduser
           and codalw  = v_codalw
           and dtestrt = p_dtestrt;
      end;

      -- insert tbackprocl
      for i in 1..20 loop
        a_item(i) := '';
      end loop;

      if p_param_search is not null then
        begin
          json_obj := json_object_t(p_param_search);
        exception when others then null;
        end;

        begin
          insert into tbackprocl (codapp,coduser,codalw,dtestrt,jsonstr,
                                  item01,item02,item03,item04,item05,item06,item07,item08,item09,item10,
                                  item11,item12,item13,item14,item15,item16,item17,item18,item19,item20)
                           values(v_codapp,p_coduser,v_codalw,p_dtestrt,p_param_search,
                                  a_item(1),a_item(2),a_item(3),a_item(4),a_item(5),a_item(6),a_item(7),a_item(8),a_item(9),a_item(10),
                                  a_item(11),a_item(12),a_item(13),a_item(14),a_item(15),a_item(16),a_item(17),a_item(18),a_item(19),a_item(20));
        exception when dup_val_on_index then
          update tbackprocl
             set jsonstr = p_param_search,
                 item01  = a_item(1),
                 item02  = a_item(2),
                 item03  = a_item(3),
                 item04  = a_item(4),
                 item05  = a_item(5),
                 item06  = a_item(6),
                 item07  = a_item(7),
                 item08  = a_item(8),
                 item09  = a_item(9),
                 item10  = a_item(10),
                 item11  = a_item(11),
                 item12  = a_item(12),
                 item13  = a_item(13),
                 item14  = a_item(14),
                 item15  = a_item(15),
                 item16  = a_item(16),
                 item17  = a_item(17),
                 item18  = a_item(18),
                 item19  = a_item(19),
                 item20  = a_item(20)
           where codapp  = v_codapp
             and coduser = p_coduser
             and codalw  = v_codalw
             and dtestrt = p_dtestrt;
        end;
        commit;
      end if;
    end if; -- if v_flginsert then
  end;

  procedure finish_batch_process(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_dtestrt date,
                                 p_flgproc varchar2 default 'Y',
                                 p_qtyproc number default 0,
                                 p_qtyerror number default 0,
                                 p_oracode varchar2 default null,
                                 p_typefile varchar2 default null,
                                 p_descproc varchar2 default null,
                                 p_filename1 varchar2 default null,p_pathfile1 varchar2 default null,
                                 p_filename2 varchar2 default null,p_pathfile2 varchar2 default null,
                                 p_filename3 varchar2 default null,p_pathfile3 varchar2 default null,
                                 p_filename4 varchar2 default null,p_pathfile4 varchar2 default null,
                                 p_filename5 varchar2 default null,p_pathfile5 varchar2 default null) is
    v_jobno         number;
    v_flgproc       tbackproc.flgproc%type;
    v_descproc      tbackproc.descproc%type;
    v_oracode       tbackproc.oracode%type;
    v_count_chk     number := 0;
    v_typefile      tbackproc.typefile%type;
    v_codapp        varchar2(100 char) := upper(p_codapp);
    v_codalw        varchar2(100 char) := upper(p_codalw);
  begin
    v_flgproc := p_flgproc;
    v_jobno := SYS_CONTEXT('USERENV', 'BG_JOB_ID');

    if v_codapp = 'HRAL3TB' or v_codapp = 'M_HRAL3TB' then
        v_descproc := get_label_name('HRAL3TBC1',global_v_lang,'180');
    elsif v_codapp = 'HRPY41B' or v_codapp = 'M_HRPY41B' then
        v_descproc := get_label_name('HRPY41B',global_v_lang,'230');
    elsif v_codapp = 'HRPY44B' or v_codapp = 'M_HRPY44B' then
        v_descproc := get_label_name('HRPY44B',global_v_lang,'160');
    elsif v_codapp = 'HRPY70B' or v_codapp = 'M_HRPY70B' then
        v_descproc := get_label_name('HRPY70B1',global_v_lang,'90');
    elsif v_codapp = 'HRPM91B' or v_codapp = 'M_HRPM91B' then
        v_descproc := get_label_name('HRPM91BP1',global_v_lang,'10');
    end if;

    -- check error data
    if v_descproc is not null then
      begin
        select count(*)
          into v_count_chk
          from tbackprocd
         where codapp  = v_codapp
           and coduser = p_coduser
           and codalw  = v_codalw
           and dtestrt = p_dtestrt;
      exception when others then
        v_count_chk := 0;
      end;
      if v_count_chk = 0 then
        v_descproc := null;
      end if;
    end if;

    v_oracode := substr(replace(replace(replace(p_oracode,'@#$%400'),'@#$%401'),'@#$%200'),1,600);
    v_oracode := replace(v_oracode,'<div style="color: #fff;font-size:10px;">',' - ');
    v_oracode := replace(v_oracode,'</div>');

    -- check if has some codalw task then delete codalw='HRAL71B'
    if (v_codapp = 'HRAL71B' or v_codapp = 'M_HRAL71B') and (v_codalw = 'HRAL71B' or v_codalw = 'M_HRAL71B') then
      begin
        update tbackproc
           set flgread = 'Y',
               flgnoti = 'Y'
         where codapp  =  v_codapp
           and codalw  =  v_codalw
           and coduser =  p_coduser
           and dtestrt =  p_dtestrt;
      exception when others then null;
      end;
      begin
        select count(*) into v_count_chk
          from tbackproc
         where codapp  =  v_codapp
           and codalw  <> v_codalw
           and coduser =  p_coduser
           and dtestrt =  p_dtestrt
           and flgproc =  'Y';
      exception when others then
        v_count_chk := 0;
      end;
      if v_count_chk > 0 then
        v_flgproc := 'Y';
      end if;
    end if;

    if p_filename1 is not null then
      v_typefile := 'F';
    end if;
    if v_descproc is not null then
      v_typefile := 'D';
    end if;

    if p_descproc is not null then
      if v_oracode is not null then
        v_oracode := v_oracode||' '||p_descproc;
      else
        v_oracode := p_descproc;
      end if;
    end if;
    begin
      update tbackproc
         set flgproc   = v_flgproc,
             dteend    = sysdate,
             qtyproc   = p_qtyproc,
             qtyerror  = p_qtyerror,
             typefile  = v_typefile,
             descproc  = v_descproc,
             filename1 = p_filename1,
             pathfile1 = p_pathfile1,
             filename2 = p_filename2,
             pathfile2 = p_pathfile2,
             filename3 = p_filename3,
             pathfile3 = p_pathfile3,
             filename4 = p_filename4,
             pathfile4 = p_pathfile4,
             filename5 = p_filename5,
             pathfile5 = p_pathfile5,
             oracode   = v_oracode
       where codapp    = v_codapp
         and coduser   = p_coduser
         and codalw    = v_codalw
         and dtestrt   = p_dtestrt
         and flgproc   = 'P';
    exception when others then null;
    end;
    commit;
  end;

  procedure insert_batch_detail(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_dtestrt date,
                                p_item01 varchar2 default null,p_item02 varchar2 default null,p_item03 varchar2 default null,
                                p_item04 varchar2 default null,p_item05 varchar2 default null,p_item06 varchar2 default null,
                                p_item07 varchar2 default null,p_item08 varchar2 default null,p_item09 varchar2 default null,
                                p_item10 varchar2 default null,p_item11 varchar2 default null,p_item12 varchar2 default null,
                                p_item13 varchar2 default null,p_item14 varchar2 default null,p_item15 varchar2 default null,
                                p_item16 varchar2 default null,p_item17 varchar2 default null,p_item18 varchar2 default null,
                                p_item19 varchar2 default null,p_item20 varchar2 default null) is
      v_numseq number := 0;
      v_codapp        varchar2(100 char) := upper(p_codapp);
      v_codalw        varchar2(100 char) := upper(p_codalw);
  begin
    begin
      select nvl(max(numseq),0) into v_numseq
        from tbackprocd
       where codapp  = v_codapp
         and coduser = p_coduser
         and codalw  = v_codalw
         and dtestrt = p_dtestrt;
    end;
    v_numseq := v_numseq + 1;

    begin
      insert into tbackprocd(codapp,coduser,codalw,dtestrt,numseq,
                            item01,item02,item03,item04,item05,item06,item07,item08,item09,item10,
                            item11,item12,item13,item14,item15,item16,item17,item18,item19,item20)
      values(v_codapp,p_coduser,v_codalw,p_dtestrt,v_numseq,
             p_item01,p_item02,p_item03,p_item04,p_item05,p_item06,p_item07,p_item08,p_item09,p_item10,
             p_item11,p_item12,p_item13,p_item14,p_item15,p_item16,p_item17,p_item18,p_item19,p_item20);
      commit;
    exception when others then null;
    end;
  end;

end;

/
