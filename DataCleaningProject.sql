-- START: Select Data
Select *
from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------
--Standardize Date Format
Select SaleDate,CONVERT (Date,saledate)
from PortfolioProject.dbo.NashvilleHousing

-- Update Saledate on Table using SQL code:
Update NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

-- Import changed data onto table
ALTER Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Check table using new updated and converted information
Select saledateconverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------
-- Populate Property Address Data (find NULL first)
Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null 

-- Use JOIN command to create table where NULL Property Address is identified using Parcel ID. Remove duplicates by using conditional AND with UNIQUE ID. If value is NULL, draw from second table
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.PARCELID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


-- Update table "a" to populate from table b.
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.PARCELID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-------------------------------------------

-- Break out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

-- Use delimiter (,) to separate address and city
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as City
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------
--Alter table to show separated work from above (Address, City) Must execute each command one by one.
ALTER Table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER Table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress))

--Check updates from tables above
Select * 
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------

-- Split "OwnerAddress" into (Address, City, State) using parsename command and delimiters

Select
PARSENAME(Replace(owneraddress,',','.') ,3),
PARSENAME(Replace(owneraddress,',','.') ,2),
PARSENAME(Replace(owneraddress,',','.') ,1)
From PortfolioProject.dbo.NashvilleHousing

--Alter table to show separated work from above "OwnerAddress" into (Address, City, State) Must execute each command one by one.
ALTER Table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing
set OwnerSplitAddress = PARSENAME(Replace(owneraddress,',','.') ,3)

ALTER Table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(owneraddress,',','.') ,2)

ALTER Table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(owneraddress,',','.') ,1)

-- Check work from above by using select*
Select * 
From PortfolioProject.dbo.NashvilleHousing

-- Count distinct values in SoldAsVacant column  
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2
-- 52Y, 399 N, 4626 Yes, 51403 No

-- Change Y and N to "Yes" and "No" respectively in the "Sold As Vacant Field"

Select SoldAsVacant,
Case when soldasvacant = 'Y' THEN 'Yes'
	 when soldasvacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set	 SoldAsVacant =
Case when soldasvacant = 'Y' THEN 'Yes'
	 when soldasvacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
-- Check work after running replacement and update script respectively

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2
	-- 4675 Yes, 51802 No, there are no more 'y' or 'n' values

--------------------------------------------------
-- Identify and remove duplicates (best practice usually does not include deleting data, but for cleaning purposes we will here)
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing
)
DELETE
from RowNumCTE
Where row_num > 1
----------------------------------------------------

-- Delete Unused Columns (columns made irrelevant by splits earlier in project)
Select * 
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select * 
From PortfolioProject.dbo.NashvilleHousing