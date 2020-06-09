CREATE OR REPLACE TRIGGER adauga_nota_student_inexistent
instead of INSERT ON catalog
Declare
TYPE varr IS VARRAY(1000) OF varchar2(255);
nume varr:=varr('Andronie', 'Pantrunjel', 'Ionescu','Popescuu','Ruptu');
prenume varr:=varr('Andrei', 'FLORIN', 'Aioanei');
v_count integer;
v_matr VARCHAR2(6);
v_nume VARCHAR2(255);
v_prenume VARCHAR2(255);
 v_an int;
 v_grupa varchar2(2);
 v_bursa int;
 v_id_curs number(38,0);
 
begin
        select count(*) into v_count from studenti where id=:new.student_id;
        if v_count=0 then
        v_an := TRUNC(DBMS_RANDOM.VALUE(0,3))+1;
        v_grupa := chr(TRUNC(DBMS_RANDOM.VALUE(0,2))+65) || chr(TRUNC(DBMS_RANDOM.VALUE(0,6))+49);
        v_nume:= nume(TRUNC(DBMS_RANDOM.VALUE(0,nume.count))+1);
        v_prenume:= prenume(TRUNC(DBMS_RANDOM.VALUE(0,prenume.count))+1);
        v_matr := FLOOR(DBMS_RANDOM.VALUE(100,999)) || CHR(FLOOR(DBMS_RANDOM.VALUE(65,91))) || CHR(FLOOR(DBMS_RANDOM.VALUE(65,91))) || FLOOR(DBMS_RANDOM.VALUE(0,9));
        v_bursa := TRUNC(DBMS_RANDOM.VALUE(0,10))*100 + 500;
        insert into studenti(id,nr_matricol,nume,prenume,an,grupa,bursa) values(SECVENTA_ID_STUDENT.nextval,
        v_matr, v_nume, v_prenume, v_an, v_grupa, v_bursa);
       insert into note(id,id_student,id_curs,valoare) values(SEQ_INS_NOTE.nextval,SECVENTA_ID_STUDENT.currval,(select id from cursuri where titlu_curs=:new.titlu_curs),:new.valoare);
       else
         DBMS_OUTPUT.PUT_LINE('Exista');  
         end if;
end;

-- cand bagi curs nou cu nota
drop trigger inserare_nota_curs_inexistent;
CREATE OR REPLACE TRIGGER inserare_nota_curs_inexistent
instead of INSERT ON catalog
Declare
v_an number;
v_semestru number;
v_credite number;

begin
v_an:=TRUNC(DBMS_RANDOM.VALUE(0,3))+1;
v_semestru:=Trunc(DBMS_RANDOM.VALUE(0,2)+1);
v_credite:=TRUNC(DBMS_RANDOM.VALUE(4,7));
insert into cursuri(id,titlu_curs,an,semestru,credite) values(SECVENTA_ID_CURS.nextval,:NEW.titlu_curs,v_an,v_semestru,v_credite);
insert into note(id,id_student,id_curs,valoare) values(SEQ_INS_NOTE.nextval,:new.student_id,(select id from cursuri where titlu_curs=:new.titlu_curs),:new.valoare);

end;

insert into catalog(student_id,titlu_curs,valoare) values(50,'romana',10);
select * from catalog where student_id=50;
insert into catalog(student_id,titlu_curs,valoare) values(50,'MANCARE',10);
select * from studenti where id=50;


