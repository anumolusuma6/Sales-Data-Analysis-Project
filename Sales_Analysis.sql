select * from sumadb.df_orders

-- 1. Find top 10 highest revenue generating products
select product_id, sum(sale_price) as revenue 
from sumadb.df_orders
group by 1 order by revenue desc limit 10 

-- 2. Find top 5 highest selling products in each region
with cte as 
(select region, product_id, sum(quantity) as sold 
from sumadb.df_orders
group by region, product_id)
select * from (select * , 
rank() over(partition by region order by sold desc) as rnk
from cte) a 
where rnk <=5

-- 3. find month over month growth comparision for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as (select year(order_date) order_year, month(order_date) order_month, 
sum(profit) as profit
from df_orders
group by year(order_date), month(order_date)
)
select order_month,
sum(case when order_year=2022 then profit else 0 end ) as year_2022,
sum(case when order_year=2023 then profit else 0 end ) as year_2023
from cte
group by order_month
order by order_month

-- 4. for each category, which month had highest sales
with cte as (select category, DATE_FORMAT(order_date, '%Y-%m') as order_year_month,
sum(sale_price) as sales 
from df_orders
group by category, order_year_month) 
select * from (select *,
rank()over(partition by category order by sales desc) as rnk 
from cte ) a
where rnk =1

-- 5. which sub category had highest growth by profit in 2023 compare to 2022
with cte as (select sub_category, date_format(order_date, '%Y') as year,
sum(profit) as profit 
from df_orders
group by sub_category, year
order by profit desc),
cte2 as
(select sub_category, 
sum(case when year= 2022 then profit else 0 end) as profit_2022,
sum(case when year = 2023 then profit else 0 end) as profit_2023
from cte
group by sub_category)
select *,
(profit_2023-profit_2022) *100 / profit_2022 as growth_percentage 
from cte2
order by growth_percentage desc

-- to get the growth 2023-2022 *100 / 2022




