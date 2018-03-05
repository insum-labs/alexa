create or replace type t_alexa_output_speech as object(
  output_speech_type varchar2(9)
  , text varchar2(4000) -- for plaintext
  , ssml varchar2(4000) -- for SSML
);
/