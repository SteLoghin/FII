set serveroutput on;

/*
    Loghin Alexandru-Stelian, grupa B5
*/
/*1.(1p) Avand exemplele trimise, creati un pachet pentru 3 din functiile trimise. Apelati apoi una din aceste functii, in
cadrul pachetului.*/

create or replace package pck_lab3
is
    procedure p_afiseaza_varsta;
    function f_exista_student(IN_id in studenti.id%type) return boolean;
    function f_are_note(IN_id_student in note.id_student%type) return boolean;
end pck_lab3;
/
set serveroutput on;
create or replace package body pck_lab3
is
    procedure p_afiseaza_varsta
        is
        p_numar_studenti number(5);
        p_student_random number(5);
        p_rezultat       VARCHAR(100);
    begin
        select count(*)
        into p_numar_studenti
        from studenti;
        p_student_random := dbms_random.value(1, p_numar_studenti);
        select id || ' ' || nume || ' ' || prenume || ' ' || varsta
        into p_rezultat
        from (select id,
                     nume,
                     prenume,
                     trunc(months_between(sysdate, data_nastere) / 12) || ' ani ' ||
                     floor(to_number(months_between(sysdate, data_nastere)
                                         (trunc(months_between(sysdate, data_nastere) / 12)) * 12)) || ' luni ' ||
                     floor(to_number(
                                 sysdate - add_months(data_nastere, trunc(months_between(sysdate, data_nastere))))) ||
                     ' zile. ' as varsta,
                     rownum    as rand
              from studenti)
        where rand = p_student_random;
        dbms_output.put_line(p_rezultat);
    end p_afiseaza_varsta;

    function f_exista_student(IN_id in studenti.id%type)
        return boolean
        is
        e_std    boolean;
        p_number number;--0 daca studentul nu exista, 1 daca exista
    begin
        select count(*) into p_number from studenti where id = IN_id;
        if p_number = 0 then
            dbms_output.put_line('Studentul cu id-ul ' || IN_id || ' nu exista in baza de date !');
            e_std := false;
            --return false;
        else
            e_std := true;
            --return true;
        end if;
        return e_std;
    end f_exista_student;

    function f_are_note(IN_id_student in note.id_student%type)
        return boolean
        is
        e_std    boolean;
        p_number number;
    begin
        select count(*) into p_number from note where id_student = IN_id_student;
        if p_number = 0 then
            dbms_output.put_line('Studentul cu id-ul ' || IN_id_student || ' nu are note!');
        end if;
        e_std := false;
        return e_std;
    end f_are_note;

end pck_lab3;


--apelarea
begin
    pck_lab3.p_afiseaza_varsta;
end;


--promovati supra numarul total de studenti
/*2.(1p) Creati o procedura sau functie care sa returneze raportul de promovabilitate pentru materiile incluse in baza de date.*/
CREATE OR REPLACE PROCEDURE rata_promov IS
    v_trecuti     integer;
    v_total       integer;
    v_titlu_curs  cursuri.titlu_curs%TYPE;
    v_id_curs     integer;
    v_rata_promov integer;
    -- fac un cursor unde iau id-ul si numele cursurilor
    CURSOR materii IS
        SELECT id,
               titlu_curs
        FROM cursuri;

BEGIN
    -- in loop calculez pentru fiecare materie rata de promovabilitate cu ajutorul cursorului de mai sus
    FOR i IN materii
        LOOP
            select count(id) into v_trecuti from note n where id_curs = i.id and valoare > 4;

            select count(id) into v_total from note n where id_curs = i.id;
            v_rata_promov := trunc((v_trecuti / v_total) * 100, 2);
            dbms_output.put_line(
                        'Pentru materia: ' || i.titlu_curs || ' rata de promovabilitate este: ' || v_rata_promov ||
                        ' . ');
        END LOOP;
END;
/

exec rata_promov;


/*3.(3p) Creati o procedura prin care un profesor pune note la disciplinele sale. Tratati toate exceptiile corespunzatoare (5).
Creati mai intai o tabela std_profi cu campurile id,id_student,id_prof,id_curs,valoare*/
-- Exceptii: nu exista studentul, cursul nu exista, profesorul nu exista, profesorul nu preda materia, studentul are nota la acea materie deja
drop table std_profi;
/
create table std_profi
(
    id         number,
    id_student number,
    id_prof    number,
    id_curs    number,
    valoare    number
);
/


-- functie data de dumneavoastra cand am facut laboratorul face2face
create or replace function f_exista_student(IN_id in studenti.id%type)
    return boolean
    is
    e_std    boolean;
    p_number number;--0 daca studentul nu exista, 1 daca exista
begin
    select count(*) into p_number from studenti where id = IN_id;
    if p_number = 0 then
        dbms_output.put_line('Studentul cu id-ul ' || IN_id || ' nu exista in baza de date !');
        e_std := false;--return false;
    else
        e_std := true;--return true;
    end if;
    return e_std;
end f_exista_student;


create or replace function f_exista_profesor(IN_id in profesori.id%type)
    return boolean
    is
    e_prof   boolean;
    p_number number;--0 daca studentul nu exista, 1 daca exista
begin
    select count(*) into p_number from profesori where id = IN_id;
    if p_number = 0 then
        dbms_output.put_line('Profesorul cu id-ul ' || IN_id || ' nu exista in baza de date !');
        e_prof := false;--return false;
    else
        e_prof := true;--return true;
    end if;
    return e_prof;
end f_exista_profesor;


create or replace function f_exista_curs(IN_id in cursuri.id%type)
    return boolean
    is
    e_curs   boolean;
    p_number number;--0 daca studentul nu exista, 1 daca exista
begin
    select count(*) into p_number from cursuri where id = IN_id;
    if p_number = 0 then
        dbms_output.put_line('Cursul cu id-ul ' || IN_id || ' nu exista in baza de date !');
        e_curs := false;--return false;
    else
        e_curs := true;--return true;
    end if;
    return e_curs;
end f_exista_curs;


create or replace function f_prof_preda_curs(IN_id_prof in profesori.id%type, IN_id_curs in cursuri.id%type)
    return boolean
    is
    e_pereche boolean;
    p_number  number;
begin
    select count(*)
    into p_number
    from cursuri c
             join didactic d on c.id = d.id_curs
             join profesori p on p.id = d.id_profesor
    where c.id = IN_id_curs
      and p.id = IN_id_prof;
    if p_number = 0 then
        dbms_output.put_line('Profesorul cu id-ul ' || in_id_prof || ' nu preda la materia cu id-ul ' || in_id_curs);
        e_pereche := false;
    else
        e_pereche := true;
    end if;
    return e_pereche;
end f_prof_preda_curs;


create or replace function f_student_nota_curs(IN_id_student in studenti.id%type, IN_id_curs in cursuri.id%type)
    return boolean
    is
    e_pereche boolean;
    p_number  number;
begin
    select count(*) into p_number from note where id_curs = IN_ID_CURS and id_student = IN_ID_STUDENT;
    if p_number = 1 then
        dbms_output.put_line(
                    'Studentul cu id-ul ' || in_id_student || ' are deja nota la materia cu id-ul ' || in_id_curs);
        e_pereche := true;
    else
        e_pereche := false;
    end if;
    return e_pereche;
end f_student_nota_curs;


-- creez o secventa pentru a ma ajuta la inseratul mai usor pentru id din std_profi
drop sequence seq_std_profi;

create sequence seq_std_profi start with 1;

-- creez triggerul ca sa pot simula un auto increment
create or replace trigger std_profi
    before insert
    on std_profi
    for each row
begin
    select seq_std_profi.nextval into :new.id from dual;
end;


-- functiile de mai sus sunt ajutatoare, le folosesc in procedura de mai jos pentru a trata toate exceptiile posibile
create or replace procedure profesor_pune_nota(IN_id_student in number, IN_id_prof in number, IN_id_curs in number,
                                               IN_valoare in number)
    is
    v_id_student number;
    v_id_prof    number;
    v_id_curs    number;
    v_valoare    number;
begin
    v_id_student := IN_id_student;
    v_id_prof := IN_id_prof;
    v_id_curs := IN_id_curs;
    v_valoare := IN_valoare;
    -- in caz ca toate conditiile de mai jos sunt adevarate, voi insera in std_profi valorile primite ca parametru la procedura aceasta
    -- nu mai adaug id deoarece am creat o secventa si un trigger cu care simulez un auto increment pentru id
    if f_exista_student(v_id_student) = true then
        if f_exista_profesor(v_id_prof) = true then
            if f_exista_curs(v_id_curs) = true then
                if f_student_nota_curs(v_id_student, v_id_curs) = true then
                    if f_prof_preda_curs(v_id_prof, v_id_curs) = true then
                        insert into std_profi(id_student, id_prof, id_curs, valoare)
                        values (v_id_student, v_id_prof, v_id_curs, v_valoare);
                    end if;
                end if;
            end if;
        end if;
    end if;
end;


-- testez  sa vad ca functiile ajutatoare functioneaza si ca procedura face ce trebuie
exec profesor_pune_nota(9921,545,60,8);
exec profesor_pune_nota(124,525,606,6);
exec profesor_pune_nota(124,5,10,10);
exec profesor_pune_nota(20,12,5,8);
exec profesor_pune_nota(20,12,5,8);


select *
from std_profi;


create or replace procedure statistici(nume_obiect varchar2) as
v_nume_index varchar2(100);
v_index_unic varchar2(30);
v_nume_coloana varchar2(50);
v_flag integer;
v_raspuns varchar2(10);
v_index integer;
v_nume_curs varchar2(100);
v_raspuns_index varchar2(10); 
v_cursuri_count integer;
    cursor c1 is select view_name,text,text_length from user_views;
    CURSOR C2 is
SELECT ut.table_name as nume_tabel,ut.num_rows as nr_randuri,nested,uc.constraint_type as tip_constrangere,acc.column_name as nume_coloana,ui.index_name as nume_index
from user_tables ut join user_constraints uc on uc.table_name=ut.table_name join all_cons_columns acc on acc.table_name=uc.table_name 
join user_indexes ui on ui.table_name=uc.table_name;
begin
        if(nume_obiect ='view' or nume_obiect='View')then
            for c1_record in c1 LOOP
            dbms_output.put_line('Numele view-ului este: ' || c1_record.view_name || ' textul view-ului este: ' || c1_record.text || ' iar lungimea textului este: ' || c1_record.text_length);
            end loop;
    elsif(nume_obiect='Tabel' or nume_obiect='tabel') then
            for c2_record in c2 LOOP
                select count(*) into v_flag from user_constraints where table_name=UPPER(c2_record.nume_tabel);
                if(v_flag=0) then
                    v_raspuns:='Nu';
                else
                    v_raspuns:='Da';
                end if;
                select count(*) into v_index from user_indexes where table_name=UPPER(c2_record.nume_tabel);
                if(v_index=0) then
                    v_raspuns_index:='Nu';
                else
                    v_raspuns_index:='Da';
                end if;
                dbms_output.put_line('Numele tabelului este: ' || c2_record.nume_tabel || ' are: ' || c2_record.nume_tabel || ' randuri, este nested: ' || c2_record.nested
                || ' tipul constrangerii: ' || 
                c2_record.tip_constrangere || ' coloanele implicate: ' || c2_record.nume_coloana || ' numele indexului este: ' || c2_record.nume_index);
            end loop;
    elsif(nume_obiect='Index' or nume_obiect='index') then
            dbms_output.put_line('hah');
        else
        dbms_output.put_line('introduceti unul dintre parametrii urmatori: View,Tabel');
        end if;
end;
set serveroutput on;
exec statistici('view');










