begin
  -- Only SYSDBA can REST-enable a schema other than itself.
  ords.enable_schema(
    p_enabled => true
    , p_url_mapping_type => 'BASE_PATH'
    , p_url_mapping_pattern => lower(user) || '-alexa'
    , p_auto_rest_auth => false
  );

  ords.define_module(
    p_module_name => 'askme.v1'
    , p_base_path => '/askme/v1/'
    , p_items_per_page => 25
    , p_status => 'PUBLISHED'
    , p_comments => null
  );

  ords.define_template(
    p_module_name => 'askme.v1'
    , p_pattern => 'sayHello'
    , p_priority => 0
    , p_etag_type => 'HASH'
    , p_etag_query => null
    , p_comments => null
  );

  ords.define_handler(
    p_module_name => 'askme.v1'
    , p_pattern => 'sayHello'
    , p_method => 'POST'
    , p_source_type => 'plsql/block'
    , p_items_per_page =>  0
    , p_mimes_allowed => 'application/json'
    , p_comments => NULL
    , p_source => q'~
declare
  l_status_code number(3);
  l_message varchar2(32767);
  l_response clob;
begin
  askme.process_request(
    p_payload => :body
    , p_status_code => l_status_code
    , p_message => l_message
    , p_response => l_response
  );

  if l_status_code = alexa.gc_status_ok then
    owa_util.status_line(nstatus => l_status_code);
    sys.htp.p(l_response);
  else
    owa_util.status_line(nstatus => l_status_code);
    sys.htp.p(l_message);
  end if;
end;
    ~'
  );
end;
/