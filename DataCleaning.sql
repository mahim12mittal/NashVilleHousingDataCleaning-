-- cleaning data in sql queries 

SELECT * FROM Portfolio.nashville_housing;

-- standardize date format

-- SELECT SaleDate, convert(SaleDate,Date)
-- FROM Portfolio.nashville_housing;

-- Update nashville_housing
-- set SaleDate = convert(SaleDate,Date);

-- Alter Table nashville_housing
-- Add SaleDateConverted Date;

-- Update nashville_housing
-- Set SaleDateConverted = convert(SaleDate, date );

-- Populate Property Address Data 	

SELECT *
FROM Portfolio.nashville_housing
-- Where propertyaddress is null;
order by Parcelid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM Portfolio.nashville_housing a join Portfolio.nashville_housing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

-- Update a
-- set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
-- FROM Portfolio.nashville_housing a join Portfolio.nashville_housing b
-- on a.parcelid = b.parcelid
-- and a.uniqueid <> b.uniqueid;

UPDATE Portfolio.nashville_housing a
JOIN Portfolio.nashville_housing b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
SET a.propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress);

-- breaking the address into indivisual columns (Address, city , state)

SELECT PropertyAddress
FROM Portfolio.nashville_housing;
-- Where propertyaddress is null;
-- order by Parcelid;

-- Select substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1 ) as address
-- FROM Portfolio.nashville_housing

SELECT SUBSTRING_INDEX(PropertyAddress, ',', 1) AS address , 
SUBSTRING_INDEX(PropertyAddress, ',', -1) as address 
FROM Portfolio.nashville_housing;

alter table nashville_housing 
add PropertySplitAddress Nvarchar(255);

Update nashville_housing
Set PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1) ;

alter table nashville_housing 
add PropertySplitCity Nvarchar(255);

Update nashville_housing
Set PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1) ;

SELECT * FROM Portfolio.nashville_housing;

Select OwnerAddress
from Portfolio.nashville_housing;

-- Select parsename(replace(owneraddress,',',1))
-- from Portfolio.nashville_housing;

SELECT SUBSTRING_INDEX(owneraddress, ',', 1) AS address , 
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2),',',-1) as address ,
SUBSTRING_INDEX(owneraddress, ',', -1) as address
FROM Portfolio.nashville_housing;

alter table nashville_housing 
add OwnerSplitAddress Nvarchar(255);

Update nashville_housing
Set OwnerSplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1) ;

alter table nashville_housing 
add OwnerSplitCity Nvarchar(255);

Update nashville_housing
Set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2),',',-1);

alter table nashville_housing 
add OwnerSplitState Nvarchar(255);

Update nashville_housing
Set OwnerSplitState = SUBSTRING_INDEX(owneraddress, ',', -1);

SELECT * FROM Portfolio.nashville_housing;

-- change Y and N to yes and no in "Sold as vacant" field 

Select Distinct(SoldAsVacant), count(soldasvacant)
From Portfolio.nashville_housing 
group by soldasvacant 
order by 2;

-- remove duplicate 



select soldasvacant 
, case when soldasvacant = 'Y' then 'Yes'
	   when soldasvacant = 'N' then 'No'
       else soldasvacant 	
       end
From Portfolio.nashville_housing;

update nashville_housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	   when soldasvacant = 'N' then 'No'
       else soldasvacant 	
       end;
 
 select *, 
 row_number() over (partition by 
 parcelid, propertyaddress,saleprice,saledate,legalreference 
 order by uniqueid) row_num
 From Portfolio.nashville_housing
 order by parcelid;
 
 
 
 With RowNumCTE as (
  select *, 
 row_number() over (partition by 
 parcelid, propertyaddress,saleprice,saledate,legalreference 
 order by uniqueid) row_num
 From Portfolio.nashville_housing
 -- order by parcelid
 )

 Select * from RowNumCTE
 where row_num > 1
 order by propertyaddress;
 
 -- delete the duplicate row
 
 DELETE FROM Portfolio.nashville_housing
WHERE (parcelid, propertyaddress, saleprice, saledate, legalreference, uniqueid) IN (
    SELECT t1.parcelid, t1.propertyaddress, t1.saleprice, t1.saledate, t1.legalreference, t1.uniqueid
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid) AS row_num
        FROM Portfolio.nashville_housing
    ) AS t1
    WHERE t1.row_num > 1
);


-- delete unused columns 

SELECT * FROM Portfolio.nashville_housing;

Alter table Portfolio.nashville_housing
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress;








    


