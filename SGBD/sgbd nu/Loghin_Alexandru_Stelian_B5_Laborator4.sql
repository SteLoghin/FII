set serveroutput on;
/*
  Loghin Alexandru-Stelian, grupa B5
*/
alter table studenti drop column LISTA_MEDII;
-- pe baza exemplului mareste_bursa am reusit sa refac tot laboratorul si sa mearga totul corect
create or replace type medii as table of number(10, 2);
/
alter table studenti
    add lista_medii medii nested table lista_medii store as lista_medii;
/

update studenti
set lista_medii=medii();

--modul de abordare: vad cati studenti se afla in tabela studenti si fac un for de la 1 la v_nr_studenti
-- verific daca exista id-ul in tabela daca da, verific in ce an se afla studentul respectiv
-- verific cu select an into v_an si daca e anul 3 se vor face 6 selecturi si 6 updateuri adica: 
--2 selecturi pentru anul 1(semestrul 1 si semestrul 2),
--2 selecturi pentru anul 2(semestrul 1 si semestrul 2),
--2 selecturi pentru anul 3(semestrul 1 si semestrul 2)
-- 6 updateuri realizate cu multiset union pe baza id-ului studentului
-- daca e in anul 2 atunci se vor realiza 4 selecturi si 4 updateuri pe baza modelului descris mai sus
-- daca e in anul 1 atunci se vor realiza doar 2 selecturi si 2 updateuri
create or replace procedure calculeaza_medii as
    v_count       integer;
    v_nr_studenti integer;
    v_nota        integer;
    v_id          integer;
    v_an          integer;
begin
    select count(*) into v_nr_studenti from studenti;
    for v_id in 1..v_nr_studenti
        loop
            --lista_medii_date numele tipului
            select id into v_count from studenti where id = v_id;
            if (v_count > 0) then
                select an into v_an from studenti where id = v_id;
                if (v_an = 3) then ------------
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 1
                      and c.semestru = 1
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 1
                      and c.semestru = 2
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 2
                      and c.semestru = 1
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 2
                      and c.semestru = 2
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 3
                      and c.semestru = 1
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 3
                      and c.semestru = 2
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                elsif (v_an = 2) then ------------------
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 1
                      and c.semestru = 1
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 1
                      and c.semestru = 2
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 2
                      and c.semestru = 1
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 2
                      and c.semestru = 2
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                elsif (v_an = 1) then -----------
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 1
                      and c.semestru = 1
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                    select trunc(avg(n.valoare), 2)
                    into v_nota
                    from studenti s
                             join note n on s.id = n.id_student
                             join cursuri c on c.id = n.id_curs
                    where s.id = v_id
                      and c.an = 1
                      and c.semestru = 2
                    group by s.id, c.semestru
                    order by s.id asc;
                    update studenti set lista_medii = lista_medii multiset union medii(v_nota) where id = v_id;
                end if;
            end if;
        end loop;
end;

select *
from studenti
order by 1 desc;

exec calculeaza_medii;

select *
from studenti;
-- v_tupla studenti%ROWTYPE iau o tupla din tabela studenti pe baza id-ului dat ca parametru functiei
-- fac select * into v_tupla ca sa iau toata tupla si apoi voi returna v_tupla.LISTA_medii.count
-- v_tupla.LIST_MEDII reprezinta coloana selectata in v_tupla si cu count vad cate medii sunt
create or replace function numar_medii(v_id IN studenti.id%type) return integer as
    v_tupla studenti%ROWTYPE;
BEGIN
    select * into v_tupla from studenti where id=v_id;
    return v_tupla.LISTA_MEDII.count;
end;

select * from studenti;
-- testez sa vad ca merge
select numar_medii(83) from DUAL;
select numar_medii(82) from dual;
select numar_medii(1000) from dual;