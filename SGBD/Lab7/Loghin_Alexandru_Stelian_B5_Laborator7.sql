-- Loghin Alexandru-Stelian, grupa B5
set serveroutput on;
drop type Jucator force;
/
create or replace type Jucator as object
(
    nume         varchar2(35),
    prenume      varchar2(35),
    rang         integer,
    salariu      integer,
    joc          varchar2(30),
    tara         varchar2(30),
    data_nastere date,
    constructor function Jucator(
        nume varchar2,
        prenume varchar2) return self as result,
    member
    function CalculAvere return integer,
    member
    procedure afiseaza_porecla,
    map
    member
    function f_compara_salariu return integer
);
/

create or replace type body Jucator
is
    constructor function Jucator(
        nume varchar2,
        prenume varchar2) return self as result
        is
        begin
            self.nume := nume;
            self.prenume := prenume;
            self.SALARIU := 50;
            self.RANG := 10;
            return;
        end;

    member function CalculAvere return integer
        is
        begin
            return (self.RANG * 5 + self.SALARIU * 5);
        end CalculAvere;

    member procedure afiseaza_porecla is
        begin
            dbms_output.put_line('Xxx' || self.NUME || 'xxX');
        end afiseaza_porecla;

    map member function f_compara_salariu return integer
        is
        begin
            return salariu;
        end f_compara_salariu;
end;

declare
    jucator1 Jucator;
    jucator2 Jucator;
    jucator3 Jucator;
begin
    jucator1 := new Jucator('Tarzaned','Josh',10,100,'LoL','America',sysdate);
    jucator2 := new Jucator('Rivera','Dom',1,500,'LoL','America',sysdate);
    -- apelul de constructor explicit
    jucator3 := Jucator('Artistu', 'Bogdan');
    dbms_output.PUT_LINE(jucator3.NUME || ' ' || jucator3.PRENUME || ' ' || jucator3.RANG || ' ' || jucator3.SALARIU);
    -- dovada ca functia MAP compara corect obiectele
    if (jucator1 > jucator2) then
        dbms_output.PUT_LINE(
                    'Jucatorul ' || jucator1.NUME || ' ' || jucator1.PRENUME ||
                    ' are salariul mai mare decat jucatorul ' || jucator2.NUME || ' ' || jucator2.PRENUME);
    else
        dbms_output.PUT_LINE(
                    'Jucatorul ' || jucator2.NUME || ' ' || jucator2.PRENUME ||
                    ' are salariul mai mare decat jucatorul ' || jucator1.NUME || ' ' || jucator1.PRENUME);

    end if;
    -- apel de functii
    jucator1.AFISEAZA_PORECLA();
    jucator2.AFISEAZA_PORECLA();
    dbms_output.PUT_LINE('Jucatorul ' || jucator1.NUME || ' ' || jucator1.PRENUME || ' are o avere de ' ||
                         jucator1.CALCULAVERE() || ' milioane');
    dbms_output.PUT_LINE('Jucatorul ' || jucator2.NUME || ' ' || jucator2.PRENUME || ' are o avere de ' ||
                         jucator2.CALCULAVERE() || ' milioane');
end;

drop table jucatori;

create table jucatori
(
    id     varchar2(4),
    obiect Jucator
);

declare
    jucator1 Jucator;
    jucator2 Jucator;
    jucator3 Jucator;
    jucator4 Jucator;
begin
    jucator1 := new Jucator('Tarzaned','Josh',10,100,'LoL','America',TO_DATE('13/05/1999', 'dd/mm/yyyy'));
    jucator2 := new Jucator('Rivera','Dom',1,500,'LoL','America',TO_DATE('24/03/1980', 'dd/mm/yyyy'));
    jucator3 := Jucator('Artistu', 'Bogdan');
    jucator4 := Jucator('Lo', 'Wang', 23, 600, 'Starcraft', 'Japonia', TO_DATE('22/03/1995', 'dd/mm/yyyy'));
    insert into jucatori values ('1', jucator1);
    insert into jucatori values ('2', jucator2);
    insert into jucatori values ('3', jucator3);
    insert into jucatori values ('4', jucator4);
end;

-- datorita functiei MAP f_compara_salariu, obiectele vor fi sortate dupa salariul lor
-- aici vor fi sortate de la cel mai mare salariu la cel mai mic
select *
from jucatori
order by obiect desc;

-- aici vor fi sortate de la cel mai mic la cel mai mare salariu
select *
from jucatori
order by obiect asc;

-- acum voi face ca Jucator sa poata permite mostenirea
drop type Jucator force;

create or replace type Jucator as object
(
    nume         varchar2(35),
    prenume      varchar2(35),
    rang         integer,
    salariu      integer,
    joc          varchar2(30),
    tara         varchar2(30),
    data_nastere date,
    constructor function Jucator(
        nume varchar2,
        prenume varchar2) return self as result,
    member
    function CalculAvere return integer,
    member
    procedure afiseaza_porecla,
    map
    member
    function f_compara_salariu return integer
) not final;
/

-- voi suprascrie metoda CalculAvere, fac o subclasa Veteran
-- care are in plus atributul: bonus_vechime
create or replace type Jucator_Veteran under Jucator
(
    bonus_vechime integer,
    overriding
    member
    function CalculAvere return integer
);
/

create or replace type body Jucator_Veteran
is
    overriding
    member function CalculAvere return integer
        is
        begin
            return (self.RANG * 5 + self.SALARIU * 5 + self.BONUS_VECHIME * 10);
        end CalculAvere;
end;
z
declare
    j_veteran Jucator_Veteran;
BEGIN
    j_veteran := Jucator_Veteran('Lee', 'Faker', 200, 700, 'Lol', 'South KR', sysdate, 6);
    dbms_output.PUT_LINE(j_veteran.NUME);
    dbms_output.PUT_LINE(j_veteran.BONUS_VECHIME);
    -- metoda suprascrisa
    dbms_output.PUT_LINE('Averea acestui veteran este: ' || j_veteran.CALCULAVERE());
end;


--supraincarcarea

drop type Jucator force;

create or replace type Jucator as object
(
    nume         varchar2(35),
    prenume      varchar2(35),
    rang         integer,
    salariu      integer,
    joc          varchar2(30),
    tara         varchar2(30),
    data_nastere date,
    constructor function Jucator(
        nume varchar2,
        prenume varchar2) return self as result,
    member
    function CalculAvere return integer,
    member
    procedure afiseaza_porecla,
    member
    procedure afiseaza_porecla(v_sufix varchar2),
    map
    member
    function f_compara_salariu return integer
);
/
create or replace type body Jucator
is
    constructor function Jucator(
        nume varchar2,
        prenume varchar2) return self as result
        is
        begin
            self.nume := nume;
            self.prenume := prenume;
            self.SALARIU := 50;
            self.RANG := 10;
            return;
        end;

    member function CalculAvere return integer
        is
        begin
            return (self.RANG * 5 + self.SALARIU * 5);
        end CalculAvere;

    member procedure afiseaza_porecla is
        begin
            dbms_output.put_line('Xxx' || self.NUME || 'xxX');
        end afiseaza_porecla;

    member procedure afiseaza_porecla(v_sufix varchar2) is
        begin
            dbms_output.put_line('Xxx' || self.NUME || 'xxX' || v_sufix);
        end afiseaza_porecla;

    map member function f_compara_salariu return integer
        is
        begin
            return salariu;
        end f_compara_salariu;
end;

declare
    jucator1 Jucator;
    jucator2 Jucator;
    jucator3 Jucator;
    jucator4 Jucator;
begin
    jucator1 := new Jucator('Leesman','Josh',15,700,'Box cu canguri','Australia',sysdate);
    jucator2 := new Jucator('Bursuc','Dan',54,1000,'World of Warcraft','Papa Noua Guinee',sysdate);
    -- constructor explicit
    jucator3 := new Jucator('The Wonder','Adi');
    jucator4 := new Jucator('Bat','Man',5,100,'Batman Arkham City','Arkham',sysdate);
    if (jucator3 > jucator4) then
        dbms_output.PUT_LINE(
                    'Jucatorul ' || jucator3.NUME || ' ' || jucator3.PRENUME ||
                    ' are salariul mai mare decat jucatorul ' || jucator4.NUME || ' ' || jucator4.PRENUME);
    else
        dbms_output.PUT_LINE(
                    'Jucatorul ' || jucator4.NUME || ' ' || jucator4.PRENUME ||
                    ' are salariul mai mare decat jucatorul ' || jucator3.NUME || ' ' || jucator3.PRENUME);
    end if;
    if (jucator1 > jucator2) then
        dbms_output.PUT_LINE(
                    'Jucatorul ' || jucator1.NUME || ' ' || jucator1.PRENUME ||
                    ' are salariul mai mare decat jucatorul ' || jucator2.NUME || ' ' || jucator2.PRENUME);
    else
        dbms_output.PUT_LINE(
                    'Jucatorul ' || jucator2.NUME || ' ' || jucator2.PRENUME ||
                    ' are salariul mai mare decat jucatorul ' || jucator1.NUME || ' ' || jucator1.PRENUME);
    end if;
    -- apelarea metodei normale
    jucator1.AFISEAZA_PORECLA;
    -- apelarea metodei supraincarcate
    jucator1.AFISEAZA_PORECLA(' aka dragonuak47');
    dbms_output.PUT_LINE('Jucatorul ' || jucator1.NUME || ' ' || jucator1.PRENUME || ' are o avere de ' ||
                         jucator1.CALCULAVERE() || ' milioane');
    dbms_output.PUT_LINE('Jucatorul ' || jucator2.NUME || ' ' || jucator2.PRENUME || ' are o avere de ' ||
                         jucator2.CALCULAVERE() || ' milioane');
end;
