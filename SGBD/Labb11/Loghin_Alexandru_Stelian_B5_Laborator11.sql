set serveroutput on;
/*
    Loghin Alexandru-Stelia, grupa B5
*/
-- am creat procedura de mai jos care in functie de parametrul corect primit, va crea cursoare pe baza dictionarul de date cu care voi afisa statisticile respective
-- in legatura cu mailul pe care vi l-am trimis legat de numarul de linii intr-o functie/procedura/pachet, am cautat pe internet si am gasit:
-- select count(text)  from all_source de unde pot prelua continutul fiecarui lucru pe baza coloanei name si asa pot numara si numarul de linii de cod
create or replace procedure statistici(nume_obiect varchar2) as
    v_linie        varchar(20000);
    v_constraint   integer;
    v_nr_linii_pfp integer;
begin
    if (nume_obiect = 'view' or nume_obiect = 'VIEW') then
        for c1 in (select view_name, text, text_length from user_views)
            LOOP
                dbms_output.put_line(
                            'Numele view-ului este: ' || c1.view_name || ' textul view-ului este: ' || c1.text ||
                            ' iar lungimea textului este: ' || c1.text_length);
            end loop;
    elsif (nume_obiect = 'TABEL' or nume_obiect = 'tabel') then
        for i in (select * from user_tables )
            loop
                v_linie := i.table_name || '  ' || i.num_rows;
                select count(*)
                into v_constraint
                from user_constraints
                         natural join user_cons_columns
                where table_name = i.table_name;
                v_linie := v_linie || ' , nr de constrangeri: ';
                if (v_constraint > 0) then
                    for j in ( SELECT uc.constraint_name, uc.constraint_type, ucc.column_name
                               from user_constraints uc
                                        join user_cons_columns ucc on uc.constraint_name = ucc.constraint_name
                               where uc.table_name = i.table_name)
                        loop
                            v_linie := v_linie || j.constraint_name || ', ' || j.constraint_type || ', ' ||
                                       j.column_name || ',';
                        end loop;
                else
                    v_linie := v_linie || '0';
                end if;
                v_linie := v_linie || ' Indexes: ';
                for j in (select * from user_indexes where table_name = i.table_name)
                    loop
                        v_linie := v_linie || j.index_name || ', ';
                    end loop;
                select count(*) into v_constraint from user_nested_tables where table_name = i.table_name;
                if (v_constraint > 0) then
                    v_linie := v_linie || ' e nested table';
                else
                    v_linie := v_linie || ' nu e nested table';
                end if;
                dbms_output.put_line(v_linie);
            end loop;
    elsif (nume_obiect = 'INDEX' or nume_obiect = 'index') then
        for j in (select ui.Index_Name   as nume_index,
                         ui.table_name   as nume_tabel,
                         Column_Name     as nume_coloana,
                         Column_Position as pozitie_coloana
                  from USER_INDEXES ui
                           join USER_IND_COLUMNS uic on ui.index_name = uic.index_name)
            LOOP
                dbms_output.put_line(
                            'Numele indexului este: ' || j.nume_index || ' ,numele tabelui este: ' || j.nume_coloana ||
                            ' , numele coloanei este: ' || j.nume_coloana || ' iar pozitia coloanei este: ' ||
                            j.pozitie_coloana);
            END LOOP;
    elsif (nume_obiect = 'type' or nume_obiect = 'TYPE') then
        for t in (select type_name, typecode, attributes, methods, instantiable from user_types)
            LOOP
                dbms_output.put_line('Numele tipului este: ' || t.type_name || ' este de tipul: ' || t.typecode ||
                                     ' , numarul de atribute al acestui type este: ' || t.attributes ||
                                     ' , numarul de metode este:  ' || t.methods || ' este instantiabila: ' ||
                                     t.instantiable);
            END LOOP;
    elsif (nume_obiect = 'FUNCTION' or nume_obiect = 'function') then
        for l in (select object_name, deterministic from user_procedures where object_type = 'FUNCTION')
            LOOP
                select count(text) into v_nr_linii_pfp from all_source where name = l.object_name;
                dbms_output.put_line('Pentru functia: ' || l.object_name || ' numarul de linii de cod este: ' ||
                                     v_nr_linii_pfp || ' , este determinista: ' || l.deterministic);
            END LOOP;
    elsif (nume_obiect = 'PACKAGE' or nume_obiect = 'PACKAGE') then
        for l in (select object_name, deterministic from user_procedures where object_type = 'PACKAGE')
            LOOP
                select count(text) into v_nr_linii_pfp from all_source where name = l.object_name;
                dbms_output.put_line('Pentru pachetul: ' || l.object_name || ' numarul de linii de cod este: ' ||
                                     v_nr_linii_pfp || ' , este determinist: ' || l.deterministic);
            END LOOP;
    elsif (nume_obiect = 'PROCEDURE' or nume_obiect = 'procedure') then
        for l in (select object_name, deterministic from user_procedures where object_type = 'PROCEDURE')
            LOOP
                select count(text) into v_nr_linii_pfp from all_source where name = l.object_name;
                dbms_output.put_line('Pentru procedura: ' || l.object_name || ' numarul de linii de cod este: ' ||
                                     v_nr_linii_pfp || ' , este determinisat: ' || l.deterministic);
            END LOOP;
    else
        dbms_output.put_line(
                'introduceti unul dintre parametrii urmatori: view,tabel,index,type,function,procedure,package sau UPPER de cele mentionate anterior');
    end if;
end;


-- testez
exec statistici('VIEW');
exec statistici('TABEL');
exec statistici('INDEX');
exec statistici('TYPE');
exec statistici('PROCEDURE');
exec statistici('PACKAGE');
exec statistici('FUNCTION');