/*1.Sa se construiasca un pachet PLSQL prin intermediul caruia sa se faca managementul unei facultati.
In pachet va trebui sa aveti:
a - o procedura sau functie ce returneaza varsta unui student (in ani, luni si zile) a acelui student;
b - o procedura care sa adauge un student in baza de date (cu generare de ID, matricol si simulare de note la materiile din anii precedenti - 
  de exemplu daca este in anul 3 va avea note la materiile din anii 1 si 2).
c - o procedura care sa elimine un student din baza de date (se vor elimina si constrangerile).
d - o procedura sau functie care sa afiseze informatii despre un student: numar matricol, foaia matricola, media, varsta 
(apel la procedura de la punctul 1), al catelea este in grupa, care ii sunt prietenii si alte informatii despre care credeti ca ar fi interesante.*/

/*1.Problema 1 (maxim 8 puncte):
Sa se construiasca un pachet PLSQL prin intermediul caruia sa se faca managementul unei facultati.
In pachet va trebui sa aveti:
(2pt) - o procedura (privata) ce returneaza varsta unui student (in ani, luni si zile) a acelui student;
(2pt) - o procedura care sa adauge un student in baza de date (cu generare de ID, matricol si simulare de note la materiile din anii precedenti - 
  de exemplu daca este in anul 3 va avea note la materiile din anii 1 si 2).
(2pt) - o procedura care sa elimine un student din baza de date (se vor elimina si constrangerile).
(2pt) - o procedura care sa afiseze informatii despre un student: numar matricol, foaia matricola, media, varsta (apel la procedura de la punctul 1), 
al catelea este in grupa, care ii sunt prietenii si alte informatii despre care credeti ca ar fi interesante.*/

--tabele ajutatoare pentru procedura de insert
drop table inume;
drop table iprenume;
drop table nume;
drop table prenume;
/
create table nume(n varchar2(100));
create table prenume(p varchar2(100));
create table inume(nr number, nume varchar2(200));
create table iprenume(nr number, prenume varchar2(200));
/
INSERT INTO prenume VALUES ('Mihai');
INSERT INTO prenume VALUES ('Gigel');
INSERT INTO prenume VALUES ('Marius');
INSERT INTO prenume VALUES ('Adina');
INSERT INTO prenume VALUES ('Ioana');
/
INSERT INTO nume VALUES ('Simionescu');
INSERT INTO nume VALUES ('Negrutu');
INSERT INTO nume VALUES ('Popescu');
INSERT INTO nume VALUES ('Popa');
INSERT INTO nume VALUES ('Matei');
/
INSERT INTO inume SELECT ROWNUM, n FROM nume;
INSERT INTO iprenume SELECT ROWNUM, p FROM prenume;
/
set serveroutput on;
create or replace package pck_management_facultate
is
  procedure p_afiseaza_varsta;--daca se cere sa se afiseze random
  function f_exista_student(IN_id in studenti.id%type) return boolean;--functie ajutatoare
  function f_are_note(IN_id_student in note.id_student%type) return boolean;--functie ajutatoare
  function f_exista_in_prieteni(IN_id_student in prieteni.id_student1%type) return boolean;--functie ajutatoare
  procedure p_afiseaza_varsta1(IN_id studenti.id%type);--daca se cere sa se dea ca parametru un id de student scris de la tastatura
  procedure p_add_student_studenti;
  procedure p_add_student_note(IN_id studenti.id%type);
  procedure p_del_student(IN_id studenti.id%type);
  procedure p_detalii_student(IN_id in studenti.id%type,p_medie1 out float,p_medie2 out float);
end pck_management_facultate;
/
create or replace package body pck_management_facultate
is
  procedure p_afiseaza_varsta
  is
    p_numar_studenti number(5);
    p_student_random number(5);
    p_rezultat VARCHAR(100);
  begin
    select count(*) 
    into p_numar_studenti
    from studenti;
    p_student_random := dbms_random.value(1,p_numar_studenti);
    select id||' '||nume||' '||prenume||' '||varsta
    into p_rezultat
    from
      (select id,nume,prenume,trunc(months_between(sysdate,data_nastere)/12)||' ani '||
      floor(to_number(months_between(sysdate,data_nastere)-(trunc(months_between(sysdate,data_nastere)/12))*12))||' luni '||
      floor(to_number(sysdate-add_months(data_nastere,trunc(months_between(sysdate,data_nastere)))))||' zile. ' as varsta, rownum as rand
      from studenti)
    where rand = p_student_random;
    dbms_output.put_line(p_rezultat);
  end p_afiseaza_varsta; 
  
  function f_exista_student(IN_id in studenti.id%type)
  return boolean
  is
    e_std boolean;
    p_number number;--0 daca studentul nu exista, 1 daca exista
  begin
    select count(*) into p_number from studenti where id=IN_id;
    if p_number=0 then
      dbms_output.put_line('Studentul cu id-ul '||IN_id||' nu exista in baza de date !');
      e_std:=false;
      --return false;
    else
      e_std:=true;
      --return true;
    end if;
    return e_std;
  end f_exista_student;  
  
  function f_are_note(IN_id_student in note.id_student%type) 
  return boolean
  is
    e_std boolean;
    p_number number;
  begin
    select count(*) into p_number from note where id_student=IN_id_student;
    if p_number=0 then
      dbms_output.put_line('Studentul cu id-ul '||IN_id_student||' nu are note!');
    end if;  
    e_std:=false;
    return e_std;
  end f_are_note;
  
  function f_exista_in_prieteni(IN_id_student in prieteni.id_student1%type) 
  return boolean
  is
    e_std boolean;
    p_number number;
  begin
    select count(*) into p_number from prieteni where id_student1=IN_id_student or id_student2=IN_id_student;
    if p_number=0 then
      dbms_output.put_line('Studentul cu id-ul '||IN_id_student||' nu exista in tabela de prieteni !');
    end if;  
    e_std:=false;
    return e_std;
  end f_exista_in_prieteni;
  
  procedure p_afiseaza_varsta1(IN_id in studenti.id%type)
  is
    p_nume_student studenti.nume%type;
    p_prenume_student studenti.prenume%type;
    p_varsta varchar2(100);
    p_exist boolean;
  begin
    p_exist :=f_exista_student(IN_id);
    if p_exist=true then
      select nume,prenume,trunc(months_between(sysdate,data_nastere)/12)||' ani '||
        floor(to_number(months_between(sysdate,data_nastere)-(trunc(months_between(sysdate,data_nastere)/12))*12))||' luni '||
        floor(to_number(sysdate-add_months(data_nastere,trunc(months_between(sysdate,data_nastere)))))||' zile.'
      into p_nume_student,p_prenume_student,p_varsta
      from studenti
      where id=IN_id;
    end if;
    dbms_output.put_line(p_nume_student||' '||p_prenume_student||' '||p_varsta);
  end p_afiseaza_varsta1;
  
  procedure p_add_student_studenti
  is
    p_count number :=0;
    p_nr_nume number :=100;
    p_nr_prenume number :=100;
    p_temp number :=0;
    p_nume varchar2(15);
    p_prenume varchar2(15);
    p_an_random number;
    p_grupa_random varchar2(2);
    p_id_curs cursuri.id%type;
    p_matr studenti.nr_matricol%type;
    p_max_id_student studenti.id%type;
  begin
    p_matr:= floor(dbms_random.value(100,999)) || chr(floor(dbms_random.value(65,91))) || 
      chr(floor(dbms_random.value(65,91))) || chr(floor(dbms_random.value(0,9)));
    --cati studenti sunt dupa nume
    select count(*) into p_nr_nume from inume;
   --cati studenti sunt dupa prenume
    select count(*) into p_nr_prenume from iprenume;         
    loop
      p_temp := trunc(dbms_random.value(1,p_nr_nume));
      select nume into p_nume from inume where nr = p_temp; 
         
      p_temp := trunc(dbms_random.value(1,p_nr_prenume));      
      select prenume into p_prenume from iprenume where nr = p_temp;
                  
      select count(*) into p_temp from studenti where nume=p_nume and prenume=p_prenume;
    
      if(p_temp = 0) then
        select max(id) into p_temp from studenti;
        p_temp := p_temp + 1;
        p_an_random := trunc(dbms_random.value(1,4));
       
        insert into studenti(id, nr_matricol, nume, prenume, an) values (p_temp, p_matr, p_nume, p_prenume, p_an_random);
          p_count := p_count + 1;
        exit when p_count = 1;
         
      end if;  
    end loop;
  end p_add_student_studenti;
  
  procedure p_add_student_note(IN_id in studenti.id%type)
  is
    p_exist_in_studenti boolean;
    p_max_id_note number;
    p_max_id_student number;
    p_temp number;
    p_an_random number;
    
    cursor c1 (p_an cursuri.an%type) is
    select id from cursuri where an < p_an;
    
  begin
    p_exist_in_studenti :=f_exista_student(IN_id);
    --in tabela de note se va insera urmatorul id dupa maxim  
    select max(id) into p_max_id_note from note;
    
    select max(id) into p_max_id_student from studenti where id=IN_id;
    
    if(p_temp = 0) then
       select max(to_number(id)) into p_temp from studenti;
       p_temp := p_temp + 1;
       p_an_random := trunc(dbms_random.value(1,4));
       
       --acordam note doar studentilor din anii 2 si 3
    if p_exist_in_studenti=true then   
      if (p_an_random>1) then
        for c1_record in c1(p_an_random) loop
          insert into note (id,id_student,id_curs,valoare) VALUES(p_max_id_note+1,p_temp,c1_record.id,trunc(dbms_random.value(1,11)));
        end loop;
      end if;
    end if;  
    end if;

  end p_add_student_note;
        
  procedure p_del_student(IN_id in studenti.id%type)
  is
    p_counter integer;
    p_nr_note number;
    p_result number;
    p_result1 number;
    p_result2 number;
    p_counter_note integer;
    p_counter_prieteni integer;
  begin
    --verific daca studentul exista in tabelele de legatura, si daca exista il sterg mai intai din aceste tabele
    select count(*) into p_counter_note from note where id_student=IN_id;
    if p_counter_note<>0 then
      delete from note where id_student=IN_id;
    p_result:=sql%rowcount;
    dbms_output.put_line(p_result||' linii sterse din tabela de note');  
    end if;
    
    select count(*) into p_counter_prieteni from prieteni where id_student1=IN_id or id_student2=IN_id;
    if p_counter_prieteni<>0 then delete from prieteni where id_student1=IN_id or id_student2=IN_id;
    p_result1:=sql%rowcount;
    dbms_output.put_line(p_result1||' linii sterse din tabela de prieteni');
    end if;

    select count(*) into p_counter from studenti where id=IN_id;
    if p_counter<>0 then 
      --acum il sterg din tabela principala
      delete from studenti where id=IN_id;
    p_result2:=sql%rowcount;
    dbms_output.put_line(p_result2||' linii sterse din tabela de studenti');--evident, aici o singura linie se va sterge mereu
    else
      dbms_output.put_line('Studentul cu id-ul '||IN_id||' nu exista in baza de date !');
    end if;

  end p_del_student;  

  procedure p_detalii_student(IN_id in studenti.id%type,p_medie1 out float,p_medie2 out float)
  is
    p_an number(2);
    p_counter_note number;
    p_exist boolean;
    p_mesaj varchar2(100);
    p_varsta varchar2(100);

    --cursor care preia situatia scolara a studentului dat ca parametru de intrare
    cursor c1 is 
    select titlu_curs,valoare,c.an
    from cursuri c join note n on c.id=n.id_curs join studenti s on s.id=n.id_student
    where s.id=IN_id
    order by 3;
    
    --cursor care preia detaliile personale ale studentului dat ca parametru de intrare
    cursor c2 is
    select nr_matricol as matricol,nume,prenume,an,grupa,nvl(bursa,0) as bursa
    from studenti
    where id=IN_id;
    
    --cursor care intoarce toti prietenii studentului dat ca parametru de intrare
    cursor c3 is
    select s2.nr_matricol as matricol, s2.nume as nume ,s2.prenume as prenume
    from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2 
    where id_student1=IN_id;

  begin   
    p_exist :=f_exista_student(IN_id);
    if p_exist=true then
      for c2_record in c2 loop
        dbms_output.put_line('Matricol: '||c2_record.matricol||' '||'Nume: '||c2_record.nume||' '||'Prenume: '||c2_record.prenume||' '||'An: '||c2_record.an
          ||'Grupa: '||c2_record.grupa||' '||'Bursa: '||c2_record.bursa);
        dbms_output.put_line('--------------------------------------------------------------');  
        dbms_output.put_line('Prietenii lui '||c2_record.nume||' '||c2_record.prenume||' sunt: ');  
        for c3_record in c3 loop
          p_mesaj:=(c3_record.matricol||' '||c3_record.nume||' '||c3_record.prenume);
          dbms_output.put_line(p_mesaj);
        end loop;
      dbms_output.put_line('--------------------------------------------------------------');
      dbms_output.put_line('Notele lui '||c2_record.nume||' '||c2_record.prenume||' sunt: ');    
      end loop;  
      for c1_record in c1 loop
        p_mesaj:=('Curs '||c1_record.titlu_curs ||' Nota '||c1_record.valoare||' An '||c1_record.an);
        dbms_output.put_line(p_mesaj);
      end loop;
      dbms_output.put_line('--------------------------------------------------------------');
      p_afiseaza_varsta1(IN_id);
    
    select an into p_an from studenti where id=IN_id; 

    dbms_output.put_line('--------------------------------------------------------------');
    if (p_an=1) then
      p_medie1:=0;
      select trunc(avg(valoare),2)
      into p_medie1
      from note n join cursuri c on c.id=n.id_curs
      where id_student=IN_id and an=1;   
      dbms_output.put_line('Media din anul I este : ' || p_medie1); 
    elsif(p_an=2) then
      select trunc(avg(valoare),2)
      into p_medie1
      from note n join cursuri c on c.id=n.id_curs
      where id_student=IN_id and an=1;   
      dbms_output.put_line('Media din anul I este : ' || p_medie1);       
    elsif(p_an=3) then
      select trunc(avg(valoare),2)
      into p_medie1
      from note n join cursuri c on c.id=n.id_curs
      where id_student=IN_id and an=1;
      dbms_output.put_line('Media din anul I este : ' || p_medie1);
      
      select trunc(avg(valoare),2)
      into p_medie2
      from note n join cursuri c on c.id=n.id_curs
      where id_student=IN_id and an=2;
      dbms_output.put_line('Media din anul II este : ' || p_medie2);
    else null;  
    end if;    
    end if;
  
  end p_detalii_student;
 
end pck_management_facultate;    
/
declare
  p_medie1 number(4,2);
  p_medie2 number(4,2);
begin
  --pck_management_facultate.p_afiseaza_varsta;
  --pck_management_facultate.p_afiseaza_varsta1(55);
  --pck_management_facultate.p_add_student_studenti;--select count(*) from studenti;--trebuie sa fie unul in plus dupa fiecare rulare 
  --pck_management_facultate.p_add_student_note(1027);--select * from note where id_student = (select max(id_student) from note);
  --pck_management_facultate.p_del_student(33);--evident, la a doua rulare trebuie sa apara ca nu mai exista in baza de date
  pck_management_facultate.p_detalii_student('1',p_medie1,p_medie2);
end;

