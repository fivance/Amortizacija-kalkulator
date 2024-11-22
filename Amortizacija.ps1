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

# Create a Window
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

$Window = New-Object system.Windows.Window
$Window.Title = "Amortizacija obracun"
$Window.Width = 400
$Window.Height = 400
$Window.ResizeMode = "NoResize"
$Window.WindowStartupLocation = "CenterScreen"

# Set dark mode background to #1A1A1A and white foreground
$Window.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(26, 26, 26))  # RGB for #1A1A1A
$Window.Foreground = [System.Windows.Media.Brushes]::White

# Create a Grid layout with 2 columns (Label + TextBox) and 6 rows (for labels, buttons)
$Grid = New-Object System.Windows.Controls.Grid
$Grid.Margin = "10"

# Define columns for labels and textboxes
$Grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
$Grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))

# Define rows for the controls (inputs + buttons)
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))  # Row 0
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))  # Row 1
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))  # Row 2
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))  # Row 3
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))  # Row 4
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))  # Row 5

$Window.Content = $Grid

# Add Labels and TextBoxes to Grid
$labels = @(
    "DT002 Datum:",
    "Datum Deklaracije:",
    "Vrijednost Stavke:",
    "Osnovica (Tax rate):"
)
$fields = @()

for ($i = 0; $i -lt $labels.Length; $i++) {
    # Create and add Label
    $Label = New-Object System.Windows.Controls.Label
    $Label.Content = $labels[$i]
    $Label.Margin = "5"
    $Label.HorizontalAlignment = "Left"
    $Label.VerticalAlignment = "Center"
    $Label.Foreground = [System.Windows.Media.Brushes]::White
    [void]$Grid.Children.Add($Label)
    [System.Windows.Controls.Grid]::SetRow($Label, $i)
    [System.Windows.Controls.Grid]::SetColumn($Label, 0)

    # Create and add TextBox
    $TextBox = New-Object System.Windows.Controls.TextBox
    $TextBox.Margin = "5"
    $TextBox.Width = 120
    $TextBox.HorizontalAlignment = "Center"
    $TextBox.VerticalAlignment = "Center"
    $TextBox.Background = [System.Windows.Media.Brushes]::White
    $TextBox.Foreground = [System.Windows.Media.Brushes]::Black
    $fields += $TextBox
    [void]$Grid.Children.Add($TextBox)
    [System.Windows.Controls.Grid]::SetRow($TextBox, $i)
    [System.Windows.Controls.Grid]::SetColumn($TextBox, 1)
}

# Add "Izracunaj broj mjeseci" Button (to show popup with months calculation)
$MonthsButton = New-Object System.Windows.Controls.Button
$MonthsButton.Content = "Izracunaj broj mjeseci"
$MonthsButton.Margin = "10"
$MonthsButton.Width = 220
$MonthsButton.HorizontalAlignment = "Center"
$MonthsButton.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(30, 86, 227))
$MonthsButton.Foreground = [System.Windows.Media.Brushes]::White
$MonthsButton.Add_Click({
    try {
        # Parse user inputs
        $StartDate = [datetime]::ParseExact($fields[0].Text, "dd.MM.yyyy", $null)
        $EndDate = [datetime]::ParseExact($fields[1].Text, "dd.MM.yyyy", $null)

        # Validate inputs
        if ($EndDate -lt $StartDate) {
            [System.Windows.MessageBox]::Show("Datum Deklaracije mora biti posle DT002 datuma.", "Greska", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        } else {
            # Calculate the actual number of months
            $ActualMonths = Calculate-FullMonthsBetweenDates -StartDate $StartDate -EndDate $EndDate

            # Show result in a popup
            [System.Windows.MessageBox]::Show("Broj mjeseci izmedju datuma je: $ActualMonths", "Broj Mjeseci", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
    } catch {
        [System.Windows.MessageBox]::Show("Greska: Neispravan format unosa. Koristite 'dd.MM.yyyy'.", "Greska", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

# Add the Months Button to Grid (Row 4)
[void]$Grid.Children.Add($MonthsButton)
[System.Windows.Controls.Grid]::SetRow($MonthsButton, 4)
[System.Windows.Controls.Grid]::SetColumn($MonthsButton, 0)
[System.Windows.Controls.Grid]::SetColumnSpan($MonthsButton, 2)

# Add "Izracunaj" Button (to calculate the tax rate)
$Button = New-Object System.Windows.Controls.Button
$Button.Content = "Izracunaj"
$Button.Margin = "10"
$Button.Width = 100
$Button.HorizontalAlignment = "Center"
$Button.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(30, 86, 227))
$Button.Foreground = [System.Windows.Media.Brushes]::White
$Button.Add_Click({
    try {
        # Parse user inputs
        $StartDate = [datetime]::ParseExact($fields[0].Text, "dd.MM.yyyy", $null)
        $EndDate = [datetime]::ParseExact($fields[1].Text, "dd.MM.yyyy", $null)
        $VrijednostStavke = [double]$fields[2].Text.Trim()

        # Validate inputs
        if ($EndDate -lt $StartDate) {
            [System.Windows.MessageBox]::Show("Datum Deklaracije mora biti posle DT002 datuma.", "Greska", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        } else {
            # Calculate full months and tax rate
            $Months = Calculate-FullMonthsBetweenDates -StartDate $StartDate -EndDate $EndDate
            $TaxRate = Calculate-TaxRate -VrijednostStavke $VrijednostStavke -Months $Months

            # Display result in the "Osnovica" field without the "Osnovica: " text
            $fields[3].Text = "$TaxRate"
        }
    } catch {
        [System.Windows.MessageBox]::Show("Greska: Neispravan format unosa. Koristite 'dd.MM.yyyy'.", "Greska", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

# Add Izracunaj Button to Grid (Row 5)
[void]$Grid.Children.Add($Button)
[System.Windows.Controls.Grid]::SetRow($Button, 5)
[System.Windows.Controls.Grid]::SetColumn($Button, 0)
[System.Windows.Controls.Grid]::SetColumnSpan($Button, 2)

# Show Window
$Window.ShowDialog()
