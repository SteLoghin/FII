/*1.Construiti o procedura (sau functie) care sa primeasca ca parametru o lista de obiecte de tip record care sa contina ID-uri de studenti si procentaj 
de marire a bursei. In cazul in care studentul nu avea bursa, i se va adauga o valoare minima (de 100) dupa care se va opera cresterea specificata. 
Procedura va face modificarile din lista primita ca parametru.*/
drop type studenti_burse;
drop type student_bursa;
/
create type student_bursa as object (id_student char(4), procent_marire number);
/
create type studenti_burse as table of student_bursa;
/
create or replace procedure mareste_bursa (IN_id_studenti IN studenti_burse) is
begin
  for c in (select id_student, procent_marire from table(IN_id_studenti)) loop
    update studenti 
    set bursa = nvl(bursa,100) * (1 + c.procent_marire) 
    where id = c.id_student;
  end loop;
end mareste_bursa;
/
select id,bursa from studenti order by id;
/
begin 
  mareste_bursa(studenti_burse(student_bursa(1,0.5),student_bursa(2,2)));
end;
/
select id,bursa from studenti order by id;
/
--eventual dau rollback pentru a reveni la datele de dinainte de apelul procedurii
rollback;


/*2.Modificati tabela studenti pentru a avea un nou camp in care sa se pastreze o lista cu modificari ale bursei (un history al valorilor anterioare).
Modificati codul de la punctul 1 pentru a face si aceasta adaugare in noul camp.*/
drop type istoric_burse;
create type istoric_burse as table of number(38,2);
 /
alter table studenti add bursa_veche istoric_burse nested table bursa_veche store as bursa_veche;
update studenti set bursa_veche = istoric_burse();
commit;
/
--https://livesql.oracle.com/apex/livesql/file/content_HA9MJBJI8GEU4PE39G2POFR79.html
--aici este descris exact ce face multiset union, e un operator pentru lucrul cu nested tables
create or replace procedure mareste_bursa (IN_id_studenti studenti_burse) is
begin
  for c in (select id_student, procent_marire from table(IN_id_studenti)) loop
    update studenti 
    set bursa_veche = bursa_veche multiset union istoric_burse(nvl(bursa,0)), bursa = nvl(bursa,100) * (1 + c.procent_marire) 
    where id = c.id_student;
  end loop;
end mareste_bursa;
/
select * from studenti order by id;


--fiecare are doar 2 medii pentru ca cele din anu 2, 3 le suprascriu pe cele precedente
select s.id,s.an,c.semestru,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=2 and nume='Avadanei'   and s.id=11 group by s.id,s.an,c.semestru order by s.id asc;

/
begin 
  mareste_bursa(studenti_burse(student_bursa(1,0.5),student_bursa(2,2)));
end;
/
--apelati de mai multe ori procedura si apoi vedeti modificarile legate de bursa, precum si de noul camp adaugat (bursa_veche)
select * from studenti where id in (1,2) order by id;


/*3.Definiti o colectie cu urmatoarele patru coloane: nr id, nume,
prenume, an. Definiti o procedura stocata (sau functie) care sa primeasca un parametru de intrare de tip colectia specificata,
iar in interiorul ei faceti join intre colectie si tabela note si afisati doar numele si media pentru studentii din anii 2 si 3.*/
drop type std_object force;
/
create or replace type std_object as object (id number(3), nume varchar2(100), prenume varchar2(100), an number(3));
/
create or replace type std_table is table of std_object;
/
create or replace procedure get_average (p_students std_table) 
  p_medie number := 0;
begin
  for i in p_students.first..p_students.last loop
    if p_students(i).an = 2 or p_students(i).an=3 then
      select round(avg(valoare)) into p_medie from note where id_student = p_students(i).id;
      dbms_output.put_line('Studentul '||p_students(i).nume||' are media '||round(p_medie,2));
    end if;
  end loop;
end;
/
--apelul (exemplificare pentru 3 studenti diferiti din baza)
--cautati studenti care au medii, adica nu cei din anul 1 !
--select * from (select id,nume,prenume,an from studenti where an in (2,3)) where rownum<4;
declare
  p_students std_table;
  p_stud1 std_object;
  p_stud2 std_object;
  p_stud3 std_object;
begin
  select std_object(id,nume,prenume,an) into p_stud1 from studenti where id=1;
  select std_object(id,nume,prenume,an) into p_stud2 from studenti where id=4;
  select std_object(id,nume,prenume,an) into p_stud3 from studenti where id=5;
     
  p_students := std_table(p_stud1,p_stud2,p_stud3);
  get_average(p_students);
end;



create or replace type medii is table of number(2,0);
/
alter table studenti add medii_student medii
nested table medii_student store as medii_student;
/
update studenti
set
    medii_student = medii();
/
select * from studenti;
/

declare 
    n_sids num_arr;
    n_values num_arr;
    s_ids num_arr;
    medie number;
begin 
    select sids, nvalues
    bulk collect into n_sids, n_values
    from (select id_student as sids, valoare as nvalues
        from note);
    select sids
    bulk collect into s_ids
    from (select id as sids
        from studenti);
    
    for i in 1..s_ids.count loop
        for an in 1..3 loop
            for semestru in 1..2 loop
                select avg(n.valoare)
                into medie 
                from note n join cursuri c on n.id_curs=c.id
                where n.id_student=s_ids(i) and c.an=an and c.semestru=semestru;
                
                update studenti
                set medii_student = medii_student multiset union medii(medie)
                where id=s_ids(i);
            end loop;
        end loop;
    end loop;
    
end;
/

CREATE OR REPLACE FUNCTION NUMAR_MEDII(id_stud_in in studenti.id%type)
return number
as 
    student studenti%ROWTYPE;
begin
    select * 
    into student
    from studenti
    where id_stud_in=id;
    
    return student.medii_student.count;
end;
/

begin
    dbms_output.put_line(numar_medii(100));
end;




--- lab 3 unde am luat numa un punct pe un apel de functie
--Grupa B5
/*1.(1p) Avand exemplele trimise, creati un pachet pentru 3 din functiile trimise. Apelati apoi una din aceste functii, in 
cadrul pachetului.*/
CREATE OR REPLACE PACKAGE pck_test IS
    PROCEDURE p_afiseaza_varsta;--daca se cere sa se afiseze random

    FUNCTION f_exista_student (
        in_id IN studenti.id%TYPE
    ) RETURN BOOLEAN;--functie ajutatoare

    FUNCTION f_are_note (
        in_id_student IN note.id_student%TYPE
    ) RETURN BOOLEAN;--functie ajutatoare

    FUNCTION f_exista_in_prieteni (
        in_id_student IN prieteni.id_student1%TYPE
    ) RETURN BOOLEAN;--functie ajutatoare

END pck_test;
/

CREATE OR REPLACE PACKAGE BODY pck_test IS

    PROCEDURE p_afiseaza_varsta IS
        p_numar_studenti  NUMBER(5);
        p_student_random  NUMBER(5);
        p_rezultat        VARCHAR(100);
    BEGIN
        SELECT
            COUNT(*)
        INTO p_numar_studenti
        FROM
            studenti;

        p_student_random := dbms_random.value(1, p_numar_studenti);
        SELECT
            id
            || ' '
            || nume
            || ' '
            || prenume
            || ' '
            || varsta
        INTO p_rezultat
        FROM
            (
                SELECT
                    id,
                    nume,
                    prenume,
                    trunc(months_between(sysdate, data_nastere) / 12)
                    || ' ani '
                    || floor(to_number(months_between(sysdate, data_nastere) -(trunc(months_between(sysdate, data_nastere) / 12)) *
                    12))
                    || ' luni '
                    || floor(to_number(sysdate - add_months(data_nastere, trunc(months_between(sysdate, data_nastere)))))
                    || ' zile. ' AS varsta,
                    ROWNUM AS rand
                FROM
                    studenti
            )
        WHERE
            rand = p_student_random;

        dbms_output.put_line(p_rezultat);
    END p_afiseaza_varsta;

    FUNCTION f_exista_student (
        in_id IN studenti.id%TYPE
    ) RETURN BOOLEAN IS
        e_std     BOOLEAN;
        p_number  NUMBER;--0 daca studentul nu exista, 1 daca exista
    BEGIN
        SELECT
            COUNT(*)
        INTO p_number
        FROM
            studenti
        WHERE
            id = in_id;

        IF p_number = 0 THEN
            dbms_output.put_line('Studentul cu id-ul '
                                 || in_id
                                 || ' nu exista in baza de date !');
            e_std := false;
      --return false;
        ELSE
            e_std := true;
      --return true;
        END IF;

        RETURN e_std;
    END f_exista_student;

    FUNCTION f_are_note (
        in_id_student IN note.id_student%TYPE
    ) RETURN BOOLEAN IS
        e_std     BOOLEAN;
        p_number  NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO p_number
        FROM
            note
        WHERE
            id_student = in_id_student;

        IF p_number = 0 THEN
            dbms_output.put_line('Studentul cu id-ul '
                                 || in_id_student
                                 || ' nu are note!');
        END IF;

        e_std := false;
        RETURN e_std;
    END f_are_note;

    FUNCTION f_exista_in_prieteni (
        in_id_student IN prieteni.id_student1%TYPE
    ) RETURN BOOLEAN IS
        e_std     BOOLEAN;
        p_number  NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO p_number
        FROM
            prieteni
        WHERE
            id_student1 = in_id_student
            OR id_student2 = in_id_student;

        IF p_number = 0 THEN
            dbms_output.put_line('Studentul cu id-ul '
                                 || in_id_student
                                 || ' nu exista in tabela de prieteni !');
        END IF;

        e_std := false;
        RETURN e_std;
    END f_exista_in_prieteni;

END pck_test;
/

DECLARE
    p_medie1  NUMBER(4, 2);
    p_medie2  NUMBER(4, 2);
BEGIN
    pck_test.p_afiseaza_varsta;
END;
/



/*2.(1p) Creati o procedura sau functie care sa returneze raportul de promovabilitate pentru materiile incluse in baza de date.*/

-------------
--Ex2
-------------

CREATE OR REPLACE PROCEDURE rata_promovabilitate IS

    p_trecuti      NUMBER := 0;
    p_total        NUMBER := 0;
    id_materie     cursuri.id%TYPE;
    titlu_materie  cursuri.titlu_curs%TYPE;
    CURSOR materii IS
    SELECT
        id,
        titlu_curs AS nume
    FROM
        cursuri;

BEGIN
    FOR i IN materii LOOP
        SELECT
            COUNT(id)
        INTO p_trecuti
        FROM
            note
        WHERE
                valoare > 4
            AND id_curs = i.id;

        SELECT
            COUNT(id)
        INTO p_total
        FROM
            note
        WHERE
            id_curs = i.id;

        dbms_output.put_line('La materia '
                             || i.nume
                             || ' raportul este '
                             || trunc(p_trecuti / p_total, 2) * 100
                             || '%');

    END LOOP;
END;
/

/*3.(3p) Creati o procedura prin care un profesor pune note la disciplinele sale. Tratati toate exceptiile corespunzatoare (5).
Creati mai intai o tabela std_profi cu campurile id,id_student,id_prof,id_curs,valoare*/
-- nu exista student
-- nu exista profesor
-- nu exista curs
-- profesoru nu preda la cursu rspectiv
-- studentu a mai fost notat la acea disciplina

DROP TABLE std_profi;
/

CREATE TABLE std_profi (
    id          NUMBER,
    id_student  NUMBER,
    id_prof     NUMBER,
    id_curs     NUMBER,
    valoare     NUMBER
);
/

CREATE OR REPLACE FUNCTION f_exista_student (
    in_id IN studenti.id%TYPE
) RETURN BOOLEAN IS
    e_std     BOOLEAN;
    p_number  NUMBER;--0 daca studentul nu exista, 1 daca exista
BEGIN
    SELECT
        COUNT(*)
    INTO p_number
    FROM
        studenti
    WHERE
        id = in_id;

    IF p_number = 0 THEN
        dbms_output.put_line('Studentul cu id-ul '
                             || in_id
                             || ' nu exista in baza de date !');
        e_std := false;--return false;
    ELSE
        e_std := true;--return true;
    END IF;

    RETURN e_std;
END f_exista_student;
/

CREATE OR REPLACE FUNCTION f_exista_profesor (
    in_id IN profesori.id%TYPE
) RETURN BOOLEAN IS
    e_std     BOOLEAN;
    p_number  NUMBER;--0 daca studentul nu exista, 1 daca exista
BEGIN
    SELECT
        COUNT(*)
    INTO p_number
    FROM
        profesori
    WHERE
        id = in_id;

    IF p_number = 0 THEN
        dbms_output.put_line('Proful cu id-ul '
                             || in_id
                             || ' nu exista in baza de date !');
        e_std := false;--return false;
    ELSE
        e_std := true;--return true;
    END IF;

    RETURN e_std;
END f_exista_profesor;
/

CREATE OR REPLACE FUNCTION f_exista_curs (
    in_id IN cursuri.id%TYPE
) RETURN BOOLEAN IS
    e_std     BOOLEAN;
    p_number  NUMBER;--0 daca studentul nu exista, 1 daca exista
BEGIN
    SELECT
        COUNT(*)
    INTO p_number
    FROM
        cursuri
    WHERE
        id = in_id;

    IF p_number = 0 THEN
        dbms_output.put_line('Cursru cu id-ul '
                             || in_id
                             || ' nu exista in baza de date !');
        e_std := false;--return false;
    ELSE
        e_std := true;--return true;
    END IF;

    RETURN e_std;
END f_exista_curs;
/

CREATE OR REPLACE PROCEDURE p_add_nota (
    in_id_profesor     IN  profesori.id%TYPE,
    in_id_student  IN  studenti.id%TYPE,
    in_id_curs     IN  cursuri.id%TYPE,
    in_valoare     IN  note.valoare%TYPE
) AS
    num_prof_curs  NUMBER;
    num_nota_stud  NUMBER;
begin
    IF f_exista_student(in_id_student) = false THEN
        dbms_output.put_line('studentu cu id-ul '
                             || in_id_student
                             || ' nu exista in baza de date !');
    
    END IF;

    IF f_exista_profesor(in_id_profesor) = false THEN
        dbms_output.put_line('profesoru cu id-ul '
                             || in_id_profesor
                             || ' nu exista in baza de date !');
        
    END IF;

    IF f_exista_curs(in_id_curs) = false THEN
        dbms_output.put_line('cursru cu id-ul '
                             || in_id_curs
                             || ' nu exista in baza de date !');
       
    END IF;

    SELECT
        COUNT(*)
    INTO num_prof_curs
    FROM
             profesori p
        JOIN didactic  d ON p.id = d.id_profesor
        JOIN cursuri   c ON d.id_curs = c.id
    WHERE
            p.id = in_id_profesor
        AND c.id = in_id_curs;

    IF num_prof_curs = 0 THEN
        dbms_output.put_line('profu si cursu nu se pupa!');
        return;
    END IF;
    SELECT
        COUNT(*)
    INTO num_nota_stud
    FROM
             studenti s
        JOIN note     n ON s.id = n.id_student
        JOIN cursuri  c ON n.id_curs = c.id
    WHERE
            s.id = in_id_student
        AND c.id = in_id_curs;

    IF num_nota_stud > 0 THEN
        dbms_output.put_line('stud are deja nota la curs!');
        return;
    END IF;
END;
/


BEGIN
    p_add_nota(10, 10, 10, 8);
end;   
/



