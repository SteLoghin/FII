set serveroutput on;

-- nu putem face operatii de insert intr un view
-- o sa fie nevoie de o secventa pentru numaru matricol la fel cum am facut la java

drop view CATALOG;
create view catalog as select s.id as student_id,s.nume as nume_student,s.prenume as prenume_student,n.id_curs as id_curs,
c.titlu_curs as titlu_curs,n.valoare as valoare from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs;

select * from catalog order by 1 desc;
-- folosim triggere instead of pentru a face viewuri inerent actualizabile in viewuri actualizabile
-- for each row din instead of trigger inseamna ca acel cod plsql de dupa for each row si intre begin ... end se va executa pentru fiecare rand actualizat,sters etc.


-- CA SA NU PRIMI BAD BIND VARIABLE, CAND FACEM DELETE TREBUIE SA PUNEM EXACT NUMELE COLOANEI
-- ASA CUM E DENUMITA IN VIEW, NU CA IN TABELELE DE BAZA

create or replace trigger sterge_student_si_note
    instead of delete on catalog
begin
     delete from note where id_student=:OLD.student_id;
  delete from prieteni where id_student1=:OLD.student_id;
  delete from prieteni where id_student2=:OLD.student_id;
  delete from studenti where id=:OLD.student_id;
end;

delete from catalog where student_id=514;

select * from catalog where student_id=1025;



delete from catalog where student_id=1025;

rollback;


select * from user_triggers;


create or replace trigger adauga_nota_student_inexistent
    instead of insert on   CATALOG
declare
    TYPE varr is VARRAY(1000) of varchar2(255);
    nume varr:=varr('Sporescu', 'Bogdan', 'Spataru','Georgescu','Spataru','Benzema','Ronaldo');
    prenume varr:=varr('Laura', 'Nicusor', 'Sabina', 'Ludmila', 'Bogdan', 'Nicusor','Turta');
    v_matr varchar2(50);
    v_nume varchar2(255);
    v_prenume varchar2(255);
    v_an int;
    v_grupa varchar2(3);
    v_bursa int;
    v_ultima_nota integer;
    v_exista integer;
begin

    select count(*) into v_exista from studenti where id=:new.student_id; 
     if v_exista=0 then
     v_an := TRUNC(DBMS_RANDOM.VALUE(0,3))+1;
     v_grupa := chr(TRUNC(DBMS_RANDOM.VALUE(0,2))+65) || chr(TRUNC(DBMS_RANDOM.VALUE(0,6))+49);
     v_nume:= nume(trunc(dbms_random.value(0,nume.count))+1);
     v_prenume:= prenume(trunc(dbms_random.value(0,prenume.count))+1);
     v_matr := FLOOR(DBMS_RANDOM.VALUE(100,999)) || CHR(FLOOR(DBMS_RANDOM.VALUE(65,91))) || CHR(FLOOR(DBMS_RANDOM.VALUE(65,91))) || FLOOR(DBMS_RANDOM.VALUE(0,9));
     v_bursa := TRUNC(DBMS_RANDOM.VALUE(0,10))*100 + 500;
            insert into studenti(id,nr_matricol,nume,prenume,an,grupa,bursa)
            values (secventa_id_student.nextval,v_matr,v_nume,v_prenume,v_an,v_grupa,v_bursa);
            insert into note(id,id_student,id_curs,valoare)
            values(SEQ_INS_NOTE.nextval,secventa_id_student.currval,(select id from cursuri where titlu_curs=:new.titlu_curs),:new.valoare);
    else
        dbms_output.put_line('studentul exista in BD');
    end if;
end;

----------------------------------


insert into catalog(titlu_curs,valoare) values('Baze de date',10);
select * from catalog order by 1 desc;

create sequence secventa_id_note
start with 7000
increment by 1;

create sequence secventa_id_student
start with 7000
increment by 1;

select id from cursuri;

select seq_ins_studenti.currval from dual;
select seq_ins_studenti.NEXTval from dual;
select * from note;

select * from studenti order by 1 desc;
select * from catalog order by 1 desc;

-------------------------------

--secventa  pentru id curs

create sequence secventa_id_curs
start with 25
increment by 1;

drop trigger inserare_nota_curs_inexistent;
create or replace trigger inserare_nota_curs_inexistent
instead of insert on catalog
declare
    v_an integer;
    v_semestru integer;
    v_credite integer;
begin
         v_an := TRUNC(DBMS_RANDOM.VALUE(0,3))+1;
         v_semestru:=trunc(dbms_random.value(1,3));
         v_credite:=trunc(dbms_random.value(4,7));
         insert into cursuri(id,titlu_curs,an,semestru,credite)
         values(secventa_id_curs.nextval,:new.titlu_curs,v_an,v_semestru,v_credite);
         insert into note(id,id_student,id_curs,valoare)
         values(SEQ_INS_NOTE.nextval,:new.student_id,(select id from cursuri where titlu_curs=:new.titlu_curs),:new.valoare);
end;

select * from note;
select * from catalog where student_id=30 ;
select * from studenti order by 1 desc;
select * from studenti where id=30;
insert into catalog(student_id,titlu_curs,valoare) values(30,'mate',9);
select * from cursuri;
















select max(id) from note;


insert into note (id, id_student, id_curs, valoare) 
               values(seq_ins_note.nextval, 
               (select id from studenti where rownum<2 order by 1 desc),
               (select id from cursuri where titlu_curs =:old.titlu_curs),:new.valoare); 
insert into studenti(id,nr_matricol,nume,prenume,an,grupa,bursa)  
                values(SEQ_INS_STUDENTI.nextval,'abc','Student' || SEQ_INS_STUDENTI.currval, 'Prenume' || SEQ_INS_STUDENTI.currval, trunc(dbms_random.value(1,4)),'B'||trunc(dbms_random.value(1,8)) ,trunc(dbms_random.value(500,3000)));    



select seq_ins_note.nextval, (select id from studenti where rownum<2 order by 1 desc), 
                (select id from cursuri where titlu_curs =:old.titlu_curs),:new.nota from dual;               

select * from recyclebin order by 6 desc;
select * from user_triggers;

select id from studenti where rownum=1 order by 1 desc;
select SEQ_INS_STUDENTI.currval from dual;
select * from note where rownum<2;
select * from catalog where rownum<2;
insert into catalog(curs_id,nota) values(1,10);
select * from studenti order by 1 desc;
select * from note where id <5;

select trunc(dbms_random.value(1,4)) from dual;

insert into studenti(id,nr_matricol,nume,prenume,an,grupa,bursa) 
            values(SEQ_INS_STUDENTI.nextval,'abc','Student' || SEQ_INS_STUDENTI.currval, 'Prenume' || SEQ_INS_STUDENTI.currval, trunc(dbms_random.value(1,4)),'B'||trunc(dbms_random.value(1,8)) ,trunc(dbms_random.value(500,3000)));    

select * from studenti order by 1 desc;


SHOW ERRORS TRIGGER STUDENT.sterge_student_si_note;
select * from user_errors where type = 'TRIGGER' and name = 'sterge_student_si_note';

