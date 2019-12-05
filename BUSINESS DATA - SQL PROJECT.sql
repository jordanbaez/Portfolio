# working with an existing set of databases about book sales
# the project was made with MySQL Workbench

USE PUBLICATIONS;

#getting the list of each book's names with their authors and their publishers

SELECT authors.au_id,authors.au_lname,authors.au_fname, titles.title,  publishers.pub_name
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titles.title_id = titleauthor.title_id
INNER join publishers on titles.pub_id = publishers.pub_id;

# counting the number of books each author published in each publishing firm

SELECT a.au_id, a.au_lname, a.au_fname, p.pub_name, count(p.pub_id) as title_count
FROM authors a
INNER JOIN TITLEAUTHOR T ON A.AU_ID = T.AU_ID
INNER JOIN TITLES TI ON T.TITLE_ID = TI.TITLE_ID
INNER JOIN PUBLISHERS P ON TI.PUB_ID = P.PUB_ID
group by au_id, p.pub_name
order by au_id desc;

# selecting the 3 best selling authors from the database and ranking them

SELECT a.au_id, a.au_lname, a.au_fname,  sum(ti.ytd_sales) as total 
from authors a
INNER JOIN TITLEAUTHOR T ON A.AU_ID = T.AU_ID
INNER JOIN TITLES TI ON T.TITLE_ID = TI.TITLE_ID
group by a.au_id
order by total desc limit 3;

# ranking all of the authors by their year-to-date book sales

SELECT a.au_id, a.au_lname, a.au_fname,  sum(ti.ytd_sales) as total 
from authors a
INNER JOIN TITLEAUTHOR T ON A.AU_ID = T.AU_ID
INNER JOIN TITLES TI ON T.TITLE_ID = TI.TITLE_ID
group by a.au_id
order by total desc ;

USE publications;

# counting the amount each author received in advance earnings and royalties

select a.au_id, a.au_lname, a.au_fname, sum(ti.advance) as adv, sum(ti.royalty) as royalties
from authors a
inner join titleauthor t on t.au_id = a.au_id
inner join titles ti on ti.title_id = t.title_id
group by au_id
order by adv desc;
#update titles set price  = 0 where price  is null;

# summing the advance earnings and the royalties received by each author for each book and ranking them

SELECT t.title_id, t.title, a.au_id, 
sum(round(t.advance) + round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100)) as total
from authors a
join titleauthor ta on ta.au_id = a.au_id
join titles t on t.title_id = ta.title_id
join sales s on s.title_id = t.title_id
group by title_id, au_id
order by total desc;


