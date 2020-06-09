/*1. Se observa ca in fiecare tabela avem cate o cheie primara surogat (care doar identifica in mod unic inregistrarile). Aceasta cheie poarta numele de ID in toate tabelele.
Deoarece toate tabele au ca si primary key chei surogat, este posibil ca macar una din cheile straine din tabelele care le referentiaza sa aiba valori de null.
De exemplu, cheia primara in tabela NOTE este id. In aceeasi tabela mai avem 2 chei straine si anume id_student si id_curs, amandoua formand o cheie unica (in exercitiul 3
aveti de pus voi o constrangere care sa faca acea combinatie de campuri sa fie UNIQUE). Din cauza ca perechea (id_student, id_curs) nu intra in componenta unei chei primare
(precum in tabela NOTE de la BD din semestrul 1), cele doua campuri pot lua valori de null. Fix acelasi lucru pentru tabela DIDACTIC.

Totusi, in cazul de fata, deoarece in tabela NOTE, atat id_student cat si id_curs sunt setate de la inceput ca fiind NOT NULL, nu pot lua valori de null !!!
Dar numai din aceasta cauza. Idem in cazul tabelei DIDACTIC.*/

/*2. Este explicat in documentul wiki, practic nu aveti de urmat decat de acolo.*/

--3.Constrangere ca un student sa nu aiba 2 note diferite la o aceeasi materie
--intai afisam toate notele unui anumit student
select s.id, s.nr_matricol, s.nume, s.prenume, c.id, c.titlu_curs, n.valoare
from studenti s join note n on n.id_student=s.id join cursuri c on c.id=n.id_curs
where s.id = 100;
/
--stergem constraintul in caz ca deja exista
alter table note drop constraint un_valoare_curs;

--adaugam constraintul ca un student ca nu aiba 2 note diferite la aceeasi disciplina
--datele sunt generate random, la voi cu siguranta vor fi alte date, important e ca constraintul sa fie scris corect (am facut si la BD constraintul asta)
alter table note add constraint un_valoare_curs unique(id_student,id_curs);

--dupa ce afisati notele studentului incercati sa inserati  o alta nota la un curs la care el are deja nota
insert into note (id,id_student,id_curs,valoare) values (5555,100,1,6);

--4.Aflati grupa din facultate care are coeziunea cea mai mare (are raportul dintre prietenii interioare grupei versus numar de studenti din grupa maxim).
--afisam, pentru fiecare grupa, nr de studenti, nr de prietenii precum si coeziunea ceruta in problema
--am facut sortarea dupa coeziune
select s1.an, s1.grupa, count(distinct s1.id) as nr_studenti, count(p.id_student1) as nr_prietenii,
  trunc(count(p.id_student1)/count(distinct s1.id),2) as coeziune
from studenti s1 join prieteni p on s1.id=p.id_student1 join studenti s2 on s2.id=p.id_student2
group by s1.an, s1.grupa
order by 5 desc;

--acum facem doar maximul coeziunii (deci asta e selectul care ni se cere in problema)
--deci acel count(p.id_student1)/count(distinct s1.id), adica a 5- coloana din selectul de mai sus trebuie sa fie maxim !
select s1.an, s1.grupa,trunc(count(p.id_student1)/count(distinct s1.id),2) as coeziune
from studenti s1 join prieteni p on s1.id=p.id_student1 join studenti s2 on s2.id=p.id_student2
group by s1.an, s1.grupa
having count(p.id_student1)/count(distinct s1.id)=
  (select max(count(p.id_student1)/count(distinct s1.id))
  from studenti s1 join prieteni p on s1.id=p.id_student1 join studenti s2 on s2.id=p.id_student2
  group by s1.an, s1.grupa)
order by 3 desc;

--5.Adaugati o studenta "Popescu Crina-Nicoleta" si puneti-i nota 10 la materia Baze de date.  
--5.1 Cream mai intai o secventa care sa genereze id-uri de studenti in mod automat
drop sequence seq_ins_studenti;
/
create sequence seq_ins_studenti
start with 5000
increment by 1;
/

--5.2 Inseram studentul in tabela de studenti pe baza secventei
insert into studenti (id,nr_matricol,nume,prenume,an,grupa) select seq_ins_studenti.nextval,'ABCDR','Popescu','Crina-Nicoleta',2,'A4' from dual; 
/
--ne asiguram ca a fost inserata
select * from studenti where id=(select max(id) from studenti);

--5.3 Cream o secventa pentru generarea de id-uri in tabela de note
drop sequence seq_ins_note;
/
create sequence seq_ins_note
start with 20000
increment by 1;

--5.4 Inseram o linie in tabela de note prin care atribuim nota 10 la BD studentei inserate mai devreme
insert into note (id, id_student, id_curs, valoare) 
select seq_ins_note.nextval, (select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu'), 
  (select id from cursuri where titlu_curs = 'Baze de date'), 10
from dual;

--dovada ca s-a inserat
select * from note where id = (select max(id) from note);

--6.Adaugati doua relatii de pretenie dintre Crina si doua colege din grupa sa.
select max(id) from prieteni;--aflam id-ul maxim din tabela prieteni pentru a sti de unde pornim secventa 
/
drop sequence seq_ins_prieten;
/
create sequence seq_ins_prieten
start with 20001
increment by 1;
/
--inseram prima relatie de prietenie (prenume like '%a' deoarece ni se cere sa fie colega a Crinei, adica fata)
--grupa Crinei am presupus-o de la inceput ca fiind A4 din anul 2, aici chiar nu se poate altfel decat cu hardcodare
--de exemplu presupunem ca prietena Crinei este studenta cu id-ul minim din grupa scrisa mai sus
insert into prieteni(id,id_student1,id_student2) 
  select seq_ins_prieten.nextval, (select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu'), 
    (select min(id) from studenti where an=2 and grupa='A4' and prenume like '%a') from dual;
/
--inseram a doua relatie de prietenie (a doua prietena este studenta cu al doilea id ca minim)
insert into prieteni(id,id_student1,id_student2) 
  select seq_ins_prieten.nextval, (select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu'), 
    (select id from studenti where id > (select min(id) from studenti where an=2 and grupa='A4' and prenume like '%a') and an=2 and grupa='A4' and prenume like '%a' and rownum = 1) from dual; 
    
/    
--dovada ca s-a inserat (acum trebuie sa avem deci doua inregistrari)
select s1.id || ' ' ||s1.prenume||' '|| s1.nume as studenta, s2.id || ' ' ||s2.prenume||' '|| s2.nume as prietena
from studenti s1 join prieteni p on p.id_student1 = s1.id join studenti s2 on s2.id=p.id_student2
where p.id_student1 = (select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu');
--100:Diana, 35:Monica


--7.Stergeti din baza de date pe una din colegele Crinei care era prietena cu ea (pentru ca s-a transferat la alta facultate).  
  
--7.1 mai intai o afisam
select n.id_student, n.id_curs, n.valoare, s.nume, s.prenume 
from note n join studenti s on s.id = n.id_student 
where n.id_student = 
  (select min(s2.id)
  from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
  where s1.id=(select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu')); 
  
--7.2 apoi o stergem mai intai din prima tabela copil, adica note
--ar trebui sa se stearga exact cate randuri obtin in selectul de la 7.1 (adica cel de mai sus)
delete from note
where id_student = 
  (select min(s2.id)
  from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
  where s1.id=(select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu')); 
  
--dovada ca s-a sters din note (adica colega Crinei cu id-ul mai mic nu trebuie sa mai apara)
--adica nu trebuie sa mai apara nici un rand 
select n.id_student, n.id_curs, n.valoare, s.nume, s.prenume 
from note n join studenti s on s.id = n.id_student 
where n.id_student = 
  (select min(s2.id)
  from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
  where s1.id=(select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu')); 
  
--7.3 acum o stergem din a doua tabela in care este referita si anume tabela prieteni
--acum o stergem, trebuie sa se stearga atatea randuri cate sunt in selectul de la 7.3  
--atentie !!! relatia de prietenie este in ambele sensuri, astfel incat studentul pe care il vom sterge va apare si ca id_student1 si ca id_student2
--select * from studenti where prenume = 'Ana'; --30
delete from prieteni
where id_student2 = 
  (select min(s2.id)
  from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
  where s1.id=(select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu'))
  or id_student1 = 
  (select min(s2.id)
  from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
  where s1.id=(select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu'));
       
--7.4 acum, dupa ce am sters-o din cele doua tabele copil
--dorim sa o stergem si din tabela parinte si anume studenti, dar mai intai o afisam (trebuie sa apara o singura inregistrare, adica prietena Crinei)*/
--am select min(s2.id)-1, deoarece acum noul minim, dupa ce am sters-o din tabelele copil pe cea cu id-ul mai mic devine automat id-ul colegei cu id mai mare
select * from studenti
where id = 
  (select min(s2.id)
  from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2
  where s1.id=(select id from studenti where prenume = 'Crina-Nicoleta' and nume = 'Popescu'));
  
--in sfarsit o stergem si din tabela parinte, adica tabela studenti 
delete from studenti
where id = (select min(id) from studenti where an=2 and grupa='A4' and prenume like '%a');

--mai facem o data selectul de mai sus inca o data pentru a ne asigura ca nu mai este nici in tabela studenti  
select * from studenti
where id = 
  (select min(id) from studenti where an=2 and grupa='A4' and prenume like '%a');
  
  
--8.Afisati studentii care au bursa mai mare de 1350
select id,nr_matricol,nume,prenume,grupa,an,bursa
from studenti
where bursa>1350
order by 5,6,7 desc;

--------------VIEWS
drop view bursieri_fruntasi;
CREATE VIEW bursieri_fruntasi AS SELECT * FROM studenti WHERE BURSA>1350;
select * from bursieri_fruntasi order by 1;
UPDATE studenti SET bursa=1400 WHERE id=1;--are loc si insertul in view
SELECT * FROM bursieri_fruntasi order by 1;--dovada ca s-a inserat (trebuie sa avem o linie in plus in view, adica studentul cu id-ul 1)
--ii schimbam bursa la 1200 din tabela
update studenti set bursa = 1200 where id=1;
--astfel va fi eliminat din view
SELECT * FROM bursieri_fruntasi order by 1;
--facem acum update-ul direct pe view 
update bursieri_fruntasi set bursa = 1200 where id=1;
--nu se intampla nimic, nu va fi inserat in view !
SELECT * FROM bursieri_fruntasi order by 1;

--inseram doi studenti in view, unul cu o bursa sub 1350, altul cu o bursa peste 1350
insert into bursieri_fruntasi values(1998,'123AB1','NUME1','PRENUME1',3,'B1',200,sysdate, 'aaa@gmail.com', sysdate, sysdate);
insert into bursieri_fruntasi values(1999,'123AB2','NUME2','PRENUME2',2,'B2',1400,sysdate, 'abc@gmail.com', sysdate, sysdate);
--se insereaza in view doar studentul cu bursa peste 1350
SELECT * FROM bursieri_fruntasi order by 1;
select * from studenti where id in (1998,1999);--dar in baza de date s-au inserat amandoi
delete from bursieri_fruntasi where id in (1998,1999);--se sterge, evident, doar o singura linie
select * from studenti where id in (1998,1999);--la fel, s-a sters doar acela ce era in view
desc user_views;
select * from user_views where view_name='BURSIERI_FRUNTASI';
--construiti un view prin intermediul caruia sa fie afisat catalogul pentru materia Logica la grupa B3 din anul 2 (se vor afisa doar numele, prenumele si valoarea notei).
--Modificati nota primului student din catalog (in ordine alfabetica dupa nume apoi dupa prenume) in 10.
drop view v_logica_B3_An2;
/
create or replace view v_logica_B3_An2 as
select s.id,nume,prenume,valoare
from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs
where titlu_curs='Logicã' and c.an=1 and grupa='B3' and s.an=2
order by 1;
/
select * from v_logica_B3_An2
order by 2,3,1;


select * from studenti where prenume='Sabina';

--Modificati nota primului student din catalog (in ordine alfabetica dupa nume apoi dupa prenume) in 10.
update v_logica_B3_An2
set valoare=10
where (nume,prenume) = (select nume,prenume
                       from
                       (select nume,prenume,rownum as rn
                       from (select * from v_logica_B3_An2) order by nume) where rn=1);
  

select * from (select id, rank() over (order by id) as poz from studenti where grupa = 'A4' and an = 2 and prenume like '%a') where poz = 1;
                        
             
