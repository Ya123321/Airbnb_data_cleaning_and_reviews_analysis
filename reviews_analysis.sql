--https://www.kaggle.com/datasets/ruthgn/new-orleans-airbnb-listings-and-reviews

select * from dbo.new_orleans_airbnb_reviews

--I started by looking at reviews-count airbnb
select c.name, r.listing_id, c.neighbourhood_cleansed, count(r.listing_id) as number_of_reviews from dbo.new_orleans_airbnb_reviews r join dbo.airbnb_cleaning c on r.listing_id=c.id
group by r.listing_id, c.name,c.neighbourhood_cleansed
order by 4 desc

--- I picked the most reviewed airbnb, This will be my sample for grading
with Top100 as(select top 100 r.listing_id as listing_id, c.name, count(r.listing_id) as number_of_reviews from dbo.new_orleans_airbnb_reviews r join dbo.airbnb_cleaning c on r.listing_id=c.id
group by c.name, r.listing_id
order by 3 desc)

-- Positive keyword filtering
,Positive as( select top 50 c.name,r.listing_id,
 sum(case when comments LIKE '%GREAT%' then 1 else 0 end) as great, sum(case when comments LIKE '%GOOD%' then 1 else 0 end) as good
,sum(case when comments LIKE '%WONDERFUL%' then 1 else 0 end) as wonderful,sum(case when comments LIKE '%comfortable%' then 1 else 0 end) as comfortable
from dbo.new_orleans_airbnb_reviews r join dbo.airbnb_cleaning c on r.listing_id=c.id where r.listing_id in(
select top 100 r.listing_id   
from dbo.new_orleans_airbnb_reviews r join dbo.airbnb_cleaning c on r.listing_id=c.id
group by r.listing_id
order by count(r.listing_id)  desc
)
group by  c.name,r.listing_id
order by 3 desc ,4 desc,5 desc,6 desc)


---Negative keyword filtering
,Negative as (select top 50 c.name,r.listing_id,
 sum(case when comments LIKE '%bad%' then 1 else 0 end) as bad, sum(case when comments LIKE '%poor%' then 1 else 0 end) as poor
,sum(case when comments LIKE '%worst%' then 1 else 0 end) as worst,sum(case when comments LIKE '%sad%' then 1 else 0 end) as sad
from dbo.new_orleans_airbnb_reviews r join dbo.airbnb_cleaning c on r.listing_id=c.id where r.listing_id in(
select top 100 r.listing_id   
from dbo.new_orleans_airbnb_reviews r join dbo.airbnb_cleaning c on r.listing_id=c.id
group by r.listing_id
order by count(r.listing_id)  desc
)
group by  c.name,r.listing_id
order by 3 desc ,4 desc,5 desc,6 desc)

---Calculate the score For those who have received both negative and positive reviews
select p.name,p.listing_id, p.great+p.good+p.wonderful+comfortable as Positive_score , n.bad+n.poor+n.worst+n.sad as Negative_score into scores
from Positive p join Negative n on p.listing_id=n.listing_id 

select * from scores
-- By the result, it can be seen that the negative score is negligible

with score as (select max(positive_score) as max, avg(positive_score) as average
from scores)

select s.name,s.listing_id,Positive_score, case when Positive_score=max then 'The best Airbnbs' when Positive_score>average then 'Airbnb above average' else 'Airbnb below average' end as score, c.new_price as price
from score, scores s join dbo.airbnb_cleaning c on c.id=s.listing_id
group by Positive_score,max,average,s.name,s.listing_id, c.new_price

-- *The apartment with the most positive reviews- "The best Airbnbs"
-- *The positive review for this apartment is higher than average- "Airbnb above average"
-- *The positive review for this apartment is lower than average- "Airbnb below average"

-- Display the best Airbnb based on recommendations
select * from dbo.airbnb_cleaning c where id=(
select top 1 listing_id
from scores 
order by Positive_score desc)





