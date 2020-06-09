DROP PROCEDURE CREATE_TABLE;
DROP PROCEDURE DROP_TABLE;
DROP PROCEDURE initiate_order;
DROP PROCEDURE delete_order;
/
drop table orders;
DROP TABLE ITEMS;
drop table accounts;
DROP TABLE CUSTOMERS;
DROP TABLE log_table;
drop table ORDERS_QUEUE_CA;
drop sequence orders_seq;
/
DROP SEQUENCE log_seq;
DROP PROCEDURE process_order;
DROP PROCEDURE log_msg;
/ 
CREATE TABLE CUSTOMERS (cust_id  NUMBER  NOT NULL PRIMARY KEY,
                        cust_name  VARCHAR2(100) NOT NULL,
                        cust_location VARCHAR2(2) NOT NULL  );
                        
CREATE TABLE ACCOUNTS (act_id NUMBER NOT NULL PRIMARY KEY,
                       act_cust_id NUMBER NOT NULL,
                       act_bal NUMBER(10,2),
                       CONSTRAINT act_cust_fk FOREIGN KEY (act_cust_id) REFERENCES  
                       customers(cust_id));

CREATE TABLE ITEMS    (item_id  NUMBER  NOT NULL PRIMARY KEY,
                       item_name  VARCHAR2(100) NOT NULL,
                       item_value number(5,2) NOT NULL  );
                      
CREATE TABLE ORDERS   (order_id  NUMBER  NOT NULL PRIMARY KEY,
                       order_item_id   NUMBER NOT NULL,
                       order_act_id    NUMBER NOT NULL ,
                       CONSTRAINT order_item_fk FOREIGN KEY (order_item_id) REFERENCES  
                       items(item_id),
                       CONSTRAINT  order_act_fk FOREIGN KEY (order_act_id) REFERENCES  
                       accounts(act_id));

--CREATE TABLE TEMP_TABLE(dummy number);

CREATE SEQUENCE orders_seq START WITH 1 INCREMENT BY 1;


-- Insert into customers table
INSERT INTO customers(cust_id,cust_name,cust_location) VALUES (1,'John','WA');
INSERT INTO customers(cust_id,cust_name,cust_location) VALUES (2,'Jack','CA');
INSERT INTO customers(cust_id,cust_name,cust_location) VALUES (3,'Jill','CA');

-- Insert into accounts table
INSERT INTO accounts(act_id,act_cust_id,act_bal) VALUES (1,1,1000);
INSERT INTO accounts(act_id,act_cust_id,act_bal) VALUES (2,2,1000);
INSERT INTO accounts(act_id,act_cust_id,act_bal) VALUES (3,3,1000);

-- Insert into items table
INSERT INTO items(item_id,item_name,item_value) VALUES (1,'Treadmill', 600);
INSERT INTO items(item_id,item_name,item_value) VALUES (2,'Elliptical',600);
COMMIT;

--1.Creare tabela
CREATE OR REPLACE PROCEDURE  create_table (p_table_name       VARCHAR2,
                                           p_table_columns    VARCHAR2)
IS 
  l_sql VARCHAR2(400);--sirul SQL (de exemplu aici e pentru crearea tabelelor)
BEGIN
  l_sql := 'CREATE TABLE '|| p_table_name || p_table_columns;
  DBMS_OUTPUT.PUT_LINE('Sql is '||l_sql);
  EXECUTE IMMEDIATE l_sql; 
END create_table;
/
EXEC create_table('ORDERS_QUEUE_CA','(queue_id NUMBER,queue_act_id NUMBER,queue_item_id NUMBER)');
/
desc orders_queue_ca;

--2.Stergere tabela 
CREATE OR REPLACE PROCEDURE drop_table (p_table_name  VARCHAR2) 
IS BEGIN
  EXECUTE IMMEDIATE  'DROP TABLE '|| p_table_name;
END drop_table;
/
EXEC drop_table('ORDERS_QUEUE_CA');
desc orders_queue_ca;--evident tabela nu mai exista

--3.Extragere de informatii pe baza unui single-select
--exemplul 1 - functie care returneaza nr de valori 
CREATE OR REPLACE FUNCTION get_count(p_table VARCHAR2)  
RETURN NUMBER
IS
  l_count NUMBER;
  l_query VARCHAR2(200);
BEGIN 
  l_query := 'SELECT COUNT(*) FROM ' || p_table; 
    EXECUTE IMMEDIATE l_query INTO l_count; 
  RETURN l_count;
END get_count;
/
DECLARE
  l_cnt NUMBER;
  l_cnt1 NUMBER;
BEGIN
  l_cnt := get_count('ORDERS');
  l_cnt1 := get_count('ITEMS');
    DBMS_OUTPUT.PUT_LINE('Count is '||l_cnt); 
    DBMS_OUTPUT.PUT_LINE('Count is '||l_cnt1); 
END; 

--exemplul 2 (cu using)
CREATE OR REPLACE FUNCTION get_order_count(p_column VARCHAR2, p_value NUMBER)
RETURN NUMBER 
IS
  l_count NUMBER;
  l_query VARCHAR2(200);
BEGIN
  l_query := 'SELECT COUNT(*) FROM items WHERE ' || p_column ||' = :col_value '; 
    EXECUTE IMMEDIATE l_query INTO l_count USING p_value;  
  RETURN l_count;
END get_order_count; 
/
DECLARE 
  l_cnt NUMBER;
  l_cnt1 NUMBER;
BEGIN  
  l_cnt := get_order_count('item_id',2);   
    DBMS_OUTPUT.PUT_LINE('Count is '||l_cnt);
END; 


--4.Extragere de informatii pe baza unui ref cursor
--exemplul 1 (utilizand nested block)
create or replace procedure apply_fees(p_column varchar2, p_value number)
is
  type cur_ref is ref cursor;
  cur_account cur_ref;
  l_query varchar2(400);
  l_act_id accounts.act_id%type;
begin
  l_query:='select act_id from accounts';
  if p_column is not null then
    l_query := l_query||' WHERE '||p_column||' = :pvalue';
    OPEN cur_account FOR l_query USING p_value;  
  else
    open cur_account for l_query;
  end if;
  
  loop
    fetch cur_account into l_act_id;
    EXIT WHEN cur_account%NOTFOUND; 
    UPDATE accounts SET act_bal = act_bal - 10 WHERE act_id = l_act_id; 
    commit;
  end loop;  
end apply_fees;

--exemplul 2
drop table ORDERS_QUEUE;
EXEC create_table('ORDERS_QUEUE','(queue_act_id NUMBER,queue_item_id NUMBER, queue_item_value NUMBER)');
/
CREATE OR REPLACE PROCEDURE initiate_order(p_where VARCHAR2) 
IS 
  TYPE cur_ref IS REF CURSOR;
  cur_order cur_ref; 
  TYPE order_rec IS RECORD(act_id orders_queue.queue_act_id%TYPE,
                          item_id orders_queue.queue_item_id%TYPE,
                          ìtem_value number);
  l_order_rec  order_rec;
  l_item_rec   items%ROWTYPE;
  l_query VARCHAR2(400);
BEGIN
  l_query := 'SELECT queue_act_id,queue_item_id FROM orders_queue' ||  p_where;
  dbms_output.put_line(l_query);
  OPEN  cur_order FOR l_query;
  LOOP
    FETCH cur_order INTO l_order_rec;
  EXIT WHEN cur_order%NOTFOUND;
  EXECUTE IMMEDIATE 'SELECT * FROM items WHERE item_id = :item_id ' INTO l_item_rec  USING l_order_rec.item_id;
    process_order(l_order_rec.act_id, l_order_rec.item_id, l_item_rec.item_value);
  END LOOP;
END initiate_order;
/
select * from orders_queue 
order by queue_act_id;
/
delete from orders;
/
update accounts set act_bal = 1000;
commit;
/
exec initiate_order('WHERE  queue_act_id = 1');
/
SELECT * FROM ORDERS;
/
delete from orders;
commit;
/
exec initiate_order(NULL);
SELECT * FROM ORDERS;

--5.Clauze DML
--inserare de inregistrari
--nr de bind values = nr de bind variables
create or replace procedure insert_record(p_table_name varchar2, p_col1_name varchar2, p_col1_value number, p_col2_name varchar2, p_col2_value varchar2, p_col3_name varchar2, p_col3_value varchar2)
is
begin
  execute immediate 'insert into '||p_table_name ||'('||p_col1_name||','||p_col2_name||','||p_col3_name||') '||'values(:col1_value,:col2_value,:col3_value)' using p_col1_value, p_col2_value, p_col3_value;
  commit;
end insert_record;
/
declare 
  l_null varchar2(1);
begin
  insert_record('customers', 'cust_id', '4', 'cust_name', 'Gigel', 'cust_location', 'AZ');
end;
/
select * from customers;

--modificari 
create or replace procedure update_record(p_table_name varchar2, p_col1_name varchar2, p_col1_value varchar2, p_where_col varchar2, p_where_value varchar2)
is
begin
  execute immediate 'UPDATE '||p_table_name ||'SET'||p_col1_name||'=:p_col1_value '||'WHERE '||p_where_col||'=:p_where_value' using p_col1_value, p_where_value;
  commit;
end update_record;
/
--update customers set cust_location = 'WA' where cust_id = 4;
declare 
  l_null varchar2(1);
begin
  update_record('CUSTOMERS', 'cust_location', 'WA', 'cust_id', 4);
end;
/
select * from customers;

--stergere
create or replace procedure delete_from_table(p_table_name varchar2)
is
begin
  execute immediate 'delete from '||p_table_name;
  commit;
end delete_from_table; 
/
begin
  delete_from_table('items');
end;
/
select * from items;

--returning into clause
--select * from accounts;
declare
  l_item_value items.item_value%type:=100;
  l_act_id accounts.act_id%TYPE:= 1;
  l_cust_id customers.cust_id%TYPE;
  l_act_bal accounts.act_bal%TYPE; 
begin
  execute immediate 'update accounts set act_bal=act_bal-:p_item_val'||'where act_id=:p_act_id returning act_cust_id, act_bal into :l_id, l_bal' using l_item_value, l_act_id returning into l_cust_id, l_act_bal;
  commit;
end;  

--6. Executie blocuri anonime
declare
  l_sql varchar2(500);
  l_inout number:=1;
  l_out number:=2;
  l_num number:=1;
begin
  l_sql:='begin :l_inout:=:l_inout + :l_num*2; '||':l_out:= :l_num/2; end;';
  execute immediate l_sql using in out l_inout, l_num, out l_out;
  dbms_output.put_line(l_sql);
  dbms_output.put_line('The result is '||l_inout);
end;  

--7.Specifying hints
create or replace procedure apply_fees(p_column varchar2, p_value number, p_hint varchar2)
is
  type cur_ref is ref cursor;
  cur_account cur_ref;
  l_query varchar2(400);
  l_act_id accounts.act_id%type;
begin
  l_query:='select '||p_hint||' act_id from accounts';
  
  if p_column is not null then
    l_query:=l_query||' where '||p_column||'=:p_value';
    open cur_account for l_query using p_value;
  else
    open cur_account for l_query;
  end if;
  
  loop
    fetch cur_account into l_act_id;
    exit when cur_account%notfound;
    update accounts SET act_bal = act_bal - 10 where act_id = l_act_id; 
    commit;
  end loop;
end apply_fees;  
/
EXEC apply_fees('act_id ' , 1,  '/*+ PARALLEL(accounts, 3)  */' );
/
select * from accounts;


--6.SQLInjection 
--first example
SELECT * FROM ORDERS;
/
CREATE OR REPLACE PROCEDURE delete_order(p_column VARCHAR2, p_value  VARCHAR2) 
IS     
  l_query VARCHAR2(200);
BEGIN
  l_query := 'DELETE FROM orders WHERE ' || p_column ||' = '||p_value;
  DBMS_OUTPUT.PUT_LINE(l_query);
  EXECUTE IMMEDIATE l_query;
  --DBMS_OUTPUT.PUT_LINE('Rows Deleted: '||SQL%ROWCOUNT);
END delete_order;
/
exec delete_order('order_act_id','1');
ROLLBACK;
exec delete_order('order_act_id','1 OR 1=1');
ROLLBACK;
/
CREATE OR REPLACE PROCEDURE delete_order(p_column VARCHAR2, p_value VARCHAR2)
IS     
  l_query VARCHAR2(200);
BEGIN
  l_query := 'DELETE FROM items WHERE ' || p_column ||' = :p_value' ;
  DBMS_OUTPUT.PUT_LINE(l_query);
  EXECUTE IMMEDIATE l_query USING p_value;
  DBMS_OUTPUT.PUT_LINE('Rows Deleted: '||SQL%ROWCOUNT);
END delete_order;
/
exec delete_order('item_id','1 OR 1=1');
exec delete_order('item_id','1'); 

--second example
create or replace procedure calc(p_condition varchar2) is
  l_block varchar2(1000);
  malicious_attack exception;
begin
  if instr(p_condition,';') > 0 then raise malicious_attack; end if;
  if instr(p_condition,';') > 0 then raise malicious_attack; end if;
    l_block:=' BEGIN  IF  '||p_condition||' = ''A'' THEN proc1; END IF; END; '; 
  execute immediate l_block;
exception
  when malicious_attack then
    dbms_output.put_line('Suspicious Input '||p_condition); 
    raise;
end calc;   
/
EXEC calc('1=1 THEN DELETE FROM orders; END IF; IF ''A'''); 
  

--7.Exemplu de creare de tabela
drop SEQUENCE queue_seq;
CREATE SEQUENCE queue_seq START WITH 1 INCREMENT BY 1;
/
CREATE OR REPLACE FUNCTION generate_order(p_loc VARCHAR2, p_act_id NUMBER, p_item_id NUMBER)
RETURN NUMBER
IS
  l_count    NUMBER;
  l_id       NUMBER;
  l_item_val NUMBER;
  no_table_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_table_exists,-942);
  CURSOR get_item_val IS
  SELECT item_value
  FROM  items
  WHERE  item_id = p_item_id;
BEGIN
  BEGIN
    --First check if table exists. If not create it for that location
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM orders_queue_'||p_loc INTO l_count;
  EXCEPTION 
    WHEN no_table_exists THEN
      EXECUTE IMMEDIATE 'CREATE TABLE orders_queue_'||p_loc||'(queue_id NUMBER,queue_act_id NUMBER,queue_item_id NUMBER)';
  END;
  EXECUTE IMMEDIATE 'INSERT INTO orders_queue_'||p_loc||'(queue_id ,queue_act_id ,queue_item_id) VALUES '|| '(:p_id,:p_act,:p_item)
                    RETURNING queue_id INTO :l_id' USING queue_seq.NEXTVAL,p_act_id,p_item_id RETURNING INTO l_id;
  DBMS_OUTPUT.PUT_LINE('queue_id is '||l_id);
  OPEN get_item_val;
  FETCH get_item_val INTO l_item_val;
  CLOSE get_item_val;
  EXECUTE IMMEDIATE 'CALL process_order(:p_act_id,:p_item_id,:p_item_value) ' USING p_act_id,p_item_id,l_item_val;
  RETURN l_id;
END generate_order;
/
DECLARE
  l_id NUMBER;
BEGIN 
  l_id := generate_order('CA',1,1);
END;

--8.Exemplu de select
select * from customers where cust_id=:1;










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


exec catalog_materie(20);
select * from user_Tables;
select * from LOGICÃ;
select * from cursuri;








