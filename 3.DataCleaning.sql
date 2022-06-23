--Data Cleaning

SELECT * FROM NashvilleHousing

--Standardize date format

SELECT SaleDateConverted,CONVERT(DATE,SaleDate)
FROM NashvilleHousing

UPDATE  NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)              -- This not working anyway :)

ALTER TABLE Nashvillehousing                       -- adding a new column to the table
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)      --Loading tranformed date from Saledate to SaleDateConverted

 --Populate property address data

 SELECT * FROM NashvilleHousing
 WHERE PropertyAddress IS NULL

 SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) FROM
 NashvilleHousing a JOIN
 NashvilleHousing b
 ON a.ParcelID =b.ParcelID
 AND a.[UniqueID ]<> b.[UniqueID ]
 WHERE a.PropertyAddress IS NULL

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM
 NashvilleHousing a JOIN
 Nashvillehousing b
 ON a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]
 WHERE a.PropertyAddress IS NULL

 -- Breaking ou address into individual coulmns(Address,city,State)

SELECT PropertyAddress FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS address FROM NashvilleHousing                    -- address mathram select cheyyunnu
SELECT SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) FROM NashvilleHousing --city name mathram select cheyyunnu

ALTER TABLE NashvilleHousing
ADD address_altered VARCHAR(150)

UPDATE NashvilleHousing
SET address_altered = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD city_altered VARCHAR(150)

UPDATE NashvilleHousing
SET city_altered = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) FROM NashvilleHousing

SELECT PropertyAddress,address_altered,city_altered FROM NashvilleHousing





--Owner address.

SELECT OwnerAddress FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(50)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(50)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(50)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM NashvilleHousing


--Change Y and N to Yes and NO in "SoldAsVacant" column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) FROM NashvilleHousing   -- checking no. of YES,NO,Y,N
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC

SELECT DISTINCT(SoldAsVacant),         -- Converting y- YES ,N - NO
CASE
    WHEN SoldAsVacant='N' THEN 'No'
	WHEN SoldAsVacant='Y' THEN 'Yes'
ELSE SoldAsVacant
END AS Corrected

FROM NashvilleHousing

UPDATE NashvilleHousing  -- Updating sold as vacant column
SET SoldAsVacant = 
CASE
    WHEN SoldAsVacant='N' THEN 'No'
	WHEN SoldAsVacant='Y' THEN 'Yes'
ELSE SoldAsVacant
END 

-- Remove duplicates

SELECT * FROM NashvilleHousing
	
SELECT *,ROW_NUMBER()            -- Using row number function and partition by identify the multiple columns
		OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID
		)Row_num
FROM NashvilleHousing


WITH duplicate_rows AS                     -- Listing out duplicate values
(
SELECT *,ROW_NUMBER()            
		OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID
		)Row_num
FROM NashvilleHousing
)
SELECT * FROM duplicate_rows
WHERE Row_num >1


WITH duplicate_rows AS                     --Deleting duplicate values
(
SELECT *,ROW_NUMBER()            
		OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID
		)Row_num
FROM NashvilleHousing
)
DELETE FROM duplicate_rows
WHERE Row_num >1
		

-- delete unused columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing                                           -- deleting columns
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict,SaleDate


