module calculations

    use types, only: ContributionLevels

    implicit none
    private

    public :: calculate_kv, calculate_pv, calculate_rv, calculate_av, &
              calculate_u1, calculate_u2, calculate_u3

contains

    pure real(8) function calculate_kv(monthly_gross, contributions)
        real(8), intent(in) :: monthly_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_kv = min(contributions%cutoff_kv(), monthly_gross) &
            * contributions%kv()
    end function calculate_kv

    pure real(8) function calculate_pv(monthly_gross, contributions)
        real(8), intent(in) :: monthly_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_pv = min(contributions%cutoff_pv(), monthly_gross) &
            * contributions%pv()
    end function calculate_pv

    pure real(8) function calculate_rv(monthly_gross, contributions)
        real(8), intent(in) :: monthly_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_rv = min(contributions%cutoff_rv(), monthly_gross) &
            * contributions%rv()
    end function calculate_rv

    pure real(8) function calculate_av(monthly_gross, contributions)
        real(8), intent(in) :: monthly_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_av = min(contributions%cutoff_av(), monthly_gross) &
            * contributions%av()
    end function calculate_av

    pure real(8) function calculate_u1(annual_gross, contributions)
        real(8), intent(in) :: annual_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_u1 = annual_gross * contributions%u1()
    end function calculate_u1

    pure real(8) function calculate_u2(annual_gross, contributions)
        real(8), intent(in) :: annual_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_u2 = annual_gross * contributions%u2()
    end function calculate_u2

    pure real(8) function calculate_u3(annual_gross, contributions)
        real(8), intent(in) :: annual_gross
        type(ContributionLevels), intent(in) :: contributions
        calculate_u3 = annual_gross * contributions%u3()
    end function calculate_u3

end module calculations
