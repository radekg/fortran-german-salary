module german_salary

  use configs, only: t_contribution_levels, western

  implicit none
  private

  public :: calculate_kv, calculate_pv, calculate_rv, calculate_av, &
            calculate_u1, calculate_u2, calculate_u3, &
            is_west
contains

  pure function calculate_kv(monthly_gross, contributions) result(kv)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: kv
    kv = min(kv_cutoff(), monthly_gross) * (contributions%kv + contributions%kv_personal)
  end function calculate_kv

  pure function calculate_pv(monthly_gross, contributions) result(kv)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: kv
    kv = min(pv_cutoff(), monthly_gross) * contributions%pv
  end function calculate_pv

  pure function calculate_rv(monthly_gross, contributions) result(kv)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: kv
    kv = min(rv_cutoff(is_west(contributions%bundesland)), monthly_gross) * contributions%rv
  end function calculate_rv

  pure function calculate_av(monthly_gross, contributions) result(kv)
    real(8), intent(in) :: monthly_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: kv
    kv = min(av_cutoff(is_west(contributions%bundesland)), monthly_gross) * contributions%av
  end function calculate_av

  pure function calculate_u1(annual_gross, contributions) result(u)
    real(8), intent(in) :: annual_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: u
    u = annual_gross * contributions%u1
  end function calculate_u1

  pure function calculate_u2(annual_gross, contributions) result(u)
    real(8), intent(in) :: annual_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: u
    u = annual_gross * contributions%u2
  end function calculate_u2

  pure function calculate_u3(annual_gross, contributions) result(u)
    real(8), intent(in) :: annual_gross
    type(t_contribution_levels), intent(in) :: contributions
    real(8) :: u
    u = annual_gross * contributions%u3
  end function calculate_u3

  ! Private functions

  pure function pv_cutoff () result(cutoff)
    real :: cutoff
    cutoff = 4837.5
  end function pv_cutoff

  pure function kv_cutoff () result(cutoff)
    real :: cutoff
    cutoff = 4837.5
  end function kv_cutoff

  pure function rv_cutoff (west) result(cutoff)
    logical, intent(in) :: west
    real :: cutoff
    if (west) then
      cutoff = 7050.0
    else
      cutoff = 6750.0
    end if
  end function rv_cutoff

  pure function av_cutoff (west) result(cutoff)
    logical, intent(in) :: west
    real :: cutoff
    if (west) then
      cutoff = 7050.0
    else
      cutoff = 6750.0
    end if
  end function av_cutoff

  pure function is_west(bundesland) result(is)
    character(50), intent(in) :: bundesland
    logical :: is
    is = any(western() == bundesland)
  end function is_west

end module german_salary
