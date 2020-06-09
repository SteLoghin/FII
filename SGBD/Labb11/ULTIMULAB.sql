select studenti from dict_columns where column_name='BLOCKS' and studenti like 'user%';
select * from user_objects;
select * from user_tables;
select * from user_functions;
select Table_Name,TABLESPACE_NAME,NUM_ROWS,dependencies
from USER_TABLES;

-- fac niste cursoare, compar argumentul primit la procedura cu ceva gen table view indecs, package procedure, function, si in functie de asta, voi parcurge
-- cursorul ala de la prima inregistrare la ultima
select * from user_views;
select * from user_Tables;
select * from user_constraints;
select ut.table_name,constraint_name,uc.constraint_type from user_tables ut join user_constraints uc on uc.table_name=ut.table_name;
select count(*) from user_constraints where table_name='STUDENTI';
select * from user_constraints;
select * from user_indexes;
/*
--nume tabe: table_name,
-- inregistrari: num_rows
-- ca sa luam constrangerile-: select ut.table_name,constraint_name,uc.constraint_type from user_tables ut join user_constraints uc on uc.table_name=ut.table_name;
-- daca are constrangeri: fac un select count(*) from user_constraints where table_name=c2_record.table_name sau cv de genu
                                                    trebuie si UPPER(C2_RECORD.TABLE_NAME) ca daca e lower nu va lua nimic
SELECT ut.table_name,ut.num_rows,ut.nested,uc.constraint_type,acc.column_name,ui.index_name 
from user_tables ut join user_constraints uc on uc.table_name=ut.table_name join all_cons_columns acc on acc.table_name=uc.table_name 
join user_indexes ui on ui.table_name=uc.table_name;
    
asta as putea sa fac intr un if si daca are, pun eu: are constrangeri: da, nu folosesc o variabila
-- pentru nested: NESTED in user_tables
-- are indecsi
select * from user_constraints;
select * from user_types;
-- la fel ca si la constrangeri-- if da else nu
select * from user_indexes
select * from all_constraints;
---
select * from all_cons_columns where table_name='STUDENTI'
-- NUMELE COLOANELOR

select * from user_indexes;

*/
desc user_indexes;
select * from user_indexes;
select ui.Index_Name, Uniqueness, Column_Name, Column_Position
from USER_INDEXES ui join USER_IND_COLUMNS uic on ui.index_name=uic.index_name
where Table_Owner = 'STUDENT' and ui.Table_Name = 'NOTE';
 for j in (select ui.Index_Name as nume_index, Uniqueness, Column_Name, Column_Position
                    from USER_INDEXES ui join USER_IND_COLUMNS uic on ui.index_name=uic.index_name
                        where Table_Owner = 'STUDENT' and ui.Table_Name =UPPER( i.titlu)) loop

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


-----
select count(text) from all_source where name='RATA_PROMOV';
-----


declare
cursor c1 is select object_name,deterministic from user_procedures where object_type='PROCEDURE';
v_text integer;
begin
    for c1_record in c1 LOOP
        select count(text) into v_text from all_source where name=c1_record.object_name;
        dbms_output.put_line('Pentru procedura: ' || c1_record.object_name || ' numarul de linii de cod este: ' || v_text || ' , este determinista: ' || c1_record.deterministic);
    END LOOP;
end;

declare
cursor c1 is select object_name,deterministic from user_procedures where object_type='FUNCTION';
v_text integer;
begin
    for c1_record in c1 LOOP
        select count(text) into v_text from all_source where name=c1_record.object_name;
        dbms_output.put_line('Pentru functia: ' || c1_record.object_name || ' numarul de linii de cod este: ' || v_text || ' , este determinista: ' || c1_record.deterministic);
    END LOOP;
end;

declare
cursor c1 is select object_name,deterministic from user_procedures where object_type='PACKAGE';
v_text integer;
begin
    for c1_record in c1 LOOP
        select count(text) into v_text from all_source where name=c1_record.object_name;
        dbms_output.put_line('Pentru pachetul: ' || c1_record.object_name || ' numarul de linii de cod este: ' || v_text || ' , este determinist: ' || c1_record.deterministic);
    END LOOP;
end;


CREATE OR REPLACE DIRECTORY MYDIR as 'D:\STUDENT';
/
create or replace procedure export_data
is
  fisier UTL_FILE.FILE_TYPE;
  p_obj CLOB;
  p_query VARCHAR2(32767);
  p_cons INTEGER;
begin
  fisier := UTL_FILE.FOPEN ('MYDIR', 'Export.sql', 'W');
  --tabele
  for i in (select * from all_tables where owner='STUDENT')loop
    p_query := i.table_name || ', '||i.num_rows;
    
    select count(*)into p_cons from user_constraints natural join user_cons_columns where table_name = i.table_name;
    p_query := p_query|| ', Constraints: ';
    if(p_cons > 0) then
        for j in ( SELECT constraint_name, constraint_type, column_name from user_constraints natural join user_cons_columns where table_name = i.table_name) loop 
            p_query := p_query ||j.constraint_name||', '||j.constraint_type||', '||j.column_name||',';
        end loop;
    else
        p_query :=p_query||'0,';
    end if;
    p_query:=p_query ||' Indexes: ';
    for j in (select * from user_indexes where table_name=i.table_name) loop 
        p_query := p_query || j.index_name||', ';
    end loop;
    select count(*) into p_cons from user_nested_tables where table_name=i.table_name;
    if(p_cons >0) then
    p_query :=p_query||' Nested Table: yes \n';
    else
    p_query :=p_query||' Nested Table: no \n';
    end if;
    UTL_FILE.PUTF(fisier,p_query);
    end loop;
  --sf tabele
  --views
  for i in (select View_Name, text, Text_Length from USER_VIEWS) loop 
    p_query :=i.view_name  ||', "'||i.text||'", '||i.text_length||'\n';
    UTL_FILE.PUTF(fisier,p_query);
 end loop;
 --sf views
 --indecsi
 for i in (select ui.Index_Name, Column_Name, Column_Position from USER_INDEXES ui join USER_IND_COLUMNS uic on ui.index_name=uic.index_name) loop --in join o sa fie doar studetul owner
    p_query := i.index_name||', '||i.column_name||', '||i.column_position;
    UTL_FILE.PUTF(fisier,p_query);
    end loop;
--sf indecsi
--package

  UTL_FILE.FCLOSE (fisier);
END;
/
exec export_data;



exec statistici('view');
