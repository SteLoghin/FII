set serveroutput on;

/*
    Loghin Alexandru-Stelian, grupa B5
*/

-- functie ajutatoare cu care voi concatena numele cursului daca contine mai mult de un cuvant
create or replace function concateneaza_cuvinte(cuvant IN varchar2)
    RETURN VARCHAR2 AS
    v_nr       INTEGER;
    v_copie    VARCHAR2(100);
    v_rezultat VARCHAR2(100) := '';
    v_index    integer;
BEGIN
    v_copie := cuvant;
    --expresie regulata ca sa imi numere cate cuvinte sunt
    v_nr := regexp_count(v_copie, '\w+');
    -- fac match pe spatiu si concatenez fiecare cuvant din string-ul dat ca parametru
    for v_index in 1..v_nr
        LOOP
            v_rezultat := v_rezultat || REGEXP_SUBSTR(v_copie, '[^ ]+', 1, v_index);
        END LOOP;
    return v_rezultat;
END;

-- testez sa vad ca merge
declare
    v_cuvant VARCHAR2(100);
    v_rez    VARCHAR2(100);
begin
    v_cuvant := 's t e r n o c l e i d o m a s t o i d i a n';
    v_rez := concateneaza_cuvinte(v_cuvant);
    dbms_output.put_line(v_rez);
end;



-- m-am ghidat dupa exercitiul dat de dumneavoastra 
create or replace procedure catalog_materie(v_curs_id IN cursuri.id%type)
    IS
    v_cursor_id         NUMBER;
    v_CreateTableString VARCHAR2(1024);
    v_NumRows           Integer;
    v_nume_curs         varchar2(200);
    cursor c1
        is
        select valoare, data_notare, nume, prenume, nr_matricol
        from studenti s
                 join note n on s.id = n.id_student
        where id_curs = v_curs_id;
BEGIN
    -- iau titlul cursului intr-o variabila pe baza id-ului dat ca parametru functiei
    select titlu_curs into v_nume_curs from cursuri where id = v_curs_id;
    -- in caz ca titlu cursului contine mai mult de un cuvant, apelez functia de mai sus si concatenez cuvintele
-- procedura fara concatenarea cuvintelor va merge doar pentru cursurile care au doar un cuvant cum ar fi: Logica si Matematica, pentru celelalte nu
-- cu functia facuta mai sus va merge pe orice titlu de curs
-- procedura merge pe toate titlurile de curs
    if (regexp_count(v_nume_curs, '\w+') > 1) then
        v_nume_curs := concateneaza_cuvinte(v_nume_curs);
    end if;
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;
    v_createTableString := 'CREATE TABLE  ' || v_nume_curs || '  (
        Nota    NUMBER(2) NOT NULL,
        Data_notare DATE NOT NULL,
        Nume_Student VARCHAR2(25),
        Prenume_Student VARCHAR2(50),
        Nr_matricol VARCHAR2(6 BYTE)
        )';
    DBMS_SQL.PARSE(v_Cursor_ID, v_CreateTableString, DBMS_SQL.NATIVE);
    v_NumRows := DBMS_SQL.EXECUTE(v_cursor_Id);
    FOR c1_curent in c1
        loop
            v_cursor_ID := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(v_Cursor_ID, 'INSERT INTO ' || v_nume_curs || '  (Nota,  Data_notare, Nume_Student, Prenume_Student, Nr_matricol) 
         VALUES (:Nota,:Data_notare,:Nume_Student,:Prenume_Student,:Nr_matricol)', DBMS_SQL.NATIVE);
            DBMS_SQL.BIND_VARIABLE(v_Cursor_ID, ':Nota', c1_curent.valoare);
            DBMS_SQL.BIND_VARIABLE(v_Cursor_ID, ':Data_notare', c1_curent.data_notare);
            DBMS_SQL.BIND_VARIABLE(v_Cursor_ID, ':Nume_Student', c1_curent.nume);
            DBMS_SQL.BIND_VARIABLE(v_Cursor_ID, ':Prenume_Student', c1_curent.prenume);
            DBMS_SQL.BIND_VARIABLE(v_Cursor_ID, ':Nr_matricol', c1_curent.nr_matricol);
            v_NumRows := DBMS_SQL.EXECUTE(v_cursor_id);
            dbms_sql.close_cursor(v_cursor_id);
        end loop;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955
        THEN
            RAISE;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: Table Already Exists!');
        END IF;
        dbms_sql.close_cursor(v_cursor_id);
        COMMIT;
end catalog_materie;
/

-- aleg un id din tabela cursuri si execut procedura pentru un id, testez pentru diferite titluri de cursuri, care au doar un cuvant si care au mai multe
-- dau copy paste la numele tabelei nou-create din user-Tables si fac select unde gasesc catalogul la materia respectiva
-- nu imi recunoste diacritcile sql developer pe acest user, pe alt user mi le recunoaste doar pe unele
select *
from cursuri;
EXEC catalog_materie(1);
select *
from user_Tables;
select *
from LOGIC?;
EXEC catalog_materie(5);
select *
from user_Tables;
select *
from SISTEMEDEOPERARE
order by 3 asc;
EXEC catalog_materie(3);
select *
from user_Tables;
select *
from INTRODUCERE?NPROGRAMARE;
EXEC catalog_materie(10);
drop table BAZEDEDATE;
select *
from BAZEDEDATE;
select *
from user_TABLES;
EXEC catalog_materie(12);
select *
from user_TABLES;
select *
from ALGORITMICAGRAFURILOR;
EXEC catalog_materie(24);
select * from user_Tables;
select  * from RE?ELEPETRI?IAPLICA?II;
EXEC catalog_materie(13);
select * from user_Tables;
select * from TEHNOLOGIIWEB;
EXEC catalog_materie(15);
select * from INGINERIAPROGRAM?RII;