--------------------------------------------------------
--  DDL for Package Body PLJSON_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "PLJSON_HELPER" as
  
  --recursive merge
  function merge( p_a_json pljson, p_b_json pljson) return pljson as
    l_json    pljson;
    l_jv      pljson_value;
    l_indx    number;
    l_recursive pljson_value;
  begin
    --
    -- Initialize our return object
    --
    l_json := p_a_json;

    -- loop through p_b_json
    l_indx := p_b_json.json_data.first;
    loop
      exit when l_indx is null;
      l_jv   := p_b_json.json_data(l_indx);
      if(l_jv.is_object) then
        --recursive
        l_recursive := l_json.get(l_jv.mapname);
        if(l_recursive is not null and l_recursive.is_object) then
          l_json.put(l_jv.mapname, merge(pljson(l_recursive), pljson(l_jv)));
        else
          l_json.put(l_jv.mapname, l_jv);
        end if;
      else
        l_json.put(l_jv.mapname, l_jv);
      end if;

      --increment
      l_indx := p_b_json.json_data.next(l_indx);
    end loop;

    return l_json;

  end merge;

  -- join two lists
  function join( p_a_list pljson_list, p_b_list pljson_list) return pljson_list as
    l_json_list pljson_list := p_a_list;
  begin
    for indx in 1 .. p_b_list.count loop
      l_json_list.append(p_b_list.get(indx));
    end loop;

    return l_json_list;

  end join;

  -- keep keys.
  function keep( p_json pljson, p_keys pljson_list) return pljson as
    l_json pljson := pljson();
    mapname varchar2(4000);
  begin
    for i in 1 .. p_keys.count loop
      mapname := p_keys.get(i).get_string;
      if(p_json.exist(mapname)) then
        l_json.put(mapname, p_json.get(mapname));
      end if;
    end loop;

    return l_json;
  end keep;

  -- drop keys.
  function remove( p_json pljson, p_keys pljson_list) return pljson as
    l_json pljson := p_json;
  begin
    for i in 1 .. p_keys.count loop
      l_json.remove(p_keys.get(i).get_string);
    end loop;

    return l_json;
  end remove;

  --equals functions

  function equals(p_v1 pljson_value, p_v2 number) return boolean as
  begin
    if(p_v2 is null) then
      return p_v1.is_null;
    end if;

    if(not p_v1.is_number) then
      return false;
    end if;

    return p_v2 = p_v1.get_number;
  end;

  /* E.I.Sarmas (github.com/dsnz)   2016-12-01   support for binary_double numbers */
  function equals(p_v1 pljson_value, p_v2 binary_double) return boolean as
  begin
    if(p_v2 is null) then
      return p_v1.is_null;
    end if;

    if(not p_v1.is_number) then
      return false;
    end if;

    return p_v2 = p_v1.get_double;
  end;

  function equals(p_v1 pljson_value, p_v2 boolean) return boolean as
  begin
    if(p_v2 is null) then
      return p_v1.is_null;
    end if;

    if(not p_v1.is_bool) then
      return false;
    end if;

    return p_v2 = p_v1.get_bool;
  end;

  function equals(p_v1 pljson_value, p_v2 varchar2) return boolean as
  begin
    if(p_v2 is null) then
      return (p_v1.is_null or p_v1.get_string is null);
    end if;

    if(not p_v1.is_string) then
      return false;
    end if;

    return p_v2 = p_v1.get_string;
  end;

  function equals(p_v1 pljson_value, p_v2 clob) return boolean as
    my_clob clob;
    res boolean;
  begin
    if(p_v2 is null) then
      return p_v1.is_null;
    end if;

    if(not p_v1.is_string) then
      return false;
    end if;

    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    p_v1.get_string(my_clob);

    res := dbms_lob.compare(p_v2, my_clob) = 0;
    dbms_lob.freetemporary(my_clob);
    return res;
  end;

  function equals(p_v1 pljson_value, p_v2 pljson_value, exact boolean) return boolean as
  begin
    if(p_v2 is null or p_v2.is_null) then
      return (p_v1 is null or p_v1.is_null);
    end if;

    if(p_v2.is_number) then return equals(p_v1, p_v2.get_number); end if;
    if(p_v2.is_bool) then return equals(p_v1, p_v2.get_bool); end if;
    if(p_v2.is_object) then return equals(p_v1, pljson(p_v2), exact); end if;
    if(p_v2.is_array) then return equals(p_v1, pljson_list(p_v2), exact); end if;
    if(p_v2.is_string) then
      if(p_v2.extended_str is null) then
        return equals(p_v1, p_v2.get_string);
      else
        declare
          my_clob clob; res boolean;
        begin
          my_clob := empty_clob();
          dbms_lob.createtemporary(my_clob, true);
          p_v2.get_string(my_clob);
          res := equals(p_v1, my_clob);
          dbms_lob.freetemporary(my_clob);
          return res;
        end;
      end if;
    end if;

    return false; --should never happen
  end;

  function equals(p_v1 pljson_value, p_v2 pljson_list, exact boolean) return boolean as
    cmp pljson_list;
    res boolean := true;
  begin
--  p_v1.print(false);
--  p_v2.print(false);
--  dbms_output.put_line('labc1'||case when exact then 'X' else 'U' end);

    if(p_v2 is null) then
      return p_v1.is_null;
    end if;

    if(not p_v1.is_array) then
      return false;
    end if;

--  dbms_output.put_line('labc2'||case when exact then 'X' else 'U' end);

    cmp := pljson_list(p_v1);
    if(cmp.count != p_v2.count and exact) then return false; end if;

--  dbms_output.put_line('labc3'||case when exact then 'X' else 'U' end);

    if(exact) then
      for i in 1 .. cmp.count loop
        res := equals(cmp.get(i), p_v2.get(i), exact);
        if(not res) then return res; end if;
      end loop;
    else
--  dbms_output.put_line('labc4'||case when exact then 'X' else 'U' end);
      if(p_v2.count > cmp.count) then return false; end if;
--  dbms_output.put_line('labc5'||case when exact then 'X' else 'U' end);

      --match sublist here!
      for x in 0 .. (cmp.count-p_v2.count) loop
--  dbms_output.put_line('labc7'||x);

        for i in 1 .. p_v2.count loop
          res := equals(cmp.get(x+i), p_v2.get(i), exact);
          if(not res) then
            goto next_index;
          end if;
        end loop;
        return true;

        <<next_index>>
        null;
      end loop;

--  dbms_output.put_line('labc7'||case when exact then 'X' else 'U' end);

    return false; --no match

    end if;

    return res;
  end;

  function equals(p_v1 pljson_value, p_v2 pljson, exact boolean) return boolean as
    cmp pljson;
    res boolean := true;
  begin
--  p_v1.print(false);
--  p_v2.print(false);
--  dbms_output.put_line('abc1');

    if(p_v2 is null) then
      return p_v1.is_null;
    end if;

    if(not p_v1.is_object) then
      return false;
    end if;

    cmp := pljson(p_v1);

--  dbms_output.put_line('abc2');

    if(cmp.count != p_v2.count and exact) then return false; end if;

--  dbms_output.put_line('abc3');
    declare
      k1 pljson_list := p_v2.get_keys;
      key_index number;
    begin
      for i in 1 .. k1.count loop
        key_index := cmp.index_of(k1.get(i).get_string);
        if(key_index = -1) then return false; end if;
        if(exact) then
          if(not equals(p_v2.get(i), cmp.get(key_index), true)) then return false; end if;
        else
          --non exact
          declare
            v1 pljson_value := cmp.get(key_index);
            v2 pljson_value := p_v2.get(i);
          begin
--  dbms_output.put_line('abc3 1/2');
--            v1.print(false);
--            v2.print(false);

            if(v1.is_object and v2.is_object) then
              if(not equals(v1, v2, false)) then return false; end if;
            elsif(v1.is_array and v2.is_array) then
              if(not equals(v1, v2, false)) then return false; end if;
            else
              if(not equals(v1, v2, true)) then return false; end if;
            end if;
          end;

        end if;
      end loop;
    end;

--  dbms_output.put_line('abc4');

    return true;
  end;

  function equals(p_v1 pljson, p_v2 pljson, exact boolean) return boolean as
  begin
    return equals(p_v1.to_json_value, p_v2, exact);
  end;

  function equals(p_v1 pljson_list, p_v2 pljson_list, exact boolean) return boolean as
  begin
    return equals(p_v1.to_json_value, p_v2, exact);
  end;

  --contain
  function contains(p_v1 pljson, p_v2 pljson_value, exact boolean) return boolean as
    v_values pljson_list;
  begin
    if(equals(p_v1.to_json_value, p_v2, exact)) then return true; end if;

    v_values := p_v1.get_values;

    for i in 1 .. v_values.count loop
      declare
        v_val pljson_value := v_values.get(i);
      begin
        if(v_val.is_object) then
          if(contains(pljson(v_val), p_v2, exact)) then return true; end if;
        end if;
        if(v_val.is_array) then
          if(contains(pljson_list(v_val), p_v2, exact)) then return true; end if;
        end if;

        if(equals(v_val, p_v2, exact)) then return true; end if;
      end;

    end loop;

    return false;
  end;

  function contains(p_v1 pljson_list, p_v2 pljson_value, exact boolean) return boolean as
  begin
    if(equals(p_v1.to_json_value, p_v2, exact)) then return true; end if;

    for i in 1 .. p_v1.count loop
      declare
        v_val pljson_value := p_v1.get(i);
      begin
        if(v_val.is_object) then
          if(contains(pljson(v_val), p_v2, exact)) then return true; end if;
        end if;
        if(v_val.is_array) then
          if(contains(pljson_list(v_val), p_v2, exact)) then return true; end if;
        end if;

        if(equals(v_val, p_v2, exact)) then return true; end if;
      end;

    end loop;

    return false;
  end;

  function contains(p_v1 pljson, p_v2 pljson, exact boolean ) return boolean as
  begin return contains(p_v1, p_v2.to_json_value, exact); end;
  function contains(p_v1 pljson, p_v2 pljson_list, exact boolean ) return boolean as
  begin return contains(p_v1, p_v2.to_json_value, exact); end;
  function contains(p_v1 pljson, p_v2 number, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  /* E.I.Sarmas (github.com/dsnz)   2016-12-01   support for binary_double numbers */
  function contains(p_v1 pljson, p_v2 binary_double, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  function contains(p_v1 pljson, p_v2 varchar2, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  function contains(p_v1 pljson, p_v2 boolean, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  function contains(p_v1 pljson, p_v2 clob, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;

  function contains(p_v1 pljson_list, p_v2 pljson, exact boolean ) return boolean as begin
  return contains(p_v1, p_v2.to_json_value, exact); end;
  function contains(p_v1 pljson_list, p_v2 pljson_list, exact boolean ) return boolean as begin
  return contains(p_v1, p_v2.to_json_value, exact); end;
  function contains(p_v1 pljson_list, p_v2 number, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  /* E.I.Sarmas (github.com/dsnz)   2016-12-01   support for binary_double numbers */
  function contains(p_v1 pljson_list, p_v2 binary_double, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  function contains(p_v1 pljson_list, p_v2 varchar2, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  function contains(p_v1 pljson_list, p_v2 boolean, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;
  function contains(p_v1 pljson_list, p_v2 clob, exact boolean ) return boolean as begin
  return contains(p_v1, pljson_value(p_v2), exact); end;


end pljson_helper;

/

  GRANT EXECUTE ON "PLJSON_HELPER" TO PUBLIC;
