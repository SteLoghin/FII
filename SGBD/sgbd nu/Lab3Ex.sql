create or replace package lab3 is
  v_cmmdc integer;
  v_cmmc integer; 
  function f_cmmdc (n1 in integer, n2 in integer) return integer;
  function f_cmmc (n1 in integer,n2 in integer) return integer;
end;
/

create or replace package body lab3 is

  procedure do_all (n1 in integer, n2 in integer) is
  begin
    p_min := least(n1, n2);
    p_max := greatest(n1, n2);
  end do_all;

  function f_min(n1 in integer, n2 in integer) return integer is
  begin
    do_all(n1, n2);
    return p_min;
  end f_min;

  function f_max(n1 in integer, n2 in integer) return integer is
  begin
    do_all(n1, n2);
    return p_max;
  end f_max;

end lab3;
/

select lab3.f_min(70, 900), lab3.f_max(70, 900) from dual;



create or replace procedure metoda1(in_id_student studenti.id%type)
as
    mesaj   varchar2(32000) := 'Studentul are deja nota la aceasta materie';
    counter integer;
    v_index integer;
begin
    -- verific daca are nota la logica
--    select count(*)
--    into counter
--    from note n
--             join cursuri c on n.ID_CURS = c.ID
--    where n.ID_STUDENT = in_id_student
--      and c.ID = 1;
--    if counter = 0 then
        for v_index in 1..10000
            LOOP
                select count(*)
    into counter
    from note n
             join cursuri c on n.ID_CURS = c.ID
    where n.ID_STUDENT = in_id_student
      and c.ID = 1;
                if counter = 0 then
                insert into note (id, id_student, id_curs, valoare)
                select seq_ins_note.nextval,
                       in_id_student,
                       (select id from cursuri where titlu_curs = 'Logicã'),
                       10
                from dual;
                else
                    dbms_output.PUT_LINE(mesaj);
                end if;
            end loop;
--    else
--        dbms_output.PUT_LINE(mesaj);
--    end if;
end;
-- select medie_student('Mihailescu','Laura') from dual;

declare
    v_index integer;
begin
    for v_index in 1..100000 loop
        dbms_output.put_line('hahah');
    end loop;
end;




begin
    metoda1(12);
end;