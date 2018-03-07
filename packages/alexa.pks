create or replace package alexa
as
  gc_status_ok constant number(3) := 200;
  gc_status_bad_request constant number(3) := 400;
  gc_status_unauthorized constant number(3) := 403;
  gc_status_error constant number(3) := 500;

  gc_launch_request constant varchar2(13) := 'LaunchRequest';
  gc_intent_request constant varchar2(13) := 'IntentRequest';
  gc_session_ended_request constant varchar2(19) := 'SessionEndedRequest';

  gc_cancel_intent constant varchar2(19) := 'AMAZON.CancelIntent';
  gc_stop_intent constant varchar2(17) := 'AMAZON.StopIntent';
  gc_help_intent constant varchar2(17) := 'AMAZON.HelpIntent';

  gc_plaintext_speech_type constant varchar2(9) := 'PlainText';
  gc_ssml_speech_type constant varchar2(4) := 'SSML';

  gc_simple_card_type constant varchar2(6) := 'Simple';
  gc_standard_card_type constant varchar2(8) := 'Standard';
  gc_linkaccount_card_type constant varchar2(11) := 'LinkAccount';

  function blob2clob(
    p_blob in blob
    , p_blob_csid in integer default dbms_lob.default_csid
  ) return clob;

  function is_request_valid(
    p_input_skill_id varchar2
    , p_amazon_skill_id varchar2
  ) return boolean;

  function get_amazon_skill_id(
    p_payload apex_json.t_values
  ) return varchar2;

  function get_request_type(
    p_payload apex_json.t_values
  ) return varchar2;

  function get_intent(
    p_payload apex_json.t_values
  ) return varchar2;

  function generate_response(
    p_output_speech in t_alexa_output_speech default null
    , p_reprompt in t_alexa_output_speech default null
    , p_card in t_alexa_card default null
    , p_end_session in boolean default false
  ) return clob;
end alexa;
/