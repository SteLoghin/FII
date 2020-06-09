drop type lista_medii_date;
create type lista_medii_date as table of number(10,2);
/
alter table studenti add lista_medii lista_medii_date nested table lista_medii store as lista_medii;
update studenti set lista_medii=lista_medii_date();
--select lista_medii from studenti;
-- fac o procedura care va parcurge 6 cursoare( fiecare cursor reprezinta un semstru dintr-un an-- sunt 6 semestru) unde calculez media fiecarui student din fiecare semestru
-- am stat ceva timp ca sa vad de ce nu compileaza, eroare este: missing right paranthesis dar in acest script exista un numar egal de paranteze ( si ).
-- am cautat pe internet niste solutii si ce am gasit este faptul ca, aceasta eroare poate fi produsa nu doar din cauza ca nu sunt un egal de paranteze, nu am mai putut continua
-- Ideea mea de rezolvare: creez un nested table ce contine mediile studentului, atasez acest nested table tabelei studenti si apoi cu procedura de mai jos parcurg mediile studentului din fiecare semestru
-- de asta am facut si 6 cursoare cum am precizat mai sus si le adaug in lista_medii din studenti.
-- selecturile merg, returneaza ce trebuie dar nu am putut sa-i dau de cap erorii, am acelasi numar de paranteze printr o cautare de ctrl-f, pe internet zice ca acest compilator 
-- nu poate face diferenta intre anumite erori si uneori afiseaza niste erori "generice"
-- Loghin Alexandru-Stelian, grupa B5
create or replace procedure calculeaza_medii is
begin
    for c0 in (select s.id,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=1 and c.semestru=1  group by s.id,s.an,c.semestru order by s.id asc) loop
        update studenti
        set lista_medii=(select avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=1 and c.semestru=1 group by s.id order by s.id asc);
    end loop;
    for c1 in(select s.id,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=1 and c.semestru=2  group by s.id,s.an,c.semestru order by s.id asc) loop
        update studenti
        set lista_medii=(select avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=1 and c.semestru=2 group by s.id order by s.id asc);
    end loop;
    for c2 in (select s.id,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=2 and c.semestru=1 group by s.id order by s.id asc) loop
        update studenti
        set lista_medii=(select avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=2 and c.semestru=1 group by s.id order by s.id asc);
    end loop;
    for c3 in(select s.id,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=2 and c.semestru=2 group by s.id order by s.id asc) loop
        update studenti
        set lista_medii=(select avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=2 and c.semestru=2 group by s.id order by s.id asc);
    end loop;
    for c4 in(select s.id,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=3 and c.semestru=1 group by s.id order by s.id asc) loop
        update studenti
        set lista_medii=(select avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=3 and c.semestru=1 group by s.id order by s.id asc);
    end loop;
    for c5 in(select s.id,avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=3 and c.semestru=2 group by s.id order by s.id asc) loop
        update studenti
        set lista_medii=(select avg(n.valoare) from studenti s join note n on s.id=n.id_student join cursuri c on c.id=n.id_curs where c.an=3 and c.semestru=2 group by s.id order by s.id asc);
    end loop;    
end calculeaza_medii;
