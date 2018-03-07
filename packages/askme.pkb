create or replace package body askme
as
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
    invalid_request_type exception;
    invalid_intent exception;
  begin
    apex_json.parse(p_values => l_payload, p_source => alexa.blob2clob(p_payload));

    if not alexa.is_request_valid(
      p_input_skill_id => alexa.get_amazon_skill_id(l_payload)
      , p_amazon_skill_id => askme.gc_amazon_skill_id
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
            , ssml => '<speak>Oracle Machine is ready. Ask me to say hello, or tell me your name.</speak>'
          )
          , p_reprompt => t_alexa_output_speech(
              output_speech_type => alexa.gc_ssml_speech_type
              , text => null
              , ssml => '<speak>Ask me to say hello, or tell me your name.</speak>'
            )
        );
      when l_request_type = alexa.gc_intent_request then
        l_intent := alexa.get_intent(l_payload);
        case
          when l_intent = 'HelloWorldIntent' then
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
            l_response := alexa.generate_response(
              p_output_speech => t_alexa_output_speech(
                output_speech_type => alexa.gc_plaintext_speech_type
                , text => 'Hello ' || coalesce(l_name, 'Anonymous') || '. I am the Oracle.'
                , ssml => null
              )
              , p_end_session => true
            );
          when l_intent in (alexa.gc_help_intent) then
            l_response := alexa.generate_response(
              p_output_speech => t_alexa_output_speech(
                output_speech_type => alexa.gc_plaintext_speech_type
                , text => 'Ask me to say hello, or tell me your name.'
                , ssml => null
              )
              , p_end_session => false
            );
          when l_intent in (alexa.gc_cancel_intent, alexa.gc_stop_intent) then
            l_response := alexa.generate_response(
              p_output_speech => t_alexa_output_speech(
                output_speech_type => alexa.gc_plaintext_speech_type
                , text => 'Goodbye!'
                , ssml => null
              )
              , p_end_session => true
            );
          else
            raise invalid_intent;
        end case;
      when l_request_type = alexa.gc_session_ended_request then
        l_response := alexa.generate_response(p_end_session => true);
      else
        raise invalid_request_type;
    end case;

    p_status_code := alexa.gc_status_ok;
    p_response := l_response;
  exception
    when invalid_skill then
      p_status_code := alexa.gc_status_unauthorized;
      p_message := 'Skill validation failed';
    when invalid_request_type then
      p_status_code := alexa.gc_status_bad_request;
      p_message := 'Invalid request type: ' || l_request_type;
    when invalid_intent then
      p_status_code := alexa.gc_status_bad_request;
      p_message := 'Invalid intent: ' || l_intent;
    when others then
      p_status_code := alexa.gc_status_error;
      p_message := dbms_utility.format_error_backtrace;
  end process_request;
end askme;
/