--------------------------------------------------------
--  DDL for Package Body SECUR_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "SECUR_MAIN" IS

  --user14 07/12/2012 add get_numdec(numlvlst,p_coduser)

  /*----------------------------------------------*/
  /* Check security group and level from filemain */
  /*----------------------------------------------*/
  function secur1(p_codcomp in varchar2,p_numlvl  in number,p_coduser in varchar2,
                  p_zminlvl in number  ,p_zwrklvl in number,p_zupdsal out varchar2,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return boolean is
    v_count        number    :=  0;
    v_numlvlst     number    :=  0;
    v_numlvlen     number    :=  0;
    v_numlvlsalst  number    :=  0;
    v_numlvlsalen  number    :=  0;
  begin
    if p_numlvlsalst is null or p_numlvlsalen is null then
      begin
        --select numlvlst,numlvlen,numlvlsalst,numlvlsalen
        select get_numdec(numlvlsalst,p_coduser) numlvlsalst ,get_numdec(numlvlsalen,p_coduser) numlvlsalen
          into v_numlvlsalst,v_numlvlsalen
          from tusrprof
         where coduser = p_coduser ;
      exception when no_data_found then
        return false;
      end ;
    else
      v_numlvlsalst := p_numlvlsalst;
      v_numlvlsalen := p_numlvlsalen;
    end if;

    v_numlvlst := p_zminlvl ;
    v_numlvlen := p_zwrklvl ;
    if p_numlvl between  v_numlvlst and v_numlvlen then
      if p_codcomp is not null then
        begin
          select count(codcomp) into v_count
            from tusrcom
           where coduser = upper(p_coduser)
             and p_codcomp like  codcomp||'%'
             and rownum   <= 1;
          if v_count <> 0 then
            zflgsecu := true;
          else
            zflgsecu := false;
          end if;
        exception when no_data_found then
          zflgsecu := true;
        end;
      else
        zflgsecu := false;
      end if;

      if p_numlvl between v_numlvlsalst and v_numlvlsalen then
        p_zupdsal := 'Y' ;
      else
        p_zupdsal := 'N' ;
      end if;
    else
      zflgsecu := false;
    end if;
    return(zflgsecu);
  end secur1;

  /*----------------------------------------------*/
  function secur (p_check in varchar ,p_codcomp in varchar2,p_numlvl  in number,p_coduser in varchar2,
                  p_zminlvl in number  ,p_zwrklvl in number,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return varchar is
    v_count        number    :=  0;
    v_numlvlst     number    :=  0;
    v_numlvlen     number    :=  0;
    v_numlvlsalst  number    :=  0;
    v_numlvlsalen  number    :=  0;
    v_pass         varchar2(1);
  begin
    if p_check = 'N' then
      return 'Y' ;
    else
      if p_numlvlsalst is null or p_numlvlsalen is null then
        begin
          --select numlvlst,numlvlen,numlvlsalst,numlvlsalen
          select get_numdec(numlvlsalst,p_coduser) numlvlsalst ,get_numdec(numlvlsalen,p_coduser) numlvlsalen
            into v_numlvlsalst,v_numlvlsalen
            from tusrprof
           where coduser = p_coduser ;
        exception when no_data_found then
          return 'N' ;
        end ;
      else
        v_numlvlsalst := p_numlvlsalst;
        v_numlvlsalen := p_numlvlsalen;
      end if;

      v_numlvlst := p_zminlvl ;
      v_numlvlen := p_zwrklvl ;
      if p_numlvl between  v_numlvlst and v_numlvlen then
        if  p_codcomp is not null then
          begin
            select count(codcomp) into v_count
              from tusrcom
             where coduser = UPPER(p_coduser)
               and p_codcomp  like  codcomp||'%'
               and rownum   <= 1;
            if v_count <> 0 then
              v_pass := 'Y';
            else
              v_pass := 'N';
            end if;
          exception when no_data_found then
            v_pass := 'Y';
          end;
        else
          v_pass := 'N';
        end if;
      else
        v_pass := 'N';
      end if;
      return v_pass ;
    end if;
  end secur;

  /*----------------------------------------------*/
  function secur2(p_codempid in varchar2,p_coduser in varchar2,
                  p_zminlvl in number,p_zwrklvl number,p_zupdsal out varchar2,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return boolean is
    t_numlvl        temploy1.numlvl%type;
    t_codcomp       temploy1.codcomp%type;
    v_count         number   := 0;
    v_numlvlst      number    :=  0;
    v_numlvlen      number    :=  0;
    v_numlvlsalst   number    :=  0;
    v_numlvlsalen   number    :=  0;
  begin

    if p_numlvlsalst is null or p_numlvlsalen is null then
      begin
        --select numlvlst,numlvlen,numlvlsalst,numlvlsalen
        select get_numdec(numlvlsalst,p_coduser) numlvlsalst ,get_numdec(numlvlsalen,p_coduser) numlvlsalen
          into v_numlvlsalst,v_numlvlsalen
          from tusrprof
         where coduser = p_coduser ;
      exception when no_data_found then
        return false ;
      end ;
    else
      v_numlvlsalst := p_numlvlsalst;
      v_numlvlsalen := p_numlvlsalen;
    end if;

    v_numlvlst := p_zminlvl ;
    v_numlvlen := p_zwrklvl ;
    begin
      select numlvl,codcomp into t_numlvl,t_codcomp
        from temploy1
       where codempid = p_codempid;

      if t_numlvl is not null and t_codcomp is not null then
        if t_numlvl between  v_numlvlst and v_numlvlen then
          begin
            select count(codcomp) into v_count
             from tusrcom
            where coduser = upper(p_coduser)
              and t_codcomp  like  codcomp||'%'
              and rownum   <= 1;
            if v_count <> 0 then
              zflgsecu := true;
            else
              zflgsecu := false;
            end if;
          exception when no_data_found then
            zflgsecu := true;
          end;
        else
          zflgsecu := false;
        end if;
      else
        zflgsecu := false;
      end if;
    exception when no_data_found then
      zflgsecu := true;
    end;

    if t_numlvl between v_numlvlsalst and v_numlvlsalen then
      p_zupdsal := 'Y' ;
    else
      p_zupdsal := 'N' ;
    end if;
    return(zflgsecu);
  end secur2;

  /*----------------------------------------------*/
  function secur3(p_codcomp in varchar2,p_codempid in varchar2,p_coduser in varchar2,
                  p_zminlvl in number,p_zwrklvl number,p_zupdsal out varchar2,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return boolean is
    t_numlvl temploy1.numlvl%type;
    v_count  number  := 0;
    v_numlvlst     number    :=  0;
    v_numlvlen     number    :=  0;
    v_numlvlsalst  number    :=  0;
    v_numlvlsalen  number    :=  0;
  begin
    if p_numlvlsalst is null or p_numlvlsalen is null then
      begin
        --select numlvlst,numlvlen,numlvlsalst,numlvlsalen
        select get_numdec(numlvlsalst,p_coduser) numlvlsalst ,get_numdec(numlvlsalen,p_coduser) numlvlsalen
          into v_numlvlsalst,v_numlvlsalen
          from tusrprof
         where coduser = p_coduser ;
      exception when no_data_found then
        return false ;
      end ;
    else
      v_numlvlsalst := p_numlvlsalst;
      v_numlvlsalen := p_numlvlsalen;
    end if;
    v_numlvlst := p_zminlvl ;
    v_numlvlen := p_zwrklvl ;
    begin
      select numlvl into t_numlvl
      from  temploy1
      where codempid = p_codempid
      and   rownum     <= 1;
      if t_numlvl is not null then
        if t_numlvl between  p_zminlvl and p_zwrklvl then
          if p_codcomp is not null then
            begin
              select count(codcomp) into v_count
                from tusrcom
               where coduser = upper(p_coduser)
                 and p_codcomp  like  codcomp||'%'
                 and rownum   <= 1;
              if v_count <> 0 then
                zflgsecu := true;
              else
                zflgsecu := false;
              end if;
            exception when no_data_found then  zflgsecu := TRUE;
            end;
          else
            zflgsecu := false;
          end if;
        else
          zflgsecu := false;
        end if;
        if t_numlvl between v_numlvlsalst and v_numlvlsalen then
          p_zupdsal := 'Y' ;
        else
          p_zupdsal := 'N' ;
        end if;
      else
        zflgsecu := false;
      end if;
    exception when no_data_found then
      zflgsecu := false;
    end;
    return(zflgsecu);
  end secur3;

  /*----------------------------------------------*/
  function secur7(p_codcomp in varchar2,p_coduser in varchar2) return boolean is
    v_count    number    := 0;
  begin
    if p_codcomp is not null then
      begin
        select count(codcomp) into v_count
          from tusrcom
         where coduser = upper(p_coduser)
           and codcomp like replace(substr(p_codcomp,1,length(codcomp))||'%',' ','_')
--           and codcomp like (RPAD(p_codcomp,LENGTH(codcomp),'_')||'%')
           and rownum   <= 1;
        if v_count <> 0 then
          zflgsecu := true;
        else
          zflgsecu := false;
        end if;
      exception when no_data_found then zflgsecu := TRUE;
      end;
    else
      zflgsecu := true;
    end if;
    return(zflgsecu);
  end secur7;
end;
/*-----------------------------*/
/* End Of Package Body         */
/*-----------------------------*/

/
