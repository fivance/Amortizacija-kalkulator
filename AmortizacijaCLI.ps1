Add-Type -AssemblyName PresentationFramework

# Function to calculate full months between dates based on the new logic
Function Calculate-FullMonthsBetweenDates {
    param (
        [datetime]$StartDate,
        [datetime]$EndDate
    )

    # 1. If the dates are the same day (same day, same month, same year), return 1 month
    if ($StartDate.Date -eq $EndDate.Date) {
        return 1
    }

    # 2. If the start and end dates are in the same month and year, return 1 month
    if ($StartDate.Month -eq $EndDate.Month -and $StartDate.Year -eq $EndDate.Year) {
        return 1
    }

    # 3. Calculate total months between start and end dates
    $totalMonths = ($EndDate.Year - $StartDate.Year) * 12 + ($EndDate.Month - $StartDate.Month)

    # 4. If the start date is after the end date (start date > end date), don't add anything extra
    if ($StartDate.Day -gt $EndDate.Day) {
        return $totalMonths
    }

    # 5. If the end date is later in the month than the start date, add 1 extra month
    if ($EndDate.Day -gt $StartDate.Day) {
        $totalMonths += 1
    }

    return $totalMonths
}

# Function to calculate tax rate based on the number of months
Function Calculate-TaxRate {
    param (
        [double]$VrijednostStavke,
        [int]$Months
    )

    # Calculate the tax rate (3% of the value multiplied by the number of months)
    $taxRate = $VrijednostStavke * 0.03 * $Months
    return $taxRate
}

# Main script logic
# Get user input for the two dates and the Vrijednost Stavke
$StartDateInput = Read-Host "Enter DT002 Datum (format dd.MM.yyyy)"
$EndDateInput = Read-Host "Enter Datum Deklaracije (format dd.MM.yyyy)"

# Validate and parse the dates
try {
    $StartDate = [datetime]::ParseExact($StartDateInput, "dd.MM.yyyy", $null)
    $EndDate = [datetime]::ParseExact($EndDateInput, "dd.MM.yyyy", $null)

    # Validate date inputs
    if ($EndDate -lt $StartDate) {
        Write-Host "Error: Datum Deklaracije must be after DT002 Datum." -ForegroundColor Red
    } else {
        # Calculate full months between the dates
        $Months = Calculate-FullMonthsBetweenDates -StartDate $StartDate -EndDate $EndDate
        Write-Host "Broj mjeseci izmedu datuma: $Months" -ForegroundColor Green
    }
} catch {
    Write-Host "Error: Invalid input. Please ensure you are using the format dd.MM.yyyy." -ForegroundColor Red
}

# After showing the months, now get input for the Vrijednost Stavke (item value)
$VrijednostStavkeInput = Read-Host "Vrijednost Stavke"

# Validate and parse Vrijednost Stavke
try {
    $VrijednostStavke = [double]$VrijednostStavkeInput.Trim()

    # Calculate the tax rate
    $TaxRate = Calculate-TaxRate -VrijednostStavke $VrijednostStavke -Months $Months
    Write-Host "Osnovica: $TaxRate" -ForegroundColor Green
} catch {
    Write-Host "Error: Invalid input for Vrijednost Stavke." -ForegroundColor Red
}

# Wait for user to press Enter before closing the script
Write-Host "Press Enter to exit..."
Read-Host
