# Analysis questions
1. How many total revenue and total profit?
2. Calculate the revenue on the month basis and month-over-month growth rate?
3. Find the top-selling date?
4. Find the top-selling products and category?
5. Find the top products and category that contribute the most revenue?
6. How much promotion are there in each month for each product
7. Calculate total orders, total revenue, total profit and net margin of each products? Order by net margin descending
8. Calculate the revenue contribution percentage by product?
9. Compare average actual cost with standard cost of each product?
---

# Solutions

Let's collaborate on running the queries using Oracle 19c

# Create view contains revenue and profit of each products
```sql
create or replace view summary_table as
select 
        s.id_product,
        s.order_date,
        sum(s.units) ttl_orders,
        sum(s.units*s.net_cost_equivalent_cogs*p.standard_cost) ttl_cost,
        sum(s.units * p.suggested_retail_price * (1-s.revenue_discount)) ttl_rev
    from cleaned_sales s
    join product p
        on s.id_product = p.id_product
    group by 
        s.id_product,
        s.order_date;
```
---
# 1. How many total revenue and total profit?
`total revenue`
```sql
select 
    sum (ttl_rev)
from summary_table
```
# Result
| TTL_REV      |
|--------------|
| 4252389.2499 |

`total profit`
```sql
select  
    sum(ttl_rev) - sum(ttl_cost) as ttl_profit
from summary_table
```
# Result
| TTL_PROFIT                 |
|----------------------------|
| 1599174.825141999973397414 |
---
# 2. Calculate the revenue on the month basis and month-over-month growth rate?
```sql
select
    order_month,
    ttl_rev,
    round(ttl_rev / nullif(lag(ttl_rev) over (order by order_month),0) -1,2) * 100 as MoM_growth_rate
from (
select 
    extract(month from (order_date)) order_month,
    sum(ttl_rev) ttl_rev
from summary_table 
group by extract(month from (order_date))
order by extract(month from (order_date))
)
```
# Result set (Preview)
| ORDER_MONTH | TTL_REV      | MOM_GROWTH_RATE |
|-------------|--------------|-----------------|
| 1           | 94274.4002   |                 |
| 2           | 66053.2289   | -30             |
| 3           | 77925.467    | 18              |
| 4           | 271971.6106  | 249             |
| 5           | 342502.4583  | 26              |
| 6           | 254192.642   | -26             |
| 7           | 301865.7681  | 19              |
| 8           | 347703.5194  | 15              |
| 9           | 73411.227    | -79             |
| 10          | 87201.0755   | 19              |
| 11          | 624499.5594  | 616             |
| 12          | 1710788.2935 | 174             ||

# Insight

###
The monthly sales fluctuated significantly, however in almost month, the sales result increased compared with the previous month. Especially, in Apr and Nov, the sales result went up sharply (249% and 616% respectively). In opposite, only in Feb, Jun and Sep, the sales result decreased.

---
# 3. Find the top-selling date?
```sql
select 
    order_date,
    sum(units)
from cleaned_sales
group by order_date
order by sum(units) desc
```
# Result set (Preview)
| ORDER_DATE | SUM(UNITS) |
|------------|------------|
| 30-NOV-16  | 5629       |
| 14-DEC-16  | 5317       |
| 28-NOV-16  | 5137       |
| 20-DEC-16  | 4946       |
| 03-DEC-16  | 4874       |
| 29-NOV-16  | 4846       |
| 06-DEC-16  | 4845       |
| 22-DEC-16  | 4832       |
| 01-DEC-16  | 4831       |
| 04-DEC-16  | 4752       |

# Insight

### 
The highest top_selling date is on 30-Nov-26. And the top-selling dates are concentrated on the last months of the year (Nov, Dec)

---
# 4. Find the top-selling products and category?
```sql
select 
    s.id_product,
    p.products,
    c.categories,
    sum(s.units) ttl_orders
from product p
join cleaned_sales s 
    on s.id_product = p.id_product
join categories c
    on p.id_category = c.id_category
group by 
    s.id_product,
    p.products,
    c.categories
order by sum(s.units) desc
```
# Result set
| ID_PRODUCT | PRODUCTS        | CATEGORIES | TTL_ORDERS |
|------------|-----------------|------------|------------|
| Y-10-20    | Yanaki          | Boomerangs | 37414      |
| JB-50-14   | Juggling Bags   | Toys       | 36416      |
| BK-40-2    | Beginner Kite   | Kites      | 28549      |
| MB-30-16   | Majestic Beaut  | Boomerangs | 23523      |
| C-30-5     | Carlota         | Boomerangs | 19966      |
| EK-40-9    | Eagle Kite      | Kites      | 14842      |
| S-30-18    | Sunset          | Boomerangs | 14729      |
| CB-10-7    | Crested Beaut   | Boomerangs | 8442       |
| A-10-1     | Aspen           | Boomerangs | 7883       |
| JS-50-15   | Juggling Sticks | Toys       | 7662       |
| GY-60-13   | Glowing Yoyo    | Toys       | 7478       |
| Q-30-17    | Quad            | Boomerangs | 7305       |
| TK-40-19   | Tri Kite        | Kites      | 7118       |
| BWK-20-4   | Bi Wing Kite    | Kites      | 7050       |
| D-30-11    | Deuce           | Boomerangs | 7010       |
| FK-20-10   | Fighter Kite    | Kites      | 6876       |
| CY-60-6    | Comp Yoyo       | Toys       | 6654       |
| B-30-3     | Bellen          | Boomerangs | 6599       |
| DS-50-8    | Devil Sticks    | Toys       | 5828       |
| GY-60-12   | Ginny Yoyo      | Toys       | 5703       | 
# Insight

### 
The best-selling product is Yanaki, belong to boomerangs category. In general, boomerangs category have the most products that attract buyers

---
# 5. Find the top products and category that contribute the most revenue?
```sql
select 
    st.id_product,
    p.products,
    c.categories,
    sum(st.ttl_rev) ttl_rev
from product p
join summary_table st 
    on st.id_product = p.id_product
join categories c
    on p.id_category = c.id_category
group by 
    st.id_product,
    p.products,
    c.categories
order by sum(st.ttl_rev) desc
```
# Result set
| ID_PRODUCT | PRODUCTS        | CATEGORIES | TTL_REV     |
|------------|-----------------|------------|-------------|
| FK-20-10   | Fighter Kite    | Kites      | 609622.0542 |
| Y-10-20    | Yanaki          | Boomerangs | 528655.086  |
| MB-30-16   | Majestic Beaut  | Boomerangs | 465381.187  |
| BWK-20-4   | Bi Wing Kite    | Kites      | 346874.268  |
| C-30-5     | Carlota         | Boomerangs | 330140.4645 |
| EK-40-9    | Eagle Kite      | Kites      | 270048.967  |
| S-30-18    | Sunset          | Boomerangs | 213014.174  |
| JB-50-14   | Juggling Bags   | Toys       | 197234.6405 |
| Q-30-17    | Quad            | Boomerangs | 194720.9145 |
| BK-40-2    | Beginner Kite   | Kites      | 175734.0145 |
| CB-10-7    | Crested Beaut   | Boomerangs | 147137.4615 |
| D-30-11    | Deuce           | Boomerangs | 143308.0425 |
| A-10-1     | Aspen           | Boomerangs | 116139.298  |
| TK-40-19   | Tri Kite        | Kites      | 110706.4497 |
| B-30-3     | Bellen          | Boomerangs | 101686.4695 |
| JS-50-15   | Juggling Sticks | Toys       | 91810.8975  |
| CY-60-6    | Comp Yoyo       | Toys       | 81960.3855  |
| DS-50-8    | Devil Sticks    | Toys       | 63651.418   |
| GY-60-12   | Ginny Yoyo      | Toys       | 32401.2375  |
| GY-60-13   | Glowing Yoyo    | Toys       | 32161.82    |

# Insight

### 
Fighter kite contribute the most revenue, while this product have low number of purchase. That means Fighter Kite is a effective product. While yanaki have both high purchase and revenue. In opposite, Ginny yoyo that belongs to Toys category is a ineffective product as it have both low purchase and revenue.

---
# 6. How much promotion are there in each month for each product
```sql
--calculate promotion of each product in each month
select 
    extract(month from order_date) month,
    id_product,
    sum(revenue_discount) ttl_discount
from cleaned_sales
group by 
    extract(month from order_date),
    id_product
order by extract(month from order_date), sum(revenue_discount);

--calculate the total discount in each month
select 
    extract(month from order_date) month,
    sum(revenue_discount) ttl_discount
from cleaned_sales
group by 
    extract(month from order_date)
order by extract(month from order_date), sum(revenue_discount);

--calculate the total discount of each product
select 
    id_product,
    sum(revenue_discount) ttl_discount
from cleaned_sales
group by 
    id_product
order by sum(revenue_discount);
```
# Result set (Preview)
| MONTH | ID_PRODUCT | TTL_DISCOUNT |
|-------|------------|--------------|
| 1     | BWK-20-4   | 0.3          |
| 1     | B-30-3     | 0.4          |
| 1     | FK-20-10   | 0.63         |
| 1     | GY-60-12   | 0.65         |
| 1     | GY-60-13   | 0.65         |
| 1     | JS-50-15   | 0.73         |
| 1     | TK-40-19   | 0.86         |
| 1     | D-30-11    | 1            |
| 1     | CB-10-7    | 1.06         |
| 1     | Q-30-17    | 1.08         |

| MONTH | TTL_DISCOUNT |
|-------|--------------|
| 1     | 35.49        |
| 2     | 28.44        |
| 3     | 32.53        |
| 4     | 107.72       |
| 5     | 120.71       |
| 6     | 99.35        |
| 7     | 116.42       |
| 8     | 128.29       |
| 9     | 30.67        |
| 10    | 34.16        |
| 11    | 228.51       |
| 12    | 634.14       |

| ID_PRODUCT | TTL_DISCOUNT |
|------------|--------------|
| DS-50-8    | 35.35        |
| GY-60-12   | 37.13        |
| D-30-11    | 40.42        |
| CY-60-6    | 40.49        |
| B-30-3     | 40.84        |
| FK-20-10   | 41.28        |
| Q-30-17    | 42.51        |
| TK-40-19   | 43.05        |
| BWK-20-4   | 43.39        |
| JS-50-15   | 44.8         |
| GY-60-13   | 45.64        |
| A-10-1     | 47.56        |
| CB-10-7    | 48.94        |
| S-30-18    | 86.61        |
| EK-40-9    | 89.1         |
| C-30-5     | 120.22       |
| MB-30-16   | 139.24       |
| BK-40-2    | 170.94       |
| JB-50-14   | 215.33       |
| Y-10-20    | 223.59       |

# Insight

### 
There are the most revenue discount in Dec and for Y-10-20 (Yanaki) product. In each month, Y-10-20 have the highest discount. Moreover, Yanaki have high number of purchase and revenue. That means Y-10-20 is effective product.
Dec contributes the highest revenue of the year, while Dec have the most discount. That means the discount program is suitable and effective

---
# 7. Calculate total orders, total revenue, total profit and net margin of each products? Order by net margin descending
```sql
select  
    id_product,
    sum(ttl_orders) ttl_orders,
    sum(ttl_rev) ttl_rev,
    round(sum(ttl_rev) - sum(ttl_cost),2) ttl_profit,
    round((sum(ttl_rev) - sum(ttl_cost)) / sum(ttl_rev),5)*100 as net_margin
from summary_table
group by id_product
order by net_margin desc;
```
# Result set
| ID_PRODUCT | TTL_ORDERS | TTL_REV     | TTL_PROFIT | NET_MARGIN |
|------------|------------|-------------|------------|------------|
| GY-60-13   | 7478       | 32161.82    | 19525.51   | 60.71      |
| JB-50-14   | 36416      | 197234.6405 | 104960.6   | 53.216     |
| S-30-18    | 14729      | 213014.174  | 97808.34   | 45.916     |
| GY-60-12   | 5703       | 32401.2375  | 14309.63   | 44.164     |
| MB-30-16   | 23523      | 465381.187  | 194997.19  | 41.901     |
| TK-40-19   | 7118       | 110706.4497 | 46265.01   | 41.791     |
| BK-40-2    | 28549      | 175734.0145 | 73308.38   | 41.716     |
| DS-50-8    | 5828       | 63651.418   | 26484.14   | 41.608     |
| Q-30-17    | 7305       | 194720.9145 | 74236.08   | 38.124     |
| CY-60-6    | 6654       | 81960.3855  | 30077.24   | 36.697     |
| Y-10-20    | 37414      | 528655.086  | 193655.45  | 36.632     |
| B-30-3     | 6599       | 101686.4695 | 37216.09   | 36.599     |
| EK-40-9    | 14842      | 270048.967  | 97012.27   | 35.924     |
| C-30-5     | 19966      | 330140.4645 | 117555.09  | 35.608     |
| JS-50-15   | 7662       | 91810.8975  | 32402.64   | 35.293     |
| D-30-11    | 7010       | 143308.0425 | 50200.96   | 35.03      |
| BWK-20-4   | 7050       | 346874.268  | 120346.67  | 34.695     |
| FK-20-10   | 6876       | 609622.0542 | 191134.43  | 31.353     |
| A-10-1     | 7883       | 116139.298  | 36138.33   | 31.116     |
| CB-10-7    | 8442       | 147137.4615 | 41540.78   | 28.233     |

# Insight

###
In general, the net_margin of all products was more than 25%.The most effective product is GY-60-13. Although FK-20-10 made the highest revenue but this product was not effective when it had low net margin.

---
# 8. Calculate the revenue contribution percentage by product
```sql
--The cummulative percent in revenue of each product 
select 
    id_product,
    ttl_rev,
    sum(ttl_rev) over (order by ttl_rev desc) cum_rev,
    round(sum(ttl_rev) over (order by ttl_rev desc) / sum(ttl_rev) over (),3)*100 cum_percent
from(
    select 
        id_product,
        sum(ttl_rev) ttl_rev
    from summary_table
    group by id_product
);

-- List products that contribute 80% revenue (Pareto)
select 
    cv.*,
    p.products
from(
    select 
        id_product,
        ttl_rev,
        sum(ttl_rev) over (order by ttl_rev desc) cum_rev,
        round(sum(ttl_rev) over (order by ttl_rev desc) / sum(ttl_rev) over (),3)*100 cum_percent
    from(
        select 
            id_product,
            sum(ttl_rev) ttl_rev
        from summary_table
        group by id_product
    )) cv
join product p
    on p.id_product = cv.id_product
where cv.cum_percent <= 80
order by cv.cum_percent;
```
# Result set for Pareto
| ID_PRODUCT | TTL_REV     | CUM_REV      | CUM_PERCENT | PRODUCTS       |
|------------|-------------|--------------|-------------|----------------|
| FK-20-10   | 609622.0542 | 609622.0542  | 14.3        | Fighter Kite   |
| Y-10-20    | 528655.086  | 1138277.1402 | 26.8        | Yanaki         |
| MB-30-16   | 465381.187  | 1603658.3272 | 37.7        | Majestic Beaut |
| BWK-20-4   | 346874.268  | 1950532.5952 | 45.9        | Bi Wing Kite   |
| C-30-5     | 330140.4645 | 2280673.0597 | 53.6        | Carlota        |
| EK-40-9    | 270048.967  | 2550722.0267 | 60          | Eagle Kite     |
| S-30-18    | 213014.174  | 2763736.2007 | 65          | Sunset         |
| JB-50-14   | 197234.6405 | 2960970.8412 | 69.6        | Juggling Bags  |
| Q-30-17    | 194720.9145 | 3155691.7557 | 74.2        | Quad           |
| BK-40-2    | 175734.0145 | 3331425.7702 | 78.3        | Beginner Kite  |

# Insight

###
There are 10 products that contribute 80% revenue. Kite-related products dominate the revenue contribution among top-performing products.

---
# 9. Compare average actual cost with standard cost of each product?
```sql
select 
    st.id_product,
    round(sum(st.ttl_cost),2) ttl_cost,
    sum(st.ttl_orders) tll_orders,
    round(round(sum(st.ttl_cost),2) / sum(st.ttl_orders),2) avg_actual_cost,
    round(p.standard_cost,2) standard_cost,
    round(sum(st.ttl_cost) / sum(st.ttl_orders),2) - round(p.standard_cost,2) diff
from summary_table st
join product p
    on p.id_product = st.id_product
group by st.id_product, p.standard_cost
order by diff
```
# Result set
| ID_PRODUCT | TTL_COST  | TLL_ORDERS | AVG_ACTUAL_COST | STANDARD_COST | DIFF  |
|------------|-----------|------------|-----------------|---------------|-------|
| FK-20-10   | 418487.62 | 6876       | 60.86           | 64            | -3.14 |
| BWK-20-4   | 226527.6  | 7050       | 32.13           | 33.77         | -1.64 |
| Q-30-17    | 120484.83 | 7305       | 16.49           | 17.41         | -0.92 |
| CB-10-7    | 105596.68 | 8442       | 12.51           | 13.27         | -0.76 |
| D-30-11    | 93107.08  | 7010       | 13.28           | 14.02         | -0.74 |
| MB-30-16   | 270384    | 23523      | 11.49           | 12.12         | -0.63 |
| EK-40-9    | 173036.7  | 14842      | 11.66           | 12.27         | -0.61 |
| C-30-5     | 212585.38 | 19966      | 10.65           | 11.18         | -0.53 |
| A-10-1     | 80000.97  | 7883       | 10.15           | 10.65         | -0.5  |
| Y-10-20    | 334999.64 | 37414      | 8.95            | 9.41          | -0.46 |
| B-30-3     | 64470.38  | 6599       | 9.77            | 10.23         | -0.46 |
| TK-40-19   | 64441.44  | 7118       | 9.05            | 9.5           | -0.45 |
| S-30-18    | 115205.83 | 14729      | 7.82            | 8.26          | -0.44 |
| JS-50-15   | 59408.26  | 7662       | 7.75            | 8.17          | -0.42 |
| CY-60-6    | 51883.14  | 6654       | 7.8             | 8.17          | -0.37 |
| DS-50-8    | 37167.28  | 5828       | 6.38            | 6.72          | -0.34 |
| BK-40-2    | 102425.64 | 28549      | 3.59            | 3.77          | -0.18 |
| JB-50-14   | 92274.04  | 36416      | 2.53            | 2.67          | -0.14 |
| GY-60-12   | 18091.61  | 5703       | 3.17            | 3.3           | -0.13 |
| GY-60-13   | 12636.31  | 7478       | 1.69            | 1.78          | -0.09 |

# Insight

###
All products have average actual cost smaller than standard cost. That means company control the cost of each product efficiently. FK-20-10 have biggest difference between average actual cost and standard cost.

---





