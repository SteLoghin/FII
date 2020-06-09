set serveroutput on;
alter table studenti
drop column LISTA_MEDII;

create or replace type medii as table of number(10, 2);
/
alter table studenti
    add lista_medii medii nested table lista_medii store as lista_medii;
/

update studenti
set lista_medii=medii();


create or replace procedure calculeaza_medii as
    v_count       integer;
    v_nr_studenti integer;
    v_nota        integer;
    v_id          integer;
    v_an          integer;
    sir_medii     studenti.lista_medii%type;
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