--------------------------------------------------------
--  DDL for Package Body HRES84X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES84X" is
-- last update: 26/07/2016 13:16

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    b_index_dteyrepay   := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));

    begin
      select codcomp
      into   global_v_codcomp
      from   temploy1
      where  codempid = b_index_codempid;
    exception when no_data_found then
      null;
    end;

    begin
       select codpaypy1 into global_v_codpaypy1
       from tcontrpy
       where codcompy = hcm_util.get_codcomp_level(global_v_codcomp,'1')
         and dteeffec = (select max(dteeffec)
                         from tcontrpy
                         where codcompy = hcm_util.get_codcomp_level(global_v_codcomp,'1')
                           and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      null;
    end;

    if global_v_lrunning is not null then
      begin
        select lterminal
          into global_v_key
          from tlogin
         where lrunning = global_v_lrunning;
      exception when no_data_found then null;
      end;
    end if;
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    obj_row_1       json_object_t;
    obj_data_1      json_object_t;
    obj_row_2       json_object_t;
    obj_data_2      json_object_t;
    obj_row_3       json_object_t;
    obj_data_3      json_object_t;
    obj_row_4       json_object_t;
    obj_data_4      json_object_t;

    obj_row_r1       json_object_t;
    obj_row_r2       json_object_t;
    obj_row_r3       json_object_t;
    obj_row_r4       json_object_t;

    v_item7         varchar2(4000 char);
    v_item8         varchar2(4000 char);
    v_item9         varchar2(4000 char);
    v_item10        varchar2(4000 char);
    v_item11        varchar2(4000 char);
    v_item12        varchar2(4000 char);
    v_item13        varchar2(4000 char);
    v_item14        varchar2(4000 char);
    v_item15        varchar2(4000 char);
    v_item16        varchar2(4000 char);
    v_item17        varchar2(4000 char);
    v_item18        varchar2(4000 char);
    v_item19        varchar2(4000 char);
    v_item20        varchar2(4000 char);

    v_flg           varchar2(200 char);
    v_sumnet        number;
    type v_array is table of number index by binary_integer;
      v_month		    v_array;
      v_sum_month   v_array;
      v_net         v_array;

	cursor c_incom is
		select codpay||'-'||get_tinexinf_name(codpay,global_v_lang) desc_codpay,
           codpay codincome,get_tinexinf_name(codpay,global_v_lang) desc_income,
           nvl(stddec(amtpay1,codempid,v_chken),0) amtpay1,
					 nvl(stddec(amtpay2,codempid,v_chken),0) amtpay2,
					 nvl(stddec(amtpay3,codempid,v_chken),0) amtpay3,
					 nvl(stddec(amtpay4,codempid,v_chken),0) amtpay4,
					 nvl(stddec(amtpay5,codempid,v_chken),0) amtpay5,
					 nvl(stddec(amtpay6,codempid,v_chken),0) amtpay6,
					 nvl(stddec(amtpay7,codempid,v_chken),0) amtpay7,
					 nvl(stddec(amtpay8,codempid,v_chken),0) amtpay8,
					 nvl(stddec(amtpay9,codempid,v_chken),0) amtpay9,
					 nvl(stddec(amtpay10,codempid,v_chken),0) amtpay10,
					 nvl(stddec(amtpay11,codempid,v_chken),0) amtpay11,
					 nvl(stddec(amtpay12,codempid,v_chken),0) amtpay12
		from tytdinc
		where	dteyrepay	=	b_index_dteyrepay
		  and codempid = b_index_codempid
		  and typpay in	('1','2','3')
		  and codpay <> global_v_codpaypy1
		order by codpay;


	cursor c_deduc is
		select codpay||'-'||get_tinexinf_name(codpay,global_v_lang) desc_codpay,
           codpay coddeduct, get_tinexinf_name(codpay,global_v_lang) desc_deduct,
           nvl(stddec(amtpay1,codempid,v_chken),0) amtpay1,
					 nvl(stddec(amtpay2,codempid,v_chken),0) amtpay2,
					 nvl(stddec(amtpay3,codempid,v_chken),0) amtpay3,
					 nvl(stddec(amtpay4,codempid,v_chken),0) amtpay4,
					 nvl(stddec(amtpay5,codempid,v_chken),0) amtpay5,
					 nvl(stddec(amtpay6,codempid,v_chken),0) amtpay6,
					 nvl(stddec(amtpay7,codempid,v_chken),0) amtpay7,
					 nvl(stddec(amtpay8,codempid,v_chken),0) amtpay8,
					 nvl(stddec(amtpay9,codempid,v_chken),0) amtpay9,
					 nvl(stddec(amtpay10,codempid,v_chken),0) amtpay10,
					 nvl(stddec(amtpay11,codempid,v_chken),0) amtpay11,
					 nvl(stddec(amtpay12,codempid,v_chken),0) amtpay12
		from tytdinc
		where dteyrepay	=	b_index_dteyrepay
		  and codempid = b_index_codempid
		  and typpay in ('4','5')
		  and codpay <> global_v_codpaypy1
		order by codcomp, codpay;

	cursor c_tax is
		select codpay||'-'||get_tinexinf_name(codpay,global_v_lang) desc_codpay,
           codpay codtax,get_tinexinf_name(codpay,global_v_lang) desc_tax,
           nvl(stddec(amtpay1,codempid,v_chken),0) amtpay1,
					 nvl(stddec(amtpay2,codempid,v_chken),0) amtpay2,
					 nvl(stddec(amtpay3,codempid,v_chken),0) amtpay3,
					 nvl(stddec(amtpay4,codempid,v_chken),0) amtpay4,
					 nvl(stddec(amtpay5,codempid,v_chken),0) amtpay5,
					 nvl(stddec(amtpay6,codempid,v_chken),0) amtpay6,
					 nvl(stddec(amtpay7,codempid,v_chken),0) amtpay7,
					 nvl(stddec(amtpay8,codempid,v_chken),0) amtpay8,
					 nvl(stddec(amtpay9,codempid,v_chken),0) amtpay9,
					 nvl(stddec(amtpay10,codempid,v_chken),0) amtpay10,
					 nvl(stddec(amtpay11,codempid,v_chken),0) amtpay11,
					 nvl(stddec(amtpay12,codempid,v_chken),0) amtpay12
		from tytdinc
		where dteyrepay =	b_index_dteyrepay
		  and	codempid = b_index_codempid
      and ((typpay = '6') or (codpay = global_v_codpaypy1))
		order by codpay;

  begin

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_row_1 := json_object_t();
    obj_row_2 := json_object_t();
    obj_row_3 := json_object_t();
    obj_row_4 := json_object_t();
    obj_data := json_object_t();
    for i in 1..12 loop
      v_sum_month(i)    := 0;
    end loop;

    select count(*)+4 into v_rcnt -- add summary row of incom, deduc, tax and grand summary
      from (select *
              from tytdinc
             where dteyrepay = b_index_dteyrepay
               and codempid = b_index_codempid
               and (typpay in ('1','2','3','4','5') and codpay <> global_v_codpaypy1)
         union all
            select *
              from tytdinc
             where dteyrepay = b_index_dteyrepay
               and codempid = b_index_codempid
               and (typpay = '6' or codpay = global_v_codpaypy1));

    for m in 1..4 loop
      for j in 1..12 loop
        v_month(j)    := 0;
      end loop;
      v_sumnet := 0;
      v_flg    := '';


      if m = 1 then
        v_numseq := 0;

        for i in c_incom loop
          v_flg    := 'incom';
          v_numseq := v_numseq + 1;
          v_item7  := i.desc_codpay;
          v_item8  := to_char(i.amtpay1,'fm99,999,990.00');
          v_item9  := to_char(i.amtpay2,'fm99,999,990.00');
          v_item10 := to_char(i.amtpay3,'fm99,999,990.00');
          v_item11 := to_char(i.amtpay4,'fm99,999,990.00');
          v_item12 := to_char(i.amtpay5,'fm99,999,990.00');
          v_item13 := to_char(i.amtpay6,'fm99,999,990.00');
          v_item14 := to_char(i.amtpay7,'fm99,999,990.00');
          v_item15 := to_char(i.amtpay8,'fm99,999,990.00');
          v_item16 := to_char(i.amtpay9,'fm99,999,990.00');
          v_item17 := to_char(i.amtpay10,'fm99,999,990.00');
          v_item18 := to_char(i.amtpay11,'fm99,999,990.00');
          v_item19 := to_char(i.amtpay12,'fm99,999,990.00');
          v_item20 := to_char((nvl(i.amtpay1,0) + nvl(i.amtpay2,0) + nvl(i.amtpay3,0) +
                               nvl(i.amtpay4,0) + nvl(i.amtpay5,0) + nvl(i.amtpay6,0) +
                               nvl(i.amtpay7,0) + nvl(i.amtpay8,0) + nvl(i.amtpay9,0) +
                               nvl(i.amtpay10,0) + nvl(i.amtpay11,0) + nvl(i.amtpay12,0)),'fm99,999,990.00');
          --
          obj_data_1 := json_object_t();
          obj_data_1.put('coderror', '200');
          obj_data_1.put('desc_coderror', ' ');
          obj_data_1.put('httpcode', '');
          obj_data_1.put('flg', v_flg);
          obj_data_1.put('codincome',i.codincome);
          obj_data_1.put('desc_income',i.desc_income);
          obj_data_1.put('detail',v_item7);
          obj_data_1.put('month1',v_item8);
          obj_data_1.put('month2',v_item9);
          obj_data_1.put('month3',v_item10);
          obj_data_1.put('month4',v_item11);
          obj_data_1.put('month5',v_item12);
          obj_data_1.put('month6',v_item13);
          obj_data_1.put('month7',v_item14);
          obj_data_1.put('month8',v_item15);
          obj_data_1.put('month9',v_item16);
          obj_data_1.put('month10',v_item17);
          obj_data_1.put('month11',v_item18);
          obj_data_1.put('month12',v_item19);
          obj_data_1.put('total',v_item20);
          obj_row_1.put(to_char(v_numseq-1),obj_data_1);
        end loop;
      elsif m = 2 then
        v_numseq := 0;
        for i in c_deduc loop
          v_flg    := 'deduc';
          v_numseq := v_numseq + 1;
          v_item7  := i.desc_codpay;
          v_item8  := to_char(i.amtpay1,'fm99,999,990.00');
          v_item9  := to_char(i.amtpay2,'fm99,999,990.00');
          v_item10 := to_char(i.amtpay3,'fm99,999,990.00');
          v_item11 := to_char(i.amtpay4,'fm99,999,990.00');
          v_item12 := to_char(i.amtpay5,'fm99,999,990.00');
          v_item13 := to_char(i.amtpay6,'fm99,999,990.00');
          v_item14 := to_char(i.amtpay7,'fm99,999,990.00');
          v_item15 := to_char(i.amtpay8,'fm99,999,990.00');
          v_item16 := to_char(i.amtpay9,'fm99,999,990.00');
          v_item17 := to_char(i.amtpay10,'fm99,999,990.00');
          v_item18 := to_char(i.amtpay11,'fm99,999,990.00');
          v_item19 := to_char(i.amtpay12,'fm99,999,990.00');
          v_item20 := to_char((nvl(i.amtpay1,0) + nvl(i.amtpay2,0) + nvl(i.amtpay3,0) +
                               nvl(i.amtpay4,0) + nvl(i.amtpay5,0) + nvl(i.amtpay6,0) +
                               nvl(i.amtpay7,0) + nvl(i.amtpay8,0) + nvl(i.amtpay9,0) +
                               nvl(i.amtpay10,0) + nvl(i.amtpay11,0) + nvl(i.amtpay12,0)),'fm99,999,990.00');
          --
          obj_data_2 := json_object_t();
          obj_data_2.put('coderror', '200');
          obj_data_2.put('desc_coderror', ' ');
          obj_data_2.put('httpcode', '');
          obj_data_2.put('flg', v_flg);
          obj_data_2.put('coddeduct',i.coddeduct);
          obj_data_2.put('desc_deduct',i.desc_deduct);
          obj_data_2.put('detail',v_item7);
          obj_data_2.put('month1',v_item8);
          obj_data_2.put('month2',v_item9);
          obj_data_2.put('month3',v_item10);
          obj_data_2.put('month4',v_item11);
          obj_data_2.put('month5',v_item12);
          obj_data_2.put('month6',v_item13);
          obj_data_2.put('month7',v_item14);
          obj_data_2.put('month8',v_item15);
          obj_data_2.put('month9',v_item16);
          obj_data_2.put('month10',v_item17);
          obj_data_2.put('month11',v_item18);
          obj_data_2.put('month12',v_item19);
          obj_data_2.put('total',v_item20);
          obj_row_2.put(to_char(v_numseq-1),obj_data_2);
          --add
        end loop;
      elsif m = 3 then
        v_numseq := 0;
        for i in c_tax loop
          v_flg    := 'tax';
          v_numseq := v_numseq + 1;
          v_item7  := i.desc_codpay;
          v_item8  := to_char(i.amtpay1,'fm99,999,990.00');
          v_item9  := to_char(i.amtpay2,'fm99,999,990.00');
          v_item10 := to_char(i.amtpay3,'fm99,999,990.00');
          v_item11 := to_char(i.amtpay4,'fm99,999,990.00');
          v_item12 := to_char(i.amtpay5,'fm99,999,990.00');
          v_item13 := to_char(i.amtpay6,'fm99,999,990.00');
          v_item14 := to_char(i.amtpay7,'fm99,999,990.00');
          v_item15 := to_char(i.amtpay8,'fm99,999,990.00');
          v_item16 := to_char(i.amtpay9,'fm99,999,990.00');
          v_item17 := to_char(i.amtpay10,'fm99,999,990.00');
          v_item18 := to_char(i.amtpay11,'fm99,999,990.00');
          v_item19 := to_char(i.amtpay12,'fm99,999,990.00');
          v_item20 := to_char((nvl(i.amtpay1,0) + nvl(i.amtpay2,0) + nvl(i.amtpay3,0) +
                               nvl(i.amtpay4,0) + nvl(i.amtpay5,0) + nvl(i.amtpay6,0) +
                               nvl(i.amtpay7,0) + nvl(i.amtpay8,0) + nvl(i.amtpay9,0) +
                               nvl(i.amtpay10,0) + nvl(i.amtpay11,0) + nvl(i.amtpay12,0)),'fm99,999,990.00');
          --
          obj_data_3 := json_object_t();
          obj_data_3.put('coderror', '200');
          obj_data_3.put('desc_coderror', ' ');
          obj_data_3.put('httpcode', '');
          obj_data_3.put('flg', v_flg);
          obj_data_3.put('codtax',i.codtax);
          obj_data_3.put('desc_tax',i.desc_tax);
          obj_data_3.put('detail',v_item7);
          obj_data_3.put('month1',v_item8);
          obj_data_3.put('month2',v_item9);
          obj_data_3.put('month3',v_item10);
          obj_data_3.put('month4',v_item11);
          obj_data_3.put('month5',v_item12);
          obj_data_3.put('month6',v_item13);
          obj_data_3.put('month7',v_item14);
          obj_data_3.put('month8',v_item15);
          obj_data_3.put('month9',v_item16);
          obj_data_3.put('month10',v_item17);
          obj_data_3.put('month11',v_item18);
          obj_data_3.put('month12',v_item19);
          obj_data_3.put('total',v_item20);
          obj_row_3.put(to_char(v_numseq-1),obj_data_3);

        end loop;
      elsif m = 4 then    
        -- Sum Tab1 income
        begin
          select nvl(sum(stddec(amtpay1,codempid,v_chken)),0) amtpay1,
                 nvl(sum(stddec(amtpay2,codempid,v_chken)),0) amtpay2,
                 nvl(sum(stddec(amtpay3,codempid,v_chken)),0) amtpay3,
                 nvl(sum(stddec(amtpay4,codempid,v_chken)),0) amtpay4,
                 nvl(sum(stddec(amtpay5,codempid,v_chken)),0) amtpay5,
                 nvl(sum(stddec(amtpay6,codempid,v_chken)),0) amtpay6,
                 nvl(sum(stddec(amtpay7,codempid,v_chken)),0) amtpay7,
                 nvl(sum(stddec(amtpay8,codempid,v_chken)),0) amtpay8,
                 nvl(sum(stddec(amtpay9,codempid,v_chken)),0) amtpay9,
                 nvl(sum(stddec(amtpay10,codempid,v_chken)),0) amtpay10,
                 nvl(sum(stddec(amtpay11,codempid,v_chken)),0) amtpay11,
                 nvl(sum(stddec(amtpay12,codempid,v_chken)),0) amtpay12
            into v_month(1), v_month(2), v_month(3), v_month(4),
                 v_month(5), v_month(6), v_month(7), v_month(8),
                 v_month(9), v_month(10), v_month(11), v_month(12)
            from tytdinc
           where dteyrepay = (b_index_dteyrepay)
             and codempid = b_index_codempid
             and typpay in ('1','2','3')
             and codpay <> global_v_codpaypy1;
        exception when no_data_found then
          v_month(1) := 0; v_month(2) := 0; v_month(3) := 0; v_month(4):= 0;
          v_month(5) := 0; v_month(6) := 0; v_month(7) := 0; v_month(8):= 0;
          v_month(9) := 0; v_month(10) := 0; v_month(11) := 0; v_month(12) := 0;
        end;
        v_sumnet := 0;
        v_sumnet := nvl(v_month(1),0) + nvl(v_month(2),0) + nvl(v_month(3),0) +
                             nvl(v_month(4),0) + nvl(v_month(5),0) + nvl(v_month(6),0) +
                             nvl(v_month(7),0) + nvl(v_month(8),0) + nvl(v_month(9),0) +
                             nvl(v_month(10),0) + nvl(v_month(11),0) + nvl(v_month(12),0);
        v_numseq := v_numseq + 1;
        v_item7  := get_label_name('HRES84X1', global_v_lang, 40) ;
        v_item8  := to_char(v_month(1),'fm99,999,990.00');
        v_item9  := to_char(v_month(2),'fm99,999,990.00');
        v_item10 := to_char(v_month(3),'fm99,999,990.00');
        v_item11 := to_char(v_month(4),'fm99,999,990.00');
        v_item12 := to_char(v_month(5),'fm99,999,990.00');
        v_item13 := to_char(v_month(6),'fm99,999,990.00');
        v_item14 := to_char(v_month(7),'fm99,999,990.00');
        v_item15 := to_char(v_month(8),'fm99,999,990.00');
        v_item16 := to_char(v_month(9),'fm99,999,990.00');
        v_item17 := to_char(v_month(10),'fm99,999,990.00');
        v_item18 := to_char(v_month(11),'fm99,999,990.00');
        v_item19 := to_char(v_month(12),'fm99,999,990.00');
        v_item20 := to_char(v_sumnet,'fm99,999,990.00');
        obj_data_1 := json_object_t();
        obj_data_1.put('coderror', '200');
        obj_data_1.put('desc_coderror', ' ');
        obj_data_1.put('httpcode', '');
        obj_data_1.put('codnetincom',v_item7);
        obj_data_1.put('detail',v_item7);
        obj_data_1.put('month1',v_item8);
        obj_data_1.put('month2',v_item9);
        obj_data_1.put('month3',v_item10);
        obj_data_1.put('month4',v_item11);
        obj_data_1.put('month5',v_item12);
        obj_data_1.put('month6',v_item13);
        obj_data_1.put('month7',v_item14);
        obj_data_1.put('month8',v_item15);
        obj_data_1.put('month9',v_item16);
        obj_data_1.put('month10',v_item17);
        obj_data_1.put('month11',v_item18);
        obj_data_1.put('month12',v_item19);
        obj_data_1.put('total',v_item20);
        obj_row_4.put(to_char(0),obj_data_1);

        for i in 1..12 loop
          v_net(i) := v_month(i);
        end loop;

        -- Sum Tab2 Deduct
        begin
          select nvl(sum(stddec(amtpay1,codempid,v_chken)),0) amtpay1,
                 nvl(sum(stddec(amtpay2,codempid,v_chken)),0) amtpay2,
                 nvl(sum(stddec(amtpay3,codempid,v_chken)),0) amtpay3,
                 nvl(sum(stddec(amtpay4,codempid,v_chken)),0) amtpay4,
                 nvl(sum(stddec(amtpay5,codempid,v_chken)),0) amtpay5,
                 nvl(sum(stddec(amtpay6,codempid,v_chken)),0) amtpay6,
                 nvl(sum(stddec(amtpay7,codempid,v_chken)),0) amtpay7,
                 nvl(sum(stddec(amtpay8,codempid,v_chken)),0) amtpay8,
                 nvl(sum(stddec(amtpay9,codempid,v_chken)),0) amtpay9,
                 nvl(sum(stddec(amtpay10,codempid,v_chken)),0) amtpay10,
                 nvl(sum(stddec(amtpay11,codempid,v_chken)),0) amtpay11,
                 nvl(sum(stddec(amtpay12,codempid,v_chken)),0) amtpay12
            into v_month(1), v_month(2), v_month(3), v_month(4),
                 v_month(5), v_month(6), v_month(7), v_month(8),
                 v_month(9), v_month(10), v_month(11), v_month(12)
            from tytdinc
           where dteyrepay = (b_index_dteyrepay)
             and codempid = b_index_codempid
             and typpay in ('4','5')
             and codpay <> global_v_codpaypy1;
        exception when no_data_found then
          v_month(1) := 0; v_month(2) := 0; v_month(3) := 0; v_month(4):= 0;
          v_month(5) := 0; v_month(6) := 0; v_month(7) := 0; v_month(8):= 0;
          v_month(9) := 0; v_month(10) := 0; v_month(11) := 0; v_month(12) := 0;
        end;
        v_sumnet := 0;
        v_sumnet := nvl(v_month(1),0) + nvl(v_month(2),0) + nvl(v_month(3),0) +
                    nvl(v_month(4),0) + nvl(v_month(5),0) + nvl(v_month(6),0) +
                    nvl(v_month(7),0) + nvl(v_month(8),0) + nvl(v_month(9),0) +
                    nvl(v_month(10),0) + nvl(v_month(11),0) + nvl(v_month(12),0);
        v_numseq := v_numseq + 1;
        v_item7  := get_label_name('HRES84X1', global_v_lang, 50) ;
        v_item8  := to_char(v_month(1),'fm99,999,990.00');
        v_item9  := to_char(v_month(2),'fm99,999,990.00');
        v_item10 := to_char(v_month(3),'fm99,999,990.00');
        v_item11 := to_char(v_month(4),'fm99,999,990.00');
        v_item12 := to_char(v_month(5),'fm99,999,990.00');
        v_item13 := to_char(v_month(6),'fm99,999,990.00');
        v_item14 := to_char(v_month(7),'fm99,999,990.00');
        v_item15 := to_char(v_month(8),'fm99,999,990.00');
        v_item16 := to_char(v_month(9),'fm99,999,990.00');
        v_item17 := to_char(v_month(10),'fm99,999,990.00');
        v_item18 := to_char(v_month(11),'fm99,999,990.00');
        v_item19 := to_char(v_month(12),'fm99,999,990.00');
        v_item20 := to_char(v_sumnet,'fm99,999,990.00');
        obj_data_2 := json_object_t();
        obj_data_2.put('coderror', '200');
        obj_data_2.put('desc_coderror', ' ');
        obj_data_2.put('httpcode', '');
        obj_data_2.put('codnetincom',v_item7);
        obj_data_2.put('detail',v_item7);
        obj_data_2.put('month1',v_item8);
        obj_data_2.put('month2',v_item9);
        obj_data_2.put('month3',v_item10);
        obj_data_2.put('month4',v_item11);
        obj_data_2.put('month5',v_item12);
        obj_data_2.put('month6',v_item13);
        obj_data_2.put('month7',v_item14);
        obj_data_2.put('month8',v_item15);
        obj_data_2.put('month9',v_item16);
        obj_data_2.put('month10',v_item17);
        obj_data_2.put('month11',v_item18);
        obj_data_2.put('month12',v_item19);
        obj_data_2.put('total',v_item20);
        obj_row_4.put(to_char(1),obj_data_2);

        for i in 1..12 loop
          v_net(i) := v_net(i) - v_month(i);
        end loop;

        -- Sum Tab2 Tax
        begin
          select nvl(sum(stddec(amtpay1,codempid,v_chken)),0) amtpay1,
                 nvl(sum(stddec(amtpay2,codempid,v_chken)),0) amtpay2,
                 nvl(sum(stddec(amtpay3,codempid,v_chken)),0) amtpay3,
                 nvl(sum(stddec(amtpay4,codempid,v_chken)),0) amtpay4,
                 nvl(sum(stddec(amtpay5,codempid,v_chken)),0) amtpay5,
                 nvl(sum(stddec(amtpay6,codempid,v_chken)),0) amtpay6,
                 nvl(sum(stddec(amtpay7,codempid,v_chken)),0) amtpay7,
                 nvl(sum(stddec(amtpay8,codempid,v_chken)),0) amtpay8,
                 nvl(sum(stddec(amtpay9,codempid,v_chken)),0) amtpay9,
                 nvl(sum(stddec(amtpay10,codempid,v_chken)),0) amtpay10,
                 nvl(sum(stddec(amtpay11,codempid,v_chken)),0) amtpay11,
                 nvl(sum(stddec(amtpay12,codempid,v_chken)),0) amtpay12
            into v_month(1), v_month(2), v_month(3), v_month(4),
                 v_month(5), v_month(6), v_month(7), v_month(8),
                 v_month(9), v_month(10), v_month(11), v_month(12)
            from tytdinc
           where dteyrepay = (b_index_dteyrepay)
             and codempid = b_index_codempid
             and ((typpay = '6') or (codpay = global_v_codpaypy1));
        exception when no_data_found then
          v_month(1) := 0; v_month(2) := 0; v_month(3) := 0; v_month(4):= 0;
          v_month(5) := 0; v_month(6) := 0; v_month(7) := 0; v_month(8):= 0;
          v_month(9) := 0; v_month(10) := 0; v_month(11) := 0; v_month(12) := 0;
        end;
        v_sumnet := 0;
        v_sumnet := nvl(v_month(1),0) + nvl(v_month(2),0) + nvl(v_month(3),0) +
                    nvl(v_month(4),0) + nvl(v_month(5),0) + nvl(v_month(6),0) +
                    nvl(v_month(7),0) + nvl(v_month(8),0) + nvl(v_month(9),0) +
                    nvl(v_month(10),0) + nvl(v_month(11),0) + nvl(v_month(12),0);
        v_numseq := v_numseq + 1;
        v_item7  := get_label_name('HRES84X1', global_v_lang, 60) ;
        v_item8  := to_char(v_month(1),'fm99,999,990.00');
        v_item9  := to_char(v_month(2),'fm99,999,990.00');
        v_item10 := to_char(v_month(3),'fm99,999,990.00');
        v_item11 := to_char(v_month(4),'fm99,999,990.00');
        v_item12 := to_char(v_month(5),'fm99,999,990.00');
        v_item13 := to_char(v_month(6),'fm99,999,990.00');
        v_item14 := to_char(v_month(7),'fm99,999,990.00');
        v_item15 := to_char(v_month(8),'fm99,999,990.00');
        v_item16 := to_char(v_month(9),'fm99,999,990.00');
        v_item17 := to_char(v_month(10),'fm99,999,990.00');
        v_item18 := to_char(v_month(11),'fm99,999,990.00');
        v_item19 := to_char(v_month(12),'fm99,999,990.00');
        v_item20 := to_char(v_sumnet,'fm99,999,990.00');
        obj_data_3 := json_object_t();
        obj_data_3.put('coderror', '200');
        obj_data_3.put('desc_coderror', ' ');
        obj_data_3.put('httpcode', '');
        obj_data_3.put('codnetincom',v_item7);
        obj_data_3.put('detail',v_item7);
        obj_data_3.put('month1',v_item8);
        obj_data_3.put('month2',v_item9);
        obj_data_3.put('month3',v_item10);
        obj_data_3.put('month4',v_item11);
        obj_data_3.put('month5',v_item12);
        obj_data_3.put('month6',v_item13);
        obj_data_3.put('month7',v_item14);
        obj_data_3.put('month8',v_item15);
        obj_data_3.put('month9',v_item16);
        obj_data_3.put('month10',v_item17);
        obj_data_3.put('month11',v_item18);
        obj_data_3.put('month12',v_item19);
        obj_data_3.put('total',v_item20);
        obj_row_4.put(to_char(2),obj_data_3);

        for i in 1..12 loop
          v_net(i) := v_net(i) - v_month(i);
        end loop;

        -- net
        v_sumnet := 0;
        for i in 1..12 loop
          v_sumnet := v_sumnet + v_net(i);
        end loop;
        obj_data_3 := json_object_t();
        obj_data_3.put('coderror', '200');
        obj_data_3.put('desc_coderror', ' ');
        obj_data_3.put('httpcode', '');
        obj_data_3.put('codnetincom',get_label_name('HRES84XC4',global_v_lang,'150'));
        obj_data_3.put('detail',get_label_name('HRES84XC4',global_v_lang,'150'));
        obj_data_3.put('month1',to_char(v_net(1),'fm999,999,990.90'));
        obj_data_3.put('month2',to_char(v_net(2),'fm999,999,990.90'));
        obj_data_3.put('month3',to_char(v_net(3),'fm999,999,990.90'));
        obj_data_3.put('month4',to_char(v_net(4),'fm999,999,990.90'));
        obj_data_3.put('month5',to_char(v_net(5),'fm999,999,990.90'));
        obj_data_3.put('month6',to_char(v_net(6),'fm999,999,990.90'));
        obj_data_3.put('month7',to_char(v_net(7),'fm999,999,990.90'));
        obj_data_3.put('month8',to_char(v_net(8),'fm999,999,990.90'));
        obj_data_3.put('month9',to_char(v_net(9),'fm999,999,990.90'));
        obj_data_3.put('month10',to_char(v_net(10),'fm999,999,990.90'));
        obj_data_3.put('month11',to_char(v_net(11),'fm999,999,990.90'));
        obj_data_3.put('month12',to_char(v_net(12),'fm999,999,990.90'));
        obj_data_3.put('total',to_char(v_sumnet,'fm999,999,990.90'));
        obj_row_4.put(to_char(3),obj_data_3);
      end if;
    end loop;

    obj_row_r1 := json_object_t();
    obj_row_r2 := json_object_t();
    obj_row_r3 := json_object_t();
    obj_row_r4 := json_object_t();
    obj_row_r1.put('rows',obj_row_1);
    obj_row_r2.put('rows',obj_row_2);
    obj_row_r3.put('rows',obj_row_3);
    obj_row_r4.put('rows',obj_row_4);

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_coderror', ' ');
    obj_data.put('httpcode', '');
    obj_data.put('tab1', obj_row_r1);
    obj_data.put('tab2', obj_row_r2);
    obj_data.put('tab3', obj_row_r3);
    obj_data.put('tab4', obj_row_r4);



    json_str_output := obj_data.to_clob;
  end;
  --
  procedure check_index is
    v_count number;
  begin

    if b_index_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if global_v_codcomp is null then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      return;
    end if;

    if global_v_codpaypy1 is null then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcontrpy');
      return;
    end if;

    begin
      select count(*)
        into v_count
        from temploy1 a
       where codempid = nvl(b_index_codempid,codempid)
         and codcomp like global_v_codcomp||'%'
         and exists (select codempid
                       from tytdinc b
                      where	dteyrepay = b_index_dteyrepay
                        and b.codempid = a.codempid
                        and	typpay <> '7');
    end;
    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tytdinc');
      return;
    end if;
  end;
end;

/
