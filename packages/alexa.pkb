create or replace package body alexa
as
  /**
   * Converts blob to clob
   *
   * Notes:
   *  - Copied from http://stackoverflow.com/questions/12849025/convert-blob-to-clob
   *  - From OOS_UTIL_LOB
   *
   * @issue #1
   *
   * declare
   *   l_blob blob;
   *   l_clob clob;
   * begin
   *   l_clob := oos_util_lob.blob2clob(l_blob);
   * end;
   *
   * @author Martin D'Souza
   * @created 02-Mar-2014
   * @param p_blob blob to be converted to clob
   * @param p_blob_csid Encoding to use. See https://docs.oracle.com/database/121/NLSPG/ch2charset.htm#NLSPG169 (table 2-4) for different charsets. Can use `nls_charset_id(<charset>)` to get the clob_csid
   * @return clob
   */
  function blob2clob(
    p_blob in blob,
    p_blob_csid in integer default dbms_lob.default_csid)
    return clob
  as
    l_clob clob;
    l_dest_offset integer := 1;
    l_src_offset integer := 1;
    l_lang_context integer := dbms_lob.default_lang_ctx;
    l_warning integer;
  begin
    if p_blob is null then
      return null;
    end if;

    dbms_lob.createtemporary(
      lob_loc => l_clob,
      cache => false);

    dbms_lob.converttoclob(
      dest_lob => l_clob,
      src_blob => p_blob,
      amount => dbms_lob.lobmaxsize,
      dest_offset => l_dest_offset,
      src_offset => l_src_offset,
      blob_csid => p_blob_csid,
      lang_context => l_lang_context,
      warning => l_warning);

    return l_clob;
  end blob2clob;

  function is_request_valid(
    p_amazon_skill_id varchar2
  ) return boolean
  as
    l_result boolean;
  begin
    l_result := p_amazon_skill_id = askme.gc_amazon_skill_id;
    return l_result;
  end is_request_valid;

  function get_amazon_skill_id(
    p_payload apex_json.t_values
  ) return varchar2
  as
  begin
    return apex_json.get_varchar2(
      p_path => 'session.application.applicationId'
      , p_values => p_payload
    );
  end get_amazon_skill_id;

  function get_request_type(
    p_payload apex_json.t_values
  ) return varchar2
  as
  begin
    return apex_json.get_varchar2(
      p_path => 'request.type'
      , p_values => p_payload
    );
  end get_request_type;

  function get_intent(
    p_payload apex_json.t_values
  ) return varchar2
  as
  begin
    return apex_json.get_varchar2(
      p_path => 'request.intent.name'
      , p_values => p_payload
    );
  end get_intent;

  function generate_response(
    p_output_speech in t_alexa_output_speech
    , p_reprompt in t_alexa_output_speech default null
    , p_card in t_alexa_card default null
    , p_end_session in boolean default false
  ) return clob
  as
    l_response clob;

    input_error exception;
    not_implemented exception;
  begin
    apex_json.initialize_clob_output;

    apex_json.open_object;

    apex_json.write(
      p_name => 'version'
      , p_value => '1.0'
    );

    apex_json.open_object(
      p_name => 'sessionAttributes'
    );
    apex_json.close_object;

    apex_json.open_object(
      p_name => 'response'
    );

    -- outputSpeech
    if p_output_speech is not null then
      apex_json.open_object(
        p_name => 'outputSpeech'
      );

      if p_output_speech.output_speech_type = alexa.gc_plaintext_speech_type then
        apex_json.write(
          p_name => 'type'
          , p_value => alexa.gc_plaintext_speech_type
        );

        apex_json.write(
          p_name => 'text'
          , p_value => p_output_speech.text
        );
      elsif p_output_speech.output_speech_type = alexa.gc_ssml_speech_type then
        apex_json.write(
          p_name => 'type'
          , p_value => alexa.gc_ssml_speech_type
        );

        apex_json.write(
          p_name => 'ssml'
          , p_value => p_output_speech.ssml
        );
      else
        raise not_implemented;
      end if;

      -- apex_json.write(
      --   p_name => 'ssml'
      --   , p_value => replace('<speak>#TEXT#</speak>', '#TEXT#', p_text)
      -- );
    else
      raise input_error;
    end if;

    apex_json.close_object;
    -- outputSpeech - END

    -- reprompt
    if p_reprompt is not null then
      raise not_implemented;
    end if;
    -- reprompt - END

    -- card
    if p_card is not null then
      raise not_implemented;
    end if;
    -- card - END

    apex_json.write(
      p_name => 'shouldEndSession'
      , p_value => p_end_session
    );

    apex_json.close_object;

    apex_json.close_object;

    l_response := apex_json.get_clob_output;

    apex_json.free_output;

    return l_response;
  end;
end alexa;
/