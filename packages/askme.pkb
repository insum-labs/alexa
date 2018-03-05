create or replace package body askme
as
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
    apex_json.parse(p_values => l_payload, p_source => alexa.blob2clob(p_payload));

    if not alexa.is_request_valid(
      p_amazon_skill_id => alexa.get_amazon_skill_id(l_payload)
    ) then
      raise invalid_skill;
    end if;

    l_request_type := alexa.get_request_type(l_payload);

    case
      when l_request_type = alexa.gc_launch_request then
        l_response := alexa.generate_response(
          p_output_speech => t_alexa_output_speech(
            output_speech_type => alexa.gc_ssml_speech_type
            , text => null
            , ssml => '<speak>Launched Oracle Machine</speak>'
          )
        );
      when l_request_type = alexa.gc_intent_request then
        l_intent := alexa.get_intent(l_payload);
        case
          when l_intent = 'HelloWorldIntent' then
            -- l_response := generate_response('Hello from APEX!', true);
            l_response := alexa.generate_response(
              p_output_speech => t_alexa_output_speech(
                output_speech_type => alexa.gc_plaintext_speech_type
                , text => 'Hello from APEX!'
                , ssml => null
              )
              , p_end_session => true
            );
          when l_intent = 'MyNameIsIntent' then
            l_name := apex_json.get_varchar2(
              p_path => 'request.intent.slots.name.value'
              , p_values => l_payload
            );
            l_response := generate_response('Hello ' || coalesce(l_name, 'Anonymous') || '. I am the Oracle.', true);
          when l_intent in (alexa.gc_help_intent) then
            l_response := generate_response('Ask me to say hello, or tell me your name.');
          when l_intent in (alexa.gc_cancel_intent, alexa.gc_stop_intent) then
            l_response := generate_response('Goodbye!');
          else
            l_response := generate_response('Invalid intent: ' || l_intent);
        end case;
      else
        l_response := generate_response('Invalid request type: ' || l_request_type);
    end case;

    p_status_code := alexa.gc_status_ok;
    p_response := l_response;
  exception
    when invalid_skill then
      p_status_code := alexa.gc_status_unauthorized;
      p_message := 'Skill validation failed';
    when others then
      p_status_code := alexa.gc_status_error;
      p_message := dbms_utility.format_error_backtrace;
  end process_request;
end askme;
/