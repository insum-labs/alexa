create or replace package askme
as
  gc_amazon_skill_id varchar2(255) := 'amzn1.ask.skill.9665e537-e177-4ca1-b449-3621ffa148d2';

  procedure process_request(
    p_payload in blob
    , p_status_code out number
    , p_message out nocopy varchar2
    , p_response out nocopy clob
  );
end askme;
/