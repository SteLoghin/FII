--1.Crearea in mod dinamic a unei tabele
declare
   v_cursor_id INTEGER;
   v_ok INTEGER;
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id, 'CREATE TABLE TEST(id NUMBER(2,2), val VARCHAR2(30))', DBMS_SQL.NATIVE);
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end; 
select * from cursuri where id=1;

--2.Afisati profesorii din baza de date in ordinea prenumelor acestora
create or replace procedure afiseaza_profesori(camp IN varchar2) as
   v_cursor_id INTEGER;
   v_ok INTEGER;
   
   v_id_prof int;
   v_nume_prof varchar2(15);
   v_prenume_prof varchar2(30);
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id, 'SELECT id, nume, prenume FROM profesori ORDER BY '||camp, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_id_prof); 
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_nume_prof,15); 
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_prenume_prof,30);   
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);
  
  LOOP 
     IF DBMS_SQL.FETCH_ROWS(v_cursor_id)>0 THEN 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_id_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_nume_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_prenume_prof); 
 
         DBMS_OUTPUT.PUT_LINE(v_id_prof || '   ' || v_nume_prof || '    ' || v_prenume_prof);
      ELSE 
        EXIT; 
      END IF; 
  END LOOP;   
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end;
/
exec afiseaza_profesori('prenume');


--3.Se listeaza doar numele coloanelor unei tabele (in cazul de fata studenti)
DECLARE
  v_cursor_id NUMBER;
  v_ok        NUMBER;
  v_rec_tab     DBMS_SQL.DESC_TAB;
  v_nr_col     NUMBER;
  v_total_coloane     NUMBER; 
BEGIN
  v_cursor_id  := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id , 'SELECT * FROM studenti', DBMS_SQL.NATIVE);
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id );
  DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_total_coloane, v_rec_tab);

  v_nr_col := v_rec_tab.first;
  IF (v_nr_col IS NOT NULL) THEN
    LOOP
      DBMS_OUTPUT.PUT_LINE(v_rec_tab(v_nr_col).col_name);
      v_nr_col := v_rec_tab.next(v_nr_col);
      EXIT WHEN (v_nr_col IS NULL);
    END LOOP;
  END IF;
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
END;
/


/*1.(4pt) Pentru fiecare student in parte construiti-i carnetul de note prin
intermediul unui script PL/SQL. Verificati carnetul propriu de note pentru a
vedea ce campuri sunt necesare. Tabelul creat va avea ca si nume numarul
matricol al studentului (pentru unicitate).*/

CREATE OR REPLACE PROCEDURE carnet_de_note (p_nr_matricol IN studenti.nr_matricol%TYPE)
IS
  v_CursorID NUMBER;--variabila careia i se atribuie valoarea de catre open cursor
  v_CreateTableString VARCHAR2(1024);--SQL stocat ca sir pentru inserarea de valori
  v_NUMRows INTEGER;--numar de randuri prelucrate
  
  CURSOR c1
  IS
    SELECT valoare,data_notare,titlu_curs,grad_didactic,p.nume,p.prenume
    FROM note n JOIN cursuri c ON n.id_curs = c.id_curs JOIN didactic d ON c.id_curs = d.id_curs JOIN profesori p ON d.id_prof = p.id_prof
    WHERE n.nr_matricol = p_nr_matricol;
BEGIN
  v_CursorID := DBMS_SQL.OPEN_CURSOR;--se obtine identificatorul cursorului
  
  v_CreateTableString := 'CREATE TABLE s' || p_nr_matricol || ' (
    Disciplina VARCHAR2(64) NOT NULL,
    Profesor VARCHAR2(128) NOT NULL,
    Felul_Probei VARCHAR2(32),
    Nota NUMBER(2) NOT NULL,
    Data_Examinarii DATE NOT NULL
    )';
  
  DBMS_SQL.PARSE(v_CursorID, v_CreateTableString, DBMS_SQL.NATIVE);--depistarea erorilor sintactice(se analizeaza instructiunea SQL)
  
  v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);--executarea instructiunii SQL
  
  DBMS_SQL.CLOSE_CURSOR(v_CursorID);--inchiderea cursorului
  
  FOR c1_record IN c1 LOOP
    v_CursorID := DBMS_SQL.OPEN_CURSOR;
    
    DBMS_SQL.PARSE(v_CursorID, 'INSERT INTO s' || p_nr_matricol || ' (Disciplina, Profesor, Nota, Data_Examinarii) 
		VALUES (:Disciplina, :Profesor, :Nota, :Data_Examinarii)', DBMS_SQL.NATIVE);
    
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Disciplina', c1_record.titlu_curs);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Profesor', c1_record.grad_didactic || ' ' || TRIM(c1_record.nume) || ' ' || TRIM(c1_record.prenume));
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Nota', c1_record.valoare);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Data_Examinarii', c1_record.data_notare);
    
    v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);--executarea instructiunii SQL
    
    DBMS_SQL.CLOSE_CURSOR(v_CursorID);
  END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955
        THEN
          RAISE;
        ELSE
          DBMS_OUTPUT.PUT_LINE('Error: Table Already Exists!');
      END IF;
    
    DBMS_SQL.CLOSE_CURSOR(v_CursorID);
    COMMIT;
END carnet_de_note;
/
--apelul procedurii
/
DECLARE
  CURSOR c1 IS
  SELECT nr_matricol
  FROM studenti;
BEGIN
  FOR c1_record IN c1 LOOP
    carnet_de_note(c1_record.nr_matricol);
  END LOOP;
END;
/
select * from s111;


/*4. Pentru fiecare student in parte construiti-i carnetul de note prin
intermediul unui script PL/SQL. Tabelul creat va avea ca si nume id-ul studentului (pentru unicitate).*/
CREATE OR REPLACE PROCEDURE carnet_de_note (p_id IN studenti.nr_matricol%TYPE)
IS
  v_CursorID NUMBER;--variabila careia i se atribuie valoarea de catre open cursor
  v_CreateTableString VARCHAR2(1024);--SQL stocat ca sir pentru inserarea de valori
  v_NUMRows INTEGER;--numar de randuri prelucrate
  
  CURSOR c1
  IS
    SELECT valoare,data_notare,titlu_curs,grad_didactic,p.nume,p.prenume
    FROM note n JOIN cursuri c ON n.id_curs = c.id JOIN didactic d ON c.id = d.id_curs JOIN profesori p ON d.id_profesor = p.id
    WHERE n.id_student = p_id;
BEGIN
  v_CursorID := DBMS_SQL.OPEN_CURSOR;--se obtine identificatorul cursorului
  
  v_CreateTableString := 'CREATE TABLE s' || p_id || ' (
    Disciplina VARCHAR2(64) NOT NULL,
    Profesor VARCHAR2(128) NOT NULL,
    Felul_Probei VARCHAR2(32),
    Nota NUMBER(2) NOT NULL,
    Data_Examinarii DATE NOT NULL
    )';
  
  DBMS_SQL.PARSE(v_CursorID, v_CreateTableString, DBMS_SQL.NATIVE);--depistarea erorilor sintactice(se analizeaza instructiunea SQL)
  
  v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);--executarea instructiunii SQL
  
  DBMS_SQL.CLOSE_CURSOR(v_CursorID);--inchiderea cursorului
  
  FOR c1_record IN c1 LOOP
    v_CursorID := DBMS_SQL.OPEN_CURSOR;
    
    DBMS_SQL.PARSE(v_CursorID, 'INSERT INTO s' || p_id || ' (Disciplina, Profesor, Nota, Data_Examinarii) 
		VALUES (:Disciplina, :Profesor, :Nota, :Data_Examinarii)', DBMS_SQL.NATIVE);
    
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Disciplina', c1_record.titlu_curs);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Profesor', c1_record.grad_didactic || ' ' || TRIM(c1_record.nume) || ' ' || TRIM(c1_record.prenume));
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Nota', c1_record.valoare);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':Data_Examinarii', c1_record.data_notare);
    
    v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);--executarea instructiunii SQL
    
    DBMS_SQL.CLOSE_CURSOR(v_CursorID);
  END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955
        THEN
          RAISE;
        ELSE
          DBMS_OUTPUT.PUT_LINE('Error: Table Already Exists!');
      END IF;
    
    DBMS_SQL.CLOSE_CURSOR(v_CursorID);
    COMMIT;
END carnet_de_note;
/
--apelul procedurii
/
declare
  cursor c1 is select id from studenti;
begin
  for c1_record in c1 loop
    carnet_de_note(c1_record.id);
  end loop;
end;
/
select * from s111;
