-- SELECTING ALL DATA TO GET THE GLIMPSE OF TABLE
			SELECT * FROM NashvilleHousing;

--Corecting saledate format , currently in datetime format , now changing it to date format for better readability

			ALTER table NashvilleHousing
			ADD  ModifiedSaleDate date;

			UPDATE NashvilleHousing
			SET ModifiedSaleDate = CONVERT(DATE,SaleDate)

			ALTER TABLE NashvilleHousing
			DROP COLUMN SaleDate;

--Checking NULL property Address

			SELECT * FROM NashvilleHousing
			WHERE PropertyAddress IS NULL;

--Since same parcelId would have been delivered to same property hence trying to populate null property address by matching parcelId from previous
--same parcelId
			SELECT A.[UniqueID ],A.ParcelID,A.PropertyAddress,B.[UniqueID ],B.ParcelID,B.PropertyAddress
			FROM NashvilleHousing A INNER JOIN NashvilleHousing B
			ON A.ParcelID = B.ParcelID AND A.[UniqueID ] != B.[UniqueID ]
			--A.[UniqueID ] = B.[UniqueID ] AND A.ParcelID = B.ParcelID
			WHERE A.PropertyAddress IS NULL;

			UPDATE A 
			SET PropertyAddress = B.PropertyAddress
			FROM NashvilleHousing A INNER JOIN NashvilleHousing B
			ON A.ParcelID = B.ParcelID AND A.[UniqueID ] != B.[UniqueID ]
			--A.[UniqueID ] = B.[UniqueID ] AND A.ParcelID = B.ParcelID
			WHERE A.PropertyAddress IS NULL;

			SELECT * FROM NashvilleHousing;

--Cleaning SoldAsVacant column to conver Y to Yes and N to No

			SELECT SoldAsVacant,COUNT(*) AS count_of_rows
			FROM NashvilleHousing
			GROUP BY SoldAsVacant
			ORDER BY count_of_rows;

			BEGIN TRANSACTION

			UPDATE NashvilleHousing
			SET SoldAsVacant = 
			CASE WHEN SoldAsVacant =  'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END

			--ROLLBACK TRANSACTION;
			COMMIT;

--Removing duplicate rows from dataset (Optional cleaning)


			WITH CTE_DUPLICATE AS(
			SELECT *,
			ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,LegalReference,ModifiedSaleDate order by UniqueID) AS ROW_NUM
			FROM NashvilleHousing
			)
			--SELECT * FROM CTE_DUPLICATE WHERE ROW_NUM>1;

			DELETE
			FROM CTE_DUPLICATE WHERE ROW_NUM>1;
			COMMIT;

--Splitting Address by address,city,state over PropertyAddress, OwnerAddress
			Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
			SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
			FROM NashvilleHousing;

			--Adding new columns to accomodate new data
			--Adding Property_house column to include basic house address
					ALTER TABLE NashvilleHousing
					ADD  PROPERTY_ADDRESS_HOUSE NVARCHAR(250);
			--Adding Property State to include state in which house is present
					ALTER TABLE NashvilleHousing
					ADD  PROPERTY_ADDRESS_CITY NVARCHAR(250);

			--UPDATING ADDRESS 
					UPDATE NashvilleHousing
					SET PROPERTY_ADDRESS_HOUSE = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
					UPDATE NashvilleHousing
					SET PROPERTY_ADDRESS_CITY = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

			SELECT *
			FROM NashvilleHousing ORDER BY ParcelID;

--Doing same with ownerAddress (But now instead of substring we will use parsename function)
--Parsename function uses '.' dot as an delimited identifier so we will have to replace ',' with '.' dot for parsename to work

			SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1),
			PARSENAME(REPLACE(OwnerAddress,',','.'),2),
			PARSENAME(REPLACE(OwnerAddress,',','.'),3)
			FROM NashvilleHousing ORDER BY ParcelID;

			--Now adding columns to accomodate new splitted data
					ALTER TABLE NashvilleHousing
					ADD  OWNER_ADDRESS_HOUSE NVARCHAR(250),
						OWNER_ADDRESS_CITY NVARCHAR(250),
						OWNER_ADDRESS_STATE NVARCHAR(250);
			--Now updating owner address column which we have splitted
					UPDATE NashvilleHousing
					SET OWNER_ADDRESS_HOUSE = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
						OWNER_ADDRESS_CITY = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
						OWNER_ADDRESS_STATE = PARSENAME(REPLACE(OwnerAddress,',','.'),1);
	

SELECT *
FROM NashvilleHousing ORDER BY ParcelID;

--Deleting unused columns
			SELECT * FROM NashvilleHousing
			order by ParcelID;

			ALTER TABLE NashvilleHousing
			DROP COLUMN OwnerAddress,PropertyAddress;

