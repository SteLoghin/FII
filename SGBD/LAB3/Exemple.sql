/*1. Avand doua IDuri de studenti (hardcodate), afisati care dintre ei are media mai mare, cu conditia ca numarul de note al fiecaruia sa fie de minim 15.
Daca media este egala, afisati care are nota mai mare la BD, asta in cazul in care amandoi au nota la BD.
Daca macar unul nu are nota la BD, afisati un mesaj corespuzator. Daca amandoi au aceeasi nota la BD, atunci amandoi sunt declarati castigatori.*/

--select de verificare (luati mai intai 2 studenti care au minim 15 note si vedeti cum merge, apoi luati macar un id de student ce are mai putin de 15 note)
--select id_student, count(*) from studenti s join note n on n.id_student = s.id group by id_student having count(valoare)<16 order by 2 desc;

declare
  p_id1                 studenti.id%type :=51;
  p_id2                 studenti.id%type :=414;
  p_castigator          varchar2(100);
  p_count_id1           studenti.id%type;
  p_count_id2           studenti.id%type;
  p_medie_id1           number;
  p_medie_id2           number;
  p_nr_note_id1         note.valoare%type;
  p_nr_note_id2         note.valoare%type;
  p_valoare_id1         note.valoare%type;
  p_valoare_id2         note.valoare%type;
  p_count_valoare_id1   note.valoare%type;
  p_count_valoare_id2   note.valoare%type;
  
begin
  select count(id) into p_count_id1 from studenti where id=p_id1;
  select count(id) into p_count_id2 from studenti where id=p_id2;
  
  select count(valoare), avg(valoare) into p_nr_note_id1, p_medie_id1 from studenti s join note n on s.id = n.id_student where s.id = p_id1;
  select count(valoare), avg(valoare) into p_nr_note_id2, p_medie_id2 from studenti s join note n on s.id = n.id_student where s.id = p_id2;
  
  if(p_count_id1=1 and p_count_id2=0) then
    dbms_output.put_line('Studentul '||p_id2||' nu exista in baza de date !');
  elsif (p_count_id1=0 and p_count_id2=1) then
    dbms_output.put_line('Studentul '||p_id1||' nu exista in baza de date !');
  elsif (p_count_id1=0 and p_count_id2=0) then
    dbms_output.put_line('Nici unul din cei doi studenti nu exista in baza de date');    
  elsif (p_id1=p_id2) then
    dbms_output.put_line('Introduceti 2 useri diferiti !');  
  elsif ((p_count_id1=1 and p_nr_note_id1<15) or (p_count_id2=1 and p_nr_note_id2<15)) then 
    dbms_output.put_line('Cel putin unul din studenti are mai putin de 15 note');
  else 
    dbms_output.put_line('Studentul 1 are '||p_nr_note_id1||' note si media '||p_medie_id1); 
    dbms_output.put_line('Studentul 2 are '||p_nr_note_id2||' note si media '||p_medie_id2); 
    
    if p_medie_id1 > p_medie_id2 then
      p_castigator := p_id1;
    elsif p_medie_id1 < p_medie_id2 then
      p_castigator := p_id2;
    elsif p_medie_id1 = p_medie_id2 then 
      select count(valoare), valoare into p_count_valoare_id1, p_valoare_id1 from note n join cursuri c on c.id = n.id_curs where titlu_curs = 'Baze de date' and n.id_student = p_id1 group by valoare;
      select count(valoare), valoare into p_count_valoare_id2, p_valoare_id1 from note n join cursuri c on c.id = n.id_curs where titlu_curs = 'Baze de date' and n.id_student = p_id2 group by valoare;
      
      if p_count_valoare_id1 = 0 then dbms_output.put_line('Studentul cu id-ul' ||p_id1||' nu are nota la Baze de date !');
      elsif p_count_valoare_id2 = 0 then dbms_output.put_line('Studentul cu id-ul' ||p_id2||' nu are nota la Baze de date !');
      end if;
      
      if p_count_valoare_id1 = 1 and p_count_valoare_id2 = 1 then
        if p_valoare_id1 > p_valoare_id2 then p_castigator := p_id1;
        elsif p_valoare_id1 < p_valoare_id2 then p_castigator := p_id2;
        else dbms_output.put_line('Ambii sunt castigatori');
        end if;
      end if; 
      end if;
  dbms_output.put_line('Castigator: '||p_castigator);
  end if;
end;


/*2. Construituiti o tabela cu numele "Fibonacci" avand campurile id si valoare. 
Adaugati in tabela toate numerele din sirul lui Fibonacci mai mici decat 1000 si strict mai mari decat 1, 
in ordinea in care acestea apar in sir. Campul ID va indica numarul de ordine din tabela.*/
--fiecare numãr reprezintã suma a douã numere anterioare, începând cu 0 si 1

--varianta cu loop
drop table fibonacci;
/
create table fibonacci(
  id number, 
  value number)
/
declare
  p_val1 number := 1;
  p_val2 number := 1; 
  p_sum number;
  p_fibo_id number := 1;
begin
  delete from fibonacci;
    -- am pus asa pentru a sterge ce am avut inainte pentru in cazul in care rulam de mai multe ori si sa nu avem valori in plus, se repeta valorile
    loop       
       p_sum := p_val1 + p_val2;
       p_val1 := p_val2;
       p_val2 := p_sum;
       exit when p_sum > 1000;       
       insert into fibonacci values (p_fibo_id, p_sum);       
       p_fibo_id := p_fibo_id + 1;       
    end loop;   
end;
/
select * from fibonacci;

--varianta cu while
drop table fibonacci;
/
create table fibonacci(
  id number, 
  value number)
/
declare
  p_val1 number := 1;
  p_val2 number := 2; 
  p_sum number:=2;
  p_fibo_id number := 1;
begin
delete from fibonacci;
  while p_sum < 1000 loop
    insert into fibonacci values (p_fibo_id,p_sum);
    p_sum:=p_val1+p_val2;
    p_val1 := p_val2;
    p_val2 := p_sum;
    p_fibo_id := p_fibo_id + 1; 
  end loop;  
end;
/
select * from fibonacci;

/*3. Scrieti un bloc anonim care afiseaza primele 10 numere naturale in sens invers, de la cel mai mare la cel mai mic.*/
declare
  p_start number:=1;
begin
  for i in reverse p_start..10 loop
    dbms_output.put_line(i);
  end loop;
end; 


/*4. Utilizand un cursor, afisati id-ul, numele si prenumele studentilor din care au bursa mai mare ca 1000.*/
--varianta 1, fara declararea explicita a cursorului
--cursorul e ce e in paranteza
begin
  for i in 
    (select * 
    from studenti
    where bursa>1000
    order by bursa)
      loop
        dbms_output.put_line(i.id||' - '||i.nume||' - '||i.prenume||' - '||i.bursa);
      end loop;
end;      

--alta varianta, se declara explicit cursorul si se parcurge cu for .. loop
declare
  cursor c1 is
  select id, nume, prenume, lpad(round(bursa),7)as bursa
  from studenti
  where bursa > 1000
  order by bursa desc;
  c1_record c1%rowtype;
begin
  for c1_record in c1 loop
    dbms_output.put_line(c1_record.id||' - '||c1_record.nume ||' - '||c1_record.prenume||' - '||c1_record.bursa);
  end loop;  
end; 

--alta varianta, cea mai buna ca performanta
--se lucreaza cu bulk collect, adica toate datele se incarca in acelasi timp - mai intai se declara 2 type-uri, iar datele din select vor fi retinute in array-uri
create or replace type num_arr as table of number;
/
create or replace type vc_arr as table of varchar2(2000);
/
--num_arr array de number; vc_arr --  p_student_nume_arr array varchar de tip vc_arr
declare
  p_id_arr                num_arr;
  p_student_nume_arr      vc_arr;
  p_student_prenume_arr   vc_arr;
  p_student_bursa_arr     num_arr;
begin
  select student_id, student_nume, student_prenume, student_bursa
  bulk collect into p_id_arr, p_student_nume_arr, p_student_prenume_arr, p_student_bursa_arr
  from
  (select s.id as student_id, s.nume as student_nume, s.prenume as student_prenume, s.bursa as student_bursa
  from studenti s where bursa>1000);
  
  -- verificarea se face dupa cheie nu dupa altceva
  if p_id_arr.count<>0 then 
    for i in 1 .. p_id_arr.count loop
      dbms_output.put_line(p_id_arr(i)||' - '|| p_student_nume_arr(i)||' - '|| p_student_prenume_arr(i)||' - '||p_student_bursa_arr(i));
    end loop;
  end if;
end;

--ultima modalitate de a scrie
declare
  type idType is table of studenti.id%type; 
  type numeType is table of studenti.nume%type;
  type prenumeType is table of studenti.prenume%type;
  type bursaType is table of studenti.bursa%type;
  id_t idType;
  id_nume numeType;
  id_prenume prenumeType;
  id_bursa bursaType;
  cursor c1 is
  select id, nume, prenume, bursa 
  from studenti 
  where bursa>1000;
begin
  open c1;
    fetch c1 bulk collect into id_t,id_nume,id_prenume,id_bursa;
    --aici se proceseaza elementele din colectii
    for i in id_t.first .. id_t.last loop
      dbms_output.put_line(id_t(i)||' - '||id_nume(i)||' - '||id_prenume(i)||' - '||id_bursa(i));
  end loop;
end;

accept i_numar prompt "Please enter your number: "; 
DECLARE
   v_numar NUMBER(5);
   i_numar NUMBER(5);
BEGIN   
   v_numar := &i_numar;
   IF (v_numar MOD 2 = 0)
      THEN 
        DBMS_OUTPUT.PUT_LINE('Numarul '||v_numar||' este par.');
      ELSE
        DBMS_OUTPUT.PUT_LINE('Numarul '||v_numar||' este impar.');
   END IF;
END; 






