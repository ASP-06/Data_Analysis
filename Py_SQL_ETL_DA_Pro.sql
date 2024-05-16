SELECT TOP (1000) [order_id]
      ,[order_date]
      ,[ship_mode]
      ,[segment]
      ,[country]
      ,[city]
      ,[state]
      ,[postal_code]
      ,[region]
      ,[category]
      ,[sub_category]
      ,[product_id]
      ,[quantity]
      ,[discount]
      ,[sale_price]
      ,[profit]
  FROM [master].[dbo].[df_Orders];


/*
  -- Drop Table and create again with required Datatype limit

  Drop table [df_Orders]

  select * from [df_Orders]

  create table df_Orders(
       [order_id]  int primary key
      ,[order_date]   date
      ,[ship_mode]    varchar(20)
      ,[segment]      varchar(20)
      ,[country]      varchar(20)
      ,[city]		  varchar(20)
      ,[state]		  varchar(20)
      ,[postal_code]  varchar(20)
      ,[region]		  varchar(20)
      ,[category]	  varchar(20)
      ,[sub_category] varchar(20)
      ,[product_id]	  varchar(20)
      ,[quantity]	  int
      ,[discount]	  decimal(7,2)
      ,[sale_price]	  decimal(7,2)
      ,[profit]		  decimal(7,2)
	  );
*/
	  select * from df_Orders;

-- find top 10 highest revenue generating products
-- As per product price & sales(as per my thoughts)
select top 10 [product_id], sum([sale_price]*[quantity]) as sales_rev
from df_Orders
group by product_id
order by sales_rev desc ;

--As per just product price
select top 10 [product_id], sum([sale_price]) as sales_rev
from df_Orders
group by product_id
order by sales_rev desc;


-- find top 5 highest selling products in each region: total count=32(records till 5th rnk for each region)
with cte1 as (
select [region], [product_id], sum([quantity]) sales
, DENSE_RANK()over(partition by region order  by sum([quantity]) desc) as sales_rnk
from df_Orders
group by [region], [product_id])
select region, product_id, sales, sales_rnk from cte1
where sales_rnk<=5

--AS per video they have used just top 5 not all other similar selling ones: total count=20(5 rec for each region)
with cte1 as (
select [region], [product_id], sum([quantity]) sales
, row_number()over(partition by region order  by sum([quantity]) desc) as sales_rnk
from df_Orders
group by [region], [product_id])
select region, product_id, sales, sales_rnk from cte1
where sales_rnk<=5


--Find month over month growth comparision for 2022 & 2023 sales eg:- Jan 2022 vs Jan 2023
with cte1 as (
select MONTH(order_date) as Months
, case when YEAR(order_date)= 2022 then sum([sale_price]) else 0 end as 'Sales_2022'
, case when YEAR(order_date)= 2023 then sum([sale_price]) else 0 end as 'Sales_2023'
from df_Orders o
group by YEAR(order_date), MONTH(order_date)
)
select Months
, sum(Sales_2022) as '2022'
, sum(Sales_2023) as '2023'
from cte1
group by Months;


-- For each category which month had highest sales
with cte2 as (
select   [category], MONTH([order_date]) Months 
, sum([sale_price]) sales_tot 
, ROW_NUMBER()over(partition by category order by sum([sale_price])  desc) rn
from df_Orders
group by [category],  MONTH([order_date])
--order by   [category], sum([sale_price]) desc--MONTH([order_date]), 
) 
select [category]
, sales_tot
, Months
from cte2 
where rn=1
Order by sales_tot desc


--Which Subcategory has highest growth by profit in 2023 compared to 2022
select * from df_Orders;
-- by profit
with cte_profit_comp as
(
select [sub_category]
, case when YEAR([order_date])=2022 then sum([profit]) else 0 end as profit_2022
, case when YEAR([order_date])=2023 then sum([profit]) else 0 end as profit_2023
from df_Orders
group by [sub_category]
,  YEAR([order_date])
)
select [sub_category]
, sum(profit_2022) as profit_2022
, sum(profit_2023) as profit_2023
, (sum(profit_2022) - sum(profit_2023) ) profit_growth 
from cte_profit_comp
group by [sub_category]
order by (sum(profit_2022) - sum(profit_2023) ) desc

-- by profit growth

with cte_profit_comp as
(
select [sub_category]
, case when YEAR([order_date])=2022 then sum([profit]) else 0 end as profit_2022
, case when YEAR([order_date])=2023 then sum([profit]) else 0 end as profit_2023
from df_Orders
group by [sub_category]
,  YEAR([order_date])
)
select top 1
[sub_category]
, sum(profit_2022) as profit_2022
, sum(profit_2023) as profit_2023
, (sum(profit_2023) - sum(profit_2022) ) profit_growth 
from cte_profit_comp
group by [sub_category]
order by (sum(profit_2023) - sum(profit_2022) ) desc

-- by percentage growth

with cte1 as (
select [sub_category]
, case when YEAR(order_date)= 2022 then sum([sale_price]) else 0 end as 'Sales_2022'
, case when YEAR(order_date)= 2023 then sum([sale_price]) else 0 end as 'Sales_2023'
from df_Orders o
group by [sub_category] ,  YEAR([order_date])
)
select top 1
[sub_category]
, sum(Sales_2022) as '2022'
, sum(Sales_2023) as '2023'
, ((sum(Sales_2023) - sum(Sales_2022))*100/sum(Sales_2022)) profit_growth 
from cte1
group by [sub_category]
order by ((sum(Sales_2023) - sum(Sales_2022))*100/sum(Sales_2022)) desc









