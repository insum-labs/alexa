create or replace package body askme
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

  --
  function generate_response(
    p_text in varchar2
    , p_end_session in boolean default false
  ) return clob
  as
    l_response clob;
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

    apex_json.open_object(
      p_name => 'outputSpeech'
    );

    apex_json.write(
      p_name => 'type'
      , p_value => 'PlainText'
    );

    apex_json.write(
      p_name => 'text'
      , p_value => p_text
    );

    apex_json.write(
      p_name => 'ssml'
      , p_value => replace('<speak>#TEXT#</speak>', '#TEXT#', p_text)
    );

    apex_json.close_object;

    apex_json.write(
      p_name => 'shouldEndSession'
      , p_value => p_end_session
    );

    apex_json.close_object;

    apex_json.close_object;

    l_response := apex_json.get_clob_output;

    apex_json.free_output;

    return l_response;
  end generate_response;

  procedure process_request(
    p_payload in blob
    , p_status_code out number
    , p_message out nocopy varchar2
    , p_response out nocopy clob
  )
  as
    l_payload apex_json.t_values;
    l_request_type varchar2(30);
    l_intent varchar2(30);
    l_name varchar2(50);
    l_response clob;

    invalid_skill exception;
  begin
    apex_json.parse(p_values => l_payload, p_source => blob2clob(p_payload));

    if not is_request_valid(
      p_amazon_skill_id => apex_json.get_varchar2(
        p_path => 'session.application.applicationId'
      , p_values => l_payload
      )
    ) then
      raise invalid_skill;
    end if;

    l_request_type := apex_json.get_varchar2(
      p_path => 'request.type'
      , p_values => l_payload
    );

    case
      when l_request_type = 'LaunchRequest' then
        l_response := generate_response('Launched Oracle Machine');
      when l_request_type = 'IntentRequest' then
        l_intent := apex_json.get_varchar2(
          p_path => 'request.intent.name'
          , p_values => l_payload
        );
        case
          when l_intent = 'HelloWorldIntent' then
            l_response := generate_response('Hello from APEX!', true);
          when l_intent = 'MyNameIsIntent' then
            l_name := apex_json.get_varchar2(
              p_path => 'request.intent.slots.name.value'
              , p_values => l_payload
            );
            l_response := generate_response('Hello ' || coalesce(l_name, 'Anonymous') || '. I am the Oracle.', true);
          when l_intent in ('AMAZON.HelpIntent') then
            l_response := generate_response('Ask me to say hello, or tell me your name.');
          when l_intent in ('AMAZON.CancelIntent', 'AMAZON.StopIntent') then
            l_response := generate_response('Goodbye!');
          else
            l_response := generate_response('Invalid intent: ' || l_intent);
        end case;
      else
        l_response := generate_response('Invalid request type: ' || l_request_type);
    end case;

    p_status_code := askme.gc_status_ok;
    p_response := l_response;
  exception
    when invalid_skill then
      p_status_code := askme.gc_status_unauthorized;
      p_message := 'Skill validation failed';
    when others then
      p_status_code := askme.gc_status_error;
      p_message := 'General error';
  end process_request;
end askme;
/