--Dati comanda SET SERVEROUTPUT ON inainte de a rula orice cod, pentru a vedea rezultatele !

--1.Afisati id-ul, numele si prenumele ultimului student din catalog din punct de vedere al id-ului.
-- LOB CLOB BLOB - declaram o coloana JSON

declare
  p_id          studenti.id%type;
  p_nume        studenti.nume%type;
  p_prenume     studenti.prenume%type;
  
begin
  select s.id, s.nume, s.prenume
  into p_id, p_nume, p_prenume
  from studenti s
  where id = (select max(id) from studenti);
  dbms_output.put_line(p_id ||' '||p_nume ||' '||p_prenume);
end;  

/*2.Afisati numele concatenat cu prenumele unui student la intamplare. 
Realizati aceasta concatenare direct in select, respectiv in functia de afisare. Hint: deoarece studentul este ales random, ar trebui ca 
la fiecare rulare sa fie afisat alt student.*/
--(concatenarea direct in select)
--metoda 1 
declare
  p_numar_studenti        NUMBER(5); 
  p_student_random        NUMBER(5);
  p_rezultat              VARCHAR(40);
begin
  --aflam mai intai nr de studenti din baza de date
  select count(*) 
  into p_numar_studenti
  from studenti;
  p_student_random := DBMS_RANDOM.VALUE(1,p_numar_studenti);
  
  select nume||' '||prenume
  into p_rezultat
  from
    (select nume,prenume,rownum as rand
    from studenti)
  where rand = p_student_random;
  dbms_output.put_line(p_rezultat);
end;

--metoda 2
declare
  p_rezultat    varchar2(100);
begin
  select nume ||' '|| prenume
  into p_rezultat 
  from
    (select nume,prenume 
    from studenti 
    order by DBMS_RANDOM.VALUE) where rownum=1;
  dbms_output.put_line(p_rezultat);
end;

--concatenarea in functia de afisare
declare
  p_nume        studenti.nume%type;
  p_prenume     studenti.prenume%type;
begin
  select nume,prenume
  into p_nume,p_prenume
  from
    (select nume,prenume from studenti order by DBMS_RANDOM.VALUE) where rownum=1;
  dbms_output.put_line(p_nume || ' ' ||p_prenume);
end; 

/*3. Gasiti persoana (sau una din persoanele) cu numele cel mai lung din tabela studenti. 
Afisati numele acesteia cu litera mare si restul caracterelor litere mici si lungimea numelui ei.*/
declare 
  p_nume studenti.nume%type;
begin
  select nume 
  into p_nume
  from
  (
    select nume 
    from studenti
    order by length(trim(nume))desc
  )
  where rownum=1;
  dbms_output.put_line(initcap(p_nume)||' - '||length(trim(p_nume))||' caractere.');
end;

