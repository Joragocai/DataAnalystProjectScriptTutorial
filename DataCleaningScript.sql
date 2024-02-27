USE PortfolioProject;

SELECT * 
FROM nashville;

#Standardize date format
UPDATE nashville
SET SaleDate = STR_TO_DATE(SaleDate,'%Y-%m-%d');

#Populate Property Address Data
SELECT v1.ParcelID, v1.PropertyAddress, v2.ParcelID, v2.PropertyAddress, 
COALESCE(v1.PropertyAddress, v2.PropertyAddress) AS MergedPropertyAddress
FROM nashville v1
JOIN nashville v2
	ON v1.ParcelID = v2.ParcelID
    AND
    v1.UniqueID <> v2.UniqueID
WHERE v1.PropertyAddress IS NULL;

#Update Property Address Data to have all null data to have value
UPDATE nashville v1
JOIN nashville v2 
	ON v1.ParcelID = v2.ParcelID 
	AND
	v1.UniqueID <> v2.UniqueID
SET v1.PropertyAddress = COALESCE(v1.PropertyAddress, v2.PropertyAddress)
WHERE v1.PropertyAddress IS NULL;

#Breakout Property Address into(Address & City)
SELECT PropertyAddress 
FROM nashville;

 SELECT 
 SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress,',')-1) AS Address
 ,SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',' )+2) AS City
 FROM nashville;
 
 ALTER TABLE nashville
 ADD PropertySplitAddress NVARCHAR(255);
 
 UPDATE nashville
 SET PropertySplitAddress 
 =SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress,',')-1);
 
 ALTER TABLE nashville
 ADD PropertySplitCity NVARCHAR(255);
 
 UPDATE nashville
 SET PropertySplitCity 
 =SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',' )+2);
 
 #Using Substring_index to separate multiple strings of Owner_Address Table
 SELECT OwnerAddress, 
 SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-3),',',1) AS address,
 SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-2),',',1) AS city,
 SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-1),',',1) AS state
 FROM nashville;
 
 ALTER TABLE nashville
 ADD OwnerSplitAddress NVARCHAR(255);
 
 UPDATE nashville
 SET OwnerSplitAddress 
 = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-3),',',1);
 
 ALTER TABLE nashville
 ADD OwnerSplitCity NVARCHAR(255);
 
 UPDATE nashville
 SET OwnerSplitCity
 = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-2),',',1);
 
 ALTER TABLE nashville
 ADD OwnerSplitState NVARCHAR(255);
 
 UPDATE nashville
 SET OwnerSplitState
 = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-1),',',1);
 
#Changing Y and N to Yes and No to coaptate it Number of values in 2 distinct parts
SELECT SoldAsVacant, COUNT(SoldAsVacant) AS NumberOfBool
FROM nashville
GROUP BY  SoldAsVacant
ORDER BY NumberOfBool;

SELECT SoldAsVacant
,CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM nashville;

Update nashville
SET SoldAsVacant  = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

#How to detect duplicates and remove it
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
	ORDER BY UniqueID
	) AS row_num
FROM nashville
ORDER BY ParcelID;


DELETE FROM nashville
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM nashville
    ) AS subquery
    WHERE row_num > 1
);

#DELETE UNUSED COLUMNS
SELECT * 
FROM nashville;

ALTER TABLE nashville
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;