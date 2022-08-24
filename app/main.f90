!< This program calculates German salary employer contributions.
program main

  use flap, only : command_line_interface
  use configs, only: bundeslands_all, bundesland_is_west, &
                     get_contributions, t_contribution_levels
  use utils, only: get_annual_gross, get_monthly_gross, make_label, west_east_string
  use calculations, only: calculate_kv, calculate_pv, calculate_rv, calculate_av, &
                          calculate_u1, calculate_u2, calculate_u3

  implicit none

  type(command_line_interface) :: cli ! Command Line Interface (CLI).
  real(8)                      :: gross, salaries, monthly_gross, annual_gross, &
                                  kv_personal, u1p, u2p
  integer(4)                   :: year
  character(5)                 :: gross_mode
  character(50)                :: bundesland

  integer         :: error  ! Error trapping flag.

  type(t_contribution_levels) :: contributions

  ! define calculation results
  ! TODO: apparently one can do class-like objects in Fortran...
  real(8) :: kv, pv, rv, av, u1, u2, u3, total
  real(8), dimension(8) :: to_sum

  ! init CLI
  call cli%init(description = 'Calculate employer contributions for gross salary')

  ! init flags
  call cli%add(switch='--gross', switch_ab='-g', help='Gross salary', &
               required=.true., &
               act='store',     &
               error=error)
  call cli%add(switch='--mode', switch_ab='-m', help='Gross salary mode', &
               required=.false.,      &
               act='store',           &
               def='annum',           &
               choices='annum,month', &
               error=error)
  call cli%add(switch='--salaries', switch_ab='-s', help='Number of salaries', &
               required=.false.,         &
               act='store',              &
               def='12.0',               &
               choices='12.0,13.0,14.0', &
               error=error)
  call cli%add(switch='--bundesland', switch_ab='-b', help='Bundesland', &
               required=.false.,           &
               act='store',                &
               def='Nordrhein-Westfalen',  &
               choices=trim(bundeslands_all()), &
               error=error)
  call cli%add(switch='--year', switch_ab='-yr', &
               help='Year for which the calculation should be done', &
               required=.false.,    &
               act='store',         &
               def='2023',          &
               choices='2022,2023', &
               error=error)

  call cli%add(switch='--kv-personal-contribution-percent', switch_ab='-kvp', &
               help='Personal health insurance contribution, in total percentage', &
               required=.false., &
               act='store',      &
               def='1.2',        &
               error=error)
  call cli%add(switch='--u1-contribution-percent', switch_ab='-u1', &
               help='The work incapacity protection contribution, in total percent (U1)', &
               required=.false., &
               act='store',      &
               def='1.6',        &
               error=error)
  call cli%add(switch='--u2-contribution-percent', switch_ab='-u2', &
               help='The maternity protection contribution, in total percent (U2)', &
               required=.false., &
               act='store',      &
               def='0.65',       &
               error=error)
  
  if (error/=0) stop

  ! get data passed on the command line
  call cli%get(switch='-g', val=gross, error=error)
  call cli%get(switch='-m', val=gross_mode, error=error)
  call cli%get(switch='-s', val=salaries, error=error)
  call cli%get(switch='-b', val=bundesland, error=error)
  call cli%get(switch='-yr', val=year, error=error)

  call cli%get(switch='-kvp', val=kv_personal, error=error)
  call cli%get(switch='-u1', val=u1p, error=error)
  call cli%get(switch='-u2', val=u2p, error=error)

  if (error/=0) stop

  ! Initialize contributions for the configured year
  contributions = get_contributions(kv_personal, u1p, u2p, year, bundesland)
  ! Get the annual and monthly salary
  annual_gross = get_annual_gross(gross, salaries, gross_mode)
  monthly_gross = get_monthly_gross(gross, salaries, gross_mode)
  ! Calculate
  kv = calculate_kv(monthly_gross, contributions) * salaries
  pv = calculate_pv(monthly_gross, contributions) * salaries
  rv = calculate_rv(monthly_gross, contributions) * salaries
  av = calculate_av(monthly_gross, contributions) * salaries

  u1 = calculate_u1(annual_gross, contributions)
  u2 = calculate_u2(annual_gross, contributions)
  u3 = calculate_u3(annual_gross, contributions)

  print '(a)', ''
  print '(a, a)',     make_label('Bundesland'), bundesland
  print '(a, a)',     make_label('West/East'), west_east_string(bundesland_is_west(bundesland))
  print '(a, a)',     make_label('Currency'), 'Euro'
  print '(a, f10.2)', make_label('Monthly gross salary'), monthly_gross
  print '(a, f10.2)', make_label('Annual gross salary'), annual_gross
  print '(a, f10.1)', make_label('# of salaries'), salaries
  print '(a)',       '--------------------------------------------|'
  print '(a)', 'Contributions breakdown:'
  print '(a, f10.2)', make_label('Kranenversicherung', indent=2), kv
  print '(a, f10.2)', make_label('Pflegeversicherung', indent=2), pv
  print '(a, f10.2)', make_label('Rentenversicherung', indent=2), rv
  print '(a, f10.2)', make_label('Arbeitslosenversicherung', indent=2), av
  print '(a)',       '--------------------------------------------|'
  print '(a)', 'Umlagen:'
  print '(a, a, f10.2)', make_label('U1 (Arbeitsunfähigkeit)', indent=2), ' ', u1 ! extra space because we have an umlaut...
  print '(a, f10.2)',    make_label('U2 (Mutterschaft)', indent=2), u2
  print '(a, f10.2)',    make_label('U3 (Insolvenz)', indent=2), u3
  print '(a)',       '--------------------------------------------|'

  to_sum = [ annual_gross, kv, pv, rv, av, u1, u2, u3 ]
  total = sum(to_sum(1: 8))

  print '(a, f10.2)', make_label('Total annual employee cost'), total
  print '(a)', ''

end program main
