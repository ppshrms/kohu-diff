--------------------------------------------------------
--  DDL for Package Body SYNC_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "SYNC_CONTROL" is
  procedure update_change (p_custname in varchar, p_type in varchar2, p_name in varchar2) is
    v_flgmodify       tcustmodify.flgmodify%type;

    cursor c_source is
      select name
        from all_source
       where upper(owner) = upper(p_custname)
         and upper(name)  = upper(p_name)
         and upper(type)  = upper(p_type)
         and lower(text)  like '%/* cust-modify:%'
      order by type,line;
  begin
    v_flgmodify := 'N';

    if upper(substr(p_name,1,2)) = 'M_' then
      v_flgmodify := 'Y';
    end if;

    if v_flgmodify = 'N' then
      for r_source in c_source loop
        v_flgmodify := 'Y';
        exit;
      end loop;
    end if;
    -- dbms_output.put_line('sync '||p_custname||' - '||p_type||' - '||p_name||' - '||v_flgmodify);
    begin
      insert into tcustmodify (custname,type,name,flgmodify)
           values(p_custname,p_type,p_name,v_flgmodify);
      dbms_output.put_line(' - insert flgmodify = '||v_flgmodify);    
    exception when dup_val_on_index then
      update tcustmodify
         set flgmodify = v_flgmodify
       where custname  = p_custname
         and type      = p_type
         and name      = p_name;
      dbms_output.put_line(' - update flgmodify = '||v_flgmodify);
    end;

  --  commit;  -- no-commit for call from trigger
  end;

  procedure initial_customer (p_custname in varchar, p_type in varchar2 default null, p_name in varchar2 default null) is 
    cursor c1 is
      select  case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                    else upper(object_type)
              end as object_type,
              upper(object_name) as object_name
        from all_objects
       where owner like p_custname
         and (object_type like 'PACKAGE%' or object_type = 'FUNCTION' or object_type = 'PROCEDURE')
         and object_type = nvl(p_type,object_type)
         and object_name = nvl(p_name,object_name)
      group by case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                    else upper(object_type)
               end,
               object_name
      order by object_type, object_name;
  begin

    if p_type is null and p_name is null then
      delete tcustmodify where custname = p_custname;
    end if;

    for r1 in c1 loop
      dbms_output.put_line(p_custname||' - '||r1.object_type||' - '||r1.object_name);
      update_change(p_custname, r1.object_type, r1.object_name);
      dbms_output.put_line('-------------------------');
    end loop;

    commit;
  end;
end;

/
