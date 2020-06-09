--Functie ajutatoare pe care o vom folosi in proceduri ca sa verificam existenta studentului;
/*1.Scrieti o functie care sa verifice daca un student, pe baza unui id, exista in baza de date.*/
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

/*2. Construiti o procedura si apoi o functie care sa returneze in doi parametri de iesire
valorile mediilor din anii trecuti pentru un student al carui ID este dat intr-un
parametru de tip IN. Exemplificati utilizarea ei intr-un bloc anonim.
Folositi de asemenea (in cadrul procedurii) si functia care verifica daca studentul, dat prin ID, exista in baza de date !*/
--varianta cu procedura 1
create or replace procedure get_medii_student(IN_id IN studenti.id%type, OUT_medie1 OUT float, OUT_medie2 OUT float)
as
  p_an number(1);
  p_exist boolean;
BEGIN
  p_exist := f_exista_student(IN_id);
  if p_exist = true then
    select an into p_an from studenti where id=IN_id;
    if (p_an=1) then 
      DBMS_OUTPUT.PUT_LINE('Studentul cu id-ul ' ||IN_id|| ' este in anul 1 si nu are medie !');
    elsif(p_an=2) then
      select trunc(avg(valoare),2) into OUT_medie1 from note n join cursuri c on c.id=n.id_curs where id_student=IN_id and an=1;
      DBMS_OUTPUT.PUT_LINE('Media din anul I este : ' || OUT_medie1);
    elsif(p_an=3) then
      select trunc(avg(valoare),2) into OUT_medie1 from note n join cursuri c on c.id=n.id_curs where id_student=IN_id and an=1;
      DBMS_OUTPUT.PUT_LINE('Media din anul I este : ' || OUT_medie1);
      select trunc(avg(valoare),2) into OUT_medie2 from note n join cursuri c on c.id=n.id_curs where id_student=IN_id and an=2;
      DBMS_OUTPUT.PUT_LINE('Media din anul II este : ' || OUT_medie2);
    else null;  
    end if;
  end if;
end;
/
--apelul
declare
  p_nr_matricol NUMBER:=899;
  p_medie1 NUMBER(4,2);
  p_medie2 NUMBER(4,2);
BEGIN
  get_medii_student(p_nr_matricol,p_medie1,p_medie2);
END;

--varianta cu procedura 2
create or replace procedure get_medii_student_1(IN_id IN studenti.id%type, OUT_medie1 OUT float, OUT_medie2 OUT float) 
as
  p_exist boolean;
begin
  p_exist := f_exista_student(IN_id);
    if p_exist = true then 
      select trunc(avg(valoare),2)
      into OUT_medie1 
      from note n join cursuri c on n.id_curs=c.id 
      where an=1 and n.id_student = IN_id;
      select trunc(avg(valoare),2)
      into OUT_medie2
      from note n join cursuri c on n.id_curs=c.id 
      where an=2 and n.id_student = IN_id;
  end if;
end;
/
DECLARE 
  p_id studenti.id%type:='1111';
  OUT_medie1 number(4,2);
  OUT_medie2 number(4,2);
BEGIN
  get_medii_student_1(p_id,OUT_medie1,OUT_medie2);
  DBMS_OUTPUT.PUT_LINE('ID : '|| p_id);
  DBMS_OUTPUT.PUT_LINE('Medie an 1 : '||OUT_medie1);  
  DBMS_OUTPUT.PUT_LINE('Medie an 2 : '||OUT_medie2);
end;   

--varianta cu functie
create or replace type medii_student_object as object(id number,medie_an1 number,medie_an2 number);
/
create or replace type medii_student_table is table of medii_student_object;
/
create or replace function get_medii_student_fc(IN_id studenti.id%type)
return medii_student_table
is
  medii_student_arr medii_student_table:=medii_student_table();
  p_an studenti.id%type;
begin
  select an into p_an from studenti where id=IN_id;
  if (p_an=1) then null;
  elsif (p_an=2) then
    select medii_student_object(id_student,medie_an1,null)
    bulk collect into medii_student_arr
    from
    (select id_student as id_student, trunc(avg(n.valoare),2) as medie_an1,null
    from note n join cursuri c on c.id=n.id_curs
    where id_student = IN_id and an=1
    group by id_student);
  elsif (p_an=3) then
    select medii_student_object(id_student,medie_an1,medie_an2)
    bulk collect into medii_student_arr
    from
    (select id_student as id_student, trunc(avg(n.valoare),2) as medie_an1, null as medie_an2
    from note n join cursuri c on c.id=n.id_curs
    where id_student = IN_id and an=1
    group by id_student
    union
    select id_student as id_student, null as medie_an1, trunc(avg(n.valoare),2) as medie_an2
    from note n join cursuri c on c.id=n.id_curs
    where id_student = IN_id and an=2
    group by id_student);
  end if;
  return medii_student_arr;
end;
/
select * from table (get_medii_student_fc(123));


/*3.Scrieti o procedura ce returneaza varsta unui student (in ani, luni si zile).
Studentul se stabileste random, astfel incat nu este nevoie de utilizarea functiei care verifica existenta lui !*/
create or replace procedure p_afiseaza_varsta
  is
  p_numar_studenti number(5);
  p_student_random number(5);
  p_rezultat VARCHAR(1000);
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
/
--apelul
exec p_afiseaza_varsta;


/*4. Construiti o functie care sa returneze ca si sir de caractere situatia
scolara a unui student al carui ID este dat ca parametru. Exemplificati
utilizarea functiei intr-un select ce returneaza rezultatul functiei pentru fiecare
dintre studenti. Utilizati procedura stocata de la punctul 2.*/
--exemplificarea modului in care se apeleaza o procedura intr-o functie
create or replace function get_situatie(IN_id IN studenti.id%type) 
return varchar2 
IS
  p_medie1 number;
  p_medie2 number;
  p_an studenti.an%type;
  p_rezultat varchar2(1000) := 'nothing here';
begin   
  --se apeleaza procedura de la exemplul 2
  get_medii_student(IN_id, p_medie1, p_medie2);
  select nume || ' ' || prenume, an 
  into p_rezultat,p_an 
  from studenti
  where id = IN_id;
  dbms_output.put_line(p_an);
  p_medie1 := round(p_medie1,2);
  p_medie2 := round(p_medie2,2);
  case (p_an)
    when (2) then p_rezultat := p_rezultat || ' este in anul 2 si in anul 1 a avut media ' || p_medie1;
    when (3) then p_rezultat := p_rezultat || ' este in anul 3 si in anii precedenti a avut mediiile ' || p_medie1 || ' respectiv ' || p_medie2;             
  else 
    p_rezultat := p_rezultat || ' este in anul 1';       
  end case;
  return p_rezultat;
end;
/
--utilizarea functiei in select
select get_situatie(ID) as situatie_scolara from studenti where id=1000;  


/*5.Construiti o procedura care sa afiseze toate relatiile de prietenie dintre studenti aflate intre id-urile 3000 si 4000 si care 
student apare de cele mai multe ori in acel interval. Inserati aceste inregistrari intr-o noua tabela denumita interval_prieteni*/
drop table interval_prieteni;
/
create table interval_prieteni(id_student1 number,id_student2 number);
/
create or replace procedure get_interval_prieteni
as 
  p_student1_arr num_arr;
  p_student2_arr num_arr;
begin
  select student1, student2
  bulk collect into p_student1_arr, p_student2_arr
  from
    (select s1.id as student1, s2.id as student2
    from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
    where p.id between 3000 and 4000 order by 1);
  
  if p_student1_arr.count<>0 then 
    forall i in p_student1_arr.first .. p_student1_arr.last
      insert into interval_prieteni(id_student1, id_student2) values (p_student1_arr(i), p_student2_arr(i));
  end if;
  
end;
/
exec get_interval_prieteni;
/
select * from interval_prieteni;
    


