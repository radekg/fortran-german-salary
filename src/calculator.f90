module calculator

    use types, only: ContributionLevels

    implicit none

    private

    public :: SalaryCalculator

    type :: SalaryCalculator
        type(ContributionLevels) :: contributions
        real(8) :: gross_value
        integer(4) :: salaries
        character(5) :: mode
        ! Populated by the constructor:
        real(8) :: calculated_kv
        real(8) :: calculated_pv
        real(8) :: calculated_rv
        real(8) :: calculated_av
        real(8) :: calculated_u1
        real(8) :: calculated_u2
        real(8) :: calculated_u3
        real(8) :: calculated_gross_annual
        real(8) :: calculated_gross_monthly
        real(8) :: calculated_total
    contains
        private
            procedure, pass(self) :: calculate
            procedure, pass(self) :: calculate_kv
            procedure, pass(self) :: calculate_pv
            procedure, pass(self) :: calculate_rv
            procedure, pass(self) :: calculate_av
            procedure, pass(self) :: calculate_u1
            procedure, pass(self) :: calculate_u2
            procedure, pass(self) :: calculate_u3
            procedure, pass(self) :: get_annual_gross
            procedure, pass(self) :: get_monthly_gross
            procedure, pass(self) :: total_annual_cost
    end type

    interface SalaryCalculator
        ! Define a constructor function for the salary calculator.
        module procedure :: new_salary_calculator
    end interface

contains

    pure type(SalaryCalculator) function new_salary_calculator( &
        contributions, gross_value, salaries, mode) result(res)
        ! This function is a SalaryCalculator constructor.
        type(ContributionLevels), intent(in) :: contributions
        real(8), intent(in) :: gross_value
        integer(4), intent(in) :: salaries
        character(5), intent(in) :: mode
        res%contributions = contributions
        res%gross_value = gross_value
        res%salaries = salaries
        res%mode = mode
        call res%calculate()
    end function new_salary_calculator

    pure subroutine calculate(self)
        ! This routine recalculates the salary data based on the input.
        class(SalaryCalculator), intent(in out) :: self
        self%calculated_gross_annual = self%get_annual_gross()
        self%calculated_gross_monthly = self%get_monthly_gross()
        self%calculated_kv = self%calculate_kv()
        self%calculated_pv = self%calculate_pv()
        self%calculated_rv = self%calculate_rv()
        self%calculated_av = self%calculate_av()
        self%calculated_u1 = self%calculate_u1()
        self%calculated_u2 = self%calculate_u2()
        self%calculated_u3 = self%calculate_u3()
        self%calculated_total = self%total_annual_cost()
    end subroutine calculate

    pure real(8) function calculate_kv(self)
        class(SalaryCalculator), intent(in) :: self    
        calculate_kv = min(self%contributions%cutoff_kv(), self%get_monthly_gross()) &
            * self%contributions%kv() * self%salaries
    end function calculate_kv

    pure real(8) function calculate_pv(self)
        class(SalaryCalculator), intent(in) :: self
        calculate_pv = min(self%contributions%cutoff_pv(), self%get_monthly_gross()) &
            * self%contributions%pv() * self%salaries
    end function calculate_pv

    pure real(8) function calculate_rv(self)
        class(SalaryCalculator), intent(in) :: self
        calculate_rv = min(self%contributions%cutoff_rv(), self%get_monthly_gross()) &
            * self%contributions%rv() * self%salaries
    end function calculate_rv

    pure real(8) function calculate_av(self)
        class(SalaryCalculator), intent(in) :: self
        calculate_av = min(self%contributions%cutoff_av(), self%get_monthly_gross()) &
            * self%contributions%av() * self%salaries
    end function calculate_av

    pure real(8) function calculate_u1(self)
        class(SalaryCalculator), intent(in) :: self
        calculate_u1 = self%get_annual_gross() * self%contributions%u1()
    end function calculate_u1

    pure real(8) function calculate_u2(self)
        class(SalaryCalculator), intent(in) :: self
        calculate_u2 = self%get_annual_gross() * self%contributions%u2()
    end function calculate_u2

    pure real(8) function calculate_u3(self)
        class(SalaryCalculator), intent(in) :: self
        calculate_u3 = self%get_annual_gross() * self%contributions%u3()
    end function calculate_u3

    pure real(8) function get_annual_gross(self)
        class(SalaryCalculator), intent(in) :: self
        if (self%mode == 'annum') then
            get_annual_gross = self%gross_value
        else
            get_annual_gross = self%gross_value * self%salaries
        end if
    end function get_annual_gross

    pure real(8) function get_monthly_gross(self)
        class(SalaryCalculator), intent(in) :: self
        if (self%mode == 'annum') then
            get_monthly_gross = self%gross_value / self%salaries
        else
            get_monthly_gross = self%gross_value
        end if
    end function get_monthly_gross

    pure real(8) function total_annual_cost(self)
        class(SalaryCalculator), intent(in) :: self
        real(8) :: to_sum(8)
        to_sum = [ self%calculated_gross_annual,    &
            self%calculated_kv,                     &
            self%calculated_pv,                     &
            self%calculated_rv,                     &
            self%calculated_av,                     &
            self%calculated_u1,                     &
            self%calculated_u2,                     &
            self%calculated_u3 ]
        total_annual_cost = sum(to_sum(1: 8))
    end function total_annual_cost

end module calculator
