--------------------------------------------------------
--  DDL for Package Body HRPMC1B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC1B" is
  -- update 07/02/2023 14:35
  -- MAE  Modify 11/05/2023
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    b_index_dteimpot    := to_date(hcm_util.get_string_t(json_obj,'p_dteimpot'),'dd/mm/yyyy hh24:mi:ss');
    b_index_filename    := hcm_util.get_string_t(json_obj, 'p_filename');
    b_index_codimpot    := global_v_codempid;

    v_column(1)           := 'codempid';
    v_column(2)           := 'dteeffec';
    v_column(3)           := 'numseq';
    v_column(4)           := 'codtrn';
    v_column(5)           := 'codcomp';
    v_column(6)           := 'codpos';
    v_column(7)           := 'codjob';
    v_column(8)           := 'numlvl';
    v_column(9)           := 'codempmt';
    v_column(10)          := 'typpayroll';
    v_column(11)          := 'typemp';
    v_column(12)          := 'codbrlc';
    v_column(13)          := 'codcalen';
    v_column(14)          := 'flgatten';
    v_column(15)          := 'jobgrade';
    v_column(16)          := 'codgrpgl';
    v_column(17)          := 'stapost2';
    v_column(18)          := 'flgduepr';
    v_column(19)          := 'dteduepr';
    v_column(20)          := 'numreqst';
    v_column(21)          := 'flgadjin';
    v_column(22)          := 'desnote';
    v_column(23)          := 'amtincom1';
    v_column(24)          := 'amtincom2';
    v_column(25)          := 'amtincom3';
    v_column(26)          := 'amtincom4';
    v_column(27)          := 'amtincom5';
    v_column(28)          := 'amtincom6';
    v_column(29)          := 'amtincom7';
    v_column(30)          := 'amtincom8';
    v_column(31)          := 'amtincom9';
    v_column(32)          := 'amtincom10';

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  --
  
  --
  function check_dteyre (p_date in varchar2)
  return date is
    v_date		date;
    v_error		boolean := false;
    v_year    number;
    v_daymon	varchar2(50);
    v_text		varchar2(50);
    p_zyear		number;
  begin
    if to_number(to_char(sysdate,'yyyy')) > 2500 then
      if to_number(substr(p_date,-4,4)) > 2500 then
        p_zyear	:=	0;
      else
        p_zyear	:=	543;
      end if;
    else
      if to_number(substr(p_date,-4,4)) > 2500 then
        p_zyear	:=	-543;
      else
        p_zyear	:=	0;
      end if;
    end if;

    if p_date is not null then
      -- plus year --
      if length(substr( p_date, instr(p_date, '/', -1, 1)+1)) = 4 then
          v_year	  := substr(p_date,-4,4);
          v_year	  := v_year + p_zyear;
          v_daymon	  := substr(p_date,1,length(p_date)-4);
          v_text	  := to_char(v_daymon||v_year);
          v_year      := null;
          v_daymon    := null;
          -- plus year --
          v_date := to_date(v_text,'dd/mm/yyyy');
      end if;
    end if;

    return v_date;
  end;
  --
  function space_text(p_text varchar2,p_length number) return varchar2 is
    v_limit_loop    number := 100;
    v_bal_text      varchar2(2500);
    v_result_text   varchar2(3000);
    v_space         varchar2(1);
  begin
    v_bal_text  := p_text;
    for i in 1..v_limit_loop loop
      if length(v_bal_text) > p_length then
        v_result_text   := v_result_text||v_space||substr(v_bal_text,1,p_length);
        v_bal_text      := substr(v_bal_text,p_length + 1);
      else
        v_result_text   := v_result_text||v_space||v_bal_text;
        exit;
      end if;
      v_space   := ' ';
    end loop;
    return v_result_text;
  end;
  --
  procedure insert_timprtlog2	(p_numseq		in number,
                               p_status   in varchar2,
                               p_codempid	in varchar2,
                               p_remark		in varchar2,
                               p_key      in varchar2	)  is

     j 						number;
     k 						number;
     v_comments   varchar2(1000);
     data_file 	  varchar2(6000):= p_key;
     v_codcomp    temploy1.codcomp%type;
     v_codpos     temploy1.codpos%type;

    type array_value is table of varchar2(50) index by binary_integer;
         v_field     array_value;

  begin

    for i in 1..5 loop
        v_field(i) := null;
    end loop;
    if instr(data_file,',',1,1) > 0 then
      v_field(1) := substr(data_file,1,instr(data_file,',',1,1) - 1);
      for i in 2..5 loop
        j := instr(data_file,',',1,i - 1);
        k := instr(data_file,',',1,i);
        if j > 0 then
            if k > 0 then
              v_field(i) := substr(data_file,j + 1,k - j - 1);
            else
              v_field(i) := substr(data_file,j + 1);
            end if;
            v_field(i)   := trim(v_field(i));
        end if;
      end loop;
    else
      v_field(1) :=	p_key;
    end if;

    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp	 := null;
      v_codpos 	 := null;
    end;

    insert into	timprtlog2 (codimpot,dteimpot,typimpot,
                            numseq,status,remark,
                            codempid,codcomp,codpos,
                            flgempl,data1,data2,
                            data3,data4,data5,
                            codcreate,coduser,dteupd)
         values
                          (b_index_codimpot,b_index_dteimpot,b_index_typimpot,
                           p_numseq,p_status,p_remark,
                           p_codempid,v_codcomp,v_codpos,
                           null,v_field(1),v_field(2),
                           v_field(3),v_field(4),v_field(5),
                           global_v_coduser,global_v_coduser,trunc(sysdate)
                           );
  end;
  --
  procedure insert_timprtlog1 (p_filename  in varchar2,
                               p_qtyrow    in number,
                               p_status    in varchar2)is

    v_qtyrow         number:= p_qtyrow;

     cursor c1 is
      select count(decode(status,'1',1,null)) qtynew,
             count(decode(status,'2',1,null)) qtychg,
             count(decode(status,'3',1,null)) qtynchg,
             count(decode(status,'4',1,null)) qtyerror,
             count(decode(flgempl,'Y',1,null)) qtyeffwk,
             count(*) qtyrow
         from timprtlog2
        where codimpot = b_index_codimpot
          and dteimpot = b_index_dteimpot
          and typimpot = b_index_typimpot
     group by codimpot,dteimpot,typimpot;


  begin
    if p_status = 'C' then
       v_qtyrow := null;
    end if;
    for i in c1  loop
      insert into timprtlog1 (codimpot,dteimpot,typimpot,
                              filename,qtyrow,qtynew,
                              qtychg,qtynchg,qtyerror,
                              qtyeffwk,status,errornum,
                              codcreate,coduser,dteupd)
              values          (b_index_codimpot,b_index_dteimpot,b_index_typimpot,
                              p_filename,i.qtyrow,i.qtynew,
                              i.qtychg,i.qtynchg,i.qtyerror,
                              i.qtyeffwk,p_status,v_qtyrow,
                              global_v_coduser,global_v_coduser,trunc(sysdate));
    end loop;
  end;
  -- end insert_timprtlog1
  procedure find_totnet (p_codcomp    in varchar2,
                         p_codempmt   in varchar2,
                         p_amtincom1  in number,
                         p_amtincom2  in number,
                         p_amtincom3  in number,
                         p_amtincom4  in number,
                         p_amtincom5  in number,
                         p_amtincom6  in number,
                         p_amtincom7  in number,
                         p_amtincom8  in number,
                         p_amtincom9  in number,
                         p_amtincom10 in number,
                         p_sumhur     in out number,
                         p_sumday     in out number,
                         p_summth     in out number
                         ) is

    v_sumhur	number := 0;
    v_sumday	number := 0;
    v_summth	number := 0;

  begin
    get_wage_income(hcm_util.get_codcomp_level(p_codcomp,'1'),p_codempmt,
                    nvl(p_amtincom1,0), nvl(p_amtincom2,0) ,
                    nvl(p_amtincom3,0), nvl(p_amtincom4,0) ,
                    nvl(p_amtincom5,0), nvl(p_amtincom6,0) ,
                    nvl(p_amtincom7,0), nvl(p_amtincom8,0) ,
                    nvl(p_amtincom9,0), nvl(p_amtincom10,0),
                    v_sumhur ,v_sumday,v_summth );

                    v_sumhur := round(v_sumhur,2);
                    v_sumday := round(v_sumday,2);
                    v_summth := round(v_summth,2);

    p_sumhur := nvl(v_sumhur,0);
    p_sumday := nvl(v_sumday,0);
    p_summth := nvl(v_summth,0);

  end;
  --
  function check_submit return varchar2 is
      v_errorfile   varchar2(100);
--    in_file   		text_io.file_type;
--    err_file    	text_io.file_type;  --exp_text error;
    linebuf  		varchar2(6000);
    data_file 		varchar2(6000);
    v_max           number;
    v_remark    	varchar2(6000);
    v_tenum         varchar2(500);
    v_flgpass		boolean;
    v_error			boolean;
    v_exist			boolean;
    v_dteeffec  	date;
    v_dteduepr      date;
    v_dteappr       date;
    v_dtecancel     date;
    v_codempid		varchar2(50);
    v_staemp    	varchar2(10);
    v_codtable      varchar2(50);
    v_codcurr       varchar2(30);
    v_codtrn        varchar2(30);
    v_stareq		treqest1.stareq%type;
    v_qtyact		treqest2.qtyact%type;
    v_qtyreq		treqest2.qtyreq%type;
    v_update        varchar2(10);
    v_codcompt 		ttmovemt.codcompt%type;
    v_codposnow 	ttmovemt.codposnow%type;
    v_codjobt 		ttmovemt.codjobt%type;
    v_numlvlt 		ttmovemt.numlvlt%type;
    v_codbrlct 		ttmovemt.codbrlct%type;
    v_codcalet      ttmovemt.codcalet%type;
    v_flgattet      ttmovemt.flgattet%type;
    v_codedlv       ttmovemt.codedlv%type;
    v_codsex        ttmovemt.codsex%type;
    v_codempmtt     ttmovemt.codempmtt%type;
    v_typpayrolt    ttmovemt.typpayrolt%type;
    v_typempt       ttmovemt.typempt%type;
    v_dteempmt      date;
    v_jobgradet     ttmovemt.jobgradet%type;
    v_codgrpglt     ttmovemt.codgrpglt%type;
    v_typmove       tcodmove.typmove%type;

    v_sumhur		number := 0;
    v_sumday		number := 0;
    v_summth		number := 0;
    v_numtemp		number := 0;

    v_amt1      	number;
    v_amt2      	number;
    v_amt3      	number;
    v_amt4      	number;
    v_amt5      	number;
    v_amt6      	number;
    v_amt7      	number;
    v_amt8      	number;
    v_amt9      	number;
    v_amt10     	number;

    v_amtincom1 	varchar2(30);
    v_amtincom2		varchar2(30);
    v_amtincom3 	varchar2(30);
    v_amtincom4 	varchar2(30);
    v_amtincom5 	varchar2(30);
    v_amtincom6 	varchar2(30);
    v_amtincom7 	varchar2(30);
    v_amtincom8	 	varchar2(30);
    v_amtincom9 	varchar2(30);
    v_amtincom10 	varchar2(30);
    v_amtinmth      varchar2(30);
    v_amtindte      varchar2(30);
    v_amtinhr       varchar2(30);

    v_adjust1   	number;
    v_adjust2   	number;
    v_adjust3   	number;
    v_adjust4   	number;
    v_adjust5   	number;
    v_adjust6   	number;
    v_adjust7   	number;
    v_adjust8   	number;
    v_adjust9   	number;
    v_adjust10  	number;

    v_amtincadj1 	varchar2(30);
    v_amtincadj2	varchar2(30);
    v_amtincadj3 	varchar2(30);
    v_amtincadj4 	varchar2(30);
    v_amtincadj5 	varchar2(30);
    v_amtincadj6 	varchar2(30);
    v_amtincadj7 	varchar2(30);
    v_amtincadj8	varchar2(30);
    v_amtincadj9 	varchar2(30);
    v_amtincadj10   varchar2(20);
    v_amtinadmth    varchar2(30);
    v_amtinaddte    varchar2(30);
    v_amtinadhr 	varchar2(30);

    v_pctadj1   	number;
    v_pctadj2   	number;
    v_pctadj3   	number;
    v_pctadj4   	number;
    v_pctadj5   	number;
    v_pctadj6   	number;
    v_pctadj7   	number;
    v_pctadj8   	number;
    v_pctadj9   	number;
    v_pctadj10  	number;

    tm_numseq       number := 0;
--    v_typmove     varchar2(15);
    v_seq           number;
    v_dteefpos		date;
    v_dteeflvl		date;
    v_dteefstep		date;
    v_flgsecu		boolean;
    v_zupdsal   	varchar2(4);
    v_flg_error     varchar2(3000);

    v_staappr       varchar2(1000);
    v_approvno      varchar2(1000)   := '0';
    v_routeno       varchar2(1000);
    v_msgerr        varchar2(1000);
    v_response      varchar2(5000);
    v_checkapp      boolean := false;
    v_check         varchar2(20);
    
    v_codcompy      tcompny.codcompy%type;
    v_json_input    clob;
    v_json_codincom clob;
    param_json      json_object_t;
    param_json_row  json_object_t;
    type t_number is table of number index by binary_integer;
    v_amtmax        t_number;
    v_codincom      text;
    
    cursor c_ttmovemt is
      select dteeffec,codtrn,codcomp,codpos,codjob,
             numlvl,codbrlc,codcalen,flgatten,stapost2,
             codempmt,typpayroll,typemp,staupd,flgadjin,
             stddec(amtincom1,codempid,global_v_chken) amtincom1 ,
             stddec(amtincom2,codempid,global_v_chken) amtincom2,
             stddec(amtincom3,codempid,global_v_chken) amtincom3,
             stddec(amtincom4,codempid,global_v_chken) amtincom4,
             stddec(amtincom5,codempid,global_v_chken) amtincom5,
             stddec(amtincom6,codempid,global_v_chken) amtincom6,
             stddec(amtincom7,codempid,global_v_chken) amtincom7,
             stddec(amtincom8,codempid,global_v_chken) amtincom8,
             stddec(amtincom9,codempid,global_v_chken) amtincom9,
             stddec(amtincom10,codempid,global_v_chken) amtincom10
        from ttmovemt
       where codempid  = v_codempid
         and dteeffec  = v_dteeffec
        -- and codtrn    = v_codtrn
         and numseq    = v_seq ;
         
      cursor c_ttmovemt2 is
      select dteeffec,staupd,numseq
        from ttmovemt
       where codempid  = v_codempid
         and rownum = 1
         order by dteeffec desc, numseq desc;

  begin
    v_flg_error       := 'N';
    b_index_typimpot  := 'PMT2';
    v_error 	 := false;
    v_remark   := null;
    v_total     := v_total + 1;
    v_codempid 	:= upper(trim(substr(v_text(1),1,10)));
    for i in 1..22 loop -- check key
      if i  in (1,2,3,4,21) then
        if v_text(i) is null then
          v_error   := true;
          v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(i)||')';
        end if;
      end if;

      if i = 1 then
        v_error := hcm_validate.check_length(v_text(i),'TEMPLOY1','CODEMPID',v_max);
        if v_error then
          v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
        end if;
        if v_codempid is not null then
          begin
            select codcomp,codpos,codjob,numlvl,codbrlc,
                   staemp,codcalen,flgatten,codedlv,codsex,
                   codempmt,typpayroll,typemp,dteempmt,codcurr,
                   jobgrade,	codgrpgl,
                   dteefpos,	dteeflvl,	dteefstep
              into v_codcompt,v_codposnow,v_codjobt,v_numlvlt,v_codbrlct,
                   v_staemp,v_codcalet,v_flgattet,v_codedlv,v_codsex,
                   v_codempmtt,v_typpayrolt,v_typempt,v_dteempmt,v_codcurr,
                   v_jobgradet,v_codgrpglt,
                   v_dteefpos, v_dteeflvl, v_dteefstep
              from temploy1 a,temploy3 b
             where a.codempid = v_codempid
             and   a.codempid = b.codempid ;
              if v_staemp = '9' then
                v_error	  := true;
                v_remark	:= v_remark||','||get_errorm_name('HR2101',global_v_lang);
              elsif v_staemp = '0' then
                v_error	  := true;
                v_remark	:= v_remark||','||get_errorm_name('HR2102',global_v_lang);
              end if;
          exception when no_data_found then
            v_error	  := true;
            v_remark	:= v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
          end;
        end if;
        v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
          v_error	  := true;
          v_remark	:= v_remark||','||get_errorm_name('HR3007',global_v_lang);
        end if;
      elsif i = 2 then
        v_error  := hcm_validate.check_date(v_text(i));

--v_error:= true;
        if v_error then
          v_remark := v_remark||','||v_head(i)||' '||get_errorm_name('HR2025',global_v_lang)||' ('||v_text(i)||')';
--3007        end if;
        else
--3007
                v_dteeffec  := check_dteyre(v_text(i));
                if v_dteeffec < v_dteempmt then
                  v_error   := true;
                  v_remark	:= v_remark||','||get_errorm_name('PM0054',global_v_lang);
                end if;
--3007
        end if;
--3007
      elsif i = 3 then
        v_error := hcm_validate.check_number(v_text(i));
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(i)||' - '||v_text(i)||')';
        else
          v_seq := v_text(i) ;
        end if;
      elsif i = 4  and v_text(i) is not null  then
        v_error   := hcm_validate.check_length(v_text(i),'TCODMOVE','CODCODEC',v_max);
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
        end if;
        v_error := hcm_validate.check_tcodcodec('tcodmove','codcodec = '''||v_text(i)||''' ');
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TCODMOVE)';
        else
          begin
            select typmove
              into v_typmove
              from tcodmove
             where codcodec = v_text(i);
          exception when no_data_found then
            v_typmove := null;
          end;
        end if;
        if upper(v_text(i)) in ('0001','0002','0003','0004','0005','0006','0007') then
          v_error   := true;
          v_remark	:= v_remark||','||get_errorm_name('PM0036',global_v_lang)||' ('||v_text(i)||')';
        end if;
      elsif i = 5 and v_text(i) is not null  then
        v_text(i) := upper(v_text(i));
        v_error   := hcm_validate.check_length(v_text(i),'TCENTER','CODCOMP',v_max);
        if v_error then
          v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
        end if;
        v_error := hcm_validate.check_tcodcodec('tcenter','codcomp = '''||v_text(i)||''' ');
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TCENTER)';
        end if;
      elsif i in (6,7,9,10,11,12,13,15,16) and v_text(i) is not null   then
        v_text(i) := upper(v_text(i));
        if i = 6 then
          v_error := hcm_validate.check_tcodcodec('tpostn','codpos = '''||v_text(i)||''' ');
          v_codtable := 'TPOSTN';
        elsif i = 7 then
          v_error := hcm_validate.check_tcodcodec('tjobcode','codjob = '''||v_text(i)||''' ');
          v_codtable := 'TJOBCODE';
        else
          if i = 9 then
            v_codtable := 'TCODEMPL';
          elsif i = 10 then
            v_codtable := 'TCODTYPY';
          elsif i = 11 then
            v_codtable := 'TCODCATG';
          elsif i = 12 then
            v_codtable := 'TCODLOCA';
          elsif i = 13 then
            v_codtable := 'TCODWORK';
          elsif i = 15 then
            v_codtable := 'TCODJOBG';
          elsif i = 16 then
            v_codtable := 'TCODGRPGL';
          end if;
          if i = 6 then
            v_error	:= hcm_validate.check_length(v_text(i),v_codtable,'CODPOS',v_max);
          elsif i = 7 then
            v_error	:= hcm_validate.check_length(v_text(i),v_codtable,'CODJOB',v_max);
          else
            v_error	:= hcm_validate.check_length(v_text(i),v_codtable,'CODCODEC',v_max);
          end if;
          if v_error then
            v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
          end if;
          v_error := hcm_validate.check_tcodcodec(v_codtable,'codcodec = '''||v_text(i)||''' ');
        end if;
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' ('''||v_codtable||''') value = '||v_text(i);
        elsif i = 6 then
          if not v_error and v_codposnow <> v_text(6) then --check change codpos
            if v_typmove <> '8' then
              v_remark	:= v_remark||','||get_errorm_name('PM0128',global_v_lang);
              v_error   := true;         
            end if;
          end if;
        end if;
      elsif i = 8 and v_text(i) is not null  then
        v_error := hcm_validate.check_number(v_text(i));
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(i)||' - '||v_text(i)||')';
        end if;
        if length(v_text(i)) > 2 then
          v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: 2)';
        end if;
      elsif i = 14 and v_text(i) is not null  then
        if length(v_text(i)) > 1 then
          v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: 1)';
        end if;
        if upper(v_text(i)) not in ('Y','N') then
          v_error  := true;
          v_remark := v_remark||','||v_head(i)||' '||get_errorm_name('HR2057',global_v_lang)||' (''Y'',''N'')';
        end if;
      end if;
    
      if i = 17 then -- STAPOST2
--        v_typmove := null;
--        begin
--          select typmove into v_typmove
--            from tcodmove
--           where codcodec = upper(v_text(4));
--        exception when no_data_found then
--          v_typmove := null;
--        end;
        if v_typmove  = 'M' then
          if v_text(17) is null and v_codposnow <> v_text(6) then
            v_error   := true;
            v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(17)||')';
          end if;
        end if;
        if v_text(i) is not null then
          if length(v_text(i)) > 1 then
            v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: 1)';
          end if;
          if upper(v_text(i)) not in ('0','1','2') then
            v_error  := true;
            v_remark := v_remark||','||v_head(i)||' '||get_errorm_name('HR2057',global_v_lang)||' (''0'',''1'',''2'')';
          end if;
        end if;
      end if;

    end loop; -- end check key
    
      --> Peerasak || SEA-HR2201 || 03022023
      if v_text(17) is null then
        v_error   := true;
        v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(17)||')';
      end if;
      --> Peerasak || SEA-HR2201 || 03022023

      if v_text(18) is not null then -- FLGDUEPR
        v_text(18):=  nvl(v_text(18),'N') ;
        if length(v_text(18)) > 1 then
          v_remark	:= get_errorm_name('HR6591',global_v_lang)||' ('||v_head(18)||' Max: 1)';
        end if;
        if upper(v_text(18)) not in ('Y','N') then
          v_error  := true;
          v_remark := v_remark||','||v_head(18)||' '||get_errorm_name('HR2057',global_v_lang)||' (''Y'',''N'')';
        end if;
      end if;

      if v_text(19) is not null then
        v_error  := hcm_validate.check_date(v_text(19));
        if v_error then
          v_remark := v_remark||','||v_head(19)||' '||get_errorm_name('HR2025',global_v_lang)||' ('||v_text(19)||')';
        end if;
      else
        if nvl(v_text(18),'N') = 'Y' then
          v_error   := true;
            v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(19)||')';
        end if;
      end if;

      if v_text(20) is not null then
        begin
          select stareq into  v_stareq
            from treqest1
           where numreqst = v_text(20);
          if v_stareq = 'C' then
            v_error  := true;
            v_remark := v_remark||','||get_errorm_name('HR4502',global_v_lang)||' (TREQEST1)';
          elsif v_stareq = 'X' then
            v_error  := true;
            v_remark := v_remark||','||get_errorm_name('HR5006',global_v_lang)||' (TREQEST1)';
          else
            begin
              select qtyact,qtyreq into v_qtyact,v_qtyreq
                from treqest2
               where numreqst = v_text(20)
                 and codpos		= v_text(6);
              if v_qtyact + 1 > v_qtyreq then
                v_error  := true;
                v_remark := v_remark||','||get_errorm_name('HR4502',global_v_lang)||' (TREQEST2)';
              end if;
            exception when no_data_found then
              v_error  := true;
              v_remark := v_remark||','||get_errorm_name('HR5005',global_v_lang)||' (TREQEST2)';
            end;
          end if;
        exception when no_data_found then
          v_error  := true;
          v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TREQEST1)';
        end;
      end if;

      if v_text(21) is not null then
        if length(v_text(21)) > 1 then
          v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(21)||' Max: 1)';
        end if;
        if upper(v_text(21)) not in ('Y','N') then
          v_error  := true;
          v_remark := v_remark||','||v_head(21)||' '||get_errorm_name('HR2057',global_v_lang)||' (''Y'',''N'')';
        end if;
      end if;
      if v_text(22) is not null then
        v_error :=  hcm_validate.check_length(v_text(22),'TTMOVEMT','DESNOTE',v_max);
        if v_error then
          v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(22)||' Max: '||v_max||')';
        end if;
      end if;

      for i in 23..32 loop
        v_error := hcm_validate.check_number(v_text(i));
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(i)||' - '||v_text(i)||')';
        end if;
      end loop;
      
      v_checkapp := chk_flowmail.check_approve ('HRPM4DE', v_codempid, v_approvno, null, null, null, v_check);
      if not v_checkapp and v_check = 'HR2010' then
        v_error   := true;
        v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TFWMAILC)';
      end if;
    
    v_codcompy        := hcm_util.get_codcomp_level(v_text(5),1);
    v_json_input      := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||v_codempmtt||'","p_lang":"'||global_v_lang||'"}';
    v_json_codincom   := hcm_pm.get_codincom(v_json_input);
    param_json        := json_object_t(v_json_codincom);
    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_amtmax(i + 1)     := hcm_util.get_string_t(param_json_row,'amtmax');
      v_codincom(i + 1)   := hcm_util.get_string_t(param_json_row,'codincom');
    end loop;
    
    --<<user36 STA3590210 02/02/2016
    for i in 1..10 loop
/*      if nvl(v_text(22 + i),0) > 0 and v_amtmax(i) is not null and v_codincom is not null then
        if nvl(v_text(22 + i),0) > v_amtmax(i) then
*/
      begin 
        if v_text(22 + i) != '' then
          v_numtemp := to_number(v_text(22 + i));
          if nvl(to_number(v_text(22 + i)),0) > 0 and v_amtmax(i) is not null and v_codincom is not null then
            if nvl(to_number(v_text(22 + i)),0) > v_amtmax(i) then
              v_error   := true;
              v_remark  := v_remark||','||get_errorm_name('PM0066',global_v_lang)||' ('||v_head(22 + i)||' - '||'Amount Max: '||v_amtmax(i)||')';
              exit;
            end if;
          elsif v_codincom is null then
            v_text(22 + i)  := null;
          end if;
        end if;
      exception when value_error then
          v_remark  := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' '||v_head(22 + i)||'';
          exit;
        end;
    end loop;
    
    if v_error then
      v_flg_error := 'Y';
      v_rec_error := v_rec_error + 1;
    else
      v_rec_tran := v_rec_tran + 1;
      v_exist     := false;
      v_codtrn    := upper(v_text(4)) ;
      v_update    := 'N' ;

      v_text(5)     := nvl(v_text(5),v_codcompt) ;
      v_text(6)     := nvl(v_text(6),v_codposnow) ;
      v_text(7)     := nvl(v_text(7),v_codjobt) ;
      v_text(8)     := nvl(v_text(8),v_numlvlt) ;
      v_text(9)     := nvl(v_text(9),v_codempmtt) ;
      v_text(10)    := nvl(v_text(10),v_typpayrolt) ;
      v_text(11)    := nvl(v_text(11),v_typempt) ;
      v_text(12)    := nvl(v_text(12),v_codbrlct) ;
      v_text(13)    := nvl(v_text(13),v_codcalet) ;
      v_text(14)    := nvl(v_text(14),v_flgattet) ;
      begin
        select stddec(amtincom1,codempid,global_v_chken),
               stddec(amtincom2,codempid,global_v_chken),
               stddec(amtincom3,codempid,global_v_chken),
               stddec(amtincom4,codempid,global_v_chken),
               stddec(amtincom5,codempid,global_v_chken),
               stddec(amtincom6,codempid,global_v_chken),
               stddec(amtincom7,codempid,global_v_chken),
               stddec(amtincom8,codempid,global_v_chken),
               stddec(amtincom9,codempid,global_v_chken),
               stddec(amtincom10,codempid,global_v_chken)
          into v_amt1,v_amt2,v_amt3,v_amt4,v_amt5,
               v_amt6,v_amt7,v_amt8,v_amt9,v_amt10
          from temploy3
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;

      for r_ttmovemt in c_ttmovemt loop
        v_exist   := true;
        if r_ttmovemt.codtrn  <>  upper(v_text(4)) then
          v_remark := v_remark||','||get_errorm_name('HR2005',global_v_lang);
          v_flg_error := 'Y';
          v_rec_error := v_rec_error + 1;
          v_rec_tran  := v_rec_tran - 1;
          exit;
        end if;
        if r_ttmovemt.staupd in ('C','U') then
          v_remark := v_remark||','||get_errorm_name('HR8014',global_v_lang);
          v_flg_error := 'Y';
          v_rec_error := v_rec_error + 1;
          v_rec_tran  := v_rec_tran - 1;
          exit;
        elsif r_ttmovemt.staupd = 'A' then
          v_remark := v_remark||','||get_errorm_name('HR8011',global_v_lang);
          v_flg_error := 'Y';
          v_rec_error := v_rec_error + 1;
          v_rec_tran  := v_rec_tran - 1;
          exit;
        elsif r_ttmovemt.staupd = 'N' then
          v_remark := v_remark||','||get_errorm_name('HR8014',global_v_lang);
          v_flg_error := 'Y';
          v_rec_error := v_rec_error + 1;
          v_rec_tran  := v_rec_tran - 1;
          exit;
        end if;
      end loop;
--MAE  Modify 11/05/2023
--      for r_ttmovemt2 in c_ttmovemt2 loop
--          if v_dteeffec < r_ttmovemt2.dteeffec then
--              if r_ttmovemt2.staupd in ('C','U') then
--                  v_remark := v_remark||','||get_errorm_name('PM0140',global_v_lang);
--                  v_flg_error := 'Y';
--                  v_rec_error := v_rec_error + 1;
--                  v_rec_tran  := v_rec_tran - 1;
--                  exit;
--              end if;
--          elsif v_dteeffec = r_ttmovemt2.dteeffec then
--            if r_ttmovemt2.numseq <= v_seq then
--               if r_ttmovemt2.staupd in ('C','U') then
--                  v_remark := v_remark||','||get_errorm_name('PM0140',global_v_lang);
--                  v_flg_error := 'Y';
--                  v_rec_error := v_rec_error + 1;
--                  v_rec_tran  := v_rec_tran - 1;
--                  exit;
--              end if;
--            end if;
--          end if;
--      end loop;
      
      if not v_flgpass then
        v_flg_error := 'Y';
        v_rec_error := v_rec_error + 1;
        v_remark := get_errorm_name('HR3007',global_v_lang);
      end if;	  --not v_flgpass

    end if; -- v_error
    return  v_remark;
  end; --check_submit
  --
  procedure validate_field_submit(json_str_input in clob,json_str_output out clob) is
    json_str          json_object_t;
    param_import      json_object_t;
    param_import_row  json_object_t;
    v_error_remark    varchar2(5000);
    obj_data          json_object_t;
    obj_row           json_object_t;
    v_rcnt            number  := 0;
  begin
    param_import      := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    obj_row   := json_object_t();

    for i in 1..32 loop
      v_head(i)   := get_label_name('HRPMC1BC1',global_v_lang, to_char(10 + (i*10)));
    end loop;
    for i in 0..param_import.get_size-1 loop
      obj_data      := json_object_t();
      v_rcnt        := v_rcnt + 1;
      obj_data.put('coderror','200');
      param_import_row    := hcm_util.get_json_t(param_import,to_char(i));
      for k in 1..v_column.count loop
        v_text(k)         := hcm_util.get_string_t(param_import_row,v_column(k));
        if k = 5 then
          obj_data.put(v_column(k),space_text(v_text(k),40));
        else
          obj_data.put(v_column(k),v_text(k));
        end if;
      end loop;
      v_error_remark      := substr(check_submit,2);
      if v_error_remark is not null then
        obj_data.put('flgerror','Y');
        obj_data.put('descerror',v_error_remark);
      else
        obj_data.put('flgerror','N');
        obj_data.put('descerror','');
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  -- end validate_field_submit
  procedure submit_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    validate_field_submit(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_ttmovemt(p_new out number,p_no_change out number,p_update out number) is
    v_codempid    varchar2(10);
    v_remark    	varchar2(4000 char);
    v_error       boolean;
    v_flgpass			boolean;

    v_numseq    	number := 0;

    v_codcompt 		ttmovemt.codcompt%type;
    v_codposnow 	ttmovemt.codposnow%type;
    v_codjobt 		ttmovemt.codjobt%type;
    v_numlvlt 		ttmovemt.numlvlt%type;
    v_codbrlct 		ttmovemt.codbrlct%type;
    v_staemp    	varchar2(1);
    v_codcalet    ttmovemt.codcalet%type;
    v_flgattet    ttmovemt.flgattet%type;
    v_codedlv     ttmovemt.codedlv%type;
    v_codsex      ttmovemt.codsex%type;
    v_codempmtt   ttmovemt.codempmtt%type;
    v_typpayrolt  ttmovemt.typpayrolt%type;
    v_typempt     ttmovemt.typempt%type;
    v_dteempmt    date;
    v_codcurr     varchar2(4);
    v_jobgradet   ttmovemt.jobgradet%type;
    v_codgrpglt   ttmovemt.codgrpglt%type;
    v_dteefpos		date;
    v_dteeflvl		date;
    v_dteefstep		date;

    v_dteeffec  	date;
    v_dteduepr    date;

    v_pkey        varchar2(500);
    v_exist				boolean;

    v_codtrn      varchar2(4);
    v_update      varchar2(1);
    v_amtincom1 	varchar2(20);
    v_amtincom2		varchar2(20);
    v_amtincom3 	varchar2(20);
    v_amtincom4 	varchar2(20);
    v_amtincom5 	varchar2(20);
    v_amtincom6 	varchar2(20);
    v_amtincom7 	varchar2(20);
    v_amtincom8	 	varchar2(20);
    v_amtincom9 	varchar2(20);
    v_amtincom10 	varchar2(20);

    v_amt1      	number;
    v_amt2      	number;
    v_amt3      	number;
    v_amt4      	number;
    v_amt5      	number;
    v_amt6      	number;
    v_amt7      	number;
    v_amt8      	number;
    v_amt9      	number;
    v_amt10     	number;

    v_adjust1   	number;
    v_adjust2   	number;
    v_adjust3   	number;
    v_adjust4   	number;
    v_adjust5   	number;
    v_adjust6   	number;
    v_adjust7   	number;
    v_adjust8   	number;
    v_adjust9   	number;
    v_adjust10  	number;

    v_pctadj1   	number;
    v_pctadj2   	number;
    v_pctadj3   	number;
    v_pctadj4   	number;
    v_pctadj5   	number;
    v_pctadj6   	number;
    v_pctadj7   	number;
    v_pctadj8   	number;
    v_pctadj9   	number;
    v_pctadj10  	number;

    v_amtincadj1 	varchar2(20);
    v_amtincadj2	varchar2(20);
    v_amtincadj3 	varchar2(20);
    v_amtincadj4 	varchar2(20);
    v_amtincadj5 	varchar2(20);
    v_amtincadj6 	varchar2(20);
    v_amtincadj7 	varchar2(20);
    v_amtincadj8	varchar2(20);
    v_amtincadj9 	varchar2(20);
    v_amtincadj10 varchar2(20);
    v_amtinadmth  varchar2(20);
    v_amtinaddte  varchar2(20);
    v_amtinadhr 	varchar2(20);

    v_sumhur			number := 0;
    v_sumday			number := 0;
    v_summth			number := 0;

    v_seq         number ;
    v_amtinhr     varchar2(20);

    v_staappr           varchar2(500);
    v_approvno          varchar2(500);
    v_routeno           varchar2(500);
    v_msgerr            varchar2(500);

    cursor c_ttmovemt is
      select dteeffec,codtrn,codcomp,codpos,codjob,
             numlvl,codbrlc,codcalen,flgatten,stapost2,
             codempmt,typpayroll,typemp,staupd,flgadjin,flgduepr,dteduepr,
             stddec(amtincom1,codempid,global_v_chken) amtincom1 ,
             stddec(amtincom2,codempid,global_v_chken) amtincom2,
             stddec(amtincom3,codempid,global_v_chken) amtincom3,
             stddec(amtincom4,codempid,global_v_chken) amtincom4,
             stddec(amtincom5,codempid,global_v_chken) amtincom5,
             stddec(amtincom6,codempid,global_v_chken) amtincom6,
             stddec(amtincom7,codempid,global_v_chken) amtincom7,
             stddec(amtincom8,codempid,global_v_chken) amtincom8,
             stddec(amtincom9,codempid,global_v_chken) amtincom9,
             stddec(amtincom10,codempid,global_v_chken) amtincom10
        from ttmovemt
       where codempid  = v_codempid
         and dteeffec  = v_dteeffec
        -- and codtrn    = v_codtrn
         and numseq    = v_seq ;
  begin
    p_new         := 0;
    p_no_change   := 0;
    p_update      := 0;

    b_index_typimpot  := 'PMT2';
    for i in 1..v_rec_text.count loop
      v_numseq  := v_numseq + 1;
      v_codempid 	:= upper(trim(substr(v_rec_text(i)(1),1,10)));
      if v_rec_text(i)(2) is not null then
        v_dteeffec  := check_dteyre(v_rec_text(i)(2));
      end if;
      if v_rec_text(i)(19) is not null then
        v_dteduepr  := check_dteyre(v_rec_text(i)(19));
      end if;
      v_seq   := v_rec_text(i)(3);
      
      v_pkey  := to_char(v_dteeffec,'dd/mm/yyyy')||','||v_rec_text(i)(4);
      if v_rec_text(i)(33) = 'Y' then
        insert_timprtlog2(v_numseq,'4',v_codempid,v_rec_text(i)(34),v_pkey);
      else
        begin
          select codcomp,codpos,codjob,numlvl,codbrlc,
                 staemp,codcalen,flgatten,codedlv,codsex,
                 codempmt,typpayroll,typemp,dteempmt,codcurr,
                 jobgrade,	codgrpgl,
                 dteefpos,	dteeflvl,	dteefstep
            into v_codcompt,v_codposnow,v_codjobt,v_numlvlt,v_codbrlct,
                 v_staemp,v_codcalet,v_flgattet,v_codedlv,v_codsex,
                 v_codempmtt,v_typpayrolt,v_typempt,v_dteempmt,v_codcurr,
                 v_jobgradet,v_codgrpglt,
                 v_dteefpos, v_dteeflvl, v_dteefstep
            from temploy1 a,temploy3 b
           where a.codempid = v_codempid
           and   a.codempid = b.codempid ;
        exception when no_data_found then
          null;
        end;
        v_rec_tran := v_rec_tran + 1;
        v_exist     := false;
        v_codtrn    := upper(v_rec_text(i)(4)) ;
        v_update    := 'N' ;

        v_rec_text(i)(5)     := nvl(v_rec_text(i)(5),v_codcompt) ;
        v_rec_text(i)(6)     := nvl(v_rec_text(i)(6),v_codposnow) ;
        v_rec_text(i)(7)     := nvl(v_rec_text(i)(7),v_codjobt) ;
        v_rec_text(i)(8)     := nvl(v_rec_text(i)(8),v_numlvlt) ;
        v_rec_text(i)(9)     := nvl(v_rec_text(i)(9),v_codempmtt) ;
        v_rec_text(i)(10)    := nvl(v_rec_text(i)(10),v_typpayrolt) ;
        v_rec_text(i)(11)    := nvl(v_rec_text(i)(11),v_typempt) ;
        v_rec_text(i)(12)    := nvl(v_rec_text(i)(12),v_codbrlct) ;
        v_rec_text(i)(13)    := nvl(v_rec_text(i)(13),v_codcalet) ;
        v_rec_text(i)(14)    := nvl(v_rec_text(i)(14),v_flgattet) ;
        begin
          select stddec(amtincom1,codempid,global_v_chken),
                 stddec(amtincom2,codempid,global_v_chken),
                 stddec(amtincom3,codempid,global_v_chken),
                 stddec(amtincom4,codempid,global_v_chken),
                 stddec(amtincom5,codempid,global_v_chken),
                 stddec(amtincom6,codempid,global_v_chken),
                 stddec(amtincom7,codempid,global_v_chken),
                 stddec(amtincom8,codempid,global_v_chken),
                 stddec(amtincom9,codempid,global_v_chken),
                 stddec(amtincom10,codempid,global_v_chken)
            into v_amt1,v_amt2,v_amt3,v_amt4,v_amt5,
                   v_amt6,v_amt7,v_amt8,v_amt9,v_amt10
            from temploy3
           where codempid = v_codempid;
        exception when no_data_found then
          null;
        end;

        for r_ttmovemt in c_ttmovemt loop
            v_exist   := true;
            if r_ttmovemt.staupd <> 'P'   then
                p_no_change    := p_no_change + 1;
                insert_timprtlog2(v_numseq,'3',v_codempid,v_remark,v_pkey);
            elsif r_ttmovemt.codtrn  <>  upper(v_rec_text(i)(4)) then
                v_remark := get_errorm_name('HR2005',global_v_lang);
                insert_timprtlog2(v_numseq,'4',v_codempid,v_remark,v_pkey);
            else
                if r_ttmovemt.codcomp 	 = nvl(upper(v_rec_text(i)(5)),r_ttmovemt.codcomp)   and
                   r_ttmovemt.codpos 	   = nvl(upper(v_rec_text(i)(6)),r_ttmovemt.codpos)    and
                   r_ttmovemt.codjob 	   = nvl(upper(v_rec_text(i)(7)),r_ttmovemt.codjob)    and
                   r_ttmovemt.numlvl 	   = nvl(v_rec_text(i)(8),r_ttmovemt.numlvl)           and
                   r_ttmovemt.codbrlc 	 = nvl(upper(v_rec_text(i)(12)),r_ttmovemt.codbrlc)  and
                   r_ttmovemt.codcalen 	 = nvl(upper(v_rec_text(i)(13)),r_ttmovemt.codcalen) and
                   r_ttmovemt.flgatten 	 = nvl(upper(v_rec_text(i)(14)),r_ttmovemt.flgatten) and
                   r_ttmovemt.codempmt 	 = nvl(upper(v_rec_text(i)(9)),r_ttmovemt.codempmt)  and
                   r_ttmovemt.typpayroll = nvl(upper(v_rec_text(i)(10)),r_ttmovemt.typpayroll)  and
                   r_ttmovemt.typemp	   = nvl(upper(v_rec_text(i)(11)),r_ttmovemt.typemp)   and
                   r_ttmovemt.flgadjin	 = nvl(upper(v_rec_text(i)(21)),r_ttmovemt.flgadjin)   and
                   r_ttmovemt.flgduepr	 = nvl(upper(v_rec_text(i)(18)),r_ttmovemt.flgduepr)   and
                   r_ttmovemt.dteduepr	 = nvl(v_dteduepr,r_ttmovemt.dteduepr)   and

                   (upper(nvl(v_rec_text(i)(21),'N')) <> 'Y' or 
                   (upper(nvl(v_rec_text(i)(21),'N')) = 'Y' and
                     nvl(r_ttmovemt.amtincom1,0)	 = nvl(to_number(v_rec_text(i)(23)),nvl(r_ttmovemt.amtincom1,0))   and
                     nvl(r_ttmovemt.amtincom2,0)	 = nvl(to_number(v_rec_text(i)(24)),nvl(r_ttmovemt.amtincom2,0))   and
                     nvl(r_ttmovemt.amtincom3,0)	 = nvl(to_number(v_rec_text(i)(25)),nvl(r_ttmovemt.amtincom3,0))   and
                     nvl(r_ttmovemt.amtincom4,0)	 = nvl(to_number(v_rec_text(i)(26)),nvl(r_ttmovemt.amtincom4,0))   and
                     nvl(r_ttmovemt.amtincom5,0)	 = nvl(to_number(v_rec_text(i)(27)),nvl(r_ttmovemt.amtincom5,0))   and
                     nvl(r_ttmovemt.amtincom6,0)	 = nvl(to_number(v_rec_text(i)(28)),nvl(r_ttmovemt.amtincom6,0))   and
                     nvl(r_ttmovemt.amtincom7,0)	 = nvl(to_number(v_rec_text(i)(29)),nvl(r_ttmovemt.amtincom7,0))   and
                     nvl(r_ttmovemt.amtincom8,0)	 = nvl(to_number(v_rec_text(i)(30)),nvl(r_ttmovemt.amtincom8,0))   and
                     nvl(r_ttmovemt.amtincom9,0)	 = nvl(to_number(v_rec_text(i)(31)),nvl(r_ttmovemt.amtincom9,0))   and
                     nvl(r_ttmovemt.amtincom10,0)  = nvl(to_number(nvl(v_rec_text(i)(32),v_amt10)),nvl(r_ttmovemt.amtincom10,0))
                    )) then

                   insert_timprtlog2(v_numseq,'3',v_codempid,v_remark,v_pkey);
                   p_no_change    := p_no_change + 1;
                else
                   v_update := 'Y' ;
                end if;
            end if;
        end loop;
      
        if not v_exist  or v_update = 'Y' then
            v_flgpass := true ;
            v_sumhur	:= 0;
            v_sumday	:= 0;
            v_summth	:= 0;

            v_adjust1 := 0; v_adjust2 := 0; v_adjust3 := 0; v_adjust4 := 0; v_adjust5  := 0;
            v_adjust6 := 0; v_adjust7 := 0; v_adjust8 := 0; v_adjust9 := 0; v_adjust10 := 0;

              if upper(nvl(v_rec_text(i)(21),'N')) = 'Y' then
                  find_totnet (upper(v_rec_text(i)(5)),upper(v_rec_text(i)(9)),
                               to_number(nvl(v_rec_text(i)(23),0)),to_number(nvl(v_rec_text(i)(24),0)),
                               to_number(nvl(v_rec_text(i)(25),0)),to_number(nvl(v_rec_text(i)(26),0)),
                               to_number(nvl(v_rec_text(i)(27),0)),to_number(nvl(v_rec_text(i)(28),0)),
                               to_number(nvl(v_rec_text(i)(29),0)),to_number(nvl(v_rec_text(i)(30),0)),
                               to_number(nvl(v_rec_text(i)(31),0)),to_number(nvl(v_rec_text(i)(32),0)),
                               v_sumhur,v_sumday,v_summth);

                  v_amtinhr     := stdenc(nvl(v_sumhur,0),v_codempid,global_v_chken);

                  v_amtincom1 	:= stdenc(to_number(nvl(v_rec_text(i)(23),v_amt1)),v_codempid,global_v_chken);
                  v_amtincom2		:= stdenc(to_number(nvl(v_rec_text(i)(24),v_amt2)),v_codempid,global_v_chken);
                  v_amtincom3 	:= stdenc(to_number(nvl(v_rec_text(i)(25),v_amt3)),v_codempid,global_v_chken);
                  v_amtincom4 	:= stdenc(to_number(nvl(v_rec_text(i)(26),v_amt4)),v_codempid,global_v_chken);
                  v_amtincom5 	:= stdenc(to_number(nvl(v_rec_text(i)(27),v_amt5)),v_codempid,global_v_chken);
                  v_amtincom6 	:= stdenc(to_number(nvl(v_rec_text(i)(28),v_amt6)),v_codempid,global_v_chken);
                  v_amtincom7 	:= stdenc(to_number(nvl(v_rec_text(i)(29),v_amt7)),v_codempid,global_v_chken);
                  v_amtincom8	 	:= stdenc(to_number(nvl(v_rec_text(i)(30),v_amt8)),v_codempid,global_v_chken);
                  v_amtincom9   := stdenc(to_number(nvl(v_rec_text(i)(31),v_amt9)),v_codempid,global_v_chken);
                  v_amtincom10 	:= stdenc(to_number(nvl(v_rec_text(i)(32),v_amt10)),v_codempid,global_v_chken);


                  v_adjust1  := to_number(nvl(v_rec_text(i)(23),v_amt1)) - nvl(v_amt1,0);
                  v_adjust2  := to_number(nvl(v_rec_text(i)(24),v_amt2)) - nvl(v_amt2,0);
                  v_adjust3  := to_number(nvl(v_rec_text(i)(25),v_amt3)) - nvl(v_amt3,0);
                  v_adjust4  := to_number(nvl(v_rec_text(i)(26),v_amt4)) - nvl(v_amt4,0);
                  v_adjust5  := to_number(nvl(v_rec_text(i)(27),v_amt5)) - nvl(v_amt5,0);
                  v_adjust6  := to_number(nvl(v_rec_text(i)(28),v_amt6)) - nvl(v_amt6,0);
                  v_adjust7  := to_number(nvl(v_rec_text(i)(29),v_amt7)) - nvl(v_amt7,0);
                  v_adjust8  := to_number(nvl(v_rec_text(i)(30),v_amt8)) - nvl(v_amt8,0);
                  v_adjust9  := to_number(nvl(v_rec_text(i)(31),v_amt9)) - nvl(v_amt9,0);
                  v_adjust10 := to_number(nvl(v_rec_text(i)(32),v_amt10)) - nvl(v_amt10,0);

                  if nvl(v_amt1,0) <> 0 then
                    v_pctadj1  := (v_adjust1/nvl(v_amt1,0)) * 100;
                  end if;
                  if nvl(v_amt2,0) <> 0 then
                    v_pctadj2  := (v_adjust2/nvl(v_amt2,0)) * 100;
                  end if;
                  if nvl(v_amt3,0) <> 0 then
                    v_pctadj3  := (v_adjust3/nvl(v_amt3,0)) * 100;
                  end if;
                  if nvl(v_amt4,0) <> 0 then
                    v_pctadj4  := (v_adjust4/nvl(v_amt4,0)) * 100;
                  end if;
                  if nvl(v_amt5,0) <> 0 then
                    v_pctadj5  := (v_adjust5/nvl(v_amt5,0)) * 100;
                  end if;
                  if nvl(v_amt6,0) <> 0 then
                    v_pctadj6  := (v_adjust6/nvl(v_amt6,0)) * 100;
                  end if;
                  if nvl(v_amt7,0) <> 0 then
                    v_pctadj7  := (v_adjust7/nvl(v_amt7,0)) * 100;
                  end if;
                  if nvl(v_amt8,0) <> 0 then
                    v_pctadj8  := (v_adjust8/nvl(v_amt8,0)) * 100;
                  end if;
                  if nvl(v_amt9,0) <> 0 then
                    v_pctadj9  := (v_adjust9/nvl(v_amt9,0)) * 100;
                  end if;
                  if nvl(v_amt10,0) <> 0 then
                    v_pctadj10 := (v_adjust10/nvl(v_amt10,0)) * 100;
                  end if;
            else
              find_totnet (upper(v_rec_text(i)(5)),upper(v_rec_text(i)(9)),
                           v_amt1,v_amt2,
                           v_amt3,v_amt4,
                           v_amt5,v_amt6,
                           v_amt7,v_amt8,
                           v_amt9,v_amt10,
                           v_sumhur,v_sumday,v_summth);

              v_amtinhr     := stdenc(nvl(v_sumhur,0),v_codempid,global_v_chken);

              v_amtincom1 	:= stdenc(v_amt1,v_codempid,global_v_chken);
              v_amtincom2		:= stdenc(v_amt2,v_codempid,global_v_chken);
              v_amtincom3 	:= stdenc(v_amt3,v_codempid,global_v_chken);
              v_amtincom4 	:= stdenc(v_amt4,v_codempid,global_v_chken);
              v_amtincom5 	:= stdenc(v_amt5,v_codempid,global_v_chken);
              v_amtincom6 	:= stdenc(v_amt6,v_codempid,global_v_chken);
              v_amtincom7 	:= stdenc(v_amt7,v_codempid,global_v_chken);
              v_amtincom8	 	:= stdenc(v_amt8,v_codempid,global_v_chken);
              v_amtincom9   := stdenc(v_amt9,v_codempid,global_v_chken);
              v_amtincom10 	:= stdenc(v_amt10,v_codempid,global_v_chken);
            end if;

            v_amtincadj1 	:= stdenc(nvl(v_adjust1,0),v_codempid,global_v_chken);
            v_amtincadj2	:= stdenc(nvl(v_adjust2,0),v_codempid,global_v_chken);
            v_amtincadj3 	:= stdenc(nvl(v_adjust3,0),v_codempid,global_v_chken);
            v_amtincadj4 	:= stdenc(nvl(v_adjust4,0),v_codempid,global_v_chken);
            v_amtincadj5 	:= stdenc(nvl(v_adjust5,0),v_codempid,global_v_chken);
            v_amtincadj6 	:= stdenc(nvl(v_adjust6,0),v_codempid,global_v_chken);
            v_amtincadj7 	:= stdenc(nvl(v_adjust7,0),v_codempid,global_v_chken);
            v_amtincadj8	:= stdenc(nvl(v_adjust8,0),v_codempid,global_v_chken);
            v_amtincadj9 	:= stdenc(nvl(v_adjust9,0),v_codempid,global_v_chken);
            v_amtincadj10 := stdenc(nvl(v_adjust10,0),v_codempid,global_v_chken);

            if v_update = 'N' then
            insert into ttmovemt (codempid,dteeffec,numseq,
                                  codtrn,codcomp,codpos,
                                  codjob,numlvl,codbrlc,
                                  codcalen,flgatten,stapost2,
                                  flgduepr,dteduepr,numreqst,
                                  codcompt,codposnow,codjobt,
                                  numlvlt,codbrlct,codcalet,
                                  flgattet,flgadjin,desnote,
                                  codedlv,codsex,staupd,
                                  codempmtt,codempmt,typpayrolt,
                                  typpayroll,typempt,typemp,
                                  amtincom1,amtincom2,amtincom3,
                                  amtincom4,amtincom5,amtincom6,
                                  amtincom7,amtincom8,amtincom9,
                                  amtincom10,amtincadj1,amtincadj2,
                                  amtincadj3,amtincadj4,amtincadj5,
                                  amtincadj6,amtincadj7,amtincadj8,
                                  amtincadj9,amtincadj10,amtothr,
                                  flggroup,codcurr,codreq,
                                  coduser, 	jobgrade ,codgrpgl,
                                  jobgradet,codgrpglt,
                                  dteefpos,	dteeflvl,	dteefstep, codcreate)
                    values (v_codempid,v_dteeffec,v_seq,
                            v_rec_text(i)(4),v_rec_text(i)(5),v_rec_text(i)(6),
                            v_rec_text(i)(7),v_rec_text(i)(8),v_rec_text(i)(12),
                            v_rec_text(i)(13),v_rec_text(i)(14),v_rec_text(i)(17),
                            nvl(v_rec_text(i)(18),'N'),v_dteduepr,v_rec_text(i)(20),
                            v_codcompt,v_codposnow,v_codjobt,
                            v_numlvlt,v_codbrlct,v_codcalet,
                            v_flgattet,v_rec_text(i)(21),v_rec_text(i)(22),
                            v_codedlv,v_codsex,'P',
                            v_codempmtt,v_rec_text(i)(9),v_typpayrolt,
                            v_rec_text(i)(10),v_typempt,v_rec_text(i)(11),
                            v_amtincom1,v_amtincom2,v_amtincom3,
                            v_amtincom4,v_amtincom5,v_amtincom6,
                            v_amtincom7,v_amtincom8,v_amtincom9,
                            v_amtincom10,v_amtincadj1,v_amtincadj2,
                            v_amtincadj3,v_amtincadj4,v_amtincadj5,
                            v_amtincadj6,v_amtincadj7,v_amtincadj8,
                            v_amtincadj9,v_amtincadj10,v_amtinhr,
                            'N',v_codcurr,global_v_codempid,
                            global_v_coduser , nvl(v_rec_text(i)(15),v_jobgradet) ,nvl(v_rec_text(i)(16),v_codgrpglt ),
                            v_jobgradet,v_codgrpglt,
                            v_dteefpos,	v_dteeflvl, v_dteefstep, global_v_coduser);

                            insert_timprtlog2(v_numseq,'1',v_codempid,v_remark,v_pkey);
                p_new   := p_new + 1;
              else
              
                 update ttmovemt
                 set    codcomp = v_rec_text(i)(5),
                        codpos = v_rec_text(i)(6),
                        codjob = v_rec_text(i)(7),
                        numlvl = v_rec_text(i)(8),
                        typemp = v_rec_text(i)(11),
                        codbrlc = v_rec_text(i)(12),
                        codcalen = v_rec_text(i)(13),
                        flgatten = v_rec_text(i)(14),
                        stapost2 = v_rec_text(i)(17),
                        flgduepr = nvl(v_rec_text(i)(18),'N'),
                        dteduepr = v_dteduepr,
                        numreqst = v_rec_text(i)(20),
                        flgadjin = v_rec_text(i)(21),
                        desnote  = v_rec_text(i)(22),
                        amtincom1 = v_amtincom1,
                        amtincom2 = v_amtincom2,
                        amtincom3 = v_amtincom3,
                        amtincom4 = v_amtincom4,
                        amtincom5 = v_amtincom5,
                        amtincom6 = v_amtincom6,
                        amtincom7 = v_amtincom7,
                        amtincom8 = v_amtincom8,
                        amtincom9 = v_amtincom9,
                        amtincom10 = v_amtincom10,
                        amtincadj1 = v_amtincadj1,
                        amtincadj2 = v_amtincadj2,
                        amtincadj3 = v_amtincadj3,
                        amtincadj4 = v_amtincadj4,
                        amtincadj5 = v_amtincadj5,
                        amtincadj6 = v_amtincadj6,
                        amtincadj7 = v_amtincadj7,
                        amtincadj8 = v_amtincadj8,
                        amtincadj9 = v_amtincadj9,
                        amtincadj10 = v_amtincadj10,
                        amtothr = v_amtinhr,
                        codcurr = v_codcurr,
                        codreq = global_v_codempid,
                        jobgrade = nvl(v_rec_text(i)(15),v_jobgradet) ,
                        codgrpgl = nvl(v_rec_text(i)(16),v_codgrpglt ),
                        dteefpos  = v_dteefpos,
                        dteeflvl  = v_dteeflvl,
                        dteefstep = v_dteefstep,
                        coduser   = global_v_coduser
                  where codempid = v_codempid
                  and   codtrn   = v_codtrn
                  and   numseq   = v_seq
                  and   dteeffec = v_dteeffec ;

              insert_timprtlog2(v_numseq,'2',v_codempid,v_remark,v_pkey);
              
              p_update   := p_update + 1;
            end if;
        end if;

        if not v_flgpass then
          v_remark := get_errorm_name('HR3007',global_v_lang);
          insert_timprtlog2(v_numseq,'4',v_codempid,v_remark,v_pkey);
        end if;	  --not v_flgpass
      end if;
    end loop;
  end;
  -- end save_ttmovemt
  procedure generate_field_save(json_str_input in clob) is
    json_str          json_object_t;
    param_import      json_object_t;
    param_import_row  json_object_t;
    v_col_cnt         number;
  begin
    param_import    := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    v_col_cnt       := v_column.count;
    for i in 1..v_col_cnt loop
      v_head(i)   := get_label_name('HRPMC1BC1',global_v_lang, to_char(10 + (i*10)));
    end loop;

    for i in 0..param_import.get_size-1 loop
      param_import_row    := hcm_util.get_json_t(param_import,to_char(i));
      for k in 1..v_col_cnt loop
        v_rec_text(i+1)(k)           := hcm_util.get_string_t(param_import_row,v_column(k));
      end loop;
      v_rec_text(i+1)(v_col_cnt+1)   := hcm_util.get_string_t(param_import_row,'flgerror');
      v_rec_text(i+1)(v_col_cnt+2)   := hcm_util.get_string_t(param_import_row,'descerror');

      v_total                      := v_total + 1;
    end loop;
  end;
  -- end generate_field
  procedure process_data (json_str_input in clob, json_str_output out clob) is
    v_new           number;
    v_no_change     number;
    v_update        number;
    v_response      varchar2(4000 char);

    obj_row         json_object_t;
  begin
    initial_value(json_str_input);
    generate_field_save(json_str_input);
    save_ttmovemt(v_new,v_no_change,v_update);
    if v_total > 0 then
      insert_timprtlog1 (b_index_filename,v_total,'C');
    end if;

    commit;

    obj_row   := json_object_t();
    param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response  := get_response_message(null,param_msg_error,global_v_lang);
    obj_row.put('coderror','200');
    obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
    obj_row.put('new',v_new);
    obj_row.put('nochange',v_no_change);
    obj_row.put('update',v_update);

    json_str_output := obj_row.to_clob;

  exception when others then
    insert_timprtlog1(b_index_filename,v_total,'E');
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end process_data;
end HRPMC1B;

/
