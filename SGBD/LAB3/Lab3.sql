declare
    cursor lista_prieteni is select s1.id,trunc(avg(n1.valoare),2) as medie1, trunc(avg(n1.valoare)) as medie_intreaga1,
    s2.id,trunc(avg(n2.valoare),2) as medie2,trunc(avg(n2.valoare)) as medie_intreaga2 from studenti s1 join prieteni p on p.id_student1=s1.id 
    join studenti s2 on s2.id=p.id_student2 join note n1 on n1.id_student=s1.id  join note n2 on n2.id_student=s2.id group by s1.id,s2.id;
    v_id1 studenti.id%type:=1041;  
    v_nume_count studenti.nume%type;
begin
    select count(nume) into v_nume_count from studenti where id=v_id1;
    if(v_nume_count=0) then
        dbms_output.put_line('Studentul  nu exista in baza de date');
    
    
    end if;
end;

--2
accept i_numar prompt "Introduceti un numar";
    declare
        v_contor integer:=0;
        i_numar integer;
        v_numar integer;
    begin
    v_numar:=&i_numar;
    if(v_numar=0) then
        dbms_output.put_line('Introduceti alt numar inafara de 0');
        else
        while(v_contor<10) LOOP
            v_contor:=v_contor+1;
            dbms_output.put_line(v_contor*v_numar);
        END LOOP;
        end if;
end;

    
--3
declare
    v_factura1 studenti.data_nastere%TYPE;
    plata_scadenta studenti.data_nastere%TYPE;
    v_id1 NUMBER(38,0):=2;
BEGIN
    select data_nastere INTO v_factura1 from studenti where id=v_id1;
    select sysdate into plata_scadenta from dual;
    if(to_date(plata_scadenta)=to_date(v_factura1)) then dbms_output.put_line('Astazi este data scadenta');
    elsif(to_date(plata_scadenta)>to_date(v_factura1)) then dbms_output.put_line('Mai aveti timp sa platiti');
    elsif (to_date(plata_scadenta)<to_date(v_factura1)) then dbms_output.put_line('Ati intarziat cu plata');
    end if;
end;

    
  
    
    
    