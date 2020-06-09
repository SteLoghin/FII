/*1. Scrieti o functie care sa compare doua date calendaristice din punctul de vedere al unei facturi. 
Sa se determine daca factura poate sa mai astepte pana ce va fi platita, daca data scadenta este azi sau daca deja s-a intarziat cu plata.*/

create or replace function get_scadenta (IN_data_scadenta date)
return varchar2
is
  p_detail varchar2(100);
begin
  if IN_data_scadenta = sysdate then
    p_detail := 'Data scadenta este azi';
  elsif IN_data_scadenta > sysdate then
    p_detail := 'Plata poate sa mai astepte';
  else
    p_detail := 'Sunteti in intarziere cu plata !';  
  end if;
  return p_detail;
end; 
/
--apelul functiei
select get_scadenta(to_date('15-12-2019','dd-mm-yyyy')) from dual;


/*2.Consideram ca bursele se impoziteaza cu un procent in functie de marimea acesteia. 
Scrieti o functie care, avand ca parametru un anumit student (dat prin ID-ul sau - din tabela studenti), 
sa returneze bursa neta a acestuia. Bursele pana la 999 inclusiv nu se impoziteaza, cele intre 1000 si 1099 se impoziteaza 
cu 10%, bursa intre 1100 si 1199 cu 20%, iar cele de minim 1200 se impoziteaza cu 40%.*/
create or replace function get_bursa_neta(IN_id studenti.id%type) 
return varchar2
is
  p_impozit number:=0;
  p_bursa_neta number:=0;
  p_bursa number:=0; 
  p_detail varchar2(200);
  p_exista_bursa number;
begin
  select count(bursa) into p_exista_bursa from studenti where id = IN_id;
    if p_exista_bursa = 0 then p_detail:='Studentul nu are bursa'; 
    else
      select bursa into p_bursa from studenti where id=IN_id;
      if p_bursa <1000 then p_impozit := 0; 
      elsif p_bursa between 1000 and 1099 then p_impozit := p_bursa * 0.1;
      elsif p_bursa between 1100 and 1199 then p_impozit := p_bursa * 0.2;
      elsif p_bursa>=1200 then p_impozit := p_bursa * 0.4;
      end if;
        p_bursa_neta:=p_bursa-p_impozit;
        p_detail:='Studentul cu id-il'||IN_id||' are bursa '||p_bursa||' si bursa neta de '||p_bursa_neta;
    end if;
  return p_detail;
END get_bursa_neta;
/
--apelul functiei
select get_bursa_neta(69) from dual;


/*3.Exemplu de functie care returneaza un array 
--Creati o functie care sa intoarca o lista cu id-urile studentilor ce au luat 10 la Baze de date*/
--in acest exemplu intorc doar date dintr-o singura coloana (si anume id-urile studentilor)
create or replace function get_students_id
return num_arr
is
  p_students_id_arr num_arr;
begin
  select student_id
  bulk collect into p_students_id_arr
  from
  (select s.id as student_id
  from studenti s join note n on n.id_student = s.id join cursuri c on c.id = n.id_curs
  where titlu_curs = 'Baze de date' and valoare = 10);
  return p_students_id_arr;
end;
/
--apelul functiei
select * from table (get_students_id) order by 1;

--in acest exemplu intorc si alte date decat id-uri, adica voi returna un tabel cu id-uri, nume si prenume
create or replace type student_object is object
(
  student_id number,
  student_nume varchar2(100),
  student_prenume varchar2(100)
);
/
create or replace type student_table is table of student_object;
/
create or replace function get_students_details
return student_table
is
  student_table_arr student_table:=student_table();
begin
  select student_object (student_id,student_nume,student_prenume)
  bulk collect into student_table_arr
  from
  (select s.id as student_id, s.nume as student_nume, s.prenume as student_prenume
  from studenti s join note n on n.id_student = s.id join cursuri c on c.id = n.id_curs
  where titlu_curs = 'Baze de date' and valoare = 10); 
  return student_table_arr;
end;
/
--apelul functiei
select * from table (get_students_details) order by 1;


/*4.Scrieti o functie care returneaza distributia pe zodii a studentilor.*/
drop table zodiac;
/
create table zodiac(
  id_zodie number(10) primary key,
  nume_zodie varchar2(30),
  data_inceput varchar2(10),
  data_sfarsit varchar2(10)); 
/
insert into zodiac values(1,'berbec', '21-03', '20-04');
insert into zodiac values(2,'taur', '21-04', '21-04');
insert into zodiac values(3,'gemeni', '22-05', '21-06');
insert into zodiac values(4,'rac', '22-06', '22-07');
insert into zodiac values(5,'leu', '23-07', '22-08');
insert into zodiac values(6,'fecioara', '23-08', '21-09');
insert into zodiac values(7,'balanta', '22-09', '22-10');
insert into zodiac values(8,'scorpion', '23-10', '21-11');
insert into zodiac values(9,'sagetator', '22-11', '20-12');
insert into zodiac values(10,'capricorn', '21-12', '19-01');
insert into zodiac values(11,'varsator', '20-01', '18-02');
insert into zodiac values(12,'pesti', '19-02', '20-03');
/
create or replace type repartitie_zodii_object is object
(
  nume_zodie varchar2(100),
  nr_studenti number
);
/
create or replace type repartitie_zodii_table is table of repartitie_zodii_object;
/
create or replace function get_repartitie_zodii
return repartitie_zodii_table
is
  repartitie_zodii_table_arr repartitie_zodii_table:=repartitie_zodii_table();
begin
  select repartitie_zodii_object (nume_zodie,distributie)
  bulk collect into repartitie_zodii_table_arr
  from
  (select nume_zodie,count(*) as distributie
  from zodiac z join studenti s on to_date(to_char(s.data_nastere,'DD-MM'),'DD-MM') between to_date(z.data_inceput, 'DD-MM') and to_date(z.data_sfarsit, 'DD-MM')
  group by nume_zodie); 
  return repartitie_zodii_table_arr;
end;
/
--apelul functiei 
select * from table (get_repartitie_zodii) order by 2 desc;


/*5. Construiti o functie care sa indice (prin intermediul ID-urilor)
care sunt prietenii care au valorile mediilor trunchiate egale (de exemplu daca studentul cu ID-ul 1 are media 7.25 si are ca si prieteni pe 
studentii cu ID-urile 2 (cu 8.33), 3 (cu 7.99) respectiv 4 (cu 7.25), se vor afisa cuplurile 1-3 si 1-4). 
Daca studentul nu exista in baza de date, afisati un mesaj corespunzator*/
create or replace type medii_intregi_prieteni_object is object
(
  id_student1 number,
  nume_student1 varchar2(100),
  prenume_student1 varchar2(100),
  medie_student1 number,
  medie_intreaga_student1 number,
  id_student2 number,
  nume_student2 varchar2(100),
  prenume_student2 varchar2(100),
  medie_student2 number,
  medie_intreaga_student2 number
);
/
create or replace type medii_intregi_prieteni_table is table of medii_intregi_prieteni_object;
/
create or replace function get_medii_intregi_prieteni(IN_id studenti.id%type)
return medii_intregi_prieteni_table
is
  medii_intregi_prieteni_arr medii_intregi_prieteni_table:=medii_intregi_prieteni_table();
begin
  select medii_intregi_prieteni_object (id1,nume1,prenume1,medie1,medie_intreaga1,id2,nume2,prenume2,medie2,medie_intreaga2)
  bulk collect into medii_intregi_prieteni_arr
  from
    (select s1.id as id1, s1.nume as nume1, s1.prenume as prenume1, trunc(avg(n1.valoare),2) as medie1, trunc(avg(n1.valoare)) as medie_intreaga1,
            s2.id as id2, s2.nume as nume2, s2.prenume as prenume2,trunc(avg(n2.valoare),2) as medie2, trunc(avg(n2.valoare)) as medie_intreaga2
    from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2 
        join note n1 on s1.id=n1.id_student join note n2 on s2.id=n2.id_student
    where id_student1=IN_id
    group by s1.id, s1.nume, s1.prenume, s2.id, s2.nume, s2.prenume
    having trunc(avg(n1.valoare)) = trunc(avg(n2.valoare)));
  return medii_intregi_prieteni_arr;
end;
/
--apelul functiei
select * from table (get_medii_intregi_prieteni(1));


/*6. Avand doua IDuri de studenti (hardcodate), scrieti o functie care sa compare mediile lor.*/
create or replace type medii_studenti_object is object
(
  id_student1 number,
  nume_student1 varchar2(100),
  prenume_student1 varchar2(100),
  medie_student1 number,
  id_student2 number,
  nume_student2 varchar2(100),
  prenume_student2 varchar2(100),
  medie_student2 number
);
/
create or replace type medii_studenti_table is table of medii_studenti_object;
/
create or replace function compara_studenti (IN_id1 studenti.id%type,IN_id2 studenti.id%type)
return
  medii_studenti_table
is
  medii_studenti_arr medii_studenti_table:=medii_studenti_table();
  p_castigator varchar2(100);
begin
  select medii_studenti_object(id_student1,nume_student1,prenume_student1,medie_student1,id_student2,nume_student2,prenume_student2,medie_student2)
  bulk collect into medii_studenti_arr
  from
    (select s1.id as id_student1, s1.nume as nume_student1, s1.prenume as prenume_student1, trunc(avg(n1.valoare),2) as medie_student1,
            s2.id as id_student2, s2.nume as nume_student2, s2.prenume as prenume_student2, trunc(avg(n2.valoare),2) as medie_student2
    from studenti s1 join note n1 on s1.id=n1.id_student join studenti s2 on s1.id<>s2.id join note n2 on n2.id_student=s2.id
    where s1.id = IN_id1 and s2.id = IN_id2
    group by s1.id,s1.nume,s1.prenume,s2.id,s2.nume,s2.prenume);
  return medii_studenti_arr;
end;
/
select * from table (compara_studenti(1,2));


  