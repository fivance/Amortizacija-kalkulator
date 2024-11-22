Add-Type -AssemblyName PresentationFramework

# Function to calculate full months between dates
Function Calculate-FullMonthsBetweenDates {
    param (
        [datetime]$StartDate,
        [datetime]$EndDate
    )

    # If the dates are on the same day in the same month, return 1 month
    if ($StartDate.Date -eq $EndDate.Date) {
        return 1
    }

    # If the start and end dates are in the same month and year but differ by days
    if ($StartDate.Month -eq $EndDate.Month -and $StartDate.Year -eq $EndDate.Year) {
        return 1
    }

    # Calculate the total number of months between the dates
    $totalMonths = ($EndDate.Year - $StartDate.Year) * 12 + ($EndDate.Month - $StartDate.Month)

    # Check if the end date is before the start day in the month
    if ($EndDate.Day -lt $StartDate.Day) {
        $fullMonths = $totalMonths - 1
    } else {
        $fullMonths = $totalMonths
    }

    # If the total months are greater than or equal to 1, but full months are 0, set it to 1 month
    if ($totalMonths -ge 1 -and $fullMonths -eq 0) {
        $fullMonths = 1
    }

    return $fullMonths
}

# Function to calculate tax rate based on the number of months
Function Calculate-TaxRate {
    param (
        [double]$VrijednostStavke,
        [int]$Months,
        [datetime]$StartDate,
        [datetime]$EndDate
    )

    if ($StartDate.Day -eq $EndDate.Day) {
        $effectiveMonths = $Months
    }
    elseif ($StartDate.Day -lt $EndDate.Day) {
        $effectiveMonths = $Months + 1
    } else {
        $effectiveMonths = $Months
    }

    $taxRate = $VrijednostStavke * 0.03 * $effectiveMonths
    return $taxRate
}

# Create a Window
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

$Window = New-Object system.Windows.Window
$Window.Title = "Amortizacija obracun"
$Window.Width = 400  # Adjust the width of the window
$Window.Height = 400  # Adjust the height of the window
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
    "Osnovica (Tax Rate):"
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

# Add Calculate Button for Actual Months
$ActualMonthsButton = New-Object System.Windows.Controls.Button
$ActualMonthsButton.Content = "Izracunaj stvarni broj mjeseci"
$ActualMonthsButton.Margin = "10"
$ActualMonthsButton.Width = 220
$ActualMonthsButton.HorizontalAlignment = "Center"
$ActualMonthsButton.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(30, 86, 227))
$ActualMonthsButton.Foreground = [System.Windows.Media.Brushes]::White
$ActualMonthsButton.Add_Click({
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

            # Display result in a message box
            [System.Windows.MessageBox]::Show("Stvarni broj mjeseci: $ActualMonths", "Rezultat", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
    } catch {
        [System.Windows.MessageBox]::Show("Greska: Neispravan format unosa. Koristite 'dd.MM.yyyy'.", "Greska", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

# Add the Actual Months button to Grid (Row 4)
[void]$Grid.Children.Add($ActualMonthsButton)
[System.Windows.Controls.Grid]::SetRow($ActualMonthsButton, 4)
[System.Windows.Controls.Grid]::SetColumn($ActualMonthsButton, 0)
[System.Windows.Controls.Grid]::SetColumnSpan($ActualMonthsButton, 2)

# Add Izracunaj Button (Tax Rate Calculation)
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
            $TaxRate = Calculate-TaxRate -VrijednostStavke $VrijednostStavke -Months $Months -StartDate $StartDate -EndDate $EndDate

            # Display results
            $fields[3].Text = "$TaxRate"
        }
    } catch {
        [System.Windows.MessageBox]::Show("Greska: Neispravan format unosa. Koristite 'dd.MM.yyyy'.", "Greska", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

# Add the Calculate (Izracunaj) button to Grid (Row 5)
[void]$Grid.Children.Add($Button)
[System.Windows.Controls.Grid]::SetRow($Button, 5)
[System.Windows.Controls.Grid]::SetColumn($Button, 0)
[System.Windows.Controls.Grid]::SetColumnSpan($Button, 2)

# Show the Window
[void]$Window.ShowDialog()
