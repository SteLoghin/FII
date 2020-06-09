select s1.an,s1.grupa,count(distinct s1.id) as nr_studenti,count(p.id_student1) as nr_prietenii,trunc(count(p.id_student1)/count(distinct s1.id),2) as coeziune
from studenti s1 join prieteni p on s1.id=p.id_student1 join studenti s2 on s2.id=p.id_student2 group by s1.an,s1.grupa order by trunc(count(p.id_student1)/count(distinct s1.id),2) desc;


select s1.an,s1.grupa,count(distinct s1.id) as nr_studenti,count(p.id_student1) as nr_prietenii,trunc(count(p.id_student1)/count(distinct s1.id),2) as coeziune
from studenti s1 join prieteni p on p.id_student1=s1.id join studenti s2 on s2.id=p.id_student2 group by s1.an,s1.grupa
having count(p.id_student1)/count(distinct s1.id)=(select max(count(p.id_student1)/count(distinct s1.id)) from studenti s1 join prieteni p on p.id_student1=s1.id 
join studenti s2 on s2.id=p.id_student2 group by s1.an,s1.grupa) order by 3 desc;

