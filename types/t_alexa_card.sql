create or replace type t_alexa_card as object(
  card_type varchar2(11)
  , title varchar2(50)
  , content varchar2(4000) -- for simple or linkaccount cards
  , text varchar2(4000) -- for standard cards
  , small_image_url varchar2(200)
  , large_image_url varchar2(200)
);
/