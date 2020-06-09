create or replace function nota_recenta_student(pi_matricol in char)
return varchar2
as
    nota_recenta integer;
    mesaj   varchar2(32767);
begin
    select valoare into nota_recenta from ( select valoare from note 
    where id_student=pi_matricol order by data_notare desc) where rownum<=1;
      mesaj        := 'Cea mai recenta nota a studentului cu matricolul ' || pi_matricol || ' este ' || nota_recenta || '.';
    RETURN MESAJ;
END nota_recenta_student;

--va returna null
--select nota_recenta_student(-1) from dual;

select nota_recenta_student(120) from dual;

create or replace function nota_recenta_student(pi_matricol in CHAR) 
return varchar2
as
    nota_recenta integer;
    mesaj   varchar2(32767);
    counter     INTEGER;
begin
    select valoare into nota_recenta from ( select valoare from note where 
        id_student=pi_matricol order by data_notare desc) where rownum<=1;
      mesaj        := 'Cea mai recenta nota a studentului cu matricolul ' || pi_matricol || ' este ' || nota_recenta || '.';
    return mesaj;
EXCEPTION 
WHEN no_data_found then
    select count(*) into counter from studenti where id=pi_matricol;
    if counter=0 then
            mesaj   := 'Studentul cu matricolul ' || pi_matricol || ' nu exista in baza de date.';
    else
        select count(*) into counter from note where id_student=pi_matricol;
        if counter=0 then
                  mesaj   := 'Studentul cu matricolul ' || pi_matricol || ' nu are nici o nota.';
        end if;
    end if;
return mesaj;
end nota_recenta_student;

select nota_recenta_student(200) from dual;

create or replace function nota_recenta_student(
pi_id_student  in studenti.id%type) return varchar2
as
    nota_recenta integer;
    mesaj   varchar2(32767);
    counter integer;
begin
    select valoare into nota_recenta from ( select valoare from note where
    id_student=pi_id_student order by data_notare desc) where rownum<=1;
      mesaj        := 'Cea mai recenta nota a studentului cu ID-ul ' || pi_id_student || ' este ' || nota_recenta || '.';
    return mesaj;
EXCEPTION
when no_data_found then
    select count(*) into counter from studenti where id=pi_id_student;
    if counter=0 then
            raise_application_error (-20001,'Studentul cu ID-ul ' || pi_id_student || ' nu exista in baza de date.');
    else
        select count(*) into counter from note where id_student=pi_id_student;
        if counter = 0 then
                raise_application_error (-20002,'Studentul cu ID-ul ' || pi_id_student|| ' nu are nici o nota.');
        end if;
    end if;
end nota_recenta_student;

select nota_recenta_student(1998) from dual;

select * from studenti where id>1100;

create or replace function nota_recenta_student(
        pi_id_student in studenti.id%type)
        return varchar2
as
    nota_recenta integer;
    mesaj varchar2(32767);
    counter     integer;
    student_inexistent exception;
    pragma exception_INIT(student_inexistent,-20001);
    student_fara_note exception;
    pragma exception_init(student_fara_note,-20002);
begin
    select count(*) into counter from studenti where id=pi_id_student;
    if counter=0 then
        raise student_inexistent;
    else
        select count(*) into counter from note where id_student=pi_id_student;
        if counter =0 then
            raise student_fara_note;
        end if;
    end if;
    select valoare into nota_recenta from( select valoare from note where
            id_student=pi_id_student order by data_notare desc) where rownum<=1;
        mesaj        := 'Cea mai recenta nota a studentului cu ID-ul ' || pi_id_student || ' este ' || nota_recenta || '.';
    return mesaj;
    EXCEPTION
    when student_inexistent then
          raise_application_error (-20001,'Studentul cu ID-ul ' || pi_id_student || ' nu exista in baza de date.');
    when student_fara_note then
          raise_application_error (-20002,'Studentul cu ID-ul ' || pi_id_student || ' nu are nici o nota.');
    end nota_recenta_student;
    
select nota_recenta_student(1998) from dual;

create or replace function medie_student(
pi_nume_student in studenti.nume%type, pi_prenume_student in studenti.prenume%type)
return varchar2
as
    counter     integer;
--    mesaj       varchar2(32000);
    medie       number(5,2);
    student_inexistent exception;
    pragma exception_init(student_inexistent,-20001);
begin
    select count(*) into counter from studenti where nume=pi_nume_Student and prenume=pi_prenume_student;
    if counter =0 then
        mesaj:='studentul NU exista in baza de date';
    else
        mesaj:='studentul DA exista in baza de date';
    end if;
    return mesaj;
end medie_student;


select medie_Student('a','b') from dual;

select * from studenti where id=1;

create or replace function medie_student(pi_nume_student in studenti.nume%type,
                                         pi_prenume_student in studenti.prenume%type)
    return varchar2
as
    counter integer;
--    mesaj   varchar2(32000);
    medie   number(5, 2);
    student_inexistent exception;
    pragma exception_init (student_inexistent,-20001);
    student_fara_note exception;
    pragma exception_init ( student_fara_note,-20002 );
begin
    select count(*) into counter from studenti where nume = pi_nume_Student and prenume = pi_prenume_student;
    if counter = 0 then
        raise student_inexistent;
    else
        select count(*)
        into counter
        from studenti s
                 join note n on s.ID = n.ID_STUDENT
        where nume = pi_nume_student
          and prenume = pi_prenume_student;
        if counter = 0 then
            raise student_fara_note;
        else
            select avg(n.valoare)
            into medie
            from studenti s
                     join note n on s.ID = n.ID_STUDENT
            where nume = pi_nume_student
              and PRENUME = pi_prenume_student;
            
        end if;
    end if;
    return medie;
EXCEPTION
when student_inexistent then
    raise_application_error(-20001,'Acest student nu exista in baza de date');
when student_fara_note then
    raise_application_error(-20002,'Acest student nu are note');
end medie_student;

select medie_student('Huzum','Ion Dimitrie') from dual;

select * from studenti where id=19;

DECLARE
type muie is table of varchar2(20);
my_muie muie;
begin
    my_muie:=MUIE('H1','H2','H3');
end;

begin
    for i in my_muie loop
        dbms_output.put_line(i);
    end loop;
end;














    
    
    
    
    
    
    






































select MEDIE_STUDENT('Mihailescu','Laura') from dual;
select MEDIE_STUDENT('NUME1','NUME2') from dual;


select MEDIE_STUDENT_NUME('Aioanei') from dual;
DECLARE
   TYPE Colors IS TABLE OF VARCHAR2(16);
   rainbow Colors;
    mesaj   varchar2(32000);
BEGIN
   rainbow := Colors('Aioanei','Orange','Yellow','Green','Blue','Indigo','Violet');
    for i in 1..7 loop
            select MEDIE_STUDENT_NUME(rainbow(i)) into mesaj from dual;
        end loop;
   END;


set serveroutput on;

create or replace function medie_student(pi_nume_student in studenti.nume%type,
                                         pi_prenume_student in studenti.prenume%type)
    return varchar2
as
    counter integer;
    mesaj   varchar2(32000);
    medie   number(5, 2);
    student_inexistent exception;
    pragma exception_init (student_inexistent,-20001);
    student_fara_note exception;
    pragma exception_init ( student_fara_note,-20002 );
begin
    select count(*) into counter from studenti where nume = pi_nume_Student and prenume = pi_prenume_student;
    if counter = 0 then
        raise student_inexistent;
    else
        select count(*)
        into counter
        from studenti s
                 join note n on s.ID = n.ID_STUDENT
        where nume = pi_nume_student
          and prenume = pi_prenume_student;
        if counter = 0 then
            raise student_fara_note;
        else
            select avg(n.valoare)
            into medie
            from studenti s
                     join note n on s.ID = n.ID_STUDENT
            where nume = pi_nume_student
              and PRENUME = pi_prenume_student;
            mesaj := 'Studentul:' || pi_nume_student || ' ' || pi_prenume_student || ' are media:' || medie;
        end if;
    end if;
    return mesaj;
EXCEPTION
    when student_inexistent then
        raise_application_error(-20001, 'Acest student nu exista in baza de date');
    when student_fara_note then
        raise_application_error(-20002, 'Acest student nu are note');
end medie_student;

select MEDIE_STUDENT('Mihailescu','Laura') FROM DUAL;

declare
    type nume is table of studenti.nume%type;
    student1 nume;
    type prenume is table of studenti.prenume%type;
    student2 prenume;
    mesaj    varchar2(32000);
begin
    student1 := nume('Mihailescu', 'Pantiruc', 'Iovu','Popescu','Loghin','Dulhac');
    student2 := prenume('Laura', 'Nicusor', 'Sabina','Sabina','David','Georgiana');
    for i in 1..student1.COUNT
        loop
            mesaj := medie_student(student1(i), student2(i));
            dbms_output.put_line(mesaj);
        end loop;
end;


