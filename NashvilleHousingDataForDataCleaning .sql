/* Cleaning Data in SQL */
SELECT *
from PortfolioProject.dbo.NashvilleHousingDataForDataCleaning 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Change Date format


SELECT SaleDate, CONVERT (date, SaleDate)
from NashvilleHousingDataForDataCleaning 


UPDATE NashvilleHousingDataForDataCleaning
SET SaleDate = CONVERT(date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Fills in missing PropertyAddress values by using a non-null value 
-- from another row with the same ParcelID.


SELECT *
FROM NashvilleHousingDataForDataCleaning
-- WHERE PropertyAddress is NULL 
order BY ParcelID 


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingDataForDataCleaning  a
Join NashvilleHousingDataForDataCleaning b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress is NULL


UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingDataForDataCleaning  a
Join NashvilleHousingDataForDataCleaning b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Splits the PropertyAddress column into separate columns for Address and City,
-- Using SUBSTRING AND PARSENAME


SELECT PropertyAddress 
FROM NashvilleHousingDataForDataCleaning


SELECT 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address 
from NashvilleHousingDataForDataCleaning


ALTER table NashvilleHousingDataForDataCleaning 
add PropertySplitAddress Nvarchar(225);

UPDATE NashvilleHousingDataForDataCleaning 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)


ALTER table NashvilleHousingDataForDataCleaning 
add PropertySplitCity Nvarchar(225);

UPDATE NashvilleHousingDataForDataCleaning 
SET PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousingDataForDataCleaning

-- Splits the OwnerAddress column into separate columns for Address, City, and State.
-- Using PARSENAME


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingDataForDataCleaning



ALTER table NashvilleHousingDataForDataCleaning 
add OwnerSplitAddress Nvarchar(225);

UPDATE NashvilleHousingDataForDataCleaning 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER table NashvilleHousingDataForDataCleaning 
add OwnerSplitCity Nvarchar(225);

UPDATE NashvilleHousingDataForDataCleaning 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER table NashvilleHousingDataForDataCleaning 
add OwnerSplitState Nvarchar(225);

UPDATE NashvilleHousingDataForDataCleaning 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO in "Sold as Vacant" field for better readability

SELECT *
FROM NashvilleHousingDataForDataCleaning


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) 
from NashvilleHousingDataForDataCleaning 
Group by SoldAsVacant 
ORDER by 2


SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		End
from NashvilleHousingDataForDataCleaning 


UPDATE NashvilleHousingDataForDataCleaning 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		End

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates using CTE
-- Identify and selects rows with duplicate values based on specific columns and keeps only one instance.

WITH RowNumbCTE as(		
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
				) row_num
from NashvilleHousingDataForDataCleaning 
)
SELECT *
FROM RowNumbCTE
WHERE row_num > 1



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns, the OwnerAddress and PropertyAddress from the table


SELECT *
FROM NashvilleHousingDataForDataCleaning


ALTER TABLE NashvilleHousingDataForDataCleaning 
DROP COLUMN OwnerAddress, PropertyAddress

