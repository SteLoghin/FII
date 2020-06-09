set serveroutput on;

/* 
    Loghin Alexandru-Stelian, grupa B5
    Tema 7- PLSQL_7
*/


drop table log_Table;
create table log_table
(
    id_nota         number,
    valoare_veche   number(2),
    valoare_noua    number(2),
    tip_operatie    varchar2(30),
    data_modificare timestamp,
    autor           varchar2(20)
);

select *
from log_table;

-- trebuie sa punem valorile in log_Table asa cum se numesc in tabelul note, altfel vom primi bad bind
-- user-ul care duce la sfarsit o operatie DML il aflu cu select user from dual;
CREATE OR REPLACE TRIGGER trg_log_table
    AFTER INSERT OR UPDATE OR DELETE
    ON note
    FOR EACH ROW
begin
    if updating then
        INSERT INTO log_table (id_nota, valoare_veche, valoare_noua, tip_operatie, data_modificare, autor)
        VALUES (:old.id, :old.valoare, :new.valoare, 'updating', :new.data_notare, (select user from dual));
    end if;
    if inserting then
        insert into log_table(id_nota, valoare_veche, valoare_noua, tip_operatie, data_modificare, autor)
        values (:new.id, null, :new.valoare, 'inserting', :new.data_notare, (select user from dual));
    end if;
    if deleting then
        insert into log_table(id_nota, valoare_veche, valoare_noua, tip_operatie, data_modificare, autor)
        values (:old.id, :old.valoare, null, 'deleting', :old.data_notare, (select user from dual));
    end if;
end;

select *
from note
order by 1 desc;

-- am facut select * from log_table dupa fiecare operatie DML pentru a ma asigura ca totul a functionat cum trebuie
insert into note
values (seq_ins_note.nextval, 7001, 2, 10, sysdate, sysdate, sysdate);
select *
from log_Table order by 1 desc;
insert into note
values (seq_ins_note.nextval, 7001, 3, 5, sysdate, sysdate, sysdate);
select *
from log_Table;
update note
set valoare=10
where id_student = 7001
  and id_curs = 3;
select *
from log_Table;
insert into note
values (seq_ins_note.nextval, 7001, 4, 5, sysdate, sysdate, sysdate);
select *
from log_Table;
update note
set valoare=7
where id_student = 7001
  and id_curs = 4;
select *
from log_table;
update note
set valoare=10
where id_student = 7001
  and id_curs = 4;
select *
from log_table;
update note
set valoare=10
where id_student = 7001
  and id_curs = 4;
select *
from note
where id_student = 69;
update note
set valoare=10
where id_student = 69
  and id_curs = 20;
select *
from log_table;
delete
from note
where id = 1107;
select *
from log_table;
delete
from note
where id = 20101;
select *
from log_table;
delete
from note
where id = 20100;
select *
from log_table;
delete
from note
where id = 20099;
select *
from log_table;
delete
from note
where id = 20096;
select *
from log_table;