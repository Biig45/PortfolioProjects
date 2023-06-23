Select * 
From NashvilleHousing

--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From NashvilleHousing


Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)


Alter table NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing
Set SalesDateConverted = Convert(Date,SaleDate)

--Populate Property Address where Parcel is repeated but in 2nd instance there is no Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Breaking out Address into Individual Columns
Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From NashvilleHousing




--Owner Address
Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)  
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2) 
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select *
From NashvilleHousing



--Change Y and N to Yes and No in "Sold As Vacant' field

Select Soldasvacant
,case 
	when Soldasvacant = 'Y' then 'Yes'
	when Soldasvacant = 'N' then 'No'
	Else Soldasvacant
	End
from NashvilleHousing


Update NashvilleHousing
SEt SoldAsVacant = case 
	when Soldasvacant = 'Y' then 'Yes'
	when Soldasvacant = 'N' then 'No'
	Else Soldasvacant
	End



--Remove Duplicates (Using CTE)
With RowNumCTE as(
Select *, 
	Row_Number() over(
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By
	UniqueID
	) row_num
From NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1


--Delete Unused Columns( Do not use this on raw data)

alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress
