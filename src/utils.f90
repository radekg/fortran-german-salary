module utils

    implicit none
    private

    public :: get_monthly_gross, get_annual_gross, make_label, west_east_string
contains

    pure function get_monthly_gross(gross, salaries, mode) result(monthly)
        real(8), intent(in) :: gross, salaries
        character(5), intent(in) :: mode
        real(8) :: monthly
        if (mode == 'annum') then
            monthly = gross / salaries
        else
            monthly = gross
        end if
    end function get_monthly_gross

    pure function get_annual_gross(gross, salaries, mode) result(annual)
        real(8), intent(in) :: gross, salaries
        character(5), intent(in) :: mode
        real(8) :: annual
        if (mode == 'annum') then
            annual = gross
        else
            annual = gross * salaries
        end if
    end function get_annual_gross

    pure function make_label (input, indent) result(output)
        character(len=*), intent(in) :: input
        logical, intent(in)         :: indent
        character(34)               :: output
        output = input//': '
        if (indent) then
            output = '  '//trim(output)
        end if
    end function make_label

    pure function west_east_string(input) result(output)
        logical, intent(in) :: input
        character(20) :: output
        if (input) then
            output = "West"
        else
            output = "East"
        end if
    end function west_east_string

end module utils