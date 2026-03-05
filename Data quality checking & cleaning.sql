--Check NULL records in 'sales' dataset
select *
from sales
where id_product is null 
    or order_date is null
    or revenue_discount is null
    or units is null
    or net_cost_equivalent_cogs is null;
--There is no NULL records in 'sales' dataset

--Check NULL records in 'product' dataset    
select * 
from product
where id_product is null 
    or products is null
    or suggested_retail_price is null
    or standard_cost is null
    or id_com is null
    or id_category is null; 
--There is no NULL records in 'product' dataset

--Check NULL records in 'distributors' dataset    
select * 
from distributors
where id_com is null 
    or company is null
    or e_mail is null
    or city is null
    or state is null;
--There is 2 NULL records in e_mail column in 'distributors' dataset

--Fix 'Null' error in 'distributors' dataset:
Create or replace View cleaned_distributors as
Select 
    id_com,
    company,
    coalesce (e_mail, 'Unknown') e_mail,
    city,
    state
from distributors;

--Check NULL records in 'categories' dataset    
select * 
from categories
where id_category is null 
    or categories is null;
--There is no NULL records in 'categories' dataset

--Check duplicate records in dimension tables
select 
    id_product,
    count(*)
from product
group by id_product
having count(*) >1;
--There is no duplicate records in 'product' dataset

select 
    id_com,
    count(*)
from distributors
group by id_com
having count(*) >1;
--There is no duplicate records in 'distributors' dataset

select 
    id_product
from sales
where not exists 
    (select id_product
    from product);    
--There is no duplicate records in 'distributors' dataset

--Check orphan records in fact tables 'Sales'
select *
from sales s
where not exists (
    select 1
    from product p
    where p.id_product = s.id_product
);
--No orphan records found between sales and product tables.

--Check orphan records in 'product' tables
select *
from product p
where not exists (
    select 1
    from cleaned_distributors d
    where p.id_com = d.id_com
);
--No orphan records found between product table and cleaned_distributors view.

select *
from product p
where not exists (
    select 1
    from categories c
    where p.id_category = c.id_category
);
--No orphan records found between product and categories tables.

--Check negative records in sales table
select *
from sales
where units < 0 
    or net_cost_equivalent_cogs < 0;
--3 negative records found in units column in sales table

--fix negative records in sales tables
create or replace view cleaned_sales as
select 
    order_date,
    id_product,
    case when units < 0 then units*-1
    else units
    end units,
    revenue_discount,
    net_cost_equivalent_cogs
from sales;

--Check negative records in product table
select *
from product
where suggested_retail_price < 0 
    or standard_cost < 0;
--no negative found in product table

