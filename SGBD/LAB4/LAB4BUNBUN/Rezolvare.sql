-- Din moment ce nu am lucrat la laborator aceasta problema, si am vazut ca este pe site, m-am gandit sa o rezolv si sa v-o trimit
-- este problema din saptamana a 4-a de 5 puncte
-- procedura este privata adica nu se afla in declarata in pachet, ci doar in corpul pachetului, asa nu poate fi accesata din afara
-- am creat aceasta procedura pentru a calcula cmmdc si cmmc a 2 numere, functiile sunt publice, ele nu fac altceva decat sa apeleze procedura si apoi sa returneze valorile prelucrate de procedura privata.


create or replace package lab3 is
  v_cmmdc integer;
  v_cmmc integer; 
  function f_cmmdc (n1 in integer, n2 in integer) return integer;
  function f_cmmc (n1 in integer,n2 in integer) return integer;
end;
/

create or replace package body lab3 is

  procedure proc_privata (n1 in integer, n2 in integer)
    is
        numar1 integer:=n1;
        numar2 integer:=n2;
        numar3 integer:=n1;
        numar4 integer:=n2;
        rezultat integer;
    begin
        while mod(numar2,numar1) !=0 LOOP
            rezultat :=mod(numar2,numar1);
            numar2:=numar1;
            numar1:=rezultat;
        END LOOP;
        v_cmmdc:=rezultat;
  end proc_privata;

  function f_cmmdc(n1 in integer, n2 in integer) return integer is
  begin
    proc_privata(n1, n2);
    return v_cmmdc;
  end f_cmmdc;

  function f_cmmc(n1 in integer, n2 in integer) return integer is
  begin
    proc_privata(n1, n2);
    return (n1* n2)/v_cmmdc;
  end f_cmmc;

end lab3;
/

select lab3.f_cmmdc(24,32) from dual;
select lab3.f_cmmc(24,32) from dual;


