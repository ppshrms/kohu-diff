--------------------------------------------------------
--  DDL for Package Body HCM_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_VALIDATE" is

  function check_date (p_date in varchar2) return boolean is
    v_date		date;
    c_date		varchar2(30) := p_date;
    v_error		boolean := false;
  begin
    if p_date is not null then
      begin
        v_date := to_date(p_date,'dd/mm/yyyy');
        v_error := false;

        c_date :=  ltrim(substr(c_date , -4),'/');
        if length(c_date) < 4 then
            v_error := true;
        end if;

      exception when others then
        v_error := true;
      end;
    end if;
    return(v_error);
  end;

  function check_number (p_number in varchar2) return boolean is
    v_number 	number;
    v_error		boolean := false;
  begin
    if p_number is not null then
      begin
        v_number := to_number(p_number);
        v_error  := false;
      exception when others then
        v_error  := true;
      end;
    end if;
    return(v_error);
  end;
  function check_time (p_time in varchar2) return boolean is
    v_number 	number;
    v_hour    number;
    v_min     number;
    v_error		boolean := false;
  begin
    if p_time is not null then
      begin
      v_hour  :=  to_number(substr(p_time, '1', '2'));
      v_min   :=  to_number(substr(p_time, '3', '2'));
      exception when others then 
        v_error := false;
        return(v_error);
      end;
      v_error := true;
      if v_hour > 23 then
        v_error := false;
      end if;
      if v_min > 59 then
        v_error := false;
      end if;
    end if;
    return(v_error);
  end;
  function check_length (p_item in varchar2, p_table in varchar2, p_column in varchar2, p_max out number) return boolean is
    v_error		  boolean;
    v_length    number;
    v_type      varchar2(128);
  begin
    begin
      select decode(data_type,'NUMBER',data_precision
                                      ,char_length) as data_length,
             data_type
        into v_length, v_type
        from user_tab_cols
       where table_name   = upper(p_table)
         and column_name  = upper(p_column);
    exception when no_data_found then
      v_length    := 0;
      v_type      := null;
    end;
    if v_type = 'NUMBER' then
      if length(trunc(to_number(p_item))) > v_length then
        v_error := true;
      else
        v_error := false;
      end if;
    else
      if length(p_item) > v_length then
        v_error := true;
      else
        v_error := false;
      end if;
    end if;

    p_max   := v_length;
    return(v_error);
  end;

  function check_tcodcodec(p_table  varchar2,p_where  varchar2)  return boolean is
    v_error		  boolean;
  begin
    v_error := execute_stmt('select count(*) from '||p_table||' where '||p_where);
    if v_error then
       v_error := false;   --found data
    else
       v_error := true;    --not found data
    end if;
    return(v_error);
  end;
  function validate_lov(p_codapp in varchar2, p_value in varchar2, p_lang in varchar2) return varchar2 is
    v_count  number := 0;
  begin
    begin
      select count(*) into v_count
        from tlistval
       where codapp     = upper(p_codapp)
         and list_value = p_value;
    exception when no_data_found then
      null;
    end;
    if v_count = 0 then
      return get_error_msg_php('HR2010', p_lang, 'tlistval');
    end if;
    return null;
  end;
end;

/
