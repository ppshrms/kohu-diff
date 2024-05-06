--------------------------------------------------------
--  DDL for Package Body HRCOCVB_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCOCVB_BATCH" as
  procedure initial_value(json_str in clob) is 
    json_obj json_object_t;
  begin
    json_obj := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_type_year  := hcm_util.get_string_t(json_obj, 'p_type_year');    
    /*
    if global_v_type_year = 1 then
        global_v_type_year := 'BE';
    elsif global_v_type_year = 2 then
        global_v_type_year := 'CE';
    end if;
    */ 
    --global_v_lang     := '102'; 
  end;
  --

  function check_date(p_date  in varchar2) return boolean is
    v_date  date;
    v_error boolean := false;
  begin
    if p_date is not null then
      begin
       v_date := to_date(p_date, 'dd/mm/yyyy');       
      exception when others then
        v_error := true;
        return ( v_error );
      end;
    end if;
    return ( v_error );
  end;
  --
  function check_number(p_number  in varchar2) return boolean is
    v_number  number;
    v_error   boolean := false;
  begin
    if p_number is not null then
      begin
       v_number := to_number(p_number);       
      exception when others then
        v_error := true;
        return ( v_error );
      end;
    end if;
    return ( v_error );
  end;
  --
  function check_year(p_year  in number) return number is
    p_zyear   number;
    chkreg    varchar2(2);
  begin
    chkreg := global_v_type_year;
    if chkreg = 'BE' then
        if p_year > 2500 then
          p_zyear := -543;
        else
          p_zyear := 0;
        end if;
    else 
       p_zyear := 0;
    end if;

    return p_year + p_zyear ;
  end;
  --
  function check_dteyre (p_date in varchar2)
  return date is
    v_date    date;
    v_error   boolean := false;
    v_year    number;
    v_daymon  varchar2(30);
    v_text    varchar2(30);
    p_zyear   number;
    chkreg    varchar2(30);
  begin
  /* 
   --old code
     begin     
      select value into chkreg
      from v$nls_parameters where parameter = 'NLS_CALENDAR';
      if chkreg = 'Thai Buddha' then    
        if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := 0;
        else
          p_zyear := 543;
       end if;
      else
       if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := -543;
       else
          p_zyear := 0;
       end if;
      end if;
    end;
  */
  chkreg := global_v_type_year;
    if chkreg = 'BE' then
        if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := -543;
        else
          p_zyear := 0;
        end if;
    else 
       p_zyear := 0;
    end if;


    if p_date is not null then
      -- plus year --
      v_year      := substr(p_date,-4,4);
      v_year      := v_year + p_zyear;
      v_daymon    := substr(p_date,1,length(p_date)-4);
      v_text      := v_daymon||to_char(v_year);
      v_year      := null;
      v_daymon    := null;
      -- plus year --
      v_date := to_date(v_text,'dd/mm/yyyy');
    end if;

    return(v_date);   
  end;
  --
  function get_result(p_rec_tran   in number,
                      p_rec_err    in number) return clob is     
    obj_row    json_object_t;
    obj_data   json_object_t;
    obj_result json_object_t;
    v_rcnt     number := 0;
  begin
    if param_msg_error is null then
      obj_row := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      if v_msgerror is null then
        obj_row.put('rec_tran', p_rec_tran);
        obj_row.put('rec_err', p_rec_err);
        obj_row.put('response', replace(get_error_msg_php('HR2715', global_v_lang), '@#$%200', null));
      else
        obj_row.put('response', v_msgerror);
        obj_row.put('flg', 'warning');
      end if;

      --??
      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first..p_numseq.last loop
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt - 1), obj_data);
        end loop;
      end if;

      obj_row.put('datadisp', obj_result);
      return obj_row.to_clob;
    else
     return get_response_message('400', param_msg_error, global_v_lang);
    end if;
  end;
--CO----------------------------------------------------------------------------------------------------------
  -- TCOMPNY
  procedure get_process_co_tcompny (json_str_input    in clob,
                                   json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_co_tcompny(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_co_tcompny (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codcompy       tcompny.codcompy%type;
    v_namcome        tcompny.namcome%type;
    v_namcomt        tcompny.namcomt%type;
    v_namste         tcompny.namste%type;
    v_namstt         tcompny.namstt%type;
    v_adrcome        tcompny.adrcome%type;
    v_adrcomt        tcompny.adrcomt%type;
    v_addrnoe        tcompny.addrnoe%type;
    v_addrnot        tcompny.addrnot%type;
    v_soie           tcompny.soie%type;
    v_soit           tcompny.soit%type;
    v_mooe           tcompny.mooe%type;
    v_moot           tcompny.moot%type;
    v_roade          tcompny.roade%type;
    v_roadt          tcompny.roadt%type;    
    v_villagee       tcompny.villagee%type;
    v_villaget       tcompny.villaget%type;    
    v_buildinge      tcompny.buildinge%type;
    v_buildingt      tcompny.buildingt%type;
    v_roomnoe        tcompny.roomnoe%type;
    v_roomnot        tcompny.roomnot%type;
    v_floore         tcompny.floore%type;
    v_floort         tcompny.floort%type;
    v_codsubdist     tcompny.codsubdist%type;
    v_coddist        tcompny.coddist%type;
    v_codprovr       tcompny.codprovr%type;    
    v_zipcode        tcompny.zipcode%type;
    v_numtele        tcompny.numtele%type;
    v_numfax         tcompny.numfax%type;
    v_numcotax       tcompny.numcotax%type;
    v_numacsoc       tcompny.numacsoc%type;
    v_email          tcompny.email%type;
    v_website        tcompny.website%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i = 1 then
      chk_len(i) := 4;
      elsif i in (2,3) then
      chk_len(i) := 150;
      elsif i in (4,5,12,13,20,21,31) then
      chk_len(i) := 10;
      elsif i in (6,7) then
      chk_len(i) := 300;
      elsif i in (8,9,18,19) then
      chk_len(i) := 60;
      elsif i in (10,11,14,15,28) then
      chk_len(i) := 30;
      elsif i in (16,17) then
      chk_len(i) := 100;
      elsif i in (22,23) then
      chk_len(i) := 3;
      elsif i in (24,25,26) then
      chk_len(i) := 4;
      elsif i in (27) then
      chk_len(i) := 5;
      elsif i in (29) then
      chk_len(i) := 20;
      elsif i in (30) then
      chk_len(i) := 13;      
      elsif i in (32,33) then
      chk_len(i) := 50;   
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

                v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
                v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
                v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
                v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
                v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
                v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
                v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
                v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
                v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
                v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
                v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
                v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
                v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
                v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
                v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
                v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
                v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
                v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
                v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
                v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
                v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
                v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
                v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
                v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
                v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
                v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
                v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
                v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');
                v_text(29)  := hcm_util.get_string_t(param_json_row,'col-29');
                v_text(30)  := hcm_util.get_string_t(param_json_row,'col-30');
                v_text(31)  := hcm_util.get_string_t(param_json_row,'col-31');
                v_text(32)  := hcm_util.get_string_t(param_json_row,'col-32');
                v_text(33)  := hcm_util.get_string_t(param_json_row,'col-33');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    --check require data column 
                    for i in 1..v_column loop
                        if i in (1,2,3,30)  then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;
                    end loop;

                    --check length all columns                  
                    for i in 1..v_column loop
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop; 


          --assign value to var
          v_codcompy    := v_text(1);
          v_namcome   := v_text(2);
          v_namcomt     := v_text(3);
          v_namste      := v_text(4);
          v_namstt      := v_text(5);
          v_adrcome     := v_text(6);
          v_adrcomt     := v_text(7);
          v_addrnoe     := v_text(8);
          v_addrnot     := v_text(9);
          v_soie              := v_text(10);
          v_soit            := v_text(11);
          v_mooe        := v_text(12);
          v_moot        := v_text(13);
          v_roade       := v_text(14);
          v_roadt       := v_text(15);
          v_villagee      := v_text(16);
          v_villaget          := v_text(17);
          v_buildinge     := v_text(18);
          v_buildingt     := v_text(19);
          v_roomnoe     := v_text(20);
          v_roomnot     := v_text(21);
          v_floore          := v_text(22);
          v_floort          := v_text(23);
          v_codsubdist    := v_text(24);
          v_coddist     := v_text(25);
          v_codprovr      := v_text(26);
          v_zipcode     := v_text(27);
          v_numtele     := v_text(28);
          v_numfax      := v_text(29);
          v_numcotax        := v_text(30);
          v_numacsoc    := v_text(31);
          v_email       := v_text(32);
          v_website       := v_text(33);

                    --check codsubdistr 
                    if v_codsubdist is not null or length(trim(v_codsubdist)) is not null  then  
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tsubdist    
                            where codsubdist  = v_codsubdist;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(24);
                            v_err_table := 'TSUBDIST';
                            exit cal_loop;
                        end;  
          end if;

          --check coddistr  
                    if v_codsubdist is not null or length(trim(v_codsubdist)) is not null  then 
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcoddist    
                            where coddist  = v_coddist;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(25);
                            v_err_table := 'TCODDIST';
                            exit cal_loop;
                        end;
                    end if;

                    --codprovr
                    if v_codsubdist is not null or length(trim(v_codsubdist)) is not null  then 
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodprov     
                            where codcodec  = v_codprovr;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(26);
                            v_err_table := 'TCODPROV';
                            exit cal_loop;
                        end;
                    end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete from tcompny where codcompy = v_codcompy;                      

            insert into   tcompny(codcompy,namcome,namcomt,namcom3,namcom4,namcom5,namste,namstt,namst3,namst4,namst5,adrcome,adrcomt,adrcom3,adrcom4,adrcom5,
                        numtele,numfax,numcotax,descomp,numacsoc,zipcode,email,website,comimage,namimgcom,namimgmap,addrnoe,addrnot,addrno3,addrno4,addrno5,
                        soie,soit,soi3,soi4,soi5,mooe,moot,moo3,moo4,moo5,roade,roadt,road3,road4,road5,villagee,villaget,village3,village4,village5,
                        codsubdist,coddist,codprovr,numacdsd,buildinge,buildingt,building3,building4,building5,roomnoe,roomnot,roomno3,roomno4,roomno5,
                        floore,floort,floor3,floor4,floor5,namimgcover,welcomemsge,welcomemsgt,welcomemsg3,welcomemsg4,welcomemsg5,typbusiness,ageretrm,ageretrf,
                        contmsge,contmsgt,contmsg3,contmsg4,contmsg5,compgrp,namimgmobi,dtecreate,codcreate,dteupd,coduser)  
                                       values(v_codcompy,v_namcome,v_namcomt,v_namcome,v_namcome,v_namcome,v_namste,v_namstt,v_namste,v_namste,v_namste,v_adrcome,v_adrcomt,v_adrcome,v_adrcome,v_adrcome,
                        v_numtele,v_numfax,v_numcotax,null,v_numacsoc,v_zipcode,v_email,v_website,null,null,null,v_addrnoe,v_addrnot,v_addrnoe,v_addrnoe,v_addrnoe,
                        v_soie,v_soit,v_soie,v_soie,v_soie,v_mooe,v_moot,v_mooe,v_mooe,v_mooe,v_roade,v_roadt,v_roade,v_roade,v_roade,v_villagee,v_villaget,v_villagee,v_villagee,v_villagee,
                        v_codsubdist,v_coddist,v_codprovr,null,v_buildinge,v_buildingt,v_buildinge,v_buildinge,v_buildinge,v_roomnoe,v_roomnot,v_roomnoe,v_roomnoe,v_roomnoe,
                        v_floore,v_floort,v_floore,v_floore,v_floore,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);                                             
                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  -- TCENTER, TCOMPNYD
  procedure get_process_co_tcenter(json_str_input    in clob,
                                   json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_co_tcenter(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --                                  
 procedure validate_excel_co_tcenter (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codcomp        tcenter.codcomp%type;
    v_codcomp1       tcenter.codcom1%type;
    v_codcomp2       tcenter.codcom2%type;
    v_codcomp3       tcenter.codcom3%type;
    v_codcomp4       tcenter.codcom4%type;
    v_codcomp5       tcenter.codcom5%type;
    v_codcomp6       tcenter.codcom6%type;
    v_codcomp7       tcenter.codcom7%type;
    v_codcomp8       tcenter.codcom8%type;
    v_codcomp9       tcenter.codcom9%type;    
    v_codcomp10      tcenter.codcom10%type;
    v_namcente       tcenter.namcente%type;
    v_namcentt       tcenter.namcentt%type;
    v_naminite       tcenter.naminite%type;
    v_naminitt       tcenter.naminitt%type;
    v_costcent       tcenter.costcent%type;
    v_compgrp        tcenter.compgrp%type;
    v_codposr        tcenter.codposr%type; 
    v_subcomp        tcenter.codcomp%type;
    v_comlevel       tcompnyd.comlevel%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i = 1 then
      chk_len(i) := 40;
      elsif i between 2 and 11 then
      chk_len(i) := 4;
      elsif i between 12 and 13 then
      chk_len(i) := 150;
      elsif i between 14 and 15 then
      chk_len(i) := 10;
      elsif i = 16 then
      chk_len(i) := 25;
      elsif i between 17 and 18 then
      chk_len(i) := 4;  
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    --check require data column 
                    for i in 1..v_column loop
                        if i in (1,2,3,4,5,6,7,8,11,12) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;
                    end loop;

                    --check length all columns                  
                    for i in 1..v_column loop
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop; 


          --assign value to var
          v_codcomp   := v_text(1);
          v_codcomp1    := v_text(2);
          v_codcomp2    := v_text(3);
          v_codcomp3    := v_text(4);
          v_codcomp4    := v_text(5);
          v_codcomp5    := v_text(6);
          v_codcomp6    := v_text(7);
          v_codcomp7    := v_text(8);
          v_codcomp8    := v_text(9);
          v_codcomp9    := v_text(10);
          v_codcomp10   := v_text(11);
          v_namcente    := v_text(12);
          v_namcentt    := v_text(13);
          v_naminite    := v_text(14);
          v_naminitt    := v_text(15);
          v_costcent    := v_text(16);
          v_compgrp   := v_text(17);
          v_codposr   := v_text(18);


                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_comlevel   := 0;
          v_subcomp    := v_codcomp1;

          if  to_number(v_codcomp2||v_codcomp3||v_codcomp4||v_codcomp5||v_codcomp6||v_codcomp7||v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 1;
          elsif   to_number(v_codcomp3||v_codcomp4||v_codcomp5||v_codcomp6||v_codcomp7||v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 2;
          elsif   to_number(v_codcomp4||v_codcomp5||v_codcomp6||v_codcomp7||v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 3;
          elsif   to_number(v_codcomp5||v_codcomp6||v_codcomp7||v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 4;
          elsif   to_number(v_codcomp6||v_codcomp7||v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 5;
          elsif   to_number(v_codcomp7||v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 6;
          elsif   to_number(v_codcomp8||v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 7;
          elsif   to_number(v_codcomp9||v_codcomp10) = 0 then
            v_comlevel   := 8;
          elsif   to_number(v_codcomp10) = 0 then
            v_comlevel   := 9;
          else  
            v_comlevel   := 10;
          end if;


                    begin 
            delete tcenter where codcomp = v_codcomp;

            insert into   tcenter(codcomp,namcente,namcentt,namcent3,namcent4,namcent5,
                        codcom1,codcom2,codcom3,codcom4,codcom5,codcom6,codcom7,codcom8,codcom9,codcom10,
                        codcompy,comlevel,comparent,naminite,naminitt,naminit3,naminit4,naminit5,
                        flgact,codproft,costcent,compgrp,codposr,codemprp,
                        dtecreate,codcreate,dteupd,coduser) 
                       values(v_codcomp,v_namcente,v_namcentt,v_namcente,v_namcente,v_namcente,
                        v_codcomp1,v_codcomp2,v_codcomp3,v_codcomp4,v_codcomp5,v_codcomp6,v_codcomp7,v_codcomp8,v_codcomp9,v_codcomp10,
                        v_codcomp1,v_comlevel,null,v_naminite,v_naminitt,v_naminite,v_naminite,v_naminite,
                        '1',null,v_costcent,v_compgrp,v_codposr,null,
                        trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

          begin
              delete tcompnyd where codcompy = v_codcomp1 and comlevel = v_comlevel and codcomp = v_subcomp;

              insert into tcompnyd(codcompy,comlevel,codcomp,
                         namcompe,namcompt,namcomp3,namcomp4,namcomp5,flgact,
                         dtecreate,codcreate,dteupd,coduser) 
                    values(v_codcomp1,v_comlevel,v_subcomp,
                         v_namcente,v_namcentt,v_namcente,v_namcente,v_namcente,'1',
                         trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);
          end;  
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  -- TPOSTN
  procedure get_process_co_tpostn(json_str_input    in clob,
                                  json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_co_tpostn(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
 procedure validate_excel_co_tpostn (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codpos         tpostn.codpos%type;
    v_nampose        tpostn.nampose%type;
    v_nampost        tpostn.nampost%type;
    v_namabbe        tpostn.namabbe%type;
    v_namabbt        tpostn.namabbt%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i = 1 then
      chk_len(i) := 4;
      elsif i in(2,3) then
      chk_len(i) := 150;
      elsif i in(4,5) then
      chk_len(i) := 50;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    --check require data column 
                    for i in 1..v_column loop
                        if i in (1,2,3) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;
                    end loop;

                    --check length all columns                  
                    for i in 1..v_column loop
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop; 


          --assign value to var
          v_codpos    := v_text(1);
          v_nampose   := v_text(2);
          v_nampost   := v_text(3);
          v_namabbe   := v_text(4);
          v_namabbt   := v_text(5);

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete tpostn where codpos = v_codpos;

            insert into  tpostn(codpos,nampose,nampost,nampos3,nampos4,nampos5,
                      namabbe,namabbt,namabb3,namabb4,namabb5,
                      dtecreate,codcreate,dteupd,coduser) 
                   values(v_codpos,v_nampose,v_nampost,v_nampose,v_nampose,v_nampose,
                      v_namabbe,v_namabbt,v_namabbe,v_namabbe,v_namabbe,
                      trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  -- TJOBCODE, TJOBDET
  procedure get_process_co_tjobcode(json_str_input    in clob,
                                    json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_co_tjobcode(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_co_tjobcode (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codjob         tjobcode.codjob%type;
    v_namjobe        tjobcode.namjobe%type;
    v_namjobt        tjobcode.namjobt%type;
    v_desjob         tjobcode.desjob%type;
    v_amtcolla       tjobcode.amtcolla%type;
    v_qtyguar        tjobcode.qtyguar%type;
    v_desguar        tjobcode.desguar%type;
    v_amtguarntr     tjobcode.amtguarntr%type;
    v_itemno         tjobdet.itemno%type;
    v_namitem        tjobdet.namitem%type;    
    v_descrip        tjobdet.descrip%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i = 1 then
      chk_len(i) := 4;
      elsif i in (2,3,10) then
      chk_len(i) := 150;
      elsif i in (4,7,11) then
      chk_len(i) := 600;  
      elsif i in (5,8) then
      chk_len(i) := 10;
    elsif i in (6) then
      chk_len(i) := 2;
    elsif i in (9) then
      chk_len(i) := 3;      
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    --check require data column 
                    for i in 1..v_column loop
                        if i in (1,2,3,4)  then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;
                    end loop;

                    --check length all columns                  
                    for i in 1..v_column loop
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop; 

          --check number format           
                    for i in 1..v_column loop
                        if i in (5,6,8,9) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;   
                            end if;
                        end if;
                    end loop; 

          --assign value to var
          v_codjob        := v_text(1);
          v_namjobe   := v_text(2);
          v_namjobt   := v_text(3);
          v_desjob        := v_text(4);
          v_amtcolla    := to_number(nvl(v_text(5),'0'),'9999999.99');
          v_qtyguar   := to_number(nvl(v_text(6),'0'),'99');
          v_desguar   := v_text(7);
          v_amtguarntr  := to_number(nvl(v_text(8),'0'),'9999999.99');
          v_itemno    := to_number(nvl(v_text(9),'0'),'999');
          v_namitem     := v_text(10);
          v_descrip   := v_text(11);

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin
              delete tjobcode where codjob = v_codjob;     

              insert into tjobcode(codjob,namjobe,namjobt,namjob3,namjob4,namjob5,
                         desjob,amtcolla,qtyguar,syncond,desguar,statement,amtguarntr, 
                         dtecreate,codcreate,dteupd,coduser) 
                    values(v_codjob,v_namjobe,v_namjobt,v_namjobe,v_namjobe,v_namjobe,
                         v_desjob,v_amtcolla,v_qtyguar,null,v_desguar,null,v_amtguarntr, 
                         trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);
          end;

          if v_itemno > 0 then 
            begin
                delete tjobdet where codjob = v_codjob and itemno = v_itemno;

                insert into tjobdet(codjob,itemno,namitem,descrip,
                          dtecreate,codcreate,dteupd,coduser) 
                       values(v_codjob,v_itemno,v_namitem,v_descrip,
                          trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);
            end;  
          end if; 
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  -- TCODAPLV, TCODAPPO, TCODASST, TCODAWRD, TCODBANK, TCODBONS, TCODBUSNO, TCODBUSRT, TCODCATE, TCODCATEXM, TCODCATG, TCODCERT, TCODCHGSH, TCODCNTY, TCODCOLA, TCODCURR, TCODDEVT, TCODDGEE, TCODDISP, TCODEDUC,TCODEMPL, TCODEXP, TCODFLEX, TCODGPOS, TCODGPPAY, TCODGRBUG, TCODGRPAP, TCODGRPGL, TCODHEAL, TCODINST, TCODISRP, TCODJOBG, TCODJOBPOST, TCODLANG, TCODLEGALD, TCODLOCA, TCODMAJR, TCODMEDI, TCODMIST, TCODMOVE,TCODNATN, TCODOCCU, TCODOTRQ, TCODPFINF, TCODPFPLC, TCODPFPLN, TCODPLCY, TCODPROV, TCODPUNH, TCODREASON, TCODREGN, TCODRELI, TCODRETM, TCODREVN, TCODREWD, TCODSERV, TCODSIZE, TCODSKIL, TCODSLIP, TCODSUBJ,TCODTIME, TCODTRAVUNIT, TCODTYDOC, TCODTYPCRT,TCODTYPWRK, TCODTYPY, TCODUNIT, TCODWORK, TCOMPGRP, TDCINF, TSUBJECT  
  procedure get_process_co_tcommon(
                                   json_str_input   in clob,
                                   json_str_output  out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_co_tcommon(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --                                
  procedure validate_excel_co_tcommon (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_table      varchar2(20);
  v_codcodec       varchar2(4);
    v_descode        varchar2(150);
    v_descodt        varchar2(150);
    v_descod3        varchar2(150);
    v_descod4        varchar2(150);
    v_descod5        varchar2(150);
    v_number         number := 0;
  v_cmdtext1     varchar2(300);
  v_cmdtext2     varchar2(300);

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i = 1 then
      chk_len(i) := 20;
      elsif i = 2 then
      chk_len(i) := 4;
      elsif i in (3,4,5,6,7) then
      chk_len(i) := 150;      
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
              v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    --check require data column 
                    for i in 1..v_column loop
                        if i in (1,2,3,4)  then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;
                    end loop;

                    --check length all columns                  
                    for i in 1..v_column loop
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop; 

          --assign value to var
          v_table   := v_text(1);
          v_codcodec  := v_text(2);
          v_descode := v_text(3);
          v_descodt := v_text(4);
          v_descod3 := v_text(5);
          v_descod4   := v_text(6);
          v_descod5 := v_text(7);

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                     begin
              v_cmdtext1 := 'delete '||v_table||' where codcodec = '''||v_codcodec||'''';                       
              v_number := execute_delete(v_cmdtext1);

              v_cmdtext2 := 'insert into '||v_table||'(codcodec,descode,descodt,descod3,descod4,descod5,flgcorr,flgact,dtecreate,codcreate,dteupd,coduser)  '||
                    'values('''||v_codcodec||''','''||v_descode||''','''||v_descodt||''','''||v_descod3||''','''||v_descod4||''','''||v_descod5||''','''||1||''','''||1||''','||
                        'sysdate,'||''''||global_v_coduser||''',sysdate,'||''''||global_v_coduser||''')';                      
                          v_number := execute_delete(v_cmdtext2);
          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

--PM----------------------------------------------------------------------------------------------------------


  procedure get_process_pm_temploy1 (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_temploy1(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_temploy1 (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;       
  v_codempid    temploy1.codempid%type;
  v_codtitle    temploy1.codtitle%type;
  v_namfirste   temploy1.namfirste%type;
  v_namfirstt   temploy1.namfirstt%type;
  v_namfirst3   temploy1.namfirst3%type;
  v_namfirst4   temploy1.namfirst4%type;
  v_namfirst5   temploy1.namfirst5%type;
  v_namlaste    temploy1.namlaste%type;
  v_namlastt    temploy1.namlastt%type;
  v_namlast3    temploy1.namlast3%type;
  v_namlast4    temploy1.namlast4%type;
  v_namlast5    temploy1.namlast5%type;
  v_namempe   temploy1.namempe%type;
  v_namempt   temploy1.namempt%type;
  v_namemp3   temploy1.namemp3%type;
  v_namemp4   temploy1.namemp4%type;
  v_namemp5   temploy1.namemp5%type;
  v_nickname    temploy1.nickname%type;
  v_nicknamt    temploy1.nicknamt%type;
  v_nicknam3    temploy1.nicknam3%type;
  v_nicknam4    temploy1.nicknam4%type;
  v_nicknam5    temploy1.nicknam5%type;
  v_dteempdb    temploy1.dteempdb%type;
  v_stamarry    temploy1.stamarry%type;
  v_codsex    temploy1.codsex%type;
  v_stamilit    temploy1.stamilit%type;
  v_dteempmt    temploy1.dteempmt%type;
  v_dteretire   temploy1.dteretire%type;
  v_codcomp   temploy1.codcomp%type;
  v_codpos    temploy1.codpos%type;
  v_numlvl    temploy1.numlvl%type;
  v_staemp    temploy1.staemp%type;
  v_dteeffex    temploy1.dteeffex%type;
  v_flgatten    temploy1.flgatten%type;
  v_codbrlc   temploy1.codbrlc%type;
  v_codempmt    temploy1.codempmt%type;
  v_typpayroll  temploy1.typpayroll%type;
  v_typemp    temploy1.typemp%type;
  v_codcalen    temploy1.codcalen%type;
  v_codjob    temploy1.codjob%type;
  v_codcompr    temploy1.codcompr%type;
  v_codposre    temploy1.codposre%type;
  v_dteeflvl    temploy1.dteeflvl%type;
  v_dteefpos    temploy1.dteefpos%type;
  v_dteduepr    temploy1.dteduepr%type;
  v_dteoccup    temploy1.dteoccup%type;
  v_qtydatrq    temploy1.qtydatrq%type;
  v_numtelof    temploy1.numtelof%type;
  v_nummobile   temploy1.nummobile%type;
  v_email     temploy1.email%type;
  v_lineid    temploy1.lineid%type;
  v_numreqst    temploy1.numreqst%type;
  v_numappl   temploy1.numappl%type;
  v_ocodempid   temploy1.ocodempid%type;
  v_flgreemp    temploy1.flgreemp%type;
  v_dtereemp    temploy1.dtereemp%type;
  v_dteredue    temploy1.dteredue%type;
  v_qtywkday    temploy1.qtywkday%type;
  v_codedlv   temploy1.codedlv%type;
  v_codmajsb    temploy1.codmajsb%type;
  v_numreqc   temploy1.numreqc%type;
  v_codposc   temploy1.codposc%type;
  v_flgreq    temploy1.flgreq%type;
  v_stareq    temploy1.stareq%type;
  v_codappr   temploy1.codappr%type;
  v_dteappr   temploy1.dteappr%type;
  v_staappr   temploy1.staappr%type;
  v_remarkap    temploy1.remarkap%type;
  v_codreq    temploy1.codreq%type;
  v_jobgrade    temploy1.jobgrade%type;
  v_dteefstep   temploy1.dteefstep%type;
  v_codgrpgl    temploy1.codgrpgl%type;
  v_stadisb   temploy1.stadisb%type;
  v_numdisab    temploy1.numdisab%type;
  v_typdisp   temploy1.typdisp%type;
  v_dtedisb   temploy1.dtedisb%type;
  v_dtedisen    temploy1.dtedisen%type;
  v_desdisp   temploy1.desdisp%type;
  v_typtrav   temploy1.typtrav%type;
  v_qtylength   temploy1.qtylength%type;
  v_carlicen    temploy1.carlicen%type;
  v_typfuel   temploy1.typfuel%type;
  v_codbusno    temploy1.codbusno%type;
  v_codbusrt    temploy1.codbusrt%type;
  v_maillang    temploy1.maillang%type;
  v_dteprgntst  temploy1.dteprgntst%type;
  v_flgpdpa   temploy1.flgpdpa%type;
  v_dtepdpa   temploy1.dtepdpa%type;
  v_approvno    temploy1.approvno%type;
  v_dtecreate   temploy1.dtecreate%type;
  v_codcreate   temploy1.codcreate%type;
  v_dteupd    temploy1.dteupd%type;
  v_coduser   temploy1.coduser%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10,4,30,30,30,30,45,45,10,1,1,1,10,10,40,4,99,1,10,1,4,4,4,4,4,4,4,4,10,10,10,10,10,999,25,25,50,50,10,10,1,13,4,10,10,500,1,5,10,1,4,4,3,1,10);
        for i in 1..v_column loop
            if i in (1,9,13,14,19,29,30,31,32,33,39,40,44,45,49,55) then
                chk_len(i) := 10;
            elsif i in (2,16,21,22,23,24,25,26,27,28,43,51,52) then
                chk_len(i) := 4;
      elsif i in (3,4,5,6) then
                chk_len(i) := 30;
      elsif i in (7,8) then
                chk_len(i) := 45;
      elsif i in (10,11,12,18,20,41,47,50,54) then
                chk_len(i) := 1;
      elsif i in (15) then
                chk_len(i) := 40;
      elsif i in (17) then
                chk_len(i) := 99;
      elsif i in (34) then
                chk_len(i) := 999;
      elsif i in (35,36) then
                chk_len(i) := 25;
      elsif i in (37,38) then
                chk_len(i) := 50;
      elsif i in (42) then
                chk_len(i) := 13;
      elsif i in (46) then
                chk_len(i) := 500;
      elsif i in (48) then
                chk_len(i) := 5;
      elsif i in (53) then
                chk_len(i) := 3;
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1)     := hcm_util.get_string_t(param_json_row,'col-1');        
        v_text(2)     := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)     := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)     := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)     := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)     := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)     := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)     := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9)     := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)    := hcm_util.get_string_t(param_json_row,'col-10');          
        v_text(11)    := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)    := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)    := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)    := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)    := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)    := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)    := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)    := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)    := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)    := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)    := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)    := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)    := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)    := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)    := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)    := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)    := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)    := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29)    := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30)    := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31)    := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32)    := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33)    := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34)    := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35)    := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36)    := hcm_util.get_string_t(param_json_row,'col-36');
        v_text(37)    := hcm_util.get_string_t(param_json_row,'col-37');
        v_text(38)    := hcm_util.get_string_t(param_json_row,'col-38');
        v_text(39)    := hcm_util.get_string_t(param_json_row,'col-39');
        v_text(40)    := hcm_util.get_string_t(param_json_row,'col-40');
        v_text(41)    := hcm_util.get_string_t(param_json_row,'col-41');
        v_text(42)    := hcm_util.get_string_t(param_json_row,'col-42');
        v_text(43)    := hcm_util.get_string_t(param_json_row,'col-43');
        v_text(44)    := hcm_util.get_string_t(param_json_row,'col-44');
        v_text(45)    := hcm_util.get_string_t(param_json_row,'col-45');
        v_text(46)    := hcm_util.get_string_t(param_json_row,'col-46');
        v_text(47)    := hcm_util.get_string_t(param_json_row,'col-47');
        v_text(48)    := hcm_util.get_string_t(param_json_row,'col-48');
        v_text(49)    := hcm_util.get_string_t(param_json_row,'col-49');
        v_text(50)    := hcm_util.get_string_t(param_json_row,'col-50');
        v_text(51)    := hcm_util.get_string_t(param_json_row,'col-51');
        v_text(52)    := hcm_util.get_string_t(param_json_row,'col-52');
        v_text(53)    := hcm_util.get_string_t(param_json_row,'col-53');
        v_text(54)    := hcm_util.get_string_t(param_json_row,'col-54');
        v_text(55)    := hcm_util.get_string_t(param_json_row,'col-55');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --                                
                    for i in 1..v_column loop
                        --check require data column
                          if i in (1,2,3,4,5,6,9,10,11,13,15,16,17,18,20,21,22,23,24,25,26,27,28,29,30,31,41,47,53,54) then  
                            if v_text(i) is  null or length(trim(v_text(i))) is null then
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns     
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                               
                            if length(v_text(i)) > chk_len(i) then                                
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (9,13,14,19,29,30,31,32,33) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop; 

          --assign value to var
          v_codempid    := v_text(1);
          v_codtitle    := v_text(2);
          v_namfirste   := v_text(3);
          v_namfirstt   := v_text(4);
          v_namlaste    := v_text(5);
          v_namlastt    := v_text(6);
          v_nickname    := v_text(7);
          v_nicknamt    := v_text(8);
          v_dteempdb  := null;
          if v_text(9) is not null or length(trim(v_text(9))) is not null then
            v_dteempdb  := check_dteyre(v_text(9));
          end if;             
          v_stamarry    := v_text(10);
          v_codsex    := v_text(11);
          v_stamilit    := v_text(12);
          if v_codsex = 'F' then
            v_stamilit  := null;
          end if;
          v_dteempmt    := null;
          if v_text(13) is not null or length(trim(v_text(13))) is not null then
            v_dteempmt  := check_dteyre(v_text(13));
          end if;
          v_dteretire   := null;
          if v_text(14) is not null or length(trim(v_text(14))) is not null then
            v_dteretire := check_dteyre(v_text(14));
          end if;
          v_codcomp   := v_text(15);
          v_codpos    := v_text(16);
          v_numlvl    := v_text(17);
          v_staemp    := v_text(18);
          v_dteeffex    := null;
          if v_text(19) is not null or length(trim(v_text(19))) is not null then
            v_dteeffex  := check_dteyre(v_text(19));
          end if;
          v_flgatten    := v_text(20);
          v_codbrlc   := v_text(21);
          v_codempmt    := v_text(22);
          v_typpayroll  := v_text(23);
          v_typemp    := v_text(24);
          v_codcalen    := v_text(25);
          v_codjob    := v_text(26);
          v_jobgrade    := v_text(27);
          v_codgrpgl    := v_text(28);
          v_dteeflvl    := null;
          if v_text(29) is not null or length(trim(v_text(29))) is not null then
            v_dteeflvl  := check_dteyre(v_text(29));
          end if;
          v_dteefpos    := null;
          if v_text(30) is not null or length(trim(v_text(30))) is not null then
            v_dteefpos  := check_dteyre(v_text(30));
          end if;
          v_dteefstep   := null;
          if v_text(31) is not null or length(trim(v_text(31))) is not null then
            v_dteefstep := check_dteyre(v_text(31));
          end if;
          v_dteduepr    :=null;
          if v_text(32) is not null or length(trim(v_text(32))) is not null then
            v_dteduepr  := check_dteyre(v_text(32));
          end if;   
          v_dteoccup    := null;
          if v_text(33) is not null or length(trim(v_text(33))) is not null then
            v_dteoccup  := check_dteyre(v_text(33));
          end if;       
          v_qtydatrq    := v_text(34);
          v_numtelof    := v_text(35);
          v_nummobile := v_text(36);
          v_email     := v_text(37);
          v_lineid        := v_text(38);
          v_numappl   := v_text(39);
          v_ocodempid := v_text(40);
          v_stadisb   := v_text(41);
          v_numdisab    := v_text(42);
          v_typdisp   := v_text(43);
          v_dtedisb   := null;
          if v_text(44) is not null or length(trim(v_text(44))) is not null then
            v_dtedisb := check_dteyre(v_text(44));
          end if; 
          v_dtedisen    := null;
          if v_text(45) is not null or length(trim(v_text(45))) is not null then
            v_dtedisen  := check_dteyre(v_text(45));
          end if; 
          v_desdisp   := v_text(46);
          v_typtrav   := v_text(47);
          v_qtylength   := v_text(48);
          v_carlicen    := v_text(49);
          v_typfuel   := v_text(50);
          v_codbusno    := v_text(51);
          v_codbusrt    := v_text(52);
          v_maillang    := v_text(53);
          v_flgpdpa   := v_text(54);
          v_dtepdpa   := null;
          if v_text(55) is not null or length(trim(v_text(55))) is not null then
            v_dtepdpa := check_dteyre(v_text(55));
          end if; 

                    --check incorrect data      
                    --check codtitle  
                    if v_codtitle not in ('003','004','005') then
                        v_error      := true;
                        v_err_code    := 'HR2020';
                        v_err_field     := v_field(5);
                        exit cal_loop;
                    end if;

                    --check dteempdb 
          select floor(months_between(sysdate, v_dteempdb) /12) into v_int_temp from dual;
          if v_int_temp < 18 then
            v_error   := true;
                        v_err_code  := 'PM0014';
                        v_err_field := v_field(9);                                
                        exit cal_loop;
          end if;

          --check stamarry 
                    if(v_stamarry not in ('S','M','D','W','I')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(10);
                        exit cal_loop;
                    end if;

          --check codsex 
                    if(v_codsex not in ('M','F')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(8);
                        exit cal_loop;
                    end if;

          --check stamilit 
                    if(v_codsex = 'M' and ((v_stamilit is null) or length(trim(v_stamilit)) is null)) then
                        v_error   := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(12);
                        exit cal_loop;
                    end if;

          if(v_codsex = 'M' and v_stamilit not in ('P','N','O') ) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(12);
                        exit cal_loop;
                    end if;

          --check codcomp       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcenter  
                        where codcomp  = v_codcomp;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(15);
                        v_err_table := 'TCENTER';
                        exit cal_loop;
                    end;

          --check codpos        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tpostn   
                        where codpos  = v_codpos;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(16);
                        v_err_table := 'TPOSTN';
                        exit cal_loop;
                    end;          

          --check staemp 
                    if(v_staemp not in ('0','1','3','9')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(18);
                        exit cal_loop;
                    end if;

          --check dteeffex 
                    if(v_staemp = '9' and ((v_dteeffex is null) or length(trim(v_dteeffex)) is null)) then
                        v_error   := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(19);
                        exit cal_loop;
                    end if;

          if((v_dteeffex is not null) or length(trim(v_dteeffex)) is not null) then
            if v_dteeffex < v_dteempmt then
              v_error   := true;
              v_err_code  := 'HR5017';
              v_err_field := v_field(19);
              exit cal_loop;
            end if; 
                    end if;

          --check flgatten 
                    if(v_flgatten not in ('Y','N','O')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(20);
                        exit cal_loop;
                    end if;

                    --check codbrlc 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodloca  
                        where codcodec = v_codbrlc;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(21);
                        v_err_table := 'TCODLOCA';
                        exit cal_loop;
                    end;

                    --check codempmt 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodempl   
                        where codcodec = v_codempmt;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(22);
                        v_err_table := 'TCODEMPL';
                        exit cal_loop;
                    end;

          --check typpayroll 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodtypy    
                        where codcodec = v_typpayroll;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(23);
                        v_err_table := 'TCODTYPY';
                        exit cal_loop;
                    end;

          --check typemp 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodcatg     
                        where codcodec = v_typemp;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(24);
                        v_err_table := 'TCODCATG';
                        exit cal_loop;
                    end;

          --check codcalen 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodwork      
                        where codcodec = v_codcalen;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(25);
                        v_err_table := 'TCODWORK';
                        exit cal_loop;
                    end;

          --check codjob 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tjobcode       
                        where codjob = v_codjob;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(26);
                        v_err_table := 'TJOBCODE';
                        exit cal_loop;
                    end;

                    --check jobgrade 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from TCODJOBG        
                        where codcodec = v_jobgrade;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(27);
                        v_err_table := 'TCODJOBG';
                        exit cal_loop;
                    end;

          --check codgrpgl 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodgrpgl         
                        where codcodec = v_codgrpgl;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(28);
                        v_err_table := 'TCODGRPGL';
                        exit cal_loop;
                    end;

          --check dteduepr 
                    if(v_staemp in ('1','3') and ((v_dteduepr is null) or length(trim(v_dteduepr)) is null)) then
                        v_error   := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(32);
                        exit cal_loop;
                    end if;

          --check stadisb 
                    if v_stadisb is not null or length(trim(v_stadisb)) is not null then
                        if v_stadisb not in ('Y','N') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(41);
                            exit cal_loop;
                        end if;
                    end if;

          --check flgpdpa 
                     if v_flgpdpa is not null or length(trim(v_flgpdpa)) is not null then
                        if v_flgpdpa not in ('Y','N' )then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(54);
                            exit cal_loop;
                        end if;
                    end if;

          --check numdisab, typdisp, dtedisb, dtedisen, desdisp
           if v_stadisb = 'Y' then
             for i in 42..46 loop
              if (v_text(i) is null or length(trim(v_text(i))) is null) then
                v_error   := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;
             end loop;
           end if;

           --check typdisp 
                    if v_typdisp is not null or length(trim(v_typdisp)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcoddisp       
                            where codcodec = v_typdisp;
                        exception when no_data_found then 
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(43);
                            v_err_table := 'TCODDISP';
                            exit cal_loop;
                        end;
           end if;

          --check typtrav 
                    if v_typtrav is not null or length(trim(v_typtrav)) is not null then
                        if(v_typtrav not in ('1','2','3'))then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(47);
                            exit cal_loop;
                        end if; 
                    end if; 

          --check typfuel 
                    if v_typfuel is not null or length(trim(v_typfuel)) is not null then
                        if(v_typfuel not in ('1','2'))then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(50);
                            exit cal_loop;
                        end if; 
                    end if;

          --check cobusno 
                    if v_codbusno is not null or length(trim(v_codbusno)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodbusno        
                            where codcodec = v_codbusno;
                        exception when no_data_found then 
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(51);
                            v_err_table := 'TCODBUSNO';
                            exit cal_loop;
                        end;
                    end if;

          --check cobusrt 
                    if v_codbusrt is not null or length(trim(v_codbusrt)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodbusrt         
                            where codcodec = v_codbusrt;
                        exception when no_data_found then 
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(52);
                            v_err_table := 'TCODBUSRT';
                            exit cal_loop;
                        end;
                    end if;

          --check maillang 
                    if(v_maillang not in ('101','102'))then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(53);
                        exit cal_loop;
                    end if; 

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_namfirst3     := v_namfirste;
          v_namfirst4     := v_namfirste;
          v_namfirst5   := v_namfirste;
          v_namlast3    := v_namlaste;
          v_namlast4    := v_namlaste;
          v_namlast5  := v_namlaste;
          v_namempe := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'101'))) || ltrim(rtrim(v_namfirste))||' '||ltrim(rtrim(v_namlaste)),1,60);
          v_namempt     := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'102'))) || ltrim(rtrim(v_namfirstt))||' '||ltrim(rtrim(v_namlastt)),1,60);
          v_namemp3 := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'103'))) || ltrim(rtrim(v_namfirst3))||' '||ltrim(rtrim(v_namlast3)),1,60);
          v_namemp4 := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'104'))) || ltrim(rtrim(v_namfirst4))||' '||ltrim(rtrim(v_namlast4)),1,60);
          v_namemp5 := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'105'))) || ltrim(rtrim(v_namfirst5))||' '||ltrim(rtrim(v_namlast5)),1,60);
          v_nicknam3      := v_nickname;
          v_nicknam4  := v_nickname;
          v_nicknam5    := v_nickname;
          v_codcompr  := null;
          v_codposre      := null;
          v_numreqst      := null;
          v_flgreemp      := null;
          v_dtereemp    := null;
          v_dteredue      := null;
          v_qtywkday    := null;
          v_codedlv     := null;
          v_codmajsb      := null;
          v_numreqc     := null;
          v_codposc     := null;
          v_flgreq          := null;
          v_stareq          := null;
          v_codappr     := null;
          v_dteappr     := null;
          v_staappr     := null;
          v_remarkap    := null;
          v_codreq      := null;
          v_approvno    := null;

                    begin 
            delete from temploy1 where codempid  = v_codempid;                        

            insert into temploy1(codempid,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                                        namlaste,namlastt,namlast3,namlast4,namlast5,
                                                        namempe,namempt,namemp3,namemp4,namemp5,
                                                        nickname,nicknamt,nicknam3,nicknam4,nicknam5,
                                                        dteempdb,stamarry,codsex,stamilit,dteempmt,
                                                        dteretire,codcomp,codpos,numlvl,staemp,
                                                        dteeffex,flgatten,codbrlc,codempmt,typpayroll,
                                                        typemp,codcalen,codjob,codcompr,codposre,
                                                        dteeflvl,dteefpos,dteduepr,dteoccup,qtydatrq,
                                                        numtelof,nummobile,email,lineid,numreqst,numappl,
                                                        ocodempid,flgreemp,dtereemp,dteredue,qtywkday,codedlv,
                                                        codmajsb,numreqc,codposc,flgreq,stareq,codappr,
                                                        dteappr,staappr,remarkap,codreq,jobgrade,dteefstep,
                                                        codgrpgl,stadisb,numdisab,typdisp,dtedisb,dtedisen,
                                                        desdisp,typtrav,qtylength,carlicen,typfuel,codbusno,
                                                        codbusrt,maillang,dteprgntst,flgpdpa,dtepdpa,approvno,
                                                        dtecreate, codcreate, dteupd, coduser)  
                                        values  (v_codempid,v_codtitle,v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,
                                                        v_namlaste,v_namlastt,v_namlast3,v_namlast4,v_namlast5,
                                                        v_namempe,v_namempt,v_namemp3,v_namemp4,v_namemp5,
                                                        v_nickname,v_nicknamt,v_nicknam3,v_nicknam4,v_nicknam5,
                                                        v_dteempdb,v_stamarry,v_codsex,v_stamilit,v_dteempmt,
                                                        v_dteretire,v_codcomp,v_codpos,v_numlvl,v_staemp,
                                                        v_dteeffex,v_flgatten,v_codbrlc,v_codempmt,v_typpayroll,
                                                        v_typemp,v_codcalen,v_codjob,v_codcompr,v_codposre,
                                                        v_dteeflvl,v_dteefpos,v_dteduepr,v_dteoccup,v_qtydatrq,
                                                        v_numtelof,v_nummobile,v_email,v_lineid,v_numreqst,v_numappl,
                                                        v_ocodempid,v_flgreemp,v_dtereemp,v_dteredue,v_qtywkday,v_codedlv,
                                                        v_codmajsb,v_numreqc,v_codposc,v_flgreq,v_stareq,v_codappr,
                                                        v_dteappr,v_staappr,v_remarkap,v_codreq,v_jobgrade,v_dteefstep,
                                                        v_codgrpgl,v_stadisb,v_numdisab,v_typdisp,v_dtedisb,v_dtedisen,
                                                        v_desdisp,v_typtrav,v_qtylength,v_carlicen,v_typfuel,v_codbusno,
                                                        v_codbusrt,v_maillang,v_dteprgntst,v_flgpdpa,v_dtepdpa,v_approvno,
                                                        trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);                  
            end;
    end loop;  

  end;  

procedure get_process_pm_temploy2 (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_temploy2(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_temploy2 (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                   number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codempid    temploy2.codempid%type;
  v_adrrege   temploy2.adrrege%type;
  v_adrregt   temploy2.adrregt%type;
  v_adrreg3   temploy2.adrreg3%type;
  v_adrreg4   temploy2.adrreg4%type;
  v_adrreg5   temploy2.adrreg5%type;
  v_codsubdistr temploy2.codsubdistr%type;
  v_coddistr    temploy2.coddistr%type;
  v_codprovr    temploy2.codprovr%type;
  v_codcntyr    temploy2.codcntyr%type;
  v_codpostr    temploy2.codpostr%type;
  v_adrconte    temploy2.adrconte%type;
  v_adrcontt    temploy2.adrcontt%type;
  v_adrcont3    temploy2.adrcont3%type;
  v_adrcont4    temploy2.adrcont4%type;
  v_adrcont5    temploy2.adrcont5%type;
  v_codsubdistc temploy2.codsubdistc%type;
  v_coddistc    temploy2.coddistc%type;
  v_codprovc    temploy2.codprovc%type;
  v_codcntyc    temploy2.codcntyc%type;
  v_codpostc    temploy2.codpostc%type;
  v_numtelec    temploy2.numtelec%type;
  v_codblood    temploy2.codblood%type;
  v_weight        temploy2.weight%type;
  v_high      temploy2.high%type;
  v_codrelgn    temploy2.codrelgn%type;
  v_codorgin    temploy2.codorgin%type;
  v_codnatnl    temploy2.codnatnl%type;
  v_coddomcl    temploy2.coddomcl%type;
  v_numoffid    temploy2.numoffid%type;
  v_adrissue    temploy2.adrissue%type;
  v_codprovi    temploy2.codprovi%type;
  v_dteoffid    temploy2.dteoffid%type;
  v_codclnsc    temploy2.codclnsc%type;
  v_numlicid    temploy2.numlicid%type;
  v_dtelicid        temploy2.dtelicid%type;
  v_numpasid    temploy2.numpasid%type;
  v_dtepasid    temploy2.dtepasid%type;
  v_numvisa   temploy2.numvisa%type;
  v_dtevisaexp  temploy2.dtevisaexp%type;
  v_numprmid  temploy2.numprmid%type;
  v_dteprmst    temploy2.dteprmst%type;
  v_dteprmen    temploy2.dteprmen%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10,100,100,4,4,4,4,5,100,100,4,4,4,4,5,20,4,3,3,4,4,4,4,13,20,4,10,4,13,10,20,10,20,10,20,10,10);    
        for i in 1..v_column loop
            if i in (1,27,30,32,34,36,37) then
                chk_len(i) := 10;
            elsif i in (2,3,9,10) then
                chk_len(i) := 100;
      elsif i in (4,5,6,7,11,12,13,14,17,20,21,22,23,26,28) then
                chk_len(i) := 4;
      elsif i in (8,15) then
                chk_len(i) := 5;
      elsif i in (18,19) then
                chk_len(i) := 3;
      elsif i in (24,29) then
                chk_len(i) := 13;
      elsif i in (16,25,31,33,35) then
                chk_len(i) := 20;     
            else
                chk_len(i) := 0;
            end if;
        end loop;                

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field   := null;
                v_err_table  := null;
                v_error       := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29)  := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30)  := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31)  := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32)  := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33)  := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34)  := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35)  := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36)  := hcm_util.get_string_t(param_json_row,'col-36');
        v_text(37)  := hcm_util.get_string_t(param_json_row,'col-37');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --                               
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,24) then     
                            if v_text(i) is null or length(trim(v_text(i))) is null  then      
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;                    

                        --check length all columns     
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;                   

                        --check date format
                        if i in (27,30,32,34,36,37) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;                    

                        --check number format   
                        if i in (8,15,18,19) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop;                       

          --assign value to var
          v_codempid    := v_text(1);
          v_adrrege   := v_text(2);
          v_adrregt   := v_text(3);
          v_codsubdistr := v_text(4);
          v_coddistr    := v_text(5);
          v_codprovr    := v_text(6);
          v_codcntyr    := v_text(7);
          v_codpostr    := v_text(8);
          if v_text(8) is not null or length(trim(v_text(8))) is not null then
            v_codpostr  := to_number(v_text(8),'99999');
          end if;
          v_adrconte    := v_text(9);
          v_adrcontt    := v_text(10);
          v_codsubdistc := v_text(11);
          v_coddistc    := v_text(12);
          v_codprovc    := v_text(13);
          v_codcntyc    := v_text(14);
          v_codpostc    := v_text(15);
          if v_text(15) is not null or length(trim(v_text(15))) is not null then
            v_codpostc  := to_number(v_text(15),'99999');
          end if;
          v_numtelec    := v_text(16);
          v_codblood    := v_text(17);
          v_weight    := v_text(18);
          if v_text(18) is not null or length(trim(v_text(18))) is not null then
            v_weight  := to_number(v_text(18),'999');
          end if;
          v_high      := v_text(19);
          if v_text(19) is not null or length(trim(v_text(19))) is not null then
            v_high    := to_number(v_text(19),'999');
          end if;
          v_codrelgn    := v_text(20);
          v_codorgin    := v_text(21);
          v_codnatnl    := v_text(22);
          v_coddomcl    := v_text(23);
          v_numoffid    := v_text(24);
          v_adrissue    := v_text(25);
          v_codprovi    := v_text(26);
          v_dteoffid    := null;
          if v_text(27) is not null or length(trim(v_text(27))) is not null then
            v_dteoffid  := check_dteyre(v_text(27));
          end if;
          v_codclnsc    := v_text(28);
          v_numlicid    := v_text(29);
          v_dtelicid    := null;
          if v_text(30) is not null or length(trim(v_text(30))) is not null then
            v_dtelicid  := check_dteyre(v_text(30));
          end if;
          v_numpasid    := v_text(31);
          v_dtepasid    := null;
          if v_text(32) is not null or length(trim(v_text(32))) is not null then
            v_dtepasid  := check_dteyre(v_text(32));
          end if;
          v_numvisa   := v_text(33);
          v_dtevisaexp  := null;
          if v_text(34) is not null or length(trim(v_text(34))) is not null then
            v_dtevisaexp  := check_dteyre(v_text(34));
          end if;
          v_numprmid    := v_text(35);
          v_dteprmst    := v_text(36);
          if v_text(36) is not null or length(trim(v_text(36))) is not null then
            v_dteprmst  := check_dteyre(v_text(36));
          end if;
          v_dteprmen    := null;
          if v_text(37) is not null or length(trim(v_text(37))) is not null then
            v_dteprmen  := check_dteyre(v_text(37));
          end if;

                    --check incorrect data  
          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          --check codsubdistr       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tsubdist    
                        where codsubdist  = v_codsubdistr;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(4);
                        v_err_table := 'TSUBDIST';
                        exit cal_loop;
                    end;  

          --check coddistr        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcoddist    
                        where coddist  = v_coddistr;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(5);
                        v_err_table := 'TCODDIST';
                        exit cal_loop;
                    end;

          --check codprovr, codprovc, coddomcl, codprovi        
                    for i in 6..26 loop
            if i in (6,13,23,26) then             
              if v_text(i) is not null or length(trim(v_text(i))) is not null then
                v_chk_exists := 0;
                begin 
                  select 1 into v_chk_exists from tcodprov     
                  where codcodec  = v_text(i);
                exception when no_data_found then  
                  v_error   := true;
                  v_err_code  := 'HR2010';
                  v_err_field := v_field(i);
                  v_err_table := 'TCODPROV';
                  exit cal_loop;
                end;
              end if; 
            end if;
          end loop;

          --check codcntyr        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodcnty    
                        where codcodec  = v_codcntyr;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(7);
                        v_err_table := 'TCODCNTY';
                        exit cal_loop;
                    end;

          --check codrelgn  
          if v_codrelgn is not null or length(trim(v_codrelgn)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodreli    
              where codcodec  = v_codrelgn;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(20);
              v_err_table := 'TCODRELI';
              exit cal_loop;
            end;
          end if;

          --check codorgin        
                    if v_codorgin is not null or length(trim(v_codorgin)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodregn    
              where codcodec  = v_codorgin;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(21);
              v_err_table := 'TCODREGN';
              exit cal_loop;
            end;
          end if;

          --check codnatnl        
                    if v_codnatnl is not null or length(trim(v_codnatnl)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodnatn    
              where codcodec  = v_codnatnl;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(22);
              v_err_table := 'TCODNATN';
              exit cal_loop;
            end;
          end if;

          --check codclnsc  
          if v_codclnsc is not null or length(trim(v_codclnsc)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tclninf    
              where codcln  = v_codclnsc;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(28);
              v_err_table := 'TCLNINF';
              exit cal_loop;
            end;
          end if; 

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_adrreg3 := v_adrrege;
          v_adrreg4 := v_adrrege;
          v_adrreg5 := v_adrrege;
          v_adrcont3  := v_adrconte;
          v_adrcont4  := v_adrconte;
          v_adrcont5  := v_adrconte;

                    begin 
            delete from temploy2 where codempid  = v_codempid;                        

            insert into temploy2(codempid,adrrege,adrregt,adrreg3,adrreg4,adrreg5,
                                                        codsubdistr,coddistr,codprovr,codcntyr,codpostr,
                                                        adrconte,adrcontt,adrcont3,adrcont4,adrcont5,
                                                        codsubdistc,coddistc,codprovc,codcntyc,codpostc,numtelec,
                                                        codblood,weight,high,codrelgn,codorgin,codnatnl,
                                                        coddomcl,numoffid,adrissue,codprovi,dteoffid,codclnsc,
                                                        numlicid,dtelicid,numpasid,dtepasid,numvisa,dtevisaexp,
                                                        numprmid,dteprmst,dteprmen,dtecreate,codcreate,dteupd,coduser)  
                                        values  (v_codempid,v_adrrege,v_adrregt,v_adrreg3,v_adrreg4,v_adrreg5,
                                                        v_codsubdistr,v_coddistr,v_codprovr,v_codcntyr,v_codpostr,
                                                        v_adrconte,v_adrcontt,v_adrcont3,v_adrcont4,v_adrcont5,
                                                        v_codsubdistc,v_coddistc,v_codprovc,v_codcntyc,v_codpostc,v_numtelec,
                                                        v_codblood,v_weight,v_high,v_codrelgn,v_codorgin,v_codnatnl,
                                                        v_coddomcl,v_numoffid,v_adrissue,v_codprovi,v_dteoffid,v_codclnsc,
                                                        v_numlicid,v_dtelicid,v_numpasid,v_dtepasid,v_numvisa,v_dtevisaexp,
                                                        v_numprmid,v_dteprmst,v_dteprmen, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));                   
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_temploy3 (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_temploy3(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_temploy3 (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codempid    temploy3.codempid%type;
  v_codcurr   temploy3.codcurr%type;
  v_amtincom1   temploy3.amtincom1%type;
  v_amtincom2   temploy3.amtincom2%type;
  v_amtincom3   temploy3.amtincom3%type;
  v_amtincom4   temploy3.amtincom4%type;
  v_amtincom5   temploy3.amtincom5%type;
  v_amtincom6   temploy3.amtincom6%type;
  v_amtincom7   temploy3.amtincom7%type;
  v_amtincom8   temploy3.amtincom8%type;
  v_amtincom9   temploy3.amtincom9%type;
  v_amtincom10  temploy3.amtincom10%type;
  v_numtaxid    temploy3.numtaxid%type;
  v_numsaid   temploy3.numsaid%type;
  v_flgtax    temploy3.flgtax%type;
  v_typtax    temploy3.typtax%type;
  v_typincom    temploy3.typincom%type;
  v_codbank   temploy3.codbank%type;
  v_numbank   temploy3.numbank%type;
  v_amtbank   temploy3.amtbank%type;
  v_amttranb    temploy3.amttranb%type;
  v_codbank2    temploy3.codbank2%type;
  v_numbank2    temploy3.numbank2%type;
  v_amtothr   temploy3.amtothr%type;
  v_amtday    temploy3.amtday%type;
  v_dtebf     temploy3.dtebf%type;
  v_amtincbf    temploy3.amtincbf%type;
  v_amttaxbf    temploy3.amttaxbf%type;
  v_amtpf     temploy3.amtpf%type;
  v_amtsaid   temploy3.amtsaid%type;
  v_dtebfsp   temploy3.dtebfsp%type;
  v_amtincsp    temploy3.amtincsp%type;
  v_amttaxsp    temploy3.amttaxsp%type;
  v_amtsasp   temploy3.amtsasp%type;
  v_amtpfsp   temploy3.amtpfsp%type;
  v_dteyrrelf   temploy3.dteyrrelf%type;
  v_dteyrrelt   temploy3.dteyrrelt%type;
  v_amtrelas    temploy3.amtrelas%type;
  v_amttaxrel   temploy3.amttaxrel%type;
  v_numbrnch    temploy3.numbrnch%type;
  v_numbrnch2   temploy3.numbrnch2%type;
  v_amtproadj   temploy3.amtproadj%type;
  v_qtychldb    temploy3.qtychldb%type;
  v_qtychlda    temploy3.qtychlda%type;
  v_qtychldd    temploy3.qtychldd%type;
  v_qtychldi    temploy3.qtychldi%type;
  v_flgslip   temploy3.flgslip%type;
  v_repays    temploy3.repays%type;
  v_qtychedu    temploy3.qtychedu%type;
  v_qtychned    temploy3.qtychned%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10,4,9,9,9,9,9,9,9,9,9,9,13,13,1,1,1,4,15,6,9,4,15,9,9,9,9,9,9,9,9,4,4,9,9,9,9,9,1);
        for i in 1..v_column loop
            if i in (1) then
                chk_len(i) := 10;
            elsif i in (2,18,22,32,33) then
                chk_len(i) := 4;
      elsif i in (3,4,5,6,7,8,9,10,11,12,21,24,25,26,27,28,29,30,31,34) then
                chk_len(i) := 9;
      elsif i in (13,14) then
                chk_len(i) := 13;
      elsif i in (15,16,17,39) then
                chk_len(i) := 1;
      elsif i in (19,23) then
                chk_len(i) := 15;
      elsif i in (20) then
                chk_len(i) := 6;
      elsif i in (35,36,37,38) then
                chk_len(i) := 2;      
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29)  := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30)  := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31)  := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32)  := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33)  := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34)  := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35)  := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36)  := hcm_util.get_string_t(param_json_row,'col-36');
        v_text(37)  := hcm_util.get_string_t(param_json_row,'col-37');
        v_text(38)  := hcm_util.get_string_t(param_json_row,'col-38');
        v_text(39)  := hcm_util.get_string_t(param_json_row,'col-39');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --     
                    for i in 1..v_column loop
                        --check require data column 
                       if i in (1,2,3,13,14,15,16,17,39)  then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;                   

                        --check length all columns 
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check number format   
                        if i in (3,4,5,6,7,8,9,10,11,12,20,21,24,25,26,27,28,29,30,31,34,35,36,37,38) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;   
                            end if;
                        end if;
                    end loop;                     

          --assign value to var
          v_codempid    := v_text(1);
          v_codcurr   := v_text(2);
          v_amtincom1   := stdenc(to_number(nvl(v_text(3),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom2   := stdenc(to_number(nvl(v_text(4),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom3   := stdenc(to_number(nvl(v_text(5),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom4   := stdenc(to_number(nvl(v_text(6),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom5   := stdenc(to_number(nvl(v_text(7),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom6   := stdenc(to_number(nvl(v_text(8),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom7   := stdenc(to_number(nvl(v_text(9),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom8   := stdenc(to_number(nvl(v_text(10),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom9   := stdenc(to_number(nvl(v_text(11),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincom10  := stdenc(to_number(nvl(v_text(12),'0'),'999999.99'),v_codempid,v_chken);
          v_numtaxid    := v_text(13);
          v_numsaid   := v_text(14);
          v_flgtax    := v_text(15);
          v_typtax    := v_text(16);
          v_typincom    := v_text(17);
          v_codbank   := v_text(18);
          v_numbank   := v_text(19);
          v_amtbank   := to_number(nvl(v_text(20),'0'),'999.99');
          v_amttranb    := to_number(nvl(v_text(21),'0'),'999999.99');
          v_codbank2    := v_text(22);
          v_numbank2    := v_text(23);
          v_amtincbf    := stdenc(to_number(nvl(v_text(24),'0'),'999999.99'),v_codempid,v_chken);
          v_amttaxbf    := stdenc(to_number(nvl(v_text(25),'0'),'999999.99'),v_codempid,v_chken);
          v_amtpf     := stdenc(to_number(nvl(v_text(26),'0'),'999999.99'),v_codempid,v_chken);
          v_amtsaid   := stdenc(to_number(nvl(v_text(27),'0'),'999999.99'),v_codempid,v_chken);
          v_amtincsp    := stdenc(to_number(nvl(v_text(28),'0'),'999999.99'),v_codempid,v_chken);
          v_amttaxsp    := stdenc(to_number(nvl(v_text(29),'0'),'999999.99'),v_codempid,v_chken);
          v_amtsasp   := stdenc(to_number(nvl(v_text(30),'0'),'999999.99'),v_codempid,v_chken);
          v_amtpfsp   := stdenc(to_number(nvl(v_text(31),'0'),'999999.99'),v_codempid,v_chken);
          v_numbrnch    := v_text(32);
          v_numbrnch2   := v_text(33);
          v_amtproadj   := stdenc(to_number(nvl(v_text(34),'0'),'999999.99'),v_codempid,v_chken);
          v_qtychldb    := to_number(nvl(v_text(35),'0'),'99');
          v_qtychlda    := to_number(nvl(v_text(36),'0'),'99');
          v_qtychldd    := to_number(nvl(v_text(37),'0'),'99');
          v_qtychldi    := to_number(nvl(v_text(38),'0'),'99');
          v_flgslip   := v_text(39);

          --check incorrect data  
          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          --check codcurr       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodcurr    
                        where codcodec  = v_codcurr;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(2);
                        v_err_table := 'TCODCURR';
                        exit cal_loop;
                    end;

                    --check flgtax 
                    if v_flgtax not in ('1','2') then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(15);
                        exit cal_loop;
                    end if;

          --check typtax 
                    if v_typtax not in ('1','2') then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(16);
                        exit cal_loop;
                    end if;

          --check typincom 
                    if v_typincom not in ('1','3','4','5') then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(17);
                        exit cal_loop;
                    end if;

          --check codbank
            if v_codbank is not null or length(trim(v_codbank)) is not null then
              v_chk_exists := 0;
              begin 
                select 1 into v_chk_exists from tcodbank    
                where codcodec  = v_codbank;
              exception when no_data_found then  
                v_error   := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(18);
                v_err_table := 'TCODBANK';
                exit cal_loop;
              end;
          end if;  

          --check codbank2  
          if v_codbank2 is not null or length(trim(v_codbank2)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodbank    
              where codcodec  = v_codbank2;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(22);
              v_err_table := 'TCODBANK';
              exit cal_loop;
            end;
          end if;

          --check amtbank     
          if v_codbank2 is null and (v_codbank is not null and v_numbank is not null and v_amtbank is not null) then 
             if v_amtbank <> 100 then
                    v_error   := true;
                    v_err_code  := 'HR2020';
                    v_err_field := v_field(20);
                    exit cal_loop;
             end if;
          end if;

          if v_codbank2 is not null and (v_codbank is not null and v_numbank is not null and v_amtbank is not null) then 
            if v_amtbank > 100 then
                v_error   := true;
                v_err_code  := 'HR2020';
                v_err_field := v_field(20);
                exit cal_loop;
            end if;
         end if;

          if v_codbank is not null and v_numbank is not null and v_amtbank is not null then
            --pass
            null;
          else 
                        v_error   := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(18); --v_codbank is null

                        if v_numbank is null then 
                             v_err_field := v_field(19);
                        elsif   v_amtbank is null then 
                             v_err_field := v_field(20);
                        end if;

                        exit cal_loop;
         end if;

          if  (v_codbank is not null and v_numbank is not null and v_amtbank is not null) then 
            if (v_amtbank < 100 and v_codbank2 is null) then
                v_error   := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(22);
                exit cal_loop;
             elsif   (v_amtbank < 100 and  v_numbank2 is null) then
                v_error   := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(23);
                exit cal_loop;
            end if;
         end if;

          --check flgslip       
                    if v_flgslip not in ('1','2','3') then
            v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(39);
                        exit cal_loop;
            end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_amtothr := null;
          v_amtday  := null;
          v_dtebf   := null;
          v_dtebfsp := null;
          v_dteyrrelf := null;
          v_dteyrrelt := null;
          v_amtrelas  := null;
          v_amttaxrel := null;
          v_repays  := null;
          v_qtychedu  := null;
          v_qtychned  := null;

                    begin 
            delete from temploy3 where codempid  = v_codempid;                        

            insert into temploy3(codempid,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                                        amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,numtaxid,numsaid,
                                                        flgtax,typtax,typincom,codbank,numbank,amtbank,amttranb,
                                                        codbank2,numbank2,amtincbf,amttaxbf,amtpf,amtsaid,amtincsp,
                                                        amttaxsp,amtsasp,amtpfsp,numbrnch,numbrnch2,amtproadj,qtychldb,
                                                        qtychlda,qtychldd,qtychldi,flgslip,dtecreate,codcreate,dteupd,coduser)  
                                        values  (v_codempid,v_codcurr,v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                                                        v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10,v_numtaxid,v_numsaid,
                                                        v_flgtax,v_typtax,v_typincom,v_codbank,v_numbank,v_amtbank,v_amttranb,
                                                        v_codbank2,v_numbank2,v_amtincbf,v_amttaxbf,v_amtpf,v_amtsaid,v_amtincsp,
                                                        v_amttaxsp,v_amtsasp,v_amtpfsp,v_numbrnch,v_numbrnch2,v_amtproadj,v_qtychldb,
                                                        v_qtychlda,v_qtychldd,v_qtychldi,v_flgslip, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_teducatn (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_teducatn(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_teducatn (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    --v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_numappl   teducatn.numappl%type;
  v_numseq    teducatn.numseq%type;
  v_codempid    teducatn.codempid%type;
  v_codedlv   teducatn.codedlv%type;
  v_coddglv   teducatn.coddglv%type;
  v_codmajsb    teducatn.codmajsb%type;
  v_codminsb    teducatn.codminsb%type;
  v_codinst   teducatn.codinst%type;
  v_codcount    teducatn.codcount%type;
  v_numgpa    teducatn.numgpa%type;
  v_stayear   teducatn.stayear%type;
  v_dtegyear    teducatn.dtegyear%type;
  v_flgeduc   teducatn.flgeduc%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10,2,10,4,4,4,4,4,4,4,4,4,1);
        for i in 1..v_column loop
            if i in (1,3) then
                chk_len(i) := 10;
            elsif i in (2) then
                chk_len(i) := 2;
      elsif i in (4,5,6,7,8,9,10,11,12) then
                chk_len(i) := 4;
      elsif i in (13) then
                chk_len(i) := 1;  
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --    
                    for i in 1..v_column loop
                        --check require data column 
                         if i in (1,2,3,4,11,12,13) then                   
                            if v_text(i) is null or length(trim(v_text(i))) is null  then    
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns   
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check number format       
                        if i in (2,10,11,12) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop;                       

          --assign value to var
          v_numappl   := v_text(1);
          v_numseq    := to_number(nvl(v_text(2),'0'),'99');
          v_codempid    := v_text(3);
          v_codedlv   := v_text(4);
          v_coddglv   := v_text(5);
          v_codmajsb    := v_text(6);
          v_codminsb    := v_text(7);
          v_codinst   := v_text(8);
          v_codcount    := v_text(9);
          v_numgpa    := to_number(nvl(v_text(10),'0'),'9.99');
          v_stayear   := to_number(nvl(v_text(2),'0'),'9999');
          v_dtegyear    := to_number(nvl(v_text(2),'0'),'9999');
          v_flgeduc   := v_text(13);

          --check incorrect data  
          --check numappl       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where numappl = v_numappl and codempid = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(2);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          if v_numappl <> v_codempid then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(1);
                        exit cal_loop;
                    end if;

          --check codedlv       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodeduc    
                        where codcodec  = v_codedlv;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(4);
                        v_err_table := 'TCODEDUC';
                        exit cal_loop;
                    end;

          --check coddglv 
                    if v_coddglv is not null or length(trim(v_coddglv)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcoddgee    
                            where codcodec  = v_coddglv;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(5);
                            v_err_table := 'TCODDGEE';
                            exit cal_loop;
                        end;
                    end if;

          --check codmajsb    
                    if v_codmajsb is not null or length(trim(v_codmajsb)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodmajr    
                            where codcodec  = v_codmajsb;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(6);
                            v_err_table := 'TCODMAJR';
                            exit cal_loop;
                        end;
                    end if;   

          --check codminsb  
                    if v_codminsb is not null or length(trim(v_codminsb)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodsubj     
                            where codcodec  = v_codminsb;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(7);
                            v_err_table := 'TCODSUBJ';
                            exit cal_loop;
                        end;
                    end if;   

          --check codinst 
                    if v_codinst is not null or length(trim(v_codinst)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodinst     
                            where codcodec  = v_codinst;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(8);
                            v_err_table := 'TCODINST';
                            exit cal_loop;
                        end;
                    end if; 

          --check codcount    
                    if v_codcount is not null or length(trim(v_codcount)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodcnty     
                            where codcodec  = v_codcount;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(9);
                            v_err_table := 'TCODCNTY';
                            exit cal_loop;
                        end;
          end if;  

                    --check dtegyear 
                    if v_dtegyear < v_stayear then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(12);
                        exit cal_loop;
                    end if;

          --check flgeduc 
                    if v_flgeduc not in ('1','2') then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(13);
                        exit cal_loop;
                    end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete from teducatn  where numappl = v_numappl and numseq = v_numseq ;                       

            insert into teducatn (numappl, numseq, codempid, codedlv, coddglv, codmajsb,  
                        codminsb, codinst, codcount, numgpa, stayear, dtegyear,  
                        flgeduc, dtecreate, codcreate, dteupd, coduser)  
                                    values  (v_numappl, v_numseq, v_codempid, v_codedlv, v_coddglv, v_codmajsb,  
                        v_codminsb, v_codinst, v_codcount, v_numgpa, v_stayear, v_dtegyear,  
                        v_flgeduc, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser); 

                        if v_flgeduc = 1 then 
                            update teducatn set flgeduc = '2'  where  numappl = v_numappl and numseq <> v_numseq ;
                        end if;

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_tapplwex (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_tapplwex(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

  procedure validate_excel_pm_tapplwex (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    --v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_numappl   tapplwex.numappl%type;
  v_numseq    tapplwex.numseq%type;
  v_codempid    tapplwex.codempid%type;
  v_desnoffi    tapplwex.desnoffi%type;
  v_deslstjob1  tapplwex.deslstjob1%type;
  v_deslstpos   tapplwex.deslstpos%type;
  v_desoffi1    tapplwex.desoffi1%type;
  v_numteleo    tapplwex.numteleo%type;
  v_namboss   tapplwex.namboss%type;
  v_desres    tapplwex.desres%type;
  v_amtincom    tapplwex.amtincom%type;
  v_dtestart    tapplwex.dtestart%type;
  v_dteend    tapplwex.dteend%type;
  v_codtypwrk   tapplwex.codtypwrk%type;
  v_desjob    tapplwex.desjob%type;
  v_desrisk   tapplwex.desrisk%type;
  v_desprotc    tapplwex.desprotc%type;
  v_filewrkex   tapplwex.filewrkex%type;
  v_remark    tapplwex.remark%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10,2,10,45,100,45,100,20,45,45,9,10,10,100,100,200,500);   
        for i in 1..v_column loop
            if i in (1,3,12,13) then
                chk_len(i) := 10;
            elsif i in (2) then
                chk_len(i) := 2;
      elsif i in (4,6,9,10) then
                chk_len(i) := 45;
      elsif i in (5,7,14,15) then
                chk_len(i) := 100;  
      elsif i in (8) then
                chk_len(i) := 20; 
      elsif i in (11) then
                chk_len(i) := 9;  
      elsif i in (16) then
                chk_len(i) := 200;  
      elsif i in (17) then
                chk_len(i) := 500;  
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --                             
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,6)  then      
                            if v_text(i) is null or length(trim(v_text(i))) is null then
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns        
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;


                        --check date format
                        if i in (12,13) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;


                        --check number format   
                        if i in (2,11) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;   
                            end if; 
                        end if;
                    end loop;   


          --assign value to var         
          v_numappl   := v_text(1);
          v_numseq    := to_number(nvl(v_text(2),'0'),'99');
          v_codempid    := v_text(3);
          v_desnoffi    := v_text(4);
          v_deslstjob1  := v_text(5);
          v_deslstpos   := v_text(6);
          v_desoffi1    := v_text(7);
          v_numteleo    := v_text(8);
          v_namboss   := v_text(9);
          v_desres    := v_text(10);
          v_amtincom    := stdenc(to_number(nvl(v_text(11),'0'),'999999.99'),v_codempid,v_chken);
          v_dtestart    := null;
          if v_text(12) is not null or length(trim(v_text(12))) is not null then
            v_dtestart  := check_dteyre(v_text(12));
          end if;
          v_dteend    := null;
          if v_text(13) is not null or length(trim(v_text(13))) is not null then
            v_dteend  := check_dteyre(v_text(13));
          end if;       
          v_desjob    := v_text(14);
          v_desrisk   := v_text(15);
          v_desprotc    := v_text(16);
          v_remark    := v_text(17);

          --check incorrect data  
          --check numappl       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where numappl  = v_numappl and codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(2);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          if v_numappl <> v_codempid then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(1);
                        exit cal_loop;
                    end if;

          --check dteend        
           if v_dteend is not null and  v_dtestart is not null  then
                    if v_dteend < v_dtestart then
                        v_error   := true;
                        v_err_code  := 'HR6625';
                        v_err_field := v_field(13);
                        exit cal_loop;
                    end if;  
           end if;        

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then    
                    p_rec_tran := p_rec_tran + 1; 
          v_codtypwrk := null;
          v_filewrkex := null;

                    begin 
            delete from tapplwex  where numappl = v_numappl and numseq = v_numseq ;                       

            insert into tapplwex(numappl, numseq, codempid, desnoffi, deslstjob1, deslstpos, 
                                                        desoffi1, numteleo, namboss, desres, amtincom, dtestart, 
                                                        dteend, codtypwrk, desjob, desrisk, desprotc, filewrkex, 
                                                        remark,  dtecreate, codcreate, dteupd, coduser)  
                                        values (v_numappl, v_numseq, v_codempid, v_desnoffi, v_deslstjob1, v_deslstpos, 
                                                        v_desoffi1, v_numteleo, v_namboss, v_desres, v_amtincom, v_dtestart, 
                                                        v_dteend, v_codtypwrk, v_desjob, v_desrisk, v_desprotc, v_filewrkex, 
                                                        v_remark, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_tfamily (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_tfamily(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_tfamily (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codempid    tfamily.codempid%type;
  v_codempfa    tfamily.codempfa%type;
  v_codtitlf    tfamily.codtitlf%type;
  v_namfstfe    tfamily.namfstfe%type;
  v_namfstft    tfamily.namfstft%type;
  v_namfstf3    tfamily.namfstf3%type;
  v_namfstf4    tfamily.namfstf4%type;
  v_namfstf5    tfamily.namfstf5%type;
  v_namlstfe    tfamily.namlstfe%type;
  v_namlstft    tfamily.namlstft%type;
  v_namlstf3    tfamily.namlstf3%type;
  v_namlstf4    tfamily.namlstf4%type;
  v_namlstf5    tfamily.namlstf5%type;
  v_namfathe    tfamily.namfathe%type;
  v_namfatht    tfamily.namfatht%type;
  v_namfath3    tfamily.namfath3%type;
  v_namfath4    tfamily.namfath4%type;
  v_namfath5    tfamily.namfath5%type;
  v_numofidf    tfamily.numofidf%type;
  v_dtebdfa   tfamily.dtebdfa%type;
  v_codfnatn    tfamily.codfnatn%type;
  v_codfrelg    tfamily.codfrelg%type;
  v_codfoccu    tfamily.codfoccu%type;
  v_staliff   tfamily.staliff%type;
  v_dtedeathf   tfamily.dtedeathf%type;
  v_filenamf    tfamily.filenamf%type;
  v_numrefdocf  tfamily.numrefdocf%type;
  v_codempmo    tfamily.codempmo%type;
  v_codtitlm    tfamily.codtitlm%type;
  v_namfstme    tfamily.namfstme%type;
  v_namfstmt    tfamily.namfstmt%type;
  v_namfstm3    tfamily.namfstm3%type;
  v_namfstm4    tfamily.namfstm4%type;
  v_namfstm5    tfamily.namfstm5%type;
  v_namlstme    tfamily.namlstme%type;
  v_namlstmt    tfamily.namlstmt%type;
  v_namlstm3    tfamily.namlstm3%type;
  v_namlstm4    tfamily.namlstm4%type;
  v_namlstm5    tfamily.namlstm5%type;
  v_nammothe    tfamily.nammothe%type;
  v_nammotht    tfamily.nammotht%type;
  v_nammoth3    tfamily.nammoth3%type;
  v_nammoth4    tfamily.nammoth4%type;
  v_nammoth5    tfamily.nammoth5%type;
  v_numofidm    tfamily.numofidm%type;
  v_dtebdmo   tfamily.dtebdmo%type;
  v_codmnatn    tfamily.codmnatn%type;
  v_codmrelg    tfamily.codmrelg%type;
  v_codmoccu    tfamily.codmoccu%type;
  v_stalifm   tfamily.stalifm%type;
  v_dtedeathm   tfamily.dtedeathm%type;
  v_filenamm    tfamily.filenamm%type;
  v_numrefdocm  tfamily.numrefdocm%type;
  v_codtitlc    tfamily.codtitlc%type;
  v_namfstce    tfamily.namfstce%type;
  v_namfstct    tfamily.namfstct%type;
  v_namfstc3    tfamily.namfstc3%type;
  v_namfstc4    tfamily.namfstc4%type;
  v_namfstc5    tfamily.namfstc5%type;
  v_namlstce    tfamily.namlstce%type;
  v_namlstct    tfamily.namlstct%type;
  v_namlstc3    tfamily.namlstc3%type;
  v_namlstc4    tfamily.namlstc4%type;
  v_namlstc5    tfamily.namlstc5%type;
  v_namconte    tfamily.namconte%type;
  v_namcontt    tfamily.namcontt%type;
  v_namcont3    tfamily.namcont3%type;
  v_namcont4    tfamily.namcont4%type;
  v_namcont5    tfamily.namcont5%type;
  v_adrcont1    tfamily.adrcont1%type;
  v_codpost   tfamily.codpost%type;
  v_numtele   tfamily.numtele%type;
  v_numfax    tfamily.numfax%type;
  v_email     tfamily.email%type;
  v_desrelat    tfamily.desrelat%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
            if i in (1,2,9,14,15,22,27) then
                chk_len(i) := 10;
            elsif i in (3,10,11,12,16,23,24,25,28) then
                chk_len(i) := 4;
      elsif i in (4,5,6,7,17,18,19,20,29,30,31,32) then
                chk_len(i) := 30;
      elsif i in (8,21) then
                chk_len(i) := 13;
      elsif i in (13,26) then
                chk_len(i) := 1;
      elsif i in (33) then
                chk_len(i) := 100;
      elsif i in (34) then
                chk_len(i) := 5;  
            elsif i in (35,36) then
                chk_len(i) := 20;
      elsif i in (37) then
                chk_len(i) := 50; 
            elsif i in (38) then
                chk_len(i) := 15; 
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29)  := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30)  := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31)  := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32)  := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33)  := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34)  := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35)  := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36)  := hcm_util.get_string_t(param_json_row,'col-36');
        v_text(37)  := hcm_util.get_string_t(param_json_row,'col-37');
        v_text(38)  := hcm_util.get_string_t(param_json_row,'col-38');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column
                        if i in (1) then    
                            if v_text(i) is null or length(trim(v_text(i))) is null then
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;                    

                        --check length all columns   
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (9,14,22,27) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;                    

                        --check number format       
                        if i in (34) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop;   

          --assign value to var
          v_codempid    := v_text(1);
          v_codempfa    := v_text(2);
          v_codtitlf    := v_text(3);
          v_namfstfe    := v_text(4);
          v_namfstft    := v_text(5);
          v_namlstfe    := v_text(6);
          v_namlstft    := v_text(7);
          v_numofidf    := v_text(8);
          v_dtebdfa   := null;
          if v_text(9) is not null or length(trim(v_text(9))) is not null then
            v_dtebdfa := check_dteyre(v_text(9));
          end if;
          v_codfnatn    := v_text(10);
          v_codfrelg    := v_text(11);
          v_codfoccu    := v_text(12);
          v_staliff   := v_text(13);
          v_dtedeathf   := null;
          if v_text(14) is not null or length(trim(v_text(14))) is not null then
            v_dtedeathf := check_dteyre(v_text(14));
          end if;
          v_codempmo    := v_text(15);
          v_codtitlm    := v_text(16);
          v_namfstme    := v_text(17);
          v_namfstmt    := v_text(18);
          v_namlstme    := v_text(19);
          v_namlstmt    := v_text(20);
          v_numofidm    := v_text(21);
          v_dtebdmo   := null;
          if v_text(22) is not null or length(trim(v_text(22))) is not null then
            v_dtebdmo := check_dteyre(v_text(22));
          end if;
          v_codmnatn    := v_text(23);
          v_codmrelg    := v_text(24);
          v_codmoccu    := v_text(25);
          v_stalifm   := v_text(26);
          v_dtedeathm   := null;
          if v_text(27) is not null or length(trim(v_text(27))) is not null then
            v_dtedeathm := check_dteyre(v_text(27));
          end if;
          v_codtitlc    := v_text(28);
          v_namfstce    := v_text(29);
          v_namfstct    := v_text(30);
          v_namlstce    := v_text(31);
          v_namlstct    := v_text(32);
          v_adrcont1    := v_text(33);
          v_codpost   := v_text(34);
          if v_text(34) is not null or length(trim(v_text(34))) is not null then
            v_codpost := to_number(v_text(34),'99999');
          end if;
          v_numtele   := v_text(35);
          v_numfax    := v_text(36);
          v_email     := v_text(37);
          v_desrelat    := v_text(38);

                    --check incorrect data  
          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          --check codempfa    
                    if v_codempfa is not null or length(trim(v_codempfa)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1, codtitle, namfirste, namfirstt, namlaste, namlastt, numoffid, dteempdb 
                                into v_chk_exists, v_codtitlf, v_namfstfe, v_namfstft, v_namlstfe, v_namlstft, v_numofidf, v_dtebdfa
                            from temploy1  t1, temploy2 t2
                            where t1.codempid  = v_codempfa and  t1.codempid =  t2.codempid ;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(2);
                            v_err_table := 'TEMPLOY1';
                            exit cal_loop;
                        end;
                    end if;

          --check codempmo  
                    if v_codempmo is not null or length(trim(v_codempmo)) is not null then
                        v_chk_exists := 0;
                        begin 
                             select 1, codtitle, namfirste, namfirstt, namlaste, namlastt, numoffid, dteempdb 
                                into v_chk_exists, v_codtitlm, v_namfstme, v_namfstmt, v_namlstme, v_namlstmt, v_numofidm, v_dtebdmo
                            from temploy1  t1, temploy2 t2
                            where t1.codempid  = v_codempmo and  t1.codempid =  t2.codempid ;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(15);
                            v_err_table := 'TEMPLOY1';
                            exit cal_loop;
                        end;
          end if;

          --check codtitlf  
                    if v_codtitlf is not null or length(trim(v_codtitlf)) is not null then
                        if v_codtitlf not in ('003','004','005') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(3);
                            exit cal_loop;
                        end if;
          end if;

          --check codtitlm  
                    if v_codtitlm is not null or length(trim(v_codtitlm)) is not null then
                        if v_codtitlm not in ('003','004','005') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(16);
                            exit cal_loop;
                        end if;
                    end if;

          --check codtitlc  
                    if v_codtitlc is not null or length(trim(v_codtitlc)) is not null then
                        if v_codtitlc not in ('003','004','005') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(28);
                            exit cal_loop;
                        end if;
          end if;

          --check codfnatn        
                    if v_codfnatn is not null or length(trim(v_codfnatn)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodnatn    
              where codcodec  = v_codfnatn;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(10);
              v_err_table := 'TCODNATN';
              exit cal_loop;
            end;
          end if;

          --check codmnatn        
                    if v_codmnatn is not null or length(trim(v_codmnatn)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodnatn    
              where codcodec  = v_codmnatn;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(23);
              v_err_table := 'TCODNATN';
              exit cal_loop;
            end;
          end if;

          --check codfrelg        
                    if v_codfrelg is not null or length(trim(v_codfrelg)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodregn    
              where codcodec  = v_codfrelg;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(11);
              v_err_table := 'TCODREGN';
              exit cal_loop;
            end;
          end if;

          --check codmrelg        
                    if v_codmrelg is not null or length(trim(v_codmrelg)) is not null then
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodregn    
              where codcodec  = v_codmrelg;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(24);
              v_err_table := 'TCODREGN';
              exit cal_loop;
            end;
          end if;

          --check codfoccu 
          if v_codfoccu is not null or length(trim(v_codfoccu)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodoccu    
              where codcodec  = v_codfoccu;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(12);
              v_err_table := 'TCODOCCU';
              exit cal_loop;
            end;
          end if; 

          --check codmoccu 
          if v_codmoccu is not null or length(trim(v_codmoccu)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodoccu    
              where codcodec  = v_codmoccu;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(25);
              v_err_table := 'TCODOCCU';
              exit cal_loop;
            end;
          end if; 

          --check staliff 
                    if v_staliff is not null or length(trim(v_staliff)) is not null then  
                        if v_staliff not in ('Y','N') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(13);
                            exit cal_loop;
                        end if;
                    end if;

          --check stalifm 
                    if v_stalifm is not null or length(trim(v_stalifm)) is not null then  
                        if v_stalifm not in ('Y','N') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(26);
                            exit cal_loop;
                        end if;
                    end if;

          --check dtedeathf
          if v_staliff = 'N' then 
            if v_dtedeathf is null or length(trim(v_dtedeathf)) is null then
              v_error   := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(14);
              exit cal_loop;
            end if;
          end if;

          --check dtedeathm
          if v_stalifm = 'N' then 
            if v_dtedeathm is null or length(trim(v_dtedeathm)) is null then
              v_error   := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(27);
              exit cal_loop;
            end if;
          end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_namfstf3  := v_namfstfe;
          v_namfstf4  := v_namfstfe;
          v_namfstf5  := v_namfstfe;
          v_namlstf3  := v_namlstfe;
          v_namlstf4  := v_namlstfe;
          v_namlstf5  := v_namlstfe;
          v_namfathe  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlf,'101'))) || ltrim(rtrim(v_namfstfe))||' '||ltrim(rtrim(v_namlstfe)),1,60);
          v_namfatht  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlf,'102'))) || ltrim(rtrim(v_namfstft))||' '||ltrim(rtrim(v_namlstft)),1,60);
          v_namfath3  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlf,'103'))) || ltrim(rtrim(v_namfstf3))||' '||ltrim(rtrim(v_namlstf3)),1,60);
          v_namfath4  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlf,'104'))) || ltrim(rtrim(v_namfstf4))||' '||ltrim(rtrim(v_namlstf4)),1,60);
          v_namfath5  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlf,'105'))) || ltrim(rtrim(v_namfstf5))||' '||ltrim(rtrim(v_namlstf5)),1,60);
          v_filenamf  := null;
          v_numrefdocf  := null;

          v_namfstm3  := v_namfstme;
          v_namfstm4  := v_namfstme;
          v_namfstm5  := v_namfstme;
          v_namlstm3  := v_namlstme;
          v_namlstm4  := v_namlstme;
          v_namlstm5  := v_namlstme;
          v_nammothe  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlm,'101'))) || ltrim(rtrim(v_namfstme))||' '||ltrim(rtrim(v_namlstme)),1,60);
          v_nammotht  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlm,'102'))) || ltrim(rtrim(v_namfstmt))||' '||ltrim(rtrim(v_namlstmt)),1,60);
          v_nammoth3  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlm,'103'))) || ltrim(rtrim(v_namfstm3))||' '||ltrim(rtrim(v_namlstm3)),1,60);
          v_nammoth4  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlm,'104'))) || ltrim(rtrim(v_namfstm4))||' '||ltrim(rtrim(v_namlstm4)),1,60);
          v_nammoth5  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlm,'105'))) || ltrim(rtrim(v_namfstm5))||' '||ltrim(rtrim(v_namlstm5)),1,60);
          v_filenamm  := null;
          v_numrefdocm  := null;

          v_namfstc3  := v_namfstce;
          v_namfstc4  := v_namfstce;
          v_namfstc5  := v_namfstce;
          v_namlstc3  := v_namlstce;
          v_namlstc4  := v_namlstce;
          v_namlstc5  := v_namlstce;
          v_namconte  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlc,'101'))) || ltrim(rtrim(v_namfstce))||' '||ltrim(rtrim(v_namlstce)),1,60);
          v_namcontt  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlc,'102'))) || ltrim(rtrim(v_namfstct))||' '||ltrim(rtrim(v_namlstct)),1,60);
          v_namcont3  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlc,'103'))) || ltrim(rtrim(v_namfstc3))||' '||ltrim(rtrim(v_namlstc3)),1,60);
          v_namcont4  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlc,'104'))) || ltrim(rtrim(v_namfstc4))||' '||ltrim(rtrim(v_namlstc4)),1,60);
          v_namcont5  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitlc,'105'))) || ltrim(rtrim(v_namfstc5))||' '||ltrim(rtrim(v_namlstc5)),1,60);


                    begin 
            delete from tfamily where codempid  = v_codempid;                        

            insert into tfamily(codempid, codempfa, codtitlf, 
                                                    namfstfe, namfstft, namfstf3, namfstf4, namfstf5, 
                                                    namlstfe, namlstft, namlstf3, namlstf4, namlstf5, 
                                                    namfathe, namfatht, namfath3, namfath4, namfath5, 
                                                    numofidf, dtebdfa, codfnatn, codfrelg, codfoccu, 
                                                    staliff, dtedeathf, filenamf, numrefdocf, codempmo, codtitlm, 
                                                    namfstme, namfstmt, namfstm3, namfstm4, namfstm5, 
                                                    namlstme, namlstmt, namlstm3, namlstm4, namlstm5, 
                                                    nammothe, nammotht, nammoth3, nammoth4, nammoth5, 
                                                    numofidm, dtebdmo, codmnatn, codmrelg, codmoccu, 
                                                    stalifm, dtedeathm, filenamm, numrefdocm, codtitlc, 
                                                    namfstce, namfstct, namfstc3, namfstc4, namfstc5, 
                                                    namlstce, namlstct, namlstc3, namlstc4, namlstc5, 
                                                    namconte, namcontt, namcont3, namcont4, namcont5, 
                                                    adrcont1, codpost, numtele, numfax, email, desrelat, 
                                                    dtecreate, codcreate, dteupd, coduser)  
                                    values  (v_codempid, v_codempfa, v_codtitlf, 
                                                    v_namfstfe, v_namfstft, v_namfstf3, v_namfstf4, v_namfstf5, 
                                                    v_namlstfe, v_namlstft, v_namlstf3, v_namlstf4, v_namlstf5, 
                                                    v_namfathe, v_namfatht, v_namfath3, v_namfath4, v_namfath5, 
                                                    v_numofidf, v_dtebdfa, v_codfnatn, v_codfrelg, v_codfoccu, 
                                                    v_staliff, v_dtedeathf, v_filenamf, v_numrefdocf, v_codempmo, v_codtitlm, 
                                                    v_namfstme, v_namfstmt, v_namfstm3, v_namfstm4, v_namfstm5, 
                                                    v_namlstme, v_namlstmt, v_namlstm3, v_namlstm4, v_namlstm5, 
                                                    v_nammothe, v_nammotht, v_nammoth3, v_nammoth4, v_nammoth5, 
                                                    v_numofidm, v_dtebdmo, v_codmnatn, v_codmrelg, v_codmoccu, 
                                                    v_stalifm, v_dtedeathm, v_filenamm, v_numrefdocm, v_codtitlc, 
                                                    v_namfstce, v_namfstct, v_namfstc3, v_namfstc4, v_namfstc5, 
                                                    v_namlstce, v_namlstct, v_namlstc3, v_namlstc4, v_namlstc5, 
                                                    v_namconte, v_namcontt, v_namcont3, v_namcont4, v_namcont5, 
                                                    v_adrcont1, v_codpost, v_numtele, v_numfax, v_email, v_desrelat, 
                                                    trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_tspouse(json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_tspouse(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

    procedure validate_excel_pm_tspouse (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tspouse       tspouse%rowtype;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i in (1,2,11,14,18) then
      chk_len(i) := 10;      
      elsif i in (3,10,19,20) then
      chk_len(i) := 4;
      elsif i in (4,5,6,7) then
      chk_len(i) := 30;
      elsif i in (8,9,16,17) then
      chk_len(i) := 13;
      elsif i in (12,13) then
      chk_len(i) := 1;
      elsif i in (15,22) then
      chk_len(i) := 100;  
      elsif i in (21) then
      chk_len(i) := 20;  
      else
      chk_len(i) := 0;   
      end if;
    end loop;               

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)   := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)   := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)   := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)   := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)   := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)   := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)   := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)   := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)   := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)   := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)   := hcm_util.get_string_t(param_json_row,'col-22');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,3,5,7) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then                                   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;                               
                            end if;
                        end if;                    

                        --check length all columns  
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;                    

                        --check date format                    
                        if i in (11,14,18) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop; 

          --assign value to var
          v_tspouse.codempid      := v_text(1);
          v_tspouse.codempidsp  := v_text(2);
          v_tspouse.codtitle        := v_text(3);
          v_tspouse.namfirste   := v_text(4);
          v_tspouse.namfirstt     := v_text(5);
          v_tspouse.namlaste    := v_text(6);
          v_tspouse.namlastt        := v_text(7);
          v_tspouse.numoffid      := v_text(8);
          v_tspouse.numtaxid      := v_text(9);
          v_tspouse.codspocc      := v_text(10);
          v_tspouse.dtespbd     := null;     
          if v_text(11) is not null or length(trim(v_text(11))) is not null then
            v_tspouse.dtespbd   := check_dteyre(v_text(11));
          end if;
          v_tspouse.stalife         := v_text(12);
          v_tspouse.staincom    := v_text(13);
          v_tspouse.dtedthsp      := null;
          if v_text(14) is not null or length(trim(v_text(14))) is not null then
            v_tspouse.dtedthsp  := check_dteyre(v_text(14));
          end if;
          v_tspouse.desnoffi        := v_text(15);
          v_tspouse.numfasp     := v_text(16);
          v_tspouse.nummosp   := v_text(17);
          v_tspouse.dtemarry      := null;
          if v_text(18) is not null or length(trim(v_text(18))) is not null then
            v_tspouse.dtemarry  := check_dteyre(v_text(18));
          end if;
          v_tspouse.codsppro      := v_text(19);
          v_tspouse.codspcty    := v_text(20);
          v_tspouse.desplreg        := v_text(21);
          v_tspouse.desnote       := v_text(22);

          --check incorrect data   
          --check codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_tspouse.codempid;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;  

          --check codempidsp
          if v_tspouse.codempidsp is not null or length(trim(v_tspouse.codempidsp)) is not null then  
            v_chk_exists := 0;
            begin 
               select 1, codtitle, namfirste, namfirstt, namlaste, namlastt, numoffid, dteempdb 
                                into v_chk_exists, v_tspouse.codtitle, v_tspouse.namfirste, v_tspouse.namfirstt, v_tspouse.namlaste, v_tspouse.namlastt, v_tspouse.numoffid, v_tspouse.dtespbd
                            from temploy1  t1, temploy2 t2
                            where t1.codempid  = v_tspouse.codempidsp and  t1.codempid =  t2.codempid ;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(2);
              v_err_table := 'TEMPLOY1';
              exit cal_loop;
            end;
          end if;

          --check codtitle 
                    if v_tspouse.codtitle is not null or length(trim(v_tspouse.codtitle)) is not null then  
                        if v_tspouse.codtitle not in ('003','004','005') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(3);
                            exit cal_loop;
                        end if;
                    end if;

          --check codspocc  
          if v_tspouse.codspocc is not null or length(trim(v_tspouse.codspocc)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodoccu    
              where codcodec  = v_tspouse.codspocc;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(10);
              v_err_table := 'TCODOCCU';
              exit cal_loop;
            end;
          end if; 

          --check stalife   
          if v_tspouse.stalife is not null or length(trim(v_tspouse.stalife)) is not null then  
            if v_tspouse.stalife not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(13);
              exit cal_loop;
            end if;
          end if;

          --check staincom    
          if v_tspouse.staincom is not null or length(trim(v_tspouse.staincom)) is not null then  
            if v_tspouse.staincom not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(12);
              exit cal_loop;
            end if;
          end if;

          --check dtedthsp    
          if v_tspouse.stalife  = 'N' then  
            if v_tspouse.dtedthsp is null or length(trim(v_tspouse.dtedthsp)) is null then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(14);
              exit cal_loop;
            end if;
          end if;

          --check codsppro  
                    if v_tspouse.codsppro is not null or length(trim(v_tspouse.codsppro)) is not null  then 
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodprov     
                            where codcodec  = v_tspouse.codsppro;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(19);
                            v_err_table := 'TCODPROV';
                            exit cal_loop;
                        end;
                    end if;                 

          --check codspcty    
                    if v_tspouse.codspcty is not null or length(trim(v_tspouse.codspcty)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodcnty     
                            where codcodec  = v_tspouse.codspcty;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(20);
                            v_err_table := 'TCODCNTY';
                            exit cal_loop;
                        end;
          end if;     

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_tspouse.namspe      := get_tlistval_name('CODTITLE',v_tspouse.codtitle,'101')||v_tspouse.namfirste||' '||v_tspouse.namlaste;
          v_tspouse.namspt      := get_tlistval_name('CODTITLE',v_tspouse.codtitle,'102')||v_tspouse.namfirstt||' '||v_tspouse.namlastt;                           

                    begin 
            delete from tspouse where codempid = v_tspouse.codempid  ;

            insert into tspouse(codempid,codempidsp,namimgsp,codtitle,
                         namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                         namlaste,namlastt,namlast3,namlast4,namlast5,
                         namspe,namspt,namsp3,namsp4,namsp5,
                         numoffid,numtaxid,codspocc,dtespbd,stalife,
                         staincom,dtedthsp,desnoffi,numfasp,nummosp,
                         dtemarry,codsppro,codspcty,desplreg,desnote,filename,numrefdoc,                         
                         dtecreate,codcreate,dteupd,coduser)
                    values(v_tspouse.codempid,v_tspouse.codempidsp,null,v_tspouse.codtitle,
                         v_tspouse.namfirste,v_tspouse.namfirstt,v_tspouse.namfirste,v_tspouse.namfirste,v_tspouse.namfirste,
                         v_tspouse.namlaste,v_tspouse.namlastt,v_tspouse.namlaste,v_tspouse.namlaste,v_tspouse.namlaste,
                         v_tspouse.namspe,v_tspouse.namspt,v_tspouse.namspe,v_tspouse.namspe,v_tspouse.namspe,
                         v_tspouse.numoffid,v_tspouse.numtaxid,v_tspouse.codspocc,v_tspouse.dtespbd,v_tspouse.stalife,
                         v_tspouse.staincom,v_tspouse.dtedthsp,v_tspouse.desnoffi,v_tspouse.numfasp,v_tspouse.nummosp,
                         v_tspouse.dtemarry,v_tspouse.codsppro,v_tspouse.codspcty,v_tspouse.desplreg,v_tspouse.desnote,null,null,
                         trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

    procedure get_process_pm_tchildrn(json_str_input  in clob,
                                      json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_tchildrn(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

    procedure validate_excel_pm_tchildrn (json_str_input in clob,
                                          p_rec_tran     out number,
                                          p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tchildrn       tchildrn%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i in (1,9,14) then
      chk_len(i) := 10;      
      elsif i in (2) then
      chk_len(i) := 2;
      elsif i in (3,11) then
      chk_len(i) := 4;
      elsif i in (4,5,6,7) then
      chk_len(i) := 30;
      elsif i in (8) then
      chk_len(i) := 13;
      elsif i in (10,12,13,15,16,17,18) then
      chk_len(i) := 1;  
      else
      chk_len(i) := 0;   
      end if;
    end loop;               

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)   := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)   := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)   := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)   := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)   := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)   := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)   := hcm_util.get_string_t(param_json_row,'col-18');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --     
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,5,7,9,10,12,13,15,16,17,18) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;                    

                        --check length all columns       
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;                   

                        --check date format
                        if i in (9,14) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;

                        --check number format   
                        if i in (2) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop; 


          --assign value to var
          v_tchildrn.codempid    := v_text(1);
          v_tchildrn.numseq     := to_number(v_text(2),'99');
          v_tchildrn.codtitle   := v_text(3);
          v_tchildrn.namfirste  := v_text(4);
          v_tchildrn.namfirstt   := v_text(5);
          v_tchildrn.namlaste  := v_text(6);
          v_tchildrn.namlastt  := v_text(7);          
          v_tchildrn.numoffid    := v_text(8);
          v_tchildrn.dtechbd    :=      null;   
          if v_text(9) is not null or length(trim(v_text(9))) is not null then
            v_tchildrn.dtechbd  := check_dteyre(v_text(9));
          end if;
          v_tchildrn.codsex     := v_text(10);
          v_tchildrn.codedlv     := v_text(11);
          v_tchildrn.stachld   := v_text(12);
          v_tchildrn.stalife   := v_text(13);
          v_tchildrn.dtedthch    := null;
          if v_text(14) is not null or length(trim(v_text(14))) is not null then
            v_tchildrn.dtedthch   := check_dteyre(v_text(14));
          end if;
          v_tchildrn.flginc      := v_text(15);
          v_tchildrn.flgedlv   := v_text(16);
          v_tchildrn.flgdeduct  := v_text(17);
          v_tchildrn.stabf      := v_text(18);

          --check incorrect data   
          --check codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_tchildrn.codempid;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;          

          --check codtitle 
                    if(v_tchildrn.codtitle not in ('001','002','003','004','005')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(3);
                        exit cal_loop;
                    end if;

          --check codsex  
          if v_tchildrn.codsex is not null or length(trim(v_tchildrn.codsex)) is not null then  
            if v_tchildrn.codsex not in ('M','F') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(10);
              exit cal_loop;
            end if;
          end if;

          --check codedlv  
          if v_tchildrn.codedlv is not null or length(trim(v_tchildrn.codedlv)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodeduc    
              where codcodec  = v_tchildrn.codedlv;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(11);
              v_err_table := 'TCODEDUC';
              exit cal_loop;
            end;
          end if; 

          --check stachld   
          if v_tchildrn.stachld is not null or length(trim(v_tchildrn.stachld)) is not null then  
            if v_tchildrn.stachld not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(12);
              exit cal_loop;
            end if;
          end if;

          --check stalife   
          if v_tchildrn.stalife is not null or length(trim(v_tchildrn.stalife)) is not null then  
            if v_tchildrn.stalife not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(13);
              exit cal_loop;
            end if;
          end if;

          --check flginc    
          if v_tchildrn.flginc is not null or length(trim(v_tchildrn.flginc)) is not null then  
            if v_tchildrn.flginc not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(15);
              exit cal_loop;
            end if;
          end if;

          --check flgedlv   
          if v_tchildrn.flgedlv not in ('Y','N') then
            v_error   := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(16);
            exit cal_loop;
          end if;

          --check flgdeduct   
          if v_tchildrn.flgdeduct not in ('Y','N') then
            v_error   := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(17);
            exit cal_loop;
          end if;

          --check stabf     
          if v_tchildrn.stabf is not null or length(trim(v_tchildrn.stabf)) is not null then  
            if v_tchildrn.stabf not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(18);
              exit cal_loop;
            end if;
          end if;

          --check dtedthch    
          if v_tchildrn.stalife  = 'N' then 
            if v_tchildrn.dtedthch is null or length(trim(v_tchildrn.dtedthch)) is null then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(14);
              exit cal_loop;
            end if;
          end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    v_tchildrn.namche   := get_tlistval_name('CODTITLE',v_tchildrn.codtitle,'101')||v_tchildrn.namfirste||' '||v_tchildrn.namlaste;
          v_tchildrn.namcht   := get_tlistval_name('CODTITLE',v_tchildrn.codtitle,'102')||v_tchildrn.namfirstt||' '||v_tchildrn.namlastt;    

                    begin 
            delete from tchildrn where codempid = v_tchildrn.codempid and numseq = v_tchildrn.numseq ;

            insert into tchildrn(codempid,numseq,codtitle,
                         namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                         namlaste,namlastt,namlast3,namlast4,namlast5,
                         namche,namcht,namch3,namch4,namch5,
                         numoffid,dtechbd,codsex,codedlv,stachld,
                         stalife,dtedthch,flginc,flgedlv,flgdeduct,
                         stabf,filename,numrefdoc,                         
                         dtecreate,codcreate,dteupd,coduser)
                    values(v_tchildrn.codempid,v_tchildrn.numseq,v_tchildrn.codtitle,
                         v_tchildrn.namfirste,v_tchildrn.namfirstt,v_tchildrn.namfirste,v_tchildrn.namfirste,v_tchildrn.namfirste,
                         v_tchildrn.namlaste,v_tchildrn.namlastt,v_tchildrn.namlaste,v_tchildrn.namlaste,v_tchildrn.namlaste,
                         v_tchildrn.namche,v_tchildrn.namcht,v_tchildrn.namche,v_tchildrn.namche,v_tchildrn.namche,
                         v_tchildrn.numoffid,v_tchildrn.dtechbd,v_tchildrn.codsex,v_tchildrn.codedlv,v_tchildrn.stachld,
                         v_tchildrn.stalife,v_tchildrn.dtedthch,v_tchildrn.flginc,v_tchildrn.flgedlv,v_tchildrn.flgdeduct,
                         v_tchildrn.stabf,null,null,
                         trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

    procedure get_process_pm_tapplref(json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_tapplref(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

    procedure validate_excel_pm_tapplref (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tapplref       tapplref%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i in (1,3,4) then
      chk_len(i) := 10;      
      elsif i in (2) then
      chk_len(i) := 2;
      elsif i in (5,16) then
      chk_len(i) := 4;
      elsif i in (6,7,8,9,15) then
      chk_len(i) := 30;
      elsif i in (10) then
      chk_len(i) := 1;
      elsif i in (11,12) then
      chk_len(i) := 100;
      elsif i in (13) then
      chk_len(i) := 40;
      elsif i in (14) then
      chk_len(i) := 20;
      elsif i in (17) then
      chk_len(i) := 500;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');        
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17'); 


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --      
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,5,7,9,10) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;                    

                        --check length all columns    
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check number format     
                        if i in (2) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop; 


          --assign value to var
          v_tapplref.numappl    := v_text(1);
          v_tapplref.numseq     := to_number(v_text(2),'99');
          v_tapplref.codempid   := v_text(3);
          v_tapplref.codempref  := v_text(4);
          v_tapplref.codtitle   := v_text(5);
          v_tapplref.namfirste  := v_text(6);
          v_tapplref.namfirstt  := v_text(7);
          v_tapplref.namlaste   := v_text(8);
          v_tapplref.namlastt   := v_text(9);                   
          v_tapplref.flgref     := v_text(10);
          v_tapplref.despos     := v_text(11);
          v_tapplref.adrcont1   := v_text(12);
          v_tapplref.desnoffi   := v_text(13);
          v_tapplref.numtele    := v_text(14);
          v_tapplref.email      := v_text(15);
          v_tapplref.codoccup   := v_text(16);
          v_tapplref.remark     := v_text(17);

          --check incorrect data   
          --check codempid
          if v_tapplref.codempid is not null or length(trim(v_tapplref.codempid)) is not null then    
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from temploy1   
              where codempid  = v_tapplref.codempid;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(3);
              v_err_table := 'TEMPLOY1';
              exit cal_loop;
            end;
          end if;

          --check numappl,codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_tapplref.codempid
            and   numappl   = v_tapplref.numappl;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;

          --check codempref
          if v_tapplref.codempref is not null or length(trim(v_tapplref.codempref)) is not null then    
            v_chk_exists := 0;
            begin 
                             select 1, codtitle, namfirste, namfirstt, namlaste, namlastt , get_tpostn_name(codpos,102), adrcontt , numtelec, substr(namcomt,1,40)   
                                into v_chk_exists, v_tapplref.codtitle, v_tapplref.namfirste, v_tapplref.namfirstt, v_tapplref.namlaste, v_tapplref.namlastt, v_tapplref.despos, v_tapplref.adrcont1, v_tapplref.numtele, v_tapplref.desnoffi 
                             from temploy1  t1, temploy2 t2, tcompny t3
                             where t1.codempid  = v_tapplref.codempref  and  t1.codempid =  t2.codempid and hcm_util.get_codcomp_level(t1.codcomp,1) = t3.codcompy;         
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(4);
              v_err_table := 'TEMPLOY1';
              exit cal_loop;
            end;
          end if; 

                    --check codtitle 
                    if v_tapplref.codtitle is not null or length(trim(v_tapplref.codtitle)) is not null then    
                        if v_tapplref.codtitle not in ('003','004','005') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(5);
                            exit cal_loop;
                        end if;
                    end if;

                    --check flgref  
          if v_tapplref.flgref not in ('F','E','P') then
            v_error   := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(10);
            exit cal_loop;
          end if;

                    --check codoccup 
          if v_tapplref.codoccup is not null or length(trim(v_tapplref.codoccup)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodoccu    
              where codcodec  = v_tapplref.codoccup;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(16);
              v_err_table := 'TCODOCCU';
              exit cal_loop;
            end;
          end if; 

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    v_tapplref.namrefe    := get_tlistval_name('CODTITLE',v_tapplref.codtitle,'101')||v_tapplref.namfirste||' '||v_tapplref.namlaste;
          v_tapplref.namreft     := get_tlistval_name('CODTITLE',v_tapplref.codtitle,'102')||v_tapplref.namfirstt||' '||v_tapplref.namlastt;     

                    begin 
            delete from tapplref where numappl = v_tapplref.numappl and numseq = v_tapplref.numseq ;

            insert into tapplref(numappl,numseq,codempid,namimgrf,codtitle,
                         namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                         namlaste,namlastt,namlast3,namlast4,namlast5,
                         namrefe,namreft,namref3,namref4,namref5,
                         flgref,despos,adrcont1,desnoffi,numtele,
                         email,codoccup,remark,filename,
                         dtecreate,codcreate,dteupd,coduser)
                    values(v_tapplref.numappl,v_tapplref.numseq,v_tapplref.codempid,null,v_tapplref.codtitle,
                        v_tapplref.namfirste,v_tapplref.namfirstt,v_tapplref.namfirste,v_tapplref.namfirste,v_tapplref.namfirste,
                        v_tapplref.namlaste,v_tapplref.namlastt,v_tapplref.namlaste,v_tapplref.namlaste,v_tapplref.namlaste,
                        v_tapplref.namrefe,v_tapplref.namreft,v_tapplref.namrefe,v_tapplref.namrefe,v_tapplref.namrefe,
                        v_tapplref.flgref,v_tapplref.despos,v_tapplref.adrcont1,v_tapplref.desnoffi,v_tapplref.numtele,
                        v_tapplref.email,v_tapplref.codoccup,v_tapplref.remark,null,
                        trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

    procedure get_process_pm_ttrainbf(json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_ttrainbf(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

    procedure validate_excel_pm_ttrainbf (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_ttrainbf       ttrainbf%rowtype;  

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i in (1,3,5,6) then
      chk_len(i) := 10;      
      elsif i in (2) then
      chk_len(i) := 2;
      elsif i in (4,7,8) then
      chk_len(i) := 100;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
                v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns   
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check number format     
                        if i in (2) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop; 

          --assign value to var
          v_ttrainbf.numappl   := v_text(1);
          v_ttrainbf.numseq    := to_number(v_text(2),'99');
          v_ttrainbf.codempid  := v_text(3);
          v_ttrainbf.destrain  := v_text(4);
          v_ttrainbf.dtetrain  := null;
          if v_text(5) is not null or length(trim(v_text(5))) is not null then
            v_ttrainbf.dtetrain := check_dteyre(v_text(5));
          end if;
          v_ttrainbf.dtetren   := null;
          if v_text(6) is not null or length(trim(v_text(6))) is not null then
            v_ttrainbf.dtetren  := check_dteyre(v_text(6));
          end if;
          v_ttrainbf.desplace  := v_text(7);
          v_ttrainbf.desinstu  := v_text(8);

          --check incorrect data  
          --check codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_ttrainbf.codempid;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(3);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;

          --check numappl,codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_ttrainbf.codempid
            and   numappl   = v_ttrainbf.numappl;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;



          --check v_ttrainbf.dtetren
          if((v_ttrainbf.dtetren is not null) or length(trim(v_ttrainbf.dtetren)) is not null) then
            if((v_ttrainbf.dtetrain is not null) or length(trim(v_ttrainbf.dtetrain)) is not null) then
              if v_ttrainbf.dtetren < v_ttrainbf.dtetrain then
                v_error   := true;
                v_err_code  := 'HR5017';
                v_err_field := v_field(6);
                exit cal_loop;
              end if; 
            end if;   
                    end if;           

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete from ttrainbf where numappl = v_ttrainbf.numappl and numseq = v_ttrainbf.numseq;

            insert into ttrainbf(numappl,numseq,codempid,
                       destrain,dtetrain,dtetren,
                       desplace,desinstu,filedoc,numrefdoc,
                       dtecreate,codcreate,dteupd,coduser)
                    values(v_ttrainbf.numappl,v_ttrainbf.numseq,v_ttrainbf.codempid,
                       v_ttrainbf.destrain,v_ttrainbf.dtetrain,v_ttrainbf.dtetren,
                       v_ttrainbf.desplace,v_ttrainbf.desinstu,null,null,
                       trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

    procedure get_process_pm_tguarntr (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_tguarntr(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

  procedure validate_excel_pm_tguarntr (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
   -- v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_codempid    tguarntr.codempid%type;
  v_codempgrt   tguarntr.codempgrt%type;
  v_numseq    tguarntr.numseq%type;
  v_dtegucon    tguarntr.dtegucon%type;
  v_codtitle    tguarntr.codtitle%type;
  v_namfirste   tguarntr.namfirste%type;
  v_namfirstt   tguarntr.namfirstt%type;
  v_namfirst3   tguarntr.namfirst3%type;
  v_namfirst4   tguarntr.namfirst4%type;
  v_namfirst5   tguarntr.namfirst5%type;
  v_namlaste    tguarntr.namlaste%type;
  v_namlastt    tguarntr.namlastt%type;
  v_namlast3    tguarntr.namlast3%type;
  v_namlast4    tguarntr.namlast4%type;
  v_namlast5    tguarntr.namlast5%type;
  v_namguare    tguarntr.namguare%type;
  v_namguart    tguarntr.namguart%type;
  v_namguar3    tguarntr.namguar3%type;
  v_namguar4    tguarntr.namguar4%type;
  v_namguar5    tguarntr.namguar5%type;
  v_dteguabd    tguarntr.dteguabd%type;
  v_dteguret    tguarntr.dteguret%type;
  v_codident    tguarntr.codident%type;
  v_numoffid    tguarntr.numoffid%type;
  v_dteidexp    tguarntr.dteidexp%type;
  v_adrcont   tguarntr.adrcont%type;
  v_codpost   tguarntr.codpost%type;
  v_numtele   tguarntr.numtele%type;
  v_codoccup    tguarntr.codoccup%type;
  v_despos    tguarntr.despos%type;
  v_amtmthin    tguarntr.amtmthin%type;
  v_adroffi   tguarntr.adroffi%type;
  v_codposto    tguarntr.codposto%type;
  v_numteleo    tguarntr.numteleo%type;
  v_stagusur    tguarntr.stagusur%type;
  v_desnote   tguarntr.desnote%type;
  v_mthlstsv    tguarntr.mthlstsv%type;
  v_yrlstsv   tguarntr.yrlstsv%type;
  v_dteguexp    tguarntr.dteguexp%type;
  v_desrelat    tguarntr.desrelat%type;
  v_email     tguarntr.email%type;
  v_numfax    tguarntr.numfax%type;
  v_filename    tguarntr.filename%type;
  v_amtguarntr  tguarntr.amtguarntr%type;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();   
        for i in 1..v_column loop
            if i in (1,2,4,10,11,14) then
                chk_len(i) := 10;
            elsif i in (3,16,22) then
                chk_len(i) := 5;
      elsif i in (5,18) then
                chk_len(i) := 4;
      elsif i in (6,7,8,9,26) then
                chk_len(i) := 30;
      elsif i in (12) then
                chk_len(i) := 1;
      elsif i in (13,17,23,27) then
                chk_len(i) := 20;
      elsif i in (19) then
                chk_len(i) := 35;
      elsif i in (20,28) then
                chk_len(i) := 9;    
            elsif i in (15,21) then
                chk_len(i) := 100;
      elsif i in (24) then
                chk_len(i) := 500;  
            elsif i in (25) then
                chk_len(i) := 40; 
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --         
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,3)  then                        
                            if v_text(i) is null or length(trim(v_text(i))) is null  then    
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns   
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (4,10,11,14) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;

                        --check number format   
                        if i in (3,16,20,22,28) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;   
                            end if;             
                        end if;
                    end loop; 

          --assign value to var
          v_codempid    := v_text(1);
          v_codempgrt   := v_text(2);
          v_numseq    :=  to_number(nvl(v_text(3),'0'),'99999');
          v_dtegucon    := null;
          if v_text(4) is not null or length(trim(v_text(4))) is not null then
            v_dtegucon  := check_dteyre(v_text(4));
          end if;
          v_codtitle    := v_text(5);
          v_namfirste   := v_text(6);
          v_namfirstt   := v_text(7);
          v_namlaste    := v_text(8);
          v_namlastt    := v_text(9);
          v_dteguabd    := null;
          if v_text(10) is not null or length(trim(v_text(10))) is not null then
            v_dteguabd  := check_dteyre(v_text(10));
          end if;
          v_dteguret    := null;
          if v_text(11) is not null or length(trim(v_text(11))) is not null then
            v_dteguret  := check_dteyre(v_text(11));
          end if;
          v_codident    := v_text(12);
          v_numoffid    := v_text(13);
          v_dteidexp    := null;
          if v_text(14) is not null or length(trim(v_text(14))) is not null then
            v_dteidexp  := check_dteyre(v_text(14));
          end if;
          v_adrcont   := v_text(15);
          v_codpost   :=  to_number(nvl(v_text(16),'0'),'99999');
          v_numtele   := v_text(17);
          v_codoccup    := v_text(18);
          v_despos    := v_text(19);
          v_amtmthin    := stdenc(to_number(nvl(v_text(20),'0'),'999999.99'),v_codempid,v_chken);
          v_adroffi   := v_text(21);
          v_codposto    :=  to_number(nvl(v_text(22),'0'),'99999');

          v_numteleo    := v_text(23);
          v_desnote   := v_text(24);
          v_desrelat    := v_text(25);
          v_email     := v_text(26);
          v_numfax    := v_text(27);
          v_amtguarntr  := stdenc(to_number(nvl(v_text(28),'0'),'999999.99'),v_codempid,v_chken);

          --check incorrect data  
          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

          --check codempgrt 
          if v_codempgrt is not null or length(trim(v_codempgrt)) is not null then          
            v_chk_exists := 0;
            begin 
                            select 1, codtitle, namfirste, namfirstt, namlaste, namlastt, dteempdb, dteretire, numoffid, dteoffid, adrcontt, codpostc, numtelec, get_tpostn_name(codpos,102), substr(namcomt||' '||adrcomt,1,100), zipcode, numtele   
                                into v_chk_exists, v_codtitle, v_namfirste, v_namfirstt, v_namlaste, v_namlastt, v_dteguabd, v_dteguret, v_numoffid, v_dteidexp, v_adrcont, v_codpost, v_numtele, v_despos, v_adroffi, v_codposto, v_numteleo
                            from temploy1  t1, temploy2 t2, tcompny t3
                            where t1.codempid  = v_codempgrt  and  t1.codempid =  t2.codempid and hcm_util.get_codcomp_level(t1.codcomp,1) = t3.codcompy;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(2);
              v_err_table := 'TEMPLOY1';
              exit cal_loop;
            end;
          end if; 

          --check codtitle  
                    if v_codtitle is not null or length(trim(v_codtitle)) is not null then  
                        if v_codtitle not in ('003','004','005') then
                            v_error   := true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(5);
                            exit cal_loop;
                        end if;
                    end if;

          --check codident 
          if v_codident is not null or length(trim(v_codident)) is not null then          
            if v_codident not in ('1','2','3') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(12);
              exit cal_loop;
            end if;
          end if;

          --check codoccup 
          if v_codoccup is not null or length(trim(v_codoccup)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodoccu    
              where codcodec  = v_codoccup;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(18);
              v_err_table := 'TCODOCCU';
              exit cal_loop;
            end;
          end if;         

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_namfirst3 := v_namfirste;
          v_namfirst4 := v_namfirste;
          v_namfirst5 := v_namfirste;
          v_namlast3  := v_namlaste;
          v_namlast4  := v_namlaste;
          v_namlast5  := v_namlaste;
          v_namguare  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'101'))) || ltrim(rtrim(v_namfirste))||' '||ltrim(rtrim(v_namlaste)),1,60);
          v_namguart  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'102'))) || ltrim(rtrim(v_namfirstt))||' '||ltrim(rtrim(v_namlastt)),1,60);
          v_namguar3  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'103'))) || ltrim(rtrim(v_namfirst3))||' '||ltrim(rtrim(v_namlast3)),1,60);
          v_namguar4  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'104'))) || ltrim(rtrim(v_namfirst4))||' '||ltrim(rtrim(v_namlast4)),1,60);
          v_namguar5  := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'105'))) || ltrim(rtrim(v_namfirst5))||' '||ltrim(rtrim(v_namlast5)),1,60);
          v_stagusur  := null;
          v_mthlstsv  := null;
          v_yrlstsv := null;
          v_dteguexp  := null;
          v_filename  := null;


                    begin 
            delete from tguarntr where codempid  = v_codempid and numseq = v_numseq  ;                     

            insert into tguarntr(codempid, codempgrt, numseq, dtegucon, codtitle, 
                      namfirste, namfirstt, namfirst3, namfirst4, namfirst5, 
                      namlaste, namlastt, namlast3, namlast4, namlast5, 
                      namguare, namguart, namguar3, namguar4, namguar5, 
                      dteguabd, dteguret, codident, numoffid, dteidexp, 
                      adrcont, codpost, numtele, codoccup, despos, 
                      amtmthin, adroffi, codposto, numteleo, stagusur, 
                      desnote, mthlstsv, yrlstsv, dteguexp, desrelat, 
                      email, numfax, filename, amtguarntr, 
                      dtecreate, codcreate, dteupd, coduser)  
                                    values (v_codempid, v_codempgrt, v_numseq, v_dtegucon, v_codtitle, 
                      v_namfirste, v_namfirstt, v_namfirst3, v_namfirst4, v_namfirst5, 
                      v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5, 
                      v_namguare, v_namguart, v_namguar3, v_namguar4, v_namguar5, 
                      v_dteguabd, v_dteguret, v_codident, v_numoffid, v_dteidexp, 
                      v_adrcont, v_codpost, v_numtele, v_codoccup, v_despos, 
                      v_amtmthin, v_adroffi, v_codposto, v_numteleo, v_stagusur, 
                      v_desnote, v_mthlstsv, v_yrlstsv, v_dteguexp, v_desrelat, 
                      v_email, v_numfax, v_filename, v_amtguarntr,  
                      trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_tcolltrl(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_pm_tcolltrl(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_pm_tcolltrl (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tcolltrl       tcolltrl%rowtype;  

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i in (1,2,3,5,7,8,9,10,15,16,17) then
      chk_len(i) := 10;      
      elsif i in (4) then
      chk_len(i) := 4;
      elsif i in (6) then
      chk_len(i) := 500;
      elsif i in (14,15,15,20,21) then
      chk_len(i) := 150;
      elsif i in (11,12,19) then
      chk_len(i) := 1;
      elsif i in (13,14) then
      chk_len(i) := 3;
      elsif i in (20) then
      chk_len(i) := 9;
      elsif i in (18) then
      chk_len(i) := 8;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --     
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,5,6,11)  then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns   
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (7,8,9,10,16,17) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop; 

          --check number format           
                    for i in 1..v_column loop
                        if i in (5,13,14,15,18) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop; 


          --assign value to var
          v_tcolltrl.codempid   := v_text(1);
          v_tcolltrl.numcolla   := v_text(2);
          v_tcolltrl.numdocum   := v_text(3);
          v_tcolltrl.typcolla   := v_text(4);
          v_tcolltrl.amtcolla   := stdenc(to_number(nvl(v_text(5),'0'),'9999999.99'),v_tcolltrl.codempid,v_chken);
          v_tcolltrl.descoll    := v_text(6);
          v_tcolltrl.dtecolla   := null;
          if v_text(7) is not null or length(trim(v_text(7))) is not null then
            v_tcolltrl.dtecolla := check_dteyre(v_text(7));
          end if; 
          v_tcolltrl.dtertdoc   := null;
          if v_text(8) is not null or length(trim(v_text(8))) is not null then
            v_tcolltrl.dtertdoc := check_dteyre(v_text(8));
          end if;
          v_tcolltrl.dteeffec   := null;
          if v_text(9) is not null or length(trim(v_text(9))) is not null then
            v_tcolltrl.dteeffec := check_dteyre(v_text(9));
          end if;
          v_tcolltrl.dtechg     := null;
          if v_text(10) is not null or length(trim(v_text(10))) is not null then
            v_tcolltrl.dtechg := check_dteyre(v_text(10));
          end if;
          v_tcolltrl.status     := v_text(11);
          v_tcolltrl.flgded     := v_text(12);
          v_tcolltrl.qtyperiod  := to_number(nvl(v_text(13),'0'),'999');
          v_tcolltrl.qtytranpy  := to_number(nvl(v_text(14),'0'),'999');
          v_tcolltrl.amtdedcol  := stdenc(to_number(nvl(v_text(15),'0'),'9999999.99'),v_tcolltrl.codempid,v_chken);
          v_tcolltrl.dtestrt    := null;
          if v_text(16) is not null or length(trim(v_text(16))) is not null then
            v_tcolltrl.dtestrt  := check_dteyre(v_text(16));
          end if;
          v_tcolltrl.dteend     := null;
          if v_text(17) is not null or length(trim(v_text(17))) is not null then
            v_tcolltrl.dteend := check_dteyre(v_text(17));
          end if;
          v_tcolltrl.amtded     := stdenc(to_number(nvl(v_text(18),'0'),'99999.99'),v_tcolltrl.codempid,v_chken);
          v_tcolltrl.staded     := v_text(19);
          v_tcolltrl.dtelstpay  := v_text(20);

          --check incorrect data   
          --check codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_tcolltrl.codempid;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;

          --check typcolla 
          if v_tcolltrl.typcolla is not null or length(trim(v_tcolltrl.typcolla)) is not null then    
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodcola   
              where codcodec  = v_tcolltrl.typcolla;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(4);
              v_err_table := 'TCODCOLA';
              exit cal_loop;
            end;
          end if; 

          --check status    
          if v_tcolltrl.status is not null or length(trim(v_tcolltrl.status)) is not null then          
            if v_tcolltrl.status not in ('A','C') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(11);
              exit cal_loop;
            end if;
          end if;

          --check flgded    
          if v_tcolltrl.flgded is not null or length(trim(v_tcolltrl.flgded)) is not null then          
            if v_tcolltrl.flgded not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(12);
              exit cal_loop;
            end if;
          end if;

          --check staded      
          if v_tcolltrl.staded is not null or length(trim(v_tcolltrl.staded)) is not null then          
            if v_tcolltrl.staded not in ('Y','N','C') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(19);
              exit cal_loop;
            end if;
          end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete from tcolltrl where codempid = v_tcolltrl.codempid;

            insert into tcolltrl(codempid,numcolla,
                                                 numdocum,typcolla,amtcolla,descoll,
                                                 dtecolla,dtertdoc,dteeffec,filename,numrefdoc,
                                                 dtechg,status,flgded,qtyperiod,qtytranpy,
                                                 amtdedcol,dtestrt,dteend,amtded,
                                                 staded,dtelstpay,
                                                 dtecreate,codcreate,dteupd,coduser)
                                      values(v_tcolltrl.codempid,v_tcolltrl.numcolla,
                                                 v_tcolltrl.numdocum,v_tcolltrl.typcolla,v_tcolltrl.amtcolla,v_tcolltrl.descoll,
                                                 v_tcolltrl.dtecolla,v_tcolltrl.dtertdoc,v_tcolltrl.dteeffec,null,null,
                                                 v_tcolltrl.dtechg,v_tcolltrl.status,v_tcolltrl.flgded,v_tcolltrl.qtyperiod,v_tcolltrl.qtytranpy,
                                                 v_tcolltrl.amtdedcol,v_tcolltrl.dtestrt,v_tcolltrl.dteend,v_tcolltrl.amtded,
                                                 v_tcolltrl.staded,v_tcolltrl.dtelstpay,
                                                 trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);   
          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  procedure get_process_pm_trelatives(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_pm_trelatives(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_pm_trelatives (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_trelatives     trelatives%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();
        for i in 1..v_column loop
      if i in (1,3) then
      chk_len(i) := 10;      
      elsif i in (2) then
      chk_len(i) := 2;
      elsif i in (4,5) then
      chk_len(i) := 100;
      elsif i in (6) then
      chk_len(i) := 20;
      elsif i in (7) then
      chk_len(i) := 300;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

              v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,5) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check number format     
                        if i in (2) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop; 


          --assign value to var
          v_trelatives.codempid := v_text(1);
          v_trelatives.numseq   := to_number(v_text(2),'99');
          v_trelatives.codemprl := v_text(3);
          v_trelatives.namrele  := v_text(4);
          v_trelatives.namrelt  := v_text(5);
          v_trelatives.numtelec := v_text(6);
          v_trelatives.adrcomt  := v_text(7);

                    --check incorrect data   
          --check codempid
          v_chk_exists := 0;
          begin 
            select 1 into v_chk_exists from temploy1   
            where codempid  = v_trelatives.codempid;
          exception when no_data_found then  
            v_error   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;

          --check codemprl
          if v_trelatives.codemprl is not null or length(trim(v_trelatives.codemprl)) is not null then    
            v_chk_exists := 0;
            begin 
                            select  1, get_temploy_name (t1.codempid,101), get_temploy_name (t1.codempid,102), numtelec, substr(adrcomt,1,300)
                               into v_chk_exists, v_trelatives.namrele, v_trelatives.namrelt, v_trelatives.numtelec, v_trelatives.adrcomt
                            from temploy1  t1, temploy2 t2, tcompny t3
                            where t1.codempid  = v_trelatives.codemprl  and  t1.codempid =  t2.codempid and hcm_util.get_codcomp_level(t1.codcomp,1) = t3.codcompy;

            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(3);
              v_err_table := 'TEMPLOY1';
              exit cal_loop;
            end;
          end if;                        

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete from trelatives where codempid = v_trelatives.codempid and numseq = v_trelatives.numseq;

            insert into   trelatives(codempid,numseq,codemprl,
                         namrele,namrelt,namrel3,namrel4,namrel5,
                         numtelec,adrcomt,
                         dtecreate,codcreate,dteupd,coduser)
                      values(v_trelatives.codempid,v_trelatives.numseq,v_trelatives.codemprl,
                         v_trelatives.namrele,v_trelatives.namrelt,v_trelatives.namrele,v_trelatives.namrele,v_trelatives.namrele,
                         v_trelatives.numtelec,v_trelatives.adrcomt,
                         trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  procedure get_process_pm_thismove (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_thismove(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_thismove (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    --v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;       
  v_codempid    thismove.codempid%type;
  v_dteeffec    thismove.dteeffec%type;
  v_numseq    thismove.numseq%type;
  v_codtrn    thismove.codtrn%type;
  v_numannou    thismove.numannou%type;
  v_codcomp   thismove.codcomp%type;
  v_codpos    thismove.codpos%type;
  v_codjob    thismove.codjob%type;
  v_codbrlc   thismove.codbrlc%type;
  v_codempmt    thismove.codempmt%type;
  v_stapost2    thismove.stapost2%type;
  v_dteempmt    thismove.dteempmt%type;
  v_numlvl    thismove.numlvl%type;
  v_typemp    thismove.typemp%type;
  v_typpayroll  thismove.typpayroll%type;
  v_jobgrade    thismove.jobgrade%type;
  v_codgrpgl    thismove.codgrpgl%type;
  v_staemp    thismove.staemp%type;
  v_qtydatrq    thismove.qtydatrq%type;
  v_dteduepr    thismove.dteduepr%type;
  v_dteeval   thismove.dteeval%type;
  v_scoreget    thismove.scoreget%type;
  v_codrespr    thismove.codrespr%type;
  v_codexemp    thismove.codexemp%type;
  v_desnote   thismove.desnote%type;
  v_typdoc    thismove.typdoc%type;
  v_codappr   thismove.codappr%type;
  v_flginput    thismove.flginput%type;
  v_qtyexpand   thismove.qtyexpand%type;
  v_flgadjin    thismove.flgadjin%type;
  v_amtincom1   thismove.amtincom1%type;
  v_amtincom2   thismove.amtincom2%type;
  v_amtincom3   thismove.amtincom3%type;
  v_amtincom4   thismove.amtincom4%type;
  v_amtincom5   thismove.amtincom5%type;
  v_amtincom6   thismove.amtincom6%type;
  v_amtincom7   thismove.amtincom7%type;
  v_amtincom8   thismove.amtincom8%type;
  v_amtincom9   thismove.amtincom9%type;
  v_amtincom10  thismove.amtincom10%type;
  v_amtincadj1  thismove.amtincadj1%type;
  v_amtincadj2  thismove.amtincadj2%type;
  v_amtincadj3  thismove.amtincadj3%type;
  v_amtincadj4  thismove.amtincadj4%type;
  v_amtincadj5  thismove.amtincadj5%type;
  v_amtincadj6  thismove.amtincadj6%type;
  v_amtincadj7  thismove.amtincadj7%type;
  v_amtincadj8  thismove.amtincadj8%type;
  v_amtincadj9  thismove.amtincadj9%type;
  v_amtincadj10 thismove.amtincadj10%type;
  v_codcalen    thismove.codcalen%type;
  v_numreqst    thismove.numreqst%type;
  v_numlettr    thismove.numlettr%type;
  v_dteend    thismove.dteend%type;
  v_codcurr   thismove.codcurr%type;
  v_typmove   thismove.typmove%type;
  v_ocodempid   thismove.ocodempid%type;

  --

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10,4,30,30,30,30,45,45,10,1,1,1,10,10,40,4,99,1,10,1,4,4,4,4,4,4,4,4,10,10,10,10,10,999,25,25,50,50,10,10,1,13,4,10,10,500,1,5,10,1,4,4,3,1,10);

        for i in 1..v_column loop
            if i in (1,2,17,21,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44) then
                chk_len(i) := 10;
            elsif i in (3,18) then
                chk_len(i) := 2;
      elsif i in (16,19,23,24) then
                chk_len(i) := 1;
      elsif i in (4,7,8,9,10,11,12,13,14,15,45) then
                chk_len(i) := 4;
      elsif i in (20) then
                chk_len(i) := 3;
      elsif i in (5) then
                chk_len(i) := 16;
      elsif i in (6) then
                chk_len(i) := 40;
      elsif i in (22) then
                chk_len(i) := 6;
            else
                chk_len(i) := 0;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29)  := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30)  := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31)  := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32)  := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33)  := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34)  := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35)  := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36)  := hcm_util.get_string_t(param_json_row,'col-36');
        v_text(37)  := hcm_util.get_string_t(param_json_row,'col-37');
        v_text(38)  := hcm_util.get_string_t(param_json_row,'col-38');
        v_text(39)  := hcm_util.get_string_t(param_json_row,'col-39');
        v_text(40)  := hcm_util.get_string_t(param_json_row,'col-40');
        v_text(41)  := hcm_util.get_string_t(param_json_row,'col-41');
        v_text(42)  := hcm_util.get_string_t(param_json_row,'col-42');
        v_text(43)  := hcm_util.get_string_t(param_json_row,'col-43');
        v_text(44)  := hcm_util.get_string_t(param_json_row,'col-44');
        v_text(45)  := hcm_util.get_string_t(param_json_row,'col-45');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column
                        if i in (1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19) then     
                            if v_text(i) is null or length(trim(v_text(i))) is null then    
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns     
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                               
                            if length(v_text(i)) > chk_len(i) then   
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;     
                        end if;

                        --check date format
                        if i in (2,17,21) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;

                        --check number format   
                        if i in (3,18,20,22,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44) then
                           if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;   
                            end if;
                        end if;
                    end loop;                         

          --assign value to var
          v_codempid    := v_text(1);
          v_dteeffec    := null;
          if v_text(2) is not null or length(trim(v_text(2))) is not null then
            v_dteeffec  := check_dteyre(v_text(2));
          end if; 
          v_numseq    := to_number(nvl(v_text(3),'0'),'99');
          v_codtrn    := v_text(4);
          v_numannou    := v_text(5);
          v_codcomp   := v_text(6);
          v_codpos    := v_text(7);
          v_codjob    := v_text(8);
          v_codbrlc   := v_text(9);
          v_codempmt    := v_text(10);
          v_codcalen    := v_text(11);
          v_typemp    := v_text(12);
          v_typpayroll  := v_text(13);
          v_jobgrade    := v_text(14);
          v_codgrpgl    := v_text(15);
          v_stapost2    := v_text(16);
          v_dteempmt    := null;
          if v_text(17) is not null or length(trim(v_text(17))) is not null then
            v_dteempmt  := check_dteyre(v_text(17));
          end if; 
          v_numlvl    :=  to_number(nvl(v_text(18),'0'),'99');
          v_staemp    := v_text(19);
          v_qtydatrq    :=  to_number(nvl(v_text(20),'0'),'999');
          v_dteduepr    := null;
          if v_text(21) is not null or length(trim(v_text(21))) is not null then
            v_dteduepr  := check_dteyre(v_text(21));
          end if; 
          v_scoreget    :=  to_number(nvl(v_text(22),'0'),'999.99');
          v_codrespr    := v_text(23);
          v_flgadjin    := v_text(24);
          v_amtincom1   := stdenc(to_number(nvl(v_text(25),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom2   := stdenc(to_number(nvl(v_text(26),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom3   := stdenc(to_number(nvl(v_text(27),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom4   := stdenc(to_number(nvl(v_text(28),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom5   := stdenc(to_number(nvl(v_text(29),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom6   := stdenc(to_number(nvl(v_text(30),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom7   := stdenc(to_number(nvl(v_text(31),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom8   := stdenc(to_number(nvl(v_text(32),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom9   := stdenc(to_number(nvl(v_text(33),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom10  := stdenc(to_number(nvl(v_text(34),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj1  := stdenc(to_number(nvl(v_text(35),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj2  := stdenc(to_number(nvl(v_text(36),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj3  := stdenc(to_number(nvl(v_text(37),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj4  := stdenc(to_number(nvl(v_text(38),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj5  := stdenc(to_number(nvl(v_text(39),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj6  := stdenc(to_number(nvl(v_text(40),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj7  := stdenc(to_number(nvl(v_text(41),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj8  := stdenc(to_number(nvl(v_text(42),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj9  := stdenc(to_number(nvl(v_text(43),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincadj10 := stdenc(to_number(nvl(v_text(44),'0'),'9999999.99'),v_codempid,v_chken);
          v_codcurr   := v_text(45);

                    --check incorrect data   
          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;            

          --check codtrn        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodmove  
                        where codcodec  = v_codtrn;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(4);
                        v_err_table := 'TCODMOVE';
                        exit cal_loop;
                    end;

          --check codcomp       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcenter  
                        where codcomp  = v_codcomp;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(6);
                        v_err_table := 'TCENTER';
                        exit cal_loop;
                    end;

          --check codpos        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tpostn   
                        where codpos  = v_codpos;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(7);
                        v_err_table := 'TPOSTN';
                        exit cal_loop;
                    end;

          --check codjob 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tjobcode       
                        where codjob = v_codjob;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(8);
                        v_err_table := 'TJOBCODE';
                        exit cal_loop;
                    end;

          --check codbrlc 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodloca   
                        where codcodec = v_codbrlc;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(9);
                        v_err_table := 'TCODLOCA';
                        exit cal_loop;
                    end;

          --check codempmt 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodempl   
                        where codcodec = v_codempmt;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(10);
                        v_err_table := 'TCODEMPL';
                        exit cal_loop;
                    end;

          --check codcalen 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodwork   
                        where codcodec = v_codcalen;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(11);
                        v_err_table := 'TCODWORK';
                        exit cal_loop;
                    end;

          --check typemp 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodcatg     
                        where codcodec = v_typemp;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(12);
                        v_err_table := 'TCODCATG';
                        exit cal_loop;
                    end;

          --check typpayroll 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodtypy    
                        where codcodec = v_typpayroll;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(13);
                        v_err_table := 'TCODTYPY';
                        exit cal_loop;
                    end;

          --check jobgrade 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodjobg        
                        where codcodec = v_jobgrade;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(14);
                        v_err_table := 'TCODJOBG';
                        exit cal_loop;
                    end;

          --check codgrpgl 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodgrpgl         
                        where codcodec = v_codgrpgl;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(15);
                        v_err_table := 'TCODGRPGL';
                        exit cal_loop;
                    end;

                    --check stapost2 
                    if(v_stapost2 not in ('0','1','2')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(16);
                        exit cal_loop;
                    end if;

          --check staemp 
                    if(v_staemp not in ('0','1','3','9')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(19);
                        exit cal_loop;
                    end if;

          --check codrespr  
          if v_codrespr is not null or length(trim(v_codrespr)) is not null then          
            if v_codrespr not in ('P','N','E') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(23);
              exit cal_loop;
            end if;
          end if;

          --check flgadjin  
          if v_flgadjin is not null or length(trim(v_flgadjin)) is not null then          
            if v_flgadjin not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(24);
              exit cal_loop;
            end if;
          end if;

          --check codcurr 
          if v_codcurr is not null or length(trim(v_codcurr)) is not null then          
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodcurr    
              where codcodec  = v_codcurr;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(45);
              v_err_table := 'TCODCURR';
              exit cal_loop;
            end;          
          end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_flginput    := 'N';
          v_dteeval   := null;
          v_codexemp    := null;
          v_desnote   := null;
          v_typdoc    := null;
          v_codappr   := null;
          v_flginput    := null;
          v_qtyexpand   := null;
          v_numreqst    := null;
          v_numlettr    := null;
          v_dteend    := null;
          v_typmove   := null;
          v_ocodempid   := null;

          begin 
            delete from thismove where codempid = v_codempid and dteeffec = v_dteeffec and numseq = v_numseq;                       

            insert into thismove(codempid, dteeffec, numseq, codtrn, numannou, codcomp, 
                                                        codpos, codjob, codbrlc, codempmt, stapost2, dteempmt, 
                                                        numlvl, typemp, typpayroll, jobgrade, codgrpgl, staemp, 
                                                        qtydatrq, dteduepr, dteeval, scoreget, codrespr, codexemp, 
                                                        desnote, typdoc, codappr, flginput, qtyexpand, flgadjin, 
                                                        amtincom1, amtincom2, amtincom3, amtincom4, amtincom5, 
                                                        amtincom6, amtincom7, amtincom8, amtincom9, amtincom10, 
                                                        amtincadj1, amtincadj2, amtincadj3, amtincadj4, amtincadj5, 
                                                        amtincadj6, amtincadj7, amtincadj8, amtincadj9, amtincadj10, 
                                                        codcalen, numreqst, numlettr, dteend, codcurr, typmove, 
                                                        ocodempid, dtecreate, codcreate, dteupd, coduser)  
                                        values (v_codempid, v_dteeffec, v_numseq, v_codtrn, v_numannou, v_codcomp, 
                                                        v_codpos, v_codjob, v_codbrlc, v_codempmt, v_stapost2, v_dteempmt, 
                                                        v_numlvl, v_typemp, v_typpayroll, v_jobgrade, v_codgrpgl, v_staemp, 
                                                        v_qtydatrq, v_dteduepr, v_dteeval, v_scoreget, v_codrespr, v_codexemp, 
                                                        v_desnote, v_typdoc, v_codappr, v_flginput, v_qtyexpand, v_flgadjin, 
                                                        v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5, 
                                                        v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, 
                                                        v_amtincadj1, v_amtincadj2, v_amtincadj3, v_amtincadj4, v_amtincadj5, 
                                                        v_amtincadj6, v_amtincadj7, v_amtincadj8, v_amtincadj9, v_amtincadj10, 
                                                        v_codcalen, v_numreqst, v_numlettr, v_dteend, v_codcurr, v_typmove, 
                                                        v_ocodempid, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser); 

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  


  procedure get_process_pm_thismist (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_thismist(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


  procedure validate_excel_pm_thismist (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    --v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;       
  --thismist
  v_codempid    thismist.codempid%type;
  v_dteeffec    thismist.dteeffec%type;
  v_numhmref    thismist.numhmref%type;
  v_refdoc    thismist.refdoc%type;
  v_codcomp   thismist.codcomp%type;
  v_codpos    thismist.codpos%type;
  v_codjob    thismist.codjob%type;
  v_numlvl    thismist.numlvl%type;
  v_dteempmt    thismist.dteempmt%type;
  v_codempmt    thismist.codempmt%type;
  v_typemp    thismist.typemp%type;
  v_typpayroll  thismist.typpayroll%type;
  v_desmist1    thismist.desmist1%type;
  v_numannou    thismist.numannou%type;
  v_codappr   thismist.codappr%type;
  v_dteappr   thismist.dteappr%type;
  v_dtemistk    thismist.dtemistk%type;
  v_jobgrade    thismist.jobgrade%type;
  v_codgrpgl    thismist.codgrpgl%type;
  v_codmist   thismist.codmist%type;
    --thispun
  v_codpunsh    thispun.codpunsh%type;
  v_numseq    thispun.numseq%type;
  v_dtestart    thispun.dtestart%type;
  v_dteend    thispun.dteend%type;
  v_codsex    thispun.codsex%type;
  v_codedlv   thispun.codedlv%type;
  v_staupd    thispun.staupd%type;
  v_typpun    thispun.typpun%type;
  v_remark    thispun.remark%type;
  v_flgexempt   thispun.flgexempt%type;
  v_codexemp    thispun.codexemp%type;
  v_flgblist    thispun.flgblist%type;
  v_flgssm    thispun.flgssm%type;
  --thispund    
  v_dteyearst   thispund.dteyearst%type;
  v_dtemthst    thispund.dtemthst%type;
  v_numprdst    thispund.numprdst%type;
  v_dteyearen   thispund.dteyearen%type;
  v_dtemthen    thispund.dtemthen%type;
  v_numprden    thispund.numprden%type;
  v_codpay    thispund.codpay%type;
  v_amtincom1   thispund.amtincom1%type;
  v_amtincom2   thispund.amtincom2%type;
  v_amtincom3   thispund.amtincom3%type;
  v_amtincom4   thispund.amtincom4%type;
  v_amtincom5   thispund.amtincom5%type;
  v_amtincom6   thispund.amtincom6%type;
  v_amtincom7   thispund.amtincom7%type;
  v_amtincom8   thispund.amtincom8%type;
  v_amtincom9   thispund.amtincom9%type;
  v_amtincom10  thispund.amtincom10%type;
  v_amtincded1  thispund.amtincded1%type;
  v_amtincded2  thispund.amtincded2%type;
  v_amtincded3  thispund.amtincded3%type;
  v_amtincded4  thispund.amtincded4%type;
  v_amtincded5  thispund.amtincded5%type;
  v_amtincded6  thispund.amtincded6%type;
  v_amtincded7  thispund.amtincded7%type;
  v_amtincded8  thispund.amtincded8%type;
  v_amtincded9  thispund.amtincded9%type;
  v_amtincded10 thispund.amtincded10%type;
  v_amtded    thispund.amtded%type;
  v_amttotded   thispund.amttotded%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng();   
       for i in 1..v_column loop
            if i in (1,2,8,17,20,21,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52) then
                chk_len(i) := 10;
            elsif i in (3,16) then
                chk_len(i) := 16;
      elsif i in (4) then
                chk_len(i) := 40;
      elsif i in (5,6,9,10,11,12,13,14,18,24,27,30,54,56) then
                chk_len(i) := 4;
      elsif i in (15) then
                chk_len(i) := 1000;
      elsif i in (7,19,25,26,28,29) then
                chk_len(i) := 2;
      elsif i in (23) then
                chk_len(i) := 500;
      elsif i in (22,53,55,57) then
                chk_len(i) := 1;
            else
                chk_len(i) := 0;
            end if;
        end loop;     

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23)  := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24)  := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25)  := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26)  := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27)  := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28)  := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29)  := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30)  := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31)  := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32)  := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33)  := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34)  := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35)  := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36)  := hcm_util.get_string_t(param_json_row,'col-36');
        v_text(37)  := hcm_util.get_string_t(param_json_row,'col-37');
        v_text(38)  := hcm_util.get_string_t(param_json_row,'col-38');
        v_text(39)  := hcm_util.get_string_t(param_json_row,'col-39');
        v_text(40)  := hcm_util.get_string_t(param_json_row,'col-40');
        v_text(41)  := hcm_util.get_string_t(param_json_row,'col-41');
        v_text(42)  := hcm_util.get_string_t(param_json_row,'col-42');
        v_text(43)  := hcm_util.get_string_t(param_json_row,'col-43');
        v_text(44)  := hcm_util.get_string_t(param_json_row,'col-44');
        v_text(45)  := hcm_util.get_string_t(param_json_row,'col-45');
        v_text(46)  := hcm_util.get_string_t(param_json_row,'col-46');
        v_text(47)  := hcm_util.get_string_t(param_json_row,'col-47');
        v_text(48)  := hcm_util.get_string_t(param_json_row,'col-48');
        v_text(49)  := hcm_util.get_string_t(param_json_row,'col-49');
        v_text(50)  := hcm_util.get_string_t(param_json_row,'col-50');
        v_text(51)  := hcm_util.get_string_t(param_json_row,'col-51');
        v_text(52)  := hcm_util.get_string_t(param_json_row,'col-52');
        v_text(53)  := hcm_util.get_string_t(param_json_row,'col-53');
        v_text(54)  := hcm_util.get_string_t(param_json_row,'col-54');
        v_text(55)  := hcm_util.get_string_t(param_json_row,'col-55');
        v_text(56)  := hcm_util.get_string_t(param_json_row,'col-56');
        v_text(57)  := hcm_util.get_string_t(param_json_row,'col-57');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,56) then   
                             if v_text(i) is null or length(trim(v_text(i))) is null then    
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns      
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                               
                            if(length(v_text(i)) > chk_len(i)) then  
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;     
                        end if;

                        --check date format
                        if i in (2,8,17,20,21) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if(check_date(v_text(i))) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;

                        --check number format     
                     if i in (7,19,24,25,26,27,28,29,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52) then
                           if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;   
                            end if; 
                        end if;
                    end loop;                         

          --assign value to var
          v_codempid    := v_text(1);
          v_dteeffec    := null;
          if v_text(2) is not null or length(trim(v_text(2))) is not null then
            v_dteeffec  := check_dteyre(v_text(2));
          end if; 
          v_numhmref    := v_text(3);
          v_codcomp   := v_text(4);
          v_codpos    := v_text(5);
          v_codjob    := v_text(6);
          v_numlvl    := to_number(nvl(v_text(7),'0'),'99');
          v_dteempmt    := null;
          if v_text(8) is not null or length(trim(v_text(8))) is not null then
            v_dteempmt  := check_dteyre(v_text(8));
          end if; 
          v_codempmt    := v_text(9);
          v_typemp    := v_text(10);
          v_typpayroll  := v_text(11);
          v_jobgrade    := v_text(12);
          v_codgrpgl    := v_text(13);
         v_codmist    := v_text(14);
          v_desmist1    := v_text(15);
          v_numannou    := v_text(16);
          v_dtemistk    := null;
          if v_text(17) is not null or length(trim(v_text(17))) is not null then
            v_dtemistk  := check_dteyre(v_text(17));
          end if; 
          v_codpunsh    := v_text(18);
          v_numseq    :=  to_number(nvl(v_text(19),'0'),'99');
          v_dtestart    := null;
          if v_text(20) is not null or length(trim(v_text(20))) is not null then
            v_dtestart  := check_dteyre(v_text(20));
          end if; 
          v_dteend    := null;
          if v_text(21) is not null or length(trim(v_text(21))) is not null then
            v_dteend  := check_dteyre(v_text(21));
          end if; 
          v_typpun    := v_text(22);
          v_remark    := v_text(23);
          v_dteyearst   := to_number(nvl(v_text(24),'0'),'9999');
          v_dtemthst    := to_number(nvl(v_text(25),'0'),'99');
          v_numprdst    := to_number(nvl(v_text(26),'0'),'99');
          v_dteyearen := to_number(nvl(v_text(27),'0'),'9999');
          v_dtemthen    := to_number(nvl(v_text(28),'0'),'99');
          v_numprden    := to_number(nvl(v_text(29),'0'),'99');
          v_codpay    := v_text(30);
          v_amtincom1   := stdenc(to_number(nvl(v_text(31),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom2   := stdenc(to_number(nvl(v_text(32),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom3   := stdenc(to_number(nvl(v_text(33),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom4   := stdenc(to_number(nvl(v_text(34),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom5   := stdenc(to_number(nvl(v_text(35),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom6   := stdenc(to_number(nvl(v_text(36),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom7   := stdenc(to_number(nvl(v_text(37),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom8   := stdenc(to_number(nvl(v_text(38),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom9   := stdenc(to_number(nvl(v_text(39),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincom10      := stdenc(to_number(nvl(v_text(40),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded1      := stdenc(to_number(nvl(v_text(41),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded2      := stdenc(to_number(nvl(v_text(42),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded3      := stdenc(to_number(nvl(v_text(43),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded4      := stdenc(to_number(nvl(v_text(44),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded5      := stdenc(to_number(nvl(v_text(45),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded6      := stdenc(to_number(nvl(v_text(46),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded7      := stdenc(to_number(nvl(v_text(47),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded8      := stdenc(to_number(nvl(v_text(48),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded9      := stdenc(to_number(nvl(v_text(49),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtincded10     := stdenc(to_number(nvl(v_text(50),'0'),'9999999.99'),v_codempid,v_chken);
          v_amtded        := stdenc(to_number(nvl(v_text(51),'0'),'9999999.99'),v_codempid,v_chken);
          v_amttotded   := stdenc(to_number(nvl(v_text(52),'0'),'9999999.99'),v_codempid,v_chken);
          v_flgexempt   := v_text(53);
          v_codexemp    := v_text(54);
          v_flgblist    := v_text(55);
          v_codgrpgl    := v_text(56);
          v_flgssm    := v_text(57);


                    --check incorrect data   
          --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1, codsex, codedlv, jobgrade into v_chk_exists, v_codsex, v_codedlv, v_jobgrade from temploy1   
                        where codempid  = v_codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;            

          --check codcomp       
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcenter  
                        where codcomp  = v_codcomp;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(4);
                        v_err_table := 'TCENTER';
                        exit cal_loop;
                    end;

          --check codpos        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tpostn   
                        where codpos  = v_codpos;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(5);
                        v_err_table := 'TPOSTN';
                        exit cal_loop;
                    end;

          --check codjob 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tjobcode       
                        where codjob = v_codjob;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(6);
                        v_err_table := 'TJOBCODE';
                        exit cal_loop;
                    end;

          --check codempmt 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodempl   
                        where codcodec = v_codempmt;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(9);
                        v_err_table := 'TCODEMPL';
                        exit cal_loop;
                    end;

          --check typemp 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodcatg     
                        where codcodec = v_typemp;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(10);
                        v_err_table := 'TCODCATG';
                        exit cal_loop;
                    end;

          --check typpayroll 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodtypy    
                        where codcodec = v_typpayroll;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(11);
                        v_err_table := 'TCODTYPY';
                        exit cal_loop;
                    end;

          --check jobgrade 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodjobg        
                        where codcodec = v_jobgrade;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(12);
                        v_err_table := 'TCODJOBG';
                        exit cal_loop;
                    end;

          --check codgrpgl 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodgrpgl         
                        where codcodec = v_codgrpgl;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(13);
                        v_err_table := 'TCODGRPGL';
                        exit cal_loop;
                    end;

          --check codpunsh 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodpunh      
                        where codcodec = v_codpunsh;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(18);
                        v_err_table := 'TCODPUNH';
                        exit cal_loop;
                    end;

                    --check typpun 
                    if(v_typpun not in ('0','1','2','3','4')) then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(22);
                        exit cal_loop;
                    end if;

          --check dteyearst, dtemthst, numprdst, dteyearen, dtemthen, numprden, codpay, amtincom1, amtincded1, amtded, amttotded 
          if v_typpun = '1' then
            for i in 1..v_column loop
              if i in (23,24,25,26,27,28,29,30,40,50,51) then
                if v_text(i) is null or length(trim(v_text(i))) is null then                                      
                                    v_error   := true;
                                    v_err_code  := 'HR2045';
                                    v_err_field := v_field(i);
                                    exit cal_loop;   
                end if;
              end if;
            end loop;
          end if;

          --check codpay 
                    if v_codpay is not null or length(trim(v_codpay)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tinexinf   
                            where codpay = v_codpay;
                        exception when no_data_found then 
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(30);
                            v_err_table := 'TINEXINF';
                            exit cal_loop;
                        end;
                    end if;

            --check flgexempt   
          if v_flgexempt is not null or length(trim(v_flgexempt)) is not null then          
            if v_flgexempt not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(53);
              exit cal_loop;
            end if;
          end if;

          --check codexemp  
                    if v_codexemp is not null or length(trim(v_codexemp)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodexem    
                            where codcodec  = v_codexemp;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(54);
                            v_err_table := 'TCODEXEM';
                            exit cal_loop;
                        end;
                    end if;


          --check flgblist  
          if v_flgblist is not null or length(trim(v_flgblist)) is not null then          
            if v_flgblist not in ('Y','N') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(55);
              exit cal_loop;
            end if;
          end if;

                    --check flgssm  
          if v_flgexempt = 'Y' then
            if v_flgssm  is null or length(trim(v_flgssm)) is null then 
              v_error   := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(57);
              exit cal_loop;
            end if;
          end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_refdoc          := null;
          v_codappr     := null;
          v_dteappr     := null;

          begin 
            delete from thismist where codempid = v_codempid and dteeffec = v_dteeffec ;                       

            insert into thismist(codempid, dteeffec, numhmref, refdoc,
                                                    codcomp, codpos, codjob, numlvl,
                                                    dteempmt, codempmt, typemp, typpayroll,
                                                    desmist1, numannou, codappr, dteappr,
                                                    dtemistk, jobgrade, codgrpgl, codmist,
                                                    dtecreate, codcreate, dteupd, coduser)  
                                    values (v_codempid, v_dteeffec, v_numhmref, v_refdoc,
                                                    v_codcomp, v_codpos, v_codjob, v_numlvl,
                                                    v_dteempmt, v_codempmt, v_typemp, v_typpayroll,
                                                    v_desmist1, v_numannou, v_codappr, v_dteappr,
                                                    v_dtemistk, v_jobgrade, v_codgrpgl, v_codmist,
                                                    trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;


          v_staupd    := 'U';

                    begin 
            delete from thispun where codempid = v_codempid and dteeffec = v_dteeffec and codpunsh = v_codpunsh and numseq = v_numseq;                   

            insert into thispun(dteeffec, codpunsh, codempid, numseq, dtestart,
                                                     dteend, codcomp, codjob, codpos, numlvl,
                                                     codsex, codedlv, staupd, typpun, remark,
                                                     flgexempt, codexemp, flgblist, jobgrade, codgrpgl,
                                                     flgssm, dtecreate, codcreate, dteupd, coduser)  
                                    values  (v_dteeffec, v_codpunsh, v_codempid, v_numseq, v_dtestart,
                                                     v_dteend, v_codcomp, v_codjob, v_codpos, v_numlvl,
                                                     v_codsex, v_codedlv, v_staupd, v_typpun, v_remark,
                                                     v_flgexempt, v_codexemp, v_flgblist, v_jobgrade, v_codgrpgl,
                                                     v_flgssm, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser); 

                    end;

          begin 
            delete from thispund where codempid = v_codempid and dteeffec = v_dteeffec and codpunsh = v_codpunsh  ;                 

            insert into thispund(dteeffec, codpunsh, codempid, codcomp, dteyearst, dtemthst, 
                                                     numprdst, dteyearen, dtemthen, numprden, codpay, 
                                                     amtincom1, amtincom2, amtincom3, amtincom4, amtincom5, 
                                                     amtincom6, amtincom7, amtincom8, amtincom9, amtincom10, 
                                                     amtincded1, amtincded2, amtincded3, amtincded4, amtincded5, 
                                                     amtincded6, amtincded7, amtincded8, amtincded9, amtincded10, 
                                                     amtded, amttotded, dtecreate, codcreate, dteupd, coduser)  
                                        values  (v_dteeffec, v_codpunsh, v_codempid, v_codcomp, v_dteyearst, v_dtemthst, 
                                                     v_numprdst, v_dteyearen, v_dtemthen, v_numprden, v_codpay, 
                                                     v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5, 
                                                     v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, 
                                                     v_amtincded1, v_amtincded2, v_amtincded3, v_amtincded4, v_amtincded5, 
                                                     v_amtincded6, v_amtincded7, v_amtincded8, v_amtincded9, v_amtincded10, 
                                                     v_amtded, v_amttotded, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  

                    end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                   -- insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

  procedure get_process_pm_tbcklst (json_str_input  in clob,
                                                   json_str_output out clob) is
      p_rec_tran number := 0;
      p_rec_err  number := 0;
  begin
      initial_value(json_str_input);
      validate_excel_pm_tbcklst(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_pm_tbcklst (json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_numoffid    tbcklst.numoffid%type;
  v_codempid    tbcklst.codempid%type;
  v_numappl   tbcklst.numappl%type;
  v_codtitle    tbcklst.codtitle%type;
  v_namfirste   tbcklst.namfirste%type;
  v_namfirstt   tbcklst.namfirstt%type;
  v_namfirst3   tbcklst.namfirst3%type;
  v_namfirst4   tbcklst.namfirst4%type;
  v_namfirst5   tbcklst.namfirst5%type;
  v_namlaste    tbcklst.namlaste%type;
  v_namlastt    tbcklst.namlastt%type;
  v_namlast3    tbcklst.namlast3%type;
  v_namlast4    tbcklst.namlast4%type;
  v_namlast5    tbcklst.namlast5%type;
  v_namempe   tbcklst.namempe%type;
  v_namempt   tbcklst.namempt%type;
  v_namemp3   tbcklst.namemp3%type;
  v_namemp4   tbcklst.namemp4%type;
  v_namemp5   tbcklst.namemp5%type;
  v_dteempmt    tbcklst.dteempmt%type;
  v_codcomp   tbcklst.codcomp%type;
  v_codpos    tbcklst.codpos%type;
  v_dteeffex    tbcklst.dteeffex%type;
  v_codexemp    tbcklst.codexemp%type;
  v_namlpos   tbcklst.namlpos%type;
  v_namlcomp    tbcklst.namlcomp%type;
  v_desexemp    tbcklst.desexemp%type;
  v_dteempdb    tbcklst.dteempdb%type;
  v_codsex    tbcklst.codsex%type;
  v_namimage    tbcklst.namimage%type;
  v_numpasid    tbcklst.numpasid%type;
  v_namlcompy   tbcklst.namlcompy%type;
  v_desinfo   tbcklst.desinfo%type;
  v_desnote   tbcklst.desnote%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(13,10,10,4,30,30,30,30,10,40,4,10,4,150,150,150,10,1,20,150,150,1000);   
        for i in 1..v_column loop
            if i in (1) then
                chk_len(i) := 13;
            elsif i in (2,3,9,12,17) then
                chk_len(i) := 10;     
      elsif i in (4,11,13) then
                chk_len(i) := 4;
      elsif i in (5,6,7,8) then
                chk_len(i) := 30;
      elsif i in (10) then
                chk_len(i) := 40;
      elsif i in (14,15,16,20,21) then
                chk_len(i) := 150;
      elsif i in (18) then
                chk_len(i) := 1;  
      elsif i in (19) then
                chk_len(i) := 20;
      elsif i in (22) then
                chk_len(i) := 1000;       
            else
                chk_len(i) := 0;
            end if;
        end loop;        


        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           
              v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17)  := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18)  := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19)  := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20)  := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21)  := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22)  := hcm_util.get_string_t(param_json_row,'col-22');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,4,5,6,7,8,18) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then  
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;   

                        --check length all columns       
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (9,12,17) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop;

          --assign value to var
          v_numoffid    := v_text(1);
          v_codempid    := v_text(2);
          v_numappl   := v_text(3);
          v_codtitle    := v_text(4);
          v_namfirste   := v_text(5);
          v_namfirstt   := v_text(6);
          v_namlaste    := v_text(7);
          v_namlastt    := v_text(8);
          v_dteempmt  := null;
          if v_text(9) is not null or length(trim(v_text(9))) is not null then
            v_dteempmt  := check_dteyre(v_text(9));
          end if; 
          v_codcomp   := v_text(10);
          v_codpos    := v_text(11);
          v_dteeffex    := null;
          if v_text(12) is not null or length(trim(v_text(12))) is not null then
            v_dteeffex  := check_dteyre(v_text(12));
          end if; 
          v_codexemp    := v_text(13);
          v_namlpos   := v_text(14);
          v_namlcomp    := v_text(15);
          v_desexemp    := v_text(16);
          v_dteempdb    := null;
          if v_text(17) is not null or length(trim(v_text(17))) is not null then
            v_dteempdb  := check_dteyre(v_text(17));
          end if;
          v_codsex    := v_text(18);
          v_numpasid    := v_text(19);
          v_namlcompy   := v_text(20);
          v_desinfo   := v_text(21);
          v_desnote   := v_text(22);

                    v_namfirst3   := v_namempe;
          v_namfirst4   := v_namfirste;
          v_namfirst5   := v_namfirste;
          v_namlast3    := v_namlaste;
          v_namlast4    := v_namlaste;
          v_namlast5  := v_namlaste;
          v_namempe := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'101'))) || ltrim(rtrim(v_namfirste))||' '||ltrim(rtrim(v_namlaste)),1,60);
          v_namempt     := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'102'))) || ltrim(rtrim(v_namfirstt))||' '||ltrim(rtrim(v_namlastt)),1,60);
          v_namemp3 := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'103'))) || ltrim(rtrim(v_namfirst3))||' '||ltrim(rtrim(v_namlast3)),1,60);
          v_namemp4 := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'104'))) || ltrim(rtrim(v_namfirst4))||' '||ltrim(rtrim(v_namlast4)),1,60);
          v_namemp5 := substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'105'))) || ltrim(rtrim(v_namfirst5))||' '||ltrim(rtrim(v_namlast5)),1,60);
          v_namimage  := null;

          --check incorrect data  
                    --check numoffid
                    v_chk_exists := 0;
                    begin 
                        select 1, t1.codempid, numappl, codtitle, namfirste, namfirstt, namfirst3, namfirst4, namfirst5, namlaste, namlastt, namlast3, namlast4, namlast5, namempe, namempt, namemp3, namemp4, namemp5, dteempmt, codcomp, codpos, dteeffex, get_tpostn_name(codpos,102), get_tcenter_name(codcomp,102) , dteempdb, codsex, numpasid, substr(namcomt ,1,150) 
                            into v_chk_exists, v_codempid,  v_numappl, v_codtitle, v_namfirste, v_namfirstt, v_namfirst3, v_namfirst4, v_namfirst5, v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5, v_namempe, v_namempt, v_namemp3, v_namemp4, v_namemp5, v_dteempmt, v_codcomp, v_codpos, v_dteeffex, v_namlpos, v_namlcomp, v_dteempdb, v_codsex, v_numpasid, v_namlcompy
                        from temploy1  t1, temploy2 t2, tcompny t3
                        where t2.numoffid  = v_numoffid  and  t1.codempid =  t2.codempid and hcm_util.get_codcomp_level(t1.codcomp,1) = t3.codcompy;
                    exception when no_data_found then  
                        null; 
                    end;   

                    if  v_chk_exists = 0 then
                        --check codempid    
                        if v_codempid is not null or length(trim(v_codempid)) is not null then
                            v_chk_exists := 0;
                            begin 
                                select 1 into v_chk_exists from temploy1   
                                where codempid  = v_codempid;
                            exception when no_data_found then  
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := v_field(2);
                                v_err_table := 'TEMPLOY1';
                                exit cal_loop;
                            end;  
                        end if;

                        --check codtitle 
                        if v_codtitle is not null or length(trim(v_codtitle)) is not null then
                            if(v_codtitle not in ('003','004','005')) then
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(4);
                                exit cal_loop;
                            end if;
                        end if;

                        --check codcomp   
                        if v_codcomp is not null or length(trim(v_codcomp)) is not null then
                            v_chk_exists := 0;
                            begin 
                                select 1 into v_chk_exists from tcenter  
                                where codcomp  = v_codcomp;
                            exception when no_data_found then  
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := v_field(10);
                                v_err_table := 'TCENTER';
                                exit cal_loop;
                            end;
                        end if;

                        --check codpos      
                        if v_codpos is not null or length(trim(v_codpos)) is not null then
                            v_chk_exists := 0;
                            begin 
                                select 1 into v_chk_exists from tpostn   
                                where codpos  = v_codpos;
                            exception when no_data_found then  
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := v_field(11);
                                v_err_table := 'TPOSTN';
                                exit cal_loop;
                            end;  
                        end if;    

                        --check codsex  
                        if v_codsex is not null or length(trim(v_codsex)) is not null then          
                            if v_codsex not in ('M','F') then
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(18);
                                exit cal_loop;
                            end if;
                        end if;

                        --check dteeffex
                        if((v_dteeffex is not null) or length(trim(v_dteeffex)) is not null) then
                            if((v_dteempmt is not null) or length(trim(v_dteempmt)) is not null) then
                                if v_dteeffex < v_dteempmt then
                                    v_error   := true;
                                    v_err_code  := 'HR5017';
                                    v_err_field := v_field(12);
                                    exit cal_loop;
                                end if; 
                            end if;   
                        end if;
                    end if;

                    --check codexemp
                    if v_codexemp is not null or length(trim(v_codexemp)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodexem    
                            where codcodec  = v_codexemp;
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(13);
                            v_err_table := 'TCODEXEM';
                            exit cal_loop;
                        end;
                    end if;  

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin 
            delete from tbcklst where numoffid = v_numoffid;                       

            insert into tbcklst(numoffid, codempid, numappl, codtitle, 
                                                    namfirste, namfirstt, namfirst3, namfirst4, namfirst5,
                                                    namlaste, namlastt, namlast3, namlast4, namlast5,
                                                    namempe, namempt, namemp3, namemp4, namemp5, 
                                                    dteempmt, codcomp, codpos, dteeffex, codexemp, namlpos,
                                                    namlcomp, desexemp, dteempdb, codsex, namimage, numpasid,
                                                    namlcompy, desinfo, desnote, dtecreate, codcreate, dteupd, coduser)  
                                    values (v_numoffid, v_codempid, v_numappl, v_codtitle, 
                                                    v_namfirste, v_namfirstt, v_namfirst3, v_namfirst4, v_namfirst5,
                                                    v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5,
                                                    v_namempe, v_namempt, v_namemp3, v_namemp4, v_namemp5, 
                                                    v_dteempmt, v_codcomp, v_codpos, v_dteeffex, v_codexemp, v_namlpos,
                                                    v_namlcomp, v_desexemp, v_dteempdb, v_codsex, v_namimage, v_numpasid,
                                                    v_namlcompy, v_desinfo, v_desnote, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser); 

                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;    

   procedure get_process_pm_tlegalexe(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_pm_tlegalexe(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_pm_tlegalexe (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tlegalexe     tlegalexe%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
      for i in 1..v_column loop
      if i in (1,7,8) then
      chk_len(i) := 10;      
      elsif i in (4,9,19) then
      chk_len(i) := 4;
	  elsif i in (2) then
      chk_len(i) := 30;
      elsif i in (3) then
      chk_len(i) := 40;
      elsif i in (5,6) then
      chk_len(i) := 150;
	  elsif i in (10) then
      chk_len(i) := 50;
      elsif i in (11) then
      chk_len(i) := 15;
	  elsif i in (12,17) then
      chk_len(i) := 3;
	  elsif i in (13,15,18) then
      chk_len(i) := 12;
      elsif i in (14) then
      chk_len(i) := 5;
	  elsif i in (16) then
      chk_len(i) := 1;
	   elsif i in (20,21) then
      chk_len(i) := 2;
      else
      chk_len(i) := 0;   
      end if;
    end loop;        


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
				v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   
				v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');   
				v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10');   
				v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');
				v_text(12)   := hcm_util.get_string_t(param_json_row,'col-12');
				v_text(13)   := hcm_util.get_string_t(param_json_row,'col-13');
				v_text(14)   := hcm_util.get_string_t(param_json_row,'col-14');
				v_text(15)   := hcm_util.get_string_t(param_json_row,'col-15');
				v_text(16)   := hcm_util.get_string_t(param_json_row,'col-16');   
				v_text(17)   := hcm_util.get_string_t(param_json_row,'col-17');   
				v_text(18)   := hcm_util.get_string_t(param_json_row,'col-18');   
				v_text(19)   := hcm_util.get_string_t(param_json_row,'col-19');   
				v_text(20)   := hcm_util.get_string_t(param_json_row,'col-20');
				v_text(21)   := hcm_util.get_string_t(param_json_row,'col-21');		

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                       if i in (1,2,4,6,7,13,16) then  
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (7,8) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;

                        --check number format     
                          if i in (12,13,14,15,17,18,19,20,21) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;
                    end loop; 


          --assign value to var
		  v_tlegalexe.codempid := v_text(1);
          v_tlegalexe.numcaselw := v_text(2);
          v_tlegalexe.civillaw  := v_text(3);
          v_tlegalexe.codlegald := v_text(4);
          v_tlegalexe.namlegalb  := v_text(5);
		  v_tlegalexe.namplntiff  := v_text(6);
		  v_tlegalexe.dtestrt  := null;
		  if v_text(7) is not null or length(trim(v_text(7))) is not null then
            v_tlegalexe.dtestrt  := check_dteyre(v_text(7));
          end if;
		  v_tlegalexe.dteend := null;
		  if v_text(8) is not null or length(trim(v_text(8))) is not null then
            v_tlegalexe.dteend  := check_dteyre(v_text(8));
          end if;
          v_tlegalexe.banklaw  := v_text(9);
          v_tlegalexe.numkeep := v_text(10);
          v_tlegalexe.numbanklg  := v_text(11);
		  v_tlegalexe.qtyperd := to_number(nvl(v_text(12),0));
          v_tlegalexe.amtfroze  := stdenc(to_number(nvl(v_text(13),'0'),'999999999.99'),v_tlegalexe.codempid,v_chken);
		  v_tlegalexe.pctded := to_number(nvl(v_text(14),0));
          v_tlegalexe.amtmin  := stdenc(to_number(nvl(v_text(15),'0'),'999999999.99'),v_tlegalexe.codempid,v_chken);
		  v_tlegalexe.stacaselw  := v_text(16);
		  v_tlegalexe.qtyperded := to_number(nvl(v_text(17),0));
          v_tlegalexe.amtded  := stdenc(to_number(nvl(v_text(18),'0'),'999999999.99'),v_tlegalexe.codempid,v_chken);
		  v_tlegalexe.dteyrded := to_number(nvl(v_text(19),0));
          v_tlegalexe.dtemthded  := to_number(nvl(v_text(20),0));
		  v_tlegalexe.numprdded := to_number(nvl(v_text(21),0));

           --check incorrect data 
		  --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1, codcomp into v_chk_exists, v_tlegalexe.codcomp from temploy1   
                        where codempid  = v_tlegalexe.codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

		  --check codlegald
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodlegald      
              where codcodec  = v_tlegalexe.codlegald;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(4);
              v_err_table := 'TCODLEGALD';
              exit cal_loop;
            end;       

			--check banklaw 
             if v_tlegalexe.banklaw is not null or length(trim(v_tlegalexe.banklaw)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tcodbank       
				  where codcodec  = v_tlegalexe.banklaw;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(9);
				  v_err_table := 'TCODBANK';
				  exit cal_loop;
				end;          
			end if; 

            --check stacaselw    
            if v_tlegalexe.stacaselw not in ('P','C') then
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(16);
              exit cal_loop;
            end if;                   

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 

                    begin 
            delete from tlegalexe where codempid  = v_tlegalexe.codempid  and numcaselw  = v_tlegalexe.numcaselw ;

            insert into   tlegalexe(codempid, codcomp, numcaselw, civillaw, codlegald, namlegalb, namplntiff,
									dtestrt, dteend, banklaw, numkeep, numbanklg, qtyperd, amtfroze,
									pctded, amtmin, stacaselw, qtyperded, amtded, dteyrded, dtemthded, numprdded,
									dtecreate, codcreate, dteupd, coduser)
                      values(v_tlegalexe.codempid, v_tlegalexe.codcomp, v_tlegalexe.numcaselw, v_tlegalexe.civillaw, v_tlegalexe.codlegald, v_tlegalexe.namlegalb, v_tlegalexe.namplntiff,
								v_tlegalexe.dtestrt, v_tlegalexe.dteend, v_tlegalexe.banklaw, v_tlegalexe.numkeep, v_tlegalexe.numbanklg, v_tlegalexe.qtyperd, v_tlegalexe.amtfroze,
								v_tlegalexe.pctded, v_tlegalexe.amtmin, v_tlegalexe.stacaselw, v_tlegalexe.qtyperded, v_tlegalexe.amtded, v_tlegalexe.dteyrded, v_tlegalexe.dtemthded, v_tlegalexe.numprdded,
								trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_pm_tlegalexd(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_pm_tlegalexd(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_pm_tlegalexd (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 
	v_amtdmin		number  := 0 ;
	v_pctded		number  := 0 ;
  v_tlegalexd     tlegalexd%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

	type codpay is table of varchar2(4 char) index by binary_integer;
	arr_codpay    codpay;--เก็บรหัสรายได้ ตัวที่1-n

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1) then
      chk_len(i) := 10;   
	  elsif i in (2) then
      chk_len(i) := 30; 	  
      elsif i in (3) then
      chk_len(i) := 4; 
      elsif i in (4) then
      chk_len(i) := 6;
	   elsif i in (5) then
      chk_len(i) := 12;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
		  arr_codpay(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
		end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
                v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
                v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check number format     
                        if i in (4,5) then    
                            if check_number(v_text(i)) then                         
                                v_error   := true;
                                v_err_code  := 'HR2816';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;  

                            --check number < 0
                             if to_number(v_text(i)) < 0 then
                                v_error   := true;
                                v_err_code  := 'HR2023';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if; 
                        end if;




                    end loop; 


				  --assign value to var
				  v_tlegalexd.codempid 		:= v_text(1);
				  v_tlegalexd.numcaselw   	:= v_text(2);
                  v_tlegalexd.codpay 	    := v_text(3);
                  v_pctded                      := to_number(nvl(v_text(4), 0),'999.99');
                  v_amtdmin                    := to_number(nvl(v_text(5), 0),'999999999.99');
				  v_tlegalexd.pctded  	    := v_pctded;
				  v_tlegalexd.amtdmin  	    := stdenc(v_amtdmin, v_tlegalexd.codempid, v_chken);                           

				  --check incorrect data 
				  --check codempid        
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from temploy1   
                        where codempid  = v_tlegalexd.codempid;
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;  

				  --check numcaselw
					v_chk_exists := 0;
					begin 
					  select 1 into v_chk_exists from tlegalexe      
					  where codempid  = v_tlegalexd.codempid and numcaselw = v_tlegalexd.numcaselw;
					exception when no_data_found then  
					  v_error   := true;
					  v_err_code  := 'HR2010';
					  v_err_field := v_field(2);
					  v_err_table := 'TLEGALEXE';
					  exit cal_loop;
					end;       

                    --check codpay
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tinexinf  
                        where codpay = v_tlegalexd.codpay;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(3);
                        v_err_table := 'TINEXINF';
                        exit cal_loop;
                    end;                      

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
                    begin   
                        delete from tlegalexd where codempid  = v_tlegalexd.codempid  and numcaselw  = v_tlegalexd.numcaselw ;
                        insert into tlegalexd (codempid, numcaselw, codpay, pctded, amtdmin,
														   dtecreate, codcreate, dteupd, coduser)                        
                                          values (v_tlegalexd.codempid, v_tlegalexd.numcaselw, v_tlegalexd.codpay, v_tlegalexd.pctded, v_tlegalexd.amtdmin,
                                                            trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


--PY---------------------------------------------------------------------------------------------------------
  procedure get_process_py_tcoscent (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tcoscent(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end ;

  procedure validate_excel_py_tcoscent (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 6;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 
    v_costcent     tcoscent.costcent%type;
    v_namcente     tcoscent.namcente%type;
    v_namcentt     tcoscent.namcentt%type;
    v_namcent3     tcoscent.namcent3%type;
    v_namcent4     tcoscent.namcent4%type;
    v_namcent5     tcoscent.namcent5%type;    
    vvvv             clob;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len         leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');        
        v_column := param_column.get_size;
        --insert into j values('v_column:'||' => ' || v_column);
        --vvvv := param_json.to_clob;
        --insert into j values('param_json|'||vvvv);
        --vvvv := param_data.to_clob;
        --insert into j values('param_data|'||vvvv);        
        --vvvv := param_column.to_clob;
        --insert into j values('param_column|'||vvvv);  

        --assign chk_len := leng(25, 150, 150, 150, 150, 150);
        for i in 1..v_column loop
            if i in (1) then
                chk_len(i) := 25;            
            else
                chk_len(i) := 150;
            end if;
        end loop;        

        --default transaction success or error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;               

        --read columns name
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
          --insert into j values('v_field:'||i||' => ' || v_field(v_num));
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));            
            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;  

                v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');               
                v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');                
                v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');                
                v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');                
                v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');                
                v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');

                <<cal_loop>> loop            
          --insert into j values('cal loop');
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;
                    --insert into j values('data_file: ' || data_file);

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column 
                        if( i in (1,2,3) and (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            --insert into j values('error require data column');
                            exit cal_loop;
                        end if;

                        --check length all columns   
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;                 

                    end loop;  

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then
                    p_rec_tran := p_rec_tran + 1; 
                    v_costcent   := v_text(1);
                    v_namcente   := v_text(2);
                    v_namcentt   := v_text(3);
                    v_namcent3   := v_text(4);
                    v_namcent4   := v_text(5);
                    v_namcent5   := v_text(6);

                    begin
                        delete from tcoscent where costcent  = v_costcent;
                        insert into tcoscent(costcent, namcente, namcentt, namcent3, namcent4,
                                             namcent5, dtecreate, codcreate, dteupd, coduser)                            
                                      values(v_costcent, v_namcente, v_namcentt, v_namcent3, v_namcent4,
                                             v_namcent5, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser); 
                    end;
                else                    
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i;     

                    --insert into j values('v_error: ' || v_error);                    
                    --insert into j values('p_rec_error:' || p_rec_error);
                    --insert into j values('v_cnt:' || v_cnt);
                    --insert into j values('p_text:' || p_text(v_cnt));                    
                    --insert into j values('p_error_code:' || p_error_code(v_cnt));
                    --insert into j values('p_numseq:' || p_numseq(v_cnt));
                end if;         

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
                --insert into j values('param_msg_error: ' || param_msg_error);
            end;
    end loop;  
  end;  

  procedure get_process_py_taccodb (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_taccodb(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

  procedure validate_excel_py_taccodb (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 6;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;       
  v_codacc     taccodb.codacc%type;
  v_desacce    taccodb.desacce%type;
  v_desacct    taccodb.desacct%type;
  v_desacc3    taccodb.desacc3%type;
  v_desacc4    taccodb.desacc4%type;
  v_desacc5    taccodb.desacc5%type;  

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    begin

      --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');        
        v_column := param_column.get_size;   

        --assign chk_len := leng(25, 150, 150, 150, 150, 150);
        for i in 1..v_column loop
            if i in (1) then
                chk_len(i) := 25;            
            else
                chk_len(i) := 150;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;

        --read columns name             
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));            
            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;   

                v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');               
                v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');                
                v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');                
                v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');                
                v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');                
                v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if( i in (1,2,3) and (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;

                        --check length all columns     
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop;                    

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then
                    p_rec_tran := p_rec_tran + 1; 
                    v_codacc  := v_text(1);
                    v_desacce   := v_text(2);
                    v_desacct   := v_text(3);
                    v_desacc3   := v_text(4);
                    v_desacc4   := v_text(5);
                    v_desacc5   := v_text(6);

                    begin
            delete from taccodb where codacc  = v_codacc;
                        insert into taccodb(codacc, desacce, desacct, desacc3, desacc4,
                      desacc5, dtecreate, codcreate, dteupd, coduser)
                   values(v_codacc, v_desacce, v_desacct, v_desacc3, v_desacc4,
                      v_desacc5, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                    end;
                else                    
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i;
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  
  end;  


  procedure get_process_py_tempinc (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tempinc(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

 procedure validate_excel_py_tempinc (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;       
  v_codempid     tempinc.codempid%type;
  v_codpay     tempinc.codpay%type;
  v_dtestrt    tempinc.dtestrt%type;
  v_dteend     tempinc.dteend%type;
  v_dtecancl     tempinc.dtecancl%type;
  v_amtfix     tempinc.amtfix%type;
  v_periodpay    tempinc.periodpay%type;
  v_flgprort     tempinc.flgprort%type; 

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

   v_chk_emp        number;
   v_chk_codpay     number;
   v_chk_period_pay number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10, 4, 10, 10, 10, 12, 1, 1);
        for i in 1..v_column loop
            if i in (1) then
                chk_len(i) := 10;
            elsif i in (2) then
                chk_len(i) := 4;
      elsif i in (3,4,5) then
                chk_len(i) := 10;
      elsif i in (6) then
                chk_len(i) := 12;
            else
                chk_len(i) := 1;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    --check require data column 
                    for i in 1..v_column loop
                        if( i in (1,2,3,6,7,8) and (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;

                        --check length all columns       
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
                            if length(v_text(i)) > chk_len(i) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;
                    end loop;                    

                    --check incorrect data      
                    --check employee in temploy1
                    v_chk_emp := 0;
                    begin 
                        select 1 into v_chk_emp from temploy1 
                        where codempid = v_text(1);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;

                    --check codpay in tinexinf
                    v_chk_codpay := 0;
                    begin 
                        select 1 into v_chk_codpay from tinexinf 
                        where codpay = v_text(2);
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(2);
                        v_err_table := 'TINEXINF';
                        exit cal_loop;
                    end;

                    --check date format
                    for i in 3..5 loop
                        if (v_text(i) is not null) then
                            if(check_date(v_text(i))) then                         
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;  
                        end if;
                    end loop;   

                     --check dtecancl must > dtestrt
                    if(v_text(5) is not null and (check_dteyre(v_text(5)) < check_dteyre(v_text(3)))) then
                        v_error   := true;
                        v_err_code  := 'PY0013';
                        v_err_field := v_field(5);
                        exit cal_loop;                    
                    end if;

                     --check dtecancl must <= dteend
                    if(v_text(5) is not null and v_text(4) is not null and (check_dteyre(v_text(5)) > check_dteyre(v_text(4)))) then
                        v_error   := true;
                        v_err_code  := 'PY0014';
                        v_err_field := v_field(5);
                        exit cal_loop;                    
                    end if;

                    --check amtfix >= 0
                    if(to_number(v_text(6)) < 0) then
                        v_error   := true;
                        v_err_code  := 'HR2023';
                        v_err_field := v_field(6);
                        exit cal_loop;                    
                    end if;

                    --check periodpay in tdtepay
                    /*
                    v_chk_period_pay := 0;
                    begin 
                        select 1 into v_chk_period_pay from tdtepay 
                        where dtestrt = check_dteyre(v_text(3)) and v_text(7) = numperiod and rownum = 1;
                    exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(7);
                        v_err_table := 'TDTEPAY';
                        exit cal_loop;                       
                    end;
                    */

                    --check flgport 
                    if(upper(v_text(8)) not in ('Y','N'))then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(8);
                        exit cal_loop;
                    end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then     
                                    p_rec_tran := p_rec_tran + 1; 
          v_codempid  := v_text(1); 
          v_codpay    := v_text(2);
          v_dtestrt   := check_dteyre(v_text(3));                     
                    if v_text(4) is not null  or length(trim(v_text(4))) is not null  then                    
                        v_dteend    := check_dteyre(v_text(4));      
                    else     
                        v_dteend    := null;
                    end if;
                    if v_text(5) is not null  or length(trim(v_text(5))) is not null  then                    
                        v_dtecancl    := check_dteyre(v_text(5));

                        if v_dtecancl < sysdate then
                            continue;
                        end if;
                   else     
                        v_dtecancl    := null;
                    end if;
          v_amtfix    := to_number(v_text(6));
                    --insert into j values('v_amtfix: ' || v_amtfix);
                    --insert into j values('stdenc: ' || stdenc(v_amtfix,v_codempid,v_chken));
          v_periodpay := v_text(7);
          v_flgprort  := upper(v_text(8));

                    begin 
            delete from tempinc where codempid  = v_codempid and codpay = v_codpay and dtestrt = v_dtestrt;
                        insert into tempinc (codempid, codpay, dtestrt, dteend, dtecancl, amtfix, 
                                                     periodpay, flgprort, dtecreate, codcreate, dteupd, coduser)                        
                                         values (v_codempid, v_codpay, v_dtestrt, v_dteend, v_dtecancl, stdenc(v_amtfix, v_codempid, v_chken),
                                                     v_periodpay, v_flgprort, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

    procedure get_process_py_tempded (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tempded(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


 procedure validate_excel_py_tempded (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 40;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;  
  v_codempid     tempded.codempid%type;
  v_coddeduct    tempded.coddeduct%type;
  v_amtdeduct    tempded.amtdeduct%type;
  v_amtspded     tempded.amtspded%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

  type coddeduct is table of varchar2(4 char) index by binary_integer;
  arr_coddeduct    coddeduct;--เก็บรหัสลดหย่อน ตัวที่1-40

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_emp               number;
    v_chk_coddeduct     number;   

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10, 12, .. , 12);
        for i in 1..v_column loop 
            if i in (1) then
                chk_len(i) := 10;            
            else
                chk_len(i) := 12;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
          v_text(i) := null;
          arr_coddeduct(i) := null;
        end loop;                

        --read columns name       
        for i in 1..v_column loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i-1));
          --v_num             := v_num + 1;
          v_field(i)    := hcm_util.get_string_t(param_column_row,'name');

          --keep array coddeduct
            arr_coddeduct(i)  := hcm_util.get_string_t(param_column_row,'value');

        end loop;    

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        --keep amount deduct
        for i in 2..v_column loop
           v_text(i) := hcm_util.get_string_t(param_json_row,'col-' || to_char(i));
        end loop;

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;    

                    --1.validate --           
                    --check require data column 
                    for i in 1..2 loop
                        if( (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;
                    end loop;

                    --check length all columns
                    --chk_len:= leng(10, 12, ..., 12);                   
                    for i in 1..v_column loop
                        if( (v_text(i) is not null)  or ( length(trim(v_text(i))) is not null ) ) then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;  
                        end if;
                    end loop;                    

                    --check incorrect data      
                    --check employee in temploy1
                    v_chk_emp := 0;
                    begin 
                        select 1 into v_chk_emp from temploy1 
                        where codempid = v_text(1);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;

                    --check coddeduct in tcodeduct
                    v_chk_coddeduct := 0;
                    for i in 2..v_column loop
                        if ( (arr_coddeduct(i) is not null)  or ( length(trim(arr_coddeduct(i))) is not null ) )   then
                            begin 
                                select 1 into v_chk_coddeduct from tcodeduct 
                                where coddeduct = arr_coddeduct(i);
                            exception when no_data_found then 
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := arr_coddeduct(i);
                                v_err_table := 'TCODEDUCT ';
                                exit cal_loop;
                            end;
                        end if;
                    end loop;  

                    --check amtdeduct >= 0
                    for i in 2..v_column loop
                        if ( (v_text(i) is not null)  or ( length(trim(v_text(i))) is not null ) )   then
                            if(to_number(v_text(i)) < 0) then
                                v_error   := true;
                                v_err_code  := 'HR2023';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;
                       end if;
                    end loop;   

                    exit cal_loop;
                end loop;


                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_codempid  := v_text(1);           
          delete from tempded where codempid  = v_codempid and amtspded = stdenc(0, v_codempid, v_chken) ;

           for i in 2..v_column loop
                         if ( (arr_coddeduct(i) is not null)  or ( length(trim(arr_coddeduct(i))) is not null ) )  then 

                             v_coddeduct := arr_coddeduct(i);
                             v_amtdeduct    := to_number(nvl(v_text(i), 0));
                            --insert into j values('v_amtdeduct: ' || v_amtdeduct);
                            --insert into j values('stdenc: ' || stdenc(v_amtdeduct,v_codempid,v_chken));

                            if v_amtdeduct > 0 then 
                                begin   
                                    insert into tempded (codempid, coddeduct, amtdeduct, amtspded, dtecreate, codcreate, dteupd, coduser)                        
                                                        values (v_codempid, v_coddeduct, stdenc(v_amtdeduct, v_codempid, v_chken), stdenc(0, v_codempid, v_chken), 
                                                                     trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                                     --insert into j values ('insert: coddeduct=> ' || v_coddeduct || ' , v_amtdeduct=> ' || v_amtdeduct);                
                                exception when dup_val_on_index  then
                                    update tempded set amtdeduct = stdenc(v_amtdeduct, v_codempid, v_chken) , dteupd =  trunc(sysdate), coduser = global_v_coduser
                                                          where codempid  = v_codempid and coddeduct = v_coddeduct ;
                                    --insert into j values ('update: coddeduct=> ' || v_coddeduct || ' , v_amtdeduct=> ' || v_amtdeduct);
                                end;
                            end if;
                        end if;
                    end loop;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;

            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;  

    procedure get_process_py_tempded_sp (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tempded_sp(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


 procedure validate_excel_py_tempded_sp (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 40;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;  
  v_codempid     tempded.codempid%type;
  v_coddeduct    tempded.coddeduct%type;
  v_amtdeduct    tempded.amtdeduct%type;
  v_amtspded     tempded.amtspded%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

  type coddeduct is table of varchar2(4 char) index by binary_integer;
  arr_coddeduct    coddeduct;--เก็บรหัสลดหย่อน ตัวที่1-40

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_emp               number;
    v_chk_coddeduct     number;   

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10, 12, .. , 12);
        for i in 1..v_column loop 
            if i in (1) then
                chk_len(i) := 10;            
            else
                chk_len(i) := 12;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
      v_text(i) := null;
          arr_coddeduct(i) := null;
        end loop;                

        --read columns name       
        for i in 1..v_column loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i-1));
          --v_num             := v_num + 1;
          v_field(i)    := hcm_util.get_string_t(param_column_row,'name');

      --keep array coddeduct
      arr_coddeduct(i)  := hcm_util.get_string_t(param_column_row,'value');

        end loop;                 

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');

        --keep amount deduct
        for i in 2..v_column loop
          v_text(i) := hcm_util.get_string_t(param_json_row,'col-' || to_char(i));                    
        end loop;

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;    

                    --1.validate --           
                    --check require data column 
                    for i in 1..2 loop
                        if( (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;
                    end loop;

                    --check length all columns
                    --chk_len:= leng(10, 12, ..., 12);                   
                    for i in 1..v_column loop
                        if( (v_text(i) is not null)  or ( length(trim(v_text(i))) is not null ) ) then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;  
                        end if;
                    end loop;                    

                    --check incorrect data      
                    --check employee in temploy1
                    v_chk_emp := 0;
                    begin 
                        select 1 into v_chk_emp from temploy1 
                        where codempid = v_text(1);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;

                    --check coddeduct in tcodeduct
                    v_chk_coddeduct := 0;
                    for i in 2..v_column loop
                        if ( (arr_coddeduct(i) is not null)  or ( length(trim(arr_coddeduct(i))) is not null ) )   then
                            begin 
                                select 1 into v_chk_coddeduct from tcodeduct 
                                where coddeduct = arr_coddeduct(i);
                            exception when no_data_found then 
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := arr_coddeduct(i);
                                v_err_table := 'TCODEDUCT ';
                                exit cal_loop;
                            end;
                        end if;
                    end loop;  

                    --check amtspded >= 0
                    for i in 2..v_column loop
                        if ( (v_text(i) is not null)  or ( length(trim(v_text(i))) is not null ) )   then
                            if(to_number(v_text(i)) < 0) then
                                v_error   := true;
                                v_err_code  := 'HR2023';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;
                       end if;
                    end loop;   

                    exit cal_loop;
                end loop;


                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 
          v_codempid  := v_text(1);           
          delete from tempded where codempid  = v_codempid and amtdeduct = stdenc(0, v_codempid, v_chken) ;

           for i in 2..v_column loop
                         if ( (arr_coddeduct(i) is not null)  or ( length(trim(arr_coddeduct(i))) is not null ) )  then                          
                             v_coddeduct := arr_coddeduct(i);
                             v_amtspded     := to_number(nvl(v_text(i), 0));

                            if v_amtspded > 0 then 
                                begin   
                                    insert into tempded (codempid, coddeduct, amtdeduct, amtspded, dtecreate, codcreate, dteupd, coduser)                        
                                                        values (v_codempid, v_coddeduct, stdenc(0, v_codempid, v_chken), stdenc(v_amtspded, v_codempid, v_chken), 
                                                                     trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                                    -- insert into j values ('insert: coddeduct=> ' || v_coddeduct || ' , v_amtspded=> ' || v_amtspded);                
                                exception when dup_val_on_index  then
                                    update tempded set amtspded = stdenc(v_amtspded, v_codempid, v_chken), dteupd =  trunc(sysdate), coduser = global_v_coduser
                                                          where codempid  = v_codempid and coddeduct = v_coddeduct ;
                                   -- insert into j values ('update: coddeduct=> ' || v_coddeduct || ' , v_amtspded=> ' || v_amtspded);
                                end;
                            end if;
                        end if;
                    end loop;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                  --  insert into j values(p_error_code(v_cnt));
                end if;            

                commit;

            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
                  --  insert into j values(param_msg_error);
            end;
    end loop;  

  end;  

    procedure get_process_py_tinexinf (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tinexinf(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;

 procedure validate_excel_py_tinexinf (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 40;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;  
  v_codpay         tinexinf.codpay%type;
    v_descpaye       tinexinf.descpaye%type;
    v_descpayt       tinexinf.descpayt%type;
    v_descpay3       tinexinf.descpay3%type;
    v_descpay4       tinexinf.descpay4%type;
    v_descpay5       tinexinf.descpay5%type;
    v_typpay         tinexinf.typpay%type;
    v_flgtax         tinexinf.flgtax%type;
    v_flgfml         tinexinf.flgfml%type;
    v_flgpvdf        tinexinf.flgpvdf%type;
    v_flgwork        tinexinf.flgwork%type;
    v_flgsoc         tinexinf.flgsoc%type;
    v_flgcal         tinexinf.flgcal%type;
    v_flgform        tinexinf.flgform%type;
    v_typinc         tinexinf.typinc%type;
    v_typpayr        tinexinf.typpayr%type;
    v_typpayt        tinexinf.typpayt%type;
    v_grppay         tinexinf.grppay%type;
    v_typincpnd      tinexinf.typincpnd%type;
    v_typincpnd50    tinexinf.typincpnd50%type;
    v_codtax         ttaxtab.codtax%type;

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_in               number;               

    begin

     --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        for i in 1..v_column loop
           if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');
                v_text(9)  := hcm_util.get_string_t(param_json_row,'col-9');
                v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
                v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
                v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
                v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
                v_text(14)   := hcm_util.get_string_t(param_json_row,'col-14');
                v_text(15)   := hcm_util.get_string_t(param_json_row,'col-15');
                v_text(16)   := hcm_util.get_string_t(param_json_row,'col-16');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column 
                        if( i in (1,2,3,4,6,10,11,12,13,14,15) and (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;

                        --check length all columns
                        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                        if (((v_text(i) is not null) or length(trim(v_text(i))) is not null )  and (length(v_text(i)) > chk_len(i))) then
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);                                
                                exit cal_loop;
                        end if;   
                    end loop;                    

                    --check incorrect data      
                    --check typpay must be 1-7 
                    if(upper(v_text(4)) not in ('1','2','3','4','5','6','7'))then
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(4);
                        exit cal_loop;
                    end if;

                    --check typinc in tcodrevn
                    if v_text(5) is not null or length(trim(v_text(5))) is not null then
                        v_chk_in := 0;                       
                        begin 
                            select 1 into v_chk_in from tcodrevn 
                            where codcodec = v_text(5);
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(5);
                            v_err_table := 'TCODREVN';
                            exit cal_loop;
                        end;  
                     end if;   

                    --check typpayr in tcodslip
                    v_chk_in := 0;
                    begin 
                        select 1 into v_chk_in from tcodslip 
                        where codcodec = v_text(6);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(6);
                        v_err_table := 'TCODSLIP';
                        exit cal_loop;
                    end;

                    --check typpayt in tcodcert                   
                    if v_text(7) is not null or length(trim(v_text(7))) is not null then
                        v_chk_in := 0;
                        begin 
                            select 1 into v_chk_in from tcodcert 
                            where codcodec = v_text(7);
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(7);
                            v_err_table := 'TCODCERT';
                            exit cal_loop;
                        end;          
                    end if;    

                    --check typincpnd in tcodrevn
                    if v_text(8) is not null or length(trim(v_text(8))) is not null then
                        v_chk_in := 0;                    
                        begin 
                            select 1 into v_chk_in from tcodrevn 
                            where codcodec = v_text(8);
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(8);
                            v_err_table := 'TCODREVN';
                            exit cal_loop;
                        end;
                     end if;   

                    --check typincpnd50 in tcodcert
                    if v_text(9) is not null or length(trim(v_text(9))) is not null then
                        v_chk_in := 0;
                        begin 
                            select 1 into v_chk_in from tcodcert 
                            where codcodec = v_text(9);
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(9);
                            v_err_table := 'TCODCERT';
                            exit cal_loop;
                        end;  
                    end if;    

                    --check flgcal, flgsoc, flgwork, flgpvdf must be Y,N
                    for i in 10..14 loop
                        if (i <> 12) then
                            if( upper(v_text(i)) not in ('Y','N')) then                         
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;  
                        end if;
                    end loop;   

                    --check flgtax must be 1-2
                    if(v_text(12) not in ('1','2')) then                         
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(12);
                        exit cal_loop;                    
                    end if; 

                    --check flgfml must be 1-10
                    if(v_text(15) not in ('1','2','3','4','5','6','7','8','9','10')) then                         
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(15);
                        exit cal_loop;                    
                    end if;    

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then    
                    p_rec_tran := p_rec_tran + 1; 
                    v_codpay         := v_text(1);
                    v_descpaye      := v_text(2); 
                    v_descpayt       := v_text(3); 
                    v_descpay3      := v_descpay3; 
                    v_descpay4      := v_descpay3;
                    v_descpay5      := v_descpay3; 
                    v_typpay          := v_text(4); 
                    v_typinc           := v_text(5); 
                    v_typpayr         := v_text(6); 
                    v_typpayt         := v_text(7); 
                    v_typincpnd      := v_text(8);  
                    v_typincpnd50   := v_text(9); 
                    v_flgcal             := upper(v_text(10)); 
                    v_flgsoc            := upper(v_text(11));
                    v_flgtax            := v_text(12);
                    v_flgwork          := upper(v_text(13));
                    v_flgpvdf           := upper(v_text(14)); 
                    v_flgfml            := v_text(15); 
                    v_flgform          := 'N';
                    v_grppay           := null;
                    if v_typpay in ('1', '2', '3')  then 
                        v_grppay := '1';
                    elsif v_typpay in ('4', '5') then
                        v_grppay := '2';
                    elsif  v_typpay in ('7') then
                        v_grppay := '3';
                    end if;
                    v_codtax            := v_text(16); 

                    begin 
            delete from tinexinf where codpay = v_codpay;
                        insert into tinexinf (  codpay, descpaye, descpayt, descpay3, descpay4, descpay5, 
                                                        typpay, flgtax, flgfml, flgpvdf, flgwork, flgsoc,
                                                        flgcal, flgform, typinc, typpayr, typpayt, grppay, 
                                                        typincpnd, typincpnd50, dtecreate, codcreate, dteupd, coduser)                       
                                           values (v_codpay, v_descpaye,  v_descpayt, v_descpaye,   v_descpaye, v_descpaye, 
                                                         v_typpay, v_flgtax, v_flgfml, v_flgpvdf, v_flgwork, v_flgsoc,                        
                                                         v_flgcal, v_flgform, v_typinc, v_typpayr, v_typpayt, v_grppay, 
                                                         v_typincpnd, v_typincpnd50,  trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

                          if  v_codtax is not null then
                                begin 
                                        delete from ttaxtab where codpay = v_codpay;
                                        insert into ttaxtab ( codpay, codtax, dtecreate, codcreate, dteupd, coduser)
                                                          values ( v_codpay, v_codtax, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                                end;
                         end if;
                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                 --   insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
               --   insert into j values(param_msg_error);
            end;
    end loop;  

    end;

    procedure get_process_py_tpfmemb (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tpfmemb(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


 procedure validate_excel_py_tpfmemb (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 40;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;  
    v_codempid     tpfmemb.codempid%type;
    v_nummember    tpfmemb.nummember%type;
    v_dteeffec     tpfmemb.dteeffec%type;
    v_codpfinf     tpfmemb.codpfinf%type;
    v_codplan    	tpfmemb.codplan%type;
    v_dteeffecp    tpfirinf.dteeffec%type;
    v_flgemp     	tpfmemb.flgemp%type;
    v_dtereti    	tpfmemb.dtereti%type;
    v_codreti    	tpfmemb.codreti%type;
    v_amtcaccu     tpfmemb.amtcaccu%type;
    v_amtcretn     tpfmemb.amtcretn%type;
    v_amteaccu     tpfmemb.amteaccu%type;
    v_amteretn     tpfmemb.amteretn%type;
    v_amtinteccu     tpfmemb.amtinteccu%type;
    v_amtintaccu     tpfmemb.amtintaccu%type;
    v_flgconded    tpfmemb.flgconded%type;
    v_tpfmemb_rateeret       tpfmemb.rateeret%type;
    v_tpfmemb_ratecret       tpfmemb.ratecret%type;
    v_dtecal     	tpfmemb.dtecal%type;
    v_typpayroll     tpfmemb.typpayroll%type;
    v_qtywken       tpfmemb.qtywken%type;
    v_flgdpvf    	tpfmemrt.flgdpvf%type; 
    v_tpfmemrt_ratecret    tpfmemrt.ratecret%type;
    v_tpfmemrt_ratecsbt    tpfmemrt.ratecsbt%type;    
    v_tpfdinf_ratecsbt    tpfdinf.ratecsbt%type;
    v_tpfdinf_rateesbt    tpfdinf.rateesbt%type;
    v_codcompy      		tpfdinf.codcompy%type;      
    v_dteempmt          temploy1.dteempmt%type;
	v_tpfcinf_ratecsbt		tpfcinf.ratecsbt%type;
	v_tpfeinf_numseq		tpfeinf.numseq%type;
    v_tpfeinf_flgconded		tpfeinf.flgconded%type;
	v_cond				varchar2(1000);
    v_stmt				varchar2(1000);
	v_chk_in               number;    
    v_flgfound	  boolean;
    temploy1_codempid	temploy1.codempid%type; 
	temploy1_codcomp 	temploy1.codcomp%type; 
	temploy1_codpos 	temploy1.codpos%type; 
	temploy1_typemp 	temploy1.typemp%type; 
	temploy1_codempmt 	temploy1.codempmt%type; 
	temploy1_typpayroll temploy1.typpayroll%type; 
	temploy1_staemp		temploy1.staemp%type; 
	temploy1_dteempmt 	temploy1.dteempmt%type; 
	temploy1_numlvl 	temploy1.numlvl%type; 
	temploy1_jobgrade	temploy1.jobgrade%type; 

    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

	cursor c_tpfeinf is --สาหรับเก็บเงื่อนไขของกองทุน
		select numseq, syncond, flgconded
		  from tpfeinf t
		 where t.codcompy = v_codcompy
		   and trunc(t.dteeffec) = (select max(dteeffec)
									from tpfeinf
									where codcompy = v_codcompy
										and dteeffec <= trunc(sysdate))
		order by numseq;

    begin

		--read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len:= leng(10, 10, 10, 4, 4, 1, 10, 4, 17, 17, 17, 17, 17, 17, 1, 1, 5); 
        for i in 1..v_column loop
           if i in (1, 2, 3, 7) then
                chk_len(i) := 10;
            elsif i in (6, 15) then
                chk_len(i) := 1;
            elsif i in (4, 5, 8) then
                chk_len(i) := 4;
            elsif i in (16) then
                chk_len(i) := 6;
            else
                chk_len(i) := 17;
            end if;
        end loop;        

        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');
                v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');
                v_text(9)  	:= hcm_util.get_string_t(param_json_row,'col-9');
                v_text(10)  := hcm_util.get_string_t(param_json_row,'col-10');
                v_text(11)  := hcm_util.get_string_t(param_json_row,'col-11');
                v_text(12)  := hcm_util.get_string_t(param_json_row,'col-12');
                v_text(13)  := hcm_util.get_string_t(param_json_row,'col-13');
                v_text(14)  := hcm_util.get_string_t(param_json_row,'col-14');
                v_text(15)  := hcm_util.get_string_t(param_json_row,'col-15');
                v_text(16)  := hcm_util.get_string_t(param_json_row,'col-16');


                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --           
                    for i in 1..v_column loop
                        --check require data column 
                        if( i in (1,2,3,4,5,6,15) and (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;

                        --check length all columns
                        --chk_len:= leng(10, 10, 10, 4, 4, 1, 10, 4, 17, 17, 17, 17, 17, 17, 1, 1, 5);    
                        if (((v_text(i) is not null) or length(trim(v_text(i))) is not null ) and (length(v_text(i)) > chk_len(i))) then
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);                                
                                exit cal_loop;
                        end if;   
                    end loop;                    

                    --check incorrect data                         
                    --check employee in temploy1
                    v_chk_in := 0;
					v_dteempmt := null;

                    begin 	
                        select 1,dteempmt, codcomp, typpayroll, months_between(sysdate, dteempmt) , codempid, codcomp, codpos, typemp, codempmt, typpayroll, staemp, dteempmt, numlvl, jobgrade  
							into v_chk_in, v_dteempmt, v_codcomp, v_typpayroll, v_qtywken, temploy1_codempid, temploy1_codcomp, temploy1_codpos, temploy1_typemp, temploy1_codempmt, temploy1_typpayroll, temploy1_staemp, temploy1_dteempmt, temploy1_numlvl, temploy1_jobgrade 
						from temploy1 
                        where codempid = v_text(1);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;

                    --check dteeffec must >= dteempmt
                    if (check_dteyre(v_text(3)) < v_dteempmt)  then
                        v_error   := true;
                        v_err_code  := 'PY0016'; 
                        v_err_field := v_field(3);
                        exit cal_loop;
                    end if;

                    --check codpfinf in tcodpfinf
                    v_chk_in := 0;
                    begin 
                        select 1 into v_chk_in from tcodpfinf 
                        where codcodec = v_text(4);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(4);
                        v_err_table := 'TCODPFINF';
                        exit cal_loop;
                    end;    

                    --check codplan in tcodpfpln
                    v_chk_in := 0;
                    begin 
                        select 1 into v_chk_in from tcodpfpln 
                        where codcodec = v_text(5);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(5);
                        v_err_table := 'TCODPFPLN';
                        exit cal_loop;
                    end;   

					--check flgemp must be 1-2
                    if(v_text(6) not in ('1','2')) then                         
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(7);
                        exit cal_loop;                    
                    end if; 

					--check dtereti, codreti must require if flgemp be 2
					if (v_text(6) = '2') then
						if(((v_text(7) is null) or length(trim(v_text(7))) is null)) then                         
						  v_error   := true;
						  v_err_code  := 'HR2045';
						  v_err_field := v_field(7);
						  exit cal_loop;                    
						end if; 
						if(((v_text(8) is null) or length(trim(v_text(8))) is null)) then                         
						  v_error   := true;
						  v_err_code  := 'HR2045';
						  v_err_field := v_field(8);
						  exit cal_loop;                    
						end if;		
					end if;		

					--check dtereti must >= dteeffec
					if (((v_text(7) is not null) or length(trim(v_text(7))) is not null)) then
						if (check_dteyre(v_text(7)) < check_dteyre(v_text(3))) then
						  v_error   := true;
						  v_err_code  := 'PY0017'; 
						  v_err_field := v_field(7);
						  exit cal_loop;
						end if;
					end if;

					--check codreti in tcodexem
                    v_chk_in := 0;
                    if (((v_text(8) is not null) or length(trim(v_text(8))) is not null)) then
                        begin 
                            select 1 into v_chk_in from tcodexem 
                            where codcodec = v_text(8);
                        exception when no_data_found then  
                            v_error   := true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(8);
                            v_err_table := 'TCODEXEM';
                            exit cal_loop;
                        end; 
                    end if;

					--check amtcaccu, amtcretn, amteaccu, amteretn, amtinteccu, amtintaccu must >= 0
                    for i in 9..14 loop
                        if (((v_text(i) is not null) or length(trim(v_text(i))) is not null)) then
                            if( to_number(v_text(i)) < 0) then                         
                                v_error   := true;
                                v_err_code  := 'HR2023';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;  
                        end if;
                    end loop;           

                    --check flgdpvf must be 1-2                   
                    if(v_text(15) not in ('1','2')) then                         
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(15);
                        exit cal_loop;                    
                    end if; 

					--check ratecret must require if flgdpvf be 2
					if (v_text(15) = '2') then
						if(((v_text(16) is null) or length(trim(v_text(16))) is null)) then                         
						  v_error   := true;
						  v_err_code  := 'HR2045';
						  v_err_field := v_field(16);
						  exit cal_loop;                    
						end if;  
					end if;

					v_codcompy := hcm_util.get_codcomp_level(v_codcomp,1);

					--find tpfeinf_numseq
					v_chk_in := 0;
					for r2 in c_tpfeinf loop		

						if r2.syncond is not null then	

							v_cond := r2.syncond;
							v_cond := replace(v_cond,'V_TEMPLOY.CODEMPID',''''||temploy1_codempid||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.CODCOMP',''''||temploy1_codcomp||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.CODPOS',''''||temploy1_codpos||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.TYPEMP',''''||temploy1_typemp||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.CODEMPMT',''''||temploy1_codempmt||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.TYPPAYROLL',''''||temploy1_typpayroll||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.STAEMP',''''||temploy1_staemp||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.DTEEMPMT'  ,'to_date('''||to_char(temploy1_dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
							--v_cond := replace(v_cond,'V_TEMPLOY.QTYWORK',v_qtywork);
							--v_cond := replace(v_cond,'V_TEMPLOY.AGES',v_ages);
							v_cond := replace(v_cond,'V_TEMPLOY.NUMLVL',''''||temploy1_numlvl||'''');
							v_cond := replace(v_cond,'V_TEMPLOY.JOBGRADE',''''||temploy1_jobgrade||'''');
							--v_cond := replace(v_cond,'TPFMEMB.CODPFINF',''''||r_tpfmemb.codpfinf||'''');
							v_stmt := 'select count(*) from dual where '||v_cond;
							v_flgfound := execute_stmt(v_stmt);

						end if;

						if v_flgfound then
							v_tpfeinf_numseq 	:= r2.numseq;
							v_tpfeinf_flgconded := r2.flgconded; 
							v_chk_in			:= 1;
							exit;				
						end if;

					end loop;		

					--check not found tpfeinf
					if v_chk_in = 0 then 
						v_error   := true;
						v_err_code  := 'HR2010';
						v_err_field := 'FLGCONDED';
						v_err_table := 'TPFEINF';			
						exit cal_loop;	
					end if;

					if v_tpfeinf_flgconded = '1' then
						begin 
                            select  months_between(sysdate, check_dteyre(v_text(3)))  into v_qtywken from dual;
                        exception when no_data_found then
                            null;
                        end; 
					end if;

					--do here if flgdpvf be 1 - policy
					if (v_text(15) = '1') then
						--find tpfmemrt.ratecsbt, tpfmemrt.rateesbt with policy 
						begin
						  select ratecsbt, rateesbt
							 into v_tpfdinf_ratecsbt, v_tpfdinf_rateesbt
						  from tpfdinf t
						  where t.codcompy  = v_codcompy
							 and v_qtywken between t.qtywkst and t.qtywken
							 and t.numseq   =  v_tpfeinf_numseq   
							 and t.dteeffec   = (select max(dteeffec)
														from tpfdinf
													  where codcompy = v_codcompy
														  and v_qtywken between qtywkst and qtywken
														  and numseq   =  v_tpfeinf_numseq );
						exception when no_data_found then
							v_error   := true;
							v_err_code  := 'HR2010';
							v_err_field := 'CODCOMPY';
							v_err_table := 'TPFDINF';
							exit cal_loop;
						end;  					
					end if;

					--find tpfmemb.ratecsbt with policy 
					begin
					  select ratecsbt
						 into v_tpfcinf_ratecsbt
					  from tpfcinf t
					  where t.codcompy  = v_codcompy
						 and v_qtywken between t.qtyyrst and t.qtyyren    
						 and t.numseq   =  v_tpfeinf_numseq   
						 and t.dteeffec   = (select max(dteeffec)
													from tpfcinf
												  where codcompy = v_codcompy
													  and v_qtywken between qtyyrst and qtyyren
													  and numseq   =  v_tpfeinf_numseq );
					exception when no_data_found then
						v_error   := true;
						v_err_code  := 'HR2010';
						v_err_field := 'CODCOMPY';
						v_err_table := 'TPFCINF';
						exit cal_loop;
					end;  

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then    
                    p_rec_tran := p_rec_tran + 1; 
					v_codempid    := v_text(1);
					v_nummember     := v_text(2); 
					v_dteeffec    := check_dteyre(v_text(3));
					v_codpfinf    := v_text(4);
					v_codplan     := v_text(5);
					v_flgemp      := v_text(6);

                    if v_flgemp <> 1 then
                        continue;
                    end if;

					  v_dtereti     := null;
					  if (((v_text(7) is not null) or length(trim(v_text(7))) is not null)) then
						v_dtereti  := check_dteyre(v_text(7));
					  end if;
					  v_codreti     := null;
					  if (((v_text(8) is not null) or length(trim(v_text(8))) is not null)) then
						v_codreti  := v_text(8);
					  end if;
					  v_amtcaccu    := 0;
					  if (((v_text(9) is not null) or length(trim(v_text(9))) is not null)) then
						v_amtcaccu  := to_number(v_text(9));
					  end if;
					  v_amtcretn    := 0;
					  if (((v_text(10) is not null) or length(trim(v_text(10))) is not null)) then
						v_amtcretn  := to_number(v_text(10));
					  end if;
					  v_amteaccu    := 0;
					  if (((v_text(11) is not null) or length(trim(v_text(11))) is not null)) then
						v_amteaccu  := to_number(v_text(11));
					  end if;
					  v_amteretn    := 0;
					  if (((v_text(12) is not null) or length(trim(v_text(12))) is not null)) then
						v_amteretn  := to_number(v_text(12));
					  end if;
					  v_amtinteccu    := 0;
					  if (((v_text(13) is not null) or length(trim(v_text(13))) is not null)) then
						v_amtinteccu  := to_number(v_text(13));
					  end if;
					  v_amtintaccu    := 0;
					  if (((v_text(14) is not null) or length(trim(v_text(14))) is not null)) then
						v_amtintaccu  := to_number(v_text(14));
					  end if;

					  v_flgconded     		:= v_tpfeinf_flgconded;                    
					  v_flgdpvf   			:= v_text(15);              
					  v_tpfmemrt_ratecret   := to_number(v_text(16));

					v_dtecal    := null;
                    v_tpfmemb_rateeret  := 100;
                    v_tpfmemb_ratecret  := v_tpfcinf_ratecsbt;              

                     --case policy        
                    if v_flgdpvf = '1' then
                        v_tpfmemrt_ratecret  := v_tpfdinf_rateesbt;					
                    end if;

                    v_tpfmemrt_ratecsbt :=  v_tpfdinf_ratecsbt;                

                    begin 
            delete from tpfmemb where codempid = v_codempid;
                        insert into tpfmemb (codempid, dteeffec, flgemp, nummember, codpfinf, codplan,
                       dtereti, codreti, amtcaccu, amtcretn, amteaccu, amteretn,
                       amtinteccu, amtintaccu, dtecal, codcomp, typpayroll, rateeret,
                       ratecret, qtywken, flgconded, dtecreate, codcreate, dteupd, coduser)                       
                                     values (v_codempid, v_dteeffec, v_flgemp, v_nummember, v_codpfinf, v_codplan,
                                                 v_dtereti, v_codreti, stdenc(v_amtcaccu, v_codempid, v_chken), stdenc(v_amtcretn, v_codempid, v_chken),  stdenc(v_amteaccu, v_codempid, v_chken), stdenc(v_amteretn, v_codempid, v_chken),
                           stdenc(v_amtinteccu, v_codempid, v_chken), stdenc(v_amtintaccu, v_codempid, v_chken), v_dtecal, v_codcomp, v_typpayroll, v_tpfmemb_rateeret,
                                                 v_tpfmemb_ratecret, v_qtywken, v_flgconded, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);


            delete from tpfmemrt where codempid  = v_codempid and dteeffec = v_dteeffec;   
                        insert into  tpfmemrt (codempid, dteeffec, flgdpvf, ratecret, ratecsbt,
                                                        dtecreate, codcreate, dteupd, coduser)
                                            values (v_codempid, v_dteeffec, v_flgdpvf, v_tpfmemrt_ratecret, v_tpfmemrt_ratecsbt, 
                                                        trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

                        delete from tpfirinf where codempid  = v_codempid and dteeffec = v_dteeffec and codplan = v_codplan;
                        insert into tpfirinf (codempid, dteeffec, codplan, codpfinf,
                                                    dtecreate, codcreate, dteupd, coduser)
                                      values (v_codempid, v_dteeffec, v_codplan, v_codpfinf, 
                                                    trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);      


                       --  insert into j values('success');

                    end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                  --  insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
              --  insert into j values(param_msg_error);
            end;

    end loop;          

    end;   


    procedure get_process_py_tsincexp (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_py_tsincexp(json_str_input, p_rec_tran, p_rec_err);
      json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


 procedure validate_excel_py_tsincexp (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 40;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0;  
    --tsincexp
    v_codempid        tsincexp.codempid%type;
    v_dteyrepay   tsincexp.dteyrepay%type;
    v_dtemthpay   tsincexp.dtemthpay%type;
    v_numperiod   tsincexp.numperiod%type;
    v_codpay        tsincexp.codpay%type;
    v_codcomp       tsincexp.codcomp%type;
    v_typpayroll        tsincexp.typpayroll%type;
    v_typemp        tsincexp.typemp%type;
    v_costcent        tsincexp.costcent%type;
    v_amtpay        tsincexp.amtpay%type;
    v_typincexp       tsincexp.typincexp%type;
    v_typinc            tsincexp.typinc%type;
    v_typpayr       tsincexp.typpayr%type;
    v_typpayt       tsincexp.typpayt%type;
    v_amtpay_e    tsincexp.amtpay_e%type;
    v_codcurr_e   tsincexp.codcurr_e%type;
    v_numlvl            tsincexp.numlvl%type;
    v_flgslip           tsincexp.flgslip%type;
    v_codbrlc       tsincexp.codbrlc%type;
    v_codcurr       tsincexp.codcurr%type;
    v_codempmt    tsincexp.codempmt%type;
    --ttaxcur
    v_amtnet        ttaxcur.amtnet%type;
    v_amtcal            ttaxcur.amtcal%type;
    v_amtincl       ttaxcur.amtincl%type;
    v_amtincc       ttaxcur.amtincc%type;
    v_amtincn       ttaxcur.amtincn%type;
    v_amtexpl       ttaxcur.amtexpl%type;
    v_amtexpc       ttaxcur.amtexpc%type;
    v_amtexpn       ttaxcur.amtexpn%type;
    v_amttax        ttaxcur.amttax%type;
    v_amtgrstx        ttaxcur.amtgrstx%type;
    v_amtsoc        ttaxcur.amtsoc%type;
    v_amtsoca       ttaxcur.amtsoca%type;
    v_amtsocc       ttaxcur.amtsocc%type;
    v_amtcprv       ttaxcur.amtcprv%type;
    v_amtprove        ttaxcur.amtprove%type;
    v_amtprovc        ttaxcur.amtprovc%type;
    v_amtproie        ttaxcur.amtproie%type;
    v_amtproic        ttaxcur.amtproic%type;
    v_pctemppf        ttaxcur.pctemppf%type;
    v_pctcompf        ttaxcur.pctcompf%type;
    v_staemp        ttaxcur.staemp%type;
    v_dteeffex        ttaxcur.dteeffex%type;
    v_amtincom1   ttaxcur.amtincom1%type;
    v_codbank       ttaxcur.codbank%type;
    v_numbank       ttaxcur.numbank%type;
    v_bankfee       ttaxcur.bankfee%type;
    v_amtnet1       ttaxcur.amtnet1%type;
    v_codbank2        ttaxcur.codbank2%type;
    v_numbank2    ttaxcur.numbank2%type;
    v_bankfee2        ttaxcur.bankfee2%type;
    v_amtnet2       ttaxcur.amtnet2%type;
    v_qtywork       ttaxcur.qtywork%type;
    v_typpaymt        ttaxcur.typpaymt%type;
    v_amtcale       ttaxcur.amtcale%type;
    v_amtcalc       ttaxcur.amtcalc%type;
    v_codgrpgl        ttaxcur.codgrpgl%type;
    v_amtcalo       ttaxcur.amtcalo%type;
    v_amttaxe       ttaxcur.amttaxe%type;
    v_amttaxc       ttaxcur.amttaxc%type;
    v_amttaxo       ttaxcur.amttaxo%type;
    v_codpos        ttaxcur.codpos%type;
    v_jobgrade        ttaxcur.jobgrade%type;
    v_flgtax            ttaxcur.flgtax%type;
    v_amtsalyr        ttaxcur.amtsalyr%type;
    v_amtothe       ttaxcur.amtothe%type;
    v_amtothc       ttaxcur.amtothc%type;
    v_amtotho       ttaxcur.amtotho%type;
    v_amttaxyr        ttaxcur.amttaxyr%type;
    v_amttaxoth   ttaxcur.amttaxoth%type;
    v_codcompy    ttaxcur.codcompy%type;
    v_flgsoc            ttaxcur.flgsoc%type;
    v_typincom        ttaxcur.typincom%type;
    v_flgtrnbank    ttaxcur.flgtrnbank%type;
    --ttaxmas
  v_amtnett   ttaxmas.amtnett%type;
  v_amtcalt   ttaxmas.amtcalt%type;
  v_amtinclt    ttaxmas.amtinclt%type;
  v_amtincct    ttaxmas.amtincct%type;
  v_amtincnt    ttaxmas.amtincnt%type;
  v_amtexplt    ttaxmas.amtexplt%type;
  v_amtexpct    ttaxmas.amtexpct%type;
  v_amtexpnt    ttaxmas.amtexpnt%type;
  v_amttaxt   ttaxmas.amttaxt%type;
  v_amtgrstxt   ttaxmas.amtgrstxt%type;
  v_amtsoct   ttaxmas.amtsoct%type;
  v_amtsocat    ttaxmas.amtsocat%type;
  v_amtsocct    ttaxmas.amtsocct%type;
  v_amtcprvt    ttaxmas.amtcprvt%type;
  v_amtprovte   ttaxmas.amtprovte%type;
  v_amtprovtc   ttaxmas.amtprovtc%type;
  v_amtsocyr    ttaxmas.amtsocyr%type;
  v_amttcprv    ttaxmas.amttcprv%type;
  v_amtproyr    ttaxmas.amtproyr%type;
  v_qtyworkt    ttaxmas.qtyworkt%type;
  v_amtcalet    ttaxmas.amtcalet%type;
  v_amtcalct    ttaxmas.amtcalct%type;
  v_amtcalot    ttaxmas.amtcalot%type;
  v_amttaxet    ttaxmas.amttaxet%type;
  v_amttaxct    ttaxmas.amttaxct%type;
  v_amttaxot    ttaxmas.amttaxot%type;



    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

  type codpay is table of varchar2(4 char) index by binary_integer;
  arr_codpay     codpay;--เก็บรหัสเงินได้/ส่วนหัก  ตัวที่1-n

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists            number;
    v_sum_a                number;
    v_sum_b                number;
    v_min_soc         number;
  v_max_soc         number;
  v_codpaypy1     varchar2(4);
  v_codpaypy2     varchar2(4);
  v_codpaypy3     varchar2(4);
  v_codpaypy6     varchar2(4);
  v_codpaypy7     varchar2(4);
    v_startdate             tdtepay.dtestrt%type;
    v_enddate              tdtepay.dteend%type;
    v_dteempmt           temploy1.dteempmt%type;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len := leng(10, 4, 2, 1, 1, 12, .. , 12);
        for i in 1..v_column loop 
            if i in (1) then
                chk_len(i) := 10;  
            elsif i in (2) then
                chk_len(i) := 4;  
            elsif i in (3) then
                chk_len(i) := 2;  
            elsif i in (4,5) then
                chk_len(i) := 1;  
            else
                chk_len(i) := 12;
            end if;
        end loop;        

        --default transaction success and error
    p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
      v_text(i) := null;
          arr_codpay(i) := null;
        end loop;                

        --read columns name       
        for i in 1..v_column loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i-1));
          --v_num             := v_num + 1;
          v_field(i)    := hcm_util.get_string_t(param_column_row,'name');

      --keep array codpay
      arr_codpay(i) := hcm_util.get_string_t(param_column_row,'value');

        end loop;                 

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;           

        v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
                v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
                v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
                v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
                v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');

        --keep amtpay 
        for i in 6..v_column loop
          v_text(i) := hcm_util.get_string_t(param_json_row,'col-' || to_char(i));
        end loop;

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;    

                    --1.validate --           
                    --check require data column 
                    for i in 1..6 loop
                        if( (length(trim(v_text(i))) is null or v_text(i) is null)) then                        
                            v_error   := true;
                            v_err_code  := 'HR2045';
                            v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                            exit cal_loop;
                        end if;
                    end loop;

                    --check length all columns
                    --chk_len:= leng(10, 4, 2, 1, 1, 12, .. , 12);             
                    for i in 1..v_column loop
                        if( (v_text(i) is not null)  or ( length(trim(v_text(i))) is not null ) ) then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;  
                        end if;
                    end loop;                    

                    --check incorrect data      
                    --check codempid in temploy1
                    v_chk_exists := 0;
                     begin 
                        select 1, codcomp, typpayroll, typemp, numlvl, codbrlc, codempmt, staemp, dteeffex, codgrpgl, codpos, jobgrade, dteempmt  
                            into v_chk_exists, v_codcomp, v_typpayroll, v_typemp, v_numlvl, v_codbrlc, v_codempmt, v_staemp, v_dteeffex, v_codgrpgl, v_codpos, v_jobgrade, v_dteempmt   
            from temploy1 
                        where codempid = v_text(1);
                    exception when no_data_found then  
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY1';
                        exit cal_loop;
                    end;

                    --check codpay in tinexinf
                    v_chk_exists := 0;
                    for i in 6..v_column loop
                        if ( (arr_codpay(i) is not null)  or ( length(trim(arr_codpay(i))) is not null ) )   then
                            begin 
                                select 1
                                    into v_chk_exists from tinexinf 
                                where codpay = arr_codpay(i);
                            exception when no_data_found then 
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := 'CODPAY-' || arr_codpay(i);
                                v_err_table := 'TINEXINF';
                                exit cal_loop;
                            end;
                        end if;
                    end loop;  

                    --check flgslip must be 1-2
                    if(v_text(5) not in ('1','2')) then                         
                        v_error   := true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(5);
                        exit cal_loop;                    
                    end if; 

                    --check amtpay >= 0
                    for i in 6..v_column loop
                        if ( (v_text(i) is not null)  or ( length(trim(v_text(i))) is not null ) )   then
                            if(to_number(v_text(i)) < 0) then
                                v_error   := true;
                                v_err_code  := 'HR2023';
                                v_err_field := v_field(i);
                                exit cal_loop;                    
                            end if;
                       end if;
                    end loop;   

                v_codempid  := v_text(1); 
                   -- insert into j values('tsincexp => v_codempid: ' || v_codempid);
                    v_dteyrepay  := check_year(v_text(2)); 
                    v_dtemthpay  := to_number(v_text(3)); 
                    v_numperiod  := to_number(v_text(4)); 
                    v_flgslip  := '1' ; --v_text(5);                     
                    v_codcurr_e     := null;

                    v_costcent      := null;          
          begin 
            select costcent into v_costcent 
            from tcenter 
            where codcomp = v_codcomp;
          exception when no_data_found then 
            /*
            v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_codcomp;
                        v_err_table := 'TCENTER';
                        exit cal_loop;
                        */
                        null;
          end;

          begin
            select codcurr, amtincom1, codbank, numbank, codbank2, numbank2, flgtax  
              into v_codcurr, v_amtincom1, v_codbank, v_numbank, v_codbank2, v_numbank2, v_flgtax  
            from temploy3 
            where codempid = v_codempid;
          exception when no_data_found then 
            v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(1);
                        v_err_table := 'TEMPLOY3';
                        exit cal_loop;

          end;

           exit cal_loop;
                end loop;

         --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 

          delete from tsincexp where codempid  = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod;


                    --insert tsincexp           
           for j in 6..v_column loop
                         if ( (arr_codpay(j) is not null)  or ( length(trim(arr_codpay(j))) is not null ) )  then 

                            v_codpay := arr_codpay(j);
                            v_amtpay       := 0;
                            if ( (v_text(j) is not null)  or ( length(trim(v_text(j))) is not null ) )  then 
                                 v_amtpay     := to_number(v_text(j));
                            end if;

                           v_amtpay_e  := v_amtpay;
                           --insert into j values('tsincexp => v_amtpay: ' || v_amtpay);
                           --insert into j values('tsincexp => v_amtpay_e: ' || v_amtpay_e);
                            --insert into j values('stdenc: ' || stdenc(v_amtpay,v_codempid,v_chken));

                            --get typpay, typinc, typpayr, typpayt  each codpay
                            begin 
                                select  typpay, typinc, typpayr, typpayt 
                                    into  v_typincexp, v_typinc, v_typpayr, v_typpayt from tinexinf 
                                where codpay = arr_codpay(j);
                            exception when no_data_found then 
                                /*
                                v_error   := true;
                                v_err_code  := 'HR2010';
                                v_err_field := 'CODPAY-' || arr_codpay(j);
                                v_err_table := 'TINEXINF';
                               */
                              null;

                            end;


                            if v_amtpay > 0 then 
                                begin   
                                    insert into tsincexp (codempid, dteyrepay, dtemthpay, numperiod, codpay, codcomp, typpayroll, typemp, 
                                                                 costcent, amtpay, typincexp, typinc, typpayr, typpayt, amtpay_e, codcurr_e, 
                                                                 numlvl, flgslip, codbrlc, codcurr, codempmt, dtecreate, codcreate, dteupd, coduser)                        
                                                     values (v_codempid, v_dteyrepay, v_dtemthpay, v_numperiod, v_codpay, v_codcomp, v_typpayroll, v_typemp, 
                                                                 v_costcent, stdenc(v_amtpay, v_codempid, v_chken), v_typincexp, v_typinc, v_typpayr, v_typpayt, stdenc(v_amtpay_e, v_codempid, v_chken), v_codcurr_e, 
                                                                 v_numlvl, v_flgslip, v_codbrlc, v_codcurr, v_codempmt, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);   
                                    exception when others then   
                                -- insert into j values('error tsincexp')  ;   
                                    null;
                                end;
                            end if; 
                        end if; 
                    end loop;

                    delete from ttaxcur  where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod;
                   -- insert into j values('deleted TTAXCUR')  ;   

                    v_sum_a := 0;
                    v_sum_b := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and typincexp in ('1','2','3') and flgslip = '1';

                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_b from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and typincexp in ('4','5','6') and flgslip = '1';   

                  --  insert into j values('ttaxcur => v_amtnet: ' || v_sum_a - v_sum_b)  ;   
                    v_amtnet := stdenc((v_sum_a - v_sum_b), v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay = '1' and y.flgcal = 'Y';

                  --  insert into j values('ttaxcur => v_amtcal: ' || v_sum_a)  ;       
                    v_amtcal := stdenc(v_sum_a, v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay = '2' and y.flgcal = 'Y';

                 --   insert into j values('ttaxcur => v_amtincl: ' || v_sum_a)  ;           
                    v_amtincl := stdenc(v_sum_a, v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay = '3' and y.flgcal = 'Y';

                 --   insert into j values('ttaxcur => v_amtincc: ' || v_sum_a)  ;      
                    v_amtincc := stdenc(v_sum_a, v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('2', '3') and y.flgcal = 'N';

                --    insert into j values('ttaxcur => v_amtincn: ' || v_sum_a)  ;        
                    v_amtincn := stdenc(v_sum_a, v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay = '4' and y.flgcal = 'Y';

                --    insert into j values('ttaxcur => v_amtexpl: ' || v_sum_a)  ;          
                    v_amtexpl := stdenc(v_sum_a, v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay = '5' and y.flgcal = 'Y';

                 --   insert into j values('ttaxcur => v_amtexpc: ' || v_sum_a)  ;             
                    v_amtexpc := stdenc(v_sum_a, v_codempid, v_chken);

                    v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('4', '5') and y.flgcal = 'N';

               --     insert into j values('ttaxcur => v_amtexpn: ' || v_sum_a)  ;      
                    v_amtexpn := stdenc(v_sum_a, v_codempid, v_chken);

                    v_codcompy := hcm_util.get_codcomp_level(v_codcomp,1);

                    v_min_soc := 0;
          v_max_soc := 0;
          begin 
            select amtminsoc, amtmaxsoc, codpaypy1, codpaypy2, codpaypy3, codpaypy6, codpaypy7 
              into v_min_soc, v_max_soc, v_codpaypy1, v_codpaypy2, v_codpaypy3, v_codpaypy6, v_codpaypy7 from tcontrpy
            where codcompy = v_codcompy
              and dteeffec = (select max(dteeffec) from tcontrpy
                       where  codcompy =v_codcompy and dteeffec <= trunc(sysdate));
          exception when no_data_found then 
            v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_codcompy;
                        v_err_table := 'TCONTRPY';
                       -- return ;

                    p_rec_tran := p_rec_tran - 1;    
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i;                        
                    continue;   
          end;  

          v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and codpay = v_codpaypy1;

               --   insert into j values('ttaxcur => v_amttax: ' || v_sum_a)  ;  
          v_amttax := stdenc(v_sum_a, v_codempid, v_chken);

                --    insert into j values('ttaxcur => v_amtgrstx: ' || 0)  ;  
                    v_amtgrstx := stdenc(0, v_codempid, v_chken);
                    --

          v_sum_a := 0;
                    v_sum_b := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('1', '2', '3') and y.flgsoc = 'Y';

                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_b from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('4', '5') and y.flgsoc = 'Y'; 

                  --  insert into j values('ttaxcur => v_amtsoc: ' || greatest(v_min_soc, least(v_max_soc,(v_sum_a - v_sum_b))))  ;      
                    v_amtsoc := stdenc(greatest(v_min_soc, least(v_max_soc,(v_sum_a - v_sum_b))), v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and codpay = v_codpaypy2;

                  --  insert into j values('ttaxcur => v_amtsoca: ' || v_sum_a)  ;  
          v_amtsoca := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and codpay = v_codpaypy6;

                 --   insert into j values('ttaxcur => v_amtsocc: ' || v_sum_a)  ;  
          v_amtsocc := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    v_sum_b := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('1', '2', '3') and y.flgpvdf  = 'Y';

                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_b from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('4', '5') and y.flgpvdf  = 'Y'; 

                 --   insert into j values('ttaxcur => v_amtcprv: ' || v_sum_a - v_sum_b)  ;  
          v_amtcprv := stdenc((v_sum_a - v_sum_b), v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and codpay = v_codpaypy3;

                 --   insert into j values('ttaxcur => v_amtprove: ' || v_sum_a)  ;  
          v_amtprove := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp
                    where codempid = v_codempid and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod 
                        and codpay = v_codpaypy7;

                --    insert into j values('ttaxcur => v_amtprovc: ' || v_sum_a)  ;  
          v_amtprovc := stdenc(v_sum_a, v_codempid, v_chken);

          v_amtproie := stdenc(0, v_codempid, v_chken);
                    v_amtproic := stdenc(0, v_codempid, v_chken);


                    v_pctemppf  := 0;
                    v_pctcompf  := 0;    
                    /*
          begin 
            select ratecret, ratecsbt into v_pctemppf, v_pctcompf 
            from tpfmemrt 
            where codempid = v_codempid and dteeffec = (select max(dteeffec) from tpfmemrt
                                  where codempid = v_codempid  and dteeffec <= trunc(sysdate)); --should use date from end_period_cal?
          exception when no_data_found then 
            null;

            v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(0);
                        v_err_table := 'TPFMEMRT';
                        return ;

          end;  
                    */
                --    insert into j values('ttaxcur => v_pctemppf: ' || v_pctemppf)  ;  
                --    insert into j values('ttaxcur => v_pctcompf: ' || v_pctcompf)  ;  

          --2022.09.14 Doctor said that don't send 
                    --v_codcurr := null;   --should use temploy3 
                    --v_codbank := null;   
                    --v_numbank := null;  
                    v_bankfee := 0;
                    v_amtnet1 := stdenc(0, v_codempid, v_chken);
                    --v_codbank2 := null;   
                    --v_numbank2 := null;  
                    v_bankfee2 := 0;
                    v_amtnet2 := stdenc(0, v_codempid, v_chken);
                    v_qtywork := 0;               

                    --2022.09.14 Doctor said that don't send 
                    /* 
                    begin 
            select dtestrt, dteend into v_startdate, v_enddate 
            from tdtepay 
                        where codcompy = v_codcompy and dteyrepay = v_dteyrepay and dtemthpay = v_dtemthpay and numperiod = v_numperiod;          
          exception when no_data_found then 
                        v_error   := true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_codcompy;
                        v_err_table := 'TDTEPAY';                    
            return;
                    end;

                    --v_dteeffex, v_dteempmt, v_startdate, v_enddate 
                    if v_dteeffex is null then --ถ้า พนง. ยังไม่ลาออก 
                        v_qtywork := v_enddate - v_startdate + 1;   --วันที่สิ้นสุดงวด - วันที่เริ่มต้นงวด + 1
                    end if;

                     if v_dteeffex is null then --ถ้า พนง. ยังไม่ลาออก และ เข้างานระหว่างงวด 
                         if v_dteempmt between v_startdate and v_enddate then 
                            v_qtywork := v_enddate - v_dteempmt + 1;   --วันที่สิ้นสุดงวด - วันที่เริ่มงาน + 1
                        end if;
                    end if;

                    if v_dteeffex is not null then --ถ้า พนง. ลาออกระหว่างงวด 
                        if v_dteeffex between v_startdate and v_enddate then 
                             v_qtywork := v_dteeffex - v_startdate;     --วันที่พ้นสภาพ – วันที่เริ่มต้นงวด
                        else --ถ้า พนง. ลาออกงวดอื่น แสดงว่า งวดนี้ พนง. มีวันทำงานเต็มเดือน
                            v_qtywork := v_enddate - v_startdate + 1;   --วันที่สิ้นสุดงวด - วันที่เริ่มต้นงวด + 1 
                        end if;
                    end if;

                    if v_dteeffex is not null then --ถ้า พนง. ลาออกระหว่างงวด และ เข้างานระหว่างงวด 
                        if v_dteeffex between v_startdate and v_enddate then 
                            if v_dteempmt between v_startdate and v_enddate then 
                                v_qtywork := v_dteeffex - v_dteempmt;     --วันที่พ้นสภาพ – วันที่เริ่มงาน                             
                            end if;
                        end if;
                    end if;
                    */

                   --  insert into j values('ttaxcur => v_qtywork: ' || v_qtywork)  ;  

          v_typpaymt := 'BK';

          v_amtcale := stdenc(0, v_codempid, v_chken);
                    v_amtcalc := stdenc(0, v_codempid, v_chken);
          v_amtcalo := stdenc(0, v_codempid, v_chken);
                    v_amttaxe := stdenc(0, v_codempid, v_chken);
                    v_amttaxc := stdenc(0, v_codempid, v_chken);
                    v_amttaxo := stdenc(0, v_codempid, v_chken);

                   -- insert into j values('ttaxcur => v_amtcale: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amtcalc: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amtcalo: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amttaxe: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amttaxc: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amttaxo: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amtsalyr: ' || 0)  ; 
          v_amtsalyr := stdenc(0, v_codempid, v_chken); --must find

          v_sum_a := 0;
                    select sum(stddec(amtpay, codempid, v_chken)) into v_sum_a from tsincexp x, tinexinf y
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                        and x.codpay = y.codpay and y.typpay in ('2', '3') and y.flgtax  = '1';

                  --  insert into j values('ttaxcur => v_amtothe: ' || v_sum_a)  ;  
                    v_amtothe := stdenc(v_sum_a, v_codempid, v_chken);

                    v_amtothc := stdenc(0, v_codempid, v_chken);
                    v_amtotho := stdenc(0, v_codempid, v_chken);
                    v_amttaxyr := stdenc(0, v_codempid, v_chken); --must find
                    v_amttaxoth := stdenc(0, v_codempid, v_chken);

                   -- insert into j values('ttaxcur => v_amtothc: ' || 0)  ;  
                  -- insert into j values('ttaxcur => v_amtotho: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amttaxyr: ' || 0)  ;  
                   -- insert into j values('ttaxcur => v_amttaxoth: ' || 0)  ; 

          v_flgsoc := 'N';
                    begin 
                        select 'Y' into v_flgsoc from tsincexp x
                        where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay and x.dtemthpay = v_dtemthpay and x.numperiod = v_numperiod 
                            and x.codpay in (select codpay from tinexinf where flgsoc = 'Y') and rownum =1; 
                    exception when no_data_found then 
                        null;
                    end;                    

          v_typincom := '1';
                    v_flgtrnbank := 'Y';

                   -- insert into j values('insert ttaxcur');

                    begin
                    insert into ttaxcur (codempid, dteyrepay, dtemthpay, numperiod, amtnet, amtcal,
                     amtincl, amtincc, amtincn, amtexpl, amtexpc, amtexpn,
                     amttax, amtgrstx, amtsoc, amtsoca, amtsocc, amtcprv,
                     amtprove, amtprovc, amtproie, amtproic, pctemppf, pctcompf,
                     codcomp, typpayroll, numlvl, typemp, codbrlc, staemp, 
                     dteeffex, codcurr, amtincom1, codbank, numbank, bankfee,
                     amtnet1, codbank2, numbank2, bankfee2, amtnet2, qtywork,
                     typpaymt, amtcale, amtcalc, codgrpgl, amtcalo, amttaxe,
                     amttaxc, amttaxo, codpos, codempmt, jobgrade, flgtax,
                     amtsalyr, amtothe, amtothc, amtotho, amttaxyr, amttaxoth, 
                     codcompy, flgsoc, typincom, flgtrnbank, dtecreate, codcreate, dteupd, coduser)
                 values (v_codempid, v_dteyrepay, v_dtemthpay, v_numperiod, v_amtnet, v_amtcal,
                     v_amtincl, v_amtincc, v_amtincn, v_amtexpl, v_amtexpc, v_amtexpn,
                     v_amttax, v_amtgrstx, v_amtsoc, v_amtsoca, v_amtsocc, v_amtcprv,
                     v_amtprove, v_amtprovc, v_amtproie, v_amtproic, v_pctemppf, v_pctcompf,
                     v_codcomp, v_typpayroll, v_numlvl, v_typemp, v_codbrlc, v_staemp, 
                     v_dteeffex, v_codcurr, v_amtincom1, v_codbank, v_numbank, v_bankfee,
                     v_amtnet1, v_codbank2, v_numbank2, v_bankfee2, v_amtnet2, v_qtywork,
                     v_typpaymt, v_amtcale, v_amtcalc, v_codgrpgl, v_amtcalo, v_amttaxe,
                     v_amttaxc, v_amttaxo, v_codpos, v_codempmt, v_jobgrade, v_flgtax,
                     v_amtsalyr, v_amtothe, v_amtothc, v_amtotho, v_amttaxyr, v_amttaxoth, 
                     v_codcompy, v_flgsoc, v_typincom, v_flgtrnbank, trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);  
                     exception when others then   
                      --  insert into j values('error ttaxcur');
                      null;
                      --  return;
                      end;

                    delete from ttaxmas  where codempid = v_codempid and dteyrepay = v_dteyrepay;
         -- insert into j values('deleted ttaxmas')  ;   

          v_sum_a := 0;
                    select sum(stddec(amtnet, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtnett: ' || v_sum_a)  ;  
                    v_amtnett := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtcal, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtcalt: ' || v_sum_a)  ;    
                    v_amtcalt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtincl, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtinclt: ' || v_sum_a)  ;       
                    v_amtinclt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtincc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amtincct: ' || v_sum_a)  ;     
                    v_amtincct := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtincn, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amtincnt: ' || v_sum_a)  ;       
                    v_amtincnt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtexpl, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amtexplt: ' || v_sum_a)  ;     
                    v_amtexplt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtexpc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amtexpct: ' || v_sum_a)  ;   
                    v_amtexpct := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtexpn, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amtexpnt: ' || v_sum_a)  ;     
                    v_amtexpnt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amttax, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amttaxt: ' || v_sum_a)  ;  
                    v_amttaxt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtgrstx, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                  --  insert into j values('ttaxmas => v_amtgrstxt: ' || v_sum_a)  ;  
                    v_amtgrstxt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtsoc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtsoct: ' || v_sum_a)  ;  
                    v_amtsoct := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtsoca, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtsocat: ' || v_sum_a)  ; 
                    v_amtsocat := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtsocc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtsocct: ' || v_sum_a)  ;   
                    v_amtsocct := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtcprv, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtcprvt: ' || v_sum_a)  ;   
                    v_amtcprvt := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtprove, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtprovte: ' || v_sum_a)  ;   
                    v_amtprovte := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtprovc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtprovtc: ' || v_sum_a)  ;    
                    v_amtprovtc := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    begin
                        select stddec(amtsalyr, codempid, v_chken) into v_sum_a from ttaxcur x
                        where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay 
                          and x.dtemthpay = (select max(dtemthpay) from ttaxcur 
                                              where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay) ;
                    exception when no_data_found then 
                        null;
                    end;  

                   -- insert into j values('ttaxmas => v_amtsalyr: ' || v_sum_a)  ; 
                    v_amtsalyr := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    begin
                        select stddec(amttax, codempid, v_chken) into v_sum_a from ttaxcur x
                        where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay 
                          and x.dtemthpay = (select max(dtemthpay) from ttaxcur 
                                              where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay) ;
          exception when no_data_found then 
                        null;
                    end;

                   -- insert into j values('ttaxmas => v_amttaxyr: ' || v_sum_a)  ; 
                    v_amttaxyr := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
          v_sum_b := 0;                    
                    select sum(stddec(amtsoca, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                    begin                   
                        select stddec(amtsoca, codempid, v_chken) * (12 - x.dtemthpay) into v_sum_b from ttaxcur x
                        where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay 
                          and x.dtemthpay = (select max(dtemthpay) from ttaxcur 
                                              where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay) ;
          exception when no_data_found then 
                        null;
                    end;

                   -- insert into j values('ttaxmas => v_amtsocyr: ' || v_sum_a + v_sum_b)  ; 
                    v_amtsocyr := stdenc(v_sum_a + v_sum_b, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtcprv, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amttcprv: ' || v_sum_a )  ;  
                    v_amttcprv := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
          v_sum_b := 0;
                    select sum(stddec(amtprove, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                    begin           
                        select stddec(amtsoca, codempid, v_chken) * (12 - x.dtemthpay) into v_sum_b from ttaxcur x
                        where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay 
                          and x.dtemthpay = (select max(dtemthpay) from ttaxcur 
                                              where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay) ;
          exception when no_data_found then 
                        null;
                    end;

                   -- insert into j values('ttaxmas => v_amtproyr: ' || v_sum_a + v_sum_b)  ; 
                    v_amtproyr := stdenc(v_sum_a + v_sum_b, v_codempid, v_chken);         

          v_qtyworkt := 0;
                    select sum(qtywork) into v_qtyworkt from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;               
                   -- insert into j values('ttaxmas => v_qtyworkt: ' || v_qtyworkt)  ; 

          v_sum_a := 0;
                    select sum(stddec(amtcale, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtcalet: ' || v_sum_a)  ; 
                    v_amtcalet := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtcalc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtcalct: ' || v_sum_a)  ;   
                    v_amtcalct := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amtcalo, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amtcalot: ' || v_sum_a)  ;   
                    v_amtcalot := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amttaxe, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amttaxet: ' || v_sum_a)  ;   
                    v_amttaxet := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amttaxc, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amttaxct: ' || v_sum_a)  ;     
                    v_amttaxct := stdenc(v_sum_a, v_codempid, v_chken);

          v_sum_a := 0;
                    select sum(stddec(amttaxo, codempid, v_chken)) into v_sum_a from ttaxcur x
                    where x.codempid = v_codempid and x.dteyrepay = v_dteyrepay ;

                   -- insert into j values('ttaxmas => v_amttaxot: ' || v_sum_a)  ;       
                    v_amttaxot := stdenc(v_sum_a, v_codempid, v_chken);

          /*  use var from insert into ttaxcur 
            v_amtothe
            v_amtothc
            v_amtotho
            v_amttaxoth
          */

                   -- insert into j values('insert ttaxmas');

                    begin
                        insert into ttaxmas(codempid, dteyrepay, codcomp, amtnett, amtcalt, amtinclt,
                                                    amtincct, amtincnt, amtexplt, amtexpct, amtexpnt, amttaxt,
                                                    amtgrstxt, amtsoct, amtsocat, amtsocct, amtcprvt, amtprovte,
                                                    amtprovtc, amtsalyr, amttaxyr, amtsocyr, amttcprv, amtproyr,
                                                    qtyworkt, amtcalet, amtcalct, amtcalot, amttaxet, amttaxct,
                                                    amttaxot, amtothe, amtothc, amtotho, amttaxoth, dteupd, coduser)
                                         values (v_codempid, v_dteyrepay, v_codcomp, v_amtnett, v_amtcalt, v_amtinclt,
                                                    v_amtincct, v_amtincnt, v_amtexplt, v_amtexpct, v_amtexpnt, v_amttaxt,
                                                    v_amtgrstxt, v_amtsoct, v_amtsocat, v_amtsocct, v_amtcprvt, v_amtprovte,
                                                    v_amtprovtc, v_amtsalyr, v_amttaxyr, v_amtsocyr, v_amttcprv, v_amtproyr,
                                                    v_qtyworkt, v_amtcalet, v_amtcalct, v_amtcalot, v_amttaxet, v_amttaxct,
                                                    v_amttaxot, v_amtothe, v_amtothc, v_amtotho, v_amttaxoth, trunc(sysdate), global_v_coduser); 
                    exception when others then            
                       -- insert into j values('error ttaxmas');
                       null;
                       -- return;
                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                   -- insert into j values(p_error_code(v_cnt));
                end if;            

                commit;

            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
               --  insert into j values(param_msg_error);
            end;
    end loop;  

  end;  

--AL---------------------------------------------------------------------------------------------------------  
  --
  procedure get_process_al_tshiftcd(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_al_tshiftcd(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_al_tshiftcd(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 22;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tshiftcd       tshiftcd%rowtype;
    v_temp           varchar2(1000);

    cursor c_tcompny is
      select codcompy 
      from   tcompny
      order by codcompy;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (2,3) then
        chk_len(i) := 150;  
      elsif i in (1,4) or i between 6 and 21 then
        chk_len(i) := 4;
      elsif i in (5,22) then
        chk_len(i) := 5;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;    
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tshiftcd  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15) := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16) := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17) := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18) := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19) := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20) := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21) := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22) := hcm_util.get_string_t(param_json_row,'col-22');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i not in (4,18,21,22) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;

          if v_text(8)||v_text(9) is not null then
            if v_text(8) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(8);
              v_err_data  := v_text(8);
              exit cal_loop;
            end if;
            if v_text(9) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(9);
              v_err_data  := v_text(9);
              exit cal_loop;
            end if;
          end if;

          if v_text(16)||v_text(17) is not null then
            if v_text(16) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(16);
              v_err_data  := v_text(16);
              exit cal_loop;
            end if;
            if v_text(17) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(17);
              v_err_data  := v_text(17);
              exit cal_loop;
            end if;
          end if;

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i between 5 and 22 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 4 and v_text(i) is not null then
              begin
                select codcodec into v_temp
                  from tcodflex
                 where codcodec = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TCODFLEX';
                exit cal_loop;
              end;                
            end if;

            if i = 5 and not(to_number(v_text(i)) > 0 and to_number(v_text(i)) <= 1440) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 22 and to_number(v_text(i)) > to_number(v_text(5)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;                            

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_tshiftcd.codshift     := upper(v_text(1));
          v_tshiftcd.desshifte    := v_text(2);
          v_tshiftcd.desshiftt    := v_text(3);
          v_tshiftcd.desshift3    := v_text(2);
          v_tshiftcd.desshift4    := v_text(2);
          v_tshiftcd.desshift5    := v_text(2);
          v_tshiftcd.grpshift     := upper(v_text(4));
          v_tshiftcd.qtydaywk     := to_number(v_text(5));
          v_tshiftcd.timstrtw     := v_text(6);
          v_tshiftcd.timendw      := v_text(7);
          v_tshiftcd.timstrtb     := v_text(8);
          v_tshiftcd.timendb      := v_text(9);
          v_tshiftcd.stampinst    := v_text(10);
          v_tshiftcd.stampinen    := v_text(11);
          v_tshiftcd.stampoutst   := v_text(12);
          v_tshiftcd.stampouten   := v_text(13);
          v_tshiftcd.timstotd     := v_text(14);
          v_tshiftcd.timenotd     := v_text(15);
          v_tshiftcd.timstotdb    := v_text(16);
          v_tshiftcd.timenotdb    := v_text(17);
          v_tshiftcd.timstotb     := v_text(18);
          v_tshiftcd.timenotb     := v_text(19);
          v_tshiftcd.timstota     := v_text(20);
          v_tshiftcd.timenota     := v_text(21);
          v_tshiftcd.qtywkfull    := to_number(v_text(22));
          --
          --Save TSHIFTCD--
          begin
            delete from tshiftcd where codshift = v_tshiftcd.codshift;

            insert into tshiftcd(codshift,desshifte,desshiftt,desshift3,desshift4,desshift5,
                                 grpshift,qtydaywk,
                                 timstrtw,timendw,timstrtb,timendb,
                                 stampinst,stampinen,stampoutst,stampouten,
                                 timstotd,timenotd,timstotdb,timenotdb,
                                 timstotb,timenotb,timstota,timenota,qtywkfull,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tshiftcd.codshift,v_tshiftcd.desshifte,v_tshiftcd.desshiftt,v_tshiftcd.desshift3,v_tshiftcd.desshift4,v_tshiftcd.desshift5,
                               v_tshiftcd.grpshift,v_tshiftcd.qtydaywk,
                               v_tshiftcd.timstrtw,v_tshiftcd.timendw,v_tshiftcd.timstrtb,v_tshiftcd.timendb,
                               v_tshiftcd.stampinst,v_tshiftcd.stampinen,v_tshiftcd.stampoutst,v_tshiftcd.stampouten,
                               v_tshiftcd.timstotd,v_tshiftcd.timenotd,v_tshiftcd.timstotdb,v_tshiftcd.timenotdb,
                               v_tshiftcd.timstotb,v_tshiftcd.timenotb,v_tshiftcd.timstota,v_tshiftcd.timenota,v_tshiftcd.qtywkfull,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

          --Save TSHIFCOM--
          for i in c_tcompny loop
            begin
              insert into tshifcom(codcompy,codshift,dtecreate,codcreate,dteupd,coduser)
                            values(i.codcompy,v_tshiftcd.codshift,trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);
            exception when dup_val_on_index then
              null;
            end;
          end loop;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;          
        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_al_tlateabs(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_al_tlateabs(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_al_tlateabs(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 7;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tlateabs       tlateabs%rowtype;
    v_temp           varchar2(1000);
    v_qtydaywk       number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2) then
        chk_len(i) := 10;  
      elsif i in (3) then
        chk_len(i) := 4;
      elsif i in (4,5,6,7) then
        chk_len(i) := 5;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tlateabs  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');   

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;          

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 2 and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i between 4 and 7 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;

            if i = 2 then
              begin
                select codempid into v_temp
                  from tattence
                 where codempid = upper(v_text(1))
                   and dtework  = to_date(v_text(2),'dd/mm/yyyy');                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TATTENCE';
                exit cal_loop;
              end;                
            end if;

            if i = 3 then
              begin
                select codshift into v_temp
                  from tshiftcd
                 where codshift = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TSHIFTCD';
                exit cal_loop;
              end;                
            end if;   

            if i in (4,5,6) and not(to_number(v_text(i)) between 0 and 1440) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_tlateabs.codempid     := upper(v_text(1));
          v_tlateabs.dtework      := to_date(v_text(2),'dd/mm/yyyy');
          v_tlateabs.codshift     := upper(v_text(3));
          v_tlateabs.qtylate      := to_number(v_text(4));
          v_tlateabs.qtyearly     := to_number(v_text(5));
          v_tlateabs.qtyabsent    := to_number(v_text(6));
          v_tlateabs.qtynostam    := to_number(v_text(7));

          begin
            select qtydaywk into v_qtydaywk
            from	 tshiftcd
            where	 codshift = v_tlateabs.codshift;
          exception when no_data_found then
            null;
          end;
          if nvl(v_qtydaywk,0) > 0 then
            v_tlateabs.daylate      := v_tlateabs.qtylate / v_qtydaywk;
            v_tlateabs.dayearly     := v_tlateabs.qtyearly / v_qtydaywk;
            v_tlateabs.dayabsent    := v_tlateabs.qtyabsent / v_qtydaywk;
          else
            v_tlateabs.daylate      := 0;
            v_tlateabs.dayearly     := 0;
            v_tlateabs.dayabsent    := 0;
          end if;
          v_tlateabs.qtytlate		  := least(v_tlateabs.qtylate,1);
          v_tlateabs.qtytearly	  := least(v_tlateabs.qtyearly,1);
          v_tlateabs.qtytabs		  := least(v_tlateabs.qtyabsent,1);
          v_tlateabs.amtlate      := stdenc(0,v_tlateabs.codempid,v_chken);
          v_tlateabs.amtearly     := stdenc(0,v_tlateabs.codempid,v_chken);
          v_tlateabs.amtabsent    := stdenc(0,v_tlateabs.codempid,v_chken);

          begin
            select codcomp,flgatten into v_tlateabs.codcomp,v_tlateabs.flgatten
            from	 temploy1
            where	 codempid = v_tlateabs.codempid;
          exception when no_data_found then
            null;
          end;

          --
          --Save TLATEABS--
          begin
            delete from tlateabs where codempid = v_tlateabs.codempid
                                   and dtework  = v_tlateabs.dtework;

            insert into tlateabs(codempid,dtework,codshift,
                                 codcomp,flgatten,
                                 qtylate,qtyearly,qtyabsent,qtynostam,
                                 daylate,dayearly,dayabsent,
                                 qtytlate,qtytearly,qtytabs,
                                 amtlate,amtearly,amtabsent,
                                 flginput,flgcallate,flgcalear,flgcalabs,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tlateabs.codempid,v_tlateabs.dtework,v_tlateabs.codshift,
                               v_tlateabs.codcomp,v_tlateabs.flgatten,
                               v_tlateabs.qtylate,v_tlateabs.qtyearly,v_tlateabs.qtyabsent,v_tlateabs.qtynostam,
                               v_tlateabs.daylate,v_tlateabs.dayearly,v_tlateabs.dayabsent,
                               v_tlateabs.qtytlate,v_tlateabs.qtytearly,v_tlateabs.qtytabs,
                               v_tlateabs.amtlate,v_tlateabs.amtearly,v_tlateabs.amtabsent,
                               'Y','N','N','N',
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);            
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then      
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_al_tleavetr(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_al_tleavetr(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_al_tleavetr(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 7;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tleavetr       tleavetr%rowtype;
    v_temp           varchar2(1000);
    v_qtydaywk       number;
    v_yrecycle       number;
    v_dtecycst       date;
    v_dtecycen       date;
    v_sum_qtymin     number;
    v_sum_qtyday     number;
    v_qtydlepay      tleavety.qtydlepay%type;
    v_flgdlemx       tleavety.flgdlemx%type;
    v_qtydlemx       tleavsum.qtydlemx%type;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2) then
        chk_len(i) := 10;  
      elsif i in (3) then
        chk_len(i) := 4;
      elsif i in (4,5,6,7) then
        chk_len(i) := 5;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tleavetr  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');    

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i <> 7 and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (2,7) and v_text(i) is not null and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 6 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;

            if i = 2 then
              begin
                select codempid,codcomp into v_temp,v_tleavetr.codcomp
                  from tattence
                 where codempid = upper(v_text(1))
                   and dtework  = to_date(v_text(2),'dd/mm/yyyy');                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TATTENCE';
                exit cal_loop;
              end;                
            end if;

            if i = 3 then
              begin
                select codleave into v_temp
                  from tleavecd
                 where codleave = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TLEAVECD';
                exit cal_loop;
              end;     

              begin
                select typleave into v_temp
                  from tleavcom
                 where typleave = (select typleave 
                                     from	 tleavecd
                                    where	 codleave = upper(v_text(i)))
                   and codcompy = hcm_util.get_codcomp_level(v_tleavetr.codcomp,1);                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'tleavcom';
                exit cal_loop;
              end;              
            end if;   

            if i = 6 and not(to_number(v_text(i)) between 0 and 1440) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_tleavetr.codempid     := upper(v_text(1));
          v_tleavetr.dtework      := to_date(v_text(2),'dd/mm/yyyy');
          v_tleavetr.codleave     := upper(v_text(3));
          v_tleavetr.timstrt      := v_text(4);
          v_tleavetr.timend       := v_text(5);
          v_tleavetr.qtymin       := to_number(v_text(6));
          v_tleavetr.dteprgntst   := to_date(v_text(7),'dd/mm/yyyy');

          begin
            select codshift,codcomp,typpayroll,flgatten 
            into   v_tleavetr.codshift,v_tleavetr.codcomp,v_tleavetr.typpayroll,v_tleavetr.flgatten
            from	 tattence
            where	 codempid = v_tleavetr.codempid
            and    dtework  = v_tleavetr.dtework;
          exception when no_data_found then
            null;
          end;
          begin
            select typleave,staleave into v_tleavetr.typleave,v_tleavetr.staleave
            from	 tleavecd
            where	 codleave = v_tleavetr.codshift;
          exception when no_data_found then
            null;
          end;
          begin
            select qtydaywk into v_qtydaywk
            from	 tshiftcd
            where	 codshift = v_tleavetr.codshift;
          exception when no_data_found then
            null;
          end;
          if nvl(v_qtydaywk,0) > 0 then
            v_tleavetr.qtyday   := v_tleavetr.qtymin / v_qtydaywk;
          else
            v_tleavetr.qtyday   := 0;
          end if;
          v_tleavetr.amtlvded   := stdenc(0,v_tleavetr.codempid,v_chken);                    

          --
          --Save TLEAVETR--
          begin
            delete from tleavetr where codempid = v_tleavetr.codempid
                                   and dtework  = v_tleavetr.dtework;

            insert into tleavetr(codempid,dtework,codleave,
                                 typleave,staleave,
                                 codshift,codcomp,typpayroll,flgatten,
                                 timstrt,timend,qtymin,dteprgntst,
                                 qtyday,amtlvded,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tleavetr.codempid,v_tleavetr.dtework,v_tleavetr.codleave,
                               v_tleavetr.typleave,v_tleavetr.staleave,
                               v_tleavetr.codshift,v_tleavetr.codcomp,v_tleavetr.typpayroll,v_tleavetr.flgatten,
                               v_tleavetr.timstrt,v_tleavetr.timend,v_tleavetr.qtymin,v_tleavetr.dteprgntst,
                               v_tleavetr.qtyday,v_tleavetr.amtlvded,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);            
          end;

          --Save TLEAVSUM--
          std_al.cycle_leave(substr(v_tleavetr.codcomp,1,3), v_tleavetr.codempid, v_tleavetr.staleave, v_tleavetr.dtework, 
                             v_yrecycle, v_dtecycst, v_dtecycen);

          begin
            select sum(qtymin),sum(qtyday)
            into   v_sum_qtymin, v_sum_qtyday
            from   tleavetr
            where  codempid = v_tleavetr.codempid
            and    codleave = v_tleavetr.codleave
            and    dtework  between v_dtecycst and v_dtecycen;
          exception when others then
            null;
          end;

          begin
            select qtydlepay,flgdlemx into v_qtydlepay, v_flgdlemx
            from   tleavety
            where  typleave = v_tleavetr.typleave;
          exception when others then
            null;
          end;
          if v_flgdlemx = 'Y' then
             v_qtydlemx := least(v_sum_qtyday,v_qtydlepay);
          else
             v_qtydlemx := 0;
          end if;

          begin
            insert into tleavsum(codempid,dteyear,codleave,
                                 typleave,staleave,codcomp,typpayroll,
                                 qtyshrle,qtydayle,qtydlemx,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tleavetr.codempid,v_yrecycle,v_tleavetr.codleave,
                               v_tleavetr.typleave,v_tleavetr.staleave,v_tleavetr.codcomp,v_tleavetr.typpayroll,
                               v_sum_qtymin / 60,v_sum_qtymin,v_qtydlemx,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);
          exception when dup_val_on_index then
            update tleavsum set qtyshrle = v_sum_qtymin / 60,
                                qtydayle = v_sum_qtymin,
                                qtydlemx = v_qtydlemx
                          where codempid = v_tleavetr.codempid
                            and dteyear  = v_yrecycle
                            and codleave = v_tleavetr.codleave;
          end;

          --Save TLEAVSUM2--
          ----Hral82b_batch.gen_vacation(data.CODEMPID, null, trunc(sysdate), global_v_coduser, v_numrec);

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then        
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_al_tleavsum(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_al_tleavsum(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_al_tleavsum(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 6;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tleavsum       tleavsum%rowtype;
    v_temp           varchar2(1000);
    v_qtydaywk       number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1) then
        chk_len(i) := 10;  
      elsif i in (2,3) then
        chk_len(i) := 4;
      elsif i in (4,5,6) then
        chk_len(i) := 13;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tleavsum  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');   

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i in (1,2,3) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;                    

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i between 4 and 6 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;            

            if i = 3 then
              begin
                select codleave into v_temp
                  from tleavecd
                 where codleave = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TLEAVECD';
                exit cal_loop;
              end;     

              begin
                select codcomp,typpayroll
                into   v_tleavsum.codcomp,v_tleavsum.typpayroll
                from	 temploy1
                where	 codempid = upper(v_text(1));
              exception when no_data_found then
                null;
              end;
              begin
                select typleave into v_temp
                  from tleavcom
                 where typleave = (select typleave 
                                     from	 tleavecd
                                    where	 codleave = upper(v_text(i)))
                   and codcompy = hcm_util.get_codcomp_level(v_tleavsum.codcomp,1);                   
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'tleavcom';
                exit cal_loop;
              end;
            end if; 

            if i = 2 and length(v_text(i)) <> 4 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i between 4 and 6 and to_number(v_text(i)) < 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_tleavsum.codempid     := upper(v_text(1));
          v_tleavsum.dteyear      := to_number(v_text(2));
          v_tleavsum.codleave     := upper(v_text(3));          
          v_tleavsum.qtyvacat     := to_number(v_text(6));

          begin
            select typleave,staleave into v_tleavsum.typleave,v_tleavsum.staleave
            from	 tleavecd
            where	 codleave = v_tleavsum.codleave;
          exception when no_data_found then
            null;
          end;          
          if v_tleavsum.staleave = 'V' then
            v_tleavsum.qtydayle   := to_number(v_text(4));
            v_tleavsum.qtypriyr   := to_number(v_text(5));
          elsif v_tleavsum.staleave = 'C' then
            v_tleavsum.qtydleot   := to_number(v_text(4));
            v_tleavsum.qtypriot   := to_number(v_text(5));
          end if;                   

          --
          --Save TLEAVSUM--
          begin
            insert into tleavsum(codempid,dteyear,codleave,
                                 typleave,staleave,
                                 codcomp,typpayroll,qtyvacat,
                                 qtydayle,qtypriyr,
                                 qtydleot,qtypriot,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tleavsum.codempid,v_tleavsum.dteyear,v_tleavsum.codleave,
                               v_tleavsum.typleave,v_tleavsum.staleave,
                               v_tleavsum.codcomp,v_tleavsum.typpayroll,v_tleavsum.qtyvacat,
                               v_tleavsum.qtydayle,v_tleavsum.qtypriyr,
                               v_tleavsum.qtydleot,v_tleavsum.qtypriot,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          exception when dup_val_on_index then
            update tleavsum set typleave    = v_tleavsum.typleave,
                                staleave    = v_tleavsum.staleave,
                                codcomp     = v_tleavsum.codcomp,
                                typpayroll  = v_tleavsum.typpayroll,
                                qtyvacat    = v_tleavsum.qtyvacat,
                                qtydayle    = v_tleavsum.qtydayle,
                                qtypriyr    = v_tleavsum.qtypriyr,
                                qtydleot    = v_tleavsum.qtydleot,
                                qtypriot    = v_tleavsum.qtypriot,
                                dteupd      = trunc(sysdate),
                                coduser     = global_v_coduser
                          where codempid = v_tleavsum.codempid
                            and dteyear  = v_tleavsum.dteyear
                            and codleave = v_tleavsum.codleave;

          end;

          --Save Previous Year TLEAVSUM--
          if to_number(v_text(5)) = 0 then --data.qtypriyr = 0
            if v_tleavsum.staleave = 'V' then
              update tleavsum set qtydayle = qtyvacat
                            where codempid = v_tleavsum.codempid
                              and dteyear  = (v_tleavsum.dteyear - 1)
                              and codleave = v_tleavsum.codleave;
            elsif v_tleavsum.staleave = 'C' then
              update tleavsum set qtydleot = qtyvacat
                            where codempid = v_tleavsum.codempid
                              and dteyear  = (v_tleavsum.dteyear - 1)
                              and codleave = v_tleavsum.codleave;
            end if;

          else --data.qtypriyr > 0
            begin
              insert into tleavsum(codempid,dteyear,codleave,
                                   typleave,staleave,
                                   codcomp,typpayroll,qtyvacat,                                 
                                   dtecreate,codcreate,dteupd,coduser)
                        values(v_tleavsum.codempid,(v_tleavsum.dteyear - 1),v_tleavsum.codleave,
                               v_tleavsum.typleave,v_tleavsum.staleave,
                               v_tleavsum.codcomp,v_tleavsum.typpayroll,to_number(v_text(5)),                               
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

            exception when dup_val_on_index then
              update tleavsum set qtyvacat = qtydayle + to_number(v_text(5))
                            where codempid = v_tleavsum.codempid
                              and dteyear  = (v_tleavsum.dteyear - 1)
                              and codleave = v_tleavsum.codleave;
            end;
          end if;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then        
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_al_tempawrd(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_al_tempawrd(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_al_tempawrd(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 7;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tempawrd2      tempawrd2%rowtype;
    v_temp           varchar2(1000);
    v_qtyoldacc      number;
    v_qtyaccaw       number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1) then
        chk_len(i) := 10;  
      elsif i in (2,5) then
        chk_len(i) := 4;
      elsif i in (3,4) then
        chk_len(i) := 2;
      elsif i in (6,7) then
        chk_len(i) := 3;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tempawrd2  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;                    

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (2,3,4,6,7) and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;            

            if i = 5 then
              begin
                select codcodec into v_temp
                  from tcodawrd
                 where codcodec = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TCODAWRD';
                exit cal_loop;
              end;                   
            end if; 

            if i = 2 and length(v_text(i)) <> 4 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i between 2 and 4 and to_number(v_text(i)) <= 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (6,7) and to_number(v_text(i)) < 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 7 and to_number(v_text(i)) > 0 then
              if to_number(v_text(i)) - to_number(v_text(i - 1)) <> 1 then
                v_error	 	  := true;
                v_err_code  := 'AL0056';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_tempawrd2.codempid    := upper(v_text(1));
          v_tempawrd2.dteyrepay   := to_number(v_text(2));
          v_tempawrd2.dtemthpay   := to_number(v_text(3));
          v_tempawrd2.numperiod   := to_number(v_text(4));
          v_tempawrd2.codaward    := upper(v_text(5));
          v_tempawrd2.qtyoldacc   := to_number(v_text(6));
          v_tempawrd2.qtyaccaw    := to_number(v_text(7));                                        
          --
          --Save TEMPAWRD2--
          begin
            delete tempawrd2 where codempid  = v_tempawrd2.codempid
                               and dteyrepay = v_tempawrd2.dteyrepay
                               and dtemthpay = v_tempawrd2.dtemthpay
                               and numperiod = v_tempawrd2.numperiod
                               and codaward  = v_tempawrd2.codaward;

            insert into tempawrd2(codempid,codaward,
                                 dteyrepay,dtemthpay,numperiod,
                                 qtyoldacc,qtyaccaw,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tempawrd2.codempid,v_tempawrd2.codaward,
                               v_tempawrd2.dteyrepay,v_tempawrd2.dtemthpay,v_tempawrd2.numperiod,
                               v_tempawrd2.qtyoldacc,v_tempawrd2.qtyaccaw,                               
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

          --Save TEMPAWRD--
          begin
            select qtyoldacc,qtyaccaw into v_qtyoldacc,v_qtyaccaw
            from	tempawrd2
            where	codempid = v_tempawrd2.codempid
            and	  codaward = v_tempawrd2.codaward
            and	  dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') = 
                   (select max(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0')) 
                      from tempawrd2 
                     where codempid = v_tempawrd2.codempid
                       and codaward = v_tempawrd2.codaward);
          end;
          begin
            insert into tempawrd(codempid,codaward,
                                 qtyoldacc,qtyaccaw,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tempawrd2.codempid,v_tempawrd2.codaward,
                               v_qtyoldacc,v_qtyaccaw,                               
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          exception when dup_val_on_index then
            update tempawrd set qtyoldacc   = v_qtyoldacc,
                                qtyaccaw    = v_qtyaccaw,
                                dteupd      = trunc(sysdate),
                                coduser     = global_v_coduser
                          where codempid    = v_tempawrd2.codempid
                            and codaward    = v_tempawrd2.codaward;
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then      
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
--BF---------------------------------------------------------------------------------------------------------
  --
  procedure get_process_bf_tclnsinf(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_tclnsinf(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_tclnsinf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 27;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tclnsinf       tclnsinf%rowtype;
    v_temp           varchar2(1000);

    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;
    v_amtexp        number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2,9,10,11,19,20,21,23) then
        chk_len(i) := 10;  
      elsif i = 3 then
        chk_len(i) := 60;
      elsif i in (4,7,8,12,22) then
        chk_len(i) := 1;
      elsif i in (5,6,24) then
        chk_len(i) := 4;
      elsif i in (13,27) then
        chk_len(i) := 20;
      elsif i in (14,15,16,17,18) then
        chk_len(i) := 13;
      elsif i in (25,26) then
        chk_len(i) := 2;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tclnsinf  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15) := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16) := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17) := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18) := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19) := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20) := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21) := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22) := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23) := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24) := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25) := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26) := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27) := hcm_util.get_string_t(param_json_row,'col-27');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if (i in (1,2,14,22) or i between 4 and 12) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;
          if v_text(15) is null and v_text(16) is not null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(15);
            v_err_data  := v_text(15);
            exit cal_loop;
          end if;
          if v_text(16) is null and v_text(15) is not null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(16);
            v_err_data  := v_text(16);
            exit cal_loop;
          end if;

          if v_text(4) in ('S','C','F','M') and v_text(3) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(3);
            v_err_data  := v_text(3);
            exit cal_loop;
          end if;

          if upper(v_text(12)) = 'Y' and v_text(13) is null then            
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(13);
            v_err_data  := v_text(13);
            exit cal_loop;    
          end if;

          if v_text(22) = '1' and v_text(23) is null then            
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(23);
            v_err_data  := v_text(23);
            exit cal_loop;    
          elsif v_text(22) = '2' then
            if v_text(24) is null then            
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(24);
              v_err_data  := v_text(24);
              exit cal_loop; 
            elsif v_text(25) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(25);
              v_err_data  := v_text(25);
              exit cal_loop;
            elsif v_text(26) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(26);
              v_err_data  := v_text(26);
              exit cal_loop;
            end if;
          elsif v_text(22) = '3' and v_text(27) is null then            
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(27);
            v_err_data  := v_text(27);
            exit cal_loop;    
          end if;          

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (2,9,10,11,19,20,23) and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i between 14 and 18 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if v_text(22) = '2' and i between 24 and 26 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (1,21) and v_text(i) is not null then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;  

            if i = 4 and v_text(i) not in ('E','S','C','F','M') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 7 and v_text(i) not in ('1','2','3','4') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 8 and v_text(i) not in ('1','2','3','4','5','A') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 12 and v_text(i) not in ('Y','N') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 22 and v_text(i) not in ('1','2','3') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;                            

          end loop;
          ----
          /*----v_tclnsinf.codempid     := upper(v_text(1));
          v_tclnsinf.dtereq       := check_dteyre(v_text(2)); ----to_date(v_text(2),'dd/mm/yyyy');          
          v_tclnsinf.codrel       := upper(v_text(4));
          v_tclnsinf.typamt       := upper(v_text(8));
          v_tclnsinf.dtecrest     := check_dteyre(v_text(9));

          std_bf.get_medlimit(v_tclnsinf.codempid, v_tclnsinf.dtereq, v_tclnsinf.dtecrest, null, v_tclnsinf.typamt, v_tclnsinf.codrel,
                              v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, 
                              v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);

          if nvl(v_qtyacc_typ,0) > 0 or nvl(v_qtywidrwy,0) > 0 or nvl(v_qtyacc,0) > 0 then
            if nvl(v_qtyacc_typ,0) >= nvl(v_qtywidrwy,0) then
              v_error	 	  := true;
              v_err_code  := 'HR6543';
              v_err_field := v_field(25);
              v_err_data  := v_text(25);
              exit cal_loop;
            end if;
            if nvl(v_qtyacc,0) >= nvl(v_qtywidrwy,0) then
              v_error	 	  := true;
              v_err_code  := 'HR6544';
              v_err_field := v_field(25);
              v_err_data  := v_text(25);
              exit cal_loop;
            end if;
          end if;*/
          ----
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --
          begin
            select codcomp,codpos,typpayroll 
              into v_tclnsinf.codcomp,v_tclnsinf.codpos,v_tclnsinf.typpayroll
              from temploy1
             where codempid = v_tclnsinf.codempid;                  
          exception when no_data_found then null;
          end;
          hrbf16e.gen_numvcher(v_tclnsinf.codcomp, global_v_lang, v_tclnsinf.numvcher);

--          v_tclnsinf.namsick := null;
--          if v_tclnsinf.codrel = 'E' then
--            v_tclnsinf.namsick := get_temploy_name(v_tclnsinf.codempid,global_v_lang);
--          elsif v_tclnsinf.codrel = 'C' and v_text(3) is not null then
--            v_tclnsinf.namsick := v_text(3);
--          elsif v_tclnsinf.codrel = 'C' and v_text(3) is null then
--            begin
--              select decode(global_v_lang,'101',namche,
--                                          '102',namcht,
--                                          '103',namch3,
--                                          '104',namch4,
--                                          '105',namch5) namch
--              into  v_tclnsinf.namsick
--              from  tchildrn
--              where codempid = v_tclnsinf.codempid
--              and   rownum = 1
--              order by numseq;
--            exception when no_data_found then null;
--            end;
--          elsif v_tclnsinf.codrel = 'S' then
--            begin
--              select decode(global_v_lang,'101',namspe,
--                                          '102',namspt,
--                                          '103',namsp3,
--                                          '104',namsp4,
--                                          '105',namsp5) namsp
--              into  v_tclnsinf.namsick
--              from  tspouse
--              where codempid = v_tclnsinf.codempid;
--            exception when no_data_found then null;
--            end;
--          elsif v_tclnsinf.codrel = 'F' then
--            begin
--              select decode(global_v_lang,'101',namfathe,
--                                          '102',namfatht,
--                                          '103',namfath3,
--                                          '104',namfath4,
--                                          '105',namfath5) namfath
--              into  v_tclnsinf.namsick
--              from  tfamily
--              where codempid = v_tclnsinf.codempid;
--            exception when no_data_found then null;
--            end;
--          elsif v_tclnsinf.codrel = 'M' then
--            begin
--              select decode(global_v_lang,'101',nammothe,
--                                          '102',nammotht,
--                                          '103',nammoth3,
--                                          '104',nammoth4,
--                                          '105',nammoth5) nammoth
--              into  v_tclnsinf.namsick
--              from  tfamily
--              where codempid = v_tclnsinf.codempid;
--            exception when no_data_found then null;
--            end;  
--          end if;
          v_tclnsinf.codempid     := upper(v_text(1));
          v_tclnsinf.dtereq       := check_dteyre(v_text(2)); ----to_date(v_text(2),'dd/mm/yyyy');          
          v_tclnsinf.namsick      := v_text(3);
          if v_tclnsinf.codrel = 'E' then
            v_tclnsinf.namsick := get_temploy_name(v_tclnsinf.codempid,global_v_lang);
          end if;
          v_tclnsinf.codrel       := upper(v_text(4));
          v_tclnsinf.codcln       := upper(v_text(5));
          v_tclnsinf.coddc        := upper(v_text(6));
          v_tclnsinf.typpatient   := upper(v_text(7));
          v_tclnsinf.typamt       := upper(v_text(8));
          v_tclnsinf.dtecrest     := check_dteyre(v_text(9));
          v_tclnsinf.dtecreen     := check_dteyre(v_text(10));
          v_tclnsinf.dtebill      := check_dteyre(v_text(11));
          v_tclnsinf.flgdocmt     := upper(v_text(12));
          v_tclnsinf.numdocmt     := v_text(13);
          v_tclnsinf.amtexp       := to_number(v_text(14));
          v_tclnsinf.amtavai      := to_number(v_text(15));
          v_amtwidrwt             := to_number(v_text(16));
          v_tclnsinf.amtemp       := to_number(v_text(17));  
          v_tclnsinf.amtpaid      := to_number(v_text(18));
          v_tclnsinf.dtepaid      := check_dteyre(v_text(19));
          v_tclnsinf.dteappr      := check_dteyre(v_text(20));
          v_tclnsinf.codappr      := upper(v_text(21));
          v_tclnsinf.typpay       := upper(v_text(22));
          v_tclnsinf.dtecash      := check_dteyre(v_text(23));
          v_tclnsinf.dteyrepay    := check_year(to_number(v_text(24)));
          v_tclnsinf.dtemthpay    := to_number(v_text(25));
          v_tclnsinf.numperiod    := to_number(v_text(26));
          v_tclnsinf.numinvoice   := v_text(27);
          --
          if v_tclnsinf.amtavai is null then
            std_bf.get_medlimit(v_tclnsinf.codempid, v_tclnsinf.dtereq, v_tclnsinf.dtecrest, null, v_tclnsinf.typamt, v_tclnsinf.codrel,
                              v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, 
                              v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);
            v_tclnsinf.amtavai    := greatest(v_amtbal,0);            
          end if;

          if v_tclnsinf.amtavai >= v_tclnsinf.amtexp then
            v_tclnsinf.amtalw := v_tclnsinf.amtexp;
          else
            v_tclnsinf.amtalw := v_tclnsinf.amtavai;
          end if;
          if v_tclnsinf.amtalw > v_amtwidrwt and v_amtwidrwt > 0 then
            v_tclnsinf.amtalw := v_amtwidrwt;
          end if;

          v_tclnsinf.amtovrpay := v_tclnsinf.amtexp - v_tclnsinf.amtavai;
          if v_tclnsinf.amtovrpay < 0 then
            v_tclnsinf.amtovrpay := 0;
          end if;
          --
          --Save TCLNSINF--
          begin
            insert into tclnsinf(numvcher,codempid,dtereq,
                                 codcomp,codpos,typpayroll,
                                 namsick,codrel,codcln,coddc,
                                 typpatient,typamt,dtecrest,dtecreen,
                                 qtydcare,dtebill,flgdocmt,numdocmt,
                                 amtexp,amtemp,amtpaid,dtepaid,
                                 dteappr,codappr,typpay,dtecash,
                                 dteyrepay,dtemthpay,numperiod,numinvoice,
                                 amtavai,amtalw,amtovrpay,
                                 staappov,flgupd,flgtranpy,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tclnsinf.numvcher,v_tclnsinf.codempid,v_tclnsinf.dtereq,
                               v_tclnsinf.codcomp,v_tclnsinf.codpos,v_tclnsinf.typpayroll,
                               v_tclnsinf.namsick,v_tclnsinf.codrel,v_tclnsinf.codcln,v_tclnsinf.coddc,
                               v_tclnsinf.typpatient,v_tclnsinf.typamt,v_tclnsinf.dtecrest,v_tclnsinf.dtecreen,
                               v_tclnsinf.qtydcare,v_tclnsinf.dtebill,v_tclnsinf.flgdocmt,v_tclnsinf.numdocmt,
                               v_tclnsinf.amtexp,v_tclnsinf.amtemp,v_tclnsinf.amtpaid,v_tclnsinf.dtepaid,
                               v_tclnsinf.dteappr,v_tclnsinf.codappr,v_tclnsinf.typpay,v_tclnsinf.dtecash,
                               v_tclnsinf.dteyrepay,v_tclnsinf.dtemthpay,v_tclnsinf.numperiod,v_tclnsinf.numinvoice,
                               v_tclnsinf.amtavai,v_tclnsinf.amtalw,v_tclnsinf.amtovrpay,
                               'Y','Y','Y',
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);            
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --  
  procedure get_process_bf_thwccase(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_thwccase(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_thwccase(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 26;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_thwccase       thwccase%rowtype;
    v_temp           varchar2(1000);

    v_codempmt       temploy1.codempmt%type;
    v_amtincom1      temploy3.amtincom1%type;
    v_amtincom2      temploy3.amtincom2%type;
    v_amtincom3      temploy3.amtincom3%type;
    v_amtincom4      temploy3.amtincom4%type;
    v_amtincom5      temploy3.amtincom5%type;
    v_amtincom6      temploy3.amtincom6%type;
    v_amtincom7      temploy3.amtincom7%type;
    v_amtincom8      temploy3.amtincom8%type;
    v_amtincom9      temploy3.amtincom9%type;
    v_amtincom10     temploy3.amtincom10%type;
    v_sumhur         number;
    v_sumday         number;
    v_summth         number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2,8,9,10,20,21,22) then
        chk_len(i) := 10;  
      elsif i in (3) then
        chk_len(i) := 1000;
      elsif i in (4,5,6,7,15,17) then
        chk_len(i) := 4;
      elsif i in (11) then
        chk_len(i) := 100;
      elsif i in (12,14) then
        chk_len(i) := 150;
      elsif i in (13) then
        chk_len(i) := 60;
      elsif i in (16) then
        chk_len(i) := 20;
      elsif i in (18,19) then
        chk_len(i) := 13;
      elsif i in (23) then
        chk_len(i) := 15;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_thwccase  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15) := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16) := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17) := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18) := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19) := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20) := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21) := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22) := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23) := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24) := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25) := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26) := hcm_util.get_string_t(param_json_row,'col-26');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i not in (23,24,25,26) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;          

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (2,8,9,10,21,22) and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (7,18,19,24,25,26) and v_text(i) is not null and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;
            if i in (7,19,24,25) and v_text(i) is not null and to_number(v_text(i)) <= 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;
            if i in (18,26) and v_text(i) is not null and to_number(v_text(i)) < 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 7 and length(v_text(i)) <> 4 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (1,20) then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;
          end loop;
          --
          v_thwccase.dteacd       := check_dteyre(v_text(2));
          v_thwccase.dtenotifi    := check_dteyre(v_text(8));
          v_thwccase.dtestr       := check_dteyre(v_text(9));
          v_thwccase.dteend       := check_dteyre(v_text(10));
          v_thwccase.dtesmit      := check_dteyre(v_text(21));
          v_thwccase.dteadmit     := check_dteyre(v_text(22));

          if v_thwccase.dtenotifi < v_thwccase.dteacd then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(8);
            exit cal_loop;
          end if;
          if v_thwccase.dtestr < v_thwccase.dteacd then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(9);
            exit cal_loop;
          end if;
          if v_thwccase.dtesmit < v_thwccase.dteacd then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(21);
            exit cal_loop;
          end if;
          if v_thwccase.dteend < v_thwccase.dtestr then
            v_error	 	  := true;
            v_err_code  := 'HR2021';
            v_err_field := v_field(10);
            exit cal_loop;
          end if;
          --
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_thwccase.codempid     := upper(v_text(1));                    
          v_thwccase.placeacd     := v_text(3);
          v_thwccase.codprov      := upper(v_text(4));
          v_thwccase.coddist      := upper(v_text(5));
          v_thwccase.codsubdist   := upper(v_text(6));
          v_thwccase.timeacd      := v_text(7);          
          v_thwccase.desnote      := v_text(11);
          v_thwccase.resultacd    := v_text(12);
          v_thwccase.namwitness   := v_text(13);
          v_thwccase.addrwitness  := v_text(14);
          v_thwccase.codcln       := upper(v_text(15));
          v_thwccase.idpatient    := v_text(16);
          v_thwccase.codclnright  := upper(v_text(17));
          v_thwccase.amtacomp     := to_number(v_text(18));
          v_thwccase.amtpens      := to_number(v_text(19));
          v_thwccase.namappr      := v_text(20);        
          v_thwccase.numwc        := v_text(23);
          v_thwccase.amtday       := to_number(v_text(24));
          v_thwccase.amtmonth     := to_number(v_text(25));
          v_thwccase.amtother     := to_number(v_text(26));

          begin
            select codcomp,codempmt into v_thwccase.codcomp,v_codempmt
            from	 temploy1
            where	 codempid = v_thwccase.codempid;
          exception when no_data_found then
            null;
          end;

--          --find income
--          begin
--            select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
--            into   v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
--            from   temploy3
--            where  codempid = v_thwccase.codempid;
--          exception when no_data_found then
--            v_amtincom1  := '';
--            v_amtincom2  := '';
--            v_amtincom3  := '';
--            v_amtincom4  := '';
--            v_amtincom5  := '';
--            v_amtincom6  := '';
--            v_amtincom7  := '';
--            v_amtincom8  := '';
--            v_amtincom9  := '';
--            v_amtincom10 := '';
--          end;          
--          v_chken      := hcm_secur.get_v_chken; --temporary--
--          v_amtincom1  := stddec(v_amtincom1,v_thwccase.codempid,v_chken);
--          v_amtincom2  := stddec(v_amtincom2,v_thwccase.codempid,v_chken);
--          v_amtincom3  := stddec(v_amtincom3,v_thwccase.codempid,v_chken);
--          v_amtincom4  := stddec(v_amtincom4,v_thwccase.codempid,v_chken);
--          v_amtincom5  := stddec(v_amtincom5,v_thwccase.codempid,v_chken);
--          v_amtincom6  := stddec(v_amtincom6,v_thwccase.codempid,v_chken);
--          v_amtincom7  := stddec(v_amtincom7,v_thwccase.codempid,v_chken);
--          v_amtincom8  := stddec(v_amtincom8,v_thwccase.codempid,v_chken);
--          v_amtincom9  := stddec(v_amtincom9,v_thwccase.codempid,v_chken);
--          v_amtincom10 := stddec(v_amtincom10,v_thwccase.codempid,v_chken);
--          
--          get_wage_income(v_thwccase.codcomp, v_codempmt, v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5, v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, 
--                          v_sumhur, v_sumday, v_summth);
--          
--          v_thwccase.amtday := v_sumday;
--          v_thwccase.amtmonth := v_summth;
--          
--          --find other income          
--          v_thwccase.amtother := v_amtincom2 + v_amtincom3 + v_amtincom4 + v_amtincom5 + 
--                                 v_amtincom6 + v_amtincom7 + v_amtincom8 + v_amtincom9 + v_amtincom10;          
          --
          --Save THWCCASE--
          begin
            delete from thwccase where codempid = v_thwccase.codempid
                                   and dteacd   = v_thwccase.dteacd;

            insert into thwccase(codempid,dteacd,codcomp,
                                 placeacd,codprov,coddist,codsubdist,
                                 timeacd,dtenotifi,dtestr,dteend,
                                 desnote,resultacd,namwitness,addrwitness,
                                 codcln,idpatient,codclnright,
                                 amtacomp,amtpens,namappr,
                                 dtesmit,dteadmit,numwc,
                                 amtday,amtmonth,amtother,
                                 stawc,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_thwccase.codempid,v_thwccase.dteacd,v_thwccase.codcomp,
                               v_thwccase.placeacd,v_thwccase.codprov,v_thwccase.coddist,v_thwccase.codsubdist,
                               v_thwccase.timeacd,v_thwccase.dtenotifi,v_thwccase.dtestr,v_thwccase.dteend,
                               v_thwccase.desnote,v_thwccase.resultacd,v_thwccase.namwitness,v_thwccase.addrwitness,
                               v_thwccase.codcln,v_thwccase.idpatient,v_thwccase.codclnright,
                               v_thwccase.amtacomp,v_thwccase.amtpens,v_thwccase.namappr,
                               v_thwccase.dtesmit,v_thwccase.dteadmit,v_thwccase.numwc,
                               v_thwccase.amtday,v_thwccase.amtmonth,v_thwccase.amtother,
                               'F',
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_bf_tobfinf(json_str_input    in clob,
                                   json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_tobfinf(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_tobfinf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 14;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tobfinf         tobfinf%rowtype;
    v_temp            varchar2(1000);
    v_typebf          varchar2(10);
    v_amtvalue        number;
    v_sum_qtywidrw    number;
    v_sum_amtwidrw    number;
    v_sum_qtytwidrw   number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2,10) then
        chk_len(i) := 10;  
      elsif i in (3,11) then
        chk_len(i) := 4;
      elsif i in (4,9) then
        chk_len(i) := 1;
      elsif i in (5) then
        chk_len(i) := 60;
      elsif i in (6,12,13) then
        chk_len(i) := 2;
      elsif i in (7) then
        chk_len(i) := 11;
      elsif i in (8) then
        chk_len(i) := 13;
      elsif i in (14) then
        chk_len(i) := 500;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tobfinf  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i <> 5 and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop; 

          if v_text(4) in ('S','C','F') and v_text(5) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(5);
            v_err_data  := v_text(5);
            exit cal_loop;
          end if;

          if v_text(9) = '1' and v_text(10) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(10);
            v_err_data  := v_text(10);
            exit cal_loop;
          end if;
          if v_text(9) = '2' then
            if v_text(11) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(11);
              v_err_data  := v_text(11);
              exit cal_loop;
            end if;
            if v_text(12) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(12);
              v_err_data  := v_text(12);
              exit cal_loop;
            end if;
            if v_text(13) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(13);
              v_err_data  := v_text(13);
              exit cal_loop;
            end if;
          end if;

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (2,10) and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (6,7,8,11,12,13) and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 11 and length(v_text(i)) <> 4 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;            

            if i = 4 and v_text(i) not in ('E','S','C','F') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 9 and v_text(i) not in ('1','2') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --    
--          v_tobfinf.namsick := null;
--          if v_tobfinf.codrel = 'E' then
--            v_tobfinf.namsick := get_temploy_name(v_tobfinf.codempid,global_v_lang);
--          elsif v_tobfinf.codrel = 'C' and v_text(3) is not null then
--            v_tobfinf.namsick := v_text(3);
--          elsif v_tobfinf.codrel = 'C' and v_text(3) is null then
--            begin
--              select decode(global_v_lang,'101',namche,
--                                          '102',namcht,
--                                          '103',namch3,
--                                          '104',namch4,
--                                          '105',namch5) namch
--              into  v_tobfinf.namsick
--              from  tchildrn
--              where codempid = v_tobfinf.codempid
--              and   rownum = 1
--              order by numseq;
--            exception when no_data_found then null;
--            end;
--          elsif v_tobfinf.codrel = 'S' then
--            begin
--              select decode(global_v_lang,'101',namspe,
--                                          '102',namspt,
--                                          '103',namsp3,
--                                          '104',namsp4,
--                                          '105',namsp5) namsp
--              into  v_tobfinf.namsick
--              from  tspouse
--              where codempid = v_tobfinf.codempid;
--            exception when no_data_found then null;
--            end;
--          elsif v_tobfinf.codrel = 'F' then
--            begin
--              select decode(global_v_lang,'101',namfathe,
--                                          '102',namfatht,
--                                          '103',namfath3,
--                                          '104',namfath4,
--                                          '105',namfath5) namfath
--              into  v_tobfinf.namsick
--              from  tfamily
--              where codempid = v_tobfinf.codempid;
--            exception when no_data_found then null;
--            end;
--          elsif v_tobfinf.codrel = 'M' then
--            begin
--              select decode(global_v_lang,'101',nammothe,
--                                          '102',nammotht,
--                                          '103',nammoth3,
--                                          '104',nammoth4,
--                                          '105',nammoth5) nammoth
--              into  v_tobfinf.namsick
--              from  tfamily
--              where codempid = v_tobfinf.codempid;
--            exception when no_data_found then null;
--            end;  
--          end if;          
          v_tobfinf.codempid    := upper(v_text(1));
          v_tobfinf.dtereq      := check_dteyre(v_text(2));
          v_tobfinf.codobf      := upper(v_text(3));

          begin
            select codcomp into v_tobfinf.codcomp
            from	 temploy1
            where	 codempid = v_tobfinf.codempid;
          exception when no_data_found then
            null;
          end;
          v_tobfinf.numvcher := get_codcompy(v_tobfinf.codcomp)||to_char(v_tobfinf.dtereq,'yy')||to_char(v_tobfinf.dtereq,'mm');

          v_tobfinf.typrelate   := upper(v_text(4));
          v_tobfinf.nameobf     := v_text(5);
          v_tobfinf.numtsmit    := to_number(v_text(6));
          v_tobfinf.qtywidrw    := to_number(v_text(7));
          v_tobfinf.amtwidrw    := to_number(v_text(8));
          v_tobfinf.typepay     := upper(v_text(9));
          v_tobfinf.dtepay      := check_dteyre(v_text(10));
          v_tobfinf.dteyrepay   := check_year(to_number(v_text(11)));
          v_tobfinf.dtemthpay   := to_number(v_text(12));
          v_tobfinf.numperiod   := to_number(v_text(13));
          v_tobfinf.desnote     := v_text(14);

          v_tobfinf.qtyalw      := v_tobfinf.qtywidrw;

--          --find v_tobfinf.amtwidrw
--          begin
--            select typebf, amtvalue into v_typebf, v_amtvalue
--            from  tobfcde 
--            where codobf = v_tobfinf.codobf;
--          exception when others then null;
--          end;
--          if v_typebf = 'C' then
--            v_tobfinf.amtwidrw := v_tobfinf.qtywidrw;
--          else
--            v_tobfinf.amtwidrw := v_tobfinf.qtywidrw * v_amtvalue;
--          end if;

          --
          --Save TOBFINF--
          begin
            insert into tobfinf(numvcher,codempid,dtereq,
                                codobf,typrelate,nameobf,
                                numtsmit,qtywidrw,amtwidrw,typepay,
                                dtepay,dteyrepay,dtemthpay,numperiod,
                                desnote,
                                qtyalw,flgtranpy,
                                dtecreate,codcreate,dteupd,coduser)
                        values(v_tobfinf.numvcher,v_tobfinf.codempid,v_tobfinf.dtereq,
                               v_tobfinf.codobf,v_tobfinf.typrelate,v_tobfinf.nameobf,
                               v_tobfinf.numtsmit,v_tobfinf.qtywidrw,v_tobfinf.amtwidrw,v_tobfinf.typepay,
                               v_tobfinf.dtepay,v_tobfinf.dteyrepay,v_tobfinf.dtemthpay,v_tobfinf.numperiod,
                               v_tobfinf.desnote,
                               v_tobfinf.qtyalw,'Y',
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

          --Save TOBFSUM at month/year--
          begin
            select sum(qtywidrw),sum(amtwidrw),count(numtsmit)
              into v_sum_qtywidrw,v_sum_amtwidrw,v_sum_qtytwidrw
              from tobfinf
             where codempid = v_tobfinf.codempid
               and to_number(to_char(dtereq,'yyyy')) = to_number(to_char(v_tobfinf.dtereq,'yyyy'))
               and to_number(to_char(dtereq,'mm'))   = to_number(to_char(v_tobfinf.dtereq,'mm'))
               and codobf   = v_tobfinf.codobf;
          exception when no_data_found then
            v_sum_qtywidrw  := 0;
            v_sum_amtwidrw  := 0;
            v_sum_qtytwidrw := 0;
          end;
          begin
            insert into tobfsum(codempid, dteyre, dtemth, codobf,
                                qtywidrw, qtytwidrw, amtwidrw, 
                                codcomp, dtelwidrw, dtecreate,
                                codcreate, dteupd, coduser)
                       values (v_tobfinf.codempid, to_number(to_char(v_tobfinf.dtereq,'yyyy')), to_number(to_char(v_tobfinf.dtereq,'mm')), v_tobfinf.codobf,
                               v_sum_qtywidrw, v_sum_qtytwidrw, v_sum_amtwidrw,
                               v_tobfinf.codcomp, v_tobfinf.dtereq ,sysdate,
                               global_v_coduser, sysdate, global_v_coduser);

          exception when dup_val_on_index then
            update tobfsum set qtywidrw  = v_sum_qtywidrw,
                               qtytwidrw = v_sum_qtytwidrw,
                               amtwidrw	 = v_sum_amtwidrw,
                               codcomp   = v_tobfinf.codcomp,
                               dteupd    = sysdate,
                               coduser   = global_v_coduser
                         where codempid  = v_tobfinf.codempid
                           and dteyre    = to_number(to_char(v_tobfinf.dtereq,'yyyy'))
                           and dtemth    = to_number(to_char(v_tobfinf.dtereq,'mm'))
                           and codobf    = v_tobfinf.codobf;
          end;

          --Save TOBFSUM at month = 13--
          begin
            select sum(qtywidrw),sum(amtwidrw),count(numtsmit)
              into v_sum_qtywidrw,v_sum_amtwidrw,v_sum_qtytwidrw
              from tobfinf
             where codempid = v_tobfinf.codempid
               and to_number(to_char(dtereq,'yyyy')) = to_number(to_char(v_tobfinf.dtereq,'yyyy'))               
               and codobf   = v_tobfinf.codobf;
          exception when no_data_found then
            v_sum_qtywidrw  := 0;
            v_sum_amtwidrw  := 0;
            v_sum_qtytwidrw := 0;
          end;
          begin
            insert into tobfsum(codempid, dteyre, dtemth, codobf,
                                qtywidrw, qtytwidrw, amtwidrw,
                                codcomp, dtelwidrw, dtecreate,
                                codcreate, dteupd, coduser)
                       values (v_tobfinf.codempid, to_number(to_char(v_tobfinf.dtereq,'yyyy')), 13, v_tobfinf.codobf,
                               v_sum_qtywidrw, v_sum_qtytwidrw, v_sum_amtwidrw,
                               v_tobfinf.codcomp, v_tobfinf.dtereq ,sysdate,
                               global_v_coduser, sysdate, global_v_coduser);

          exception when dup_val_on_index then
            update tobfsum set qtywidrw  = v_sum_qtywidrw,
                               qtytwidrw = v_sum_qtytwidrw,
                               amtwidrw	 = v_sum_amtwidrw,
                               codcomp   = v_tobfinf.codcomp,
                               dteupd    = sysdate,
                               coduser   = global_v_coduser
                         where codempid  = v_tobfinf.codempid
                           and dteyre    = to_number(to_char(v_tobfinf.dtereq,'yyyy'))
                           and dtemth    = 13
                           and codobf    = v_tobfinf.codobf;
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_bf_ttravinf(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_ttravinf(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_ttravinf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 19;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_ttravinf       ttravinf%rowtype;
    v_temp           varchar2(1000);
    v_max_numtravrq  number;
    v_codcompy       varchar2(100);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2,7,9,16) then
        chk_len(i) := 10;  
      elsif i in (3,15) then
        chk_len(i) := 1;
      elsif i in (4) then
        chk_len(i) := 150;
      elsif i in (5,6,8,10,12,17) then
        chk_len(i) := 150;
      elsif i in (11) then
        chk_len(i) := 3;
      elsif i in (13) then
        chk_len(i) := 500;
      elsif i in (14) then
        chk_len(i) := 13;
      elsif i in (18,19) then
        chk_len(i) := 2;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_ttravinf  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'codempid');
        v_text(2) := hcm_util.get_string_t(param_json_row,'dtereq');
        v_text(3) := hcm_util.get_string_t(param_json_row,'typetrav');
        v_text(4) := hcm_util.get_string_t(param_json_row,'location');
        v_text(5) := hcm_util.get_string_t(param_json_row,'codprov');
        v_text(6) := hcm_util.get_string_t(param_json_row,'codcnty');
        v_text(7) := hcm_util.get_string_t(param_json_row,'dtestrt');
        v_text(8) := hcm_util.get_string_t(param_json_row,'timstrt');
        v_text(9) := hcm_util.get_string_t(param_json_row,'dteend');
        v_text(10) := hcm_util.get_string_t(param_json_row,'timend');
        v_text(11) := hcm_util.get_string_t(param_json_row,'qtyday');
        v_text(12) := hcm_util.get_string_t(param_json_row,'qtydistance');
        v_text(13) := hcm_util.get_string_t(param_json_row,'remark');
        v_text(14) := hcm_util.get_string_t(param_json_row,'amtreq');
        v_text(15) := hcm_util.get_string_t(param_json_row,'typepay');
        v_text(16) := hcm_util.get_string_t(param_json_row,'dtepay');
        v_text(17) := hcm_util.get_string_t(param_json_row,'dteyrepay');
        v_text(18) := hcm_util.get_string_t(param_json_row,'dtemthpay');
        v_text(19) := hcm_util.get_string_t(param_json_row,'numperiod');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i in (1,2,3,4,7,9,11,12,13,14,15) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;          

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (2,7,9,16) and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (8,10,11,12,14,17,18,19) and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 and v_text(i) is not null then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;  

            if i in (11,12,14,17,18,19) and v_text(i) is not null and to_number(v_text(i)) < 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;              
            end if; 

            if i = 3 and v_text(i) not in ('I','O') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 15 and v_text(i) not in ('1','2') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (8,10,17) and length(v_text(i)) <> 4 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;              
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          -- 
          v_ttravinf.codempid     := upper(v_text(1));

          begin
            select codcomp,hcm_util.get_codcomp_level(codcomp,1) into v_ttravinf.codcomp,v_codcompy
            from	 temploy1
            where	 codempid = v_ttravinf.codempid;
          exception when no_data_found then
            null;
          end;
          begin
            select max(numtravrq)
            into   v_max_numtravrq
            from   ttravinf
            where  numtravrq like v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')||'%';
          end;
          if v_max_numtravrq is null then
            v_max_numtravrq := v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')||'0000';
          end if;
          v_ttravinf.numtravrq := v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')
                                  ||lpad(substr(v_max_numtravrq, -4, 4) + 1,4,'0'); 

          begin
            select codinctv into v_ttravinf.codpay
            from   tcontrbf 
            where  codcompy = v_codcompy
            and    dteeffec = (select max(dteeffec) 
                              from    tcontrbf 
                              where   codcompy = v_codcompy
                              and     dteeffec  <= sysdate);
          exception when no_data_found then
            v_ttravinf.codpay := null;
          end;

          v_ttravinf.dtereq       := check_dteyre(v_text(2));
          v_ttravinf.typetrav     := upper(v_text(3));
          v_ttravinf.location     := v_text(4);
          v_ttravinf.codprov      := upper(v_text(5));
          v_ttravinf.codcnty      := upper(v_text(6));
          v_ttravinf.dtestrt      := check_dteyre(v_text(7));
          v_ttravinf.timstrt      := v_text(8);
          v_ttravinf.dteend       := check_dteyre(v_text(9));
          v_ttravinf.timend       := v_text(10);
          v_ttravinf.qtyday       := to_number(v_text(11));
          v_ttravinf.qtydistance  := to_number(v_text(12));
          v_ttravinf.remark       := v_text(13);
          v_ttravinf.amtreq       := to_number(v_text(14));
          v_ttravinf.typepay      := upper(v_text(15));
          v_ttravinf.dtepay       := check_dteyre(v_text(16));
          v_ttravinf.dteyrepay    := check_year(to_number(v_text(17)));
          v_ttravinf.dtemthpay    := to_number(v_text(18));
          v_ttravinf.numperiod    := to_number(v_text(19));
          --
          --Save TTRAVINF--
          begin
            --delete from ttravinf where codempid = v_ttravinf.codempid
            --                       and dtereq   = v_ttravinf.dtereq;

            insert into ttravinf(numtravrq,codempid,dtereq,
                                codcomp,codpay,
                                typetrav,location,codprov,codcnty,
                                dtestrt,timstrt,dteend,timend,
                                qtyday,qtydistance,remark,amtreq,
                                typepay,dtepay,
                                dteyrepay,dtemthpay,numperiod,
                                flgvoucher,flgtranpy,
                                dtecreate,codcreate,dteupd,coduser)
                        values(v_ttravinf.numtravrq,v_ttravinf.codempid,v_ttravinf.dtereq,
                               v_ttravinf.codcomp,v_ttravinf.codpay,
                               v_ttravinf.typetrav,v_ttravinf.location,v_ttravinf.codprov,v_ttravinf.codcnty,
                               v_ttravinf.dtestrt,v_ttravinf.timstrt,v_ttravinf.dteend,v_ttravinf.timend,
                               v_ttravinf.qtyday,v_ttravinf.qtydistance,v_ttravinf.remark,v_ttravinf.amtreq,
                               v_ttravinf.typepay,v_ttravinf.dtepay,
                               v_ttravinf.dteyrepay,v_ttravinf.dtemthpay,v_ttravinf.numperiod,
                               'N','N',
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then        
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_bf_thisheal(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_thisheal(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_thisheal(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 24;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_thisheal       thisheal%rowtype;
    v_temp           varchar2(1000);
    v_qtydaywk       number;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1) then
        chk_len(i) := 10;  
      elsif i in (2,4,6,8,10,12,14,16,21) then
        chk_len(i) := 1;
      elsif i in (3,5,7,9,11,13,15) then
        chk_len(i) := 200;
      elsif i in (17,18,20,22) then
        chk_len(i) := 3;
      elsif i in (19,23) then
        chk_len(i) := 5;
      elsif i in (24) then
        chk_len(i) := 500;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_thisheal  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'codempid');
        v_text(2) := hcm_util.get_string_t(param_json_row,'flgheal1');
        v_text(3) := hcm_util.get_string_t(param_json_row,'remark1');
        v_text(4) := hcm_util.get_string_t(param_json_row,'flgheal2');
        v_text(5) := hcm_util.get_string_t(param_json_row,'remark2');
        v_text(6) := hcm_util.get_string_t(param_json_row,'flgheal3');
        v_text(7) := hcm_util.get_string_t(param_json_row,'remark3');
        v_text(8) := hcm_util.get_string_t(param_json_row,'flgheal4');
        v_text(9) := hcm_util.get_string_t(param_json_row,'remark4');
        v_text(10) := hcm_util.get_string_t(param_json_row,'flgheal5');
        v_text(11) := hcm_util.get_string_t(param_json_row,'remark5');
        v_text(12) := hcm_util.get_string_t(param_json_row,'flgheal6');
        v_text(13) := hcm_util.get_string_t(param_json_row,'remark6');
        v_text(14) := hcm_util.get_string_t(param_json_row,'flgheal7');
        v_text(15) := hcm_util.get_string_t(param_json_row,'remark7');
        v_text(16) := hcm_util.get_string_t(param_json_row,'flgheal8');
        v_text(17) := hcm_util.get_string_t(param_json_row,'qtysmoke');
        v_text(18) := hcm_util.get_string_t(param_json_row,'qtyyear8');
        v_text(19) := hcm_util.get_string_t(param_json_row,'qtymth8');
        v_text(20) := hcm_util.get_string_t(param_json_row,'qtysmoke2');
        v_text(21) := hcm_util.get_string_t(param_json_row,'flgheal9');
        v_text(22) := hcm_util.get_string_t(param_json_row,'qtyyear9');
        v_text(23) := hcm_util.get_string_t(param_json_row,'qtymth9');
        v_text(24) := hcm_util.get_string_t(param_json_row,'desnote');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i in (1,2,4,6,8,10,12,14,16,21) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
            if i in (2,4,6,8,10,12,14) then
              if v_text(i) = '1' and v_text(i+1) is null then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(i+1);
                v_err_data  := v_text(i+1);
                exit cal_loop;
              end if;
            end if;
          end loop;   

          if v_text(16) in ('1','2') then
            if v_text(17) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(17);
              v_err_data  := v_text(17);
              exit cal_loop;
            end if;
            if v_text(18) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(18);
              v_err_data  := v_text(18);
              exit cal_loop;
            end if;
            if v_text(19) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(19);
              v_err_data  := v_text(19);
              exit cal_loop;
            end if;
          end if;
          if v_text(16) = '2' and v_text(20) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(20);
            v_err_data  := v_text(20);
            exit cal_loop;            
          end if;
          if v_text(21) <> '0' then
            if v_text(22) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(22);
              v_err_data  := v_text(22);
              exit cal_loop;
            end if;
            if v_text(23) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(23);
              v_err_data  := v_text(23);
              exit cal_loop;
            end if;
          end if;

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (17,18,19,20,22,23) and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --            
          v_thisheal.codempid     := upper(v_text(1));          
          v_thisheal.flgheal1     := upper(v_text(2));
          v_thisheal.remark1      := v_text(3);
          v_thisheal.flgheal2     := upper(v_text(4));
          v_thisheal.remark2      := v_text(5);
          v_thisheal.flgheal3     := upper(v_text(6));
          v_thisheal.remark3      := v_text(7);
          v_thisheal.flgheal4     := upper(v_text(8));
          v_thisheal.remark4      := v_text(9);
          v_thisheal.flgheal5     := upper(v_text(10));
          v_thisheal.remark5      := v_text(11);
          v_thisheal.flgheal6     := upper(v_text(12));
          v_thisheal.remark6      := v_text(13);
          v_thisheal.flgheal7     := upper(v_text(14));
          v_thisheal.remark7      := v_text(15);
          v_thisheal.flgheal8     := upper(v_text(16));
          v_thisheal.qtysmoke     := v_text(17);
          v_thisheal.qtyyear8     := v_text(18);
          v_thisheal.qtymth8      := v_text(19);
          v_thisheal.qtysmoke2    := v_text(20);
          v_thisheal.flgheal9     := upper(v_text(21));
          v_thisheal.qtyyear9     := v_text(22);
          v_thisheal.qtymth9      := v_text(23);
          v_thisheal.desnote      := v_text(24);         
          --
          --Save THISHEAL--
          begin
            delete from thisheal where codempid = v_thisheal.codempid;

            insert into thisheal(codempid,flgheal1,remark1,
                                 flgheal2,remark2,
                                 flgheal3,remark3,
                                 flgheal4,remark4,
                                 flgheal5,remark5,
                                 flgheal6,remark6,
                                 flgheal7,remark7,
                                 flgheal8,qtysmoke,
                                 qtyyear8,qtymth8,qtysmoke2,
                                 flgheal9,qtyyear9,qtymth9,
                                 desnote,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_thisheal.codempid,v_thisheal.flgheal1,v_thisheal.remark1,
                               v_thisheal.flgheal2,v_thisheal.remark2,
                               v_thisheal.flgheal3,v_thisheal.remark3,
                               v_thisheal.flgheal4,v_thisheal.remark4,
                               v_thisheal.flgheal5,v_thisheal.remark5,
                               v_thisheal.flgheal6,v_thisheal.remark6,
                               v_thisheal.flgheal7,v_thisheal.remark7,
                               v_thisheal.flgheal8,v_thisheal.qtysmoke,
                               v_thisheal.qtyyear8,v_thisheal.qtymth8,v_thisheal.qtysmoke2,
                               v_thisheal.flgheal9,v_thisheal.qtyyear9,v_thisheal.qtymth9,
                               v_thisheal.desnote,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  procedure get_process_bf_tloaninf(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_tloaninf(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_tloaninf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 36;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tloaninf       tloaninf%rowtype;
    v_temp           varchar2(1000);
    v_max_numtravrq  number;
    v_codcompy       varchar2(100);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i = 1 then
        chk_len(i) := 20; 
      elsif i in (2,6,7,16,26,27,28,30) then
        chk_len(i) := 10;  
      elsif i in (3,23,32) then
        chk_len(i) := 4;
      elsif i in (4,14,15,25,31,34) then
        chk_len(i) := 1;
      elsif i in (5) then
        chk_len(i) := 6;
      elsif i in (8,9,21) then
        chk_len(i) := 3;
      elsif i in (10,11,12,18,19,20,22,35,36) then
        chk_len(i) := 12;
      elsif i in (13,17,29) then
        chk_len(i) := 500;
      elsif i in (24,33) then
        chk_len(i) := 2;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tloaninf  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15) := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16) := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17) := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18) := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19) := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20) := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21) := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22) := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23) := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24) := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25) := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26) := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27) := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28) := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29) := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30) := hcm_util.get_string_t(param_json_row,'col-30');
        v_text(31) := hcm_util.get_string_t(param_json_row,'col-31');
        v_text(32) := hcm_util.get_string_t(param_json_row,'col-32');
        v_text(33) := hcm_util.get_string_t(param_json_row,'col-33');
        v_text(34) := hcm_util.get_string_t(param_json_row,'col-34');
        v_text(35) := hcm_util.get_string_t(param_json_row,'col-35');
        v_text(36) := hcm_util.get_string_t(param_json_row,'col-36');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i in (1,2,3,6,8,9,10,14,15,19,31,32,33,34) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop; 
          if v_text(4) is null and v_text(5) is not null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(4);
            v_err_data  := v_text(4);
            exit cal_loop;
          end if;
          if v_text(5) is null and v_text(4) is not null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(5);
            v_err_data  := v_text(5);
            exit cal_loop;
          end if;

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (6,7,16,26,27) and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if (i in (5,8,9,10,11,12) 
            or i between 18 and 25 
            or i between 32 and 36) 
            and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;           

            if i in (2,28) and v_text(i) is not null then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;  

            if (i in (5,8,9,10,11,12) 
            or i between 18 and 25 
            or i between 32 and 36) 
            and v_text(i) is not null 
            and to_number(v_text(i)) < 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;              
            end if; 

            if i in (4,14) and v_text(i) not in ('1','2','3') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 15 and v_text(i) not in ('N','P','C') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 31 and v_text(i) not in ('1','2') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (8,10,17) and length(v_text(i)) <> 4 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;              
            end if;

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          -- 
          v_tloaninf.numcont      := v_text(1);
          v_tloaninf.codempid     := upper(v_text(2));

          begin
            select codcomp,typpayroll into v_tloaninf.codcomp,v_tloaninf.typpayroll
            from	 temploy1
            where	 codempid = v_tloaninf.codempid;
          exception when no_data_found then
            null;
          end;

          v_tloaninf.codlon     := upper(v_text(3));
          v_tloaninf.typintr    := upper(v_text(4));
          if v_tloaninf.typintr is null then
            begin
              select typintr into v_tloaninf.typintr 
              from   tintrteh a
              where  codcompy = hcm_util.get_codcomp_level(v_tloaninf.codcomp,1)
              and    codlon	  = v_tloaninf.codlon
              and    dteeffec = (select max(dteeffec)
                                 from   tintrteh b
                                 where  b.codcompy = a.codcompy
                                 and    b.codlon   = a.codlon);
            exception when no_data_found then
              v_tloaninf.typintr := null;
            end;
          end if;
          v_tloaninf.rateilon   := to_number(v_text(5));
          if v_tloaninf.rateilon is null then
            begin
              select rateilon into v_tloaninf.rateilon
              from   tintrted a
              where  codcompy = hcm_util.get_codcomp_level(v_tloaninf.codcomp,1)
              and    codlon	  = v_tloaninf.codlon
              and    dteeffec = (select max(dteeffec)
                                 from   tintrteh b
                                 where  b.codcompy = a.codcompy
                                 and    b.codlon   = a.codlon)
              and    v_tloaninf.amtlon  >= amtlon;
            exception when no_data_found then
              v_tloaninf.rateilon := null;
            end;
          end if;
          v_tloaninf.dtelonst   := check_dteyre(v_text(6));
          v_tloaninf.dtestcal   := check_dteyre(v_text(7));
          v_tloaninf.numlon     := to_number(v_text(8));
          v_tloaninf.qtyperiod  := to_number(v_text(9));
          v_tloaninf.amttlpay   := to_number(v_text(10));
          v_tloaninf.amtpaybo   := to_number(v_text(11));
          v_tloaninf.amtiflat   := to_number(v_text(12));
          v_tloaninf.reaslon    := v_text(13);
          v_tloaninf.typpay     := upper(v_text(14));
          v_tloaninf.stalon     := upper(v_text(15));
          v_tloaninf.dteaccls   := check_dteyre(v_text(16));
          v_tloaninf.desaccls   := v_text(17);
          v_tloaninf.amttotpay  := to_number(v_text(18));
          v_tloaninf.amtlon     := to_number(v_text(19));
          v_tloaninf.amtnpfin   := to_number(v_text(20));
          v_tloaninf.qtyperip   := to_number(v_text(21));
          v_tloaninf.amtintovr  := to_number(v_text(22));
          v_tloaninf.yrelcal    := to_number(v_text(23));
          v_tloaninf.mthlcal    := to_number(v_text(24));
          v_tloaninf.prdlcal    := to_number(v_text(25));
          v_tloaninf.dtelpay    := check_dteyre(v_text(26));
          v_tloaninf.dteappr    := check_dteyre(v_text(27));
          v_tloaninf.codappr    := upper(v_text(28));
          v_tloaninf.remarkap   := v_text(29);
          v_tloaninf.codreq     := upper(v_text(30));
          v_tloaninf.typpayamt  := upper(v_text(31));
          v_tloaninf.dteyrpay   := to_number(v_text(32));
          v_tloaninf.mthpay     := to_number(v_text(33));
          v_tloaninf.prdpay     := to_number(v_text(34));
          v_tloaninf.amtitotflat := to_number(v_text(35));
          v_tloaninf.amtpflat   := to_number(v_text(36));

          v_tloaninf.dtelonen   := add_months(v_tloaninf.dtelonst,v_tloaninf.numlon);
          v_tloaninf.dtestcal   := nvl(v_tloaninf.dtestcal,v_tloaninf.dtelonst);
          --
          --Save TLOANINF--
          begin
            delete from tloaninf where numcont  = v_tloaninf.numcont
                                   and codempid = v_tloaninf.codempid;

            insert into tloaninf(numcont,codempid,
                                 codlon,typintr,rateilon,
                                 dtelonst,dtelonen,dtestcal,
                                 numlon,qtyperiod,
                                 amttlpay,amtpaybo,amtiflat,
                                 reaslon,typpay,stalon,
                                 dteaccls,desaccls,
                                 amttotpay,amtlon,amtnpfin,
                                 qtyperip,amtintovr,
                                 yrelcal,mthlcal,prdlcal,dtelpay,
                                 dteappr,codappr,remarkap,codreq,
                                 typpayamt,dteyrpay,mthpay,prdpay,
                                 amtitotflat,amtpflat,
                                 dtecreate,codcreate,dteupd,coduser)
                        values(v_tloaninf.numcont,v_tloaninf.codempid,
                               v_tloaninf.codlon,v_tloaninf.typintr,v_tloaninf.rateilon,
                               v_tloaninf.dtelonst,v_tloaninf.dtelonen,v_tloaninf.dtestcal,
                               v_tloaninf.numlon,v_tloaninf.qtyperiod,
                               v_tloaninf.amttlpay,v_tloaninf.amtpaybo,v_tloaninf.amtiflat,
                               v_tloaninf.reaslon,v_tloaninf.typpay,v_tloaninf.stalon,
                               v_tloaninf.dteaccls,v_tloaninf.desaccls,
                               v_tloaninf.amttotpay,v_tloaninf.amtlon,v_tloaninf.amtnpfin,
                               v_tloaninf.qtyperip,v_tloaninf.amtintovr,
                               v_tloaninf.yrelcal,v_tloaninf.mthlcal,v_tloaninf.prdlcal,v_tloaninf.dtelpay,
                               v_tloaninf.dteappr,v_tloaninf.codappr,v_tloaninf.remarkap,v_tloaninf.codreq,
                               v_tloaninf.typpayamt,v_tloaninf.dteyrpay,v_tloaninf.mthpay,v_tloaninf.prdpay,
                               v_tloaninf.amtitotflat,v_tloaninf.amtpflat,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  -- 
  procedure get_process_bf_tinsrer(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_bf_tinsrer(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_bf_tinsrer(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 14;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tinsrer       tinsrer%rowtype;
    v_temp           varchar2(1000);
    v_max_numtravrq  number;
    v_codcompy       varchar2(100);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,5,6) then
        chk_len(i) := 10;  
      elsif i in (2) then
        chk_len(i) := 15;
      elsif i in (3) then
        chk_len(i) := 4;
      elsif i in (4,8,9,14) then
        chk_len(i) := 1;
      elsif i in (7,10,11,12,13) then
        chk_len(i) := 11;      
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tinsrer   := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;          

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (5,6) and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2015';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (7,10,11,12,13) and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 1 and v_text(i) is not null then
              begin
                select codempid into v_temp
                  from temploy1
                 where codempid = upper(v_text(i));                  
              exception when no_data_found then 
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_field := v_field(i);
                v_err_table := 'TEMPLOY1';
                exit cal_loop;
              end;                
            end if;  

            if i in (7,10,11,12,13) and v_text(i) is not null and to_number(v_text(i)) < 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;              
            end if; 

            if i = 4 and v_text(i) not in ('1','4') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (8,9) and v_text(i) not in ('Y','N') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 14 and v_text(i) not in ('1','2') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;            

          end loop;
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          -- 
          v_tinsrer.codempid     := upper(v_text(1));

          begin
            select codcomp,typpayroll into v_tinsrer.codcomp,v_tinsrer.typpayroll
            from	 temploy1
            where	 codempid = v_tinsrer.codempid;
          exception when no_data_found then
            null;
          end;

          v_tinsrer.numisr       := v_text(2);
          v_tinsrer.codisrp      := upper(v_text(3));
          v_tinsrer.flgisr       := upper(v_text(4));
          v_tinsrer.dtehlpst     := check_dteyre(v_text(5));
          v_tinsrer.dtehlpen     := check_dteyre(v_text(6));          
          v_tinsrer.amtisrp      := to_number(v_text(7));
          v_tinsrer.codecov      := upper(v_text(8));
          v_tinsrer.codfcov      := upper(v_text(9));
          v_tinsrer.amtpmiumme   := to_number(v_text(10));
          v_tinsrer.amtpmiumye   := to_number(v_text(11));
          v_tinsrer.amtpmiummc   := to_number(v_text(12));
          v_tinsrer.amtpmiumyc   := to_number(v_text(13));
          v_tinsrer.flgemp       := upper(v_text(14));
          --
          --Save TINSRER--
          begin
            delete from tinsrer where codempid = v_tinsrer.codempid
                                  and numisr   = v_tinsrer.numisr;

            insert into tinsrer(codempid,numisr,
                                codcomp,typpayroll,
                                codisrp,flgisr,dtehlpst,dtehlpen,
                                amtisrp,codecov,codfcov,
                                amtpmiumme,amtpmiumye,
                                amtpmiummc,amtpmiumyc,
                                flgemp,
                                dtecreate,codcreate,dteupd,coduser)
                        values(v_tinsrer.codempid,v_tinsrer.numisr,
                               v_tinsrer.codcomp,v_tinsrer.typpayroll,
                               v_tinsrer.codisrp,v_tinsrer.flgisr,v_tinsrer.dtehlpst,v_tinsrer.dtehlpen,
                               v_tinsrer.amtisrp,v_tinsrer.codecov,v_tinsrer.codfcov,
                               v_tinsrer.amtpmiumme,v_tinsrer.amtpmiumye,
                               v_tinsrer.amtpmiummc,v_tinsrer.amtpmiumyc,
                               v_tinsrer.flgemp,
                               trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);          
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then        
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end;  
  --
  --TR---------------------------------------------------------------------------------------------------------
  --
  procedure get_process_tr_tcourse(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_tr_tcourse(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_tr_tcourse(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 30;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tcourse        tcourse%rowtype;
    v_temp           varchar2(1000);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,12,17,19) then
        chk_len(i) := 6;  
      elsif i in (2,3,7,8,10) then
        chk_len(i) := 200;
      elsif i in (4,9,23,27) then
        chk_len(i) := 4;
      elsif i in (5,15,16,20,21,25,26) then
        chk_len(i) := 1000;
      elsif i in (6) then
        chk_len(i) := 2;
      elsif i in (11,13) then
        chk_len(i) := 10;
      elsif i in (14,29,30) then
        chk_len(i) := 1;
      elsif i in (18) then
        chk_len(i) := 3;
      elsif i in (24) then
        chk_len(i) := 9;
      elsif i in (28) then
        chk_len(i) := 40;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tcourse  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15) := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16) := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17) := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18) := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19) := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20) := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21) := hcm_util.get_string_t(param_json_row,'col-21');
        v_text(22) := hcm_util.get_string_t(param_json_row,'col-22');
        v_text(23) := hcm_util.get_string_t(param_json_row,'col-23');
        v_text(24) := hcm_util.get_string_t(param_json_row,'col-24');
        v_text(25) := hcm_util.get_string_t(param_json_row,'col-25');
        v_text(26) := hcm_util.get_string_t(param_json_row,'col-26');
        v_text(27) := hcm_util.get_string_t(param_json_row,'col-27');
        v_text(28) := hcm_util.get_string_t(param_json_row,'col-28');
        v_text(29) := hcm_util.get_string_t(param_json_row,'col-29');
        v_text(30) := hcm_util.get_string_t(param_json_row,'col-30');

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if (i in (9,14,17,23,29) or i between 1 and 6) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;

          if upper(v_text(14)) = 'Y' and v_text(15) is null then            
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(15);
            v_err_data  := v_text(15);
            exit cal_loop;    
          end if;          

          if upper(v_text(29)) = 'Y' and v_text(30) is null then            
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(30);
            v_err_data  := v_text(30);
            exit cal_loop;    
          end if;                  

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i in (17,18,19,23,24) and v_text(i) is not null then
              if check_number(v_text(i)) then
                v_error	 	  := true;
                v_err_code  := 'HR2020';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;

              if to_number(v_text(i)) <= 0 then
                v_error	 	  := true;
                v_err_code  := 'HR2020';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;
            end if;

            if i in (14,29) and upper(v_text(i)) not in ('Y','N') then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;
          end loop;

          if v_text(13) is not null then
            begin
              select codempid into v_temp
                from temploy1
               where codempid = upper(v_text(13));                  
            exception when no_data_found then 
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(13);
              v_err_table := 'TEMPLOY1';
              exit cal_loop;
            end;                
          end if;  

          if v_text(28) is not null then
            begin
              select codcomp into v_temp
                from tcenter
               where codcomp = upper(v_text(28));                  
            exception when no_data_found then 
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(28);
              v_err_table := 'TCENTER';
              exit cal_loop;
            end;                
          end if;

          if upper(v_text(6)) not in ('10','11','12') then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(6);
            exit cal_loop;
          end if;

          if upper(v_text(9)) not in ('C','G','S','O') then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(9);
            exit cal_loop;
          end if;

          if v_text(30) is not null and upper(v_text(30)) not in ('Y','N') then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(30);
            exit cal_loop;
          end if;                                    
          ----
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --          
          v_tcourse.codcours    := upper(v_text(1));          
          v_tcourse.namcourse   := v_text(2);
          v_tcourse.namcourst   := v_text(3);
          v_tcourse.codcate     := upper(v_text(4));
          v_tcourse.descours    := v_text(5);
          v_tcourse.typtrain    := upper(v_text(6));
          v_tcourse.url1        := v_text(7);
          v_tcourse.url2        := v_text(8);
          v_tcourse.coddevp     := upper(v_text(9));
          v_tcourse.descdevp    := v_text(10);
          v_tcourse.codinst     := upper(v_text(11));
          v_tcourse.codsubj     := upper(v_text(12));
          v_tcourse.codconslt   := upper(v_text(13));
          v_tcourse.flgcommt    := v_text(14);
          v_tcourse.descommt    := v_text(15);
          v_tcourse.descommt2   := v_text(16);
          v_tcourse.qtytrhur    := to_number(v_text(17));
          v_tcourse.qtytrflw    := to_number(v_text(18));
          v_tcourse.qtytrday    := to_number(v_text(19));
          v_tcourse.descobjt    := v_text(20);
          v_tcourse.descbenefit := v_text(21);
          v_tcourse.codresp     := upper(v_text(22));
          v_tcourse.qtyppc      := to_number(v_text(23));
          v_tcourse.amtbudg     := to_number(v_text(24));
          v_tcourse.desceval    := v_text(25);
          v_tcourse.desmeasure  := v_text(26);
          v_tcourse.codform     := upper(v_text(27));
          v_tcourse.codcomptr   := upper(v_text(28));
          v_tcourse.flgelern    := upper(v_text(29));
          v_tcourse.typcours    := upper(v_text(30));
          --                    
          --Save TCOURSE--
          begin
            delete tcourse where codcours = v_tcourse.codcours;

            insert into tcourse(codcours,
                                namcourse,namcourst,namcours3,namcours4,namcours5,
                                codcate,descours,typtrain,
                                url1,url2,
                                coddevp,descdevp,
                                codinst,codsubj,codconslt,
                                flgcommt,descommt,descommt2,
                                qtytrhur,qtytrflw,qtytrday,
                                descobjt,descbenefit,codresp,
                                qtyppc,amtbudg,
                                desceval,desmeasure,
                                codform,codcomptr,
                                flgelern,typcours,
                                dtecreate,codcreate,dteupd,coduser)
                        values( v_tcourse.codcours,
                                v_tcourse.namcourse,v_tcourse.namcourst,v_tcourse.namcours3,v_tcourse.namcours4,v_tcourse.namcours5,
                                v_tcourse.codcate,v_tcourse.descours,v_tcourse.typtrain,
                                v_tcourse.url1,v_tcourse.url2,
                                v_tcourse.coddevp,v_tcourse.descdevp,
                                v_tcourse.codinst,v_tcourse.codsubj,v_tcourse.codconslt,
                                v_tcourse.flgcommt,v_tcourse.descommt,v_tcourse.descommt2,
                                v_tcourse.qtytrhur,v_tcourse.qtytrflw,v_tcourse.qtytrday,
                                v_tcourse.descobjt,v_tcourse.descbenefit,v_tcourse.codresp,
                                v_tcourse.qtyppc,v_tcourse.amtbudg,
                                v_tcourse.desceval,v_tcourse.desmeasure,
                                v_tcourse.codform,v_tcourse.codcomptr,
                                v_tcourse.flgelern,v_tcourse.typcours,
                                trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end; 
  --
  procedure get_process_tr_tinstruc(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_tr_tinstruc(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_tr_tinstruc(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 21;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tinstruc       tinstruc%rowtype;
    v_temp           varchar2(1000);

    v_codcomp        varchar2(40);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,12,17,19) then
        chk_len(i) := 6;  
      elsif i in (2,3,7,8,10) then
        chk_len(i) := 200;
      elsif i in (4,9,23,27) then
        chk_len(i) := 4;
      elsif i in (5,15,16,20,21,25,26) then
        chk_len(i) := 1000;
      elsif i in (6) then
        chk_len(i) := 2;
      elsif i in (11,13) then
        chk_len(i) := 10;
      elsif i in (14,29,30) then
        chk_len(i) := 1;
      elsif i in (18) then
        chk_len(i) := 3;
      elsif i in (24) then
        chk_len(i) := 9;
      elsif i in (28) then
        chk_len(i) := 40;
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tinstruc  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');
        v_text(5) := hcm_util.get_string_t(param_json_row,'col-5');
        v_text(6) := hcm_util.get_string_t(param_json_row,'col-6');
        v_text(7) := hcm_util.get_string_t(param_json_row,'col-7');
        v_text(8) := hcm_util.get_string_t(param_json_row,'col-8');
        v_text(9) := hcm_util.get_string_t(param_json_row,'col-9');
        v_text(10) := hcm_util.get_string_t(param_json_row,'col-10');
        v_text(11) := hcm_util.get_string_t(param_json_row,'col-11');
        v_text(12) := hcm_util.get_string_t(param_json_row,'col-12');
        v_text(13) := hcm_util.get_string_t(param_json_row,'col-13');
        v_text(14) := hcm_util.get_string_t(param_json_row,'col-14');
        v_text(15) := hcm_util.get_string_t(param_json_row,'col-15');
        v_text(16) := hcm_util.get_string_t(param_json_row,'col-16');
        v_text(17) := hcm_util.get_string_t(param_json_row,'col-17');
        v_text(18) := hcm_util.get_string_t(param_json_row,'col-18');
        v_text(19) := hcm_util.get_string_t(param_json_row,'col-19');
        v_text(20) := hcm_util.get_string_t(param_json_row,'col-20');
        v_text(21) := hcm_util.get_string_t(param_json_row,'col-21');         

        -- push row values
        data_file := null; ----
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if i in (1,7,18) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;

            if upper(v_text(7)) = 'E' and i in (3,4,5,6) and v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;  

          if upper(v_text(7)) = 'I' and v_text(8) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(8);
            v_err_data  := v_text(8);
            exit cal_loop;
          end if;

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 19 and v_text(i) is not null then
              if check_number(v_text(i)) then
                v_error	 	  := true;
                v_err_code  := 'HR2020';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;

              if to_number(v_text(i)) <= 0 then
                v_error	 	  := true;
                v_err_code  := 'HR2020';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;
            end if;
          end loop;

          if upper(v_text(7)) not in ('I','E') then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(7);
            exit cal_loop;
          end if;

          if upper(v_text(7)) = 'E' and v_text(2) is not null 
          and upper(v_text(2)) not in ('3','4','5') then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(2);
            exit cal_loop;     
          end if;                    

          begin
            select codempid into v_temp
              from temploy1
             where codempid = upper(v_text(8));                  
          exception when no_data_found then 
            v_error	 	  := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(8);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;  

          if upper(v_text(18)) not in ('1','2') then
            v_error	 	  := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(18);
            exit cal_loop;
          end if;                                                        
          ----
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --          
          v_tinstruc.codinst    := upper(v_text(1)); 
          v_tinstruc.stainst     := upper(v_text(7));
          if v_tinstruc.stainst = 'I' then
            v_tinstruc.codempid    := upper(v_text(8));
            begin
                select codcomp,codprovc,coddistc,codsubdistc,get_tpostn_name(codpos, global_v_lang),
                       numtelec,email,lineid,
                       namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                       namlaste,namlastt,namlast3,namlast4,namlast5,
                       namempe,namempt,namemp3,namemp4,namemp5,
                       decode(global_v_lang,
                             '101',adrconte,
                             '102',adrcontt,
                             '103',adrcont3,
                             '104',adrcont4,
                             '105',adrcont5, adrconte) adrcont
                into   v_codcomp,v_tinstruc.codprovr,v_tinstruc.coddistr,v_tinstruc.codsubdistr,v_tinstruc.namepos,
                       v_tinstruc.numtelc,v_tinstruc.email,v_tinstruc.lineid, 
                       v_tinstruc.namfirste,v_tinstruc.namfirstt,v_tinstruc.namfirst3,v_tinstruc.namfirst4,v_tinstruc.namfirst5,
                       v_tinstruc.namlaste,v_tinstruc.namlastt,v_tinstruc.namlast3,v_tinstruc.namlast4,v_tinstruc.namlast5,
                       v_tinstruc.naminse,v_tinstruc.naminst,v_tinstruc.namins3,v_tinstruc.namins4,v_tinstruc.namins5,
                       v_tinstruc.adrcont
                from   temploy1 a, temploy2 b
                where  a.codempid = b.codempid
                and    a.codempid = v_tinstruc.codempid;
            exception when no_data_found then null;              
            end;

            begin
              select namimage
              into   v_tinstruc.namimage
              from   tempimge
              where  codempid = v_tinstruc.codempid;
            exception when no_data_found then
              v_tinstruc.namimage := null;
            end;

            begin
              select decode(global_v_lang,
                          '101',adrcome,
                          '102',adrcomt,
                          '103',adrcom3,
                          '104',adrcom4,
                          '105',adrcom5, adrcome) adrcom
              into    v_tinstruc.desnoffi
              from    tcompny
              where   codcompy = get_codcompy(v_codcomp);
            exception when no_data_found then
              v_tinstruc.desnoffi := null;
            end;

          else --'E'
            v_tinstruc.codempid    := null;
            v_tinstruc.codtitle    := upper(v_text(2));
            v_tinstruc.namfirste   := v_text(3);
            v_tinstruc.namfirstt   := v_text(4);
            v_tinstruc.namfirst3   := v_text(3);
            v_tinstruc.namfirst4   := v_text(3);
            v_tinstruc.namfirst5   := v_text(3);
            v_tinstruc.namlaste    := v_text(5);
            v_tinstruc.namlastt    := v_text(6);
            v_tinstruc.namlast3    := v_text(5);
            v_tinstruc.namlast4    := v_text(5);
            v_tinstruc.namlast5    := v_text(5);
            v_tinstruc.naminse     := v_tinstruc.namfirste||' '||v_tinstruc.namlaste;
            v_tinstruc.naminst     := v_tinstruc.namfirstt||' '||v_tinstruc.namlastt;
            v_tinstruc.namins3     := v_tinstruc.naminse;
            v_tinstruc.namins4     := v_tinstruc.naminse;
            v_tinstruc.namins5     := v_tinstruc.naminse;
            v_tinstruc.desnoffi    := v_text(9);
            v_tinstruc.namepos     := v_text(10);
            v_tinstruc.adrcont     := v_text(11);
            v_tinstruc.codsubdistr := upper(v_text(12));
            v_tinstruc.coddistr    := upper(v_text(13));
            v_tinstruc.codprovr    := upper(v_text(14));
            v_tinstruc.numtelc     := v_text(15);
            v_tinstruc.email       := v_text(16);
            v_tinstruc.lineid      := v_text(17);

            v_tinstruc.namimage    := null;
          end if;

          v_tinstruc.codunit     := upper(v_text(18));
          v_tinstruc.amtinchg    := v_text(19);
          v_tinstruc.desskill    := v_text(20);
          v_tinstruc.desnote     := v_text(21);
          --                    
          --Save TINSTRUC--
          begin
            delete tinstruc where codinst = v_tinstruc.codinst;

            insert into tinstruc(codinst,codtitle,
                                namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                namlaste,namlastt,namlast3,namlast4,namlast5,
                                naminse,naminst,namins3,namins4,namins5,
                                stainst,codempid,
                                desnoffi,namepos,adrcont,
                                codsubdistr,coddistr,codprovr,
                                numtelc,email,lineid,
                                codunit,amtinchg,desskill,desnote,
                                namimage,
                                dtecreate,codcreate,dteupd,coduser)
                        values( v_tinstruc.codinst,v_tinstruc.codtitle,
                                v_tinstruc.namfirste,v_tinstruc.namfirstt,v_tinstruc.namfirst3,v_tinstruc.namfirst4,v_tinstruc.namfirst5,
                                v_tinstruc.namlaste,v_tinstruc.namlastt,v_tinstruc.namlast3,v_tinstruc.namlast4,v_tinstruc.namlast5,
                                v_tinstruc.naminse,v_tinstruc.naminst,v_tinstruc.namins3,v_tinstruc.namins4,v_tinstruc.namins5,
                                v_tinstruc.stainst,v_tinstruc.codempid,
                                v_tinstruc.desnoffi,v_tinstruc.namepos,v_tinstruc.adrcont,
                                v_tinstruc.codsubdistr,v_tinstruc.coddistr,v_tinstruc.codprovr,
                                v_tinstruc.numtelc,v_tinstruc.email,v_tinstruc.lineid,
                                v_tinstruc.codunit,v_tinstruc.amtinchg,v_tinstruc.desskill,v_tinstruc.desnote,
                                v_tinstruc.namimage,
                                trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);           
          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then        
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end; 
  --
  procedure get_process_tr_tcoursub(json_str_input    in clob,
                                    json_str_output   out clob) is
    v_rec_tran number := 0;
    v_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_tr_tcoursub(json_str_input, v_rec_tran, v_rec_err);
    json_str_output := get_result(v_rec_tran, v_rec_err);        
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure validate_excel_tr_tcoursub(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    v_filename       varchar2(1000);
    linebuf          varchar2(6000);
    data_file        varchar2(6000);
    v_column         number := 4;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    v_err_data       varchar2(1000);
    v_comments       varchar2(1000);
    v_namtbl         varchar2(300);
    i                number;
    j                number;
    k                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_field        text;
      v_text         text;

    type leng is table of number index by binary_integer;
      chk_len        leng;

    --
    v_tcoursub       tcoursub%rowtype;
    v_temp           varchar2(1000);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;  
    for i in 1..v_column loop
      v_field(i) := null;
      v_text(i) := null;
    end loop;

    for i in 1..v_column loop
      if i in (1,2) then
        chk_len(i) := 6;  
      elsif i in (3) then
        chk_len(i) := 10;
      elsif i in (4) then
        chk_len(i) := 7;      
      end if;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    --
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_tcoursub  := null;        
        v_numseq    := v_numseq + 1;
        v_error 	  := false;
        --
        v_text(1) := hcm_util.get_string_t(param_json_row,'col-1');
        v_text(2) := hcm_util.get_string_t(param_json_row,'col-2');
        v_text(3) := hcm_util.get_string_t(param_json_row,'col-3');
        v_text(4) := hcm_util.get_string_t(param_json_row,'col-4');              

        -- push row values
        data_file := null; 
        for i in 1..v_column loop
          if data_file is null then
            data_file := v_text(i);
          else
            data_file := data_file||','||v_text(i);
          end if;
        end loop;

          <<cal_loop>> loop            
          --check require data column 
          for i in 1..v_column loop
            if v_text(i) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(i);
              v_err_data  := v_text(i);
              exit cal_loop;
            end if;
          end loop;                                  

          --check length/validate all column
          for i in 1..v_column loop
            if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;

            if i = 4 and check_number(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if; 

            if i = 4 and to_number(v_text(i)) <= 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if; 
          end loop;

          begin
            select codcours into v_temp
              from tcourse
             where codcours = upper(v_text(1));                  
          exception when no_data_found then 
            v_error	 	  := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TCOURSE';
            exit cal_loop;
          end;                        

          ----
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then
          v_rec_tran := v_rec_tran + 1; 
          --          
          v_tcoursub.codcours  := upper(v_text(1));          
          v_tcoursub.codsubj   := upper(v_text(2));
          v_tcoursub.codinst   := upper(v_text(3));
          v_tcoursub.qtytrhr   := to_number(v_text(4));          
          --                    
          --Save TCOURSUB--
          begin
            delete tcoursub where codcours = v_tcoursub.codcours and codsubj = v_tcoursub.codsubj;

            insert into tcoursub(codcours,codsubj,
                                 codinst,qtytrhr,                                
                                 dtecreate,codcreate,dteupd,coduser)
                        values( v_tcoursub.codcours,v_tcoursub.codsubj,
                                v_tcoursub.codinst,v_tcoursub.qtytrhr,                                
                                trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);

          end;

        else
          v_rec_error   := v_rec_error + 1;
          v_cnt         := v_cnt + 1;
          p_text(v_cnt) := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null)
                                 ||'['|| v_err_field||']';    
          p_numseq(v_cnt) := i;

        end if; --not v_error
        commit;
      exception when others then       
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
      end;
    end loop;
  end; 
  --
  --EL----------------------------------------------------------------------------------------------------------
  procedure get_process_el_tvcourse(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvcourse(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvcourse (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tvcourse     tvcourse%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1) then
      chk_len(i) := 6;      
      elsif i in (2,3,4,5,6) then
      chk_len(i) := 4;
	  elsif i in (7,8,9,10,12,13) then
      chk_len(i) := 1;
	  elsif i in (11) then
      chk_len(i) := 500; 
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
				v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   
				v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');   
				v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10');   
				v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');
				v_text(12)   := hcm_util.get_string_t(param_json_row,'col-12');
				v_text(13)   := hcm_util.get_string_t(param_json_row,'col-13');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,7,8,9,10,11,12,13) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                    end loop; 


          --assign value to var
		  v_tvcourse.codcours := v_text(1);
          v_tvcourse.codcate   := v_text(2);
          v_tvcourse.codcatpre := v_text(3);
          v_tvcourse.codexampr  := v_text(4);
          v_tvcourse.codcatpo := v_text(5);
          v_tvcourse.codexampo  := v_text(6);
		  v_tvcourse.flgpreteset  := v_text(7);
		  v_tvcourse.flgposttest  := v_text(8);
		  v_tvcourse.staresult  := v_text(9);
          v_tvcourse.typcours  := v_text(10);
          v_tvcourse.descours := v_text(11);
          v_tvcourse.flgdata  := v_text(12);
		  v_tvcourse.flgdashboard  := v_text(13);
		  v_tvcourse.filemedia	:= null;

          --check incorrect data 
		  --check codcours        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tcourse    
				where codcours = v_tvcourse.codcours;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TCOURSE';
				exit cal_loop;
			end;  

		  --check codcate
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tcodcate       
              where codcodec  = v_tvcourse.codcate;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(2);
              v_err_table := 'TCODCATE';
              exit cal_loop;
            end;       

			--check codexampr 
             if v_tvcourse.codexampr is not null or length(trim(v_tvcourse.codexampr)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tvtest        
				  where codexam   = v_tvcourse.codexampr;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(4);
				  v_err_table := 'TVTEST';
				  exit cal_loop;
				end;          
			end if; 


			--check codexampo 
             if v_tvcourse.codexampo is not null or length(trim(v_tvcourse.codexampo)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tvtest        
				  where codexam   = v_tvcourse.codexampo;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(6);
				  v_err_table := 'TVTEST';
				  exit cal_loop;
				end;          
			end if; 	

			--check codcatpre 
             if v_tvcourse.codcatpre is not null or length(trim(v_tvcourse.codcatpre)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tcodcatexm        
				  where codcodec   = v_tvcourse.codcatpre;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(3);
				  v_err_table := 'TCODCATEXM';
				  exit cal_loop;
				end;          
			end if; 

			--check codcatpo 
             if v_tvcourse.codcatpo is not null or length(trim(v_tvcourse.codcatpo)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tcodcatexm        
				  where codcodec   = v_tvcourse.codcatpo;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(5);
				  v_err_table := 'TCODCATEXM';
				  exit cal_loop;
				end;          
			end if; 

            --check flgpreteset   
			if v_tvcourse.flgpreteset is not null or length(trim(v_tvcourse.flgpreteset)) is not null then    
				if v_tvcourse.flgpreteset not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(7);
				  exit cal_loop;
				end if;   
			end if; 	

			--check flgposttest   
			if v_tvcourse.flgposttest is not null or length(trim(v_tvcourse.flgposttest)) is not null then    
				if v_tvcourse.flgposttest not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(8);
				  exit cal_loop;
				end if;   
			end if; 	

			--check staresult   
			if v_tvcourse.staresult is not null or length(trim(v_tvcourse.staresult)) is not null then    
				if v_tvcourse.staresult not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(9);
				  exit cal_loop;
				end if;   
			end if; 	

			--check typcours   
			if v_tvcourse.typcours is not null or length(trim(v_tvcourse.typcours)) is not null then    
				if v_tvcourse.typcours not in ('Y','O') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(10);
				  exit cal_loop;
				end if;   
			end if;

			--check flgdata   
			if v_tvcourse.flgdata is not null or length(trim(v_tvcourse.flgdata)) is not null then    
				if v_tvcourse.flgdata not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(12);
				  exit cal_loop;
				end if;   
			end if; 	

			--check flgdashboard   
			if v_tvcourse.flgdashboard is not null or length(trim(v_tvcourse.flgdashboard)) is not null then    
				if v_tvcourse.flgdashboard not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(13);
				  exit cal_loop;
				end if;   
			end if;			

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 

                    begin 
            delete from tvcourse where codcours  = v_tvcourse.codcours  and codcate  = v_tvcourse.codcate ;

            insert into   tvcourse(codcours, codcate, codcatpre, codexampr, codcatpo, codexampo, filemedia,
									flgpreteset, flgposttest, staresult, typcours, descours, flgdata, flgdashboard,
									dtecreate, codcreate, dteupd, coduser)
                      values(v_tvcourse.codcours, v_tvcourse.codcate, v_tvcourse.codcatpre, v_tvcourse.codexampr, v_tvcourse.codcatpo, v_tvcourse.codexampo, v_tvcourse.filemedia,
								v_tvcourse.flgpreteset, v_tvcourse.flgposttest, v_tvcourse.staresult, v_tvcourse.typcours, v_tvcourse.descours, v_tvcourse.flgdata, v_tvcourse.flgdashboard,
								trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_el_tvsubject(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvsubject(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvsubject (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tvsubject     tvsubject%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1) then
      chk_len(i) := 6;      
      elsif i in (2,6,7) then
      chk_len(i) := 4;
	  elsif i in (3,4,7) then
      chk_len(i) := 1;
	  elsif i in (8) then
      chk_len(i) := 500;   
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
				v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,8) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                    end loop; 

          --assign value to var
		  v_tvsubject.codcours := v_text(1);
          v_tvsubject.codsubj   := v_text(2);
          v_tvsubject.flglearn := v_text(3);
          v_tvsubject.flgexam  := v_text(4);
          v_tvsubject.codexam := v_text(5);
          v_tvsubject.codcatexm  := v_text(6);
		  v_tvsubject.staexam  := v_text(7);
		  v_tvsubject.dessubj  := v_text(8);

          --check incorrect data 
		  --check codcours        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tvcourse    
				where codcours = v_tvsubject.codcours;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TVCOURSE';
				exit cal_loop;
			end;  

			--check codsubj        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tcoursub    
				where codcours = v_tvsubject.codcours and codsubj = v_tvsubject.codsubj;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(2);
				v_err_table := 'TCOURSUB';
				exit cal_loop;
			end;  

			--check flglearn   
			if v_tvsubject.flglearn is not null or length(trim(v_tvsubject.flglearn)) is not null then    
				if v_tvsubject.flglearn not in (1,2) then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(3);
				  exit cal_loop;
				end if;   
			end if; 

			--check flgexam   
			if v_tvsubject.flgexam is not null or length(trim(v_tvsubject.flgexam)) is not null then    
				if v_tvsubject.flgexam not in (1,2,3) then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(4);
				  exit cal_loop;
				end if;   
			end if; 

			--check codexam 
             if v_tvsubject.codexam is not null or length(trim(v_tvsubject.codexam)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tvtest        
				  where codexam   = v_tvsubject.codexam;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(5);
				  v_err_table := 'TVTEST';
				  exit cal_loop;
				end;          
			end if;	

			if v_tvsubject.codexam is null then
				if v_tvsubject.flgexam in (1,2) then
					v_error   := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(5); 
                    exit cal_loop;
				end if;
			end if;	

		  --check codcatexm
			if v_tvsubject.codcatexm is not null or length(trim(v_tvsubject.codcatexm)) is not null then    
            v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tcodcatexm       
				  where codcodec  = v_tvsubject.codcatexm;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(6);
				  v_err_table := 'TCODCATEXM';
				  exit cal_loop;
				end;       
			end if;	

			if v_tvsubject.codcatexm is null then
				if v_tvsubject.flgexam in (1,2) then
					v_error   := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(6); 
                    exit cal_loop;
				end if;
			end if;

			--check staexam   
			if v_tvsubject.staexam is not null or length(trim(v_tvsubject.staexam)) is not null then    
				if v_tvsubject.staexam not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(7);
				  exit cal_loop;
				end if;   
			end if; 	

			if v_tvsubject.staexam is null then
				if v_tvsubject.flgexam in (1,2) then
					v_error   := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(7); 
                    exit cal_loop;
				end if;
			end if;

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 

                    begin 
            delete from tvsubject where codcours  = v_tvsubject.codcours  and codsubj = v_tvsubject.codsubj  ;

            insert into   tvsubject(codcours, codsubj, flglearn, flgexam,
									codexam, codcatexm, staexam, dessubj,
									dtecreate, codcreate, dteupd, coduser)
                      values(v_tvsubject.codcours, v_tvsubject.codsubj, v_tvsubject.flglearn, v_tvsubject.flgexam, 
								v_tvsubject.codexam, v_tvsubject.codcatexm, v_tvsubject.staexam, v_tvsubject.dessubj, 
								trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

					update tvcourse 
					 set qtysubj = nvl(qtysubj, 0) + 1
					where codcours  = v_tvsubject.codcours  ;		

					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_el_tvchapter(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvchapter(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvchapter (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tvchapter     tvchapter%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1,6,14) then
      chk_len(i) := 6;      
      elsif i in (2,8,9) then
      chk_len(i) := 4;
	  elsif i in (3) then
      chk_len(i) := 3;
	  elsif i in (4,5,11,12,16,17) then
      chk_len(i) := 150;
	  elsif i in (7,10,13) then
      chk_len(i) := 1;  
	  elsif i in (15) then
      chk_len(i) := 1000;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
				v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   
				v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9'); 
				v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10'); 
				v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');
				v_text(12)   := hcm_util.get_string_t(param_json_row,'col-12');
				v_text(13)   := hcm_util.get_string_t(param_json_row,'col-13');
				v_text(14)   := hcm_util.get_string_t(param_json_row,'col-14');
				v_text(15)   := hcm_util.get_string_t(param_json_row,'col-15');
				v_text(16)   := hcm_util.get_string_t(param_json_row,'col-16');   
				v_text(17)   := hcm_util.get_string_t(param_json_row,'col-17'); 

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5,6,7,14) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

						--check number format     
                        if i in (3,6,14) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;

                    end loop; 

          --assign value to var
		  v_tvchapter.codcours := v_text(1);
          v_tvchapter.codsubj   := v_text(2);
          v_tvchapter.chaptno := to_number(nvl(v_text(3),0), '999');
          v_tvchapter.namchapte  := v_text(4);
          v_tvchapter.namchaptt := v_text(5);
          v_tvchapter.namchapt3  := v_text(4);
		  v_tvchapter.namchapt4  := v_text(4);
		  v_tvchapter.namchapt5  := v_text(4);
		  v_tvchapter.qtytrainm  := to_number(nvl(v_text(6),0), '999999');
		  v_tvchapter.flgexam  := v_text(7);
		  v_tvchapter.codexam := v_text(8);
          v_tvchapter.codcatexm   := v_text(9);
          v_tvchapter.staexam := v_text(10);
          v_tvchapter.namemedia  := v_text(11);
          v_tvchapter.namelink := v_text(12);
          v_tvchapter.typfile  := v_text(13);
		  v_tvchapter.qtytrmin  := to_number(nvl(v_text(14),0), '999999');
		  v_tvchapter.deschaptt  := v_text(15);
		  v_tvchapter.desclink  := v_text(16);
		  v_tvchapter.namefiled  := v_text(17);
		  v_tvchapter.filemedia  := null;
		  v_tvchapter.filedoc  := null;

          --check incorrect data 
		  --check codcours and codsubj       
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tvsubject    
				where codcours = v_tvchapter.codcours and codsubj = v_tvchapter.codsubj ;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TVSUBJECT';
				exit cal_loop;
			end;  

			--check flgexam   
			if v_tvchapter.flgexam is not null or length(trim(v_tvchapter.flgexam)) is not null then    
				if v_tvchapter.flgexam not in (1,2) then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(7);
				  exit cal_loop;
				end if;   
			end if; 

			--check codexam 
             if v_tvchapter.codexam is not null or length(trim(v_tvchapter.codexam)) is not null then    
                v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tvtest        
				  where codexam   = v_tvchapter.codexam;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(8);
				  v_err_table := 'TVTEST';
				  exit cal_loop;
				end;          
			end if;	

			if v_tvchapter.codexam is null then
				if v_tvchapter.flgexam in (1,2) then
					v_error   := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(8); 
                    exit cal_loop;
				end if;
			end if;

		  --check codcatexm
			if v_tvchapter.codcatexm is not null or length(trim(v_tvchapter.codcatexm)) is not null then    
            v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tcodcatexm       
				  where codcodec  = v_tvchapter.codcatexm;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(9);
				  v_err_table := 'TCODCATEXM';
				  exit cal_loop;
				end;       
			end if;	

			if v_tvchapter.codcatexm is null then
				if v_tvchapter.flgexam in (1,2) then
					v_error   := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(9); 
                    exit cal_loop;
				end if;
			end if;

			--check staexam   
			if v_tvchapter.staexam is not null or length(trim(v_tvchapter.staexam)) is not null then    
				if v_tvchapter.staexam not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(10);
				  exit cal_loop;
				end if;   
			end if; 	

			if v_tvchapter.staexam is null then
				if v_tvchapter.flgexam in (1,2) then
					v_error   := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(10); 
                    exit cal_loop;
				end if;
			end if;

			--check typfile   
			if v_tvchapter.typfile is not null or length(trim(v_tvchapter.typfile)) is not null then    
				if v_tvchapter.typfile not in ('V','F','L') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(13);
				  exit cal_loop;
				end if;   
			end if; 


                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 

                    begin 
             delete from tvchapter where codcours = v_tvchapter.codcours and codsubj = v_tvchapter.codsubj and chaptno = v_tvchapter.chaptno ;

            insert into   tvchapter(codcours, codsubj, chaptno, namchapte, namchaptt, namchapt3, namchapt4, namchapt5,
									qtytrainm, flgexam, codexam, codcatexm, staexam,  namemedia, namelink,
									typfile, qtytrmin, desclink, namefiled, filemedia, filedoc, deschaptt,
									dtecreate, codcreate, dteupd, coduser)
                      values(v_tvchapter.codcours, v_tvchapter.codsubj, v_tvchapter.chaptno, v_tvchapter.namchapte, v_tvchapter.namchaptt, v_tvchapter.namchapt3, v_tvchapter.namchapt4, v_tvchapter.namchapt5,
								v_tvchapter.qtytrainm, v_tvchapter.flgexam, v_tvchapter.codexam, v_tvchapter.codcatexm, v_tvchapter.staexam, v_tvchapter.namemedia, v_tvchapter.namelink, 
								v_tvchapter.typfile, v_tvchapter.qtytrmin, v_tvchapter.desclink, v_tvchapter.namefiled, v_tvchapter.filemedia, v_tvchapter.filedoc, v_tvchapter.deschaptt, 
								trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

					update tvsubject  
					 set qtychapt  = nvl(qtychapt , 0) + 1
					where codcours  = v_tvchapter.codcours and codsubj = v_tvchapter.codsubj  ;		

					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_el_tvtest(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvtest(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvtest (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        number := 0; 

  v_tvtest     tvtest%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1,4) then
      chk_len(i) := 4;      
      elsif i in (2,3) then
      chk_len(i) := 150;
	  elsif i in (5,6) then
      chk_len(i) := 8;
	  elsif i in (7,8) then
      chk_len(i) := 6;	 
	  elsif i in (10) then
      chk_len(i) := 500;  
	  elsif i in (11) then
      chk_len(i) := 1;  
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
				v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   
				v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9'); 
				v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10'); 
				v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5,6,7,9,10,11) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

						--check number format     
                        if i in (5,6,7,8,9) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;

                    end loop; 

          --assign value to var
		  v_tvtest.codexam := v_text(1);
          v_tvtest.namexame   := v_text(2);
          v_tvtest.namexam2 := v_text(3);
          v_tvtest.namexam4 := v_text(2);
          v_tvtest.namexam3  := v_text(2);
          v_tvtest.namexam5  := v_text(2);
		  v_tvtest.codcatexm  := v_text(4);
		  v_tvtest.qtyscore  := to_number(nvl(v_text(5),0), '99999.99');
		  v_tvtest.qtyscrpass  := to_number(nvl(v_text(6),0), '99999.99');
		  v_tvtest.qtyexammin  := to_number(nvl(v_text(7),0), '999999');
		  v_tvtest.qtyalrtmin := to_number(nvl(v_text(8),0), '999999');
		  v_tvtest.qtyexam  := to_number(nvl(v_text(9),0), '99999');
          v_tvtest.desexam := v_text(10);
          v_tvtest.flgmeasure  := v_text(11);


          --check incorrect data 
		  --check codcatexm
			if v_tvtest.codcatexm is not null or length(trim(v_tvtest.codcatexm)) is not null then    
            v_chk_exists := 0;
				begin 
				  select 1 into v_chk_exists from tcodcatexm       
				  where codcodec  = v_tvtest.codcatexm;
				exception when no_data_found then  
				  v_error   := true;
				  v_err_code  := 'HR2010';
				  v_err_field := v_field(4);
				  v_err_table := 'TCODCATEXM';
				  exit cal_loop;
				end;       
			end if;	

			--check flgmeasure   
			if v_tvtest.flgmeasure is not null or length(trim(v_tvtest.flgmeasure)) is not null then    
				if v_tvtest.flgmeasure not in ('Y','N') then
				  v_error   := true;
				  v_err_code  := 'HR2020';
				  v_err_field := v_field(11);
				  exit cal_loop;
				end if;   
			end if; 	

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                    p_rec_tran := p_rec_tran + 1; 

                    begin 
            delete from tvtest where codexam = v_tvtest.codexam ;

            insert into   tvtest(codexam, namexame, namexam2, namexam3, namexam4, namexam5, codcatexm,
									qtyscore, qtyscrpass, qtyexammin, qtyalrtmin, qtyexam, desexam, flgmeasure,
									dtecreate, codcreate, dteupd, coduser)
                      values(v_tvtest.codexam, v_tvtest.namexame, v_tvtest.namexam2, v_tvtest.namexam3, v_tvtest.namexam4, v_tvtest.namexam5, v_tvtest.codcatexm,
								v_tvtest.qtyscore, v_tvtest.qtyscrpass, v_tvtest.qtyexammin, v_tvtest.qtyalrtmin, v_tvtest.qtyexam, v_tvtest.desexam, v_tvtest.flgmeasure,
								trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);


					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;

  procedure get_process_el_tvquest(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvquest(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvquest (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        	number := 0; 

	v_tvquest     tvquest%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1,2) then
      chk_len(i) := 4;        
	  elsif i in (3,4) then
      chk_len(i) := 150;
	  elsif i in (5) then
      chk_len(i) := 6; 
	  elsif i in (6) then
      chk_len(i) := 1; 
	  elsif i in (7) then
      chk_len(i) := 5; 
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');    

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5,6,7) then
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

						--check number format     
                        if i in (5,7) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;

                    end loop; 


          --assign value to var
		  v_tvquest.codexam := v_text(1);
          v_tvquest.codquest   := v_text(2);
          v_tvquest.namsubje := v_text(3);
          v_tvquest.namsubj2  := v_text(4);
          v_tvquest.namsubj3 := v_text(3);
          v_tvquest.namsubj4  := v_text(3);
		  v_tvquest.namsubj5  := v_text(3);
		  v_tvquest.qtyscore  := to_number(nvl(v_text(5),0));
		  v_tvquest.typeexam  := v_text(6);
		  v_tvquest.qtyexam	:= to_number(nvl(v_text(7),0));

          --check incorrect data 
		  --check codexam        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tvtest     
				where codexam  = v_tvquest.codexam ;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TVTEST';
				exit cal_loop;
			end;  

		  --check typeexam   
			if v_tvquest.typeexam not in ('1','2','3','4') then
			  v_error   := true;
			  v_err_code  := 'HR2020';
			  v_err_field := v_field(6);
			  exit cal_loop;
			end if;   


                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                   	p_rec_tran := p_rec_tran + 1; 

                    begin 
						delete from tvquest where codexam = v_tvquest.codexam and codquest = v_tvquest.codquest;

						insert into tvquest(codexam, codquest, namsubje, namsubj2, namsubj3,
												namsubj4, namsubj5, qtyscore, typeexam, qtyexam,
												dtecreate, codcreate, dteupd, coduser)
									   values(v_tvquest.codexam, v_tvquest.codquest, v_tvquest.namsubje, v_tvquest.namsubj2, v_tvquest.namsubj3, 
												v_tvquest.namsubj4, v_tvquest.namsubj5, v_tvquest.qtyscore, v_tvquest.typeexam, v_tvquest.qtyexam,
												trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_el_tvquestd1(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvquestd1(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvquestd1 (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        	number := 0; 

	v_tvquestd1     tvquestd1%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1,2) then
      chk_len(i) := 4;      
      elsif i in (3) then
      chk_len(i) := 3;
	  elsif i in (4,5) then
      chk_len(i) := 500;
	  elsif i in (6) then
      chk_len(i) := 6; 
	  elsif i in (7) then
      chk_len(i) := 1; 
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5,7) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

						--check number format     
                        if i in (3,6,7) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;

                    end loop; 


          --assign value to var
		  v_tvquestd1.codexam := v_text(1);
          v_tvquestd1.codquest   := v_text(2);
          v_tvquestd1.numques := to_number(nvl(v_text(3),0), '999');
          v_tvquestd1.desquese  := v_text(4);
          v_tvquestd1.desques2 := v_text(5);
          v_tvquestd1.desques3  := v_text(4);
		  v_tvquestd1.desques4  := v_text(4);
		  v_tvquestd1.desques5  := v_text(4);
		  v_tvquestd1.qtyscore  := to_number(nvl(v_text(6),0));
          v_tvquestd1.numans  := to_number(nvl(v_text(7),0), '9');
		  v_tvquestd1.filename	:= null;

          --check incorrect data 
		  --check codexam        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tvquest     
				where codexam  = v_tvquestd1.codexam ;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TVQUEST';
				exit cal_loop;
			end;  

			 --check codquest
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tvquest        
              where codexam  = v_tvquestd1.codexam and codquest = v_tvquestd1.codquest;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(2);
              v_err_table := 'TVQUEST';
              exit cal_loop;
            end;  


                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                   	p_rec_tran := p_rec_tran + 1; 

                    begin 
						delete from tvquestd1 where codexam = v_tvquestd1.codexam and codquest = v_tvquestd1.codquest and numques = v_tvquestd1.numques ;

						insert into tvquestd1(codexam, codquest, numques, desquese, desques2,
												desques3, desques4, desques5, filename, qtyscore, numans,
												dtecreate, codcreate, dteupd, coduser)
									   values(v_tvquestd1.codexam, v_tvquestd1.codquest, v_tvquestd1.numques, v_tvquestd1.desquese, v_tvquestd1.desques2, 
												v_tvquestd1.desques3, v_tvquestd1.desques4, v_tvquestd1.desques5, v_tvquestd1.filename, v_tvquestd1.qtyscore, v_tvquestd1.numans,
												trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
						/*		
						update tvquest 
							set qtyexam = qtyexam + 1  
						where codexam = v_tvquestd1.codexam and codquest = v_tvquestd1.codquest;
						*/
					end;


                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_el_tvquestd2(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvquestd2(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvquestd2 (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        	number := 0; 

	v_tvquestd2     tvquestd2%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1,2) then
      chk_len(i) := 4;      
      elsif i in (3) then
      chk_len(i) := 3;
	   elsif i in (4) then
      chk_len(i) := 1;
	  elsif i in (5,6) then
      chk_len(i) := 200;
	  elsif i in (7) then
      chk_len(i) := 6; 
      else
      chk_len(i) := 0;   
      end if;
    end loop;       


        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4,5,6,7) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

						--check number format     
                        if i in (3,4,7) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;

                    end loop; 


          --assign value to var
		  v_tvquestd2.codexam := v_text(1);
          v_tvquestd2.codquest   := v_text(2);
          v_tvquestd2.numques := to_number(nvl(v_text(3),0), '999');
		  v_tvquestd2.numans  := to_number(nvl(v_text(4),0), '9');
          v_tvquestd2.desanse  := v_text(5);
          v_tvquestd2.desans2 := v_text(6);
          v_tvquestd2.desans3  := v_text(5);
		  v_tvquestd2.desans4  := v_text(5);
		  v_tvquestd2.desans5  := v_text(5);
          v_tvquestd2.score  := to_number(nvl(v_text(7),0));
		  v_tvquestd2.filename	:= null;

          --check incorrect data 
		  --check codexam        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tvquestd1     
				where codexam  = v_tvquestd2.codexam;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TVQUESTD1';
				exit cal_loop;
			end;  

		  --check codquest
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tvquestd1        
              where codexam  = v_tvquestd2.codexam and codquest = v_tvquestd2.codquest;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(2);
              v_err_table := 'TVQUESTD1';
              exit cal_loop;
            end;   

			--check numques
            v_chk_exists := 0;
            begin 
              select 1 into v_chk_exists from tvquestd1        
              where codexam  = v_tvquestd2.codexam and codquest = v_tvquestd2.codquest and numques = v_tvquestd2.numques;
            exception when no_data_found then  
              v_error   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(3);
              v_err_table := 'TVQUESTD1';
              exit cal_loop;
            end;  			

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                   	p_rec_tran := p_rec_tran + 1; 			
                    begin 
						delete from tvquestd2 where codexam = v_tvquestd2.codexam and codquest = v_tvquestd2.codquest and numques = v_tvquestd2.numques and numans = v_tvquestd2.numans;

						insert into tvquestd2(codexam, codquest, numques, numans, desanse, desans2,
												desans3, desans4, desans5, score, filename,  
												dtecreate, codcreate, dteupd, coduser)
									   values(v_tvquestd2.codexam, v_tvquestd2.codquest, v_tvquestd2.numques, v_tvquestd2.numans, v_tvquestd2.desanse, v_tvquestd2.desans2, 
												v_tvquestd2.desans3, v_tvquestd2.desans4, v_tvquestd2.desans5, v_tvquestd2.score, v_tvquestd2.filename, 
												trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

					end;

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;


   procedure get_process_el_tvtesta(json_str_input    in clob,
                                      json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_el_tvtesta(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_el_tvtesta (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt        	number := 0; 

	v_tvtesta     tvtesta%rowtype;


    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์

    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    v_chk_exists     number;
    v_int_temp     number;

    begin

        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 

        --assign chk_len 
        for i in 1..v_column loop
      if i in (1) then
      chk_len(i) := 4;      
      elsif i in (2,3) then
      chk_len(i) := 6;
	   elsif i in (4) then
      chk_len(i) := 500;
      else
      chk_len(i) := 0;   
      end if;
    end loop;       

        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;

        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       

        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;

        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         

            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error   := false;       

				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');

                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;

                    --1.validate --        
                    for i in 1..v_column loop
                        --check require data column 
                        if i in (1,2,3,4) then     
                             if v_text(i) is null or length(trim(v_text(i))) is null then   
                                v_error   := true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;

                        --check length all columns         
                        if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
                            if(length(v_text(i)) > chk_len(i)) then                               
                                v_error   := true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

						--check number format     
                        if i in (2,3) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_number(v_text(i)) then                         
                                    v_error   := true;
                                    v_err_code  := 'HR2816';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  

                                --check number < 0
                                 if to_number(v_text(i)) < 0 then
                                    v_error   := true;
                                    v_err_code  := 'HR2023';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if; 
                            end if;
                        end if;

                    end loop; 


          --assign value to var
		  v_tvtesta.codexam := v_text(1);
          v_tvtesta.scorest := to_number(nvl(v_text(2),0));
		  v_tvtesta.scoreen  := to_number(nvl(v_text(3),0));
          v_tvtesta.remark  := v_text(4);

          --check incorrect data 
		  --check codexam        
			v_chk_exists := 0;
			begin 
				select 1 into v_chk_exists from tvtest     
				where codexam  = v_tvtesta.codexam ;
			exception when no_data_found then  
				v_error   := true;
				v_err_code  := 'HR2010';
				v_err_field := v_field(1);
				v_err_table := 'TVTEST';
				exit cal_loop;
			end;  

		  --check scorest
            if v_tvtesta.scorest > v_tvtesta.scoreen then            
              v_error   := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;   

                    exit cal_loop;
                end loop;

                --2.crud table--
                if not v_error then      
                   	p_rec_tran := p_rec_tran + 1; 			
                    begin 
						delete from tvtesta where codexam = v_tvtesta.codexam and scorest = v_tvtesta.scorest;

						insert into tvtesta(codexam, scorest, scoreen, remark,  
												dtecreate, codcreate, dteupd, coduser)
									   values(v_tvtesta.codexam, v_tvtesta.scorest, v_tvtesta.scoreen, v_tvtesta.remark,  
												trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

					end;					

                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                    --insert into j values(p_error_code(v_cnt));
                end if;            

                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
            end;
    end loop;  

  end;



--RP----------------------------------------------------------------------------------------------------------  

  --RP--
  procedure get_process_rp_tposemph(json_str_input    in clob,
                                    json_str_output   out clob) is
    p_rec_tran number := 0;
    p_rec_err  number := 0;
  begin
    initial_value(json_str_input);
    validate_excel_rp_tposemph(json_str_input, p_rec_tran, p_rec_err);
    json_str_output := get_result(p_rec_tran, p_rec_err);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure validate_excel_rp_tposemph (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is

    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);
    v_column         number := 13;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt            number := 0; 

    v_tposemph      tposemph%rowtype;
    v_numpath       tposplnh.numpath%type;
    v_dteeffec      tposplnh.dteeffec%type;
    v_empnumseq     tposplnd.numseq%type;
    v_maxnumseq     tposplnd.numseq%type;
    v_nextnumseq    tposplnd.numseq%type;

    v_dteefpos	    temploy1.dteefpos%type;
    v_dteposdue		  date;
    v_codcomp_next	temploy1.codcomp%type;
    v_codpos_next	  temploy1.codpos%type;
    v_grdemp		    tposempctc.grdemp%type;
    v_codskill 		  tposempctc.codskill%type;
    v_grade_emp		  tposempctc.grdemp%type;
    v_grade			    tposempctc.grade%type;
    v_gap			      number;

    type text is table of varchar2(1000 char) index by binary_integer;
      v_text           text;
      v_field          text;

    type leng is table of number index by binary_integer;       
      chk_len          leng;

    cursor c_career_path is
      select numseq, codlinef, codcomp, codpos, agepos, othdetail
        from tposplnd a
      where a.codcompy  = hcm_util.get_codcomp_level(v_tposemph.codcomp,1)
        and a.numpath   = v_numpath
        and a.dteeffec  = v_dteeffec
        and a.numseq    >= v_empnumseq   
--        and a.codcomp    = v_tposemph.codcomp
--        and a.codpos     = v_tposemph.codpos                                  
		order by numseq;

    cursor c_competency is
      select codtency, codskill, grade 
        from tjobposskil 
       where codcomp  = v_codcomp_next
         and codpos   = v_codpos_next
		order by codtency, codskill;

    cursor c_tposempctc	is
      select codskill, grdemp, grade
        from tposempctc
       where codempid = v_tposemph.codempid
         and codcomp  = v_codcomp_next
         and codpos   = v_codpos_next
    order by codskill;

    cursor c_tcomptcr is
      select distinct codcours
        from tcomptcr
       where codskill = v_codskill
         and grade    between (v_grade_emp + 1) and v_grade 
		order by codcours;

    cursor c_tcomptdev is
      select distinct coddevp  
        from tcomptdev
       where codskill = v_codskill
         and grade    between (v_grade_emp + 1) and v_grade 
		order by coddevp;

  begin
    --read json        
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
    param_column := hcm_util.get_json_t(param_json, 'p_columns');       
    v_column     := param_column.get_size; 

    --assign chk_len 
    for i in 1..v_column loop
      if i in (1,2,3) then
        chk_len(i) := 10;      
      elsif i in (4) then
        chk_len(i) := 500;
      elsif i in (5,6,7,8,9,10,11,12) then
        chk_len(i) := 600;
      elsif i in (13) then
        chk_len(i) := 6;         
      end if;
    end loop;       

    --default transaction success and error
		p_rec_tran  := 0;
    p_rec_error := 0;

    --assign null to v_field which keep array column name
    for i in 1..v_column loop
      v_field(i) := null;
    end loop;                       

    --read columns name       
    for i in 0..param_column.get_size-1 loop          
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;

    --read data each rows 
    for i in 0..param_data.get_size-1 loop            
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_numseq    := v_numseq + 1;
        v_error     := false;       
        --
				v_text(1)   := hcm_util.get_string_t(param_json_row,'col-1');
				v_text(2)   := hcm_util.get_string_t(param_json_row,'col-2');
				v_text(3)   := hcm_util.get_string_t(param_json_row,'col-3');
				v_text(4)   := hcm_util.get_string_t(param_json_row,'col-4');
				v_text(5)   := hcm_util.get_string_t(param_json_row,'col-5');
				v_text(6)   := hcm_util.get_string_t(param_json_row,'col-6');   
				v_text(7)   := hcm_util.get_string_t(param_json_row,'col-7');   
				v_text(8)   := hcm_util.get_string_t(param_json_row,'col-8');   
				v_text(9)   := hcm_util.get_string_t(param_json_row,'col-9');   
				v_text(10)   := hcm_util.get_string_t(param_json_row,'col-10');   
				v_text(11)   := hcm_util.get_string_t(param_json_row,'col-11');
				v_text(12)   := hcm_util.get_string_t(param_json_row,'col-12');
				v_text(13)   := hcm_util.get_string_t(param_json_row,'col-13');

        <<cal_loop>> loop      
          --concat all data values each rows 
          data_file := v_text(1);
          for i in 2..v_column loop                     
            data_file := data_file||','||v_text(i);                     
          end loop;

          --1.validate --        
          for i in 1..v_column loop
            --check require data column 
            if i in (1,2,3,13) then     
              if v_text(i) is null or length(trim(v_text(i))) is null then   
                v_error     := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                exit cal_loop;
              end if;
            end if;

            --check length all columns         
            if v_text(i) is not null or length(trim(v_text(i))) is not null  then                                 
              if(length(v_text(i)) > chk_len(i)) then                               
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_field := v_field(i);
                exit cal_loop;
              end if;   
            end if;  

            if i = 3 and check_date(v_text(i)) then
              v_error	 	  := true;
              v_err_code  := 'HR2020';
              v_err_field := v_field(i);
              exit cal_loop;
            end if;
          end loop;            

          --assign value to var
          v_tposemph.codempid     := upper(v_text(1));
          v_tposemph.codreview    := upper(v_text(2));
          v_tposemph.dtereview    := check_dteyre(v_text(3));
          v_tposemph.remark       := v_text(4);
          v_tposemph.shorttrm     := v_text(5);
          v_tposemph.midterm      := v_text(6);
          v_tposemph.longtrm      := v_text(7);
          v_tposemph.descstr      := v_text(8);
          v_tposemph.descweek     := v_text(9);
          v_tposemph.descoop      := v_text(10);
          v_tposemph.descthreat   := v_text(11);
          v_tposemph.descdevp     := v_text(12);
          v_numpath               := v_text(13);

          --check incorrect data 
          --check codempid        
          begin 
            select codpos, codcomp
              into v_tposemph.codpos, v_tposemph.codcomp 
              from temploy1    
             where codempid = v_tposemph.codempid;
          exception when no_data_found then  
            v_error     := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(1);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;

          --check codreview        
          begin 
            select 1
              into v_num
              from temploy1    
             where codempid = v_tposemph.codreview;
          exception when no_data_found then  
            v_error     := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(2);
            v_err_table := 'TEMPLOY1';
            exit cal_loop;
          end;

          --check numpath
          begin
            select max(dteeffec) into v_dteeffec
              from tposplnh
             where codcompy = hcm_util.get_codcomp_level(v_tposemph.codcomp,1)
               and numpath  = v_numpath
               and dteeffec <= trunc(sysdate);          
          end;
          begin
            select numseq into v_empnumseq
              from tposplnd
             where codcompy = hcm_util.get_codcomp_level(v_tposemph.codcomp,1)
               and numpath  = v_numpath
               and dteeffec = v_dteeffec
               and codcomp  = v_tposemph.codcomp
               and codpos		= v_tposemph.codpos;
          exception when no_data_found then
            v_error     := true;
            v_err_code  := 'HR2055';
            v_err_field := v_field(13);
            v_err_table := 'TPOSPLND';
            exit cal_loop;
          end;
          --
          exit cal_loop;
        end loop; -- cal_loop

        if not v_error then                                  

          begin 
						--Save TPOSEMPH--
            delete from tposemph where codempid = v_tposemph.codempid;

						insert into tposemph(codempid, codreview, dtereview, 
                                remark, codcomp, codpos, 
                                shorttrm, midterm, longtrm, 
                                descstr, descweek, descoop,
                                descthreat, descdevp, 
                                dtecreate, codcreate, dteupd, coduser)
                          values(v_tposemph.codempid, v_tposemph.codreview, v_tposemph.dtereview, 
                                v_tposemph.remark, v_tposemph.codcomp, v_tposemph.codpos, 
                                v_tposemph.shorttrm, v_tposemph.midterm, v_tposemph.longtrm, 
                                v_tposemph.descstr, v_tposemph.descweek, v_tposemph.descoop, 
                                v_tposemph.descthreat, v_tposemph.descdevp, 
                                trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);

						--Save TPOSEMPD--
            delete from tposempd where codempid = v_tposemph.codempid;

            for r in c_career_path loop						
							v_dteefpos  := null;
              v_dteposdue := null;
              if r.numseq = v_empnumseq then --Present Seq.
                begin
                  select dteefpos 
                    into v_dteefpos
                    from temploy1
                   where codempid = v_tposemph.codempid;
                exception when no_data_found then
                  v_dteefpos := null;
                end;
                v_dteposdue := add_months(v_dteefpos, r.agepos);
              end if;

							insert into tposempd (codempid, numseq, 
                                    codlinef, codcomp, 
                                    codpos, agepos, dteefpos, dteposdue,
                                    dtecreate, codcreate, dteupd, coduser)
                            values (v_tposemph.codempid, r.numseq, 
                                    r.codlinef, r.codcomp,
                                    r.codpos, r.agepos, v_dteefpos, v_dteposdue,
                                    trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);							
						end loop;

            --Save TPOSEMPCTC--
            delete from tposempctc where codempid = v_tposemph.codempid; 
            delete from tposemptr  where codempid = v_tposemph.codempid;            
            delete from tposempdev where codempid = v_tposemph.codempid;

            begin
              select max(numseq) into v_maxnumseq
                from tposplnd
               where codcompy = hcm_util.get_codcomp_level(v_tposemph.codcomp,1)
                 and numpath  = v_numpath
                 and dteeffec = v_dteeffec;
            end;            
            if v_maxnumseq > v_empnumseq then --Not Max Seq.
              begin
                select min(numseq) into v_nextnumseq
                  from tposplnd
                 where codcompy = hcm_util.get_codcomp_level(v_tposemph.codcomp,1)
                   and numpath  = v_numpath
                   and dteeffec = v_dteeffec
                   and numseq   > v_empnumseq;
              end; 
              begin
                select codcomp, codpos 
                  into v_codcomp_next, v_codpos_next
                  from tposplnd
                 where codcompy = hcm_util.get_codcomp_level(v_tposemph.codcomp,1)
                   and numpath  = v_numpath
                   and dteeffec = v_dteeffec
                   and numseq   = v_nextnumseq; ----(v_empnumseq + 1);
              exception when no_data_found then null;
              end;              

              for r in c_competency loop						
                begin
                  select grade 
                    into v_grdemp
                    from tcmptncy 
                   where codempid = v_tposemph.codempid 
                     and codtency = r.codskill;
                exception when no_data_found then 
                  v_grdemp := 0;
                end;

                insert into tposempctc (codempid, codcomp, codpos, codskill,
                                        codtency, grade, grdemp,
                                        dtecreate, codcreate, dteupd, coduser)
                                values (v_tposemph.codempid, v_codcomp_next, v_codpos_next, r.codskill,
                                        r.codtency, r.grade, v_grdemp, 
                                        trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
              end loop;

              --Save TPOSEMPTR, TPOSEMPDEV--
              for r1 in c_tposempctc loop
                v_codskill 	:= r1.codskill; 
                v_grade_emp	:= r1.grdemp;
                v_grade		  := r1.grade;				

                for r2 in c_tcomptcr loop
                  insert into tposemptr (codempid, codcomp, codpos, codcours, 
                                        dtestr, dteend, dtetrst, dtetren,
                                        dtecreate, codcreate, dteupd, coduser)
                                 values (v_tposemph.codempid, v_codcomp_next, v_codpos_next, r2.codcours,
                                        null, null, null, null,
                                        trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);
                end loop;	

                for r3 in c_tcomptdev loop	
                  insert into tposempdev (codempid, codcomp, codpos, coddevp, 
                                          desdevp, targetdev, dtestr, dteend, desresults,
                                          dtecreate, codcreate, dteupd, coduser)
                                  values (v_tposemph.codempid, v_codcomp_next, v_codpos_next, r3.coddevp,
                                          null, null, null, null, null,
                                          trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);																		
                end loop;

              end loop; --c_competency
            end if; --v_maxnumseq > v_empnumseq 
					end;					
					p_rec_tran := p_rec_tran + 1; 

        else        
          p_rec_error := p_rec_error + 1;                   
          v_cnt := v_cnt + 1;                    
          p_text(v_cnt) := data_file;                    
          p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
          p_numseq(v_cnt) := i;         
        end if; --not v_error
        commit;
      exception when others then           
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);  
      end;
    end loop;  
  end;
  --

end;

/
