------------------------------------------------------------------------------------
--Data Cleaning using SQL
------------------------------------------------------------------------------------

Select * 
from Portfolio_Project.dbo.NashvilleHousing
-------------------------------------------------------------------------------------
-- Standardise Date Format
Select SaleDate, Convert(date,SaleDate)
from Portfolio_Project..NashvilleHousing

Alter table Portfolio_Project..NashvilleHousing
add SaleDateConverted date

Update Portfolio_Project..NashvilleHousing
Set SaleDateConverted=Convert(date,saledate)

Select * 
from Portfolio_Project.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------
--Populate Property address data
Select UniqueID, ParcelID, PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing
where PropertyAddress is not null
order by ParcelID   ---here in this data we have same parcelID and same property address for multiple entries

Select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.uniqueID<>b.uniqueID
where a.PropertyAddress is null 

update a
set
a.propertyaddress=isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.uniqueID<>b.uniqueID
where a.PropertyAddress is null 

-------------------------------------------------------------------------------------------------
--Breaking out address into individual column (address,city,state)
Select 
Substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as City
from Portfolio_Project.dbo.NashvilleHousing

Alter table Portfolio_Project.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set PropertySplitAddress=Substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

Alter table Portfolio_Project.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set PropertySplitCity=substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from Portfolio_Project.dbo.NashvilleHousing

Alter table Portfolio_Project.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255),OwnerSplitCity nvarchar(255),OwnerSplitState nvarchar(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

Update Portfolio_Project.dbo.NashvilleHousing
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

Update Portfolio_Project.dbo.NashvilleHousing
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------
--Convert N and Y to Yes and No
Select DISTINCT(soldasvacant),count(soldasvacant)
from Portfolio_Project.dbo.NashvilleHousing
group by soldasvacant
order by 2


Select soldasvacant,
case when soldasvacant='Y' then 'Yes'
     when soldasvacant='Noo' then 'No'
	 else soldasvacant
	 end
from Portfolio_Project.dbo.NashvilleHousing

Update Portfolio_Project.dbo.NashvilleHousing
Set soldasvacant=case when soldasvacant='Y' then 'Yes'
     when soldasvacant='Noo' then 'No'
	 else soldasvacant
	 end

-----------------------------------------------------------------------------------------------------
--Remove Duplicates

--USE CTE
With ROWNUMCTE as(
Select *,
   ROW_NUMBER() over (
   partition by ParcelID,
                PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference,
				OwnerName,
				OwnerAddress
				order by uniqueID
				)  row_num
from Portfolio_Project.dbo.NashvilleHousing
)
Delete 
from ROWNUMCTE
where row_num>1
--order by parcelID

With ROWNUMCTE as(
Select *,
   ROW_NUMBER() over (
   partition by ParcelID,
                PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference,
				OwnerName,
				OwnerAddress
				order by uniqueID
				)  row_num
from Portfolio_Project.dbo.NashvilleHousing
)
Select * 
from ROWNUMCTE
where row_num>1
order by parcelID       ----No more Duplicates

----------------------------------------------------------------------------------------------------
---Remove unused column
Alter table Portfolio_Project.dbo.NashvilleHousing
drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict,address,city

Select * 
from Portfolio_Project.dbo.NashvilleHousing