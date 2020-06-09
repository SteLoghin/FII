/*1. Instructiunile DML vor fi permise asupra tabelelor doar in timpul orelor normale de program 8:45 dimineata pina la 5:30 dupa-amiaza,
de Luni pana Vineri. 
a) creati o procedura stocata, numita SECURE_DML, care nu se va executa in afara orelor respective caz in care va afisa mesajul :
'Se pot efectua modificari asupra datelor doar in timpul orelor de program'.
b) creati un trigger asupra tabelei STUDENTI care va apela procedura de mai sus.
c) testati procedura modificand, temporar, orele respective si incercati sa inserati o noua linie in tabela STUDENTI.
Dupa testare, refaceti orele din interiorul procedurii conform cu specificatiile de la exercitiul 1*/
create or replace procedure secure_dml
is
begin
  if to_char(sysdate,'dy') in ('sat','sun') or to_char(sysdate,'HH24:MI') not between '08:45' and '17:30' then
    raise_application_error(-20400,'Se pot efectua modificari asupra datelor doar in timpul orelor de program') ;
  end if;
end;
/
create or replace trigger valid_student
before insert or update or delete on studenti
begin
  secure_dml() ;
end;
/
--testare
insert into studenti(id,nr_matricol,nume,prenume) values (seq_ins_studenti.nextval,'abc','Gigel','Ionescu'); 
/
select * from studenti order by 1 desc;


/*2.Creati un trigger care asigura ca toate numele din tabela studenti au fost stocate folosind majuscule pentru prima litera a numelui si a prenumelui.*/
--triggerul este activat de cate ori un nou rand este inserat in tabel sau de cate ori este modificata o inregistrare din acelasi tabel
--astfel, triggerul de fata se activeaza pentru doua instructiuni SQL, in cazul de fata inserare si modificare
create or replace trigger studenti_insert_update
before insert or update on studenti
--se foloseste declansatorul pentru fiecare rand modificat
for each row
begin
  --scrie toate numele si prenumele de studenti cu prima litera majuscula
  :new.nume:=initcap(:new.nume);
  :new.prenume:=initcap(:new.prenume);
end;  

--testarea triggerului 
--se va observa ca desi am scris cu litera mica prima litera a numelui si / sau a prenumelui, triggerul asigura ca insertul se face corect, adica cu majuscula
insert into studenti(id,nr_matricol,nume,prenume) values (seq_ins_studenti.nextval,'abc','gigel','ionescu'); 
/
select max(id) as id,nume,prenume from studenti where id = (select max(id) from studenti) group by nume,prenume;


/*3. Adaugati trei noi coloane in tabelul PROFESORI: salariu, tip_salarizare si salariu_orar.
Modificati salarizarea pentru un profesor in functie de modalitatea de plata:
--daca profesorul trece de la salarizarea la plata cu ora la salariu fix atunci salariul sau se modifica cu +- un procent (de exemplu 10%)*/
alter table profesori add (salariu number(25));
alter table profesori add (tip_salarizare varchar2(25));
alter table profesori add (salariu_orar number(10));
/   
update profesori set salariu = 5000, tip_salarizare='salariu fix', salariu_orar = 50 where id in (1,2);
/
update profesori set salariu = 4000, tip_salarizare='plata cu ora', salariu_orar = 25 where id in (3,4);
/
select * from profesori where id between 1 and 4;

--triggerul este de tip before, astfel incat el poate valida orice modificare in inregistrarile profesorilor inainte ca acestea sa fie salvate in baza de date
--conditia when activeaza triggerul doar cand modul de plata este schimbat
--triggerul valideaza doar schimbarile asupra campului tip_salarizare
create or replace trigger trg_change_tip_salarizare
before update on profesori
for each row when (old.tip_salarizare<>new.tip_salarizare)
declare
  p_sal_nou profesori.salariu_orar%type;
  p_sal_vechi profesori.salariu_orar%type;
  p_ore_lucrate_lunar integer:=160;
  p_limita profesori.salariu_orar%type;
  p_procent number(2,2):=.10;
begin
  /*if :old.tip_salarizare<>:new.tip_salarizare and :old.sal=:new.sal then
    raise_application_error(-20000,'Tipul de salarizare s-a modificat, nu insa si salariul !');
  end if;*/
  
  --se verifica daca noul salariu lunar este cuprins intre +/- 10% din salariul anterior
  if :old.tip_salarizare='plata cu ora' and :new.tip_salarizare='salariu fix' then
    --noul salariu trebuie sa fie + sau - 10% din vechea plata la ora * 160 ore
    p_sal_vechi:=round(:old.salariu_orar*p_ore_lucrate_lunar);--vechiul salariu lunar, in care folosim campul salariu_orar
    p_sal_nou:=:new.salariu; --adica ii dam salariu fix 
    p_limita:=p_procent*p_sal_vechi;
      if abs(p_sal_nou-p_sal_vechi)>p_limita then
        raise_application_error(-20000,'Noul salariu nu este intre + / -'||to_char(p_procent*100)||' % din vechiul salariu !');
      end if;
  elsif :old.tip_salarizare='salariu fix' and :new.tip_salarizare='plata cu ora' then
    --noul salariu trebuie sa fie + sau - 10% din vechiul salariu
    p_sal_vechi:=:old.salariu;--vechiul salariu lunar, in care folosim campul salariu
    p_sal_nou:=round(:new.salariu_orar*p_ore_lucrate_lunar);
    p_limita:=p_procent*(p_sal_vechi*p_ore_lucrate_lunar);
      if abs(p_sal_nou-p_sal_vechi)>p_limita then
        raise_application_error(-20000,'Noul salariu nu este intre + / -'||to_char(p_procent*100)||' % din vechiul salariu !');
      end if;
  else
    raise_application_error(-20000, 'Combinatie incorecta a tipurilor de salarizare: '||:old.tip_salarizare|| ' - ' ||:new.tip_salarizare);
  end if;
end;  

--testarea declansatorului
/*se incearca modificarea cu un tip de data invalid 'salariu PFA' este un cod invalid*/
update profesori set tip_salarizare='salariu PFA', salariu_orar=45 where id=1;

/*actualizeaza tipul de salarizare cat si valoarea, dar noul salariu lunar este cu peste 10% mai mare sau mai mic decat salariul anterior
vechiul salariu este de 4000, noul salariu ar trebui cuprins in intervalul (4000 - 400; 4000 + 400), se observa ca valoarea 3000 nu este in interval*/
update profesori set tip_salarizare='salariu fix',salariu=3000 where id=3;

/*actualizeaza tipul de salarizare cat si valoarea salariului, acesta fiind in interval !*/
update profesori set tip_salarizare='salariu fix',salariu=3800 where id=3;
/
select * from profesori where id = 3;


/*4. Construiti un trigger care sa faca log la toate modificarile aparute in tabela note (va contine un timestamp, si operatia in sine*/
drop table log_table cascade constraints;
/
create table log_table(
  id_student number,
  id_curs char(4),
  valoare number(2),
  data_notare timestamp,
  action char(10)
  );
/
CREATE OR REPLACE TRIGGER trg_log_table
AFTER INSERT OR UPDATE OR DELETE ON note
FOR EACH ROW
begin
	if updating then 
		INSERT INTO log_table (id_student, id_curs, valoare, data_notare, action)
		VALUES (:old.id_student, :old.id_curs, :new.valoare, :new.data_notare, 'updating');
	end if;
	if inserting then
		INSERT INTO log_table (id_student, id_curs, valoare, data_notare, action)
		VALUES (:new.id_student, :new.id_curs, :new.valoare, :new.data_notare, 'inserting');
	end if;
	if deleting then
		INSERT INTO log_table (id_student, id_curs, valoare, data_notare, action)
		VALUES (:old.id_student, :old.id_curs, :old.valoare, :old.data_notare, 'deleting');
	end if;
end;
/
--verificare
select * from note where id_student = 1 order by id_student;
delete from note where id=1 and id_curs=1;
insert into note values(seq_ins_note.nextval,1,1,10,sysdate,sysdate,sysdate);
/
desc note;
/
delete from log_table;
select * from log_table;


/*5. Creati un trigger la nivel de clauza care sa stabileasca conditia ca un profesor nu are voie sa tina mai mult de 10 cursuri.*/
--cream o secventa pentru a insera datele in tabela didactic (in scopul verificarii functionarii corecte a triggerului)
--1p realizare trigger + 1p testare
drop sequence seq_ins_didactic
/
create sequence seq_ins_didactic
start with 100 
increment by 1 
maxvalue 10000;
/
--acest select imi permite sa vad profesorul cu cele mai multe cursuri
select id_profesor,count(*) as nr_cursuri from didactic group by id_profesor having count(*) = (select max(count(*)) from didactic group by id_profesor);
/
--trigger la nivel de clauza
create or replace trigger trg_verificare_nr_materii
after insert on didactic
declare
  cursor c1 is 
  select id_profesor, count(*) as nr from didactic group by id_profesor;
begin
  for c1_record in c1 loop
    if c1_record.nr>10 then
      raise_application_error(-20500,'Un profesor nu poate tine mai mult de 10 cursuri !') ;
    end if;
  end loop;
end; 
/
--testare pentru a vedea detaliile despre proful cu cele mai multe cursuri
--la mine are 7 cursuri
select * from didactic where id_profesor = 21 order by id_curs;
/
insert into didactic values (seq_ins_didactic.nextval,21,1,null,null);--inserez al 8-lea curs - merge
insert into didactic values (seq_ins_didactic.nextval,21,2,null,null);--inserez al 9-lea curs - merge
insert into didactic values (seq_ins_didactic.nextval,21,3,null,null);--inserez al 10-lea curs - merge
insert into didactic values (seq_ins_didactic.nextval,21,4,null,null);--inserez al 10-lea curs - nu mai merge, se activeaza triggerul

/*6.Creati si mai apoi testati un trigger la nivel de linie prin care nota unui student poate doar sa creasca, niciodata sa scada*/
create or replace trigger trg_verificare_nota
after update of valoare on note
for each row
begin
  if :new.valoare<:old.valoare then
    raise_application_error(-20500,'Nota nu poate sa scada !') ;
  end if;
end;
/
--verificare (vrem sa ii scadem o nota studentului cu id-ul 1)
select * from note where id_student = 1;
/
--testare (evident la voi sunt alte valori)
--scadem nota - nu trebuie sa functioneze !!
update note set valoare = 5 where id_student = 1 and id_curs = 1;
--crestem nota - trebuie sa functioneze
update note set valoare = 10 where id_student = 1 and id_curs = 1;


select * from note;


