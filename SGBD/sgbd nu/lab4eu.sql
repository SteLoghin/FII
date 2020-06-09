CREATE OR REPLACE PROCEDURE 
afiseaza AS
    my_name varchar2(20):='ZEU';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Ma cheama ' 
    || my_name);
END afiseaza;

BEGIN
    afiseaza();
END;

--DROP PROCEDURE AFISEAZA;
--
--select text from user_source where lower(name)
----LIKE 'afiseaza';

CREATE OR REPLACE PROCEDURE inc(p_val in out number) as
BEGIN
    p_val:=p_val+1;
end;

declare
    v_numar NUMBER:=68;
BEGIN
    inc(v_numar);
    dbms_output.put_line(v_numar);
    end;

declare
    v_numar NUMBER:=10;
begin
    inc(v_numar);
    dbms_output.put_line(v_numar);
end;

BEGIN
    inc(7);
END;

declare
    v_numar varchar2(10):='7';
    begin
    inc(v_numar);
    dbms_output.put_line(v_numar);
    end;

CREATE OR REPLACE PROCEDURE data_plus (p_val IN OUT DATE) as
begin
    p_val :=p_val+1;
end;

declare
    v_data studenti.data_nastere%TYPE:='31-DEC-1990';
    begin
    data_plus(v_data);
    dbms_output.put_line(v_data);
    end;


SELECT data_nastere from studenti where id=1;

CREATE OR REPLACE procedure suma(p_nr1 in NUMBER:=3,p_nr2 in NUMBER:=10) AS
p_rezultat NUMBER;
BEGIN
    p_rezultat:=p_nr1+p_nr2;
    DBMS_output.put_line(p_rezultat);
    end;

BEGIN
    suma();
    end;
    
create or replace procedure suma(p_nr1 in NUMBER:=10,p_nr2 in NUMBER:=59) as p_rezultat NUMBER;
begin
    p_rezultat:=p_nr1+p_nr2;
    dbms_output.put_line(p_rezultat);
    end;

BEGIN
    suma();
    end;
    
    DESCRIbe suma;
    
create or replace procedure pow(p_baza IN Integer:=3,p_exponent IN Integer:=5) as p_rezultat Integer;
BEGIN
 p_rezultat:=p_baza**p_exponent;
 dbms_output.put_line(p_rezultat);
 end;

begin
    pow(2,0);
    end;
    
begin
   pow(p_baza=>2, p_exponent=>3);
    end;
    
BEGIN
   pow(p_exponent=>3, p_baza=>2);
END;

begin
--    pow(2,p_exponent=>3);
    pow(p_baza=>2);
   pow(3,2);
  pow(p_exponent=>3); 
    end;
    
 create or replace procedure suma_pow(p_nr1 IN integer,p_nr2 in integer) as p_rezultat integer;
 begin
    p_rezultat:=(p_nr1+p_nr2)+(p_nr1**p_nr2);
    dbms_output.put_line(p_rezultat);
    end;
    
    begin
      suma_pow(20,3);
      end;
      
    DECLARE 
   v_out INTEGER;
BEGIN
   pow(p_baza=>3, p_out => v_out);
   DBMS_OUTPUT.PUT_LINE(v_out);
END;

create or replace function make_waves(p_sir_caractere varchar2) return varchar2 as
v_index integer;v_rezultat varchar2(1000):='';
begin
    for v_index IN 1..length(p_sir_caractere) LOOP
        if(v_index mod 2 =1)
            then
                v_rezultat:=v_rezultat || UPPER(SUBSTR(p_sir_caractere,v_index,1));
            else
                v_rezultat:=v_rezultat || lower(SUBSTR(p_sir_caractere,v_index,1));
        end if;
        end loop;
        return v_rezultat;
        end;
    
select make_waves('Facultatea de informatica') from dual;

create or replace function makes_waves(p_sir_caractere varchar2) return varchar2 as
v_index integer; v_rezultat varchar2(1000):= '';
begin
    for v_index in 1..length(p_sir_caractere) LOOP
        if(v_index mod 2=1)
            then
                v_rezultat:=v_rezultat || upper(substr(p_sir_caractere,v_index,1));
            else
                v_rezultat:=v_rezultat|| lower(substr(p_sir_caractere,v_index,1));
            end if;
        end loop;
        return v_rezultat;
        end;

select make_waves('cauciucuri continental') from dual;

SET SERVEROUTPUT ON;
DECLARe
    v_sir varchar2(1000):='Incaasdahideti facultatile';
BEGIN
    v_sir:=make_waves(v_sir);
    DBMS_OUTPUT.PUT_LINE(v_sir);
    end;
    
create or replace package manager_facultate is
    g_today_date    DATE:=SYSDATE;
    cursor lista_studenti is select nr_matricol,nume,prenume,grup,an from studenti order by nume;
    PROCEDURE adauga_student(nume_studenti.nume%type,prenume studenti.prenume%type);
    PROCEDURE sterge_student(nr_matr studenti.nr_matricol%type);
    END manager_facultate;
    
CREATE or replace package body manager_facultate is
    nume_facultate VARCHAR2(100):='Facultatea de Informatica din IASI';
    
    FUNCTION calculeaza_varsta(data_naster DATE) return int as 
    BEGIN
        return floor((g_today_date-data_nastere)/365);
    END calculeaza_varsta;
    
    PROCEDURE adauga_student(nume studenti.nume%type,prenume studenti.prenume%type)
    IS BEGIN
        dbms_output.put_line('Exemplu apel functie privata: ' || calculeaza_varsta(to_date('01/01/1990','DD/MM/YY')));
        dbms_output.put_line('Aici ar trebui sa scrieti cod pentru adaugarea unui student');
    END adauga_student;
    
    PROCEDURE sterge_student(nr_matr studenti.nr_matricol%type) is
    begin
        null;
    end sterge_student;
END manager_facultate;



create or replace function f_exista_student(IN_id in studenti.id%type) 
return boolean
is
  e_std boolean;
  p_number number;--0 daca studentul nu exista, 1 daca exista
begin
  select count(*) into p_number from studenti where id=IN_id;
  if p_number=0 then dbms_output.put_line('Studentul cu id-ul '||IN_id||' nu exista in baza de date !');
    e_std:=false;--return false;
  else e_std:=true;--return true;
  end if;
  return e_std;
end f_exista_student; 

create or replace procedure get_medii_student(IN_id IN studenti.id%type, OUT_medie1 OUT float,OUT_medie2 OUT float)
as
    p_an number(1);
    p_exist boolean;
BEGin
    p_exist:=f_exista_student(IN_id);
    if p_exist=true then
    select an into p_an from studenti where id=IN_id;
    if(p_an=1) then
              DBMS_OUTPUT.PUT_LINE('Studentul cu id-ul ' ||IN_id|| ' este in anul 1 si nu are medie !');
        elsif(p_an=2) then
            select trunc(avg(valoare),2) into OUT_medie1 from note n join cursuri c on c.id=n.id_curs where id_student=IN_id and an=1;
                  DBMS_OUTPUT.PUT_LINE('Media din anul 1 este: ' || OUT_medie1);
        elsif(p_an=3)then
            select trunc(avg(valoare),2) into out_medie1 from note n join cursuri c on c.id=n.id_curs where id_student=IN_id












