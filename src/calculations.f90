module calculations

  use configs, only: t_contribution_levels, western

  implicit none
  private

  public :: calculate_kv, calculate_pv, calculate_rv, calculate_av, &
            calculate_u1, calculate_u2, calculate_u3, &
            is_west
contains

  pure real(8) function calculate_kv(monthly_gross, contributions)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_kv = min(kv_cutoff(), monthly_gross) * (contributions%kv + contributions%kv_personal)
  end function calculate_kv

  pure real(8) function calculate_pv(monthly_gross, contributions)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_pv = min(pv_cutoff(), monthly_gross) * contributions%pv
  end function calculate_pv

  pure real(8) function calculate_rv(monthly_gross, contributions)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_rv = min(rv_cutoff(is_west(contributions%bundesland)), monthly_gross) * contributions%rv
  end function calculate_rv

  pure real(8) function calculate_av(monthly_gross, contributions)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_av = min(av_cutoff(is_west(contributions%bundesland)), monthly_gross) * contributions%av
  end function calculate_av

  pure real(8) function calculate_u1(annual_gross, contributions)
    real(8), intent(in) :: annual_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_u1 = annual_gross * contributions%u1
  end function calculate_u1

  pure real(8) function calculate_u2(annual_gross, contributions)
    real(8), intent(in) :: annual_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_u2 = annual_gross * contributions%u2
  end function calculate_u2

  pure real(8) function calculate_u3(annual_gross, contributions)
    real(8), intent(in) :: annual_gross
    type(t_contribution_levels), intent(in) :: contributions
    calculate_u3 = annual_gross * contributions%u3
  end function calculate_u3

  ! Private functions

  pure real function pv_cutoff()
    pv_cutoff = 4837.5
  end function pv_cutoff

  pure real function kv_cutoff()
    kv_cutoff = 4837.5
  end function kv_cutoff

  pure real function rv_cutoff(west)
    logical, intent(in) :: west
    rv_cutoff = 7050.0
    if (.not.west) then
      rv_cutoff = 6750.0
    end if
  end function rv_cutoff

  pure real function av_cutoff (west) result(cutoff)
    logical, intent(in) :: west
    if (west) then
      cutoff = 7050.0
    else
      cutoff = 6750.0
    end if
  end function av_cutoff

  pure logical function is_west(bundesland)
    character(50), intent(in) :: bundesland
    is_west = any(western() == bundesland)
  end function is_west

end module calculations
