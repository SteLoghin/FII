--Exemplu din documentatie
--din contul de sys: GRANT EXECUTE ON UTL_FILE TO STUDENT;
--din contul de sys: GRANT CREATE ANY DIRECTORY TO STUDENT;
--din contul student: CREATE OR REPLACE DIRECTORY MYDIR as 'C:\Baze de date - cursuri\Practica SGBD\2019-2020\lab8';
create or replace procedure p_create_document 
is
  v_fisier UTL_FILE.FILE_TYPE;
begin
  v_fisier:=UTL_FILE.FOPEN('MYDIR','myfile.txt','W');
  UTL_FILE.PUTF(v_fisier,'abcdefg');
  UTL_FILE.FCLOSE(v_fisier);
end;
/
exec p_create_document;


/*1. Creati o procedura care sa exporte toate datele dintr-o baza de date: la apelul acestuia se va construi un fisier, preferabil
cu extensia SQL in care vor fi trecute toate datele, functiile, procedurile, viewurile si triggerele pentru care un utilizator este owner.*/ 
CREATE OR REPLACE DIRECTORY MYDIR AS 'C:\Baze de date - cursuri\Practica SGBD\2019-2020\lab8';
/
create or replace procedure export_data
is
  fisier UTL_FILE.FILE_TYPE;
  p_obj CLOB;
  p_query VARCHAR2(300);
begin
  fisier := UTL_FILE.FOPEN ('MYDIR', 'Export.sql', 'W');
  
  FOR i IN (SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE='TABLE') LOOP
    SELECT DBMS_METADATA.GET_DDL(i.OBJECT_TYPE,i.OBJECT_NAME) 
    INTO p_obj 
    FROM dual;
    --dbms_output.put_line(myObject);
    UTL_FILE.PUT_LINE(fisier,p_obj);
  END LOOP;
  
  FOR i IN (SELECT DBMS_METADATA.GET_DDL('INDEX', INDEX_NAME) as METADATA_INDEX FROM USER_INDEXES) LOOP
    UTL_FILE.PUT_LINE(fisier,i.METADATA_INDEX);
    --dbms_output.put_line(i.METADATA_INDEX);
  END LOOP;
  
  FOR i IN (SELECT text FROM user_views) LOOP
    UTL_FILE.PUT_LINE(fisier,i.TEXT);
    --dbms_output.put_line(i.TEXT);
  END LOOP;
  
  FOR i IN (SELECT text FROM user_source) LOOP
    UTL_FILE.PUT_LINE(fisier,i.TEXT);
    --dbms_output.put_line(i.TEXT);
  END LOOP;
 
  FOR i IN (SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE='TABLE') LOOP
    p_query:='select /*insert*/ * from '||i.OBJECT_NAME;
    DBMS_OUTPUT.PUT_LINE(p_query);
  END LOOP;
 
  UTL_FILE.FCLOSE (fisier);
END;
/
exec export_data;


/*2.Creati o procedura stocata care sa exporte tabelele studenti si prieteni 
pentru utilizatorul curent intr-un format la alegere (mai putin SQL - adica fara sa generati inserturi care ar popula automat tabelele).*/
CREATE OR REPLACE DIRECTORY LAB7 AS 'C:\Baze de date - cursuri\Practica SGBD\2019-2020\lab8';
/
create or replace procedure export_tables
is
  fisier UTL_FILE.FILE_TYPE;
  p_obj CLOB;
begin
  fisier := UTL_FILE.FOPEN ('LAB7', 'Tables.txt', 'W');
  
  FOR i IN (SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE='TABLE' and object_name in ('STUDENTI','PRIETENI')) LOOP
    SELECT DBMS_METADATA.GET_DDL(i.OBJECT_TYPE,i.OBJECT_NAME) 
    INTO p_obj 
    FROM dual;
    --dbms_output.put_line(myObject);
    UTL_FILE.PUT_LINE(fisier,p_obj);
  END LOOP;
  UTL_FILE.FCLOSE (fisier);
END;
/
exec export_tables;


/*3. Creati o procedura care sa stearga tabelele din schema utilizatorului cu care sunteti logat.*/
create or replace procedure delete_tables
is
  cursor c1 is 
  select object_type,object_name 
  from user_objects 
  where object_type = 'TABLE';
begin
  for c1_record in c1 loop
    execute immediate ('drop '||c1_record.object_type||' ' ||c1_record.object_name||' cascade constraints');
  end loop;
end;
/
exec delete_tables;

--Urmatoarele exemple sunt cateva interogari simple care ilustreaza lucrul efectiv cu dictionarul de date pentru schema unui utilizator

/*4.Sa se afiseze toate tabele din baza de date care incep cu litera S, impreuna cu numele tablespaceului unde acestea sunt
continute si cu nr de inregistrari continute. Sa se afiseze si daca tabela are si un back-up de la ultima modificare.*/
select Table_Name,TABLESPACE_NAME,NUM_ROWS,dependencies
from USER_TABLES
where Table_Name like 'S%';
--all_tables are tabele suplimentare, nu doar cele ale utilizatorului
select Table_Name,TABLESPACE_NAME,NUM_ROWS,Backed_Up
from ALL_TABLES
where Table_Name like 'S%';

/*5.Pentru tabela DIDACTIC, vizualizati constringerile create si coloanele asociate folosind tabelele USER_CONSTRAINTS 
si USER_CONS_COLUMNS, folosind o singura interogare!! */
select uc.owner,uc.constraint_name,constraint_type,column_name,position
from user_constraints uc inner join user_cons_columns ucc on uc.table_name=ucc.table_name and uc.constraint_name=ucc.constraint_name
where uc.table_name='DIDACTIC'; 

SELECT ut.table_name as nume_tabel,ut.num_rows as nr_randuri,nested,uc.constraint_type as tip_constrangere,acc.column_name as nume_coloana,ui.index_name as nume_index
from user_tables ut join user_constraints uc on uc.table_name=ut.table_name join all_cons_columns acc on acc.table_name=uc.table_name 
join user_indexes ui on ui.table_name=uc.table_name;

select * from user_objects;
select ut.table_name as nume_tabel,ut.num_rows as nr_randuri,nested,uc.constraint_type as tip_constrangere,ucc.column_name as nume_coloana,ui.index_name as nume_index
from user_Tables ut join user_indexes ui  on ut.table_name=ui.table_name join user_constraints uc on ut.table_name=uc.table_name inner join user_cons_columns ucc on uc.table_name=ucc.table_name and uc.constraint_name=ucc.constraint_name
where ut.table_name='STUDENTI';

declare
muie varchar2(100);
begin
select object_type into muie from all_objects where object_name='STUDENTI' and rownum=1;
dbms_output.put_line(muie);
end;

select column_name from user_cons_columns;



/*6.Afisati toti indecsii din tabela NOTE, impreuna cu coloanele indexate si verificati care indecsi sunt unici si care nu.*/
select ui.Index_Name, Uniqueness, Column_Name, Column_Position
from USER_INDEXES ui join USER_IND_COLUMNS uic on ui.index_name=uic.index_name
where Table_Owner = 'STUDENT' and ui.Table_Name = 'NOTE';


/*7.Sa se afiseze numele campurilor, tipul si dimensiunea pentru tabela 'PRIETENI'.*/
select Column_Name, Data_Type, Data_Length
from USER_TAB_COLUMNS
where Table_Name = 'PRIETENI';

/*8.Afisati pentru toate view-urile din baza de date lungimea acestora, impreuna cu textul aferent.*/
select View_Name, text, Text_Length
from USER_VIEWS;

/*9.Adaugati un comentariu la campul NUME din tabela STUDENTI. Afisati apoi acel comentariu. Eliminati apoi comentariul.*/
comment on column studenti.nume is 'Numele de familie al studentului';
/
select Comments
from USER_COL_COMMENTS
where Table_Name = 'STUDENTI' and Column_Name = 'NUME';
/
comment on column studenti.nume is '';





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
