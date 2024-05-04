--------------------------------------------------------
--  DDL for Package Body HCM_PM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_PM" is
--ST11 06/03/2018 14:10
function get_codincom (json_str in clob ) return clob is

    json_obj         json;
    obj_row         json;
    obj_data        json;
    json_str_output clob;
    v_row           number  := 0;

    v_codcompy  tcontpmd.codcompy%type;
    v_dteeffec     date;
    v_codempmt  tcontpmd.codempmt%type;


   type p_num is table of number index by binary_integer;
           v_amtmax    p_num;

   type p_char is table of tcontpms.codincom1%type index by binary_integer;
           v_codincom  p_char;
           v_unitcal      p_char;

   type p_char2 is table of tinexinf.descpayt%type index by binary_integer;
           v_desincom  p_char2;
           v_desunit     p_char2;

  begin

-- get_parameter
--'{"p_codcompy":"TJS","p_dteeffec":"06032018","p_codempmt":"T","p_lang":"102"}'

      json_obj            := json(json_str);
      v_codcompy        := json_ext.get_string(json_obj,'p_codcompy');
      v_dteeffec          := to_date(json_ext.get_string(json_obj,'p_dteeffec'),'dd/mm/yyyy');
      v_codempmt       := json_ext.get_string(json_obj,'p_codempmt');
      global_v_lang       := json_ext.get_string(json_obj,'p_lang');

     for i in 1..10 loop
          v_codincom(i)   := null;
          v_unitcal(i)       := null;
          v_amtmax(i)     := null;
          v_desincom(i)   := null;
          v_desunit(i)      := null;
     end loop;

			begin
  			 	select codincom1,codincom2,codincom3,codincom4,codincom5,
  			 	          codincom6,codincom7,codincom8,codincom9,codincom10
   				  into  v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),
                    v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
 					 from  tcontpms a
        where a.codcompy = v_codcompy
            and a.dteeffec in (select max(b.dteeffec)
                                      from tcontpms b
                                    where b.codcompy = a.codcompy
                                        and b.dteeffec <= nvl(v_dteeffec,sysdate));
			exception when no_data_found then
	      null ;
			end;

			begin
  			 	select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
  			 	          unitcal6,unitcal7,unitcal8,unitcal9,unitcal10,
                    amtmax1,amtmax2,amtmax3,amtmax4,amtmax5,
                    amtmax6,amtmax7,amtmax8,amtmax9,amtmax10
   				   into v_unitcal(1),v_unitcal(2),v_unitcal(3),v_unitcal(4),v_unitcal(5),
                    v_unitcal(6),v_unitcal(7),v_unitcal(8),v_unitcal(9),v_unitcal(10) ,
                    v_amtmax(1),  v_amtmax(2),  v_amtmax(3), v_amtmax(4),  v_amtmax(5),
                    v_amtmax(6),  v_amtmax(7),  v_amtmax(8), v_amtmax(9),  v_amtmax(10)
 					  from tcontpmd a
          where a.codcompy =  v_codcompy
					    and a.codempmt = v_codempmt
					    and a.dteeffec = (select max(b.dteeffec)
                                        from tcontpmd b
                                      where b.codcompy  = a.codcompy
                                          and b.codempmt = a.codempmt
                                          and b.dteeffec <= sysdate);
			exception when no_data_found then
	      null ;
			end;

     for i in 1..10 loop
          if v_codincom(i) is null then
             v_unitcal(i)       := null;
             v_amtmax(i)     := null;
          end if;
        v_desincom(i)  := get_tinexinf_name(v_codincom(i),global_v_lang);
        v_desunit(i)   := get_tlistval_name('NAMEUNIT',v_unitcal(i),global_v_lang);
     end loop;

     obj_row := json();
     obj_data := json();
    for i in 1..10 loop
      v_row := v_row+1;
      obj_data.put('codincom',   v_codincom(i));
      obj_data.put('desincom',   v_desincom(i));
      obj_data.put('desunit',      v_desunit(i));
      obj_data.put('amtmax',     v_amtmax(i));
      msg_err(v_row);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
--return
--      {"0":{"codincom":"01","desincom":"Salary/Wage","desunit":"Per Month","amtmax":100000},
--       "1":{"codincom":"02","desincom":"Cost of Living Allowance","desunit":"Per Month","amtmax":50000},
--       .....
--       "8":{"codincom":"","desincom":"   ","desunit":"","amtmax":null},
--       "9":{"codincom":"","desincom":"   ","desunit":"","amtmax":null}
--       }

      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);

      return (json_str_output);

  exception when others then
    obj_data := json();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_char;

    return (json_str_output);

  end; --function get_codincom

function  check_over_income(json_str          in clob )   return clob is

  json_obj        json;
  v_row           number  := 0;
  v_numseq      number  := 0;

  obj_data        json;
  json_str_output clob;

  v_codcompy  tcontpmd.codcompy%type;
  v_dteeffec     date;
  v_codempmt  tcontpmd.codempmt%type;

  type p_char is table of varchar2(20) index by binary_integer;
         v_codincom         p_char;
         v_codincom2       p_char;
         v_flgover             p_char;

  type p_num is table of number index by binary_integer;
         v_amtmax          p_num;
         v_amtincom2      p_num;

begin

    for i in 1..10 loop
      v_codincom(i)     := null;
      v_amtmax(i)       := null;
      v_codincom2(i)   := null;
      v_amtincom2(i)   := null;
      v_flgover(i)     := 'N';
    end loop;

-- get_parameter
-- '{"p_codcompy":"TJS","p_dteeffec":"06032018","p_codempmt":"T"  ,
-- "p_codincom1":"01","p_amtincom1":"10000",
-- "p_codincom2":"02","p_amtincom2":"100000",
-- "p_codincom3":"03","p_amtincom3":"10000",
--"p_codincom4":"","p_amtincom4":"",
--"p_codincom5":"","p_amtincom5":"",
--"p_codincom6":"","p_amtincom6":"",
--"p_codincom7":"","p_amtincom7":"",
--"p_codincom8":"","p_amtincom8":"",
--"p_codincom9":"","p_amtincom9":"",
--"p_codincom10":"","p_amtincom10":""}'

    json_obj             := json(json_str);
    v_codcompy        := upper(json_ext.get_string(json_obj,'p_codcompy'));
    v_dteeffec          := to_date(json_ext.get_string(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    v_codempmt       := upper(json_ext.get_string(json_obj,'p_codempmt'));
    for i in 1..10 loop
      v_codincom2(i)      := upper(json_ext.get_string(json_obj,'p_codincom'||i));
      v_amtincom2(i)      :=         json_ext.get_string(json_obj, 'p_amtincom'||i);
    end loop;

  begin
    select codincom1,codincom2,codincom3,codincom4,codincom5,
           codincom6,codincom7,codincom8,codincom9,codincom10
    into   v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),
           v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
    from tcontpms a
  where a.codcompy = v_codcompy
      and a.dteeffec in (select max(b.dteeffec)
                                from tcontpms b
                              where b.codcompy = a.codcompy
                                  and b.dteeffec <= nvl(v_dteeffec,sysdate));
	exception when no_data_found then null;
  end;

  begin
    select amtmax1,amtmax2,amtmax3,amtmax4,amtmax5,
              amtmax6,amtmax7,amtmax8,amtmax9,amtmax10
      into   v_amtmax(1),v_amtmax(2),v_amtmax(3),v_amtmax(4),v_amtmax(5),
           v_amtmax(6),v_amtmax(7),v_amtmax(8),v_amtmax(9),v_amtmax(10)
    from   tcontpmd a
  where  a.codcompy   = v_codcompy
      and  a.codempmt  = v_codempmt
      and  a.dteeffec = (select max(b.dteeffec)
                                   from  tcontpmd b
                                where  b.codcompy = a.codcompy
                                   and  b.codempmt = a.codempmt
                                   and  b.dteeffec <= sysdate);
	exception when no_data_found then null ;
  end;

  v_numseq := 0;
  v_row      := 0;

  obj_data := json();
  obj_data.put('numseq',   v_numseq  );
  obj_data.put('codincom', 'N' );
  obj_data.put('flgover', 'N');
  for i in 1..10 loop
    v_numseq  := i;
    if v_codincom2(i) = v_codincom(i) and v_amtmax(i) is not null then
       if v_amtincom2(i) > v_amtmax(i) then
          v_flgover(i) := 'Y';
          obj_data.put('numseq',   v_numseq  );
          obj_data.put('codincom', v_amtincom2(i) );
          obj_data.put('flgover', v_flgover(i) );
          exit;
       end if;
    end if;
  end loop;
--return
--      {"numseq":3, "codincom":"03","flgover":"Y"}   --Over amount
--      {"numseq":0, "codincom":"N","flgover":"N"}    --No Over amount
--       }
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
     return(json_str_output);
exception when others then
    obj_data := json();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_char;

    return (json_str_output);
end;--function  chk_over_income
----------------------------------------------------------------------------------

function get_tincpos ( json_str          in clob )   return clob is

  json_obj        json;
  v_row           number  := 0;
  obj_row         json;
  obj_data        json;
  json_str_output clob;

  v_flgtype    varchar2(1);
  v_temploy1  temploy1%rowtype;
  v_chken      varchar2(4);
  v_flgcond     varchar2(4);

	v_flgfound		boolean;
	v_cond				varchar2(1000);
	v_stmt				varchar2(1000);

    type p_num is table of number index by binary_integer;
         v_amtincom      p_num;

  cursor c_tincpos is
	  select codfrm,syncond,
	  			 amtproba1,amtproba2,amtproba3,amtproba4,amtproba5,amtproba6,amtproba7,amtproba8,amtproba9,amtproba10,
	  			 amtpacup1,amtpacup2,amtpacup3,amtpacup4,amtpacup5,amtpacup6,amtpacup7,amtpacup8,amtpacup9,amtpacup10
		  from tincpos
		 where codcompy = hcm_util.get_codcomp_level(v_temploy1.codcomp,'1')
		   and dteeffec = (select max(dteeffec)
                               from tincpos
                              where codcompy = hcm_util.get_codcomp_level(v_temploy1.codcomp,'1')
                                and dteeffec <= sysdate)
	order by codfrm;

  begin
    for i in 1..10 loop
         v_amtincom(i) := null;
    end loop;



-- get_parameter
--'{
--"p_flgtype":"1","p_codcomp":"TJS0000","p_codpos":"0740","p_numlvl":"01","p_jobgrade":"01","p_codjob":"01","p_typpayroll":"01","p_codempmt":"01","p_codbrlc":"01",
--"p_amtincom1":"10000",
--"p_amtincom2":"100000",
--"p_amtincom3":"10000",
--"p_amtincom4":"","p_amtincom5":"","p_amtincom6":"","p_amtincom7":"","p_amtincom8":"","p_amtincom9":"","p_amtincom10":""
--}'
    json_obj            := json(json_str);
    v_flgtype                     := json_ext.get_string(json_obj,'p_flgtype');  --'1' = amtproba , '2' = amtpacup
    v_temploy1.codcomp    := json_ext.get_string(json_obj,'p_codcomp');
    v_temploy1.codpos       := json_ext.get_string(json_obj,'p_codpos');
    v_temploy1.numlvl        := json_ext.get_string(json_obj,'p_numlvl');
    v_temploy1.jobgrade    := json_ext.get_string(json_obj,'p_jobgrade');
    v_temploy1.codjob       := json_ext.get_string(json_obj,'p_codjob');
    v_temploy1.typpayroll    := json_ext.get_string(json_obj,'p_typpayroll');
    v_temploy1.codempmt  := json_ext.get_string(json_obj,'p_codempmt');
    v_temploy1.codbrlc       := json_ext.get_string(json_obj,'p_codbrlc');
    v_chken                      := hcm_secur.get_v_chken;

    for i in 1..10 loop
         v_amtincom(i)             := json_ext.get_string(json_obj,'p_amtincom'||i);
    end loop;

    v_flgcond := 'N';
    for r_tincpos in c_tincpos loop
      v_flgfound := true;
      if r_tincpos.syncond is not null then
        v_cond := r_tincpos.syncond;
        v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_temploy1.codcomp||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_temploy1.codpos||'''');
        v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_temploy1.numlvl);
        v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_temploy1.jobgrade||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_temploy1.codjob||'''');
        v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_temploy1.typpayroll||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_temploy1.codempmt||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_temploy1.codbrlc||'''');
        v_stmt := 'select count(*) from dual where '||v_cond;
        v_flgfound := execute_stmt(v_stmt);
      end if;

msg_err(v_stmt);

      if v_flgfound then
        v_flgcond := 'Y';
        if v_flgtype = '1' then	  --'1' = amtproba
         -- not define salary : v_amtincom(1)		:= nvl(chk_dec(r_tincpos.amtproba1,r_tincpos.codfrm, v_chken), v_amtincom(1));

          v_amtincom(2)		:= nvl(chk_dec(r_tincpos.amtproba2,r_tincpos.codfrm, v_chken), v_amtincom(2) );
          v_amtincom(3)		:= nvl(chk_dec(r_tincpos.amtproba3,r_tincpos.codfrm, v_chken),v_amtincom(3)  );
          v_amtincom(4)		:= nvl(chk_dec(r_tincpos.amtproba4,r_tincpos.codfrm, v_chken),v_amtincom(4)  );
          v_amtincom(5)		:= nvl(chk_dec(r_tincpos.amtproba5,r_tincpos.codfrm, v_chken),v_amtincom(5)  );
          v_amtincom(6)		:= nvl(chk_dec(r_tincpos.amtproba6,r_tincpos.codfrm, v_chken),v_amtincom(6)  );
          v_amtincom(7)		:= nvl(chk_dec(r_tincpos.amtproba7,r_tincpos.codfrm, v_chken),v_amtincom(7)  );
          v_amtincom(8)		:= nvl(chk_dec(r_tincpos.amtproba8,r_tincpos.codfrm, v_chken),v_amtincom(8) );
          v_amtincom(9)		:= nvl(chk_dec(r_tincpos.amtproba9,r_tincpos.codfrm, v_chken),v_amtincom(9) );
          v_amtincom(10)		:= nvl(chk_dec(r_tincpos.amtproba10,r_tincpos.codfrm, v_chken),v_amtincom(10) );
        elsif v_flgtype = '2' then	  -- '2' = amtpacup
         -- not define salary :  v_amtincom(1)		:= nvl(chk_dec(r_tincpos.amtpacup1,r_tincpos.codfrm, v_chken), v_amtincom(1));

          v_amtincom(2)		:= nvl(chk_dec(r_tincpos.amtpacup2,r_tincpos.codfrm, v_chken), v_amtincom(2));
          v_amtincom(3)		:= nvl(chk_dec(r_tincpos.amtpacup3,r_tincpos.codfrm, v_chken), v_amtincom(3));
          v_amtincom(4)		:= nvl(chk_dec(r_tincpos.amtpacup4,r_tincpos.codfrm, v_chken), v_amtincom(4) );
          v_amtincom(5)		:= nvl(chk_dec(r_tincpos.amtpacup5,r_tincpos.codfrm, v_chken), v_amtincom(5));
          v_amtincom(6)		:= nvl(chk_dec(r_tincpos.amtpacup6,r_tincpos.codfrm, v_chken), v_amtincom(6) );
          v_amtincom(7)		:= nvl(chk_dec(r_tincpos.amtpacup7,r_tincpos.codfrm, v_chken), v_amtincom(7));
          v_amtincom(8)		:= nvl(chk_dec(r_tincpos.amtpacup8,r_tincpos.codfrm, v_chken), v_amtincom(8) );
          v_amtincom(9)		:= nvl(chk_dec(r_tincpos.amtpacup9,r_tincpos.codfrm, v_chken), v_amtincom(9));
          v_amtincom(10)		:= nvl(chk_dec(r_tincpos.amtpacup10,r_tincpos.codfrm, v_chken),  v_amtincom(10));
        end if;--p_flgtype = '1'
        exit;
      end if;--v_flgfound
    end loop;


     obj_row := json();
     v_row := 0;
     obj_data := json();
    for i in 1..10 loop
          v_row := v_row+1;
          obj_data.put('amtincom',   v_amtincom(i));
          obj_row.put(to_char(v_row-1),obj_data);
     end loop;
--return
--      {"0":{"amtincom":100000},
--       "1":{"amtincom":1000},
--       .....
--       "8":{"amtincom":100000},
--       "9":{"amtincom":100000}
--       }

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
     return(json_str_output);
exception when others then
    obj_data := json();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_char;

    return (json_str_output);

  end;
----------------------------------------------------------------------------------
  function chk_dec(p_amt varchar2, p_codfrm varchar2,p_chken2 varchar2) return number is
    v_num number;

  begin
      if p_amt is not null then
        v_num := stddec(p_amt,p_codfrm,p_chken2);
      else
        v_num := null;
      end if;
      return v_num;
  end chk_dec;
----------------------------------------------------------------------------------
  procedure msg_err (p_error in varchar2) is

  begin
    null;
  end;--procedure msg_err

 end;--hcm_pm

/
