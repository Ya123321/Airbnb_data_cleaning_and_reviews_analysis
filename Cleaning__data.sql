-- https://www.kaggle.com/datasets/ruthgn/new-orleans-airbnb-listings-and-reviews

select * from dbo.new_orleans_airbnb

-- Standardize Date Format

select first_reviewConverted, convert(Date,first_review)
from portfolio_Project..new_orleans_airbnb

update new_orleans_airbnb
set first_reviewConverted= convert(Date,first_review)

alter table new_orleans_airbnb
add first_reviewConverted Date;

select last_reviewConverted, convert(Date,last_review)
from portfolio_Project..new_orleans_airbnb

update new_orleans_airbnb
set last_reviewConverted= convert(Date,last_review) 

alter table new_orleans_airbnb
add last_reviewConverted Date;

select host_sinceConverted, convert(Date,host_since)
from portfolio_Project..new_orleans_airbnb

update new_orleans_airbnb
set host_sinceConverted= convert(Date,host_since) 

alter table new_orleans_airbnb
add host_sinceConverted Date;

---Change t and f to Yes and No in fields

update new_orleans_airbnb
set host_has_profile_pic= case when host_has_profile_pic='t' then 'yes'
       when host_has_profile_pic= 'f' then 'no'
	   else host_has_profile_pic
	   end
	

update new_orleans_airbnb
set host_identity_verified= case when host_identity_verified='t' then 'yes'
       when host_identity_verified= 'f' then 'no'
	   else host_identity_verified
	   end


update new_orleans_airbnb
set instant_bookable= case when instant_bookable='t' then 'yes'
       when instant_bookable= 'f' then 'no'
	   else instant_bookable
	   end

update new_orleans_airbnb
set host_is_superhost= case when host_is_superhost='t' then 'yes'
       when host_is_superhost= 'f' then 'no'
	   else host_is_superhost
	   end

update new_orleans_airbnb
set has_availability= case when has_availability='t' then 'yes'
       when has_availability= 'f' then 'no'
	   else has_availability
	   end

-- Convert the price float 

alter table dbo.new_orleans_airbnb
drop column new_price

select substring(price,2,len(price))
from dbo.new_orleans_airbnb

alter table new_orleans_airbnb
add new_price varchar(25);

update new_orleans_airbnb
set new_price= substring(price,2,len(price))

select new_price, cast(replace(replace(new_price, '.00', ''), ',','') as float)
from new_orleans_airbnb  

update new_orleans_airbnb
set new_price= cast(replace(replace(new_price, '.00', ''), ',','') as float)


--Extracts the parentheses

select substring(host_verifications,2,len(host_verifications)-2) 
from dbo.new_orleans_airbnb

update new_orleans_airbnb
set host_verificationsNoparentheses= substring(host_verifications,2,len(host_verifications)-2) 

alter table new_orleans_airbnb
add host_verificationsNoparentheses varchar(255);

-- Remove Duplicates

with RowNumberCTE as(
select *, row_number () over (partition by
id, name
order by 
id)
row_num
from Portfolio_Project.dbo.new_orleans_airbnb
)
select * from RowNumberCTE 
where row_num>1

--Breaking out host_location into Individual Columns (city,country, state)

select parsename (replace(host_location,',','.'),1)
,parsename (replace(host_location,',','.'),2)
,parsename (replace(host_location,',','.'),3)
from Portfolio_Project.dbo.new_orleans_airbnb

alter table new_orleans_airbnb
add state Nvarchar(255);

update dbo.new_orleans_airbnb
SET state= parsename (replace(host_location,',','.'),1) 

update dbo.new_orleans_airbnb
SET state = case when state ='US' then 'United States'
else state
	   end

alter table new_orleans_airbnb
add country Nvarchar(255);

update dbo.new_orleans_airbnb
SET country= parsename (replace(host_location,',','.'),2) 

alter table new_orleans_airbnb
add city Nvarchar(255);

update dbo.new_orleans_airbnb
SET city= parsename (replace(host_location,',','.'),3) 

-- make bathrooms can be counted
alter table new_orleans_airbnb
add bathrooms float;

update new_orleans_airbnb
set bathrooms = substring(bathrooms_text,1,charindex(' ',bathrooms_text,1))

-- copy the data into a new table

select * into airbnb_cleaning from dbo.new_orleans_airbnb

select * from airbnb_cleaning

-- Delete columns that are not relevant
alter table airbnb_cleaning
drop column host_location, first_review, last_review, host_since,host_verifications,bathrooms_text, price,license

--alter table airbnb_cleaning
--drop column license