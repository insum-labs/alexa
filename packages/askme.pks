create or replace package askme
as
  gc_amazon_skill_id varchar2(255) := 'amzn1.ask.skill.9665e537-e177-4ca1-b449-3621ffa148d2';

  gc_status_ok number(3) := 200;
  gc_status_bad_request number(3) := 400;
  gc_status_unauthorized number(3) := 403;
  gc_status_error number(3) := 500;

  --
  function generate_response(
    p_text in varchar2
    , p_end_session in boolean default false
  ) return clob;

  procedure process_request(
    p_payload in blob
    , p_status_code out number
    , p_message out nocopy varchar2
    , p_response out nocopy clob
  );
end askme;
/