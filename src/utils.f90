module utils

    implicit none
    private

    public :: get_monthly_gross, get_annual_gross, make_label
contains

    pure real(8) function get_monthly_gross(gross, salaries, mode)
        real(8), intent(in) :: gross, salaries
        character(*), intent(in) :: mode
        if (mode == 'annum') then
            get_monthly_gross = gross / salaries
        else
            get_monthly_gross = gross
        end if
    end function get_monthly_gross

    pure real(8) function get_annual_gross(gross, salaries, mode)
        real(8), intent(in) :: gross, salaries
        character(*), intent(in) :: mode
        if (mode == 'annum') then
            get_annual_gross = gross
        else
            get_annual_gross = gross * salaries
        end if
    end function get_annual_gross

    pure character(34) function make_label(input, indent)
        character(*), intent(in)  :: input
        integer, intent(in), optional :: indent
        make_label = input//': '
         ! suprisingly, if (present(var).and.var) leads to a segmentation fault
        if (present(indent)) then
            if (indent > 0) then
                make_label = repeat(' ', indent)//trim(make_label)
            end if
        end if
    end function make_label

end module utils