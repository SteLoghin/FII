set serveroutput on;
/*
    Loghin Alexandru-Stelian, grupa B5
*/
-- creez variabile care corespund fiecarei coloane din tabelul note si in ele voi pune fiecare valoare din o coloana pe un rand
-- practic iau linie cu linie de la inceput pana la final
-- v_tupla este linia ce va fi scrisa in fisierul .csv, concatenez la fiecare valoare o virgula si la urma pun \n- newline pentru a putea continua sa adaug pe urmatoarea linie
create or replace procedure CSV_Export
    is
    v_id          NUMBER(38, 0);
    v_id_student  NUMBER(38, 0);
    v_id_curs     NUMBER(38, 0);
    v_valoare     NUMBER(2, 0);
    v_data_notare DATE;
    v_created_at  DATE;
    v_updated_at  DATE;
    v_count       integer;
    v_fisier      UTL_FILE.FILE_TYPE;
    v_tupla       varchar2(200);
    i             integer;
begin
    v_fisier := UTL_FILE.FOPEN('MYDIR', 'note.csv', 'W');
    select count(*) into v_count from note;
    for i in 1..v_count
        loop
            select id, id_student, id_curs, valoare, data_notare, created_at, updated_at
            into v_id,v_id_student,v_id_curs,v_valoare,v_data_notare,v_created_at,v_updated_at
            from note
            where id = i;
            v_tupla := v_id || ',' || v_id_student || ',' || v_id_curs || ',' || v_valoare || ',' || v_data_notare ||
                       ',' || v_created_at || ',' || v_updated_at || '\n';
            UTL_FILE.PUTF(v_fisier, v_tupla);
        end loop;
    UTL_FILE.FCLOSE(v_fisier);
end;

exec CSV_EXPORT;

delete
from note;

-- citesc din fisier cate o linie
-- fac match cu un regex pe virgula, returnand fiecare valoare existenta in csv de pe o linie
create or replace procedure CSV_IMPORT
    is
    v_id          NUMBER(38, 0);
    v_id_student  NUMBER(38, 0);
    v_id_curs     NUMBER(38, 0);
    v_valoare     NUMBER(2, 0);
    v_data_notare DATE;
    v_created_at  DATE;
    v_updated_at  DATE;
    v_tupla       varchar2(70);
    v_fisier      UTL_FILE.FILE_TYPE;
begin
    v_fisier := UTL_FILE.FOPEN('MYDIR', 'note.csv', 'R');
    LOOP
        begin
            UTL_FILE.GET_LINE(v_fisier, v_tupla);
            -- v_tupla este linie pe care o "sparg", fac match pe virgula, al treilea parametru indica de unde incepe sa imi returneze cuvantul(pozitia in cuvant)
            -- in acest caz e 1 pentru a putea citi de la inceput
            -- al patrulea parametru reprezinta pozitia unui cuvant in linia "sparta"
            -- cum o tupla din tabelul note are 7 coloane, pozitiile in linie vor fi de la 1 la 7
            v_id := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 1);
            v_id_student := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 2);
            v_id_curs := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 3);
            v_valoare := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 4);
            v_data_notare := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 5);
            v_created_at := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 6);
            v_updated_at := REGEXP_SUBSTR(V_tupla, '[^,]+', 1, 7);
            -- inserez in tabelul note
            insert into note
            values (v_id, v_id_student, v_id_curs, v_valoare, v_data_notare, v_created_at, v_updated_at);
            -- la final dupa ce nu mai are ce sa citeasca va fi aruncata o exceptie, mai jos o prind si dau doar exit la program
            -- pentru a fi sigur ca totul se va termina ok
        exception
            when no_data_found then
                exit;
        end;
    end loop;
    UTL_FILE.FCLOSE(v_fisier);
end;

exec CSV_IMPORT;

select *
from note
order by 1 asc;
