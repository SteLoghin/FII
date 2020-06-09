 ----- universal pentru toate
--- lab7

create or replace type student as object
(
    nume         varchar2(10),
    prenume      varchar2(10),
    grupa        varchar2(4),
    an           number(1),
    data_nastere date,
    member procedure afiseaza_foaie_matricola,
    CONSTRUCTOR FUNCTION student(nume varchar2, prenume varchar2)
    RETURN SELF AS RESULT
);

-- in cazul declararii unui obiect nu putem utiliza
-- %type, trebuie sa fie "primitive" cred ca se cheama
-- acest lucru este asa deoarece:
-- daca cineva vrea sa modifice tipul de baza al unui rand din
--baza de date, atunci  obiectul ar avea de suferit
-- si alte subprograme ce foloesc %type
-- trebuie declarat si body

create or replace type body student as
    member procedure afiseaza_foaie_matricola is
        begin
            dbms_output.PUT_LINE('Aceasta procedura calculeaza si afiseaza foaia matricola');
        end afiseaza_foaie_matricola;
        constructor function student(nume varchar2, prenume varchar2)
            return self as result
        as
        begin
            self.nume:=nume;
            self.prenume:=prenume;
            self.data_nastere:=sysdate;
            self.an:=1;
            self.grupa:='A1';
            return;
            end;
end;
/

create table studenti_oop
(
    nr_matricol varchar2(4),
    obiect      STUDENT
);

declare
    v_student1 STUDENT;
    v_student2 STUDENT;
begin
    v_student1 := student('Popescu', 'Ionut', 'A2', 3, TO_DATE('11/04/1994', 'dd/mm/yyyy'));
    v_student2 := student('Vasilescu', 'George', 'A4', 3, TO_DATE('22/03/1995', 'dd/mm/yyyy'));
    v_student1.afiseaza_foaie_matricola();
    DBMS_OUTPUT.PUT_LINE(v_student1.nume);
    insert into studenti_oop values('100',v_student1);
    insert into studenti_oop values('101',v_student2);

end;

select * from studenti_oop;

set serveroutput on;

 CONSTRUCTOR FUNCTION student(nume varchar2, prenume varchar2)
    RETURN SELF AS RESULT

CONSTRUCTOR FUNCTION student(nume varchar2, prenume varchar2)
    RETURN SELF AS RESULT
  AS
  BEGIN
    SELF.nume := nume;
    SELF.prenume := prenume;
    SELF.data_nastere := sysdate;
    SELF.an := 1;
    SELF.grupa := 'A1';
    RETURN;
  END;

declare
    v_student1 STUDENT;
    v_student2 STUDENT;
begin   
    v_student1:=student('Vacariu','Vasile');
    v_student2:=student('Virusu','Cristian');
      if (v_student1 < v_student2) 
      THEN DBMS_OUTPUT.PUT_LINE('Studentul '|| v_student1.nume || ' este mai tanar.');
      ELSE DBMS_OUTPUT.PUT_LINE('Studentul '|| v_student2.nume || ' este mai tanar.');
   END IF;
--    insert into studenti_oop values('102',v_student1);
end;


select * from studenti_oop;

Create or replace type caminar as object
(
    nume varchar2(10),
    prenume varchar2(10),
    grupa varchar2(4),
    an number(1),
    data_nastere date,
    member procedure afiseaza_foaie_matricola,
    map member function varsta_in_zile return number,
    constructor function caminar(nume varchar2, prenume varchar2)
            return self as result
)NOT FINAL;
/
drop table caminar_oop;
create or replace type body caminar as
    member procedure afiseaza_foaie_matricola is
    begin
        dbms_output.put_line('aceasta procedura calculeaza si afiseaza foaia matricola');
    end afiseaza_foaie_matricola;
    constructor function caminar(nume varchar2, prenume varchar2)
        return self as result
    as
    begin
        self.nume:=nume;
        self.prenume:=prenume;
        self.data_nastere:=sysdate;
        self.an:=1;
        self.grupa:='A1';
        return;
    end;
    map member function varsta_in_zile
    return number
    is
    begin
        return sysdate-data_nastere;
    end;
end;

create table caminar_oop(nr_matricol varchar2(4),obiect caminar);

set serveroutput on;
DECLARE
   v_caminar1 caminar;
   v_caminar2 caminar;
   v_caminar3 caminar;
   v_caminar4 caminar;
BEGIN
   v_caminar1 := caminar('Popescu', 'Ionut', 'A2', 3, TO_DATE('11/04/1994', 'dd/mm/yyyy'));
   v_caminar2 := caminar('Vasilescu', 'George', 'A4', 3, TO_DATE('22/03/1995', 'dd/mm/yyyy'));
   v_caminar3:= caminar('Caminescu','cAMINAR');
   v_caminar4:=caminar('zeescu','CAMATAR');
--   v_caminar1.afiseaza_foaie_matricola=();
--   dbms_output.put_line(v_caminar1.nume);
    if (v_caminar3 < v_caminar4) 
      THEN DBMS_OUTPUT.PUT_LINE('Caminarul '|| v_caminar3.nume || ' este mai tanar.');
      ELSE DBMS_OUTPUT.PUT_LINE('Caminarul '|| v_caminar4.nume || ' este mai tanar.');
   END IF;
--   insert into caminar_oop values ('100', v_caminar1);
--   insert into caminar_oop values ('101', v_caminar2);
--   insert into caminar_oop values ('102', v_caminar3);
--   insert into caminar_oop values ('103', v_caminar4);
END;


select * from caminar_oop;
delete from caminar_oop where nr_matricol in ('102','103','100','101');


-- e pentru caminar
drop type student_bazat;
create or replace type student_bazat under caminar
(
    bursa number(6,2),
    overriding member procedure afiseaza_foaie_matricola
)
/

create or replace type body student_bazat as
    overriding member procedure afiseaza_foaie_matricola is
    begin
        dbms_output.put_line('bursier');
    end afiseaza_foaie_matricola;
end;
/

declare
    v_student_bazat student_bazat;
begin
    v_student_bazat := student_bazat('Mihalcea', 'Mircea', 'A1', 2, TO_DATE('18/09/1996', 'dd/mm/yyyy'), 1000);
    dbms_output.put_line(v_student_bazat.nume);
    v_student_bazat.afiseaza_foaie_matricola();
end;


-- merge order by dupa obiect pentru ca exista functia de MAP
select * from caminar_oop order by obiect;

--Pentru a crea o clas? abstract? utiliza?i NOT INSTANTIABLE dup? declara?ia clasei (înainte de NOT FINAL).
--Are rost s? folosi?i NOT INSTANTIABLE f?r? a fi urmat? de NOT FINAL  ?
-- raspuns: nu pentru ca asa am avea o clasa abstracta adica nu poate fi instantiata, si fara sa
-- declaram NOT FINAL, inseamna ca nu putem nici instantia si nici a permite mostenirea altor clase


DECLARE
  s caminar;
BEGIN
  SELECT obiect INTO s FROM caminar_oop WHERE nr_matricol='103';
  dbms_output.put_line(s.nume);
END;

