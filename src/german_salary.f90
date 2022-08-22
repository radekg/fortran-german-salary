module german_salary

  use configs, only: western

  implicit none
  private

  public :: calculate_kv, calculate_pv, calculate_rv, calculate_av, &
            calculate_u1, calculate_u2, calculate_u3, &
            is_west
contains

  pure function calculate_kv(monthly_gross) result(kv)
    real(8), intent(in) :: monthly_gross
    real(8) :: kv
    kv = min(kv_cutoff(), monthly_gross) * (0.073 + 0.006)
  end function calculate_kv

  pure function calculate_pv(monthly_gross) result(kv)
    real(8), intent(in) :: monthly_gross
    real(8) :: kv
    kv = min(pv_cutoff(), monthly_gross) * 0.01525
  end function calculate_pv

  pure function calculate_rv(monthly_gross, bundesland) result(kv)
    real(8), intent(in) :: monthly_gross
    character(50), intent(in) :: bundesland
    real(8) :: kv
    kv = min(rv_cutoff(is_west(bundesland)), monthly_gross) * 0.093
  end function calculate_rv

  pure function calculate_av(monthly_gross, bundesland) result(kv)
    real(8), intent(in) :: monthly_gross
    character(50), intent(in) :: bundesland
    real(8) :: kv
    kv = min(av_cutoff(is_west(bundesland)), monthly_gross) * 0.012
  end function calculate_av

  function calculate_u1(annual_gross) result(u)
    real(8) :: annual_gross, u
    u = annual_gross * 0.016
  end function calculate_u1

  function calculate_u2(annual_gross) result(u)
    real(8) :: annual_gross, u
    u = annual_gross * 0.0065
  end function calculate_u2

  function calculate_u3(annual_gross) result(u)
    real(8) :: annual_gross, u
    u = annual_gross * 0.0009
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
