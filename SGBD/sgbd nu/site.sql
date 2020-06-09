create or replace type my_nested_table is table of varchar2(10);
/
create table my_subject(
    sub_id number,
    sub_name varchar2(20),
    sub_schedule_day my_nested_table
)NESTED TABLE sub_schedule_day store as nested_tab_space;

select * from my_subject;

desc my_subject;

insert into my_subject(sub_id,sub_name,sub_schedule_day)
values(101,'maths' ,my_nested_table('mon' , 'fri'));

insert into my_subject(sub_id,sub_name,sub_schedule_day)
values(102,'sugipl',my_nested_table('in','orice','zi'));

select * from my_subject;













--drop type studenti_burse;
--drop type student_bursa;
--/
--create type student_bursa as object (id_student char(4), procent_marire number);
--/
--create type studenti_burse as table of student_bursa;
--/
--create or replace procedure mareste_bursa (IN_id_studenti IN studenti_burse) is
--begin
--  for c in (select id_student, procent_marire from table(IN_id_studenti)) loop
--    update studenti 
--    set bursa = nvl(bursa,100) * (1 + c.procent_marire) 
--    where id = c.id_student;
--  end loop;
--end mareste_bursa;
--/
--select id,bursa from studenti order by id;
--/
--begin 
--  mareste_bursa(studenti_burse(student_bursa(1,0.5),student_bursa(2,2)));
--end;
--/
--
--select id,bursa from studenti order by id;
--/
--rollback;
--
----2
--drop type istoric_burse;
--create type istoric_burse as table of number(38,2);
--/
--alter table studenti add bursa_veche istoric_burse nested table bursa_veche store AS bursa_veche;
--update studenti set bursa_veche=istoric_burse();
--commit;
--
--create or replace procedure mareste_bursa (IN_id_studenti studenti_burse) is
--begin
--  for c in (select id_student, procent_marire from table(IN_id_studenti)) loop
--    update studenti 
--    set bursa_veche = bursa_veche multiset union istoric_burse(nvl(bursa,0)), bursa = nvl(bursa,100) * (1 + c.procent_marire) 
--    where id = c.id_student;
--  end loop;
--end mareste_bursa;
--/
--
--select * from studenti order by id;
--
--begin 
--    mareste_bursa(studenti_burse(student_bursa(1,0.5),student_bursa(2,2)));
--    end;
--
--select bursa from studenti where id in(1,2);
--update studenti set bursa=1000 where id in(1,2);
