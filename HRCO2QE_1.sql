--------------------------------------------------------
--  DDL for Package Body HRCO2QE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2QE" is
-- last update: 19/03/2020 17:20
  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codapp          := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codproc         := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));

    p_codcust         := hcm_util.get_string_t(json_obj,'p_codcust');

    json_params       := hcm_util.get_json_t(json_obj, 'params');
    json_params2       := hcm_util.get_json_t(json_obj, 'param_json');
  end initial_value;
----------------------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    --obj_result  json;
    v_rcnt      number := 0;

    cursor c_tcust is
            SELECT t.codcust ,
                   get_tcust_name (t.codcust ,global_v_lang ) as namcust
            FROM tcust t
            ORDER BY t.codcust ;

  begin
    obj_row     := json_object_t();
    --obj_result  := json();
    for r_tcust in c_tcust loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codapp', p_codapp);

        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);

        obj_data.put('codcust', r_tcust.codcust);
        obj_data.put('namcust', r_tcust.namcust);


        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;

  end gen_index;

  ----------------------------------------------------------------------------------
  procedure save_tcust (json_str_input in clob, json_str_output out clob) is
    --obj_data      json;
    --obj_row       json;
    --obj_result    json;
    v_codcust     tcust.codcust%type;
    ----------------------------------
    v_namcust     tcust.namcuste%type;
    v_namcuste    tcust.namcuste%type;
    v_namcustt    tcust.namcustt%type;
    v_namcust3    tcust.namcust3%type;
    v_namcust4    tcust.namcust4%type;
    v_namcust5    tcust.namcust5%type;
    ----------------------------------
    v_namst       tcust.namste%type;
    v_namste      tcust.namste%type;
    v_namstt      tcust.namstt%type;
    v_namst3      tcust.namst3%type;
    v_namst4      tcust.namst4%type;
    v_namst5      tcust.namst5%type;
    ----------------------------------
    v_adrcuste    tcust.adrcuste%type;
    v_adrcustt    tcust.adrcustt%type;
    v_adrcust3    tcust.adrcust3%type;
    v_adrcust4    tcust.adrcust4%type;
    v_adrcust5    tcust.adrcust5%type;
    ----------------------------------
    v_building    tcust.buildinge%type;
    v_buildinge   tcust.buildinge%type;
    v_buildingt   tcust.buildingt%type;
    v_building3   tcust.building3%type;
    v_building4   tcust.building4%type;
    v_building5   tcust.building5%type;
    ----------------------------------
    v_roomno      tcust.roomnoe%type;
    v_roomnoe     tcust.roomnoe%type;
    v_roomnot     tcust.roomnot%type;
    v_roomno3     tcust.roomno3%type;
    v_roomno4     tcust.roomno4%type;
    v_roomno5     tcust.roomno5%type;
    ----------------------------------
    v_floor       tcust.floore%type;
    v_floore      tcust.floore%type;
    v_floort      tcust.floort%type;
    v_floor3      tcust.floor3%type;
    v_floor4      tcust.floor4%type;
    v_floor5      tcust.floor5%type;
    ----------------------------------
    v_village     tcust.villagee%type;
    v_villagee    tcust.villagee%type;
    v_villaget    tcust.villaget%type;
    v_village3    tcust.village3%type;
    v_village4    tcust.village4%type;
    v_village5    tcust.village5%type;
    ----------------------------------
    v_addrno      tcust.addrnoe%type;
    v_addrnoe     tcust.addrnoe%type;
    v_addrnot     tcust.addrnot%type;
    v_addrno3     tcust.addrno3%type;
    v_addrno4     tcust.addrno4%type;
    v_addrno5     tcust.addrno5%type;
    ----------------------------------
    v_moo         tcust.mooe%type;
    v_mooe        tcust.mooe%type;
    v_moot        tcust.moot%type;
    v_moo3        tcust.moo3%type;
    v_moo4        tcust.moo4%type;
    v_moo5        tcust.moo5%type;
    ----------------------------------
    v_soi         tcust.soie%type;
    v_soie        tcust.soie%type;
    v_soit        tcust.soit%type;
    v_soi3        tcust.soi3%type;
    v_soi4        tcust.soi4%type;
    v_soi5        tcust.soi5%type;
    ----------------------------------
    v_road        tcust.roade%type;
    v_roade       tcust.roade%type;
    v_roadt       tcust.roadt%type;
    v_road3       tcust.road3%type;
    v_road4       tcust.road4%type;
    v_road5       tcust.road5%type;
    ----------------------------------
    v_codsubdist  tcust.codsubdist%type;
    v_coddist     tcust.coddist%type;
    v_codprovr    tcust.codprovr%type;
    v_zipcode     tcust.zipcode%type;
    v_numtele     tcust.numtele%type;
    v_numfax      tcust.numfax%type;
    v_email       tcust.email%type;
    v_website     tcust.website%type;
    v_latitude    tcust.latitude%type;
    v_longitude   tcust.longitude%type;
    v_radius      tcust.radius%type;
    v_radiuso     tcust.radiuso%type;

    v_count_chk     number;
    ----------------------------------
  begin
      initial_value(json_str_input);

      v_codcust    := hcm_util.get_string_t(json_params, 'codcust');
      ----------------------------------
      v_namcust    := hcm_util.get_string_t(json_params, 'namcust');
      v_namcuste   := hcm_util.get_string_t(json_params, 'namcuste');
      v_namcustt   := hcm_util.get_string_t(json_params, 'namcustt');
      v_namcust3   := hcm_util.get_string_t(json_params, 'namcust3');
      v_namcust4   := hcm_util.get_string_t(json_params, 'namcust4');
      v_namcust5   := hcm_util.get_string_t(json_params, 'namcust5');
      ----------------------------------
      v_namst      := hcm_util.get_string_t(json_params, 'namst');
      v_namste     := hcm_util.get_string_t(json_params, 'namste');
      v_namstt     := hcm_util.get_string_t(json_params, 'namstt');
      v_namst3     := hcm_util.get_string_t(json_params, 'namst3');
      v_namst4     := hcm_util.get_string_t(json_params, 'namst4');
      v_namst5     := hcm_util.get_string_t(json_params, 'namst5');
      ----------------------------------
      v_building   := hcm_util.get_string_t(json_params, 'building');
      v_buildinge  := hcm_util.get_string_t(json_params, 'buildinge');
      v_buildingt  := hcm_util.get_string_t(json_params, 'buildingt');
      v_building3  := hcm_util.get_string_t(json_params, 'building3');
      v_building4  := hcm_util.get_string_t(json_params, 'building4');
      v_building5  := hcm_util.get_string_t(json_params, 'building5');
      ----------------------------------
      v_roomno     := hcm_util.get_string_t(json_params, 'roomno');
      v_roomnoe    := hcm_util.get_string_t(json_params, 'roomnoe');
      v_roomnot    := hcm_util.get_string_t(json_params, 'roomnot');
      v_roomno3    := hcm_util.get_string_t(json_params, 'roomno3');
      v_roomno4    := hcm_util.get_string_t(json_params, 'roomno4');
      v_roomno5    := hcm_util.get_string_t(json_params, 'roomno5');
      ----------------------------------
      v_floor      := hcm_util.get_string_t(json_params, 'floor');
      v_floore     := hcm_util.get_string_t(json_params, 'floore');
      v_floort     := hcm_util.get_string_t(json_params, 'floort');
      v_floor3     := hcm_util.get_string_t(json_params, 'floor3');
      v_floor4     := hcm_util.get_string_t(json_params, 'floor4');
      v_floor5     := hcm_util.get_string_t(json_params, 'floor5');
      ----------------------------------
      v_village    := hcm_util.get_string_t(json_params, 'village');
      v_villagee   := hcm_util.get_string_t(json_params, 'villagee');
      v_villaget   := hcm_util.get_string_t(json_params, 'villaget');
      v_village3   := hcm_util.get_string_t(json_params, 'village3');
      v_village4   := hcm_util.get_string_t(json_params, 'village4');
      v_village5   := hcm_util.get_string_t(json_params, 'village5');
      ----------------------------------
      v_addrno     := hcm_util.get_string_t(json_params, 'addrno');
      v_addrnoe    := hcm_util.get_string_t(json_params, 'addrnoe');
      v_addrnot    := hcm_util.get_string_t(json_params, 'addrnot');
      v_addrno3    := hcm_util.get_string_t(json_params, 'addrno3');
      v_addrno4    := hcm_util.get_string_t(json_params, 'addrno4');
      v_addrno5    := hcm_util.get_string_t(json_params, 'addrno5');
      ----------------------------------
      v_moo        := hcm_util.get_string_t(json_params, 'moo');
      v_mooe       := hcm_util.get_string_t(json_params, 'mooe');
      v_moot       := hcm_util.get_string_t(json_params, 'moot');
      v_moo3       := hcm_util.get_string_t(json_params, 'moo3');
      v_moo4       := hcm_util.get_string_t(json_params, 'moo4');
      v_moo5       := hcm_util.get_string_t(json_params, 'moo5');
      ----------------------------------
      v_soi        := hcm_util.get_string_t(json_params, 'soi');
      v_soie       := hcm_util.get_string_t(json_params, 'soie');
      v_soit       := hcm_util.get_string_t(json_params, 'soit');
      v_soi3       := hcm_util.get_string_t(json_params, 'soi3');
      v_soi4       := hcm_util.get_string_t(json_params, 'soi4');
      v_soi5       := hcm_util.get_string_t(json_params, 'soi5');
      ----------------------------------
      v_road       := hcm_util.get_string_t(json_params, 'road');
      v_roade      := hcm_util.get_string_t(json_params, 'roade');
      v_roadt      := hcm_util.get_string_t(json_params, 'roadt');
      v_road3      := hcm_util.get_string_t(json_params, 'road3');
      v_road4      := hcm_util.get_string_t(json_params, 'road4');
      v_road5      := hcm_util.get_string_t(json_params, 'road5');
      ----------------------------------
      v_codsubdist := hcm_util.get_string_t(json_params, 'codsubdist');
      v_coddist    := hcm_util.get_string_t(json_params, 'coddist');
      v_codprovr   := hcm_util.get_string_t(json_params, 'codprovr');
      v_zipcode    := hcm_util.get_string_t(json_params, 'zipcode');
      v_numtele    := hcm_util.get_string_t(json_params, 'numtele');
      v_numfax     := hcm_util.get_string_t(json_params, 'numfax');
      v_email      := hcm_util.get_string_t(json_params, 'email');
      v_website    := hcm_util.get_string_t(json_params, 'website');
      v_latitude   := hcm_util.get_string_t(json_params, 'latitude');
      v_longitude  := hcm_util.get_string_t(json_params, 'longitude');
      v_radius     := hcm_util.get_string_t(json_params, 'radius');
      v_radiuso    := hcm_util.get_string_t(json_params, 'radiuso');
      ----------------------------------
      v_adrcuste    :=  case when v_buildinge is not null then get_label_name('HRCO2QE2', '101' , '30') || ' ' || v_buildinge || ' ' end ||
                        case when v_roomnoe is not null then get_label_name('HRCO2QE2', '101' , '40') || ' ' || v_roomnoe || ' ' end ||
                        case when v_floore is not null then get_label_name('HRCO2QE2', '101' , '50') || ' ' || v_floore || ' ' end ||
                        case when v_villagee is not null then get_label_name('HRCO2QE2', '101' , '60') || ' ' || v_villagee || ' ' end ||
                        case when v_addrnoe is not null then get_label_name('HRCO2QE2', '101' , '70') || ' ' || v_addrnoe || ' ' end ||
                        case when v_mooe is not null then get_label_name('HRCO2QE2', '101' , '80') || ' ' || v_mooe || ' ' end ||
                        case when v_soie is not null then get_label_name('HRCO2QE2', '101' , '90') || ' ' || v_soie || ' ' end ||
                        case when v_roade is not null then get_label_name('HRCO2QE2', '101' , '100') || ' ' || v_roade || ' ' end ||
                        case when v_codsubdist is not null then get_label_name('HRCO2QE2', '101' , '130') || ' ' || get_tsubdist_name(v_codsubdist, '101') || ' ' end ||
                        case when v_coddist is not null then get_label_name('HRCO2QE2', '101' , '120') || ' ' || get_tcoddist_name(v_coddist, '101') || ' ' end ||
                        case when v_codprovr is not null then get_label_name('HRCO2QE2', '101' , '110') || ' ' || get_tcodec_name('TCODPROV', v_codprovr, '101') end;

      v_adrcustt    :=  case when v_buildingt is not null then get_label_name('HRCO2QE2', '102' , '30') || ' ' || v_buildingt || ' ' end ||
                        case when v_roomnot is not null then get_label_name('HRCO2QE2', '102' , '40') || ' ' || v_roomnot || ' ' end ||
                        case when v_floort is not null then get_label_name('HRCO2QE2', '102' , '50') || ' ' || v_floort || ' ' end ||
                        case when v_villaget is not null then get_label_name('HRCO2QE2', '102' , '60') || ' ' || v_villaget || ' ' end ||
                        case when v_addrnot is not null then get_label_name('HRCO2QE2', '102' , '70') || ' ' || v_addrnot || ' ' end ||
                        case when v_moot is not null then get_label_name('HRCO2QE2', '102' , '80') || ' ' || v_moot || ' ' end ||
                        case when v_soit is not null then get_label_name('HRCO2QE2', '102' , '90') || ' ' || v_soit || ' ' end ||
                        case when v_roadt is not null then get_label_name('HRCO2QE2', '102' , '100') || ' ' || v_roadt || ' ' end ||
                        case when v_codsubdist is not null then get_label_name('HRCO2QE2', '102' , '130') || ' ' || get_tsubdist_name(v_codsubdist, '102') || ' ' end ||
                        case when v_coddist is not null then get_label_name('HRCO2QE2', '102' , '120') || ' ' || get_tcoddist_name(v_coddist, '102') || ' ' end ||
                        case when v_codprovr is not null then get_label_name('HRCO2QE2', '102' , '110') || ' ' || get_tcodec_name('TCODPROV', v_codprovr, '102') end;

      v_adrcust3    :=  case when v_building3 is not null then get_label_name('HRCO2QE2', '103' , '30') || ' ' || v_building3 || ' ' end ||
                        case when v_roomno3 is not null then get_label_name('HRCO2QE2', '103' , '40') || ' ' || v_roomno3 || ' ' end ||
                        case when v_floor3 is not null then get_label_name('HRCO2QE2', '103' , '50') || ' ' || v_floor3 || ' ' end ||
                        case when v_village3 is not null then get_label_name('HRCO2QE2', '103' , '60') || ' ' || v_village3 || ' ' end ||
                        case when v_addrno3 is not null then get_label_name('HRCO2QE2', '103' , '70') || ' ' || v_addrno3 || ' ' end ||
                        case when v_moo3 is not null then get_label_name('HRCO2QE2', '103' , '80') || ' ' || v_moo3 || ' ' end ||
                        case when v_soi3 is not null then get_label_name('HRCO2QE2', '103' , '90') || ' ' || v_soi3 || ' ' end ||
                        case when v_road3 is not null then get_label_name('HRCO2QE2', '103' , '100') || ' ' || v_road3 || ' ' end ||
                        case when v_codsubdist is not null then get_label_name('HRCO2QE2', '103' , '130') || ' ' || get_tsubdist_name(v_codsubdist, '103') || ' ' end ||
                        case when v_coddist is not null then get_label_name('HRCO2QE2', '103' , '120') || ' ' || get_tcoddist_name(v_coddist, '103') || ' ' end ||
                        case when v_codprovr is not null then get_label_name('HRCO2QE2', '103' , '110') || ' ' || get_tcodec_name('TCODPROV', v_codprovr, '103') end;

      v_adrcust4    :=  case when v_building4 is not null then get_label_name('HRCO2QE2', '104' , '30') || ' ' || v_building4 || ' ' end ||
                        case when v_roomno4 is not null then get_label_name('HRCO2QE2', '104' , '40') || ' ' || v_roomno4 || ' ' end ||
                        case when v_floor4 is not null then get_label_name('HRCO2QE2', '104' , '50') || ' ' || v_floor4 || ' ' end ||
                        case when v_village4 is not null then get_label_name('HRCO2QE2', '104' , '60') || ' ' || v_village4 || ' ' end ||
                        case when v_addrno4 is not null then get_label_name('HRCO2QE2', '104' , '70') || ' ' || v_addrno4 || ' ' end ||
                        case when v_moo4 is not null then get_label_name('HRCO2QE2', '104' , '80') || ' ' || v_moo4 || ' ' end ||
                        case when v_soi4 is not null then get_label_name('HRCO2QE2', '104' , '90') || ' ' || v_soi4 || ' ' end ||
                        case when v_road4 is not null then get_label_name('HRCO2QE2', '104' , '100') || ' ' || v_road4 || ' ' end ||
                        case when v_codsubdist is not null then get_label_name('HRCO2QE2', '104' , '130') || ' ' || get_tsubdist_name(v_codsubdist, '104') || ' ' end ||
                        case when v_coddist is not null then get_label_name('HRCO2QE2', '104' , '120') || ' ' || get_tcoddist_name(v_coddist, '104') || ' ' end ||
                        case when v_codprovr is not null then get_label_name('HRCO2QE2', '104' , '110') || ' ' || get_tcodec_name('TCODPROV', v_codprovr, '104') end;

      v_adrcust5    :=  case when v_building5 is not null then get_label_name('HRCO2QE2', '105' , '30') || ' ' || v_building5 || ' ' end ||
                        case when v_roomno5 is not null then get_label_name('HRCO2QE2', '105' , '40') || ' ' || v_roomno5 || ' ' end ||
                        case when v_floor5 is not null then get_label_name('HRCO2QE2', '105' , '50') || ' ' || v_floor5 || ' ' end ||
                        case when v_village5 is not null then get_label_name('HRCO2QE2', '105' , '60') || ' ' || v_village5 || ' ' end ||
                        case when v_addrno5 is not null then get_label_name('HRCO2QE2', '105' , '70') || ' ' || v_addrno5 || ' ' end ||
                        case when v_moo5 is not null then get_label_name('HRCO2QE2', '105' , '80') || ' ' || v_moo5 || ' ' end ||
                        case when v_soi5 is not null then get_label_name('HRCO2QE2', '105' , '90') || ' ' || v_soi5 || ' ' end ||
                        case when v_road5 is not null then get_label_name('HRCO2QE2', '105' , '100') || ' ' || v_road5 || ' ' end ||
                        case when v_codsubdist is not null then get_label_name('HRCO2QE2', '105' , '130') || ' ' || get_tsubdist_name(v_codsubdist, '105') || ' ' end ||
                        case when v_coddist is not null then get_label_name('HRCO2QE2', '105' , '120') || ' ' || get_tcoddist_name(v_coddist, '105') || ' ' end ||
                        case when v_codprovr is not null then get_label_name('HRCO2QE2', '105' , '110') || ' ' || get_tcodec_name('TCODPROV', v_codprovr, '105') end;
      ----------------------------------
      if global_v_lang = '101' then
        v_namcuste    := v_namcust;
        v_namste      := v_namst;
        v_buildinge   := v_building;
        v_roomnoe     := v_roomno;
        v_floore      := v_floor;
        v_villagee    := v_village;
        v_addrnoe     := v_addrno;
        v_mooe        := v_moo;
        v_soie        := v_soi;
        v_roade       := v_road;
        --v_adrcuste    := v_building || ' ' || v_roomno || ' ' || v_floor || ' ' ||  v_addrno || ' ' || v_moo || ' ' || v_soi || ' ' || v_road ;
      elsif global_v_lang = '102' then
        v_namcustt    := v_namcust;
        v_namstt      := v_namst;
        v_buildingt   := v_building;
        v_roomnot     := v_roomno;
        v_floort      := v_floor;
        v_villaget    := v_village;
        v_addrnot     := v_addrno;
        v_moot        := v_moo;
        v_soit        := v_soi;
        v_roadt       := v_road;
        --v_adrcustt    := get_label_name('HRCO2QE2', '102' , '30') || ' ' || v_building || ' ' || v_roomno || ' ' || v_floor || ' ' ||  v_addrno || ' ' || v_moo || ' ' || v_soi || ' ' || v_road ;
      elsif global_v_lang = '103' then
        v_namcust3    := v_namcust;
        v_namst3      := v_namst;
        v_building3   := v_building;
        v_roomno3     := v_roomno;
        v_floor3      := v_floor;
        v_village3    := v_village;
        v_addrno3     := v_addrno;
        v_moo3        := v_moo;
        v_soi3        := v_soi;
        v_road3       := v_road;
        --v_adrcust3    := v_building || ' ' || v_roomno || ' ' || v_floor || ' ' ||  v_addrno || ' ' || v_moo || ' ' || v_soi || ' ' || v_road ;
      elsif global_v_lang = '104' then
        v_namcust4    := v_namcust;
        v_namst4      := v_namst;
        v_building4   := v_building;
        v_roomno4     := v_roomno;
        v_floor4      := v_floor;
        v_village4    := v_village;
        v_addrno4    := v_addrno;
        v_moo4        := v_moo;
        v_soi4        := v_soi;
        v_road4       := v_road;
        --v_adrcust4    := v_building || ' ' || v_roomno || ' ' || v_floor || ' ' ||  v_addrno || ' ' || v_moo || ' ' || v_soi || ' ' || v_road ;
      elsif global_v_lang = '105' then
        v_namcust5    := v_namcust;
        v_namst5      := v_namst;
        v_building5   := v_building;
        v_roomno5     := v_roomno;
        v_floor5      := v_floor;
        v_village5    := v_village;
        v_addrno5     := v_addrno;
        v_moo5        := v_moo;
        v_soi5        := v_soi;
        v_road5       := v_road;
        --v_adrcust5    := v_building || ' ' || v_roomno || ' ' || v_floor || ' ' ||  v_addrno || ' ' || v_moo || ' ' || v_soi || ' ' || v_road ;
      end if;

      -- check exists
      if param_msg_error is null then
          begin
              select count(*)
                into v_count_chk
                from tcoddist
               where coddist = v_coddist
                 and codprov = v_codprovr;
          exception when others then
            v_count_chk := 0;
          end;

          if v_count_chk = 0 then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODDIST');
          end if;
      end if;

      if param_msg_error is null then
          begin
              select count(*)
                into v_count_chk
                from tsubdist
               where coddist = v_coddist
                 and codsubdist = v_codsubdist
                 and codprov = v_codprovr;
          exception when others then
            v_count_chk := 0;
          end;

          if v_count_chk = 0 then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TSUBDIST');
          end if;
      end if;

      if param_msg_error is null then
          begin
                insert into tcust
                  (codcust, namcuste, namcustt, namcust3, namcust4, namcust5, namste, namstt, namst3, namst4, namst5, adrcuste, adrcustt, adrcust3, adrcust4, adrcust5, buildinge, buildingt, building3, building4, building5, roomnoe, roomnot, roomno3, roomno4, roomno5, floore, floort, floor3, floor4, floor5, villagee, villaget, village3, village4, village5, addrnoe, addrnot, addrno3, addrno4, addrno5, mooe, moot, moo3, moo4, moo5, soie, soit, soi3, soi4, soi5, roade, roadt, road3, road4, road5, codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, codcreate, coduser)
                values
                  (v_codcust, v_namcuste, v_namcustt, v_namcust3, v_namcust4, v_namcust5, v_namste, v_namstt, v_namst3, v_namst4, v_namst5, v_adrcuste, v_adrcustt, v_adrcust3, v_adrcust4, v_adrcust5, v_buildinge, v_buildingt, v_building3, v_building4, v_building5, v_roomnoe, v_roomnot, v_roomno3, v_roomno4, v_roomno5, v_floore, v_floort, v_floor3, v_floor4, v_floor5, v_villagee, v_villaget, v_village3, v_village4, v_village5, v_addrnoe, v_addrnot, v_addrno3, v_addrno4, v_addrno5, v_mooe, v_moot, v_moo3, v_moo4, v_moo5, v_soie, v_soit, v_soi3, v_soi4, v_soi5, v_roade, v_roadt, v_road3, v_road4, v_road5, v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, sysdate, global_v_coduser, global_v_coduser );
          exception when DUP_VAL_ON_INDEX then
                update tcust
                   set codcust = v_codcust,
                       namcuste = v_namcuste,
                       namcustt = v_namcustt,
                       namcust3 = v_namcust3,
                       namcust4 = v_namcust4,
                       namcust5 = v_namcust5,
                       namste = v_namste,
                       namstt = v_namstt,
                       namst3 = v_namst3,
                       namst4 = v_namst4,
                       namst5 = v_namst5,
                       adrcuste = v_adrcuste,
                       adrcustt = v_adrcustt,
                       adrcust3 = v_adrcust3,
                       adrcust4 = v_adrcust4,
                       adrcust5 = v_adrcust5,
                       buildinge = v_buildinge,
                       buildingt = v_buildingt,
                       building3 = v_building3,
                       building4 = v_building4,
                       building5 = v_building5,
                       roomnoe = v_roomnoe,
                       roomnot = v_roomnot,
                       roomno3 = v_roomno3,
                       roomno4 = v_roomno4,
                       roomno5 = v_roomno5,
                       floore = v_floore,
                       floort = v_floort,
                       floor3 = v_floor3,
                       floor4 = v_floor4,
                       floor5 = v_floor5,
                       villagee = v_villagee,
                       villaget = v_villaget,
                       village3 = v_village3,
                       village4 = v_village4,
                       village5 = v_village5,
                       addrnoe = v_addrnoe,
                       addrnot = v_addrnot,
                       addrno3 = v_addrno3,
                       addrno4 = v_addrno4,
                       addrno5 = v_addrno5,
                       mooe = v_mooe,
                       moot = v_moot,
                       moo3 = v_moo3,
                       moo4 = v_moo4,
                       moo5 = v_moo5,
                       soie = v_soie,
                       soit = v_soit,
                       soi3 = v_soi3,
                       soi4 = v_soi4,
                       soi5 = v_soi5,
                       roade = v_roade,
                       roadt = v_roadt,
                       road3 = v_road3,
                       road4 = v_road4,
                       road5 = v_road5,
                       codsubdist = v_codsubdist,
                       coddist = v_coddist,
                       codprovr = v_codprovr,
                       zipcode = v_zipcode,
                       numtele = v_numtele,
                       numfax = v_numfax,
                       email = v_email,
                       website = v_website,
                       latitude = v_latitude,
                       longitude = v_longitude,
                       radius = v_radius,
                       radiuso = v_radiuso,
                       dteupd = sysdate ,
                       coduser = global_v_coduser
                 where codcust = v_codcust;
          end;
      end if;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        commit;
      else
        rollback;
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);

  end save_tcust ;
----------------------------------------------------------------------------------
  procedure get_tcust_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcust_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tcust_detail;
----------------------------------------------------------------------------------
  procedure gen_tcust_detail (json_str_output out clob) is
    obj_data               json_object_t;
    v_codcust     tcust.codcust%type;
    v_dteupd      tcust.dteupd%type;
    v_coduser     tcust.coduser%type;
    ----------------------------------
    v_namcust     tcust.namcuste%type;
    v_namcuste    tcust.namcuste%type;
    v_namcustt    tcust.namcustt%type;
    v_namcust3    tcust.namcust3%type;
    v_namcust4    tcust.namcust4%type;
    v_namcust5    tcust.namcust5%type;
    ----------------------------------
    v_namst       tcust.namste%type;
    v_namste      tcust.namste%type;
    v_namstt      tcust.namstt%type;
    v_namst3      tcust.namst3%type;
    v_namst4      tcust.namst4%type;
    v_namst5      tcust.namst5%type;
    ----------------------------------
    v_adrcust     tcust.adrcuste%type;
    v_adrcuste    tcust.adrcuste%type;
    v_adrcustt    tcust.adrcustt%type;
    v_adrcust3    tcust.adrcust3%type;
    v_adrcust4    tcust.adrcust4%type;
    v_adrcust5    tcust.adrcust5%type;
    ----------------------------------
    v_building    tcust.buildinge%type;
    v_buildinge   tcust.buildinge%type;
    v_buildingt   tcust.buildingt%type;
    v_building3   tcust.building3%type;
    v_building4   tcust.building4%type;
    v_building5   tcust.building5%type;
    ----------------------------------
    v_roomno      tcust.roomnoe%type;
    v_roomnoe     tcust.roomnoe%type;
    v_roomnot     tcust.roomnot%type;
    v_roomno3     tcust.roomno3%type;
    v_roomno4     tcust.roomno4%type;
    v_roomno5     tcust.roomno5%type;
    ----------------------------------
    v_floor       tcust.floore%type;
    v_floore      tcust.floore%type;
    v_floort      tcust.floort%type;
    v_floor3      tcust.floor3%type;
    v_floor4      tcust.floor4%type;
    v_floor5      tcust.floor5%type;
    ----------------------------------
    v_village     tcust.villagee%type;
    v_villagee    tcust.villagee%type;
    v_villaget    tcust.villaget%type;
    v_village3    tcust.village3%type;
    v_village4    tcust.village4%type;
    v_village5    tcust.village5%type;
    ----------------------------------
    v_addrno      tcust.addrnoe%type;
    v_addrnoe     tcust.addrnoe%type;
    v_addrnot     tcust.addrnot%type;
    v_addrno3     tcust.addrno3%type;
    v_addrno4     tcust.addrno4%type;
    v_addrno5     tcust.addrno5%type;
    ----------------------------------
    v_moo         tcust.mooe%type;
    v_mooe        tcust.mooe%type;
    v_moot        tcust.moot%type;
    v_moo3        tcust.moo3%type;
    v_moo4        tcust.moo4%type;
    v_moo5        tcust.moo5%type;
    ----------------------------------
    v_soi         tcust.soie%type;
    v_soie        tcust.soie%type;
    v_soit        tcust.soit%type;
    v_soi3        tcust.soi3%type;
    v_soi4        tcust.soi4%type;
    v_soi5        tcust.soi5%type;
    ----------------------------------
    v_road        tcust.roade%type;
    v_roade       tcust.roade%type;
    v_roadt       tcust.roadt%type;
    v_road3       tcust.road3%type;
    v_road4       tcust.road4%type;
    v_road5       tcust.road5%type;
    ----------------------------------
    v_codsubdist  tcust.codsubdist%type;
    v_coddist     tcust.coddist%type;
    v_codprovr    tcust.codprovr%type;
    v_zipcode     tcust.zipcode%type;
    v_numtele     tcust.numtele%type;
    v_numfax      tcust.numfax%type;
    v_email       tcust.email%type;
    v_website     tcust.website%type;
    v_latitude    tcust.latitude%type;
    v_longitude   tcust.longitude%type;
    v_radius      tcust.radius%type;
    v_radiuso     tcust.radiuso%type;
    ----------------------------------
  begin
    begin

      select codcust,
             decode(global_v_lang,'101', namcuste,
                                  '102', namcustt,
                                  '103', namcust3,
                                  '104', namcust4,
                                  '105', namcust5,
                                  namcuste) as namcust ,
             namcuste, namcustt, namcust3, namcust4, namcust5,
             decode(global_v_lang,'101', namste,
                                  '102', namstt,
                                  '103', namst3,
                                  '104', namst4,
                                  '105', namst5,
                                  namste) as namst ,
             namste, namstt, namst3, namst4, namst5,
             decode(global_v_lang,'101', adrcuste,
                                  '102', adrcustt,
                                  '103', adrcust3,
                                  '104', adrcust4,
                                  '105', adrcust5,
                                  adrcuste) as adrcust ,
             adrcuste, adrcustt, adrcust3, adrcust4, adrcust5,
             decode(global_v_lang,'101', buildinge,
                                  '102', buildingt,
                                  '103', building3,
                                  '104', building4,
                                  '105', building5,
                                  buildinge) as building ,
             buildinge, buildingt, building3, building4, building5,
             decode(global_v_lang,'101', roomnoe,
                                  '102', roomnot,
                                  '103', roomno3,
                                  '104', roomno4,
                                  '105', roomno5,
                                  roomnoe) as roomno ,
             roomnoe, roomnot, roomno3, roomno4, roomno5,
             decode(global_v_lang,'101', floore,
                                  '102', floort,
                                  '103', floor3,
                                  '104', floor4,
                                  '105', floor5,
                                  floore) as floor ,
             floore, floort, floor3, floor4, floor5,
             decode(global_v_lang,'101', villagee,
                                  '102', villaget,
                                  '103', village3,
                                  '104', village4,
                                  '105', village5,
                                  villagee) as village ,
             villagee, villaget, village3, village4, village5,
             decode(global_v_lang,'101', addrnoe,
                                  '102', addrnot,
                                  '103', addrno3,
                                  '104', addrno4,
                                  '105', addrno5,
                                  addrnoe) as addrno ,
             addrnoe, addrnot, addrno3, addrno4, addrno5,
             decode(global_v_lang,'101', mooe,
                                  '102', moot,
                                  '103', moo3,
                                  '104', moo4,
                                  '105', moo5,
                                  mooe) as moo ,
             mooe, moot, moo3, moo4, moo5,
             decode(global_v_lang,'101', soie,
                                  '102', soit,
                                  '103', soi3,
                                  '104', soi4,
                                  '105', soi5,
                                  soie) as soi ,
             soie, soit, soi3, soi4, soi5,
             decode(global_v_lang,'101', roade,
                                  '102', roadt,
                                  '103', road3,
                                  '104', road4,
                                  '105', road5,
                                  roade) as road ,
             roade, roadt, road3, road4, road5,
             codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, coduser
      into   v_codcust,
             v_namcust, v_namcuste, v_namcustt, v_namcust3, v_namcust4, v_namcust5,
             v_namst, v_namste, v_namstt, v_namst3, v_namst4, v_namst5,
             v_adrcust, v_adrcuste, v_adrcustt, v_adrcust3, v_adrcust4, v_adrcust5,
             v_building, v_buildinge, v_buildingt, v_building3, v_building4, v_building5,
             v_roomno, v_roomnoe, v_roomnot, v_roomno3, v_roomno4, v_roomno5,
             v_floor, v_floore, v_floort, v_floor3, v_floor4, v_floor5,
             v_village, v_villagee, v_villaget, v_village3, v_village4, v_village5,
             v_addrno, v_addrnoe, v_addrnot, v_addrno3, v_addrno4, v_addrno5,
             v_moo, v_mooe, v_moot, v_moo3, v_moo4, v_moo5,
             v_soi, v_soie, v_soit, v_soi3, v_soi4, v_soi5,
             v_road, v_roade, v_roadt, v_road3, v_road4, v_road5,
             v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, v_dteupd, v_coduser
      from tcust
      where codcust = p_codcust;

    exception when no_data_found then
      null;
    end;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcust', p_codcust);
    ------------------------------------
    obj_data.put('namcust', v_namcust);
    obj_data.put('namcuste', v_namcuste);
    obj_data.put('namcustt', v_namcustt);
    obj_data.put('namcust3', v_namcust3);
    obj_data.put('namcust4', v_namcust4);
    obj_data.put('namcust5', v_namcust5);
    ------------------------------------
    obj_data.put('namst', v_namst);
    obj_data.put('namste', v_namste);
    obj_data.put('namstt', v_namstt);
    obj_data.put('namst3', v_namst3);
    obj_data.put('namst4', v_namst4);
    obj_data.put('namst5', v_namst5);
    ------------------------------------
    obj_data.put('adrcust', v_adrcust);
    obj_data.put('adrcuste', v_adrcuste);
    obj_data.put('adrcustt', v_adrcustt);
    obj_data.put('adrcust3', v_adrcust3);
    obj_data.put('adrcust4', v_adrcust4);
    obj_data.put('adrcust5', v_adrcust5);
    ------------------------------------
    obj_data.put('building', v_building);
    obj_data.put('buildinge', v_buildinge);
    obj_data.put('buildingt', v_buildingt);
    obj_data.put('building3', v_building3);
    obj_data.put('building4', v_building4);
    obj_data.put('building5', v_building5);
    ------------------------------------
    obj_data.put('roomno', v_roomno);
    obj_data.put('roomnoe', v_roomnoe);
    obj_data.put('roomnot', v_roomnot);
    obj_data.put('roomno3', v_roomno3);
    obj_data.put('roomno4', v_roomno4);
    obj_data.put('roomno5', v_roomno5);
    ------------------------------------
    obj_data.put('floor', v_floor);
    obj_data.put('floore', v_floore);
    obj_data.put('floort', v_floort);
    obj_data.put('floor3', v_floor3);
    obj_data.put('floor4', v_floor4);
    obj_data.put('floor5', v_floor5);
    ------------------------------------
    obj_data.put('village', v_village);
    obj_data.put('villagee', v_villagee);
    obj_data.put('villaget', v_villaget);
    obj_data.put('village3', v_village3);
    obj_data.put('village4', v_village4);
    obj_data.put('village5', v_village5);
    ------------------------------------
    obj_data.put('addrno', v_addrno);
    obj_data.put('addrnoe', v_addrnoe);
    obj_data.put('addrnot', v_addrnot);
    obj_data.put('addrno3', v_addrno3);
    obj_data.put('addrno4', v_addrno4);
    obj_data.put('addrno5', v_addrno5);
    ------------------------------------
    obj_data.put('moo', v_moo);
    obj_data.put('mooe', v_mooe);
    obj_data.put('moot', v_moot);
    obj_data.put('moo3', v_moo3);
    obj_data.put('moo4', v_moo4);
    obj_data.put('moo5', v_moo5);
    ------------------------------------
    obj_data.put('soi', v_soi);
    obj_data.put('soie', v_soie);
    obj_data.put('soit', v_soit);
    obj_data.put('soi3', v_soi3);
    obj_data.put('soi4', v_soi4);
    obj_data.put('soi5', v_soi5);
    ------------------------------------
    obj_data.put('road', v_road);
    obj_data.put('roade', v_roade);
    obj_data.put('roadt', v_roadt);
    obj_data.put('road3', v_road3);
    obj_data.put('road4', v_road4);
    obj_data.put('road5', v_road5);
    ------------------------------------
    obj_data.put('codsubdist', v_codsubdist);
    obj_data.put('coddist', v_coddist);
    obj_data.put('codprovr', v_codprovr);
    obj_data.put('zipcode', v_zipcode);
    obj_data.put('numtele', v_numtele);
    obj_data.put('numfax', v_numfax);
    obj_data.put('email', v_email);
    obj_data.put('website', v_website);
    obj_data.put('latitude', v_latitude);
    obj_data.put('longitude', v_longitude);
    obj_data.put('radius', v_radius);
    obj_data.put('radiuso', v_radiuso);
    obj_data.put('dteupd', to_char(v_dteupd, 'dd/mm/yyyy'));
    obj_data.put('coduser', v_coduser);
    obj_data.put('codempid', get_codempid(v_coduser));
    obj_data.put('temploy_name', get_codempid(v_coduser)|| ' - ' ||get_temploy_name(get_codempid(v_coduser), global_v_lang));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tcust_detail;
----------------------------------------------------------------------------------
  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_codcust           tcust.codcust%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codcust          := hcm_util.get_string_t(json_row, 'codcust');
        if v_flg = 'delete' then
           begin
                 delete from tcust
                 where codcust = v_codcust;
           end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;
----------------------------------------------------------------------------------
   procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_rec_tran      number;
    v_rec_err       number;
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
      if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return ;
      end if ;
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));

    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i) + 1);
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);
    --
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_import_process;
----------------------------------------------------------------------------------
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    json_obj_list   json_list;
    --
    linebuf       varchar2(6000 char);
    data_file     varchar2(6000 char);
    v_column      number := 22;
    v_error       boolean;
    v_err_code    varchar2(1000 char);
    v_err_filed   varchar2(1000 char);
    v_err_table   varchar2(20 char);
    i             number;
    j             number;
    v_numseq      number := 0;
    -------------------------------------------
    v_codcust     varchar2(1000 char); --tcust.codcust%type;
    v_namcust     varchar2(1000 char); --tcust.namcuste%type;
    v_namst       varchar2(1000 char); --tcust.namste%type;
    v_adrcust     varchar2(1000 char); --tcust.adrcuste%type;
    v_building    varchar2(1000 char); --tcust.buildinge%type;
    v_roomno      varchar2(1000 char); --tcust.roomnoe%type;
    v_floor       varchar2(1000 char); --tcust.floore%type;
    v_village     varchar2(1000 char); --tcust.villagee%type;
    v_addrno      varchar2(1000 char); --tcust.addrnoe%type;
    v_moo         varchar2(1000 char); --tcust.mooe%type;
    v_soi         varchar2(1000 char); --tcust.soie%type;
    v_road        varchar2(1000 char); --tcust.roade%type;
    v_codsubdist  varchar2(1000 char); --tcust.codsubdist%type;
    v_coddist     varchar2(1000 char); --tcust.coddist%type;
    v_codprovr    varchar2(1000 char); --tcust.codprovr%type;
    v_zipcode     varchar2(1000 char); --tcust.zipcode%type;
    v_numtele     varchar2(1000 char); --tcust.numtele%type;
    v_numfax      varchar2(1000 char); --tcust.numfax%type;
    v_email       varchar2(1000 char); --tcust.email%type;
    v_website     varchar2(1000 char); --tcust.website%type;
    v_latitude    varchar2(1000 char); --tcust.latitude%type;
    v_longitude   varchar2(1000 char); --tcust.longitude%type;
    v_radius      varchar2(1000 char); --tcust.radius%type;
    v_radiuso     varchar2(1000 char); --tcust.radiuso%type;
    -------------------------------------------
    v_cnt_codsubdist   number := 0 ; v_cnt_coddist   number := 0 ; v_cnt_codprov   number := 0;
    v_cnt         number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_text   text;
      v_filed  text;
    type arr_int is table of integer index by binary_integer;
      v_text_len arr_int ;

  begin

    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
--        json_obj_list   := param_json_row.get_values;

    begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        linebuf     := i;
        v_numseq    := v_numseq;
        v_error 	  := false;

        --------------------------------------
        if  param_json_row.get_size() != 22 then
          param_msg_error := get_error_msg_php('CO0033',global_v_lang);
          return ;
        end if ;
        v_codcust     := hcm_util.get_string_t(param_json_row,'codcust'); -- 1
        v_namcust     := hcm_util.get_string_t(param_json_row,'namcust'); -- 2
        v_namst       := hcm_util.get_string_t(param_json_row,'namst'); -- 3
        v_building    := hcm_util.get_string_t(param_json_row,'building'); -- 4
        v_roomno      := hcm_util.get_string_t(param_json_row,'roomno'); -- 5
        v_floor       := hcm_util.get_string_t(param_json_row,'floor'); -- 6
        v_village     := hcm_util.get_string_t(param_json_row,'village'); -- 7
        v_addrno      := hcm_util.get_string_t(param_json_row,'addrno'); -- 8
        v_moo         := hcm_util.get_string_t(param_json_row,'moo'); -- 9
        v_soi         := hcm_util.get_string_t(param_json_row,'soi'); -- 10
        v_road        := hcm_util.get_string_t(param_json_row,'road'); -- 11
        v_codsubdist  := hcm_util.get_string_t(param_json_row,'codsubdist'); -- 12
        v_coddist     := hcm_util.get_string_t(param_json_row,'coddist'); -- 13
        v_codprovr    := hcm_util.get_string_t(param_json_row,'codprovr'); -- 14
        v_zipcode     := hcm_util.get_string_t(param_json_row,'zipcode'); -- 15
        v_numtele     := hcm_util.get_string_t(param_json_row,'numtele'); -- 16
        v_numfax      := hcm_util.get_string_t(param_json_row,'numfax'); -- 17
        v_email       := hcm_util.get_string_t(param_json_row,'email'); -- 18
        v_website     := hcm_util.get_string_t(param_json_row,'website'); -- 19
        v_latitude    := hcm_util.get_string_t(param_json_row,'latitude'); -- 20
        v_longitude   := hcm_util.get_string_t(param_json_row,'longitude'); -- 21
        v_radius      := hcm_util.get_string_t(param_json_row,'radius'); --22
        v_radiuso     := hcm_util.get_string_t(param_json_row,'radiuso'); --23

        v_text(1)   := v_codcust;    v_text(2)   := v_namcust;   v_text(3)   := v_namst;
        v_text(4)   := v_building;   v_text(5)   := v_roomno ;   v_text(6)   := v_floor ;
        v_text(7)   := v_village;    v_text(8)   := v_addrno;    v_text(9)   := v_moo;
        v_text(10)  := v_soi;        v_text(11)  := v_road;      v_text(12)  := v_codsubdist;
        v_text(13)  := v_coddist; v_text(14)  := v_codprovr;  v_text(15)  := v_zipcode;
        v_text(16)  := v_numtele;    v_text(17)  := v_numfax ;   v_text(18)  := v_email;
        v_text(19)  := v_website;    v_text(20)  := v_latitude;  v_text(21)  := v_longitude;
        v_text(22)  := v_radius;     v_text(23)  := v_radius;

        v_filed(1)  := 'codcust';    v_filed(2)  := 'namcust';   v_filed(3)  := 'namst';
        v_filed(4)  := 'building';   v_filed(5)  := 'roomno';    v_filed(6)  := 'floor';
        v_filed(7)  := 'village';    v_filed(8)  := 'addrno';    v_filed(9)  := 'moo';
        v_filed(10) := 'soi';        v_filed(11) := 'road';      v_filed(12) := 'codsubdist';
        v_filed(13) := 'coddist';    v_filed(14) := 'codprovr';  v_filed(15) := 'zipcode';
        v_filed(16) := 'numtele';    v_filed(17) := 'numfax';    v_filed(18) := 'email';
        v_filed(19) := 'website';    v_filed(20) := 'latitude';  v_filed(21) := 'longitude';
        v_filed(22) := 'radius';     v_filed(23) := 'radiuso';

        v_text_len(1)  := 10;        v_text_len(2)  := 100;     v_text_len(3)  := 10;
        v_text_len(4)  := 100;       v_text_len(5)  := 10;      v_text_len(6)  := 3;
        v_text_len(7)  := 100;       v_text_len(8)  := 60;      v_text_len(9)  := 10;
        v_text_len(10) := 100;       v_text_len(11) := 100;     v_text_len(12) := 4;
        v_text_len(13) := 4;         v_text_len(14) := 4;       v_text_len(15) := 5;
        v_text_len(16) := 30;        v_text_len(17) := 20;      v_text_len(18) := 50;
        v_text_len(19) := 50;        v_text_len(20) := 50;      v_text_len(21) := 50;
        v_text_len(22) := 50;        v_text_len(23) := 50;
        data_file := null;
        ------------------------------------------------
        for j in 1..22 loop
            ------------------------------------------------
            if data_file is null then
                data_file := v_text(j);
              else
                data_file := data_file||','||v_text(j);
            end if;
            ------------------------------------------------
            if nvl(length(v_text(j)),0) > v_text_len(j) then
               v_error	 	 := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(j) ;
               continue ;
            end if ;
            ------------------------------------------------    3
            if not v_error then
              if j in (1,2,8,12,13,14,20,21,22,23) then
                if v_text(j) is null then
                   v_error	 	 := true;
                   v_err_code  := 'HR2045';
                   v_err_filed := v_filed(j) ;
                end if ;
              end if ;
            end if ;
            ------------------------------------------------
        end loop;
        --------------------------------------------------------
        if not v_error then
          --------------------------------------------------------
          select ( select count('x')
                   from   tsubdist t
                   where  t.codsubdist = v_codsubdist ) ,
                 ( select count('x')
                   from   tcoddist t
                   where  t.coddist = v_coddist ) ,
                 ( select count('x')
                   from   tcodprov t
                   where  t.codcodec = v_codprovr )
          into   v_cnt_codsubdist , v_cnt_coddist , v_cnt_codprov
          from   dual ;
          --------------------------------------------------------
            if v_cnt_codsubdist != 1 then
              v_error	 	 := true;
              v_err_code  := 'HR2010';
              v_err_filed := 'codsubdist' ;
            elsif v_cnt_coddist != 1 then
              v_error	 	 := true;
              v_err_code  := 'HR2010';
              v_err_filed := 'coddist' ;
            elsif v_cnt_codprov != 1 then
              v_error	 	 := true;
              v_err_code  := 'HR2010';
              v_err_filed := 'codprovr' ;
            end if ;
          --------------------------------------------------------
        end if ;
        --------------------------------------------------------
        if not v_error then
            v_rec_tran := v_rec_tran + 1;
            v_adrcust := get_label_name('HRCO2QE2', global_v_lang , '30') || ' ' || v_building || ' ' || get_label_name('HRCO2QE2', global_v_lang , '40') || ' ' || v_roomno || ' ' || get_label_name('HRCO2QE2', global_v_lang , '50') || ' ' || v_floor || ' ' || get_label_name('HRCO2QE2', global_v_lang , '60') || ' ' || v_village || ' ' ||
                      get_label_name('HRCO2QE2', global_v_lang , '70') || ' ' || v_addrno || ' ' || get_label_name('HRCO2QE2', global_v_lang , '80') || ' ' || v_moo || ' ' ||
                      get_label_name('HRCO2QE2', global_v_lang , '90') || ' ' || v_soi || ' ' || get_label_name('HRCO2QE2', global_v_lang , '100') || ' ' || v_road || ' ' ||
                      get_label_name('HRCO2QE2', global_v_lang , '130') || ' ' || get_tsubdist_name(v_codsubdist, global_v_lang) || ' ' ||
                      get_label_name('HRCO2QE2', global_v_lang , '120') || ' ' || get_tcoddist_name(v_coddist, global_v_lang) || ' ' || get_label_name('HRCO2QE2', global_v_lang , '110') || ' ' || get_tcodec_name('TCODPROV', v_codprovr, global_v_lang) ;
            ----------------------------------------------
            if global_v_lang = '101' then
              --------------------------------------------
              begin
                insert into tcust
                  (codcust, namcuste, namste, adrcuste, buildinge, roomnoe, floore, villagee, addrnoe, mooe, soie, roade, codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, codcreate, coduser, flgact)
                values
                  (v_codcust, v_namcust, v_namst, v_adrcust, v_building, v_roomno, v_floor, v_village, v_addrno, v_moo, v_soi, v_road, v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, sysdate, global_v_coduser, global_v_coduser, '1' );
              exception when DUP_VAL_ON_INDEX then
                update tcust
                   set codcust = upper(v_codcust), namcuste = v_namcust, namste = v_namst, adrcuste = v_adrcust, buildinge = v_building,
                       roomnoe = v_roomno, floore = v_floor, villagee = v_village, addrnoe = v_addrno, mooe = v_moo,
                       soie = v_soi, roade = v_road, codsubdist = v_codsubdist, coddist = v_coddist, codprovr = v_codprovr,
                       zipcode = v_zipcode, numtele = v_numtele, numfax = v_numfax, email = v_email, website = v_website,
                       latitude = v_latitude, longitude = v_longitude, radius = v_radius, radiuso = v_radiuso, dteupd = sysdate , coduser = global_v_coduser
                 where codcust = upper(v_codcust);
              end ;
              --------------------------------------------
            elsif global_v_lang = '102' then
              --------------------------------------------
             begin
                insert into tcust
                  (codcust, namcustt, namstt, adrcustt, buildingt, roomnot, floort, villaget, addrnot, moot, soit, roadt, codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, codcreate, coduser, flgact)
                values
                  (v_codcust, v_namcust, v_namst, v_adrcust, v_building, v_roomno, v_floor, v_village, v_addrno, v_moo, v_soi, v_road, v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, sysdate, global_v_coduser, global_v_coduser, '1' );
              exception when DUP_VAL_ON_INDEX then
                update tcust
                   set codcust = upper(v_codcust), namcustt = v_namcust, namstt = v_namst, adrcustt = v_adrcust, buildingt = v_building,
                       roomnot = v_roomno, floort = v_floor, villaget = v_village, addrnot = v_addrno, moot = v_moo,
                       soit = v_soi, roadt = v_road, codsubdist = v_codsubdist, coddist = v_coddist, codprovr = v_codprovr,
                       zipcode = v_zipcode, numtele = v_numtele, numfax = v_numfax, email = v_email, website = v_website,
                       latitude = v_latitude, longitude = v_longitude, radius = v_radius, radiuso = v_radiuso, dteupd = sysdate , coduser = global_v_coduser
                 where codcust = upper(v_codcust);
              end ;
              --------------------------------------------
            elsif global_v_lang = '103' then
              --------------------------------------------
              begin
                insert into tcust
                  (codcust, namcust3, namst3, adrcust3, building3, roomno3, floor3, village3, addrno3, moo3, soi3, road3, codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, codcreate, coduser, flgact)
                values
                  (v_codcust, v_namcust, v_namst, v_adrcust, v_building, v_roomno, v_floor, v_village, v_addrno, v_moo, v_soi, v_road, v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, sysdate, global_v_coduser, global_v_coduser, '1' );
              exception when DUP_VAL_ON_INDEX then
                update tcust
                   set codcust = upper(v_codcust), namcust3 = v_namcust, namst3 = v_namst, adrcust3 = v_adrcust, building3 = v_building,
                       roomno3 = v_roomno, floor3 = v_floor, village3 = v_village, addrno3 = v_addrno, moo3 = v_moo,
                       soi3 = v_soi, road3 = v_road, codsubdist = v_codsubdist, coddist = v_coddist, codprovr = v_codprovr,
                       zipcode = v_zipcode, numtele = v_numtele, numfax = v_numfax, email = v_email, website = v_website,
                       latitude = v_latitude, longitude = v_longitude, radius = v_radius, radiuso = v_radiuso, dteupd = sysdate , coduser = global_v_coduser
                 where codcust = upper(v_codcust);
              end ;
              --------------------------------------------
            elsif global_v_lang = '104' then
              --------------------------------------------
              begin
                insert into tcust
                  (codcust, namcust4, namst4, adrcust4, building4, roomno4, floor4, village4, addrno4, moo4, soi4, road4, codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, codcreate, coduser, flgact)
                values
                  (v_codcust, v_namcust, v_namst, v_adrcust, v_building, v_roomno, v_floor, v_village, v_addrno, v_moo, v_soi, v_road, v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, sysdate, global_v_coduser, global_v_coduser, '1' );
              exception when DUP_VAL_ON_INDEX then
                update tcust
                   set codcust = upper(v_codcust), namcust4 = v_namcust, namst4 = v_namst, adrcust4 = v_adrcust, building4 = v_building,
                       roomno4 = v_roomno, floor4 = v_floor, village4 = v_village, addrno4 = v_addrno, moo4 = v_moo,
                       soi4 = v_soi, road4 = v_road, codsubdist = v_codsubdist, coddist = v_coddist, codprovr = v_codprovr,
                       zipcode = v_zipcode, numtele = v_numtele, numfax = v_numfax, email = v_email, website = v_website,
                       latitude = v_latitude, longitude = v_longitude, radius = v_radius, radiuso = v_radiuso, dteupd = sysdate , coduser = global_v_coduser
                 where codcust = upper(v_codcust);
              end ;
              --------------------------------------------
            elsif global_v_lang = '105' then
              --------------------------------------------
              begin
                insert into tcust
                  (codcust, namcust5, namst5, adrcust5, building5, roomno5, floor5, village5, addrno5, moo5, soi5, road5, codsubdist, coddist, codprovr, zipcode, numtele, numfax, email, website, latitude, longitude, radius, radiuso, dteupd, codcreate, coduser, flgact)
                values
                  (v_codcust, v_namcust, v_namst, v_adrcust, v_building, v_roomno, v_floor, v_village, v_addrno, v_moo, v_soi, v_road, v_codsubdist, v_coddist, v_codprovr, v_zipcode, v_numtele, v_numfax, v_email, v_website, v_latitude, v_longitude, v_radius, v_radiuso, sysdate, global_v_coduser, global_v_coduser, '1' );
              exception when DUP_VAL_ON_INDEX then
                update tcust
                   set codcust = upper(v_codcust), namcust5 = v_namcust, namst5 = v_namst, adrcust5 = v_adrcust, building5 = v_building,
                       roomno5 = v_roomno, floor5 = v_floor, village5 = v_village, addrno5 = v_addrno, moo5 = v_moo,
                       soi5 = v_soi, road5 = v_road, codsubdist = v_codsubdist, coddist = v_coddist, codprovr = v_codprovr,
                       zipcode = v_zipcode, numtele = v_numtele, numfax = v_numfax, email = v_email, website = v_website,
                       latitude = v_latitude, longitude = v_longitude, radius = v_radius, radiuso = v_radiuso, dteupd = sysdate , coduser = global_v_coduser
                 where codcust = upper(v_codcust);
              end ;
              --------------------------------------------
            end if;
            ----------------------------------------------
            commit;
        else
            v_rec_error     := v_rec_error + 1;
            v_cnt           := v_cnt+1;
            p_text(v_cnt)       := data_file;
            p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang),'@#$%400',null)||'['||v_err_filed||']';
            p_numseq(v_cnt)     := i;
        end if ;
        ----------------------
    end ;
    end loop ;
  end format_text_json ;

end HRCO2QE;

/
