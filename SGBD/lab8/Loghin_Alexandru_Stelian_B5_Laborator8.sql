set serveroutput on;

-- Loghin Alexandru-Stelian, grupa B5

-- view-ul este cel pe care ni l-ati aratat pe classroom
select *
from catalog
order by 1 desc;
drop view CATALOG;
create view catalog as
select s.id         as student_id,
       s.nume       as nume_student,
       s.prenume    as prenume_student,
       n.id_curs    as id_curs,
       c.titlu_curs as titlu_curs,
       n.valoare    as valoare
from studenti s
         join note n on s.id = n.id_student
         join cursuri c on c.id = n.id_curs;

select *
from catalog;

-- Delete-ul
-- trebuie sterse si inregistrarile din prieteni de asemenea, adica studentii care sunt prieteni cu studentul sters, vor pierde acea prietenie
-- deoarece nu ar mai exista consistenta datelor din tabelul prieteni
-- acest cod este asemanator cu cel de pe site-ul materiei PLSQL_7
create or replace trigger sterge_student_si_note
    instead of delete
    on catalog
begin
    delete from note where id_student = :OLD.student_id;
    delete from prieteni where id_student1 = :OLD.student_id;
    delete from prieteni where id_student2 = :OLD.student_id;
    delete from studenti where id = :OLD.student_id;
end;

delete
from catalog
where student_id = 515;
select *
from studenti
where id = 515;
select *
from catalog
where student_id = 515;

--Inserarea unei note la un curs pentru un student inexistent cu adaugarea studentului;
-- am creat o secventa ca sa imi fie mai usor la inserarea unui ID pentru un student nou
create sequence secventa_id_student
    start with 7000
    increment by 1;


CREATE OR REPLACE TRIGGER adauga_nota_student_inexistent
    instead of INSERT
    ON catalog
DECLARE
    TYPE varr IS VARRAY (1000) OF varchar2(255);
    nume      varr := varr('Sporescu', 'Bogdan', 'Spataru', 'Georgescu', 'Spataru', 'Benzema', 'Ronaldo', 'Zvanca',
                           'Bezedica');
    prenume   varr := varr('Laura', 'Nicusor', 'Sabina', 'Ludmila', 'Bogdan', 'Nicusor', 'Titirca', 'Mitica', 'Medeea',
                           'Degetica');
    v_count   integer;
    v_matr    VARCHAR2(6);
    v_nume    VARCHAR2(255);
    v_prenume VARCHAR2(255);
    v_an      int;
    v_grupa   varchar2(2);
    v_bursa   int;
    v_id_curs number(38, 0);
    -- partea cu generarea random am incercat sa o fac singur dar nu prea mi-a reusit asa ca m-am uitat pe scriptul de populare rulat la inceputul semestrului
    -- din acel script am luat partea cu generarea random a informatiilor despre un student nou
begin
    -- verific daca acest ID nu exista deja in baza de date, daca nu atunci vom insera un student nou, daca exista atunci se va intra pe ramura else si
    -- se va afisa un mesaj corespunzator
    -- pentru inserarea in tabele m-am folosit de secventele create anterior in laboratorul 1 si de altele create de mine cand am rezolvat acest laborator
    select count(*) into v_count from studenti where id = :new.student_id;
    if v_count = 0 then
        v_an := TRUNC(DBMS_RANDOM.VALUE(0, 3)) + 1;
        v_grupa := chr(TRUNC(DBMS_RANDOM.VALUE(0, 2)) + 65) || chr(TRUNC(DBMS_RANDOM.VALUE(0, 6)) + 49);
        v_nume := nume(TRUNC(DBMS_RANDOM.VALUE(0, nume.count)) + 1);
        v_prenume := prenume(TRUNC(DBMS_RANDOM.VALUE(0, prenume.count)) + 1);
        v_matr := FLOOR(DBMS_RANDOM.VALUE(100, 999)) || CHR(FLOOR(DBMS_RANDOM.VALUE(65, 91))) ||
                  CHR(FLOOR(DBMS_RANDOM.VALUE(65, 91))) || FLOOR(DBMS_RANDOM.VALUE(0, 9));
        v_bursa := TRUNC(DBMS_RANDOM.VALUE(0, 10)) * 100 + 500;
        insert into studenti(id, nr_matricol, nume, prenume, an, grupa, bursa)
        values (SECVENTA_ID_STUDENT.nextval,
                v_matr, v_nume, v_prenume, v_an, v_grupa, v_bursa);
        insert into note(id, id_student, id_curs, valoare)
        values (SEQ_INS_NOTE.nextval, SECVENTA_ID_STUDENT.currval,
                (select id from cursuri where titlu_curs = :new.titlu_curs), :new.valoare);

    end if;
end;

-- inseram o nota la o materie existenta unui student inexistent
insert into catalog(titlu_curs, valoare)
values ('Baze de date', 10);

-- verificam ca a fost inserat studentul, dau order by 1 desc deoarece valoarea id-ului studentului nou este data de urmatoarea valoare dintr o secventa
-- si e una mare
select *
from catalog
order by 1 desc;

----Inserarea unei note la un curs pentru un curs inexistent - cu adaugarea cursului
-- incep cu 25 pentru ca 24 e ultimul id din cursurile deja existente in baza de date
create sequence secventa_id_curs
    start with 25
    increment by 1;


CREATE OR REPLACE TRIGGER adauga_nota_curs_inexistent
    instead of INSERT
    ON catalog
DECLARE
    v_an       number;
    v_semestru number;
    v_credite  number;
    v_id_curs  number;

BEGIN
    -- din nou am apelat la scriptul de populare pentru a genera datele random
-- verific daca exista acest curs, daca nu, atunci il voi adauga altfel voi afisa un mesaj corespunzator
    select count(*) into v_id_curs from cursuri where titlu_curs = :new.titlu_curs;
    if v_id_curs = 0 then
        v_an := TRUNC(DBMS_RANDOM.VALUE(0, 3)) + 1;
        v_semestru := Trunc(DBMS_RANDOM.VALUE(0, 2) + 1);
        v_credite := TRUNC(DBMS_RANDOM.VALUE(4, 7));
        insert into cursuri(id, titlu_curs, an, semestru, credite)
        values (SECVENTA_ID_CURS.nextval, :NEW.titlu_curs, v_an, v_semestru, v_credite);
        insert into note(id, id_student, id_curs, valoare)
        values (SEQ_INS_NOTE.nextval, :new.student_id, (select id from cursuri where titlu_curs = :new.titlu_curs),
                :new.valoare);
    end if;
end;

-- trebuie adaugata nota unui student existent
insert into catalog(student_id, titlu_curs, valoare)
values (65, 'OOP', 10);
select *
from catalog
where titlu_curs = 'OOP';

---Inserarea unei note cand nu exista nici studentul si nici cursul
CREATE OR REPLACE TRIGGER adauga_student_si_curs
    instead of INSERT
    ON catalog
DECLARE
    v_matr       VARCHAR2(60);
    v_an_student int;
    v_grupa      varchar2(20);
    v_bursa      int;
    v_an_materie number;
    v_semestru   number;
    v_credite    number;
    -- cu astea de jos verific daca exista studentul si cursul
    v_count      integer;
    v_id_curs    number;
begin
    -- verific daca exista studentul sau cursul
    select count(*) into v_count from studenti where id = :new.student_id;
    select count(*) into v_id_curs from cursuri where id = (select id from cursuri where titlu_curs = :new.titlu_curs);
    -- daca nu exista niciunul dintre cele mai sus, voi insera un student nou si un curs nou
    -- din nou, m-am folosit de scriptul de populare pentru a putea genera date random
    if (v_count = 0 and v_id_curs = 0) then
        v_an_student := TRUNC(DBMS_RANDOM.VALUE(0, 3)) + 1;
        v_grupa := chr(TRUNC(DBMS_RANDOM.VALUE(0, 2)) + 65) || chr(TRUNC(DBMS_RANDOM.VALUE(0, 6)) + 49);
        v_matr := FLOOR(DBMS_RANDOM.VALUE(100, 999)) || CHR(FLOOR(DBMS_RANDOM.VALUE(65, 91))) ||
                  CHR(FLOOR(DBMS_RANDOM.VALUE(65, 91))) || FLOOR(DBMS_RANDOM.VALUE(0, 9));
        v_bursa := TRUNC(DBMS_RANDOM.VALUE(0, 10)) * 100 + 500;
        v_an_materie := TRUNC(DBMS_RANDOM.VALUE(0, 3)) + 1;
        v_semestru := Trunc(DBMS_RANDOM.VALUE(0, 2) + 1);
        v_credite := TRUNC(DBMS_RANDOM.VALUE(4, 7));

        -- creez studentul prima oara
        -- creez apoi cursul
        -- in final inserez nota studentului proaspat creat la cursul nou
        -- daca as face insert-ul in note inainte de cursuri, atunci nu s-ar intampla nimic pentru ca e nevoie de o materie la care sa fie pusa nota
        insert into studenti(id, nr_matricol, nume, prenume, an, grupa, bursa)
        values (:new.student_id,
                v_matr, :new.nume_student, :new.prenume_student, v_an_student, v_grupa, v_bursa);
        insert into cursuri(id, titlu_curs, an, semestru, credite)
        values (SECVENTA_ID_CURS.nextval, :NEW.titlu_curs, v_an_materie, v_semestru, v_credite);
        insert into note(id, id_student, id_curs, valoare)
        values (SEQ_INS_NOTE.nextval, :new.student_id, (select id from cursuri where titlu_curs = :new.titlu_curs),
                :new.valoare);
    end if;
end;

-- cum dumneavostra ne-ati recomandat sa inseram in acest view si student_id si id_curs, m-am folosit de student_it pentru a putea insera un student nou
INSERT INTO CATALOG(student_id, nume_Student, prenume_student, titlu_curs, valoare)
VALUES (10010, 'Zeu', 'Suprem', 'Educatie Civica', 10);

select *
from catalog
where titlu_curs = 'Educatie Civica';


---Update la valoarea notei pentru un student - se va modifica valoarea campului updated_at. De asemenea, valoarea nu poate fi modificata cu una mai mica (la mariri se considera nota mai mare).
create or replace trigger update_nota
    instead of UPDATE
    ON catalog
begin
    -- noua data cand se updateaza va fi chiar ziua in care ne aflam
-- verific daca nota noua e mai mica decat cea curenta, daca nu e atunci o updatez, daca da voi afisa un mesaj corespunzator
    if (:old.valoare < :new.valoare) then
        update note
        set valoare=:new.valoare,
            updated_at=sysdate
        where id_student = :new.student_id
          and id_curs = :new.id_curs;
    else
        dbms_output.put_line('Nota noua nu poate fi mai mica decat cea veche.');
    end if;
end;

update catalog
set valoare=10
where student_id = 69
  and id_curs = 16;
select *
from catalog
where student_id = 69
  and id_curs = 16;
-- incercam sa punem o nota mai mica acum aceluiasi student la aceeasi materie
update catalog
set valoare=8
where student_id = 69
  and id_curs = 16;
-- se observa ca nota ramane la fel si mesajul este afisat
select *
from catalog
where student_id = 69
  and id_curs = 16;

drop table log_table cascade constraints;
/
create table log_table
(
    id_student  number,
    id_curs     char(4),
    valoare     number(2),
    data_notare timestamp,
    action      char(10)
);
select * from log_table;
/
CREATE OR REPLACE TRIGGER trg_log_table
    AFTER INSERT OR UPDATE OR DELETE
    ON note
    FOR EACH ROW
begin
    if updating then
        INSERT INTO log_table (id_student, id_curs, valoare, data_notare, action)
        VALUES (:old.id_student, :old.id_curs, :new.valoare, :new.data_notare, 'updating');
    end if;
    if inserting then
        INSERT INTO log_table (id_student, id_curs, valoare, data_notare, action)
        VALUES (:new.id_student, :new.id_curs, :new.valoare, :new.data_notare, 'inserting');
    end if;
    if deleting then
        INSERT INTO log_table (id_student, id_curs, valoare, data_notare, action)
        VALUES (:old.id_student, :old.id_curs, :old.valoare, :old.data_notare, 'deleting');
    end if;
end;
/
--verificare
select *
from note
where id_student = 1
order by id_student;
delete
from note
where id = 1
  and id_curs = 1;
insert into note
values (seq_ins_note.nextval, 1, 1, 10, sysdate, sysdate, sysdate);
/
desc note;
/
delete
from log_table;
select *
from log_table;






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
from log_Table;

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

drop sequence seq_ins_note;
/
create sequence seq_ins_note
start with 20000
increment by 1;

drop sequence seq_ins_studenti;
/
create sequence seq_ins_studenti
start with 5000
--5000 e un nr random ales de praf
increment by 1;
/

 insert into studenti(id, nr_matricol, nume, prenume, an, grupa, bursa)
        values (seq_ins_studenti.nextval,'ab123g','Alex','Alex',2,'B5',1000);

insert into 
select * from studenti order by 1 desc;
select * from log_table;
-- am facut select * from log_table dupa fiecare operatie DML pentru a ma asigura ca totul a functionat cum trebuie
insert into note
values (seq_ins_note.nextval, 5001, 2, 10, sysdate, sysdate, sysdate);
select * from note;
select *
from log_Table;
insert into note
values (seq_ins_note.nextval, 5001, 3, 5, sysdate, sysdate, sysdate);
select *
from log_Table;
update note
set valoare=10
where id_student = 5001
  and id_curs = 3;
select *
from log_Table;
insert into note
values (seq_ins_note.nextval, 5001, 4, 5, sysdate, sysdate, sysdate);
select *
from log_Table;
update note
set valoare=7
where id_student = 5001
  and id_curs = 4;
select *
from log_table;
update note
set valoare=10
where id_student = 5001
  and id_curs = 4;
select *
from log_table;
update note
set valoare=10
where id_student = 5001
  and id_curs = 4;
select *
from note
where id_student = 69;
update note
set valoare=10
where id_student = 39
  and id_curs = 1;
  select * from cursuri where id=20;
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
