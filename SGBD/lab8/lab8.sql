--triggerele sunt blocuri de cod care se executa automat, de obicei cand o operatie DML este executata in baza de date.
-- atunci cand este creat, se va specifica si cand se va executa in mod automat.
-- Triggerele peste tabele/viewuri sunt de tip DML- data manipulation language
-- cele peste schemele de baze de date sunt de tip DDL- data definition language
-- cele peste bazele de date sunt de tip system.
create or replace trigger dml_stud
    before insert or update or delete on studenti  
begin
    dbms_output.put_line('Operatie DML in tabela STUDENTI!');
    case
        when inserting then dbms_output.put_line('INSERT');
        when deleting then dbms_output.put_line('DELETE');
        when updating then dbms_output.put_line('UPDATE');
    end case;
end;

delete from studenti where id=10000;
update studenti set bursa=2000 where bursa=1000;
rollback;

create or replace trigger dml_stud1
    before insert or update or delete on studenti
declare
    v_nume studenti.nume%type;
begin
    select nume into v_nume from studenti where id=200;
    dbms_output.put_line('BEFORE DML NIGGER: ' || v_nume);
end;
/
drop trigger dml_stud1;
drop trigger dml_stud2;

create or replace trigger dml_stud2
    after insert or update or delete on studenti
declare
    v_nume studenti.nume%type;
begin
    select nume into v_nume from studenti where id=200;
    dbms_output.put_line('AFTER DML TRIGGER: ' || v_nume);
end;
/

update studenti set nume='NumeNou' where id=201;
rollback;
select * from studenti where id=201;

-- chiar daca am pus in acel trigger un id=200, macar cand vom insera
-- sau sterge sau updata orice inregistrare ni se va afisa pentru acel id
-- e ceva ce doar explica ce se intampla

create or replace trigger marire_nota
    before update of valoare on note -- aicia se executa numai cand modificam valoarea
    for each row
    begin
        dbms_output.put_line('ID nota: ' || :OLD.id); -- avem acces si la alte campuri, nu doar la cele modificate
        dbms_output.put_line('Vechea nota: ' || :OLD.valoare);
        dbms_output.put_line('Noua nota: ' || :NEW.valoare);
            if(:OLD.valoare>:NEW.valoare) then :NEW.valoare:=:old.valoare; -- nu se schimba nimic
        end if;
end;

-- prin :old ne referim la valoarea actuala din tabela, adica cea care nu e modificata
-- prin :new ne referim la valoarea noua modificata dupa o operatie DML

update note set valoare=8 where id in (1,2,3,4);
rollback;
-- cand facem insert, valoare :OLD este NULL pentru ca nu exista inca acea inregistrare
-- cand facem delete, :NEW este NULL pentru ca nu exista o alta valoare
-- nu putem modifica valoarea :new intr un trigger de tip after( pentru ca deja valoarea
-- a fost scrisa in tabela inainte sa fie executat triggerul);
-- daca o modificare lanseaza 2 triggere, una de tip before si una de tip after
-- si daca triggerul de tip before schimba valoarea inregistrarii, atunci triggerul de tip after
-- va vedea valoarea modificata de triggerul 
drop trigger mutate_example;
create or replace trigger mutate_example
after delete on note for each row
declare
    v_Ramas int;
begin
    dbms_output.put_line('stergere nota cu ID: ' || :OLD.id);
    select count(*) into v_ramas from note;
    dbms_output.put_line('Au ramas ' || v_Ramas || ' note');
end;
/
delete from note where id between 101 and 110;
/


CREATE OR REPLACE TRIGGER stergere_note 
FOR DELETE ON NOTE
COMPOUND TRIGGER
  v_ramase INT;
  
  AFTER EACH ROW IS 
  BEGIN
     dbms_output.put_line('Stergere nota cu ID: '|| :OLD.id);
  END AFTER EACH ROW;
  
  AFTER STATEMENT IS BEGIN
     select count(*) into v_ramase from note;
     dbms_output.put_line('Au ramas '|| v_ramase || ' note.');  
  END AFTER STATEMENT ;
END stergere_note;
-- after each row is begin .. end asta se va executa exact dupa fiecare rand sters
-- dupa ce se sterg toate randurile alese, se va executa after statement is begin
delete from note where id between 241 and 250;

alter trigger stergere_note disable; -- sau enable

-- triggerele de tipul instead of nu pot fi construite asupra tabelelor ci doar peste operatii
-- ce tin de un view

create view std as select * from studenti;
select * from studenti order by 1 asc;

create or replace trigger delete_student
    instead of delete on std
begin
    dbms_output.put_line('Stergem pe: ' || :OLD.nume);
    delete from note where id_student=:OLD.id;
    delete from prieteni where id_student1=:OLD.id;
    delete from prieteni where id_Student2=:OLD.id;
    delete from studenti where id=:OLD.id;
    end;
    
delete from std where id=75;
select * from studenti where id =75;
select * from std where id =75;
rollback;
-- cand stergem intr-un view se va sterge si in tabela de baza a view-ului

create or replace trigger drop_trigger
    before drop on student.SCHEMA
    begin
        raise_application_error(
            num=>-20000,
            msg=> ' cant touch this' );
        end;
/
drop trigger drop_trigger;
drop table note;
select * from note where id<120 order by 1 asc;
-- IN CAZ CA STERGI UN TABEL, TE DUCI : show recyclebin;
-- APOI FLASHBACK STUDENT.NUMETABEL  TO BEFORE DROP;
--ZEU SUPREM

CREATE OR REPLACE TRIGGER p
    instead of CREATE ON SCHEMA
    begin
        execute immediate 'CREATE TABLE T(n NUMBER, m NUMBER)';
    end;
/
drop trigger p;
drop table p;
create table o(x number);
drop table a;
select * from  T;

drop table autentificari;
create table autentificari(nume varchar2(30), ora timestamp);
/
create or replace trigger check_user
    after logon on database
    declare
        v_nume varchar2(30);
    begin
        v_nume:=ora_login_user; -- ora vine de la ORAcle
        insert into autentificari values(v_nume, CURRENT_TIMESTAMP);
end;
/

select * from autentificari;

