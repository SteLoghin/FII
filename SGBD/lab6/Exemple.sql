/*1. Creati o tabela ce va contine studentii ce au fost plecati cu o bursa erasmus care sa contina numarul matricol,
numele si prenumele studentilor care au plecat in Erasmus impreuna cu un camp nou care sa indice tara in care au plecat (de exemplu printr-un ID numeric).
--a.Creati un index unic peste coloana reprezentand numarul matricol din noua tabela.
--b.Copiati in tabela nou creata 100 de studenti din tabela studenti alesi in mod aleatoriu si
respectand conditia de unicitate de la punctul 1. Dintre cei 100 de studenti numai cativa vor putea fi copiati, unii vor fi deja existenti in tabela 
cea noua si vor genera exceptii.
--c.Afisati studentii care au fost copiati cu succes si pe cei care nu au putut fi copiati.*/
--dupa cum vedeti este chiar problema 1 din documentul wiki
drop table studenti_erasmus;
/
create table studenti_erasmus(
  nr_matricol varchar2(6),
  nume varchar2(15),
  prenume varchar2(30),
  id_tara int,
  copiat number(1));
/
drop index emp_name_idx;
/
create unique index nr_matricol_idx on studenti_erasmus(nr_matricol);
/
create or replace procedure copie_studenti
is
  p_studenti_copiati clob;--am ales tipul de data clob deoarece vom avea 100 de inregistrari, deci un numar foarte mare de caractere
  p_studenti_necopiati clob;
  p_count number :=0;
  p_count_copiati number :=0;
  cursor c1 is select nr_matricol,nume,prenume from studenti order by 1;
begin
  --delete from studenti_erasmus;
  for c1_record in c1 loop
    begin
      insert into studenti_erasmus(nr_matricol,nume,prenume,id_tara) values (c1_record.nr_matricol,c1_record.nume,c1_record.prenume,dbms_random.value(1,10));
      p_count := p_count + 1;
      
      --initial le punem la toti flagul cu 1, adica presupunem ca au fost toti copiati
      update studenti_erasmus
      set copiat=1
      where nr_matricol=c1_record.nr_matricol;
      p_studenti_copiati:=p_studenti_copiati||' , '||c1_record.nume||'.'||c1_record.prenume;
    exception
      when dup_val_on_index then
        update studenti_erasmus
        set copiat=0
        where nr_matricol=c1_record.nr_matricol;
        p_studenti_necopiati:=p_studenti_necopiati||' , '||c1_record.nume||'.'||c1_record.prenume;
      end;
      exit when p_count =100;--copiem doar 100
  end loop;    
 
  p_studenti_copiati := ltrim(p_studenti_copiati,' , ');
  p_studenti_necopiati := ltrim(p_studenti_necopiati,' , ');
  dbms_output.put_line('Studenti copiati cu succes: ' || p_studenti_copiati);  
  dbms_output.put_line('Au fost copiati cu succes '||p_count||' studenti.');
  dbms_output.put_line('Studenti necopiati: ' || p_studenti_necopiati); 
end;  
/  
--la prima rulare se vor copia toti, deoarece initial tabela studenti_erasmus este goala
exec copie_studenti;
/
select count(*) from studenti_erasmus;
select * from studenti_erasmus order by nr_matricol;
--mai apelam procedura inca o data, deja avem 100 studenti in tabela studenti_erasmus, trebuie sa inseram inca 100, dar nu din aceia ce au fost deja inserati
/
exec copie_studenti;
/
--la a doua rulare, cei deja copiati prima data vor avea 1 in dreptul campului copiat
--problema a fost un pic ambigua ca si cerinta (nu am compus-o eu, doar rezolvarea e personala, eu am refacut cerinta ca sa fie cat mai usor de inteles),
--parerea mea este ca am facut rezolvarea corecta, dar daca aveti voi o alta idee, o puteti spune
select count(*) from studenti_erasmus;
select * from studenti_erasmus order by nr_matricol;


--2.Creati specificatia si corpul unui pachet numit student_pack si care sa contina procedurile: add_stud, upd_stud si del_stud foaie_stud. 
--primele 3 proceduri creeaza operatii DML, iar ultima intoarce foaia matricola a unui student pe baza id-ului sau
create or replace package stud_pack is
  procedure add_stud (IN_student_id in studenti.id%type, IN_nr_matricol studenti.nr_matricol%type, IN_student_name in studenti.nume%type, IN_student_prenume in studenti.prenume%type);
  procedure upd_stud (IN_student_id in studenti.id%type, IN_student_an in studenti.nume%type);
  procedure del_stud (IN_student_id in studenti.id%type);
  procedure foaie_stud (IN_student_id in studenti.id%type);
end;
/
create or replace package body stud_pack
is

procedure add_stud (IN_student_id in studenti.id%type, IN_nr_matricol studenti.nr_matricol%type, IN_student_name in studenti.nume%type, IN_student_prenume in studenti.prenume%type)
is
begin
  --nu am facut cu secventa si nici cu max(id)+1 tocmai ca sa exemplific lucrul cu exceptii, in mod corect si normal se lucra cu secventa
  insert into studenti(id,nr_matricol,nume,prenume) values(IN_student_id, IN_nr_matricol, IN_student_name, IN_student_prenume);
exception
  when dup_val_on_index then
  dbms_output.put_line('Studentul cu id-ul ' ||IN_student_id||' exista in baza de date! ');
end add_stud;

procedure upd_stud (IN_student_id in studenti.id%type, IN_student_an in studenti.nume%type)
is
  e_nu_exista exception;
begin
  update studenti set an=IN_student_an where id=IN_student_id;
  if sql%notfound then 
    raise e_nu_exista;
  end if;
exception
  when e_nu_exista then
  dbms_output.put_line('Studentul cu id-ul '||IN_student_id||' nu se regaseste in baza de date ! ');
  dbms_output.put_line(sqlcode||'  '||sqlerrm);--afisez si codul de eroare Oracle
end upd_stud; 

procedure del_stud (IN_student_id in studenti.id%type)
is
  e_del_stud exception;
begin
  delete from prieteni where id = IN_student_id;
  delete from note where id = IN_student_id;
  delete from studenti where id=IN_student_id;
  if sql%notfound then
    raise e_del_stud;
  end if;
exception
  when e_del_stud then
  dbms_output.put_line('Studentul cu id-ul '||IN_student_id||' nu se regaseste in baza de date !');
end del_stud;  

procedure foaie_stud (IN_student_id in studenti.id%type)
is
  p_counter integer;
  p_daca_exista boolean;
  p_mesaj varchar2(100);
  cursor c1 is 
  select titlu_curs,valoare,c.an,s.nume as numes,s.prenume as prenumes
  from cursuri c join note n on c.id=n.id_curs join studenti s on s.id=n.id_student
  where s.id=IN_student_id
  order by 3;
  begin
    p_daca_exista:=f_exista_student(IN_student_id); --avem deja stocata aceasta functie de la un laborator anterior
    if p_daca_exista=true then
      for c1_record in c1 loop
        p_mesaj:=('Curs '||c1_record.titlu_curs ||' Nota '||c1_record.valoare||' An '||c1_record.an);
        dbms_output.put_line(p_mesaj);
      end loop;
    end if;
end foaie_stud;  

end stud_pack; --am inchis intreg pachetul
/
--apelul 
exec stud_pack.add_stud(1,'ABC','Ionescu','Gigel');
exec stud_pack.add_stud(71711,'XYZ','Ion','Gigi');
/
select * from studenti where id = 71711;--dovada ca s-a inserat
/
exec stud_pack.upd_stud(71711,1);
/
exec stud_pack.del_stud(71712);
/
exec stud_pack.foaie_stud(1);


/*3.
a. Creati o functie sau procedura care sa majoreze bursa unui student (dat prin ID) cu o valoare hardcodata (de exemplu 2000). 
Daca valoarea bursei dupa modificare este mai mare de 3000, ea va fi truncheata la 3000 si se va notifica printr-o exceptie proprie.
b. Apelati functia sau procedura dintr-un bloc anonim pentru macar 100 de studenti. In blocul anonim veti trata exceptia definita de voi si care a fost 
aruncata de catre procedura.
c. Creati un bloc anonim care sa afiseze o lista cu primii 10 studenti bursieri, bursa noua si cu cat a fost majorata fata de bursa precedenta.*/

--a.
create or replace procedure proc_majorare_bursa(IN_id_student in studenti.id%type)
is
  e_prea_multi_bani exception;
  p_bursa studenti.bursa%type;
  p_new_bursa studenti.bursa%type;
  cursor c1 is
  select id,nume,prenume,bursa
  from studenti
  where id=IN_id_student;
  pragma exception_init(e_prea_multi_bani, -20001);
begin
  update studenti
  set bursa=nvl(bursa,0)+2000
  where id = IN_id_student;
  for c1_record in c1 loop
    if c1_record.bursa>3000 then
      raise e_prea_multi_bani;
    end if; 
  end loop;
exception
  when e_prea_multi_bani then
  update studenti
  set bursa=3000
  where id = IN_id_student;
end;  
/
begin
  proc_majorare_bursa(2);
end;
/
--demonstram ca s-a modificat bursa (incepand cu a doua rulare, bursa va fi mereu doar 3000)
select id,bursa from studenti where id=2; 

--b.
--inainte de rularea blocului anonim sa aratam ce burse au studentii inainte de majorare
select id,nvl(bursa,0) as bursa
from studenti
where rownum<=100
order by 1;

-------------------------------------  
declare
  e_prea_multi_bani exception;
  cursor c1 is
  select id,nvl(bursa,0) as bursa
  from studenti
  where rownum<=100;
  pragma exception_init(e_prea_multi_bani, -20001);
begin
  for c1_record in c1 loop
    proc_majorare_bursa(c1_record.id);
  end loop;  
end;    

---dupa rularea blocului anonim, aratam ca s-au modificat bursele
select id,nvl(bursa,0) as bursa
from studenti
where rownum<=100
order by 1;

--c.
--dupa prima rulare la punctul b rulam blocul acesta !
declare
  cursor c1 is
  select *
  from (select id,nvl(bursa,0) as bursa_noua,nvl(bursa,0)-2000 as diferenta, nvl(bursa,0)-nvl(bursa,0)+2000 as majorare from studenti order by 2 desc)
  where rownum<=10;
begin
  dbms_output.put_line('Id student: '||' '||'Bursa noua: '||' '||'Diferenta: '||' '||'Majorare: ');
  for c1_record in c1 loop
    dbms_output.put_line(lpad(c1_record.id,4)||'            '||lpad(c1_record.bursa_noua,5)||'         '||lpad(c1_record.diferenta,5)||'     '||c1_record.majorare);
  end loop;
end;  


/*4.Creati o procedura numita check_prof_curs care verifica combinatia curs-profesor. Puteti folosi orice tip de exceptie doriti.
Testarea sa se faca pentru toate cazurile, adica atunci cand nu exista fie un profesor, fie un curs, cand combinatia nu este corecta
si cand combinatia este corecta. In cazul combinatiei corecte afisati si numele profesorului impreuna cu titlul cursului.*/
--varianta 1 (cred ca stiti varianta asta, e cea cu if-uri, ati avut si o problema intr-un test de la laborator)
create or replace procedure check_prof_curs (IN_curs_id cursuri.id%type, IN_prof_id profesori.id%type)
is
  p_count_curs number(3);
  p_count_prof number(3);
  p_count_curs_prof number(3);
  p_titlu_curs cursuri.titlu_curs%type;
  p_nume_prof profesori.nume%type;
begin

  select count(*) into p_count_curs from cursuri where id=IN_curs_id;
  select count(*) into p_count_prof from profesori where id=IN_prof_id;
  select count(*) into p_count_curs_prof from didactic where id_curs=IN_curs_id and id_profesor=IN_prof_id;
  
  if p_count_curs=0 then dbms_output.put_line('Nu exista cursul !');
  elsif p_count_prof=0 then dbms_output.put_line('Nu exista profesorul !');
  elsif p_count_curs_prof=0 then dbms_output.put_line('Combinatia curs-profesor nu este corecta !');
  else dbms_output.put_line('Combinatia curs-profesor este corecta. ');
    select c.titlu_curs, p.nume
    into p_titlu_curs, p_nume_prof 
    from profesori p join didactic d on p.id = d.id_profesor join cursuri c on c.id = d.id_curs 
    where d.id_profesor = IN_prof_id and d.id_curs = IN_curs_id;
    dbms_output.put_line(p_titlu_curs||' - '||p_nume_prof);
  end if;
end check_prof_curs;
/
exec check_prof_curs(1,1);

--varianta 2 (cea in care se folosesc exceptiile propriu-zise)
create or replace procedure check_prof_curs (IN_curs_id cursuri.id%type, IN_prof_id profesori.id%type)
is
  e_nu_exista_curs exception;
  PRAGMA EXCEPTION_INIT(e_nu_exista_curs, -20001);
  e_nu_exista_prof exception;
  PRAGMA EXCEPTION_INIT(e_nu_exista_prof, -20002);
  e_combinatie_incorecta exception;
  PRAGMA EXCEPTION_INIT(e_combinatie_incorecta, -20003);
  p_count_curs number(3);
  p_count_prof number(3);
  p_count_curs_prof number(3);
  p_titlu_curs cursuri.titlu_curs%type;
  p_nume_prof profesori.nume%type;
begin

  select count(*) into p_count_curs from cursuri where id=IN_curs_id;
    if p_count_curs=0 then raise e_nu_exista_curs; end if;
  select count(*) into p_count_prof from profesori where id=IN_prof_id;
    if p_count_prof=0 then raise e_nu_exista_prof; end if;
  select count(*) into p_count_curs_prof from didactic where id_curs=IN_curs_id and id_profesor=IN_prof_id;
    if p_count_curs_prof = 0 then raise e_combinatie_incorecta;
    else dbms_output.put_line('Combinatia curs-profesor este corecta. ');
      select c.titlu_curs, p.nume
      into p_titlu_curs, p_nume_prof 
      from profesori p join didactic d on p.id = d.id_profesor join cursuri c on c.id = d.id_curs 
      where d.id_profesor = IN_prof_id and d.id_curs = IN_curs_id;
      dbms_output.put_line(p_titlu_curs||' - '||p_nume_prof);
    end if;
    
exception
  when e_nu_exista_curs then raise_application_error (-20001,'Cursul cu id-ul ' || IN_curs_id || ' nu exista in baza de date.');
  when e_nu_exista_prof then raise_application_error (-20002,'Proful cu id-ul ' || IN_prof_id || ' nu exista in baza de date.');
  when e_combinatie_incorecta then raise_application_error (-20003,'Combinatia este incorecta');
  
end check_prof_curs;
/
exec check_prof_curs(1,3);--trebuie sa afiseze si linia si nr erorii, pragma ne da si nr erorii !!!


--asa ceva trebuie sa afiseze
/*BEGIN check_prof_curs(1,3); END;
Error report -
ORA-20003: Combinatia este incorecta
ORA-06512: at "STUDENT.CHECK_PROF_CURS", line 33
ORA-06512: at line 1*/
