/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------

-- Standardize Sale Date
 
Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID



Select a.[ParcelID], a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL



--------------------------------------------------------------------------------------------------

-- Breaking down Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))





Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address, 
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
From PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




--------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Column

Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 End
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SoldAsVacant =
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 End





--------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1


--------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate