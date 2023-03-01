
--Cleaning Data in SQL Queries 



SELECT *
FROM [Nashville Housing]   

---------------------------------------------------------------------------------------------------------------------
--Standarize Data Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM [Nashville Housing]

Update [Nashville Housing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville Housing] 
Add SaleDateConverted Date;

Update [Nashville Housing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT PropertyAddress 
FROM [Nashville Housing]
WHERE PropertyAddress is null

SELECT a. ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

-------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing] 
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

ALTER TABLE [Nashville Housing] 
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM [Nashville Housing]

SELECT OwnerAddress
FROM [Nashville Housing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing] 
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Nashville Housing] 
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Nashville Housing] 
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

----------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
Group by SoldAsVacant


SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

----------------------------------------------------------------------------------------------------------------------

--Remove Duplicates 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference 
		ORDER BY
			UniqueID
			) row_num

FROM [Nashville Housing]
--order by ParcelID
)
SELECT *
FROM RowNumCTE
Where row_num > 1 
Order by PropertyAddress

-------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]  
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE [Nashville Housing]  
DROP COLUMN SaleDate 